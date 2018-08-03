---
title: "Parameters"
description: "Parameters"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 10
---

## {$page.title}

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
