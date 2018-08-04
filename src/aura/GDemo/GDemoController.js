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
            helper.describe(cmp, linkType);
        }
    },

    onClickRoot: function(cmp, event, helper) {
        helper.describe(cmp);
    },

    onExecute: function(cmp, event, helper) {
        helper.execute(cmp);
    },
})
