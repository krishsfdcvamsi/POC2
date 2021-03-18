/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 1st July 2019
* @Description : Class is to create Opportunity Renewal & Management records.
**/
public class RFO_OpportunityHelper {
    /**
*   Method Name: createRenewalOpportunity
*   Description: This method to create Renewal Opportunities.
**/
    public static void createRenewalOpportunity(RFO_Rider__c riderRec, String Source){
        List<Opportunity> createRenewalOptyList = new List<Opportunity>();
        ID optyRenewalRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY ).getRecordTypeId();
        
        if(riderRec.id!=null && riderRec.RFO_TotalOfCars__c!=null && riderRec.RFO_TotalOfCars__c!=0 &&
           riderRec.RFO_Commodity__c!=null &&
           riderRec.RFO_ProductType__c!=null && riderRec.RFO_ProductType__c!='' && riderRec.RFO_Account__c!=null)
        {
            Opportunity newRenewalOpty = new Opportunity();
            newRenewalOpty.RFO_RiderID__c = riderRec.id;
            newRenewalOpty.Name = RFO_Constant.OPTY_TEST_NAME; //will be updated from Process Builder
            newRenewalOpty.RecordTypeId  = optyRenewalRtId;
            newRenewalOpty.RFO_Quantity__c = riderRec.RFO_TotalActiveCars__c;
            newRenewalOpty.RFO_MaximumQuantity__c = riderRec.RFO_TotalActiveCars__c;
            newRenewalOpty.RFO_ExpectedCarstoTrinity__c = riderRec.RFO_TotalOfCars__c;
            newRenewalOpty.RFO_ProductType__c = riderRec.RFO_ProductType__c;
            newRenewalOpty.AccountId = riderRec.RFO_Account__c;
            newRenewalOpty.CloseDate = riderRec.RFO_OriginalMaturityDate__c;
            newRenewalOpty.StageName = RFO_Constant.INITIATED;
            newRenewalOpty.Type = RFO_Constant.TRINITY_LEASE_EXPIRATIONS;
            newRenewalOpty.RFO_MarketSegment__c = RFO_Constant.NULL_STRING ;
            newRenewalOpty.RFO_ConfidenceLevel__c = RFO_Constant.MEDIUM;
            newRenewalOpty.RFO_PreferredNewExisting__c = RFO_Constant.OPP_PREFERRED_NEW_EXISTING_EXISTING ;
            newRenewalOpty.RFO_Mileage__c = 30000;
            newRenewalOpty.RFO_MileageFee__c = 0.05;
            newRenewalOpty.RFO_ServiceType__c = RFO_Constant.ASSET_TRACKING;
            newRenewalOpty.RFO_ThroughBatch__c = true;
            newRenewalOpty.RFO_Commodity__c=riderRec.RFO_Commodity__c;
            
            createRenewalOptyList.add(newRenewalOpty);
            System.debug('createRenewalOptyList: '+createRenewalOptyList);
        }
        try{
            if(createRenewalOptyList.size()>0){
                //insert createRenewalOptyList;
                Database.insert(createRenewalOptyList, false);
                System.debug('createRenewalOptyList list: '+createRenewalOptyList);
                if(Source.equals(RFO_Constant.BATCH) ){
                    updateRiderStatus(riderRec);
                }
            }
        }
        catch(Exception e){
            if(Source.equals(RFO_Constant.BATCH) ){
                RFO_Utility.createErrorLogRecord(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                                 RFO_Constant.BATCH,'RFO_OpportunityHelper','createRenewalOpportunity');
            }
            else {
                RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                                       RFO_Constant.TRIGER,'RFO_OpportunityHelper','createRenewalOpportunity');
            }
        }
        
    }
    
    /**
*   Method Name: createManagementServicesOpp
*   Description: This method to create Management Opportunities.
**/
    public static void createManagementServicesOpp(RFO_Rider__c rider, String Source){
        List<Opportunity> createManagementOptyList = new List<Opportunity>();
        
        ID optyMangmntServRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId();
        if(rider.id!=null && rider.RFO_Commodity__c!=null && rider.RFO_TotalActiveCars__c!=null && 
           rider.RFO_ProductType__c!=null && rider.RFO_ProductType__c!='' && rider.RFO_Account__c!=null)
        {
            Opportunity newMngmtOpty = new Opportunity();
            newMngmtOpty.RFO_RiderID__c = rider.id;
            newMngmtOpty.RFO_Quantity__c = rider.RFO_TotalActiveCars__c;
            newMngmtOpty.RFO_MaximumQuantity__c = rider.RFO_TotalActiveCars__c;
            newMngmtOpty.RFO_ProductType__c = rider.RFO_ProductType__c;
            newMngmtOpty.AccountId = rider.RFO_Account__c;
            newMngmtOpty.CloseDate = rider.RFO_OriginalMaturityDate__c;
            newMngmtOpty.RFO_ConfidenceLevel__c = RFO_Constant.MEDIUM ;
            newMngmtOpty.StageName = RFO_Constant.INITIATED;
            newMngmtOpty.OwnerId = System.Label.RFO_MatthewDavis;//'00546000001V9ZiAAK';
            newMngmtOpty.RFO_CustomerExpectedDeliveryStartDate__c = rider.RFO_OriginalMaturityDate__c;
            
            //if(rider.RFO_RiderLeaseType__c.equals(RFO_Constant.MANAGEMENT_SERVICE) ){
            if(rider.RFO_RiderType__c.equals(RFO_Constant.MANAGEMENT_AGREEMENT) ){
                newMngmtOpty.RFO_ServiceType__c = RFO_Constant.PASS_THROUGH_MANAGEMENT;
            }
            //else if(rider.RFO_RiderLeaseType__c.equals(RFO_Constant.MAINTENANCE_SERVICE) ){
            else if(rider.RFO_RiderType__c.equals(RFO_Constant.MAINTENANCE_AGREEMENT) ){
                newMngmtOpty.RFO_ServiceType__c = RFO_Constant.MAINTENANCE ;
            }
            newMngmtOpty.RFO_Commodity__c = rider.RFO_Commodity__c;
            newMngmtOpty.RFO_Renewal__c = RFO_Constant.YES; //mandatory when initiated.
            
            newMngmtOpty.Name = RFO_Constant.OPTY_TEST_NAME; // will be updated from PB
            newMngmtOpty.RecordTypeId  = optyMangmntServRtId;
            newMngmtOpty.RFO_ThroughBatch__c = true;
            
            createManagementOptyList.add(newMngmtOpty);
        }
        try{
            if(createManagementOptyList.size()>0){
                //insert createManagementOptyList;
                System.debug('createManagementOptyList: '+createManagementOptyList);
                Database.insert(createManagementOptyList, false);
                
                if(Source.equals(RFO_Constant.BATCH) ){
                    updateRiderStatus(rider);
                }
            }
        }catch(Exception e){
            if(Source.equals(RFO_Constant.BATCH) ){
                RFO_Utility.createErrorLogRecord(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                                 RFO_Constant.BATCH,'RFO_OpportunityHelper','createManagementServicesOpp');
            }
            else {
                RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                                       RFO_Constant.TRIGER,'RFO_OpportunityHelper','createManagementServicesOpp');
            }
        }
    }
    
    /**
*   Method Name: updateRiderStatus
*   Description: This method to update Rider Status.
**/
    public static void updateRiderStatus(RFO_Rider__c rider){
        List<RFO_Rider__c> riderUpdateList = new List<RFO_Rider__c>();
        
        RFO_Rider__c riderObj = new RFO_Rider__c();
        riderObj.id = rider.id;
        riderObj.RFO_Status__c = RFO_Constant.RENEWAL_RIDER_INITIATED;
        riderUpdateList.add(riderObj);
        try{
            if(riderUpdateList.size()>0){
                //update riderUpdateList;
                Database.update(riderUpdateList, false);
            }
        }catch(Exception e){
            RFO_Utility.createErrorLogRecord(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                             RFO_Constant.BATCH,'RFO_OpportunityHelper','updateRiderStatus');
        }
    }
    /**
*   Method Name: oppStageRequiredFields
*   Description: This method is to throw custom validation message when required fields for status are missing on opportunity
* */
    public static void oppStageRequiredFields(List<Opportunity> newItems, Map<Id, SObject> oldMap){
        Map<String,String> oppStatusMap = new Map<String,String>();
        Map<String,Set<String>> requiredFieldMap = new Map<String,Set<String>>();
        Set<String> temp =  new Set<String>();
        Map<String,Set<String>> additionalFieldMap = new Map<String,Set<String>>();
        Map<String,Set<String>> renewalFieldMap = new Map<String,Set<String>>();
        String errorMessage='';
        Integer count=0, addCount=0;
        Map<id, String> recordtypeMap = new Map<id, String>();
        Map<String,String> errorMessageMap = new Map<String,String>();
        Schema.DescribeSObjectResult oppRecordtypes = Schema.SObjectType.Opportunity; 
        Map<Id,Schema.RecordTypeInfo> recordtyMap = oppRecordtypes.getRecordTypeInfosById();
        System.debug('recordTypes map: '+recordtyMap);
        //try{
        for(RFO_OpportunityfieldsRequiredStatus__mdt oppReq : 
            [Select RFO_FieldAPIName__c, RFO_RecordTypeName__c, RFO_Active__c, RFO_AdditionalConditions__c, 
             RFO_FieldLabelName__c, RFO_StageName__c, RFO_IsNew__c, RFO_IsUpdated__c, RFO_PartialTermFieldCondition__c 
             From RFO_OpportunityfieldsRequiredStatus__mdt where RFO_Active__c=TRUE Limit 49999]) {
                 oppStatusMap.put(oppReq.RFO_FieldAPIName__c,oppReq.RFO_FieldLabelName__c);
                 if(oppReq.RFO_AdditionalConditions__c==false && oppReq.RFO_PartialTermFieldCondition__c == false){
                     temp = new Set<String>();
                     if(requiredFieldMap.containsKey(oppReq.RFO_RecordTypeName__c + oppReq.RFO_StageName__c)) {
                         temp = requiredFieldMap.get(oppReq.RFO_RecordTypeName__c + oppReq.RFO_StageName__c);
                     }                         
                     temp.add(oppReq.RFO_FieldAPIName__c);
                     requiredFieldMap.put(oppReq.RFO_RecordTypeName__c + oppReq.RFO_StageName__c,temp);
                 }
                 else if(oppReq.RFO_AdditionalConditions__c==true){
                     temp = new Set<String>();
                     if(oppReq.RFO_PartialTermFieldCondition__c == true){
                         if(renewalFieldMap.containsKey(oppReq.RFO_RecordTypeName__c + oppReq.RFO_StageName__c)) {
                             temp = renewalFieldMap.get(oppReq.RFO_RecordTypeName__c + oppReq.RFO_StageName__c);
                         }
                         temp.add(oppReq.RFO_FieldAPIName__c);
                         renewalFieldMap.put(oppReq.RFO_RecordTypeName__c + oppReq.RFO_StageName__c,temp);
                     }
                     else{
                         if(additionalFieldMap.containsKey(oppReq.RFO_RecordTypeName__c + oppReq.RFO_StageName__c)) {
                             temp = additionalFieldMap.get(oppReq.RFO_RecordTypeName__c + oppReq.RFO_StageName__c);
                         }
                         temp.add(oppReq.RFO_FieldAPIName__c);
                         additionalFieldMap.put(oppReq.RFO_RecordTypeName__c + oppReq.RFO_StageName__c,temp);
                     }
                 }
             }
        System.debug('requiredFieldMap: '+requiredFieldMap);
        System.debug('renewalFieldMap: '+renewalFieldMap);
        System.debug('additionalFieldMap: '+additionalFieldMap);
        for(Opportunity oppRecord : newItems) {
            String opRecrdtyp = recordtyMap.get(oppRecord.RecordtypeId).getDeveloperName();
            System.debug('Opportunity status: '+opRecrdtyp);
            if((!requiredFieldMap.isEmpty()) && requiredFieldMap.containsKey(opRecrdtyp + oppRecord.StageName)) {
                System.debug('Entered requiredFieldMap loop');
                for(String fieldApiName : requiredFieldMap.get(opRecrdtyp + oppRecord.StageName)) {
                    System.debug('opportunity fields: '+oppRecord.get(fieldApiName));
                    if(oppRecord.get(fieldApiName)==null || oppRecord.get(fieldApiName)=='' ){
                        errorMessage += RFO_Constant.BLANK_SPACE+oppStatusMap.get(fieldApiName)+RFO_Constant.COMMA;//+String.valueOf(changeReqMap.get(fieldApiName));//
                        count = count+1;
                    }
                }                   
            }
            if((!additionalFieldMap.isEmpty()) && additionalFieldMap.containsKey(opRecrdtyp + oppRecord.StageName)){
                if((opRecrdtyp==RFO_Constant.RENEWAL_OPPORTUNITY || opRecrdtyp==RFO_Constant.RFO_MANAGEMENT_SERVICES) &&
                   (oppRecord.RFO_IsOpportunityConverted__c == false || (oppRecord.RFO_IsOpportunityConverted__c == true &&  oppRecord.CreatedDate!=oppRecord.LastModifiedDate)))
                {
                    System.debug('Entered additionalFieldMap loop');
                    for(String fieldApiName : additionalFieldMap.get(opRecrdtyp + oppRecord.StageName)) {
                        System.debug('opportunity fields: '+oppRecord.get(fieldApiName));
                        if(oppRecord.get(fieldApiName)==null || oppRecord.get(fieldApiName)=='' ){
                            errorMessage += RFO_Constant.BLANK_SPACE+oppStatusMap.get(fieldApiName)+RFO_Constant.COMMA;//+String.valueOf(changeReqMap.get(fieldApiName));//
                            count = count+1;
                        }
                    }
                }
                else if((opRecrdtyp==RFO_Constant.FREIGHT || opRecrdtyp==RFO_Constant.TANK) && 
                        oppRecord.StageName=='Closed-Won' && oppRecord.RFO_PartialLost__c!=null && oppRecord.RFO_PartialLost__c == RFO_Constant.YES)
                {
                    System.debug('Entered additionalFieldMap loop');
                    for(String fieldApiName : additionalFieldMap.get(opRecrdtyp + oppRecord.StageName)) {
                        if(oppRecord.get(fieldApiName)==null || oppRecord.get(fieldApiName)=='' ){
                            errorMessage += RFO_Constant.BLANK_SPACE+oppStatusMap.get(fieldApiName)+RFO_Constant.COMMA;//+String.valueOf(changeReqMap.get(fieldApiName));//
                            count = count+1;
                        }
                    }
                }
            }
            if((!renewalFieldMap.isEmpty()) && renewalFieldMap.containsKey(opRecrdtyp + oppRecord.StageName)){
                if(opRecrdtyp==RFO_Constant.RENEWAL_OPPORTUNITY && oppRecord.StageName=='Closed-Renewed'
                   && oppRecord.RFO_Partialtermination__c!=null && oppRecord.RFO_Partialtermination__c == RFO_Constant.YES){
                       for(String fieldApiName : renewalFieldMap.get(opRecrdtyp + oppRecord.StageName)) {
                           System.debug('opportunity fields: '+oppRecord.get(fieldApiName));
                           if(oppRecord.get(fieldApiName)==null || oppRecord.get(fieldApiName)=='' ){
                               errorMessage += RFO_Constant.BLANK_SPACE+oppStatusMap.get(fieldApiName)+RFO_Constant.COMMA;//+String.valueOf(changeReqMap.get(fieldApiName));//
                               count = count+1;
                           }
                       }
                   }
            }
            if(errorMessage!=''){
                oppRecord.addError('Please populate: \n'+errorMessage.removeEnd(RFO_Constant.COMMA)+(count>1?' fields':' field')+' on opportunity', false);
            }
        }
        /*}
        Catch(Exception e){
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.CASE_OBJECT,
            RFO_Constant.TRIGER,'RFO_CaseRequiredStatus','errorMessageOnCaseStatus');
        }*/
    }
     public static void moveQuoteStatus(Map<id,List<Opportunity>> newItemsMap){
        
       List<SBQQ__Quote__c> newQuoteList = new List<SBQQ__Quote__c>();
        List<String> stagelist= new List<String>();
        Map<id,String> quoteStatusMap = new Map<id,String>();
        List <SBQQ__Quote__c> qtBAList = [Select Id,Name,SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c,SBQQ__Opportunity2__c,RFO_QuoteStage__c,SBQQ__Opportunity2__r.StageName FROM SBQQ__Quote__c WHERE 
                                                  SBQQ__Opportunity2__c IN:newItemsMap.KeySet() AND SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c ='No' AND SBQQ__Opportunity2__r.StageName='Closed-Won'  LIMIT 49999];
         if(qtBAList.size()>0){
        for(SBQQ__Quote__c quote :qtBAList){
        quoteStatusMap.put(quote.id,quote.RFO_QuoteStage__c);
        
        }
    }
        if(quoteStatusMap.values().contains('Business Awarded')){
            for(SBQQ__Quote__c quote :qtBAList){
            if(quote.RFO_QuoteStage__c!='Business Awarded'){
                quote.RFO_QuoteStage__c='Withdrawn';
                newQuoteList.add(quote);
            
            }
        }
        system.debug('****newQuoteList***'+newQuoteList);
        if(newQuoteList.size()>0){
        update newQuoteList ;
        }
      }
   }
    /**
*   Method Name: cloneOpportunity
*   Description: This method is to clone an opportunity when Stage is Closed-Won/Closed-Lost and Partial Opportunity is Active
* */
    public static void cloneOpportunity(Map<Id,Opportunity> newMap){
        
        List<Opportunity> newOptyList = new List<Opportunity>();
        List<Opportunity> oldOptyList = new List<Opportunity>();
        List<SBQQ__Quote__c> qtList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> qtCountList = new List<SBQQ__Quote__c>();
        
        Opportunity oppNew = new Opportunity();
        
        ID optyTankRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Tank').getRecordTypeId();
        ID optyFreightRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Freight').getRecordTypeId();
        
        List<SBQQ__Quote__c> temp;
        Map<Id, List<SBQQ__Quote__c>> quoteMap = new Map<Id, List<SBQQ__Quote__c>>();
        Map<Id, List<SBQQ__Quote__c>> quoteNewMap = new Map<Id, List<SBQQ__Quote__c>>();
        if(!newMap.isEmpty()){
            for(SBQQ__Quote__c quoteRec: [Select Id,Name,SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c,SBQQ__Opportunity2__c,RFO_QuoteStage__c,SBQQ__Opportunity2__r.StageName FROM SBQQ__Quote__c WHERE 
                                                  SBQQ__Opportunity2__c in :newMap.keySet() AND RFO_QuoteStage__c = 'Business Awarded' AND SBQQ__Opportunity2__r.StageName='Closed-Won' 
                                                  AND SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c ='Yes' LIMIT 49999]){
                temp = new List<SBQQ__Quote__c>();
                if(quoteMap.containsKey(quoteRec.SBQQ__Opportunity2__c)) {
                    temp = quoteMap.get(quoteRec.SBQQ__Opportunity2__c);
                }                         
                temp.add(quoteRec);
                quoteMap.put(quoteRec.SBQQ__Opportunity2__c,temp);
                
            }
            System.debug('QuoteMap: '+quoteMap);   
            for (Opportunity opp: newMap.values()){
                String str=opp.RFO_Commodity__c;
                if (((opp.StageName == 'Closed-Won' && (!quoteMap.isEmpty()) && quoteMap.containsKey(opp.Id) && (quoteMap.get(opp.Id)).size()>0 ) || opp.StageName == 'Closed-Lost') && (opp.RFO_PartialOpportunitystillActive__c == 'Yes')
                    && (opp.RecordTypeId == optyTankRecordType ||opp.RecordTypeId == optyFreightRecordType) && (opp.RFO_ClonedOpportunity__c==false)){
                        System.debug('if entering loop'+opp.Id);
                        Opportunity originalOpp = new Opportunity(Id=opp.Id);
                        originalOpp.RFO_ClonedOpportunity__c = true;
                        originalOpp.Demand_Origination_Date__c = Date.valueOf(opp.CreatedDate);
                        System.debug('if entering loop'+opp.Id);
                        oppNew = new Opportunity();
                        oppNew =opp.clone();
                        oppNew.StageName = 'Negotiation';
                        oppNew.RFO_OriginalOpportunity__c = '<a href=' +System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+' >'+ opp.RFO_OpportunityID__c+'</a> <br/>';
                        oppNew.RFO_OriginalOpportunityId__c = opp.Id;
                        oppNew.Demand_Origination_Date__c = Date.valueOf(opp.CreatedDate);   
                        if(opp.StageName == 'Closed-Won' && opp.RFO_PartialLost__c == 'No'){                            
                            
                            // Update Original Opportunity
                            if(opp.RFO_WonQuantity__c > opp.RFO_MaximumQuantity__c){
                                originalOpp.RFO_MaximumQuantity__c = opp.RFO_MaximumQuantity__c;
                            }else{
                               originalOpp.RFO_MaximumQuantity__c = opp.RFO_WonQuantity__c;
                            }
                            
                            if(opp.RFO_WonQuantity__c > opp.RFO_Quantity__c){
                                originalOpp.RFO_Quantity__c = opp.RFO_Quantity__c;
                            }else{
                               originalOpp.RFO_Quantity__c = opp.RFO_WonQuantity__c;
                            }
                            
                            if(opp.RFO_WonQuantity__c > opp.RFO_ExpectedCarstoTrinity__c){
                                originalOpp.RFO_ExpectedCarstoTrinity__c = opp.RFO_ExpectedCarstoTrinity__c;
                            }else{
                               originalOpp.RFO_ExpectedCarstoTrinity__c = opp.RFO_WonQuantity__c;
                            }
                            
                            // Update Cloned Opportunity
                            if(opp.RFO_MaximumQuantity__c - opp.RFO_WonQuantity__c < 1){
                                oppNew.RFO_MaximumQuantity__c = 1;
                            }else{
                                oppNew.RFO_MaximumQuantity__c = opp.RFO_MaximumQuantity__c - opp.RFO_WonQuantity__c;
                            }
                            if(opp.RFO_Quantity__c - opp.RFO_WonQuantity__c < 1){
                                oppNew.RFO_Quantity__c = 1;
                            }else{
                                oppNew.RFO_Quantity__c = opp.RFO_Quantity__c - opp.RFO_WonQuantity__c;
                            }
                            
                            if(opp.RFO_ExpectedCarstoTrinity__c - opp.RFO_WonQuantity__c < 1){
                                oppNew.RFO_ExpectedCarstoTrinity__c = 1;
                            }else{
                                oppNew.RFO_ExpectedCarstoTrinity__c = opp.RFO_ExpectedCarstoTrinity__c - opp.RFO_WonQuantity__c;
                            }
                            
                        } 
                        else if(opp.StageName == 'Closed-Won' && opp.RFO_PartialLost__c == 'Yes'){
                            System.debug('Closed Won and Yes'+opp.Id);
                            //Update Original Opportunity Quantity
                            if((opp.RFO_WonQuantity__c+opp.RFO_LostQuantity__c) > opp.RFO_MaximumQuantity__c){
                                originalOpp.RFO_MaximumQuantity__c = opp.RFO_MaximumQuantity__c;
                            }else{
                                originalOpp.RFO_MaximumQuantity__c = opp.RFO_WonQuantity__c+opp.RFO_LostQuantity__c;
                            }
                            
                            if((opp.RFO_WonQuantity__c+opp.RFO_LostQuantity__c) > opp.RFO_Quantity__c){
                                originalOpp.RFO_Quantity__c = opp.RFO_Quantity__c;
                            }else{
                                originalOpp.RFO_Quantity__c = opp.RFO_WonQuantity__c+opp.RFO_LostQuantity__c;
                            }
                            
                            if((opp.RFO_WonQuantity__c+opp.RFO_LostQuantity__c) > opp.RFO_ExpectedCarstoTrinity__c){
                                originalOpp.RFO_ExpectedCarstoTrinity__c = opp.RFO_ExpectedCarstoTrinity__c;
                            }else{
                                originalOpp.RFO_ExpectedCarstoTrinity__c = opp.RFO_WonQuantity__c+opp.RFO_LostQuantity__c;
                            }
                            
                            //Update Cloned Opportunity Quantity
                            if((opp.RFO_MaximumQuantity__c - (opp.RFO_WonQuantity__c+ opp.RFO_LostQuantity__c)) < 1){
                                oppNew.RFO_MaximumQuantity__c = 1;
                            }else{
                                oppNew.RFO_MaximumQuantity__c = opp.RFO_MaximumQuantity__c - (opp.RFO_WonQuantity__c+ opp.RFO_LostQuantity__c);
                            }
                            
                            if((opp.RFO_Quantity__c - (opp.RFO_WonQuantity__c+ opp.RFO_LostQuantity__c)) < 1){
                                oppNew.RFO_Quantity__c = 1;
                            }else{
                                oppNew.RFO_Quantity__c = opp.RFO_Quantity__c - (opp.RFO_WonQuantity__c+ opp.RFO_LostQuantity__c);
                            }
                            
                            if((opp.RFO_ExpectedCarstoTrinity__c - (opp.RFO_WonQuantity__c+ opp.RFO_LostQuantity__c))< 1){
                                oppNew.RFO_ExpectedCarstoTrinity__c = 1;
                            }else{
                                oppNew.RFO_ExpectedCarstoTrinity__c = opp.RFO_ExpectedCarstoTrinity__c - (opp.RFO_WonQuantity__c+ opp.RFO_LostQuantity__c);
                            }   
                        }
                        else{
                            //update original opportunity
                            if(opp.RFO_LostQuantity__c > opp.RFO_MaximumQuantity__c){
                                originalOpp.RFO_MaximumQuantity__c = opp.RFO_MaximumQuantity__c;
                            }else{
                               originalOpp.RFO_MaximumQuantity__c = opp.RFO_LostQuantity__c;
                            }
                            
                            if(opp.RFO_LostQuantity__c > opp.RFO_Quantity__c){
                                originalOpp.RFO_Quantity__c = opp.RFO_Quantity__c;
                            }else{
                               originalOpp.RFO_Quantity__c = opp.RFO_LostQuantity__c;
                            }
                            
                            if(opp.RFO_LostQuantity__c > opp.RFO_ExpectedCarstoTrinity__c){
                                originalOpp.RFO_ExpectedCarstoTrinity__c = opp.RFO_ExpectedCarstoTrinity__c;
                            }else{
                               originalOpp.RFO_ExpectedCarstoTrinity__c = opp.RFO_LostQuantity__c;
                            }
                            
                            // Update Cloned Opportunity
                            if(opp.RFO_MaximumQuantity__c - opp.RFO_LostQuantity__c < 1){
                                oppNew.RFO_MaximumQuantity__c = 1;
                            }else{
                                oppNew.RFO_MaximumQuantity__c = opp.RFO_MaximumQuantity__c - opp.RFO_LostQuantity__c;
                            }
                            
                            if(opp.RFO_Quantity__c - opp.RFO_LostQuantity__c < 1){
                                oppNew.RFO_Quantity__c = 1;
                            }else{
                                oppNew.RFO_Quantity__c = opp.RFO_Quantity__c - opp.RFO_LostQuantity__c;
                            }
                            
                            if(opp.RFO_ExpectedCarstoTrinity__c - opp.RFO_LostQuantity__c < 1){
                                oppNew.RFO_ExpectedCarstoTrinity__c = 1;
                            }else{
                                oppNew.RFO_ExpectedCarstoTrinity__c = opp.RFO_ExpectedCarstoTrinity__c - opp.RFO_LostQuantity__c;
                            }
                            
                        }                        
                        newOptyList.add(oppNew);
                        oldOptyList.add(originalOpp);
                        
                    }
            }
        }
         system.debug('oldOpty' + oldOptyList);
        if(oldOptyList.size() > 0){
                update oldOptyList;
                
            }
        system.debug('newOpty' + newOptyList);
        if(newOptyList.size() > 0){
                insert newOptyList;
            }
    }
    public static void clonedOpportunityQuoteAssignment(List<Opportunity> newItems){
        Map<Id, Id> oppMap = new Map<Id, Id>();
        List<SBQQ__Quote__c> temp;
        Integer count = 0;
        Set<Id> originalOppRecIdSet = new Set<Id>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteDelList = new List<SBQQ__Quote__c>();
        Map<Id, List<SBQQ__Quote__c>> quoteNewMap = new Map<Id, List<SBQQ__Quote__c>>();
        Opportunity oppRec1;
        List<SBQQ__Quote__Share> quoteShareRecds = new List<SBQQ__Quote__Share>();
        for(Opportunity oppRec : newItems){
            if(oppRec.RFO_OriginalOpportunity__c!=null && oppRec.RFO_OriginalOpportunity__c!='' && oppRec.RFO_OriginalOpportunityId__c!=null){
                originalOppRecIdSet.add(oppRec.RFO_OriginalOpportunityId__c);
                 System.debug('entered loop: ');
                oppMap.put(oppRec.RFO_OriginalOpportunityId__c, oppRec.Id);
            }
        }
         System.debug('Values: ' +oppMap);
        if(!originalOppRecIdSet.isEmpty()){
            for(SBQQ__Quote__c quoteRec: [Select Id,Name,SBQQ__Opportunity2__c,ownerid, SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__c,RFO_QuoteTeam__c,SBQQ__Primary__c,RFO_QuoteStage__c FROM SBQQ__Quote__c WHERE 
                                          SBQQ__Opportunity2__c in :oppMap.keySet() AND RFO_QuoteStage__c NOT IN ('Business Awarded','Withdrawn')
                                          AND (SBQQ__Opportunity2__r.StageName='Closed-Lost'OR SBQQ__Opportunity2__r.StageName='Closed-Won') 
                                          AND SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c ='Yes' 
                                          AND SBQQ__Primary__c = false LIMIT 49999]){
                    SBQQ__Quote__c qtUpdt = new SBQQ__Quote__c();
                    qtUpdt.Id=quoteRec.Id;
                    qtUpdt.SBQQ__Opportunity2__c = oppMap.get(quoteRec.SBQQ__Opportunity2__c);
                    qtUpdt.RFO_QuoteTeam__c = quoteRec.RFO_QuoteTeam__c;
                     quoteList.add(qtUpdt);
           }
        }
        if(!quoteList.isEmpty()){
            update quoteList;
            RFO_CpqTriggerSwitch.disableCpqTriggers();
            quoteList[0].SBQQ__Primary__c = true;
            update quoteList[0];
            RFO_CpqTriggerSwitch.disableCpqTriggers();
        }        
        
    }
    public static void moveOpportunityStatus(List<Opportunity> newItems, Map<Id, SObject> oldMap){
        
        List<SBQQ__Quote__c> newQuoteList = new List<SBQQ__Quote__c>();
        List<String> stagelist= new List<String>();
        Map<id,String> quoteStatusMap = new Map<id,String>();
        List <SBQQ__Quote__c> qtBAList = [Select Id,Name,SBQQ__Opportunity2__c,RFO_QuoteStage__c,SBQQ__Opportunity2__r.StageName FROM SBQQ__Quote__c WHERE 
                                                  SBQQ__Opportunity2__c IN:newItems AND RFO_QuoteStage__c='Business Awarded'  LIMIT 49999];
         if(qtBAList.size()>0){
            for(Opportunity oppRecord : newItems) {
                if(oppRecord.StageName=='Closed-Withdrawn' || oppRecord.StageName=='Closed-Lost'){
                oppRecord.addError('Opportunity should be marked as Closed-Won when a Quote is Business Awarded', false);
                }
            }
        } 
    }
    public static void resetOpportunityOwner(List<Opportunity> newItems, Map<Id, Opportunity> oldMap){
        for(Opportunity oppRecord : newItems) {
            if((oppRecord.StageName=='Closed-Won' || oppRecord.StageName=='Closed-Lost'
                || oppRecord.StageName=='Closed-Withdrawn' || oppRecord.StageName=='Closed-Renewed'
                || oppRecord.StageName=='Closed-Termination')
                && (oppRecord.OwnerId != oldMap.get(oppRecord.Id).OwnerId)){
                
                oppRecord.OwnerId = oldMap.get(oppRecord.Id).OwnerId;
            }
        }
    }
    public static void moveQuoteStatusToWithdrawn(Map<id,List<Opportunity>> newItemsMap){
        
        List<SBQQ__Quote__c> terminatedlist = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> withdrwanlist = new List<SBQQ__Quote__c>();
        Map<id,String> quoteStatusMap = new Map<id,String>();
        ID optyRenewalRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY ).getRecordTypeId();
        ID optyTankRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Tank').getRecordTypeId();
        ID optyFreightRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Freight').getRecordTypeId(); 
        ID optyMangmntServRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId(); 
        List <SBQQ__Quote__c> qtlist = [Select Id,Name,SBQQ__Opportunity2__r.RecordTypeId,SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c,SBQQ__Opportunity2__c,RFO_QuoteStage__c,SBQQ__Opportunity2__r.StageName FROM SBQQ__Quote__c WHERE 
                                        SBQQ__Opportunity2__c IN:newItemsMap.KeySet() LIMIT 49999];
        
        if(qtlist.size()>0){
            for(SBQQ__Quote__c qte :qtlist){
                if((qte.SBQQ__Opportunity2__r.StageName=='Closed-Withdrawn' || qte.SBQQ__Opportunity2__r.StageName=='Closed-Lost')){
                    if(qte.SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c== 'NO' && (qte.SBQQ__Opportunity2__r.RecordTypeId== optyTankRecordType || qte.SBQQ__Opportunity2__r.RecordTypeId==optyFreightRecordType)){
                        
                        qte.RFO_QuoteStage__c='Withdrawn';
                        withdrwanlist.add(qte);
                        
                    }
                    else if(qte.SBQQ__Opportunity2__r.RecordTypeId== optyMangmntServRtId ){
                        qte.RFO_QuoteStage__c='Withdrawn';
                        withdrwanlist.add(qte);
                    }
                }
                else if(qte.SBQQ__Opportunity2__r.RecordTypeId== optyRenewalRtId && qte.SBQQ__Opportunity2__r.StageName=='Closed-Termination'){
                    qte.RFO_QuoteStage__c='Withdrawn';
                    terminatedlist.add(qte);
                }
            }
            
        }
        if(withdrwanlist.size()>0){
            database.update(withdrwanlist);
        }
        if(terminatedlist.size()>0){
            database.update(terminatedlist) ;
        }
        
        
    }
    


    /* Added by Vihari ALPHA - 932 */
    public static void createClosedTerminationTask(List<Opportunity> opps){
    
       	Set<Id> accIds = new Set<Id>();
        
        for(Opportunity o:opps){
            accIds.add(o.accountId);
        }
        
        try{

            // Get CDM from the AccountTeamMember
            Map<String,AccountTeamMember> accountToAccCDMTeamMap = AccountTeamMemberService.getAccountCDMMembers(accIds);

            if(accountToAccCDMTeamMap.keySet().size()>0){
                List<Task> taskList = getTasksToInsert(opps, accountToAccCDMTeamMap);
                insert taskList;
        	} 
        }catch(Exception e){
            throw e;
        }
    }
    
    public static List<Task> getTasksToInsert(List<Opportunity> opps, Map<String,AccountTeamMember> accountToAccCDMTeamMap){
        List<Task> taskList = new List<Task>(); 
        for(Opportunity o:opps){
            TaskService ts = new TaskService();
            String recipient = accountToAccCDMTeamMap.get(o.AccountId)?.UserId;
            
            //Check if Recipient is not blank
            if(String.isNotBlank(recipient)){
                task t = ts.createTask('Opportunity - '+o.RFO_OpportunityID__c+' is Closed-Terminated', RFO_Constant.Task_Status_Open , RFO_Constant.Task_Priority_Normal, o.id, recipient);
                taskList.add(t);
            }
        }
        return taskList;
    }
    /* End by Vihari ALPHA - 932 */
   
            
    
}