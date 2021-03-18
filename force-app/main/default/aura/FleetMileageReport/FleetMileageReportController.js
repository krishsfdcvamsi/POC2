({
    doInit : function(component, event, helper) {
        helper.doInit(component, event);
        helper.setDataByAccount(component, event);
    },
    setEarnedEndDate : function(component,event,helper){
        var earnedSateDate = new Date(component.get("v.earnedStartDate"));
        var earnedDateLimit = new Date(earnedSateDate.setMonth(earnedSateDate.getMonth()+18));
        component.set("v.earnedDateLimit", earnedDateLimit.getFullYear()+'-'+(earnedDateLimit.getMonth()+1)+'-'+ earnedDateLimit.getDate());
    },
    goToReport : function(component, event, helper) {
        console.log(component.get("v.allcars"));
        try{
        var reportFilter = [];
        //2020-11-09T06:00:00Z
        if(component.get("v.allowedStartDate")){
            reportFilter.push({
                "column":"Fleet_Mileage_Data__c.Allowed_Date__c",
                "operator":"greaterOrEqual",
                "value": new Date(component.get("v.allowedStartDate")+'T00:00:00Z')
            });
        }
        if(component.get("v.allowedEndDate")){

            reportFilter.push({
                "column":"Fleet_Mileage_Data__c.Allowed_Date__c",
                "operator":"lessOrEqual",
                "value": new Date(component.get("v.allowedEndDate")+'T23:59:59Z')
            });
        }
        if(component.get("v.earnedStartDate")){
            reportFilter.push({
                "column":"Fleet_Mileage_Data__c.Earned_Date__c",
                "operator":"greaterOrEqual",
                "value": new Date(component.get("v.earnedStartDate")+'T00:00:00Z')
            });
        }
        if(component.get("v.earnedEndDate")){

            reportFilter.push({
                "column":"Fleet_Mileage_Data__c.Earned_Date__c",
                "operator":"lessOrEqual",
                "value": new Date(component.get("v.earnedEndDate")+'T23:59:59Z')
            });
        }
        if(component.get("v.allcars").length == 0){
            var fromCarNumber = component.get("v.fromCarNumber")
            if(fromCarNumber){
                component.set("v.carMark", fromCarNumber.substring(0,4));
                reportFilter.push({
                    "column":"Fleet_Mileage_Data__c.Car_Number__c",
                    "operator":"greaterOrEqual",
                    "value":parseInt(fromCarNumber.substring(4))
                });
            }
            if(component.get("v.toCarNumber")){
                var toCarNumber = component.get("v.toCarNumber")
                reportFilter.push({
                    "column":"Fleet_Mileage_Data__c.Car_Number__c",
                    "operator":"lessOrEqual",
                    "value":parseInt(toCarNumber.substring(4))
                });
            }
        }
        if(component.get("v.railRoad")){
            reportFilter.push({
                "column":"Fleet_Mileage_Data__c.RailRoad__c",
                "operator":"equals",
                "value":component.get("v.railRoad")
            });
        } 
        if(component.get("v.riderNumber")){
            reportFilter.push({
                "column":"Fleet_Mileage_Data__c.Rider_Number__c",
                "operator":"equals",
                "value":component.get("v.riderNumber")
            });
        }
        if(component.get("v.accountName")){
            reportFilter.push({
                "column":"Fleet_Mileage_Data__c.Account__c.Name",
                "operator":"equals",
                "value":component.get("v.accountsMap")[component.get("v.accountName")]
            });
        }
        if(component.get("v.carMark")){
            reportFilter.push({
                "column":"Fleet_Mileage_Data__c.Car_Mark__c",
                "operator":"equals",
                "value":component.get("v.carMark")
            });
        }
        
        if(helper.validateForm(component,event)){
            window.open($A.get("$Label.c.Fleet_Mileage")+encodeURIComponent(JSON.stringify(reportFilter)))
            //window.open('/s/report/00O5B000000jogqUAA/fleet-mileage-data?reportFilters='+encodeURIComponent(JSON.stringify(reportFilter)));
        }
        }
        catch(e){
            console.log(e);
        }
    },
    
    setDataByAccount :  function(component, event, helper){
        helper.setDataByAccount(component, event);
    },
    
    riderNumberChange : function(component,event,helper){
        helper.getRiderNumbersByAccount(component,event, component.get("v.accountName"), event.getParam("value"));
    },
    setAllCars : function(component,event,helper){
        if(component.get("v.allcars").length>0){
            component.set("v.fromCarNumber","");
            component.set("v.toCarNumber","");
            component.set("v.carMark","");
        }
    }
   
})