---
title: "Global"
description: "Global"
layout: "guide"
icon: "cloud"
weight: 2
---

###### {$page.description}

<article id="1">

## execute

Execute query on the schema

```javascript
G.Schema schema = new G.Schema();
Object data = G.execute(schema, query);
```

| Method | Description |
| ------ | ----------- |
| G.execute(Schema, String) | Execute with schema and query |
| G.execute(Schema, Map&lt;String, Object&gt;) | Execute with schema and query data |
| G.execute(String) | Execute with query |
| G.execute(Map&lt;String, Object&gt;) | Execute with query data |

</article>

<article id="2">

## getObjectType

Get the registered object type

```javascript
G.ObjectType objectType = G.getObjectType('Book');
```

</article>

<article id="3">

## describe

Describe the given object type by name
Return the description of the schema if no object type given

```javascript
Map<String, String> result = G.describe('Book');
```

</article>

<article id="4">

## registerDirective

Register a custom direcitve

```javascript
G.registerDirective(new MyCustomDirective());
```

</article>
