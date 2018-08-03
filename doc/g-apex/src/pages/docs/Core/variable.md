---
title: "Variable"
description: "Variable"
layout: "guide"
icon: "flash"
weight: 6
---

###### {$page.description}

<article id="1">

## Use Variables

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

We define variables by prepending `$` before the name and placing them at the root of the query.

</article>
