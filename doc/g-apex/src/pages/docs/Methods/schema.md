---
title: "Schema"
description: "Schema"
layout: "guide"
icon: "cloud"
weight: 3
---

###### {$page.description}

<article id="1">

## Constructor

```javascript
G.Schema schema = new G.Schema();
```

</article>

<article id="2">

## add

Add a root object type

```javascript
new G.Schema()
    .add(new G.ObjectType('Book'));
```

</article>

<article id="3">

## describe

Describe the schema

```javascript
Map<String, String> data = new G.Schema.describe();
// { 'query' => 'Query' }
```

</article>
