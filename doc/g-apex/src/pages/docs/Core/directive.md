---
title: "Directive"
description: "Directive"
layout: "guide"
icon: "flash"
weight: 7
---

###### {$page.description}

<article id="1">

## Use Directives

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

We use the directives by prepending `#`.

The available directives are:

| Name | Description |
| ---- | ----------- |
| include | used with param 'if' to control if the object type is included |
| skip | used with param 'if' to control if the object type is skipped |

</article>

<article id="2">

## Custom Directives

We can define custom directives.

```javascript
private class CustomDirective implements Directive {
    public String getName() {
        return 'custom';
    }

    public Boolean beforeExecuting(Map<String, Object> args, DirectiveContext context) {
        // ...
        return true;
    }
}

G.registerDirective(new CustomDirective());
```

</article>
