---
title: "Parameters"
description: "Parameters"
layout: "guide"
icon: "flash"
weight: 2
---

###### {$page.description}

<article id="1">

## Define Parameters

```javascript
G.Schema schema = new G.Schema()
    .add(
        new G.ObjectType('query')
            .addField('book', bookType, new GetBookResolver())
                .addParam('book', 'id', G.StringType, R.isNotNull)
    );
```

</article>

<article id="2">

## Compose Parameters

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

</article>

<article id="3">

## Processing Parameters

```javascript
private class GetBookResolver implements G.Resolver {
    public Object resolve(Map<String, Object> parent, Map<String, Object> args, G.ResolvingContext context) {
        return R.of(books).find(R.propEq.apply('id', args.get('id'))).toMap();
    }
}
```

</article>
