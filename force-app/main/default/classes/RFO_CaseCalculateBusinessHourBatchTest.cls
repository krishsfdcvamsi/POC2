@isTest
private class RFO_CaseCalculateBusinessHourBatchTest {
	@testSetup 
    static void setup() {
    	Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
     	Id RecordTypeIdProspect = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Prospect').getRecordTypeId();
     	//Profile profileId = [SELECT Id FROM Profile WHERE Name = 'RFO - Sales' LIMIT 1]; Changed by Ramesh
     	Group queueInfo = [select Id from Group where  Type = 'Queue' AND DeveloperName = 'Customer_Delivery'];
       	system.debug('%%%%'+queueInfo);
     	List<Account> accList = new List<Account>();
     	List<User> usrList = new List<User>();
     	List<AccountTeamMember> accTMList = new List<AccountTeamMember>();
     	List<Contact> cntList = new List<Contact>();
     	List<Case> caseList = new List<Case>();
        Id currentUserId = Userinfo.getUserId();
        Account accnt = new Account(
            Name = 'BNSF',  // Account Name
            RecordTypeId = RecordTypeIdCustomer,           // Account Record Type
            Phone = '800-832-5452',          // Phone
            RFO_Region__c = 'Class 1 Railroads',   // Region
            RFO_AccountStatus__c = 'Active'         // Account Status
           
       );
        accList.add(accnt);
        Account accntNew = new Account(
            Name = 'BNSFT',  // Account Name
            RecordTypeId = RecordTypeIdProspect,           // Account Record Type
            Phone = '800-832-5252',          // Phone
            RFO_Region__c = 'Class 1 Railroads',   // Region
            RFO_AccountStatus__c = 'Active'         // Account Status
           
        );
        accList.add(accntNew);
        Account accntNewRec = new Account(
            Name = 'BNT Co',  // Account Name
            RecordTypeId = RecordTypeIdProspect,           // Account Record Type
            Phone = '800-832-5252',          // Phone
            RFO_Region__c = 'Class 1 Railroads',   // Region
            RFO_AccountStatus__c = 'Active'       // Account Status
           
         );
        accList.add(accntNewRec);
        
        Database.insert(accList);
        
        Contact contactRec = new Contact(
           FirstName = 'Faluni',         // FirstName
           LastName = 'Blazen',            // LastName
           RFO_Status__c = 'Active',                                               // Status
           Email = 'Faluni.Blazen@trin.net',                                  // Email
           AccountId = accList[0].id,                                          // Account Name
           Phone = '(806) 301-0261',                                               // Phone
           RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
           Fax = '(806) 391-7528'                                                 // Fax
       );
       cntList.add(contactRec);
       Contact contactRec1 = new Contact(
           FirstName = 'Kelly',     // FirstName
           LastName = 'Trozen',                      // LastName
           RFO_Status__c = 'Active',                                               // Status
           Email = 'Kelly.Trozen@trinity.net',                                  // Email
           AccountId = accList[1].id,                                          // Account Name
           Phone = '(806) 381-0261',                                               // Phone
           RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
           Fax = '(806) 371-7528'                                                 // Fax
       );
       cntList.add(contactRec1);
       Contact contactRec2 = new Contact(
           FirstName = 'Tony',         // FirstName
           LastName = 'Alen',            // LastName
           RFO_Status__c = 'Active',                                               // Status
           Email = 'Tony.Alen@trinity.net',                                  // Email
           AccountId = accList[2].id,                                          // Account Name
           Phone = '(806) 381-0261',                                               // Phone
           RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
           Fax = '(806) 371-7528'                                                 // Fax
       );
       cntList.add(contactRec2);
       Database.insert(cntList);
        
        
        
        Case caseRec = new Case(
           RFO_CaseNature__c = 'Request',           // Case Nature
           ContactId = null,             // Contact Name
           Type = 'Estimating',                       // Type
           Priority = 'Medium',                       // Priority
           RFO_SubType__c = 'Information Request',    // Sub-Type
           Status = 'In Progress',                    // Status
           Origin = 'Phone'                         // Case Origin
       );
       caseList.add(caseRec);
       Case caseRec1 = new Case(
           RFO_CaseNature__c = 'Request',           // Case Nature
           //ContactId = cntList[0].id,             // Contact Name Changed by Ramesh
           Type = 'Estimating',                       // Type
           Priority = 'Medium',                       // Priority
           RFO_SubType__c = 'Information Request',    // Sub-Type
           Status = 'In Progress',                    // Status
           Origin = 'Phone'                          // Case Origin
       );
       caseList.add(caseRec1);
       Case caseRec2 = new Case(
           RFO_CaseNature__c = 'Request',           // Case Nature
           //ContactId = cntList[0].id,             // Contact Name Changed by Ramesh
           Type = 'Estimating',                       // Type
           Priority = 'Medium',                       // Priority
           RFO_SubType__c = 'Information Request',    // Sub-Type
           Status = 'In Progress',                    // Status
           Origin = 'Phone'                          // Case Origin
       );
       caseList.add(caseRec2);
       Database.insert(caseList);
        
       Task tsk = new Task();
        tsk.WhatId = caseRec.id;
        insert tsk;
       
       caseRec.status='Closed';
       caseRec.RFO_CaseClosedDescription__c='testing'; 
       caseRec1.status='Closed';
       caseRec1.RFO_CaseClosedDescription__c='testing';
       caseRec2.status='Closed';
       caseRec2.RFO_CaseClosedDescription__c='testing'; 
       List<Case> updateCaseList = new List<Case>();
       updateCaseList.add(caseRec);
       updateCaseList.add(caseRec1);
       updateCaseList.add(caseRec2);
       update updateCaseList;
        
    }
    
    static testmethod void testBJ(){
        Test.startTest();
        // Changed bby Ramesh start
        List<case> caseList = new List<case>();
        caseList = [select id, status, ClosedDate, Task_Associated__c, 
                    Case_Age_Business_Hour__c , CreatedDate, FCR_Case__c 
                    from case where status='Closed' and ClosedDate != null];
        RFO_CaseCalculateBusinessHourBatch cbh = new RFO_CaseCalculateBusinessHourBatch();
        Id batchId = Database.executeBatch(cbh);
        cbh.execute(null,caseList);
        // Changed bby Ramesh End
        RFO_CaseCalculateBusinessHourSchedule sh1 = new RFO_CaseCalculateBusinessHourSchedule();
		String sch = '0 0 2 * * ?'; 
		system.schedule('Closed case business hour calculation', sch, sh1); 
		
        /* Changed bby Ramesh Start
        List<case> caseList = new List<case>();
        caseList = [select id from case];

        AdminJob_UpdateCaseExtId batch = new AdminJob_UpdateCaseExtId();
        DataBase.executeBatch(batch); 
        Database.QueryLocator ql = batch.start(null);
        batch.execute(null,caseList);
        // Changed bby Ramesh End */
        
        Test.stopTest();
    }
    
}