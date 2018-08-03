---
title: "Resolver"
description: "Resolver"
layout: "guide"
icon: "cloud"
weight: 5
---

###### {$page.description}

<article id="1">

## Resolver Methods

| Method | Description |
| ------ | ----------- |
| Object resolve(Map&lt;String, Object&gt;, Map&lt;String, Object&gt;, ResolvingContext) | Needs to be implemented |

</article>

<article id="2">

## BatchResolver Methods

| Method | Description |
| ------ | ----------- |
| List&lt;Object&gt; resolve(List&lt;Object&gt;, Map&lt;String, Object&gt;, ResolvingContext) | Needs to be implemented |

</article>

<article id="3">

## ResolvingContext Methods

| Method | Description |
| ------ | ----------- |
| String getSObjectType() | Get the bound sobject type |
| List&lt;String&gt; getSObjectFields() | Get the filtered sobject fields |
| Map&lt;String, Object&gt; getQueryData() | Get the query data |
| Map&lt;String, Object&gt; convertSObject(SObject) | Convert the sobject according to the object type |

</article>
