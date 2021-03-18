/*Trigger Name:-RFO_CallReportTrigger
*/
trigger RFO_CallReportTrigger on Call_Report__c (after insert, after update, before insert, before update) {
    if(Trigger.isAfter){
         if(Trigger.isInsert || Trigger.isUpdate){
            
             RFO_CoveragePlanHandlerClass cpHelper = new RFO_CoveragePlanHandlerClass();
             if(!RFO_CoveragePlanHandlerClass.callrepotRecursionCheck){
                 cpHelper.callReportForActualContactDate(Trigger.newMap,trigger.oldMap);
                 RFO_CoveragePlanHandlerClass.callrepotRecursionCheck=true;
             } //recursive end 
         } //end of After insert, After Update
    } //end of After
    if(Trigger.isBefore){
        if(Trigger.isInsert|| Trigger.isUpdate){
            //old method deleted
            RFO_CallReportTriggerHandler.updateAccountRelatedEmail(Trigger.New);
            RFO_CallReportTriggerHandler.ValidateCallReportStatus(Trigger.New);
            RFO_CallReportTriggerHandler.previousCallDate(trigger.new,trigger.oldMap);
            System.debug('Method call completed');
            //done

        }
    }
    
}