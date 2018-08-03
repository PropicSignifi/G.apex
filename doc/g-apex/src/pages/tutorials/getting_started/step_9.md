---
title: "Mutation"
description: "Mutation"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 9
---

## {$page.title}

G.apex treats query and mutation similarly. We can define our mutation operations in the schema, and process the requests in the resolving functions.

```javascript
G.Schema schema = new G.Schema()
    .add(
        new G.ObjectType('mutation')
            .addField('addBook', bookType, new AddBookResolver())
                .addParam('addBook', 'name', G.StringType, R.isNotNull)
    );
```

We add a parameter definition `name` of String type to the field `addBook`. Also this parameter has a validation of not-null specified by the `R.isNotNull` Func.
