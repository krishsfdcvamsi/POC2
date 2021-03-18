({
    doInit : function(component, event, helper){
        helper.loadQuoteStatus(component, event, helper);

    },

    refreshview : function(component, event, helper){
        console.log('checking refresh...');
        $A.get('e.force:refreshView').fire();
    }
})