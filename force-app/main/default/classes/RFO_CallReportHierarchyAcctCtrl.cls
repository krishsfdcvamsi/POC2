public class RFO_CallReportHierarchyAcctCtrl {

    @auraEnabled
    public static List<Call_Report__c> getCallReportsForHierachyAccounts(Id objId){
        List<Account> childAccounts = [Select Id from Account where ParentId = :objId or Id= :objId];
        List<Call_Report__c> callReportList = [select Id, Name,Account__r.Name,RFO_Purpose__c,Action_Next_Step__c,Contact__r.Name,Call_Date__c,Deadline__c,Objective_Fulfilled__c from Call_Report__c where Account__c in :childAccounts];
        return callReportList;
    }
}