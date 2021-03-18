global class RFO_CPPlanStatusScheduler implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    //Variable Section
    global FINAL String strQuery;
    
    global RFO_CPPlanStatusScheduler() { 
        this.strQuery = getBatchQuery();
    }
    
    //Returns the Query String to Batch constructor to fetch right records.
    private String getBatchQuery() {
        String strQuery = 'SELECT Id FROM RFO_CoveragePlan__c WHERE RFO_AccountName__c!=null and RFO_RecordStatus__c = true and (RFO_NextTargetContactDate__c != null OR RFO_NextScheduledContactDate__c != null)';
        return strQuery;
    }
    
    //Batch Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }

    //Batch Execute method calls findCostForWoD method
    global void execute(Database.BatchableContext BC, List<sObject> scopeList) {
    List<RFO_CoveragePlan__c> planToUpdate = new List<RFO_CoveragePlan__c>();
        System.debug(LoggingLevel.INFO, '== scopeList size ==' + scopeList.size());
        List<RFO_CoveragePlan__c> CPPlanList = (List<RFO_CoveragePlan__c>) scopeList;
        if(!CPPlanList.isEmpty()) { 
            Database.update(CPPlanList);
        }
    }  

    global void finish(Database.BatchableContext BC) { 
    }
    //Method which schedules the RFO_CPPlanStatusScheduler
    global void execute(SchedulableContext sc) {        
        RFO_CPPlanStatusScheduler snInstance = new RFO_CPPlanStatusScheduler();
        ID batchprocessid = Database.executeBatch(snInstance);
    }
}