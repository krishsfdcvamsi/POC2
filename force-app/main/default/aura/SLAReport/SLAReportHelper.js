({
	doInit : function(component, event, helper) {
		var recordId = component.get("v.recordId");
        const action = component.get('c.getApprovalHistory');
        action.setParams({
                QuoteId: recordId
            });
        	action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === 'SUCCESS') {
                //var result = response.getReturnValue();
                
                //component.set("v.data",result);
                //var data = [];
                //var i=0;
                //for (var key in result) {
                  //  if (result.hasOwnProperty(key)) {
                    //    data.push(key);
                        //data[i] = key;
                        //data[i]._children = result[key];
                        //console.log(key + " -> " + result[key]);
                        //i++;
                    //}
                //}
                
                var result = response.getReturnValue();
                var resuletsInfo = [];
                for(var i=0;i<result.length;i++){
                    console.log('result>>>>>SLA>>>',result[i]);
                   var ElapsedDays = 0;
                        if(!$A.util.isUndefinedOrNull(result[i].ElapsedTimeInDays) && !$A.util.isEmpty(result[i].ElapsedTimeInDays)){
                        	ElapsedDays = Math.ceil(result[i].ElapsedTimeInDays);
                    	}
                    var lastActor = '';
                    if(!$A.util.isUndefinedOrNull(result[i].LastActorId) && !$A.util.isEmpty(result[i].LastActorId)){
                        lastActor = result[i].LastActor.Name;
                    }
                    var approval = {
                        ProcessNodeName : result[i].ProcessNodeName,
                          NodeStatus : result[i].NodeStatus,
                          //ElapsedTimeInDays  : Math.round(result[i].ElapsedTimeInDays),
                          ElapsedTimeInDays  : ElapsedDays,
                        	ElapsedTimeInHours : result[i].ElapsedTimeInHours,
                          createdDate     : result[i].CreatedDate,
                        CompletedDate : result[i].CompletedDate,
                        lastActor : lastActor
                        };
                    resuletsInfo.push(approval);
                }
                //component.set("");
                console.log('resuletsInfo>>>>>>',resuletsInfo);
                component.set("v.data",resuletsInfo);
            } else {
                this.showToast('Message', 'error', 'An error occurred while processing your request. Please contact your administrator or try again.');
            }
        });
        $A.enqueueAction(action);
	},
    columns : function(component, event, helper){
    const columns = [
    { label: 'Step Name', fieldName: 'ProcessNodeName', type: 'text' },
    { label: 'Status', fieldName: 'NodeStatus', type: 'text' },
    //{ label: 'Elapsed Time In Days', fieldName: 'ElapsedTimeInDays', type: 'text' },
    { label: 'Elapsed Time In Hours', fieldName: 'ElapsedTimeInHours', type: 'number' },
    { label: 'Start Date', fieldName:'createdDate', type: 'date'},
    { label: 'Complete Date', fieldName:'CompletedDate', type: 'date'},
        { label: 'Last Actor:Full Name', fieldName:'lastActor', type: 'text'}
   	];
        component.set("v.columns",columns);
    },
    showToast : function(title, type, message) {
        const toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });
        toastEvent.fire();
    }
})