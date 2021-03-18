({
	 doInit: function(cmp,event, helper){
        var action = cmp.get("c.GetActionItems");
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(data!=null)
                {
                    cmp.set('v.EstimatesData',data.PendingEstimates);
                    cmp.set('v.EstimatesSize',data.PendingEstimates.length);
                    cmp.set('v.OTMAData',data.PendingOTMA);
                    cmp.set('v.OTMASize',data.PendingOTMA.length);
                    cmp.set('v.DispositionData',data.OutboundDisposition);
                    cmp.set('v.DispositionSize',data.OutboundDisposition.length);
                    cmp.set('v.SchedulesData',data.AwaitingSchedules);
                    cmp.set('v.SchedulesSize',data.AwaitingSchedules.length);
                    cmp.set('v.CasesData',data.AwaitingCases);
                    cmp.set('v.CasesSize',data.AwaitingCases.length);
                    cmp.set('v.InvoicesData',data.InvoicesDue);
                    cmp.set('v.InvoicesSize',data.InvoicesDue.length);
                    cmp.set('v.RidersData',data.MaturingRiders);
                    cmp.set('v.RidersSize',data.MaturingRiders.length); 
					cmp.set('v.hasPerm',data.permCheck); 
					var hasPerm = data.permCheck;
					if(hasPerm) {
						cmp.set('v.projectsList',data.ObjectData.projectList);
						cmp.set('v.weekList',data.ObjectData.weekList);
						cmp.set('v.projectsListSize',data.ObjectData.projectList.length);
					}
                    helper.showMyToast(cmp,event, helper);
                    
                    console.log('DISP SIZE: '+data.OutboundDisposition.length);
                }
                else
                {
                    console.log('v.errors','No Estimates: ');  
                    console.log('Here'+v.errors);
                }
            }
        });
        $A.enqueueAction(action);
    }
})