/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 20th June 2019
* @Description : 
*                
**/
public class RFO_OpportunityTriggerHandler implements ITriggerHandler{
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean triggerDisabled = false;
    RFO_TriggerSetting__mdt caseTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='OpportunityTrigger' LIMIT 1];
    /*****
Checks to see if the trigger has been disabled either by custom setting or by running code
*****/
    public Boolean isDisabled()
    {
        if (caseTrigger.RFO_Active__c){
            return triggerDisabled;
        }else{
            return true;
        }
    }
    
    /*****
* Method Name: BeforeInsert
*****/
    public void beforeInsert(List<SObject> newItems) {
        set<Id> riderIdSet = new set<Id>();
        //Integer Count = 0;
        //Map<Id, Integer> opportunityMap= new Map<Id, Integer>();
        ID optyRenewalRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY).getRecordTypeId(); 
        ID optyMangmntServRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId();
        List<Pricebook2> standardPriceBookList = [select Id, Name, IsActive from PriceBook2 where IsStandard  = TRUE LIMIT 1];
        
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        
        for(Opportunity opp: (List<Opportunity>)newItems){
             if(opp.RecordtypeId != null && standardPriceBookList != null){
                opp.Pricebook2Id = standardPriceBookList[0].id;
                
            }
            riderIdSet.add(opp.RFO_RiderID__c);
        }
        if(riderIdSet.size()>0){
            for(Opportunity opp: [select id, RFO_RiderID__c, RecordTypeId from opportunity where RFO_RiderID__c in :riderIdSet and (recordtypeId =:optyRenewalRtId or recordtypeId =:optyMangmntServRtId) LIMIT 49999] ){
                oppMap.put(opp.RFO_RiderID__c, opp);
            }
            if(!oppMap.isEmpty()){
                try{
                    for(Opportunity oppRec: (List<Opportunity>)newItems){
                        if(oppRec.RFO_RiderID__c!=null && oppMap.containsKey(oppRec.RFO_RiderID__c) && oppRec.RecordTypeId == oppMap.get(oppRec.RFO_RiderID__c).RecordTypeId && oppRec.RecordTypeId == optyRenewalRtId){
                            oppRec.addError('You cannot create more than one Renewal Opportunity for a Rider.');
                        }
                        else if(oppRec.RFO_RiderID__c!=null && oppMap.containsKey(oppRec.RFO_RiderID__c) && oppRec.RecordTypeId == optyMangmntServRtId && oppRec.RecordTypeId == oppMap.get(oppRec.RFO_RiderID__c).RecordTypeId){
                            oppRec.addError('You cannot create more than one Management Opportunity for a Rider.');
                        }
                    }
                }
                catch(Exception e) {   
                    RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                                           RFO_Constant.TRIGER,'RFO_OpportunityTriggerHandler','beforeInsert');
                }
            }
        }
        try{
            RFO_OpportunityHelper.oppStageRequiredFields((List<Opportunity>)newItems, null);
        }
        catch(Exception e) {   
                    RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                                           RFO_Constant.TRIGER,'RFO_OpportunityTriggerHandler','beforeInsert');
        }
    }
    
    /**
* Method Name: beforeUpdate
**/
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try{
            RFO_OpportunityHelper.oppStageRequiredFields((List<Opportunity>)newItems.values(), oldItems);
            RFO_OpportunityHelper.moveOpportunityStatus((List<Opportunity>)newItems.values(), oldItems);
            RFO_OpportunityHelper.resetOpportunityOwner((List<Opportunity>)newItems.values(), (Map<Id, Opportunity>)oldItems);
        }
        catch(Exception e) {   
                    RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                                           RFO_Constant.TRIGER,'RFO_OpportunityTriggerHandler','beforeUpdate');
        }
    }
    
    /**
* Method Name: beforeDelete
**/
    public void beforeDelete(Map<Id, SObject> oldItems) {}
    
    /**
* Method Name: afterInsert
**/
    public void afterInsert(Map<Id, SObject> newItems) {
        try{
            RFO_OpportunityHelper.clonedOpportunityQuoteAssignment((List<Opportunity>)newItems.values());
            Map<id,Opportunity> oppNewMap = (Map<id,Opportunity>)newItems;
            set<id> accountIds = new set<id>();
            Id tankRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tank').getRecordTypeId();
            Id freightRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Freight').getRecordTypeId();
            for(Opportunity opp: oppNewMap.values()){
                if(opp.RFO_MaximumQuantity__c != null
                    && (opp.recordtypeId == tankRecordTypeId || opp.recordtypeId == freightRecordTypeId)
                    && opp.createdDate >= Date.Today().addDays(-365) ) {         // Added by MA Alpha-33
                    accountIds.add(opp.accountId);
                }
                
            }
            if(accountIds.size() > 0) {
                RFO_CoverageUtility.calculateRecommendedCoverage(RFO_CoverageUtility.getAccountFleet(accountIds), RFO_CoverageUtility.getOpportunitesCount(accountIds), RFO_CoverageUtility.getRidersCount(accountIds));
            }
        }
        catch(Exception e) {   
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                                   RFO_Constant.TRIGER,'RFO_OpportunityTriggerHandler','afterUpdate');
        }
    }
    
    /**
* Method Name: afterUpdate
**/
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
     try{
            List<Opportunity> oppUpdateList = new List<Opportunity>();
             Map<id,Opportunity> oppNewlist = (Map<id,Opportunity>)newItems;
             Map<id,Opportunity> oppOldlist = (Map<id,Opportunity>)oldItems;
            Map<id,List<Opportunity>> oppNewMap = new Map<id,List<Opportunity>>();
            set<id> accountIds = new set<id>();
            
            Id tankRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tank').getRecordTypeId();
            Id freightRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Freight').getRecordTypeId();
            
            /* Added by Vihari ALPHA - 932 */
         	List<Opportunity> closedTerminatedOpps = new List<Opportunity>();
            Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY).getRecordTypeId();
            /* End ALPHA-932 */
                
            for(Opportunity opp: oppNewlist.values()){
                if(opp.StageName != oppOldlist.get(opp.id).StageName){ 
                    oppUpdateList.add(opp);
                  oppNewMap.put(opp.id, oppUpdateList);
                }
                if(opp.RFO_MaximumQuantity__c != null && opp.RFO_MaximumQuantity__c != oppOldlist.get(opp.id).RFO_MaximumQuantity__c
                    && (opp.recordtypeId == tankRecordTypeId || opp.recordtypeId == freightRecordTypeId)
                    && opp.createdDate >= Date.Today().addDays(-365)) {   // Added by MA Alpha-33
                    accountIds.add(opp.accountId);
                }
                /* Added by Vihari ALPHA - 932 */
                if(opp.recordtypeId == renewalRecordTypeId && opp.StageName == RFO_Constant.Opportunity_Stage_Closed_Termination
                   && opp.StageName != oppOldlist.get(opp.id).StageName){
                    closedTerminatedOpps.add(opp);   
                }
                /* End by Vihari ALPHA - 932 */
                
            }
            if(accountIds.size() > 0) {
                RFO_CoverageUtility.calculateRecommendedCoverage(RFO_CoverageUtility.getAccountFleet(accountIds), RFO_CoverageUtility.getOpportunitesCount(accountIds), RFO_CoverageUtility.getRidersCount(accountIds));
            }
    if(!oppNewMap.isEmpty()){       
            RFO_OpportunityHelper.moveQuoteStatus(oppNewMap);
            RFO_OpportunityHelper.moveQuoteStatusToWithdrawn(oppNewMap);
         }
            RFO_OpportunityHelper.cloneOpportunity((Map<Id,Opportunity>)newItems);
         	/* Added by Vihari ALPHA - 932 */
         	if(closedTerminatedOpps.size()>0)RFO_OpportunityHelper.createClosedTerminationTask(closedTerminatedOpps);
            /* End by Vihari ALPHA - 932 */
        }
        catch(Exception e) {   
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                                   RFO_Constant.TRIGER,'RFO_OpportunityTriggerHandler','afterUpdate');
        }
    }
    
    /**
* Method Name: afterDelete
**/
    public void afterDelete(Map<Id, SObject> oldItems) {}
    
    /**
* Method Name: afterUndelete
**/
    public void afterUndelete(Map<Id, SObject> oldItems) {}
}