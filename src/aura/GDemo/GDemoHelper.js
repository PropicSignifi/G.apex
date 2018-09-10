({
    getObjectType: function(type) {
        var pos = 0;
        while((pos = type.indexOf('<')) >= 0) {
            type = type.substring(pos + 1);
        }
        while((pos = type.indexOf('[')) >= 0) {
            type = type.substring(pos + 1);
        }
        if((pos = type.indexOf('>')) >= 0) {
            type = type.substring(0, pos);
        }
        if((pos = type.indexOf(']')) >= 0) {
            type = type.substring(0, pos);
        }

        if(type === 'Boolean' ||
            type === 'Integer' ||
            type === 'Long' ||
            type === 'Double' ||
            type === 'String') {
            return '';
        }
        else {
            return type;
        }
    },

    describe: function(cmp, type) {
        var self = this;
        this.callServerAction(cmp, 'c.describe', { type : type }, function(data) {
            if(!data) {
                console.error('Cound not describe');
            }
            var keys = Object.keys(data).sort();
            var fields = keys.map(function(key) {
                var info = data[key];
                if(typeof info === 'string') {
                    return {
                        name: key,
                        type: {
                            name: info,
                            link: self.getObjectType(info),
                        }
                    };
                }
                else {
                    var params = info.params || {};
                    var paramList = [];
                    for(var paramName in params) {
                        paramList.push({
                            name: paramName,
                            type: {
                                name: params[paramName],
                                link: self.getObjectType(params[paramName]),
                            },
                        });
                    }
                    return {
                        name: key,
                        params: paramList,
                        type: {
                            name: info.type,
                            link: self.getObjectType(info.type),
                        },
                    };
                }
            });

            cmp.set('v.fields', fields);
            cmp.set('v.currentTypeName', type);
        });
    },

    execute: function(cmp) {
        this.callServerAction(cmp, 'c.execute', { query : cmp.get('v.query') }, function(data) {
            if(!data) {
                console.error('Cound not execute');
            }

            var json = JSON.stringify(data, null, 4);

            cmp.set('v.result', json);
        });
    },

    callServerAction: function(cmp, actionName, params, callback) {
        var action = cmp.get(actionName);
        action.setParams(params);

        cmp.set('v.loading', true);

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(callback) {
                    callback(data);
                }
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " + errors[0].message);

                        cmp.set('v.result', errors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }
            }

            cmp.set('v.loading', false);
        });

        $A.enqueueAction(action);
    },
})
