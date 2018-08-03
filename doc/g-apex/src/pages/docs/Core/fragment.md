---
title: "Fragment"
description: "Fragment"
layout: "guide"
icon: "flash"
weight: 5
---

###### {$page.description}

<article id="1">

## Use Fragments

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

We define fragments by prepending `...` before the name and placing them at the root of the query.
The result will be like:

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

</article>
