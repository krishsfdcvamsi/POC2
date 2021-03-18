({
    doInit : function(component, event, helper) {
        helper.doInit(component, event,helper);
    },
    setEarnedEndDate : function(component,event,helper){
        //setEarnedEndDate
        var earnedSateDate = new Date(component.get("v.earnedStartDate"));

        var earnedDateLimit = new Date(earnedSateDate.setMonth(earnedSateDate.getMonth()+12));
        var today = new Date();
        earnedDateLimit = earnedDateLimit < today ? earnedDateLimit : today;
        component.set("v.earnedDateLimit", earnedDateLimit.getFullYear()+'-'+(earnedDateLimit.getMonth()+1)+'-'+ earnedDateLimit.getDate());
        component.find("earnedEndDate").reportValidity();

    },
    goToReport : function(component, event, helper) {
        var reportFilter = [];
        
        //2020-11-09T06:00:00Z
        if(component.get("v.earnedStartDate")){

            var startDate = new Date(component.get("v.earnedStartDate")+'T00:00:00Z');
            reportFilter.push({
                "column":"AssetRepairHistory__c.RepairDate__c",
                "operator":"greaterOrEqual",
                "value" : startDate
            });
        }
        if(component.get("v.earnedEndDate")){
            var endDate = new Date(component.get("v.earnedEndDate")+'T23:59:59Z');
            console.log(endDate);
            reportFilter.push({
                "column":"AssetRepairHistory__c.RepairDate__c",
                "operator":"lessOrEqual",
                "value":endDate
            });
        }
      
        if(component.get("v.riderNumber") && component.get("v.riderNumber") != 'All'){

            reportFilter.push({
                "column":"AssetRepairHistory__c.Rider_Number__c",
                "operator":"equals",
                "value":component.get("v.riderNumber")
            });
        }
        if(component.get("v.accountName")){
            reportFilter.push({
                "column":"AssetRepairHistory__c.ReimbursableFrom__c.Name",
                "operator":"equals",

                "value": '"'+component.get("v.accountsMap")[component.get("v.accountName")]+'"'
            });
        }
       
        if(helper.validateForm(component,event)){
            console.log(JSON.stringify(reportFilter));
            window.open($A.get("$Label.c.Repair_History")+encodeURIComponent(JSON.stringify(reportFilter)))
            //window.open('/s/report/00O5B000000jogqUAA/fleet-mileage-data?reportFilters='+encodeURIComponent(JSON.stringify(reportFilter)));
        }
    },
    
     riderNumberChange : function(component,event,helper){
        helper.getRiderNumbersByAccount(component,event, component.get("v.accountName"), event.getParam("value"));
    },

    setDataByAccount :  function(component, event, helper){
        helper.setDataByAccount(component, event);
    },
})