({
	fetchData: function (component, event, helper) {
        var vAction = component.get("c.getAllFiles");
        vAction.setParams({ 
                intLimit: 20 
            });
        vAction.setCallback(this, function(pResponse) {
            var vState = pResponse.getState();
            if (vState === "SUCCESS") { 
                var data = pResponse.getReturnValue();
                component.set('v.files', data);
                component.set('v.allData', data);
                if(data.length ==20) component.set('v.showMore', true);
            } else {
                var vErrors = pResponse.getError();
                if (vErrors) {
                    if (vErrors[0] && vErrors[0].message) {
                        console.log("Error message: " + vErrors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(vAction);
    },
    
    fetchAllData: function (component, event, helper) {
        var vAction = component.get("c.getAllFiles");
        vAction.setParams({ 
                intLimit: 1000 
            });
        vAction.setCallback(this, function(pResponse) {
            var vState = pResponse.getState();
            if (vState === "SUCCESS") { 
                var data = pResponse.getReturnValue();
                component.set('v.files', data);
                component.set('v.allData', data);
                if(data.length == 15) component.set('v.showMore', false);
            } else {
                var vErrors = pResponse.getError();
                if (vErrors) {
                    if (vErrors[0] && vErrors[0].message) {
                        console.log("Error message: " + vErrors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(vAction);
    },
    
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.files");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.files", data);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})