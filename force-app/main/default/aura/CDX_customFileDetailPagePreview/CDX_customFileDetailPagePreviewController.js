({
    openSingleFile: function(cmp, event, helper) {
        $A.get('e.lightning:openFiles').fire({
            recordIds: recordId
        });
    },
    
    handleOpenFiles: function(cmp, event, helper) {
    }
})