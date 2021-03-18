({
    doInit : function(component, event, helper) {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        component.set("v.parentRecordId", context.attributes.recordId);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ORM_Notes",
            componentAttributes: {
                recordId : context.attributes.recordId
            }
        });
        evt.fire();
    }
    })