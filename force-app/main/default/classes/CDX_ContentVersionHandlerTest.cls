/* Edited By Aniket Bajaj--*/
@isTest(seeAllData=true)
private class CDX_ContentVersionHandlerTest 
{
    @isTest 
    static void testContentVersion()
    {
        Account ac=new Account();
        ac.Name='testAccount';
        insert ac;
        Contact con = new contact();
        con.AccountId = ac.Id;
        con.FirstName = 'Test';
        con.LastName = 'Contact 123';
        con.Email = 'aniketbajaj3150@gmail.com';
        con.CDX_Cleaning_Certificate_Notifications__c=true;
        insert con;
        System.debug('account'+ac);
        Asset testAsset=new Asset();
        testAsset.name='testAsset';
        testAsset.AccountId=ac.id;
        insert  testAsset;
        System.debug('asset'+testAsset);
        RFO_ShopIncident__c shopInc=new  RFO_ShopIncident__c();
        shopInc.name='Test Service Request';
        shopInc.RFO_Customer__c = ac.id;
        shopInc.RFO_Asset__c=testAsset.id;
        insert shopInc;
        System.debug('service request'+shopInc);
        RecordType ContentRT = [select Id FROM RecordType WHERE Name='Other' and SobjectType = 'ContentVersion'];
        System.debug(' RecordType'+ContentRT);

        ContentVersion contentVersionToInsert = new ContentVersion(
                                                    Title = 'Test',
                                                    PathOnClient = 'Test.jpg',
                                                    VersionData = Blob.valueOf('Test Content Data'),
                                                    IsMajorVersion = true,
                                                    Trinity_File_Type__c = 'Partially Executed Rider',
                                                    recordTypeId = ContentRT.Id,
                                                    SharingPrivacy='N'
                                                     
                                                );
        insert contentVersionToInsert;
        
        ContentVersion ver = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionToInsert.Id];
        Id contentDocumentId=ver.ContentDocumentId;
        Id contentVersionId= ver.Id;   
                
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            
            Trinity_File_Type__c ='OTMA',
            recordTypeId = ContentRT.Id,
            SharingPrivacy='N',
            ContentDocumentId= contentDocumentId
        );
        ContentVersion contentVersionInsert1 = new ContentVersion(
            Title = 'Test1',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            Trinity_File_Type__c ='SDS',
            recordTypeId = ContentRT.Id,
            SharingPrivacy='N',
            ContentDocumentId= contentDocumentId
            
        );
        ContentVersion contentVersionInsert2 = new ContentVersion(
            Title = 'Test2',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            Trinity_File_Type__c ='Cleaning Certification',
            recordTypeId = ContentRT.Id,
            SharingPrivacy='N',
            ContentDocumentId=contentDocumentId
            
        );
        
        List<SObject> contList= new List<SObject>();
        contList.add(contentVersionInsert);
        contList.add(contentVersionInsert1);
        contList.add(contentVersionInsert2);
        Set<Id> contentVersionIds=new Set<Id>();
        Set<Id> contentVersionIds1=new Set<Id>();
        Test.startTest();
        insert contList;
        system.debug('contList'+contList);
        Set<Id> contentDocumentIdSet = new Set<Id>();
        contentDocumentIdSet.add(contentDocumentId);
        contentVersionIds.add(contentVersionId);
        
        contentVersionIds1.add(contentVersionInsert.Id);
        contentVersionIds1.add(contentVersionInsert1.Id);
        
        CollaborationGroup cg = new CollaborationGroup(Name = 'Trinity Development', CollaborationType = 'Public');
        insert cg;
        
        //CDX_CleaningCertNotificationForSerReq conVar = new CDX_CleaningCertNotificationForSerReq(shopInc);
       // Database.executeBatch(conVar);
        CDX_ContentVersionHandler.handleContentVersion(contentDocumentIdSet,contentVersionIds);
        CDX_ContentVersionHandler.handleServiceRequest(contentDocumentIdSet,contentVersionIds);
        
        Test.stopTest();
        System.debug('result'+contList);
        
    }
    @isTest
    static void testContentVersion1()
    {
        RecordType ContentRT = [select Id FROM RecordType WHERE Name='Other' and SobjectType = 'ContentVersion'];
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RFO_AccountOwner__c = 'Me';
        acc.CDX_CopyCDMOnEmail__c = true;
        insert acc;
        
        Customer_Commodity__c custcom = new Customer_Commodity__c();
        custcom.CDX_Customer__c = acc.Id;
        custcom.Name__c = 'Test Customer Commodity';
        insert custcom;

        ContentVersion c = new ContentVersion();
        c.Title = 'Test cv 1';
        c.PathOnClient = 'cv1.jpg';
        c.VersionData = Blob.valueOf('Test Content');
        c.IsMajorVersion = false;
        c.Trinity_File_Type__c = 'OTMA';
        c.recordTypeId = ContentRT.Id;
        insert c;
        
        ContentVersion d = new ContentVersion();
        d.Title = 'Test cv 2';
        d.PathOnClient = 'cv1.jpg';
        d.VersionData = Blob.valueOf('Test Content');
        d.IsMajorVersion = true;
        d.Trinity_File_Type__c = 'OTMA';
        d.recordTypeId = ContentRT.Id;
        d.ContentDocumentId = c.ContentDocumentId;
        insert d;
        
        //ContentVersion Test = [SELECT Id, Title]
    }
  /*  @isTest
    static void testContentVersionTrigger()
    {
        RecordType contentRT = [select Id FROM RecordType WHERE Name='Other' and SobjectType = 'ContentVersion' Limit 10];
        testContentVersion1();
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Limit 10];
        system.debug('LORENZO DOC SIZE: '+documents.size()+'  FIRST DOC ID '+documents[0].Id); 
        ContentVersion test = new ContentVersion();
        test.Title = 'Test';
        test.PathOnClient = 'Test.jpg';
        test.VersionData = Blob.valueOf('Test Content Data');
        test.IsMajorVersion = true;  
        test.Trinity_File_Type__c ='OTMA';
        test.recordTypeId = ContentRT.Id;
        test.SharingPrivacy='N';
        test.ContentDocumentId = documents[0].Id;
        insert test;
        
        ContentVersion yee = [SELECT Id, Trinity_File_Type__c, ContentDocumentId FROM ContentVersion WHERE Id =: test.Id Limit 10];
        
        System.debug('CONTENT VERSION LORENZO: FILE TYPE '+yee.Trinity_File_Type__c+'  DOC ID '+yee.ContentDocumentId);



    }*/



/**************************************************************************************
* @Author : Ashish Reddy
* @Modified Date : 9/10/2020
* @Description       
* @User Story : ALPHA-119    
**************************************************************************************/    
    @isTest static void testHandlePartialFileUploadNotifications(){
        
        RecordType ContentRT = [select Id FROM RecordType WHERE Name='Other' and sObjectType = 'ContentVersion'];
        
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> accList = RFO_Utility_Test.createProspectAccounts();

        accList[0].RFO_GlobalAccountID__c = String.valueOf(Math.Random()).left(18);
        accList[0].RFO_OracleId__c = String.valueOf(Math.Random()).left(18);
        accList[0].RFO_TASId__c = String.valueOf(Math.Random()).left(18);
        for(Account acc :accList ) {
            acc.recordTypeId = recordTypeId;
        }
        DataBase.insert(accList);

        
        List<Contact> contactList = new List<Contact>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        contactList = RFO_Utility_Test.createContact1(accList[0]);
        Database.insert(contactList);
        
        //contract Creation
        Contract contr = new Contract(AccountId = accList[0].id, 
                                      RFO_ContractType__c=RFO_Constant.TEST, RFO_ContractDate__c=system.today());
        Database.insert(contr);
        //Creating a Commodity
        commodityList = RFO_Utility_Test.createCommodity1();
        Database.insert(commodityList);
        Product2 prod = RFO_Utility_Test.createProduct();
        prod.isActive = true;
        Database.insert(prod);
        //Rider Creation
        RFO_Rider__c rider=new RFO_Rider__c();
        rider=RFO_Utility_Test.createrider();
        rider.RFO_Account__c=accList[0].id;
        rider.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
        rider.RFO_AutoRenewal__c = RFO_Constant.YES;
        rider.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider.RFO_RiderType__c = RFO_Constant.MANAGEMENT_AGREEMENT;
        rider.RFO_ProductType__c = RFO_Constant.TEST;
        rider.RFO_Contract__c=contr.id;
        rider.RFO_TotalOfCars__c = 9;
        rider.RFO_Commodity__c = commodityList[0].id;
        rider.RFO_IncreaseEffectiveUpon__c = RFO_Constant.COMPLETION_OF_MODIFICATION;
        rider.RFO_Product__c = prod.Id;
        Database.insert(rider);

            User userQuoteTeam = new User();
        userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
        //  userQuoteTeam.RFO_Contracts__c = True;
        userQuoteTeam.RFO_Engineering__c = True;
        userQuoteTeam.RFO_Estimating__c = True;
        userQuoteTeam.RFO_PortfolioManagement__c = True;
        userQuoteTeam.RFO_PricingSummary__c = True;
        userQuoteTeam.RFO_ProductionPlanning__c = True;
        userQuoteTeam.RFO_AccountManager__c = True;
        userQuoteTeam.RFO_Sales__c = True;
        Database.insert(userQuoteTeam);
        
        List<Opportunity> oppList = RFO_Utility_Test.createTankOpportunities1(accList[0],contactList[0]); 
        for(Opportunity opp:oppList){
            Opp.Requirement_Status__c = '';
            Opp.StageName = 'Negotiation';
        }
        database.insert(oppList);
        
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c(
            Name = 'Test',                               // QuoteTeams Name
            RFO_PortfolioMember__c = userQuoteTeam.id,  // Portfolio Management
            RFO_EngineeringMember__c = userQuoteTeam.id,  // Engineering
            RFO_PlanningMember__c = userQuoteTeam.id,     // Production Planning
            RFO_EstimatingMember__c = userQuoteTeam.id,   // Estimating
            RFO_PricingMember__c = userQuoteTeam.id,      // Pricing
            // RFO_ContractsMember__c = userQuoteTeam.id,    // Contract
            RFO_SalesMember__c = userQuoteTeam.id,    // Sales
            Region__c='Eastern',
            Type__c='Tank'
        );
        database.insert(quoteTeamRec);
        Id recordTypeIdRenewal = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();  
        // Quote Creation 
        SBQQ__Quote__c  quote = RFO_Utility_Test.createQuote(oppList[0]);
        quote.RFO_QuoteTeam__c=quoteTeamRec.id;  
        quote.RFO_PortfolioManagementSection_Started__c='Yes';
        quote.RFO_EngineeringSectionStarted__c='Yes';
        quote.RFO_EstimatingSectionStarted__c='Yes';
        quote.RFO_ProductionPlanningSection_Started__c='Yes';
        quote.RFO_PortfolioManagementSectionComplete__c =' ' ;
        quote.RFO_PortfolioManagementSectionComplete__c ='No' ;
        quote.RFO_ProdPlanSectionComplete__c='';
        quote.RFO_PricingSectionStarted__c='Yes';
        quote.RFO_PricingSectionComplete__c='';
        quote.RecordtypeId=recordTypeIdRenewal; 
        quote.RFO_RenewalDate__c=system.today();
        quote.SBQQ__Primary__c=True;
        quote.SBQQ__Key__c='1999999999';
        quote.RFO_BusinessAwarded__c = 'Yes';
        quote.RFO_QuoteStage__c = RFO_Constant.BUSINESS_AWARDED;

        database.insert(quote); 
        Test.startTest();
        ContentVersion contentVersionInsert = new ContentVersion(
                                                    Title = 'Test',
                                                    PathOnClient = 'Test.jpg',
                                                    VersionData = Blob.valueOf('Test Content Data'),
                                                    IsMajorVersion = true,
                                                    Trinity_File_Type__c = 'Partially Executed Rider',
                                                    recordTypeId = ContentRT.Id,
                                                    SharingPrivacy='N'
                                                     
                                                );
        insert contentVersionInsert;
        
        ContentVersion v = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id];
        
        
        ContentDocumentLink contentlink = new ContentDocumentLink(
                                                LinkedEntityId = rider.id,
                                                contentdocumentid = v.ContentDocumentId,
                                                ShareType = 'V',
                                                Visibility = 'AllUsers');
        insert contentlink;

        ContentDocumentLink contentlinkQuote = new ContentDocumentLink(
                                                LinkedEntityId = quote.id,
                                                contentdocumentid = v.ContentDocumentId,
                                                ShareType = 'V',
                                                Visibility = 'AllUsers');
        insert contentlinkQuote;
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        contentVersionList.add( new ContentVersion(
                                                Title = 'Test',
                                                PathOnClient = 'Test.jpg',
                                                VersionData = Blob.valueOf('Test Content Data'),
                                                IsMajorVersion = true,
                                                Trinity_File_Type__c = 'Partially Executed Rider',
                                                recordTypeId = ContentRT.Id,
                                                SharingPrivacy='N',
                                                ContentDocumentId = v.ContentDocumentId));
        
        contentVersionList.add( new ContentVersion(
                                                Title = 'Test Partially Executed Rider',
                                                PathOnClient = 'Test.jpg',
                                                VersionData = Blob.valueOf('Test Content Data Partially Executed Rider'),
                                                IsMajorVersion = true,
                                                Trinity_File_Type__c = 'Partially Executed Rider',
                                                recordTypeId = ContentRT.Id,
                                                SharingPrivacy='N',
                                                ContentDocumentId = v.ContentDocumentId));
        
        contentVersionList.add( new ContentVersion(
                                                Title = 'Test Signed Proposal',
                                                PathOnClient = 'Test.jpg',
                                                VersionData = Blob.valueOf('Test Content Data Signed Proposal'),
                                                IsMajorVersion = true,
                                                Trinity_File_Type__c = 'Signed Proposal',
                                                recordTypeId = ContentRT.Id,
                                                SharingPrivacy='N',
                                                ContentDocumentId = v.ContentDocumentId));
        insert contentVersionList;
        
        Test.stopTest();
        List<Task> t = [select id from task where whatId =: rider.Id];
        //system.assertEquals(1,t.size(), 'Failed in creating task');
    }    

    


}