---
title: "G.apex Core"
description: "G.apex Core"
layout: "guide"
icon: "flash"
weight: 1
---

###### {$page.description}

<article id="1">

## What is G.apex?

G.apex is a library that helps you adopt GraphQL features in Apex.

</article>

<article id="2">

## What is G.apex Query?

G.apex Query is a JSON query that very much resembles GraphQL queries.

</article>

<article id="3">

## Is G.apex compatible with GraphQL?

Sadly no. G.apex adopts similar concepts from GraphQL, but is tuned for Salesforce Apex and is therefore
not compatible with GraphQL specification.

</article>

<article id="4">

## Why G.apex Query?

Influenced by GraphQL, G.apex query can help you build flexible service end points.

For example, normal RESTful end point like below can get you a book:

```
https://<DOMAIN>/api/v2/book/{id}
```

However, you have to code every single end point like this, and they are just not as flexible and composable.

Say what if I want to get some extra fields of the book? what if I also want to get the related author of the book?

G.apex can help you build a more flexible and composable end point like this:

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

You can control the fields of the result by adding or removing extra fields. Or you can get the related author easily like this:

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

And you can nest as you like:

```JSON
{
    "query": {
        "book": {
            "@id": "2",
            "name": "",
            "author": {
                "name": "",
                "books": {
                    "name": ""
                }
             }
        }
    }
}
```

</article>

<article id="5">

## Core G.apex Concepts

Below are the most important concepts in G.apex.

- Schema

A schema is the whole collection of the DataTypes defined. There is usually only one instance of Schema, registered
globally to G.apex. The schema defines the graph.

- Data Type

Various data types construct the query system. Simple data types can help build the basic data, while more complicated
object types are used everywhere to define objects. Object types are more important in that they offer the main functionality
to encapsulate the data and relate with each other. Object types are just like the vertexes in the graph.

- Resolving

Resolving is the process when an object type tries to find its related object types. Basically, object types are
supposed to be self-independent and should not concern other object type data. Only when a relationship is required do the object types
start resolving the related object types. The resolving function provides the ability to navigate between vertexes in the graph.

</article>

<article id="6">

## Example

Here is an example of the schema and object types:

```javascript
private static G.ObjectType bookType = new G.ObjectType('Book', 'Book__c')
    .addField('id', G.StringType, 'Id')
    .addField('name', G.StringType, 'Name')
    .addField('author', new G.ReferenceType('Author'), new BookAuthorResolver());

private static G.ObjectType authorType = new G.ObjectType('Author')
    .addField('id', G.StringType)
    .addField('name', G.StringType)
    .addField('books', new G.ListType(new G.ReferenceType('Book')), new AuthorBooksResolver());

private static G.Schema schema = new G.Schema()
    .add(
        new G.ObjectType('query')
            .addField('books', new G.ListType(bookType), R.constant.apply(new List<Object>{ books }))
            .addField('book', bookType, new GetBookResolver())
                .addParam('book', 'id', G.StringType, R.isNotNull)
            .addField('authors', new G.ListType(authorType), R.constant.apply(new List<Object>{ authors }))
            .addField('author', authorType, new GetAuthorResolver())
                .addParam('author', 'id', G.StringType, R.isNotNull)
    );

private class BookAuthorResolver implements G.Resolver {
    public Object resolve(Map<String, Object> parent, Map<String, Object> args, G.ResolvingContext context) {
        return R.of(authors).find(R.propEq.apply('id', parent.get('authorId'))).toMap();
    }
}

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

private class GetAuthorResolver implements G.Resolver {
    public Object resolve(Map<String, Object> parent, Map<String, Object> args, G.ResolvingContext context) {
        return R.of(authors).find(R.propEq.apply('id', args.get('id'))).toMap();
    }
}

private class GetBookResolver implements G.Resolver {
    public Object resolve(Map<String, Object> parent, Map<String, Object> args, G.ResolvingContext context) {
        return R.of(books).find(R.propEq.apply('id', args.get('id'))).toMap();
    }
}
```

</article>

<article id="7">

## Resolvers

Resolvers are the complex part in G.apex. We have two types of resolvers.

- Normal resolvers

Normal resolvers take the resolving request one by one.

- Batch resolvers

Batch resolvers take all the resolving requests in a batch.

For performance's sake, we should use batch resolvers whenever we can.

</article>

<article id="8">

## Normal Resolvers

We can create a normal resolver by implementing `G.Resolver` like in the example.

Or we can create a Func that takes the same arguments, and register it like this:

```javascript
G.ObjectType bookType = new G.ObjectType('Book', 'Book__c')
    .addField('id', G.StringType, 'Id')
    .addField('name', G.StringType, 'Name')
    .addField('author', new G.ReferenceType('Author'), new NormalResolverFunc(), false);
```

</article>

<article id="9">

## Batch Resolvers

We can create a batch resolver by implementing `G.BatchResolver` like in the example.

Or we can create a Func that takes the same arguments, and register it like this:

```javascript
G.ObjectType bookType = new G.ObjectType('Book', 'Book__c')
    .addField('id', G.StringType, 'Id')
    .addField('name', G.StringType, 'Name')
    .addField('author', new G.ReferenceType('Author'), new BatchResolverFunc(), true);
```

</article>

<article id="10">

## Resolving SObjects

G.apex is especially tuned for handling SObjects.

Here is an example of how to resolve SObjects.

```javascript
private class OpportunityResolver implements G.BatchResolver {
    public List<Object> resolve(List<Object> parents, Map<String, Object> args, G.ResolvingContext context) {
        List<Object> result = new List<Object>();

        List<Id> ids = new List<Id>();
        for(Object parentObj : parents) {
            Map<String, Object> parent = (Map<String, Object>)parentObj;
            ids.add((Id)parent.get('id'));
        }

        String sObjectType = context.getSObjectType();
        List<String> fields = context.getSObjectFields();

        String soql = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + sObjectType + ' WHERE Id in :ids';
        List<SObject> soList = Database.query(soql);
        for(SObject so : soList) {
            result.add(context.convertSObject(so));
        }

        return result;
    }
}
```

</article>

<article id="11">

## Pull the Trigger

When everything is ready, we can start executing G.apex queries with ease.

```javascript
Map<String, Object> result = (Map<String, Object>)G.execute(query);
```

You can further build this as a remote action or a lightning server controller action or a web service end point.

</article>
