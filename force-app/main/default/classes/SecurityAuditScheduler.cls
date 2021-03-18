/**********************************************************************************************************
Name: SecurityAuditScheduler
(c) 2020 

Purpose: Class to execute the scheduler to populate Audit_Permissions__c with permssions 
         retrieved from Security_Report_Configuration__mdt and Profile 

**********************************************************************************************************/

Global with sharing class SecurityAuditScheduler implements Schedulable {

  Global void execute(SchedulableContext ctx) {
      SecurityAuditInitialize batchInit = new SecurityAuditInitialize();
      batchInit.query = 'SELECT Id FROM Audit_Permissions__c';
      Id batchIdInit = Database.executeBatch(batchInit,100);
      System.debug('jobID: ' + batchIdInit);
  }
}