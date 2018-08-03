# G.apex
G.apex is a library to set up GraphQL-lite features in Apex.

## Why G.apex?
GraphQL is flexible and powerful, yet there is no direct support in Apex. G.apex addresses this issue by developing a GraphQL-like query language to offer most of the GraphQL benefits on Salesforce platform. G.apex is not GraphQL-compatible, but it adopts the same paradigm in development, so that it lowers the learning curve.

## Dependencies
G.apex has a dependency over [R.apex](https://github.com/Click-to-Cloud/R.apex/) .

Please include it before including G.apex.

## Preliminary Knowledge
G.apex has a dependency over R.apex, but you don't have to use anything from R.apex if prefer not.

## Getting Started

### G.apex Demo
G.apex provides a Lightning component for you to explore the features of G.apex.

To use this component after installing G.apex, simply create a Lightning tab and select c:G_apex_demo in the dropdown list. Then visit the tab link in your org.

The top part of the component is the Query Editor, where you can edit your G.apex query and execute them against a small set of data.

![Query Editor](/images/query_small.png "Query Editor")

The bottom part of the component is the Schema Explorer, which exposes all the object types defined in your root schema. Click on the link to jump to the details of the object type.

![Schema Explorer](/images/schema_small.png "Schema Explorer")

### G.apex Query

G.apex uses a different query syntax from GraphQL. It uses JSON format like this:

```JSON
{
    "query": {
        "book": {
            "@id": "2",
            "name": ""
        }
    }
}
```

This is somehow equivalent to the true GraphQL below:

```
{
    book(id: 2) {
        name
    }
}
```

This query will yield results like this:

```JSON
{
    "query": {
        "book": {
            "name": "Second Book"
        }
    }
}
```

For those who are not familiar with GraphQL, the code above means that we want to query the book with `id` equals to 2, retrieving the `name` of the book.

We use JSON to define the query language primarily because we want to avoid unnecessary use of compute in Apex considering the governor limits.

### Create Object Types
To start with, we create some simple Object Types.

```java
G.ObjectType bookType = new G.ObjectType('Book', 'Book__c')
    .addField('id', G.StringType, 'Id')
    .addField('name', G.StringType, 'Name');
```

Here we created an ObjectType of `Book`, bound to SObject type `Book__c`. The book type has two fields, `id` of String type and `name` of String type.

### Create Schema
We need to define access points on our schema so that our data is accessible.

```java
G.Schema schema = new G.Schema()
    .add(
        new G.ObjectType('query')
            .addField('books', new G.ListType(bookType), R.constant.apply(new List<Object>{ books }))
    );
```

Here we defined a new ObjectType `query`, with the field `books` that can retrive a list of books. Then we add this object type to the schema. `R.constant.apply(new List<Object>{ books })` here is a resolver Func that always returns the list of list of books whenever called. A resolver can be implemented by either a Func or an instance of `BatchResolver` or `Resolver`.

You might feel strange why we return a list of list of books. The reason is that by default our resolver function is invoked by batch to improve performance. We will see this later.

### Resolver Functions
In G.apex, we fetch information based on each nodes. When it comes to the relationship between different nodes, we use resolver functions to handle.

Consider the query below:

```JSON
{
    "query": {
        "book": {
            "@id": "2",
            "name": "",
            "author": {
                 "name": ""
             }
        }
    }
}
```

We want to further get the author information related to the book. In this case, we define our book type as below.

```java
G.ObjectType bookType = new G.ObjectType('Book', 'Book__c')
    .addField('id', G.StringType, 'Id')
    .addField('name', G.StringType, 'Name')
    .addField('author', new G.ReferenceType('Author'), new BookAuthorResolver());
```

`BookAuthorResolver` is provided to `author` field, so that whenever the relationship is required, the resolver function will be invoked.

Here is what `BookAuthorResolver` looks like:

```java
private class BookAuthorResolver implements G.Resolver {
    public Object resolve(Map<String, Object> parent, Map<String, Object> args, G.ResolvingContext context) {
        return R.of(authors).find(R.propEq.apply('id', parent.get('authorId'))).toMap();
    }
}
```

In the resolver, we find the author that matches the `authorId` of the book from the list of authors.

Notice here that we are using a resolver that does not take a batch. If we want to use a batch resolver, we do it like this:

```java
private class AuthorBooksResolver implements G.BatchResolver {
    public List<Object> resolve(List<Object> parents, Map<String, Object> args, G.ResolvingContext context) {
        List<Object> result = new List<Object>();

        for(Object parentObj : parents) {
            Map<String, Object> parent = (Map<String, Object>)parentObj;
            List<Object> found = R.of(books).filter(R.propEq.apply('authorId', parent.get('id'))).toList();
            result.add(found);
        }

        return result;
    }
}
```

In this resolver, we get the list of books related to the author based on the passed in list of parents.

Basically batch resolvers should be used if there is such operation like doing DML operations or querying or making http requests.

### Serve Query Request
Our building work is done. Next we can provide our query service. The core API is below:

```java
Map<String, Object> result = (Map<String, Object>)G.execute(query);
```

`query` here is the G.apex query JSON string. And the `result` is the data after processing the query.

### Mutation
G.apex treats query and mutation similarly. We can define our mutation operations in the schema, and process the requests in the resolving functions.

```java
G.Schema schema = new G.Schema()
    .add(
        new G.ObjectType('mutation')
            .addField('addBook', bookType, new AddBookResolver())
                .addParam('addBook', 'name', G.StringType, R.isNotNull)
    );
```

We add a parameter definition `name` of String type to the field `addBook`. Also this parameter has a validation of not-null specified by the `R.isNotNull` Func.

### Parameters
G.apex query support passing parameters.

```JSON
{
    "query": {
        "book": {
            "@id": "2",
            "name": "",
            "author": {
                 "name": ""
             }
        }
    }
}
```

A parameter `id` is added to `book` in this example. Parameters are always prefixed with `@`.

### Default Value

We can specify the default values in G.apex query.

```JSON
{
    "query": {
        "book": {
            "@id": "2",
            "name": "",
            "author": {
                 "name": "Unknown author"
             }
        }
    }
}
```

Here if the author of the book is not found, `Unknown author` will be returned as the default value.

### Aliases

We can specify aliases in our G.apex query, so that the query result can be tailored to our needs.

```JSON
{
    "query": {
        "my_book:book": {
            "@id": "2",
            "name": ""
        },
        "her_book:book": {
            "@id": "3",
            "name": ""
        }
    }
}
```

The result will look like:

```JSON
{
    "query": {
        "her_book": {
            "name": "Third Book"
        },
        "my_book": {
            "name": "Second Book"
        }
    }
}
```

Here we use `:` to separate the alias and the field name.

### Fragments

We can create fragments to reuse some of our definitions in the G.apex query.

```JSON
{
    "query": {
        "book": {
            "@id": "2",
            "name": "",
            "...author": ""
        }
    },
    "...author": {
        "author": {
            "name": ""
        }
    }
}
```

Produces:

```JSON
{
    "query": {
        "book": {
            "author": {
                "name": "First Author"
            },
            "name": "Second Book"
        }
    }
}
```

Here we define a fragment named `...author` at the root of the query, and anywhere else it is used, it will be replaced by the fragment. Fragments are defined by prepending `...`.

### Variables

Simple variables are supported in G.apex query.

```JSON
{
    "query": {
        "book": {
            "@id": "2",
            "$var": ""
        }
    },
    "$var": "name"
}
```

We define a variable `$var` at the root of the query, and anywhere else it is used, it will be replace by the value `name`. Variables are defined by prepending `$`.

### Directives

We can control the behavior of the G.apex query by applying directives.

```JSON
{
    "query": {
        "book": {
            "#include": {
                "if": "$showBook"
            },
            "@id": "2",
            "name": ""
        }
    },
    "$showBook": "false"
}
```

Here `#include` is a directive, which will include fields of `book` only when `if` is true. As we are in JSON, we have to quote variables with double quotes. But it does not matter as G.apex will still correctly parse its value according to the data type we have specified.

Directives in G.apex start with `#`. We can also define custom directives in G.apex.
