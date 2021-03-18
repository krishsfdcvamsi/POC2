({
    CreateRenewalOppty : function(component) {
        var riderId = component.get("v.recordId");
        var action = component.get("c.getRiderDetails");
        action.setParams({
            "riderId" : riderId
        });       
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var jsonResp=response.getReturnValue();
                this.createRenewalOpptyRec(jsonResp);
            }
        });
        $A.enqueueAction(action);
    },
    createRenewalOpptyRec:function(jsonResp){
        
        var riderRecData= jsonResp.RiderRecord;
        var renewOpptyData=  jsonResp.RenewalOpptyRecType;
        var dt = new Date(riderRecData.RFO_OriginalMaturityDate__c);

        dt.setMonth( dt.getMonth() - 1 );
        
        var result = $A.localizationService.formatDate(dt, "YYYY-MM-DD");
                 
        var orgMatDt = $A.localizationService.formatDate(new Date(riderRecData.RFO_OriginalMaturityDate__c), "MM/DD/YYYY");
        var oppName = riderRecData.Account_Name__c +(riderRecData.RFO_RiderNumber__c!=null?' - '+riderRecData.RFO_RiderNumber__c:'')+
            (riderRecData.RFO_RiderNumberSuffix__c!=null?'.'+riderRecData.RFO_RiderNumberSuffix__c:'')+(riderRecData.RFO_OriginalMaturityDate__c!=null?' - '+orgMatDt:'');
          
        var createRecordEvent = $A.get("e.force:createRecord");
         console.log(result);
        createRecordEvent.setParams({
            "entityApiName": "Opportunity",
            "recordTypeId":renewOpptyData,
            "defaultFieldValues": {
                'StageName' :'Initiated',
                'Pricebook2Id':jsonResp.StandardPriceBookId,
                'Name' : oppName,
                'AccountId' : riderRecData.RFO_Account__c,
                'RFO_ProductType__c' : riderRecData.RFO_ProductType__c,
               
                //'CloseDate' :  dt, 
                
                'CloseDate' :  result, 
                
                'RFO_Mileage__c' : riderRecData.RFO_MileageLimit__c,
                'RFO_MileageFee__c' : riderRecData.RFO_ExcessMileagePremium__c,
                'RFO_Commodity__c' : riderRecData.RFO_Commodity__c,
                'RFO_MaturityDate__c' : riderRecData.RFO_OriginalMaturityDate__c,
                'RFO_ExpectedCarstoTrinity__c' : riderRecData.RFO_TotalActiveCars__c,
                'RFO_MaximumQuantity__c': riderRecData.RFO_TotalActiveCars__c,
                'RFO_Quantity__c': riderRecData.RFO_TotalActiveCars__c,
                'RFO_RiderID__c' :riderRecData.Id,
                'RFO_PreferredNewExisting__c' : 'Existing',
                'RFO_Product__c':riderRecData.RFO_Product__c,
            }
        });
        createRecordEvent.fire();
    }
})