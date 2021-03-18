trigger RFO_CaseTrigger on Case (after insert,before update,before insert, after update) {
  
  // Start Alpha-520 & 521 Changed by Haseeb & Ramesh
  //  Purpose: Updates order status based Case Status.

    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
    CaseTriggerHandler.updateOrderStatus(Trigger.new, Trigger.oldMap);
        // Alpha-676
            RFO_CaseHelper.newCarAlertEstimatingStart(Trigger.new,Trigger.oldMap);
    }


	// End of Alpha-520 & 521


    System.debug('entered trigger 1');

    //Execute trigger only if RFO_TriggeSetting__mdt CMD of account is enabled
    RFO_TriggerSetting__mdt caseTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='CaseTrigger'];

    //Enable trigger execution from CMD
    if(caseTrigger.RFO_Active__c) {
        if(!RFO_RecursionHandler.isRecursive && Trigger.isAfter && Trigger.isInsert){
            RFO_RecursionHandler.isRecursive = true;
             RFO_CaseHelper.caseAssignment(trigger.new);            
        }
        if(Trigger.isUpdate && Trigger.isBefore) {
            System.debug('entered trigger');
            RFO_CaseRequiredStatus.errorMessageOnCaseStatus(Trigger.newMap);
            RFO_CaseHelper.validateAccountContactRelation(trigger.new);
            
            
            //EPSI 382/383 - added for Customer Disputes
            RFO_CaseHelper.updateStatusAndClockTime(trigger.new,Trigger.oldMap);
        }    
        if (Trigger.isBefore && Trigger.isInsert){
            RFO_CaseHelper.Account_CaseUpdate(trigger.new);
            RFO_CaseHelper.validateAccountContactRelation(trigger.new);
        }        


        
        //Added by Vihari ALPHA-677
        if(Trigger.isAfter && Trigger.isUpdate ){
            CaseTriggerHandler.afterUpdate(trigger.new,Trigger.oldMap);

        }
    }  
}