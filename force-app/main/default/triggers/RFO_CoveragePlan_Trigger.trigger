trigger RFO_CoveragePlan_Trigger on RFO_CoveragePlan__c (before insert, after insert, after update) {
    RFO_CoveragePlanHandlerClass helper = new RFO_CoveragePlanHandlerClass ();
    if(Trigger.isAfter && RFO_CoveragePlanHandlerClass.isRecurrsive){
     if(Trigger.isInsert){
         helper.createNewCPafterCPlanChangeApproved(Trigger.oldMap, Trigger.newMap);
         helper.createNewCPwithAdmin(Trigger.oldMap, Trigger.newMap);
     } // end of after insert
     
     if(Trigger.isUpdate){
         helper.createNewCPafterCPlanChangeApproved(Trigger.oldMap, Trigger.newMap);
         helper.createNewCPwithAdmin(Trigger.oldMap, Trigger.newMap);
        // helper.createNewCPwhenActOwnersManagerChangeCP(Trigger.oldMap, Trigger.newMap);
        helper.createNewCPforManager(Trigger.oldMap, Trigger.newMap);
     } // end of after Update
     
    } // end of isAfter
    RFO_CoveragePlanHandlerClass.isRecurrsive = false;
    
    if(trigger.isBefore) {
        if(trigger.isInsert) { 
            helper.coverageCalculations(trigger.new);
        }
    }
    
} // end of trigger