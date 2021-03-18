({  
    showMyToast : function(component, event, helper) {
        //Gets number of items in each category
        var EstNumb = component.get('v.EstimatesSize');
        var OTMANumb = component.get('v.OTMASize');
        var DispNumb = component.get('v.DispositionSize');
        var SchedNumb = component.get('v.SchedulesSize');
        var CaseNumb = component.get('v.CasesSize');
        var InvNumb = component.get('v.InvoicesSize');
        var RideNumb = component.get('v.RidersSize');
        
		//View Variables for Components that can be hidden
        var VisableOTMA = component.get('v.ViewOTMA');
        var VisableInvoices = component.get('v.ViewInvoices');
        var VisableRiders = component.get('v.ViewRiders');
        
        //Gets Total
        var Total = EstNumb+DispNumb+SchedNumb+CaseNumb; 
        
        if(VisableOTMA)
        {
            Total += OTMANumb;
        }
        if(VisableInvoices)
        {
            Total += InvNumb;
        }
        if(VisableRiders)
        {
            Total += RideNumb;
        }
        
        component.set('v.Total',Total);
        
        var toastEvent = $A.get("e.force:showToast");
        
        if (Total == 1)
        {
            toastEvent.setParams({
            	mode: 'dismissible',
            	type: 'warning',
            	message: 'You have '+Total+' item pending action. Please review them below.'
        	});
        }
        else if (Total > 0)
        {
            toastEvent.setParams({
            	mode: 'dismissible',
            	type: 'warning',
            	message: 'You have '+Total+' items pending action. Please review them below.'
        	});
        }
        else
        {
            toastEvent.setParams({
            	mode: 'dismissible',
            	type: 'success',
            	message: 'There are no pending items. You\'re all caught up!'
        	});
        }
        
        toastEvent.fire();
    }
})