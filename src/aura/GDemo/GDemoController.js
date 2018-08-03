({
    doInit: function(cmp, event, helper) {
        var defaultQueryObject = {
            query: {
                book: {
                    '@id': "2",
                    name: ""
                }
            }
        };
        cmp.set('v.query', JSON.stringify(defaultQueryObject, null, 4));

        helper.describe(cmp);
    },

    onClickField: function(cmp, event, helper) {
        var index = Number(event.target.className);
        var fields = cmp.get("v.fields");
        var field = fields[index];
        if(field) {
            var fieldType = field.type;
            var pos = 0;
            while((pos = fieldType.indexOf('<')) >= 0) {
                fieldType = fieldType.substring(pos + 1);
            }
            while((pos = fieldType.indexOf('[')) >= 0) {
                fieldType = fieldType.substring(pos + 1);
            }
            if((pos = fieldType.indexOf('>')) >= 0) {
                fieldType = fieldType.substring(0, pos);
            }
            if((pos = fieldType.indexOf(']')) >= 0) {
                fieldType = fieldType.substring(0, pos);
            }
            helper.describe(cmp, fieldType);
        }
    },

    onClickRoot: function(cmp, event, helper) {
        helper.describe(cmp);
    },

    onExecute: function(cmp, event, helper) {
        helper.execute(cmp);
    },
})
