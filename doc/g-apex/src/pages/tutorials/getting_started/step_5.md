---
title: "Create Object Types"
description: "Create Object Types"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 5
---

## {$page.title}

To start with, we create some simple Object Types.

```javascript
G.ObjectType bookType = new G.ObjectType('Book', 'Book__c')
    .addField('id', G.StringType, 'Id')
    .addField('name', G.StringType, 'Name');
```

Here we created an ObjectType of `Book`, bound to SObject type `Book__c`. The book type has two fields, `id` of String type and `name` of String type.
