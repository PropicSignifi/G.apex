---
title: "Variables"
description: "Variables"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 14
---

## {$page.title}

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

We define a variable `$var` at the root of the query, and anywhere else it is used, it will be replace by the value name. Variables are defined by prepending `$`.
