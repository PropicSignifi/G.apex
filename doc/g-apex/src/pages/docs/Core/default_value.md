---
title: "Default Value"
description: "Default Value"
layout: "guide"
icon: "flash"
weight: 3
---

###### {$page.description}

<article id="1">

## Define Default Values

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

For non-object types, we can specify the default value of the field if the fetched value is null.

</article>
