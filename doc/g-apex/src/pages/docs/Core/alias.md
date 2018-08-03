---
title: "Alias"
description: "Alias"
layout: "guide"
icon: "flash"
weight: 4
---

###### {$page.description}

<article id="1">

## Use Aliases

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

Prepend the alias and `:` before the field to rename the field to the alias, producing results like:

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

</article>
