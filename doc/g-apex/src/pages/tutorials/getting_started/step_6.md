---
title: "Create Schema"
description: "Create Schema"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 6
---

## {$page.title}

We need to define access points on our schema so that our data is accessible.

```javascript
G.Schema schema = new G.Schema()
    .add(
        new G.ObjectType('query')
            .addField('books', new G.ListType(bookType), R.constant.apply(new List<Object>{ books }))
    );
```

Here we defined a new ObjectType `query`, with the field `books` that can retrive a list of books. Then we add this object type to the schema. `R.constant.apply(...)` here is a resolver Func that always returns the list of list of books whenever called. A resolver can be implemented by either a Func or an instance of `BatchResolver` or `Resolver`.

You might feel strange why we return a list of list of books. The reason is that by default our resolver function is invoked by batch to improve performance. We will see this later.
