---
title: "Aliases"
description: "Aliases"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 12
---

## {$page.title}

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
