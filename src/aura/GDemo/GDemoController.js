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
        var linkType = event.target.className;
        if(linkType) {
            var lastTypes = cmp.get('v.lastTypes');
            if(!lastTypes) {
                lastTypes = [];
            }
            lastTypes.push(linkType);
            cmp.set('v.lastTypes', lastTypes);
            helper.describe(cmp, linkType);
        }
    },

    onClickRoot: function(cmp, event, helper) {
        helper.describe(cmp);
    },

    onClickBack: function(cmp, event, helper) {
        var lastTypes = cmp.get('v.lastTypes');
        lastTypes = lastTypes.slice(0, lastTypes.length - 1);
        cmp.set('v.lastTypes', lastTypes);
        helper.describe(cmp, lastTypes[lastTypes.length - 1]);
    },

    onExecute: function(cmp, event, helper) {
        helper.execute(cmp);
    },
})
