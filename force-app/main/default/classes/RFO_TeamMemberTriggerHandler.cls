/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 
* @Description : This Class is used to call team member helper actions.
                           
**/
public class RFO_TeamMemberTriggerHandler implements ITriggerHandler{
// Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean triggerDisabled = false;
    RFO_TriggerSetting__mdt quoteTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='TeamMemberTrigger' LIMIT 1];
    /*****
Checks to see if the trigger has been disabled either by custom setting or by running code
*****/
    public Boolean isDisabled()
    {
        if (quoteTrigger.RFO_Active__c){
            return triggerDisabled;
        }else{
            return true;
        }
    }
    
     
    /*****
* Method Name: BeforeInsert
*****/
    public void beforeInsert(List<SObject> newItems) {}
     /**
* Method Name: beforeUpdate
**/
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
         /**
* Method Name: beforeDelete
**/
    public void beforeDelete(Map<Id, SObject> oldItems) {}
    
    /**
* Method Name: afterInsert
**/
    public void afterInsert(Map<Id, SObject> newItems) {
        try{
             RFO_TeamMemberHelper.updateQuoteTeamMembers((List<RFO_TeamMembers__c>)newItems.values());
        }  
        catch(Exception e) {   
                    RFO_Utility.createErrorLogRecordFuture(e.getMessage(),'QuoteTeamMember',
                                                           RFO_Constant.TRIGER,'RFO_QuoteTeamMemberTriggerHandler','afterInsert');
        }
   
    }
    /**
* Method Name: afterUpdate
**/
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
         try{
             RFO_TeamMemberHelper.updateQuoteTeamMembers((List<RFO_TeamMembers__c>)newItems.values());
        }  
        catch(Exception e) {   
                    RFO_Utility.createErrorLogRecordFuture(e.getMessage(),'QuoteTeamMember',
                                                           RFO_Constant.TRIGER,'RFO_QuoteTeamMemberTriggerHandler','afterUpdate');
        }
    }
     /**
* Method Name: afterDelete
**/
    public void afterDelete(Map<Id, SObject> oldItems) {
           try{
             RFO_TeamMemberHelper.updateQuoteTeamMembers((List<RFO_TeamMembers__c>)oldItems.values());
        }  
        catch(Exception e) {   
                    RFO_Utility.createErrorLogRecordFuture(e.getMessage(),'QuoteTeamMember',
                                                           RFO_Constant.TRIGER,'RFO_QuoteTeamMemberTriggerHandler','afterDelete');
        }
    }
    
    /**
* Method Name: afterUndelete
**/
    public void afterUndelete(Map<Id, SObject> oldItems) {}
}