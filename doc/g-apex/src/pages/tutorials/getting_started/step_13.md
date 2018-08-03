---
title: "Fragments"
description: "Fragments"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 13
---

## {$page.title}

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
