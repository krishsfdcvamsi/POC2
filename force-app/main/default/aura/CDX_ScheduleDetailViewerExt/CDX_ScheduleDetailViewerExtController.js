({
    doInit2: function(cmp) {
        var action = cmp.get('c.getScheduleDetails'); 
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        action.setParams({
            "Schedule" : cmp.get('v.ScheduleID') 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            console.log("What's the state?")
            if(state == 'SUCCESS') {
                cmp.set('v.ScheduleDetails', a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        //Commeneted by MA
        /*var action2 = cmp.get('c.hasActualCarsPerm'); 
        action2.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            console.log("output = "+a.getReturnValue())
            if(state == 'SUCCESS') {
                cmp.set('v.hasPerm', a.getReturnValue());
            }
        });
        $A.enqueueAction(action2);*/
    }
})