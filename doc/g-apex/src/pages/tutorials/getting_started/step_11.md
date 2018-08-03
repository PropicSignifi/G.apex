---
title: "Default Value"
description: "Default Value"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 11
---

## {$page.title}

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
