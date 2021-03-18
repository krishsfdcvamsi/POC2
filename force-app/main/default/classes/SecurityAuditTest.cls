/**********************************************************************************************************
Name: SecurityAuditTest
(c) 2020 

Purpose: Class to test the population of Audit_Permissions__c from data retrieved from 
         Security_Report_Configuration__mdt and Profile

**********************************************************************************************************/

@isTest
public class SecurityAuditTest {

static testmethod void testSecurityAuditInitialize(){

    //Test Data
    Integer numRecs = 3;
    List<Audit_Permissions__c> ap = new List<Audit_Permissions__c>();
        
    for(Integer i=0;i<numRecs;i++) {
        Audit_Permissions__c a = new Audit_Permissions__c(Persona_Name__c='Persona Name' + i);
        ap.add(a);
    }
    insert ap;
        
    Test.startTest();
    
        SecurityAuditInitialize.batchExecute = false;
        
        SecurityAuditInitialize batchInit = new SecurityAuditInitialize();
        batchInit.query = 'SELECT Id FROM Audit_Permissions__c';
        Id batchIdInit = Database.executeBatch(batchInit,100); 
        System.debug('jobID Initialize: ' + batchIdInit);
    
    Test.stopTest();       
    
    //Validate job Id
    System.assertNotEquals(batchIdInit, null);
}

static testmethod void testSecurityAuditObjectPermissions(){
        
    Test.startTest();
    
        SecurityAuditObjectPermissions.batchExecute = false;
        
        SecurityAuditObjectPermissions batchObjPerms = new SecurityAuditObjectPermissions(); 
        Id batchIdObjPerms = Database.executeBatch(batchObjPerms,100); 
        System.debug('jobID Object Permissions: ' + batchIdObjPerms);
    
    Test.stopTest();       
    
    //Validate job Id
    System.assertNotEquals(batchIdObjPerms, null);
}
    
static testmethod void testSecurityAuditFieldPermissions(){

    //Test Data
    Integer numRecs = 3;
    List<Audit_Permissions__c> ap = new List<Audit_Permissions__c>();
        
    for(Integer i=0;i<numRecs;i++) {
        Audit_Permissions__c a = new Audit_Permissions__c(Persona_Name__c='Persona Name' + i, Sobject_Name__c='Account', Sobject_Type__c='ObjectPermissions', Read_Access__c=true, Edit_Access__c=false);
        ap.add(a);
    }
    insert ap;
        
    Test.startTest();
    
        SecurityAuditFieldPermissions.batchExecute = false;
        
        SecurityAuditFieldPermissions batchFieldPerms = new SecurityAuditFieldPermissions(); 
        Id batchIdFieldPerms = Database.executeBatch(batchFieldPerms,100);   
        System.debug('jobID Field Permissions: ' + batchIdFieldPerms);
    
    Test.stopTest();       
    
    //Validate job Id
    System.assertNotEquals(batchIdFieldPerms, null);
}

static testmethod void testSecurityAuditPermissionSet(){

    Test.startTest();
        
        SecurityAuditPermissionSet batchPermSet = new SecurityAuditPermissionSet(); 
        Id batchIdPermSet = Database.executeBatch(batchPermSet,50);
        System.debug('jobID Permission Set: ' + batchIdPermSet);
    
    Test.stopTest();       
    
    //Validate job Id
    System.assertNotEquals(batchIdPermSet, null);
}

static testmethod void testSecurityAuditScheduler(){
        
    Test.startTest();
        
        SecurityAuditScheduler secAudit = new SecurityAuditScheduler();
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String scheduleConfig = '0 0 23 * * ?';
        String jobIdScheduler = system.schedule('Test Audit User Access Report', scheduleConfig, secAudit); 
    
    Test.stopTest();  
    
    //Validate job Id
    System.assertNotEquals(jobIdScheduler, null);     
    
}

}