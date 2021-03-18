/**********************************************************************************************************
Name: SecurityAuditInitialize
(c) 2020 

Purpose: Class to delete Audit_Permissions__c to be refreshed and retrieve permissions from 
         Security_Report_Configuration__mdt and Profile

**********************************************************************************************************/

global class SecurityAuditInitialize implements Database.Batchable<sObject> {

    @TestVisible private static Boolean batchExecute = true; 
    
    global String query;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Sobject> scope) {
        if(scope.size() > 0){
            Database.delete(scope,false); 
            Database.emptyRecycleBin(scope);
        }
    }
    
    global void finish(Database.BatchableContext bc){
        //Start batch chain execution - Object Permissions
        if(batchExecute){ 
            SecurityAuditObjectPermissions batchObjPerms = new SecurityAuditObjectPermissions(); 
            Id batchIdObjPerms = Database.executeBatch(batchObjPerms,100);
        }
    }

}