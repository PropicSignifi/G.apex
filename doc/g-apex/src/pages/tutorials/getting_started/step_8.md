---
title: "Serve Query Request"
description: "Serve Query Request"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 8
---

## {$page.title}

Our building work is done. Next we can provide our query service. The core API is below:

```javascript
Map<String, Object> result = (Map<String, Object>)G.execute(query);
```

`query` here is the G.apex query JSON string. And the `result` is the data after processing the query.
