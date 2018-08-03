---
title: "Directives"
description: "Directives"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 15
---

## {$page.title}

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
