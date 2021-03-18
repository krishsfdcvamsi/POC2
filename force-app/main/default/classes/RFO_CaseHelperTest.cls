/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 9th Sep 2018
* @Description :This is test class for RFO_CaseHelper.
**/

@isTest(SeeAllData = false)

private class RFO_CaseHelperTest {
    
    @testSetup 
    static void setup() {
    	Id recordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        Id existingCar = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_ExistingCarChangeRequest).getRecordTypeId();
        /*Added By Vihari ALPHA -677 */ 
        Id newCar = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CASE_NewCar).getRecordTypeId();
        /*End ALPHA-677 */
        Id caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_Case').getRecordTypeId();
        //Id customerDisputeRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Case_Resolving_Dispute).getRecordTypeId();
        
        Id customerDisputeRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_Case').getRecordTypeId();
        Id newCarRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_NewCarChangeRequest').getRecordTypeId();
        
        Id recordTypeIdProspect = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Prospect').getRecordTypeId();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = : RFO_Constant.SALES_PROFILE LIMIT 1];
        
        Id stdCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CASE) != null ? Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CASE).getRecordTypeId() : null;  //manikantesh
        
        List<Account> accList = new List<Account>();
        List<User> usrList = new List<User>();
        List<AccountTeamMember> accTMList = new List<AccountTeamMember>();
        List<Contact> cntList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        /*Added By Vihari ALPHA -677 */ 
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c();
        List<Order> orderList = new List<Order>();
        SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
        Product2 productRec = new Product2();
        List<RFO_Asset_File__c> assetFileList = new List<RFO_Asset_File__c>();
        /*End By Vihari ALPHA -677 */ 
        
        //Id currentUserId = Userinfo.getUserId();
        Account accnt = new Account(
            Name = 'BNSF',  // Account Name
            RecordTypeId = recordTypeIdCustomer,           // Account Record Type
            Phone = '800-832-5452',          // Phone
            RFO_Region__c = 'Class 1 Railroads',   // Region
            RFO_AccountStatus__c = 'Active'         // Account Status
            
        );
        accList.add(accnt);
        Account accntNew = new Account(
            Name = 'BNSFT',  // Account Name
            RecordTypeId = recordTypeIdProspect,           // Account Record Type
            Phone = '800-832-5252',          // Phone
            RFO_Region__c = 'Class 1 Railroads',   // Region
            RFO_AccountStatus__c = 'Active'         // Account Status
            
        );
        accList.add(accntNew);
        Account accntNewRec = new Account(
            Name = 'BNT Co',  // Account Name
            RecordTypeId = recordTypeIdProspect,           // Account Record Type
            Phone = '800-832-5252',          // Phone
            RFO_Region__c = 'Class 1 Railroads',   // Region
            RFO_AccountStatus__c = 'Active'       // Account Status
            
        );
        accList.add(accntNewRec);
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
                             LocaleSidKey = 'en_US',
                             isActive = true,
                             RFO_Engineering__c = true
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
        AccountTeamMember accTM2 = new AccountTeamMember(AccountId = accList[1].id,
                                                         UserId = usrList[1].id,
                                                         TeamMemberRole = 'Customer Delivery Director',
                                                         AccountAccessLevel = 'Read',
                                                         OpportunityAccessLevel = 'Read',
                                                         CaseAccessLevel = 'Read',
                                                         ContactAccessLevel = 'Read'
                                                        );
        accTMList.add(accTM2);
        AccountTeamMember accTM3 = new AccountTeamMember(AccountId = accList[1].id,
                                                         UserId = usrList[1].id,
                                                         TeamMemberRole = 'Sales Rep',
                                                         AccountAccessLevel = 'Read',
                                                         OpportunityAccessLevel = 'Read',
                                                         CaseAccessLevel = 'Read',
                                                         ContactAccessLevel = 'Read'
                                                        );
        accTMList.add(accTM3);
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
        
        /*Added By Vihari ALPHA -677 */ 
         //Creating a Commodity
        commodityList = RFO_Utility_Test.createCommodity1();
        Database.insert(commodityList);
        //Creating an Opportunity
        opportunityList=RFO_Utility_Test.createTankOpportunities(accList[0]);
        for(Opportunity o: opportunityList){
            o.RFO_ProductType__c = null;
            o.StageName = 'Initiated';
        }
        Database.insert(opportunityList);
        //Creating a QuoteTeam
        quoteTeamRecord = RFO_Utility_Test.createQuoteTeam();
        Database.insert(quoteTeamRecord);
        
        //Creating a CPQ Quote
        cpqQuoteList = RFO_Utility_Test.createCPQPrimaryQuote(opportunityList[0], quoteTeamRecord);
        cpqQuoteList.RFO_ProposalRefreshStatus__c = 'Resubmit for Pricing';   // Proposal Refresh Status
        cpqQuoteList.RFO_ProposalRefreshRequired__c = 'Yes';                  // Proposal Refresh Required
        cpqQuoteList.RFO_DaysUntilProposalExpires__c = '30'; 
        cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;
        Database.insert(cpqQuoteList);
        //Creating a Product
        productRec = RFO_Utility_Test.createProduct();
        productRec.IsActive = true;// Updated by Vihari
        Database.insert(productRec,false);
        //Creating an Order
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList[0], commodityList[0], productRec);
        orderList[0].RFO_File__c = '1234';
        Database.insert(orderList);
        //Creating an Asset File
        assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        assetFileList[0].RFO_FileNumber__c = '123';
        Database.insert(assetFileList);
        
        List<Project_Engineer__c> peList = new List<Project_Engineer__c>();
        peList.add(new Project_Engineer__c(Order__c = orderList[0].id, Engineer__c=usrList[1].id));
        Database.insert(peList);        
        /*End By Vihari ALPHA -677 */ 
        
        Case caseRec = new Case(
            RFO_CaseNature__c = 'Request',           // Case Nature
            ContactId = cntList[0].id,             // Contact Name
            AccountId = accList[0].id,
            Type = 'Estimating',                       // Type
            Priority = 'Medium',                       // Priority
            RFO_SubType__c = 'Information Request',    // Sub-Type
            Status = 'In Progress',                    // Status
            Origin = 'Phone'                         // Case Origin
        );
        caseList.add(caseRec);
        Case caseRec1 = new Case(
            RFO_CaseNature__c = 'Request',           // Case Nature
            ContactId = cntList[0].id,             // Contact Name
            AccountId = accList[0].id,
            Type = 'Estimating',                       // Type
            Priority = 'Medium',                       // Priority
            RFO_SubType__c = 'Information Request',    // Sub-Type
            Status = 'In Progress',                    // Status
            RecordtypeId = existingCar,                  //Recordtype id
            Origin = 'Phone'                          // Case Origin
        );
        caseList.add(caseRec1);
        Case caseRec2 = new Case(
            RFO_CaseNature__c = 'Request',           // Case Nature
            ContactId = cntList[1].id,             // Contact Name
            AccountId = accList[1].id,
            Type = 'Estimating',                       // Type
            Priority = 'Medium',                       // Priority
            RFO_SubType__c = 'Information Request',    // Sub-Type
            Status = 'In Progress',                    // Status
            RecordtypeId = caseRecType,                  //Recordtype Id
            Origin = 'Phone'                          // Case Origin
        );
        caseList.add(caseRec2);
        
        Case caseRec3 = new Case(
            RFO_CaseNature__c = 'Request',           // Case Nature
            ContactId = cntList[2].id,             // Contact Name
            AccountId = accList[2].id,
            Type = 'Estimating',                       // Type
            Priority = 'Medium',                       // Priority
            RFO_SubType__c = 'Information Request',    // Sub-Type
            Status = 'In Progress',                    // Status
            RecordtypeId = stdCaseRT,                  //Recordtype Id // manikantesh
            Origin = 'Phone'                          // Case Origin
        );
        caseList.add(caseRec3);
        
        Case caseRec4 = new Case(
            RFO_CaseNature__c = 'Request',         		// Case Nature
            ContactId = cntList[1].id,             		// Contact Name
            AccountId = accList[1].id,
            Type = 'Invoicing',                       	// Type
            Priority = 'Medium',                       	// Priority
            RFO_SubType__c = 'Tax',    					// Sub-Type
            Status = label.Case_Resolving_Dispute,      // Status
            RecordtypeId = customerDisputeRecType,      //Recordtype Id
            Origin = 'Phone'                            // Case Origin
        );
        caseList.add(caseRec4);
        
         Case newCarcaseRec5 = new Case(
            RFO_CaseNature__c = 'Request',             // Case Nature
            ContactId = cntList[1].id,                 // Contact Name
            AccountId = accList[1].id,
            Priority = 'Medium',                         // Priority
            RFO_SubType__c = 'Tax',              // Sub-Type
            Status = 'Material Cost Review',      // Status
            RecordtypeId = newCarRecType,      //Recordtype Id
            Origin = 'Phone',                            // Case Origin
            RFO_OrderID__c = orderList[0].id,			// Order Id 
            RFO_FileNumber__c = assetFileList[0].id    // asset File Id
        );
        caseList.add(newCarcaseRec5);
        
 
        /*Added By Vihari ALPHA -677 */ 
        Case caseRec6 = new Case(
            RFO_CaseNature__c = 'Request',         		// Case Nature
            ContactId = cntList[1].id,             		// Contact Name
            AccountId = accList[1].id,
            Type = 'Invoicing',                       	// Type
            Priority = 'Medium',                       	// Priority
            RFO_SubType__c = 'Tax',    					// Sub-Type
            Status = 'In Progress' ,                     // Status
            RecordtypeId = newCar,                      //Recordtype Id
            Origin = 'Phone',                            // Case Origin
            RFO_OrderID__c = orderList[0].id,			// Order Id 
            RFO_FileNumber__c = assetFileList[0].id		// Asset File
        );
        caseList.add(caseRec6);
        
         Case caseRec7 = new Case(
            RFO_CaseNature__c = 'Request',         		// Case Nature
            ContactId = cntList[1].id,             		// Contact Name
            AccountId = accList[1].id,
            Type = 'Invoicing',                       	// Type
            Priority = 'Medium',                       	// Priority
            RFO_SubType__c = 'Tax',    					// Sub-Type
            Status = 'In Progress' ,                     // Status
            RecordtypeId = newCar,                      //Recordtype Id
            Origin = 'Phone',                            // Case Origin
            RFO_OrderID__c = orderList[0].id,			// Order Id 
            RFO_FileNumber__c = assetFileList[0].id		// Asset File
        );
        caseList.add(caseRec7);
        /*End By Vihari ALPHA -677 */ 
        
        
        Case caseRec5 = new Case(
            RFO_CaseNature__c = 'Request',         		// Case Nature
            ContactId = cntList[1].id,             		// Contact Name
            AccountId = accList[1].id,
            Priority = 'Medium',                       	// Priority
            RFO_SubType__c = 'Tax',    					// Sub-Type
            Status = 'Material Cost Review',      // Status
            RecordtypeId = newCarRecType,      //Recordtype Id
            Origin = 'Phone',                            // Case Origin
            /* Added By Vihari */
            RFO_OrderID__c = orderList[0].id,			// Order Id 
            RFO_FileNumber__c = assetFileList[0].id		// Asset File
        );
        caseList.add(caseRec5);
        
        
        
        Database.insert(caseList);
        
    }
    
    private static testMethod void accntTMRoleCaseOwner(){
        List<Case> caseList = [select Id, subject from case limit 100];
        System.assert(!caseList.isEmpty());
        List<Case> caselistToUpdate = new List<Case>();
        caselistToUpdate = [select id,Ownerid from Case where id IN: caseList Limit 49999];
        RFO_CaseHelper.caseAssignment(caselistToUpdate);
    }
    
    private static testMethod void customerDisputeTest(){
        Test.startTest();
        Case c = [select Id, subject, status from case where Type='Invoicing' limit 1];
        c.status = label.Case_Awaiting_On_Customer;
        update c;
        
        c.status = label.Case_Awaiting_On_Payment;
        update c;
        
        c.status = label.Case_Closed;
        c.RFO_CaseClosedDescription__c = 'RFO_CaseClosedDescription';
        
        update c;

        Test.stopTest();

    }
    
    private static testMethod void newCarAlertEstimatingStartTest(){
        Test.startTest();
        Case c = [select Id, subject, status from case where RecordType.DeveloperName = 'RFO_NewCarChangeRequest' Limit 1];
        c.New_Car_Alert_Estimating_Start__c = false;
        
        update c;
        
        c.New_Car_Alert_Estimating_Start__c = true;
        
        update c;
        
        Test.stopTest();
        
        
            
    }
    
    /*Added By Vihari ALPHA -677 */ 
    // test method to test CreateAlert method
    private static testMethod void createAlertTest(){

        Id newCar = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CASE_NewCar).getRecordTypeId();
        AlertService aService = new AlertService();
        Map<String,Alert_Setting__mdt> alertSettingsMap = aService.mapAlertSetting;
        String engReviewAlert = Label.Case_Engineering_Review_AlertSetting_Name;
        
        Test.startTest();
        Case c = [select Id, subject,RFO_OrderID__c, status, Change_Request_Category__c,Engineering_Review_Started__c from case where RecordTypeId= :newCar limit 1];
        c.status = RFO_Constant.Case_Status_Engineering_Review;
        c.Change_Request_Category__c = 'External';
        c.Engineering_Review_Started__c = true;
        update c;
        
        Project_Engineer__c pe = [Select id, Engineer__c from Project_Engineer__c where Order__c = :c.RFO_OrderID__c LIMIT 1];
        Test.stopTest();
        
        Alert__c a = [Select id, Immediate_Alert_List__c, Related_To__c from Alert__c limit 1];
        String immediateList = alertSettingsMap.get(engReviewAlert)?.Immediate_Alert_List__c;
        if(!immediateList.contains(pe.Engineer__c))immediateList += immediateList.substring(immediateList.length()-1)!=';'?';' + pe.Engineer__c:pe.Engineer__c+';';
        
        System.assertEquals(immediateList, a.Immediate_Alert_List__c);
    }
    /*End ALPHA-677 */
    
}