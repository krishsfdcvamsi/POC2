@isTest(SeeAllData = false)
private class RFO_CustomerDisputeEscalationSchTest {
	private static testMethod void customerDisputeScheduler7daysTest(){
    	Id recordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        Id existingCar = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_ExistingCarChangeRequest).getRecordTypeId();
        Id caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_Case').getRecordTypeId();
        Id customerDisputeRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_Customer_Disputes').getRecordTypeId();
        
        Id recordTypeIdProspect = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Prospect').getRecordTypeId();
        String accountProfile = label.Profile_Accounting;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = : accountProfile LIMIT 1];
        
        Id stdCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CASE) != null ? Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CASE).getRecordTypeId() : null;  //manikantesh
        
        List<Account> accList = new List<Account>();
        List<User> usrList = new List<User>();
        List<AccountTeamMember> accTMList = new List<AccountTeamMember>();
        List<Contact> cntList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        
        //Id currentUserId = Userinfo.getUserId();
        Account accnt = new Account(
            Name = 'BNSF',  // Account Name
            RecordTypeId = recordTypeIdCustomer,           // Account Record Type
            Phone = '800-832-5452',          // Phone
            RFO_Region__c = 'Class 1 Railroads',   // Region
            RFO_AccountStatus__c = 'Active'         // Account Status
            
        );
        accList.add(accnt);
        Database.insert(accList);
        
        User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason.liveston@example.com',
                            Username = 'jason.liveston@example.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        usrList.add(usr);
        User usr2 = new User(LastName = 'LIVESON',
                             FirstName='JASO',
                             Alias = 'jsiv',
                             Email = 'jaso.liveson@example.com',
                             Username = 'jaso.liveson@example.com',
                             ProfileId = profileId.id,
                             TimeZoneSidKey = 'GMT',
                             LanguageLocaleKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             LocaleSidKey = 'en_US'
                            );
        usrList.add(usr2);
        Database.insert(usrList);
        
        AccountTeamMember accTM1 = new AccountTeamMember(AccountId = accList[0].id,
                                                         UserId = usrList[0].id,
                                                         TeamMemberRole = 'Customer Delivery Manager',
                                                         AccountAccessLevel = 'Read',
                                                         OpportunityAccessLevel = 'Read',
                                                         CaseAccessLevel = 'Read',
                                                         ContactAccessLevel = 'Read'
                                                        );
        accTMList.add(accTM1);
        Database.insert(accTMList);
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
            AccountId = accList[0].id,                                          // Account Name
            Phone = '(806) 381-0261',                                               // Phone
            RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
            Fax = '(806) 371-7528'                                                 // Fax
        );
        cntList.add(contactRec1);
        
        Database.insert(cntList);
        Case caseRec = new Case(
            subject = 'Test 1',
            RFO_CaseNature__c = 'Request',           // Case Nature
            ContactId = cntList[0].id,             // Contact Name
            AccountId = accList[0].id,
            Type = 'Invoicing',                       // Type
            Priority = 'Medium',                       // Priority
            RFO_SubType__c = 'Tax',    				// Sub-Type
            Status = label.Case_Resolving_Dispute,                    // Status
            RecordtypeId = customerDisputeRecType,
            Origin = 'Phone',                         // Case Origin
            RFO_Resolving_Dispute_Start_Time__c = DateTime.Now().addDays(-12)
        );
        caseList.add(caseRec);
        		Case caseRec1 = new Case(
            subject = 'Test 2',
            RFO_CaseNature__c = 'Request',           // Case Nature
            ContactId = cntList[0].id,             // Contact Name
            AccountId = accList[0].id,
            Type = 'Invoicing',                       // Type
            Priority = 'Medium',                       // Priority
            RFO_SubType__c = 'Tax',    // Sub-Type
            Status = label.Case_Resolving_Dispute,                    // Status
            RecordtypeId = customerDisputeRecType,                  //Recordtype id
            Origin = 'Phone',                          // Case Origin
            RFO_Resolving_Dispute_Start_Time__c = DateTime.Now().addDays(-22)
        );
        caseList.add(caseRec1);
        Case caseRec2 = new Case(
            subject = 'Test 3',
            RFO_CaseNature__c = 'Request',           // Case Nature
            ContactId = cntList[0].id,             // Contact Name
            AccountId = accList[0].id,
            Type = 'Invoicing',                      // Type
            Priority = 'Medium',                       // Priority
            RFO_SubType__c = 'Tax',    // Sub-Type
            Status = label.Case_Resolving_Dispute,                   // Status
            RecordtypeId = customerDisputeRecType,                  //Recordtype Id
            Origin = 'Phone',                          // Case Origin
            RFO_Resolving_Dispute_Start_Time__c = DateTime.Now().addDays(-8)
        );
        caseList.add(caseRec2);
        
        Case caseRec3 = new Case(
            subject = 'Test 4',
            RFO_CaseNature__c = 'Request',           // Case Nature
            ContactId = cntList[0].id,             // Contact Name
            AccountId = accList[0].id,
            Type = 'Invoicing',                      // Type
            Priority = 'Medium',                       // Priority
            RFO_SubType__c = 'Tax',    // Sub-Type
            Status = label.Case_Resolving_Dispute,                    // Status
            RecordtypeId = customerDisputeRecType,                  //Recordtype Id // manikantesh
            Origin = 'Phone',                          // Case Origin
            RFO_Resolving_Dispute_Start_Time__c = DateTime.Now().addDays(-37)
        );
        caseList.add(caseRec3);

        Database.insert(caseList);
        
        Test.startTest();
        RFO_CustomerDisputeEscalationSchedule sh1 = new RFO_CustomerDisputeEscalationSchedule();
        String sch = '0 0 2 * * ?'; 
        system.schedule('customer dispute', sch, sh1); 
        Test.stopTest();
    }
    
    
    
}