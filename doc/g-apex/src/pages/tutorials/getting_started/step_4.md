---
title: "G.apex Query"
description: "G.apex Query"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 4
---

## {$page.title}

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
