({
	refresh : function(cmp,event, helper) {
		 var action = cmp.get('c.getScheduleInfo'); 
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        action.setParams({
            "ProjectID" : cmp.get('v.recordId') 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var Proj = a.getReturnValue();
                cmp.set('v.Schedules', Proj);
            }
        });
        
        $A.enqueueAction(action);

	},
    
    PendingCount : function(cmp,event, helper) {
        var action = cmp.get('c.PendingSchedules'); 
        console.log("Pending Count");
        action.setParams({
            "ProjectID" : cmp.get('v.recordId') 
        });

        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            console.log(state);
            if(state == 'SUCCESS') {
                var Proj = a.getReturnValue();
                cmp.set('v.Pends', Proj);
                console.log(Proj);
            }
        });      
        $A.enqueueAction(action);
    }    
})