/**
* @Author      : Accenture  
* @Version     : 1.0
* @Created Date: 7 May 2019
* @Description :This batch class is to update the Account record with global accountid.

History
*
* 17JUL2019 | I Martinez | SIT-WK2-IM-071719 | Added the Customer and Third Party Sales record type to the query scope.
                                               This will address updating any existing accounts without a Global Id
**/
global class RFO_UpdateGlobalAccountIdBatch implements Database.Batchable<sObject>,   Database.AllowsCallouts {
    
    Id prosRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_Prospect).getRecordTypeId();
    Id tPProsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_ThirdPartyProspect).getRecordTypeId();
    Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_Customer).getRecordTypeId();
    Id tPSalesRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_ThirdPartySalesRec).getRecordTypeId();
    public String query = 'select Id, RFO_GlobalAccountID__c, RecordTypeId from Account where RecordTypeId in (:prosRecordTypeId, :tPProsRecordTypeId, :customerRecordTypeId, :tPSalesRecordTypeId) and RFO_GlobalAccountID__c = null';
/**
*   start method
**/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
/**
*   execute method
**/
    global void execute(Database.BatchableContext BC, List<Account> records) {         
        try{
            if(records.size()>0){
                    for (Account acct : records) {
                        RFO_GlobalCallOut.getRFOGlobalAccountId(acct.id);
                    }
            }
        }
        catch(Exception e) {  
            RFO_Utility.createErrorLogRecord(e.getMessage(),RFO_Constant.ACCOUNT_OBJECT,
                                             RFO_Constant.BATCH,'RFO_UpdateGlobalAccountIdBatch','execute');
        }
    }  
/**
*   Finish method
**/
    global void finish(Database.BatchableContext BC){  
    }
}