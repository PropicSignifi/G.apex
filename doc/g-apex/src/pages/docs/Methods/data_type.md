---
title: "Data Type"
description: "Data Type"
layout: "guide"
icon: "cloud"
weight: 4
---

###### {$page.description}

<article id="1">

## Data Types

| Name | Usage |
| ---- | ----- |
| Boolean | G.BooleanType |
| Integer | G.IntegerType |
| Long | G.LongType |
| Double | G.DoubleType |
| String | G.StringType |
| List | new G.ListType(G.DataType) |
| Object | new G.ObjectType(String) / new G.ObjectType(String, String) |
| Reference | new G.ReferenceType(String) |

</article>

<article id="2">

## Data Type Methods

All data types have the following methods:

| Method | Description |
| ------ | ----------- |
| String getType() | Get the type name |

</article>

<article id="3">

## List Type Methods

| Method | Description |
| ------ | ----------- |
| G.DataType getElementType() | Get element data type |

</article>

<article id="4">

## Object Type Methods

| Method | Description |
| ------ | ----------- |
| String getName() | Get the name of the object type |
| String getSObjectType() | Get the bound SObject type |
| ObjectType addField(String, DataType, Func, Boolean, String) | Add field with name, type, resolver, resolver batch, and sobject type |
| ObjectType addField(String, DataType, Func, Boolean) | Add field with name, type, resolver, resolver batch |
| ObjectType addField(String, DataType, Func) | Add field with name, type, resolver |
| ObjectType addField(String, DataType, BatchResolver) | Add field with name, type, resolver |
| ObjectType addField(String, DataType, Resolver) | Add field with name, type, resolver |
| ObjectType addField(String, DataType, String) | Add field with name, type, sobject type |
| ObjectType addField(String, DataType) | Add field with name, type |
| ObjectType addParam(String, String, DataType, Func) | Add a param with the field name, param name, type, validate func |
| ObjectType addParam(String, String, DataType) | Add a param with the field name, param name, type |
| Map&lt;String, String&gt; getSObjectFieldMapping() | Get the sobject field mapping |
| Map&lt;String, String&gt; describe() | Describe the object type |

</article>

<article id="5">

## Reference Type Methods

| Method | Description |
| ------ | ----------- |
| String getName() | Get the name of the object type |
| ObjectType getReferencedType() | Get the referenced object type |

</article>
