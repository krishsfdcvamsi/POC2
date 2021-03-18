({
    doInit: function(cmp,evt,helper) {
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
                //console.log(JSON.stringify(Proj));
                helper.PendingCount(cmp,evt,helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    approve:function(cmp,evt,helper)
    {
        var inputfield = cmp.find('inputField');
        var input= inputfield.get('v.value');
        
        var action = cmp.get('c.approveAllSchedules');   
        action.setParams({
            "ProjectID" : cmp.get('v.recordId') ,"Comment":input
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') 
            {
                cmp.find("inputField").set('v.value',"");
                cmp.find("inputField").setCustomValidity("");
                cmp.find("inputField").reportValidity();
                cmp.set('v.Schedules', a.getReturnValue());
                // var quick=cmp.get('c.quickClose');
                //  $A.enqueueAction(quick);
                helper.refresh(cmp,event, helper);
                helper.PendingCount(cmp,evt,helper);
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
        
        
    },
    reject:function(cmp,evt,helper)
    {
        var inputfield = cmp.find('inputField');
        var input= inputfield.get('v.value');
        
        if(input==null||input.trim()=='')
        {     
            inputfield.setCustomValidity('Comments cannot be blank to reject schedules'); //do not get any message
            inputfield.reportValidity();
 
        }
        else
        {
            var action = cmp.get('c.rejectAllSchedules');      
            
            action.setParams({
                "ProjectID" : cmp.get('v.recordId'),"Comment":input
            });
            action.setCallback(this, function(a){
                var state = a.getState(); // get the response state
                if(state == 'SUCCESS') {
                    cmp.find("inputField").set('v.value',"");
                    cmp.find("inputField").setCustomValidity("");
                    cmp.find("inputField").reportValidity();
                    cmp.set('v.Schedules', a.getReturnValue());
                    helper.refresh(cmp,event, helper);
                    helper.PendingCount(cmp,evt,helper);
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    quickClose : function(component, event, helper) {
        
        setTimeout(function(){
            $A.get('e.force:refreshView').fire();
        }, 500);
    },
    
    downloadCsv : function(component, event, helper){       
        var action = component.get('c.ReturnCSV'); 

        action.setParams({
            "ProjectID" : component.get('v.recordId') 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var csv = a.getReturnValue();
                
                if (csv == null){return;}
                
                // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
                hiddenElement.target = '_self'; //
                hiddenElement.download = 'ProjectSchedules.csv';  
                document.body.appendChild(hiddenElement); // Required for FireFox browser
                hiddenElement.click(); // using click() js function to download csv file
            }
        });
        $A.enqueueAction(action);        
    }
})