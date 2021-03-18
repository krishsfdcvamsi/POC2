/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 11th 10 2018, Modified Date: 27th May 2020
* @Description :This is test class for RFO_CoveragePlanHandlerClass.
**/
@isTest
private class RFO_CoveragePlanHandlerClass_Test {
    @testsetup static void testDataSetup(){
        List<Account> accList = new List<Account>();
       
        Profile profileId = [Select Id, Name from Profile where Name = 'System Administrator' limit 1];
        //Profile profileId1 = [Select Id, Name from Profile where Name =: 'RFO - Sales' limit 1];
        UserRole roleId;
        UserRole salesReproleId;
        try {
            roleId =[Select Id,Name from UserRole where Name = 'Commercial-30' limit 1];
            salesReproleId =[Select Id,Name from UserRole where Name = 'Commercial - East-40' limit 1];
        }
        catch(QueryException e) {
            roleId =[Select Id,Name from UserRole limit 1];
            salesReproleId =[Select Id,Name from UserRole limit 1];
        }
        
        Map<Id, Task> TaskNewMp = new Map<Id, Task>(); 
        
        Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        Id RecordTypeIdCS = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
        Id activeRecordTypeId = Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get('RFO_Active').getRecordTypeId();
        
        Map<Id, RFO_CoveragePlan__c> newCPMap = new Map<Id, RFO_CoveragePlan__c>();
        Map<Id, RFO_CoveragePlan__c> oldCPMap = new Map<Id, RFO_CoveragePlan__c>();
        
        User userRec = createUser();
        User userRec1 = createUser1();
        system.runAs(userRec){
           account ac =new account();
           ac.Name = 'BNSF';  // Account Name
           ac.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
           ac.Phone = '800-832-5452';          // Phone
           ac.RFO_Region__c = 'Class 1 Railroads';   // Region
           ac.RFO_AccountStatus__c = 'Active';
           ac.OwnerId = userRec1.id;
           database.insert(ac,false);
           accList.add(ac);
           
           Contact cnt = new Contact(
               FirstName = 'Tony',         // FirstName
               LastName = 'Alen',            // LastName
               RFO_Status__c = 'Active',                                               // Status
               Email = 'Tony.Alen@trinity.net',                                  // Email
               AccountId = accList[0].id,                                          // Account Name
               Phone = '(806) 381-0261',                                               // Phone
               RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
               Fax = '(806) 371-7528'                                                 // Fax
           );
           database.insert(cnt,false);
        }
        
        
       
    }

    @isTest 
    private static void callReportCompletedTest(){
        Account accRec = [select id, name from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Id RecordTypeIdCS = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
        User userRec = [Select Id, firstName, lastName from User where userName='jaso.liveson@example.com'];
        system.runAs(userRec){
            Call_Report__c cr = new Call_Report__c(
                Account__c = accRec.id,          // Account
                RecordTypeId = RecordTypeIdCS,                // Record Type
                Contact__c = contRec.id,            // Contact
                RFO_Status__c = 'Completed',               // Status
                RFO_Purpose__c = 'test',                   // Purpose
                Call_Date__c = system.today(),  // Call Date
                RFO_TotalFleetCount__c = 7,              // Total Fleet Count
                RFO_Hashtags__c = '#FaceToFace',       // Hashtags
                Result__c = 'test\n'                      // Result
            );
            database.insert(cr,false);
        }
            
        
    }

    @isTest 
    private static void callReportCompletedTestInsideMedium(){
        Account accRec = [select id, name from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Id RecordTypeIdCS = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
        List<RFO_CoveragePlan__c> newcpList = [SELECT id,RFO_AccountName__c, RFO_AccountOwner__c, RFO_AccountName__r.ownerId, RFO_CoveragePlan__c,RFO_Notes__c,RFO_CoverageRecommendation__c,RFO_NextScheduledContactDate__c,RFO_CoveragePlanApprovalStatus__c, RFO_ActualContactDate__c, RFO_ReasonForCoverageChange__c,RFO_CoverageChangeDetails__c,RFO_SalesLastPhoneCallDate__c,  RFO_SalesLastFacetoFaceDate__c,RecordTypeId,RFO_PriorValueOfCoveragePlan__c FROM RFO_CoveragePlan__c limit 1];
        User userRec = [Select Id, firstName, lastName from User where userName='jaso.liveson@example.com'];
        
        System.debug('newcpList.size() is '+newcpList.size());
        if(newcpList!=null && newcpList.size() >0){
            System.debug('newcp:'+newcpList[0]);
        }
        
        system.runAs(userRec){
            newcpList[0].RFO_CoveragePlan__c = 'Inside High';
            newcpList[0].RFO_CoveragePlanApprovalStatus__c = 'Approved';
            newcpList[0].RFO_PriorValueOfCoveragePlan__c = 'Not Managed';
            update newcpList[0];
            
            Call_Report__c cr = new Call_Report__c(
                Account__c = accRec.id,          // Account
                RecordTypeId = RecordTypeIdCS,                // Record Type
                Contact__c = contRec.id,            // Contact
                RFO_Status__c = 'Completed',               // Status
                RFO_Purpose__c = 'test',                   // Purpose
                Call_Date__c = system.today(),  // Call Date
                RFO_TotalFleetCount__c = 7,              // Total Fleet Count
                RFO_Hashtags__c = '#FaceToFace',       // Hashtags
                Result__c = 'test\n'                      // Result
            );
            database.insert(cr,false);
            
            
            /*newcpList[0].RFO_CoveragePlanApprovalStatus__c = 'Rejected';
            newcpList[0].RFO_PriorValueOfCoveragePlan__c = 'test';
            update newcpList[0];
            
            Call_Report__c cr1 = new Call_Report__c(
                Account__c = accRec.id,          // Account
                RecordTypeId = RecordTypeIdCS,                // Record Type
                Contact__c = contRec.id,            // Contact
                RFO_Status__c = 'Completed',               // Status
                RFO_Purpose__c = 'test',                   // Purpose
                Call_Date__c = system.today(),  // Call Date
                RFO_TotalFleetCount__c = 7,              // Total Fleet Count
                RFO_Hashtags__c = '#FaceToFace',       // Hashtags
                Result__c = 'test\n'                      // Result
            );
            database.insert(cr1,false);*/
            
        }

    }
    
    @isTest 
    private static void callReportCompletedTestInsideMedium1(){
        Account accRec = [select id, name from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Id RecordTypeIdCS = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
        List<RFO_CoveragePlan__c> newcpList = [SELECT id,RFO_AccountName__c, RFO_AccountOwner__c, RFO_AccountName__r.ownerId, RFO_CoveragePlan__c,RFO_Notes__c,RFO_CoverageRecommendation__c,RFO_NextScheduledContactDate__c,RFO_CoveragePlanApprovalStatus__c, RFO_ActualContactDate__c, RFO_ReasonForCoverageChange__c,RFO_CoverageChangeDetails__c,RFO_SalesLastPhoneCallDate__c,  RFO_SalesLastFacetoFaceDate__c,RecordTypeId,RFO_PriorValueOfCoveragePlan__c FROM RFO_CoveragePlan__c limit 1];
        User userRec = [Select Id, firstName, lastName from User where userName='jaso.liveson@example.com'];
        
        System.debug('newcpList.size() is '+newcpList.size());
        if(newcpList!=null && newcpList.size() >0){
            System.debug('newcp:'+newcpList[0]);
        }
        
        system.runAs(userRec){
            newcpList[0].RFO_CoveragePlan__c = 'Inside High';
            newcpList[0].RFO_CoveragePlanApprovalStatus__c = 'Rejected';
            newcpList[0].RFO_PriorValueOfCoveragePlan__c = 'Not Managed';
            update newcpList[0];
            DateTime yesterday =Datetime.now().addDays(-1);
            Test.setCreatedDate(newcpList[0].id,yesterday);
            Call_Report__c cr = new Call_Report__c(
                Account__c = accRec.id,          // Account
                RecordTypeId = RecordTypeIdCS,                // Record Type
                Contact__c = contRec.id,            // Contact
                RFO_Status__c = 'Completed',               // Status
                RFO_Purpose__c = 'test',                   // Purpose
                Call_Date__c = system.today(),  // Call Date
                RFO_TotalFleetCount__c = 7,              // Total Fleet Count
                RFO_Hashtags__c = '#FaceToFace',       // Hashtags
                Result__c = 'test\n'                      // Result
            );
            database.insert(cr,false);
        }

    }
    
    @isTest 
    private static void logACallCPTest(){
        Id activeRecordTypeId = Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get('RFO_Active').getRecordTypeId();
        List<Task> taskList = new List<Task>();
        Account accRec = [select id, name from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        RFO_CoveragePlan__c cvpl = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Minimal',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Low', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_Notes__c = 'CP Test'                
            );
           Database.insert(cvpl,false);
           
           RFO_CoveragePlan__c cvpl1 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Inside High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Inside High', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_Notes__c = 'CP Test'                
            );
           Database.insert(cvpl1,false);
           
           RFO_CoveragePlan__c cvpl2 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Inside Medium',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Inside Medium', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_Notes__c = 'CP Test'                
            );
           Database.insert(cvpl2,false);
        Task ts = new Task(
                Subject = 'Call',               
                Description = 'test', 
                Tasksubtype='Call',
                WhoId = contRec.id, 
                WhatId = cvpl.id
                
            );
           database.insert(ts,false);
           Task ts1 = new Task(
                Subject = 'Call',               
                Description = 'test', 
                Tasksubtype='Call',
                WhoId = contRec.id,               
                WhatId = cvpl1.id                
            );
           
           database.insert(ts1,false);
           
           Task ts2 = new Task(
                Subject = 'Call',               
                Description = 'test', 
                Tasksubtype='Call',
                WhoId = contRec.id,               
                WhatId = cvpl2.id                
            );
           
           database.insert(ts2,false);           
           taskList.add(ts);
           taskList.add(ts1);
           taskList.add(ts2);
        
        
    }
    
    @isTest 
    private static void approvalCPTest(){
        Account accRec = [select id, name from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Id activeRecordTypeId = Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get('RFO_Active').getRecordTypeId();
        Id RecordTypeIdCS = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
        List<RFO_CoveragePlan__c> cpList = new List<RFO_CoveragePlan__c>();
        List<RFO_CoveragePlan__c> cpNewList = new List<RFO_CoveragePlan__c>();
        RFO_CoveragePlan__c cp = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Minimal',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Low', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp);
            RFO_CoveragePlan__c cp1 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Low', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Sent For Approval',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'Not Managed',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp1);
            RFO_CoveragePlan__c cp2 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Not Managed', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Rejected',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'Not Managed',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp2);
           RFO_CoveragePlan__c cp3 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'LOW',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Minimal', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Pending Approval',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp3);
           RFO_CoveragePlan__c cp4 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Not Managed', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Rejected',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp4);
           RFO_CoveragePlan__c cp5 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Not Managed', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Sent For Approval',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp5);
           
           RFO_CoveragePlan__c cp6 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Inside High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Inside High', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp6);
           RFO_CoveragePlan__c cp7 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Inside Medium',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'Inside Medium', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp7);
           
           RFO_CoveragePlan__c cp8 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accRec.id,               
                RFO_CoveragePlan__c = 'High', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp8);
           
           
            database.insert(cpList,false);
           
           cp4.RFO_PriorValueOfCoveragePlan__c = 'Not Managed';
           cp4.RFO_CoveragePlan__c = 'Maximum';
           cpNewList.add(cp4);
           
           cp5.RFO_PriorValueOfCoveragePlan__c = 'Not Managed';
           cp5.RFO_CoveragePlan__c = 'Maximum';
           cpNewList.add(cp5);
           database.update(cpNewList, false);
           cpNewList.add(cp2);
    }
    @isTest static void editCompletedCallReport(){
        Account accRec = [select id, name from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Id activeRecordTypeId = Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get('RFO_Active').getRecordTypeId();
        Id RecordTypeIdCS = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
        List<RFO_CoveragePlan__c> newcpList = [SELECT id,RFO_AccountName__c, RFO_AccountOwner__c, RFO_AccountName__r.ownerId, RFO_CoveragePlan__c,RFO_Notes__c,RFO_CoverageRecommendation__c,RFO_NextScheduledContactDate__c,RFO_CoveragePlanApprovalStatus__c, RFO_ActualContactDate__c, RFO_ReasonForCoverageChange__c,RFO_CoverageChangeDetails__c,RFO_SalesLastPhoneCallDate__c,  RFO_SalesLastFacetoFaceDate__c,RecordTypeId,RFO_PriorValueOfCoveragePlan__c FROM RFO_CoveragePlan__c limit 1];
        User userRec = [Select Id, firstName, lastName from User where userName='jaso.liveson@example.com'];
        System.debug('newcpList.size() is '+newcpList.size());
        if(newcpList!=null && newcpList.size() >0){
            System.debug('newcp:'+newcpList[0]);
        }
        newcpList[0].RFO_CoveragePlan__c = 'Inside High';
        newcpList[0].RFO_CoveragePlanApprovalStatus__c = 'Approved';
        newcpList[0].RFO_PriorValueOfCoveragePlan__c = 'Not Managed';
        system.runAs(userRec){
        update newcpList[0];
        
        Call_Report__c cr = new Call_Report__c(
            Account__c = accRec.id,          // Account
            RecordTypeId = RecordTypeIdCS,                // Record Type
            Contact__c = contRec.id,            // Contact
            RFO_Status__c = 'Draft',               // Status
            RFO_Purpose__c = 'test',                   // Purpose
            Call_Date__c = system.today(),  // Call Date
            RFO_TotalFleetCount__c = 7,              // Total Fleet Count
            RFO_Hashtags__c = '#FaceToFace',       // Hashtags
            Result__c = 'test\n'                      // Result
        );
        Test.startTest();
        insert cr;
        cr.RFO_Status__c = 'Completed';
        update cr;

        cr.RFO_Status__c = 'Draft';
        cr.RFO_Purpose__c = 'test1';
        update cr;
        cr.RFO_Status__c = 'Completed';
        update cr;

        Test.stopTest();
        }
    }
        @isTest 
    private static void callReportCompletedTestInsideMedium2(){
        Account accRec = [select id, name ,RFO_TotalFleetCount__c  from Account Limit 1];
        accRec.RFO_TotalFleetCount__c = 8000;
        update accRec;
        Contact contRec = [select id, name from Contact Limit 1];
        Id RecordTypeIdCS = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
        List<RFO_CoveragePlan__c> newcpList = [SELECT id,RFO_AccountName__c, RFO_AccountOwner__c, RFO_AccountName__r.ownerId, RFO_CoveragePlan__c,RFO_Notes__c,RFO_CoverageRecommendation__c,RFO_NextScheduledContactDate__c,RFO_CoveragePlanApprovalStatus__c, RFO_ActualContactDate__c, RFO_ReasonForCoverageChange__c,RFO_CoverageChangeDetails__c,RFO_SalesLastPhoneCallDate__c,  RFO_SalesLastFacetoFaceDate__c,RecordTypeId,RFO_PriorValueOfCoveragePlan__c FROM RFO_CoveragePlan__c limit 1];
        User userRec = [Select Id, firstName, lastName from User where userName='jaso.liveson@example.com'];
        
        System.debug('newcpList.size() is '+newcpList.size());
        if(newcpList!=null && newcpList.size() >0){
            System.debug('newcp:'+newcpList[0]);
        }
        DateTime yesterday =Datetime.now().addDays(-1);
            Test.setCreatedDate(newcpList[0].id,yesterday);
        system.runAs(userRec){
            newcpList[0].RFO_CoveragePlan__c = 'Inside Medium';
            newcpList[0].RFO_CoveragePlanApprovalStatus__c = 'Approved';
            newcpList[0].RFO_PriorValueOfCoveragePlan__c = 'Not Managed';
            newcpList[0].RFO_RecordStatus__c = true;
            update newcpList[0];
            
            Call_Report__c cr = new Call_Report__c(
                Account__c = accRec.id,          // Account
                RecordTypeId = RecordTypeIdCS,                // Record Type
                Contact__c = contRec.id,            // Contact
                RFO_Status__c = 'Completed',               // Status
                RFO_Purpose__c = 'test',                   // Purpose
                Call_Date__c = system.today()+2,  // Call Date
                RFO_TotalFleetCount__c = 7,              // Total Fleet Count
                RFO_Hashtags__c = '#FaceToFace',       // Hashtags
                Result__c = 'test\n'                      // Result
            );
            
            Test.startTest();
            database.insert(cr,false);
            Test.stopTest();
            
            
            
        }

    }
	@isTest 
    private static void callReportCompletedTestMedium2(){
        Account accRec = [select id, name ,RFO_TotalFleetCount__c  from Account Limit 1];
        accRec.RFO_TotalFleetCount__c = 8000;
        update accRec;
        Contact contRec = [select id, name from Contact Limit 1];
        Id RecordTypeIdCS = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
        List<RFO_CoveragePlan__c> newcpList = [SELECT id,RFO_AccountName__c, RFO_AccountOwner__c, RFO_AccountName__r.ownerId, RFO_CoveragePlan__c,RFO_Notes__c,RFO_CoverageRecommendation__c,RFO_NextScheduledContactDate__c,RFO_CoveragePlanApprovalStatus__c, RFO_ActualContactDate__c, RFO_ReasonForCoverageChange__c,RFO_CoverageChangeDetails__c,RFO_SalesLastPhoneCallDate__c,  RFO_SalesLastFacetoFaceDate__c,RecordTypeId,RFO_PriorValueOfCoveragePlan__c FROM RFO_CoveragePlan__c limit 1];
        User userRec = [Select Id, firstName, lastName from User where userName='jaso.liveson@example.com'];
        
        System.debug('newcpList.size() is '+newcpList.size());
        if(newcpList!=null && newcpList.size() >0){
            System.debug('newcp:'+newcpList[0]);
        }
        DateTime yesterday =Datetime.now().addDays(-1);
            Test.setCreatedDate(newcpList[0].id,yesterday);
        system.runAs(userRec){
            newcpList[0].RFO_CoveragePlan__c = 'Medium';
            newcpList[0].RFO_CoveragePlanApprovalStatus__c = 'Approved';
            newcpList[0].RFO_PriorValueOfCoveragePlan__c = 'Not Managed';
            newcpList[0].RFO_RecordStatus__c = true;
            update newcpList[0];
            
            Call_Report__c cr = new Call_Report__c(
                Account__c = accRec.id,          // Account
                RecordTypeId = RecordTypeIdCS,                // Record Type
                Contact__c = contRec.id,            // Contact
                RFO_Status__c = 'Completed',               // Status
                RFO_Purpose__c = 'test',                   // Purpose
                Call_Date__c = system.today()+2,  // Call Date
                RFO_TotalFleetCount__c = 7,              // Total Fleet Count
                RFO_Hashtags__c = '#FaceToFace',       // Hashtags
                Result__c = 'test\n'                      // Result
            );
            
            Test.startTest();
            database.insert(cr,false);
            Test.stopTest();
            
            
            
        }

    }
	 @isTest 
    
    private static User createUser() {
        Profile profileId = [Select Id, Name from Profile where Name = 'System Administrator' limit 1];
        //Profile profileId1 = [Select Id, Name from Profile where Name =: 'RFO - Sales' limit 1];
        UserRole roleId;
        try {
            roleId =[Select Id,Name from UserRole where Name = 'Commercial-30' limit 1];
        }
        catch(QueryException e) {
            roleId =[Select Id,Name from UserRole limit 1];
        }
        User usr = new User();
       usr.LastName = 'LIVESON';
       usr.FirstName='JASO';
       usr.Alias = 'jsiv';
       usr.Email = 'jaso.liveson@example.com';
       usr.Username = 'jaso.liveson@example.com';
       usr.ProfileId = profileId.id;
       usr.TimeZoneSidKey = 'GMT';
       usr.LanguageLocaleKey = 'en_US';
       usr.EmailEncodingKey = 'UTF-8';
       usr.LocaleSidKey = 'en_US';
       usr.UserRoleId = roleId.id;
       database.insert(usr,false);
       return usr;
    }    
        
    private static User createUser1() {
        Profile profileId = [Select Id, Name from Profile where Name = 'System Administrator' limit 1];
        //Profile profileId1 = [Select Id, Name from Profile where Name =: 'RFO - Sales' limit 1];
        UserRole salesReproleId;
        try {
            salesReproleId =[Select Id,Name from UserRole where Name = 'Commercial-30' limit 1];
        }
        catch(QueryException e) {
            salesReproleId =[Select Id,Name from UserRole limit 1];
        }
       User usr1 = new User();
       usr1.LastName = 'Daniel';
       usr1.FirstName='Russ';
       usr1.Alias = 'Daru';
       usr1.Email = 'Daniel.Russ@example.com';
       usr1.Username = 'Daniel.Russ@example.com';
       usr1.ProfileId = profileId.id;
       usr1.TimeZoneSidKey = 'GMT';
       usr1.LanguageLocaleKey = 'en_US';
       usr1.EmailEncodingKey = 'UTF-8';
       usr1.LocaleSidKey = 'en_US';
       usr1.UserRoleId = salesReproleId.id;
       //usr1.managerId = usr.id;
       database.insert(usr1,false);
       return usr1;
    }    
            
     /*
    @isTest 
    private static void actualContactDateOnCP(){
        Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        Id RecordTypeIdCS = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
        Id activeRecordTypeId = Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get('RFO_Active').getRecordTypeId();
        List<Account> accList = new List<Account>();
         List<Contact> cntList = new List<Contact>();
        List<Call_Report__c> crList = new List<Call_Report__c>();
        List<RFO_CoveragePlan__c> cpList = new List<RFO_CoveragePlan__c>();
        List<RFO_CoveragePlan__c> cpNewList = new List<RFO_CoveragePlan__c>();
        List<Task> taskList = new List<Task>();
       Test.startTest();
       
        ===========================
       system.runAs(createUser()){
           account ac =new account();
           ac.Name = 'BNSF';  // Account Name
           ac.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
           ac.Phone = '800-832-5452';          // Phone
           ac.RFO_Region__c = 'Class 1 Railroads';   // Region
           ac.RFO_AccountStatus__c = 'Active';
           ac.OwnerId = createUser1().id;
           database.insert(ac,false);
           accList.add(ac);
           
           Contact cnt = new Contact(
               FirstName = 'Tony',         // FirstName
               LastName = 'Alen',            // LastName
               RFO_Status__c = 'Active',                                               // Status
               Email = 'Tony.Alen@trinity.net',                                  // Email
               AccountId = accList[0].id,                                          // Account Name
               Phone = '(806) 381-0261',                                               // Phone
               RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
               Fax = '(806) 371-7528'                                                 // Fax
           );
           database.insert(cnt,false);
           cntList.add(cnt);
           
           Call_Report__c cr = new Call_Report__c(
                Account__c = accList[0].id,          // Account
                RecordTypeId = RecordTypeIdCS,                // Record Type
                Contact__c = cntList[0].id,            // Contact
                RFO_Status__c = 'Completed',               // Status
                RFO_Purpose__c = 'test',                   // Purpose
                Call_Date__c = system.today(),  // Call Date
                RFO_TotalFleetCount__c = 7,              // Total Fleet Count
                RFO_Hashtags__c = '#FaceToFace',       // Hashtags
                Result__c = 'test\n'                      // Result
            );
            database.insert(cr,false);
            //crList.add(cr);
            
           Id testAccId = accList[0].id;
            
            RFO_CoveragePlan__c newcp = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Inside Medium',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accList[0].id,               
                RFO_CoveragePlan__c = 'Inside Medium', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_Notes__c = 'CP Test'                
            );
           insert newcp;
           database.insert(newcp,false);
           
           Call_Report__c cr1 = new Call_Report__c(
                Account__c = accList[0].id,          // Account
                RecordTypeId = RecordTypeIdCS,                // Record Type
                Contact__c = cntList[0].id,            // Contact
                RFO_Status__c = 'Completed',               // Status
                RFO_Purpose__c = 'test',                   // Purpose
                Call_Date__c = system.today(),  // Call Date
                RFO_TotalFleetCount__c = 7,              // Total Fleet Count
                RFO_Hashtags__c = '#MaintenanceService',       // Hashtags
                Result__c = 'test\n'                      // Result
            );
            database.insert(cr1,false);
           
           /*
            
            RFO_Level20Roles__c cs20Roles =new RFO_Level20Roles__c();
            cs20Roles.name = 'Commercial-30';
            insert cs20Roles;
           
            RFO_CoveragePlan__c cp = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Minimal',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accList[0].id,               
                RFO_CoveragePlan__c = 'Low', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp);
            RFO_CoveragePlan__c cp1 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accList[0].id,               
                RFO_CoveragePlan__c = 'Low', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Sent For Approval',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'Not Managed',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp1);
            RFO_CoveragePlan__c cp2 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accList[0].id,               
                RFO_CoveragePlan__c = 'Not Managed', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Rejected',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'Not Managed',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp2);
           RFO_CoveragePlan__c cp3 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'LOW',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accList[0].id,               
                RFO_CoveragePlan__c = 'Minimal', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Pending Approval',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp3);
           RFO_CoveragePlan__c cp4 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accList[0].id,               
                RFO_CoveragePlan__c = 'Not Managed', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Rejected',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp4);
           RFO_CoveragePlan__c cp5 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accList[0].id,               
                RFO_CoveragePlan__c = 'Not Managed', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Sent For Approval',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp5);
           
           RFO_CoveragePlan__c cp6 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Inside High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accList[0].id,               
                RFO_CoveragePlan__c = 'Inside High', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp6);
           RFO_CoveragePlan__c cp7 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Inside Medium',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accList[0].id,               
                RFO_CoveragePlan__c = 'Inside Medium', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp7);
           
           RFO_CoveragePlan__c cp8 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = accList[0].id,               
                RFO_CoveragePlan__c = 'High', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_PlanningStatus__c = 'Need to Schedule',  
                RFO_SalesLastFacetoFaceDate__c = system.today(),
                RFO_SalesLastContactDate__c = system.today(),
                RFO_PriorValueOfCoveragePlan__c = 'High',
                RFO_Notes__c = 'CP Test'                
            );
            cpList.add(cp8);
           
           
            database.insert(cpList,false);
           
           cp4.RFO_PriorValueOfCoveragePlan__c = 'Not Managed';
           cp4.RFO_CoveragePlan__c = 'Maximum';
           cpNewList.add(cp4);
           
           cp5.RFO_PriorValueOfCoveragePlan__c = 'Not Managed';
           cp5.RFO_CoveragePlan__c = 'Maximum';
           cpNewList.add(cp5);
           database.update(cpNewList, false);
           cpNewList.add(cp2);              
        
           RFO_CoveragePlan__c cvpl = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Minimal',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = ac.id,               
                RFO_CoveragePlan__c = 'Low', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_Notes__c = 'CP Test'                
            );
           Database.insert(cvpl,false);
           
           RFO_CoveragePlan__c cvpl1 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Inside High',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = ac.id,               
                RFO_CoveragePlan__c = 'Inside High', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_Notes__c = 'CP Test'                
            );
           Database.insert(cvpl1,false);
           
           RFO_CoveragePlan__c cvpl2 = new RFO_CoveragePlan__c(
                RFO_CoverageRecommendation__c = 'Inside Medium',               
                RFO_ReasonForCoverageChange__c = 'Other', 
                RFO_AccountName__c = ac.id,               
                RFO_CoveragePlan__c = 'Inside Medium', 
                RFO_RecordStatus__c=true,
                RecordTypeId = activeRecordTypeId,
                RFO_ActualContactDate__c = system.today(),
                RFO_CoveragePlanApprovalStatus__c = 'Approved',
                RFO_Notes__c = 'CP Test'                
            );
           Database.insert(cvpl2,false);
           
          String idPrefix = String.valueOf(cvpl.id).substring(0,3);
                   
            Task ts = new Task(
                Subject = 'Call',               
                Description = 'test', 
                Tasksubtype='Call',
                WhoId = cntList[0].id, 
                WhatId = cpList[0].id
                
            );
           database.insert(ts,false);
           Task ts1 = new Task(
                Subject = 'Call',               
                Description = 'test', 
                Tasksubtype='Call',
                WhoId = cntList[0].id,               
                WhatId = cvpl1.id                
            );
           
           database.insert(ts1,false);
           
           Task ts2 = new Task(
                Subject = 'Call',               
                Description = 'test', 
                Tasksubtype='Call',
                WhoId = cntList[0].id,               
                WhatId = cvpl2.id                
            );
           
           database.insert(ts2,false);           
           taskList.add(ts);
           taskList.add(ts1);
           taskList.add(ts2);
           
       }
        Test.stopTest();
   }  */    
    
    
}