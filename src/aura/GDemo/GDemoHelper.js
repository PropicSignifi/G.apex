({
    describe: function(cmp, type) {
        var action = cmp.get("c.describe");
        action.setParams({ type : type });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(!data) {
                    console.error('Cound not describe');
                }
                var keys = Object.keys(data).sort();
                var fields = keys.map(function(key) {
                    var type = data[key];
                    var hideLink = type === 'Boolean' ||
                        type === 'Integer' ||
                        type === 'Long' ||
                        type === 'String' ||
                        type === 'List<Boolean>' ||
                        type === 'List<Integer>' ||
                        type === 'List<Long>' ||
                        type === 'List<String>';
                    return {
                        name: key,
                        type: type,
                        hideLink: hideLink,
                    };
                });

                cmp.set('v.fields', fields);
                cmp.set('v.currentTypeName', type);
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " + errors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    execute: function(cmp) {
        var action = cmp.get("c.execute");
        action.setParams({ query : cmp.get('v.query') });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(!data) {
                    console.error('Cound not execute');
                }

                var json = JSON.stringify(data, null, 4);

                cmp.set('v.result', json);
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " + errors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
})
