---
title: "Resolver Functions"
description: "Resolver Functions"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 7
---

## {$page.title}

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

```JSON
G.ObjectType bookType = new G.ObjectType('Book', 'Book__c')
    .addField('id', G.StringType, 'Id')
    .addField('name', G.StringType, 'Name')
    .addField('author', new G.ReferenceType('Author'), new BookAuthorResolver());
```

`BookAuthorResolver` is provided to `author` field, so that whenever the relationship is required, the resolver function will be invoked.

Here is what `BookAuthorResolver` looks like:

```javascript
private class BookAuthorResolver implements G.Resolver {
    public Object resolve(Map<String, Object> parent, Map<String, Object> args, G.ResolvingContext context) {
        return R.of(authors).find(R.propEq.apply('id', parent.get('authorId'))).toMap();
    }
}
```

In the resolver, we find the author that matches the `authorId` of the book from the list of authors.

Notice here that we are using a resolver that does not take a batch. If we want to use a batch resolver, we do it like this:

```javascript
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
