/* 
* Class Name: RFO_Utility_Test 
*/
@isTest
public class RFO_Utility_Test {
    public static List<RecordType> rList = new List<RecordType>();
    /* 
* 
* @createProspectAccounts
* isTestSetup 
*/
    public static List<Account> createProspectAccounts(){
        List<Account> accList = new List<Account>();
        rList= [Select id From RecordType Where sObjectType = 'Account'and RecordType.Name = 'Prospect' Limit 1];
        Account act =new account();
        act.Name = '37 Building Products';  // Account Name
        act.recordTypeid = rlist[0].id;           // Account Record Type
        act.Phone = '800-832-5451';          // Phone
        act.RFO_Region__c = 'Class 1 Railroads';   // Region
        act.RFO_AccountStatus__c = 'Active';
        accList.add(act);
        
        Account ac1 =new account();
        ac1.Name = 'testghy1';  // Account Name
        ac1.recordTypeid = rlist[0].id;           // Account Record Type
        ac1.Phone = '800-832-5453';          // Phone
        ac1.RFO_Region__c = 'Class 1 Railroads';   // Region
        ac1.RFO_AccountStatus__c = 'Active';
        accList.add(ac1);
        
        Account ac2 =new account();
        ac2.Name = 'yuntion';  // Account Name
        ac2.recordTypeid = rlist[0].id;           // Account Record Type
        ac2.Phone = '800-832-5452';          // Phone
        ac2.RFO_Region__c = 'Class 1 Railroads';   // Region
        ac2.RFO_AccountStatus__c = 'Active';
        accList.add(ac2);
        
        System.assertEquals(ac2.RFO_AccountStatus__c, 'Active');
        
        return accList;
    }
    public static List<Contact> createContact(Account acc){
        List<Contact> cntList = new List<Contact>();
        Contact contactRec = new Contact(
            FirstName = 'Faluni'+string.valueOf(system.now().millisecond()) + string.valueOf(system.now().minute()) + string.valueOf(system.now().second()),         // FirstName
            LastName = 'Blazen'+string.valueOf(system.now().millisecond()) + string.valueOf(system.now().minute()) + string.valueOf(system.now().second()),            // LastName
            RFO_Status__c = 'Active',                                               // Status
            Email = 'Faluni.Blazen'+string.valueOf(system.now().millisecond()) + string.valueOf(system.now().minute()) + string.valueOf(system.now().second())+'@trin.net',                                  // Email
            AccountId = acc.id,                                          // Account Name
            Phone = '(806) 301-0261',                                               // Phone
            RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
            Fax = '(806) 391-7528'                                                 // Fax
        );
        cntList.add(contactRec);
        System.assertEquals(contactRec.AccountId, acc.id);
        // Contact Creation
        Contact sobj = new Contact(
            RFO_Status__c = 'Active',                      // Status
            Title = 'TESTING TITLE',               // Title
            Phone = '0000000000',                        // Work Phone
            AccountId = acc.id,                       // Account Name
            FirstName = 'Test',                        //First Name
            LastName  = 'Test',                       //Last Name
            MobilePhone = '0000000000',                  // Mobile Phone
            RFO_ContactRole__c = 'Sales - Primary Contact',  // Contact Role
            RFO_AlertOwner__c = false                       // Alert Owner
        ); 
        Database.insert(sobj);   
        
        return cntList;
    }
    /*
* @create Pricebook
*/
    public static Pricebook2 createPricebook(){
        Pricebook2 sobj = new Pricebook2(
            Name = 'Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
            
        );
        System.assertEquals(sobj.Name, 'Standard Price Book');
        
        return sobj;
    }
    /* 
* @createTankOpportunities
*/
    public static List<Opportunity> createTankOpportunities(Account acc){
        Pricebook2 sobj = createPricebook();
        update sobj;
        List<Opportunity> oppList = new List<Opportunity>();
        Id recordTypeIdTank = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Tank').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = recordTypeIdTank;                           // opportunity record type
        opp.Pricebook2Id = sobj.id;
        opp.AccountId= acc.Id;                                         // Account
        opp.Name = 'Test Opportunity';                                 // opportunity Name
        opp.StageName = 'Ready To Quote';                                   // Stage
        opp.CloseDate = Date.newInstance(2019, 05, 25);                // Close Date
        opp.RFO_Quantity__c = 2;                              // Quantity
        opp.RFO_MaximumQuantity__c = 2;
        opp.TotalOpportunityQuantity = 2; 
        opp.RFO_ExpectedCarstoTrinity__c = 3;                          // Expected cars to Trinity
        opp.RFO_ConfidenceLevel__c = 'High';                           // Confidence Level
        opp.RFO_MarketSegment__c = 'Petrochemicals';                   // Petro Chemicals
        opp.RFO_PreferredNewExisting__c = 'New';                       // Preferred New/Existing
        opp.RFO_ProductType__c = 'High Pressure Large';                // Product Type
        opp.RFO_ClosedDate__c = Date.newInstance(2019, 05, 25);// Closed Date
        opp.RFO_CustomerExpectedDeliveryStartDate__c = Date.newInstance(2019, 05, 25); // Customer Expected Delivery Date
        opp.Type = 'Additional Business';        // Basis for Transaction
        opp.RFO_LiningRequired__c ='Yes'; 
        opp.RFO_IsOpportunityConverted__c = true;
        opp.RFO_Mileage__c = 2;
        opp.RFO_MileageFee__c = 3;
        opp.RFO_ProposalDueDate__c = Date.newInstance(2019, 08, 31);
        opp.RFO_SDSReceived__c = 'Yes';
        opp.RFO_CarSpec__c = 'Trinity';  
        opp.RFO_InteriorBlast__c = 'Prep for Lining'; 
        opp.RFO_LiningSystem__c = 'AQUAFL';
        opp.RFO_LostDtl_TransactionType__c  = 'Net Lease'; 
        opp.RFO_LeaseTermsRequestedMonths__c = 90;
        opp.RFO_RenewalDueDate__c  = Date.newInstance(2019, 10, 31);
        opp.RFO_CustomerExpectedDeliveryCompleteDate__c = Date.newInstance(2019, 10, 31);
        opp.RFO_CustomerExpectedDeliveryRate__c = '9';
        opp.Requirement_Status__c = ''; //Changed by Ramesh
        List<RFO_Commodity__c> commd=RFO_Utility_Test.createCommodity();
        insert commd;
        system.debug('commd' +commd[0].id);
        opp.RFO_Commodity__c=commd[0].id;
        List<Contact> conlist= RFO_Utility_Test.createContact(acc);
        insert conlist;
        //system.debug('conlist' +conlist[0].id);
        opp.RFO_ProposalContact__c=conlist[0].id;
        // Lining Required
        oppList.add(opp);
        System.assertEquals(opp.RFO_LiningRequired__c, 'Yes');
        return oppList;
    }
    /*@createContract
*/
    public static Contract createContract(List<Account> accList)
    {
        Contract contr = new Contract();
        contr.AccountId = accList[0].id;
        contr.RFO_ContractType__c='DIRECT SALE';
        contr.RFO_ContractDate__c=system.today();
        return contr;
    }    
    /* 
* @createAssetFile
*/
    public static List<RFO_Asset_File__c> createAssetFile(Order orderRecord){
        List<RFO_Asset_File__c> assetfileList = new List<RFO_Asset_File__c>();
        RFO_Asset_File__c afile = new  RFO_Asset_File__c();
        afile.Name ='Asset File0101';
        afile.RFO_OrderNumber__c = orderRecord.id;
        afile.RFO_FileType__c='Plain';
        afile.RFO_FileSplitType__c='BOM';
        afile.RFO_Suffix__c='30';
        afile.RFO_Term__c = 1;
        afile.RFO_PaymentAmount__c = 2;
        afile.RFO_ContractType__c = 'LEASE';
        afile.RFO_Quantity__c = 10;
        afile.RFO_ProductDivision__c = 'Tank';
        afile.RFO_RiderLeaseType__c = 'Full Service';
        afile.RFO_FileNumber__c= 'T1099'; 
        afile.RFO_OrdrOriginalUnitPrice__c = 1000;// Updated By Vihari Alpha - 743
        assetfileList.add(afile);
        System.assertEquals(afile.RFO_FileType__c, 'Plain');
        return assetfileList;
    }
    /* 
* @createNewCarOrders
*/
    public static List<Order> createNewCarOrders(SBQQ__Quote__c qt,Account acc, RFO_Commodity__c comm, Product2 productRecord){
        List<Order> orderList = new List<Order>();
        Id recordTypeIdNewCar = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('RFO_NewCar').getRecordTypeId();
        Order ord = new Order();
        ord.AccountId= acc.Id;    // Account Name
        ord.RecordTypeId = recordTypeIdNewCar; // Order Record Type
        ord.SBQQ__Quote__c = qt.Id; // Quote
        ord.EffectiveDate = Date.newInstance(2019, 05, 25); //Effective DAte
        ord.Status = 'Initiated'; // Status
        ord.RFO_Quantity__c =1; // Quantity
        ord.RFO_TankorFreight__c = 'Tank'; // Tank or Freight
        ord.Type= 'Lease';  // order type
        ord.RFO_SubType__c = 'Net Lease';
        ord.RFO_CarType__c='4793 Super Max Gon'; //car type
        ord.RFO_Commodity_lookup__c =comm.id;
        ord.RFO_LeaseRate__c = 1;
        ord.RFO_LeaseTerms__c = 1;
        ord.RFO_JobCostDetails__c = 'jobcost';
        ord.RFO_SignedProposalDate__c = Date.newInstance(2019, 05, 30);
        ord.RFO_ProposalRequired__c='Yes';
        //od.RFO_NoProposalIssued__c = True ;
        ord.RFO_Product__c = productRecord.id;
        ord.RFO_Shipping_Commence_stop_notifications__c = false;
        ord.RFO_ContractRiderReceived__c = false;
        ord.Type = 'Lease';
        orderList.add(ord);
        System.assertEquals(ord.RFO_ProposalRequired__c, 'Yes');
        return orderList;
    }
    /* 
* @createNewCarCR
*/
    public static List<Case> createNewCarCR(Account acc, order od, RFO_Asset_File__c af){
        List<Case> caseList = new List<Case>();
        Id newCarChangeReqRecID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_NewCarChangeRequest').getRecordTypeId();
        //Id ExistCarChangeReqRecTypID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_ExistingCarChangeRequest').getRecordTypeId();
        Case cse = new Case();
        cse.RecordTypeId = newCarChangeReqRecID; // Change Request Record Type   
        cse.AccountId = acc.Id;   // Account Name 
        cse.RFO_OrderID__c = od.Id;
        cse.RFO_FileNumber__c = af.Id;
        cse.RFO_ChangeRequestReason__c = 'Regulatory Change';
        cse.origin ='Plant';
        cse.Description = 'test';
        cse.Status = 'Change Request Initiated'; // Status
        caseList.add(cse);
        System.assertEquals(cse.origin, 'Plant');
        return caseList;        
    }
    /* 
* @createNewCarCRLI
*/
    public static List<RFO_ChangeRequestLineItem__c> createNewCarCRLI(Case cr){
        List<RFO_ChangeRequestLineItem__c> crliList = new List<RFO_ChangeRequestLineItem__c>();
        Id cRLIRecTypId = Schema.SObjectType.RFO_ChangeRequestLineItem__c.getRecordTypeInfosByDeveloperName().get('RFO_NewCarChangeRequestLineItem').getRecordTypeId();
        RFO_ChangeRequestLineItem__c crli1 = new RFO_ChangeRequestLineItem__c();
        crli1.RecordTypeId = cRLIRecTypId;
        crli1.RFO_NewPartPartNumberIn__c = '1';
        crli1.RFO_OriginalPartPartNumberOut__c = '1';
        crli1.RFO_ImpacttoAARApproval__c = RFO_Constant.YES;
        crli1.RFO_ChangeRequestID__c = cr.id;
        crli1.Name = 'test';
        crliList.add(crli1);
        RFO_ChangeRequestLineItem__c crli2 = new RFO_ChangeRequestLineItem__c();
        crli2.RecordTypeId = cRLIRecTypId;
        crli2.RFO_NewPartPartNumberIn__c = '1';
        crli2.RFO_OriginalPartPartNumberOut__c = '1';
        crli2.RFO_ImpacttoAARApproval__c = RFO_Constant.YES;
        crli2.RFO_ChangeRequestID__c = cr.id;
        crli2.Name = 'test1';
        crliList.add(crli2);
        System.assertEquals(crli1.RFO_ChangeRequestID__c, cr.id);        
        return crliList;
    }
    /* 
* @createCPQPrimaryQuote
*/
    public static SBQQ__Quote__c createCPQPrimaryQuote(Opportunity opp ,RFO_QuoteTeams__c quoteTeamRec){
        //Id RecordTypeIdNewCarLease = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_New').getRecordTypeId();
        RFO_SkipValidations__c skipvalidation = new RFO_SkipValidations__c();
        skipvalidation.RFO_skip__c = false;
        insert skipvalidation;
        
        SBQQ__Quote__c qte = new SBQQ__Quote__c();
        qte.RFO_QuoteTeam__c =  quoteTeamRec.id;
        qte.SBQQ__Opportunity2__c = opp.Id; // Opportunity
        qte.RFO_QuoteStatus__c ='Estimating'; // Quote Status
        qte.SBQQ__Primary__c = True; // Primary Quote
        qte.RFO_ProposalRefreshStatus__c = RFO_Constant.PROPOSAL_FRESH_STATUS;   // Proposal Refresh Status
        qte.RFO_ProposalRefreshRequired__c = RFO_Constant.YES;                  // Proposal Refresh Required
        qte.RFO_DaysUntilProposalExpires__c = RFO_Constant.THIRTY; 
        //  qte.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        qte.RFO_DaysBeforeProposalRefresh__c=30;
        qte.RFO_BAdateCapture__c = Date.newInstance(2019, 05, 30);
        qte.Freight_Charge__c = 'Prepaid (TRMI Pays)';
        System.assertEquals(qte.SBQQ__Opportunity2__c, opp.Id);
        return qte;
    }
    
    /*create CPQPrimaryQuote with Product  */
    public static SBQQ__Quote__c createCPQPrimaryQuotewithProduct(Opportunity opp ,RFO_QuoteTeams__c quoteTeamRec,Product2 Product){
        //Id RecordTypeIdNewCarLease = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_New').getRecordTypeId();
        RFO_SkipValidations__c skipvalidation = new RFO_SkipValidations__c();
        skipvalidation.RFO_skip__c = false;
        insert skipvalidation;
        
        SBQQ__Quote__c quot = new SBQQ__Quote__c();
        quot.RFO_QuoteTeam__c =  quoteTeamRec.id;
        quot.SBQQ__Opportunity2__c = opp.Id; // Opportunity
        quot.RFO_QuoteStatus__c ='Estimating'; // Quote Status
        quot.SBQQ__Primary__c = True; // Primary Quote
        quot.RFO_Product__c = Product.id;
        quot.RFO_BAdateCapture__c = Date.newInstance(2019, 05, 30);
        quot.RFO_ProposalRefreshStatus__c = RFO_Constant.PROPOSAL_FRESH_STATUS;   // Proposal Refresh Status
        quot.RFO_ProposalRefreshRequired__c = RFO_Constant.YES;                  // Proposal Refresh Required
        quot.RFO_DaysUntilProposalExpires__c = '30'; 
        quot.RFO_DaysBeforeProposalRefresh__c= 30;
        quot.RFO_BusinessAwarded__c='Yes';
        quot.SBQQ__Ordered__c = True;
        quot.Freight_Charge__c = 'Prepaid (TRMI Pays)';
        System.assertEquals(quot.SBQQ__Opportunity2__c, opp.Id);
        Pricebook2 sobj = createPricebook();
        update sobj;
        return quot;
    }
    
    /*    Create a QuoteLine
*/
    
    public static SBQQ__QuoteLine__c createQuoteLine(SBQQ__Quote__c quot, Product2 Product)
    {
        SBQQ__QuoteLine__c qtl1 = new SBQQ__QuoteLine__c();
        qtl1.SBQQ__Quote__c = quot.id;
        qtl1.RFO_QuoteLookup__c=quot.id;
        qtl1.RFO_TransactionType__c='Direct Sale';
        qtl1.RFO_DirSaleQty__c=10;
        qtl1.SBQQ__Product__c =  Product.id;
        return qtl1;
    }
    /** Create a Lease Quote Line 
**/
    
    public static SBQQ__QuoteLine__c createQuoteLineLease(SBQQ__Quote__c quot, Product2 Product)
    {
        SBQQ__QuoteLine__c qtllease1 = new SBQQ__QuoteLine__c();
        qtllease1.SBQQ__Quote__c = quot.id;
        qtllease1.RFO_QuoteLookup__c=quot.id;
        qtllease1.RFO_TransactionType__c='Lease';
        qtllease1.RFO_LeaseRate__c= 5;
        qtllease1.SBQQ__Product__c =  Product.id;
        qtllease1.RFO_LeaseTerm__c= 1;
        qtllease1.RFO_LeaseType__c= 'Full Service';
        return qtllease1;
    }
    /* 
* @createQuote
*/
    public static SBQQ__Quote__c createQuote(Opportunity opp){
        /* RFO_SkipValidations__c skipvalidation = new RFO_SkipValidations__c();
skipvalidation.RFO_skip__c = false;
insert skipvalidation;*/
        
        //Id RecordTypeIdNewCarLease = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_New').getRecordTypeId();
        SBQQ__Quote__c qt1 = new SBQQ__Quote__c();
        qt1.SBQQ__Opportunity2__c = opp.Id; // Opportunity
        qt1.RFO_QuoteStatus__c ='Estimating'; // Quote Status
        qt1.SBQQ__Primary__c = True; // Primary Quote
        qt1.RFO_ProposalRefreshStatus__c = 'Resubmit for Pricing';   // Proposal Refresh Status
        qt1.RFO_ProposalRefreshRequired__c = 'Yes';                  // Proposal Refresh Required
        qt1.RFO_DaysUntilProposalExpires__c = '30'; 
        qt1.RFO_DaysBeforeProposalRefresh__c=30;
        qt1.RFO_QuoteStage__c='Not Started';
        qt1.RFO_BAdateCapture__c = Date.newInstance(2019, 05, 30);
        qt1.Freight_Charge__c = 'Prepaid (TRMI Pays)';
        System.assertEquals(qt1.SBQQ__Opportunity2__c, opp.Id);
        return qt1;
    }
    
    /* 
* @createUserRecord
*/
    public static User createUserRecord(){
        
        UserRole rle = new UserRole(DeveloperName = 'MyCustomRole' + System.currentTimeMillis(), Name = 'My Role');
        Database.insert(rle); 
        User userRecord = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = rle.Id
        );
        System.assert(userRecord !=null);
        return userRecord;
    }
    
    /* 
* @createUserRecordForCPQ
*/
    public static User createUserRecordForCPQ(){       
        User userRecord = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        System.assert(userRecord.username!=null);
        
        return userRecord;
    }
    /* 
* @createCommodity
*/
    public static List<RFO_Commodity__c> createCommodity(){
        List<RFO_Commodity__c> commList = new List<RFO_Commodity__c>();
        RFO_Commodity__c sobj = new RFO_Commodity__c(
            Name = 'TEST1',                    // Commodity Name
            //RFO_STCC__c = String.valueOf(string.valueOf(system.now().millisecond()) + string.valueOf(system.now().minute()) + string.valueOf(system.now().second()) + 'TEST').subString(0,6), // STCC
            //RFO_STCC__c = 'test'+String.valueOf(Crypto.getRandomInteger()).substring(0,3),
            RFO_Active__c = true,                // Active
            RFO_Corrosive__c = true,             // Corrosive
            RFO_Hazard__c = true,                // Hazard
            RFO_MarketGroup__c = 'kahdksj',      // Market Group
            RFO_MarketSubSegment__c = 'jsdsjd',  // Market Sub Segment
            RFO_MarketSegment__c = 'dusud'      // Market Segment
        );
        commList.add(sobj);
        System.assertEquals(sobj.RFO_Active__c, true);
        System.debug(sobj.RFO_STCC__c);
        return commList;
    }
    
    public static List<RFO_Commodity__c> createCommodity1(){
        List<RFO_Commodity__c> commList = new List<RFO_Commodity__c>();
        RFO_Commodity__c sobj = new RFO_Commodity__c(
            Name = 'TEST2',                    // Commodity Name
            //RFO_STCC__c = String.valueOf(string.valueOf(system.now().millisecond()) + string.valueOf(system.now().minute()) + string.valueOf(system.now().second()) + 'T2').subString(0,6), // STCC
            //RFO_STCC__c = 'test'+String.valueOf(Crypto.getRandomInteger()).substring(0,3),
            RFO_Active__c = true,                // Active
            RFO_Corrosive__c = true,             // Corrosive
            RFO_Hazard__c = true,                // Hazard
            RFO_MarketGroup__c = 'kahdksjasd',      // Market Group
            RFO_MarketSubSegment__c = 'jsdsasdjd',  // Market Sub Segment
            RFO_MarketSegment__c = 'dussadud'      // Market Segment
        );
        commList.add(sobj);
        System.assertEquals(sobj.RFO_Active__c, true);
        
        return commList;
    }
    /* 
* insert #AccountTeamMember record
*/
    public static AccountTeamMember createAccountTeamMember(Id userRecordId, id accountRecordId) {
        
        AccountTeamMember team = new AccountTeamMember();
        team.AccountID=accountRecordId;
        team.UserId=userRecordId;
        team.TeamMemberRole ='Customer Delivery Director';
        System.assertEquals(team.UserId, userRecordId);
        
        return team;
    }
    
    public static AccountTeamMember createAccountTeamMemberCDM(Id userRecordId, id accountRecordId) {
        
        AccountTeamMember team = new AccountTeamMember();
        team.AccountID=accountRecordId;
        team.UserId=userRecordId;
        team.TeamMemberRole ='Customer Delivery Manager';
        System.assertEquals(team.UserId, userRecordId);
        
        return team;
    }
    /* 
* custom setting insertion - #customSetting RFO_IntegrationLinks__c
*/
    public static RFO_IntegrationLinks__c createIntegrationLinks(String value) {
        RFO_IntegrationLinks__c links = new RFO_IntegrationLinks__c();
        links.name = 'AccountTeamMember';
        links.RFO_APILink__c = value;
        System.assertEquals(links.RFO_APILink__c, value);
        
        return links;
    }
    /**
* Create Rider test data
**/ 
    public static RFO_Rider__c createrider(){
        RFO_Rider__c rider = new RFO_Rider__c(
            RFO_Status__c = 'Signed Contract Documents Received',     // Status
            RFO_PriceType__c = 'Firm Pricing',                        // Price Type
            RFO_RiderType__c = 'Management Service' ,            
            RFO_ProductType__c = '20,590 wg SS NCNI - 263 GRL',                      // Product Type
            RFO_TotalOfCars__c = 5,                                                // Total # of Cars
            //RFO_ReportingMarks__c = '7',                                             // Reporting Marks
            //RFO_RunningNumbers__c = '6',                                             // Running Numbers
            //RFO_OrderTypeDescription__c = 'test',                                    // Order Type Description
            //RFO_TransactionType__c = 'Direct Sale',                                  // Transaction Type
            RFO_RiderDate__c = system.today(),                            // Rider Date
            RFO_ExecutedDate__c = system.today(),                         // Executed Date
            RFO_StartMethod__c = 'Delivery Date',                                    // Start Method
            RFO_AssetsAssigned__c = false,                                           // Assets Assigned
            RFO_OriginalMaturityDate__c = system.today(),                 // Original Maturity Date
            RFO_CurrentMaturityDate__c = system.today(),                  // Current Maturity Date
            RFO_RiderRateType__c = 'Term',                                           // Rider Rate Type
            RFO_UnitofMeasure__c = 'per car, per month',                             // Unit of Measure
            //RFO_PaymentFrequency__c = 'Monthly',                                     // Payment Frequency
            RFO_Term__c = 6,                                                       // Term
            //RFO_NumberofPayments__c = 4,                                           // Number of Payments
            RFO_StartMonth__c = 7,                                                 // Start Month
            RFO_EndMonth__c = 7,                                                   // End Month
            RFO_StartDate__c = system.today(),                            // Start Date
            RFO_EndDate__c = system.today(),                              // End Date
            RFO_EstimatedMiles__c = 7,                                             // Estimated Miles
            RFO_RiderRate__c = 7.00,                                                 // Rider Rate
            RFO_RiderFixedRate__c = 7.00,                                            // Fixed Rate
            //RFO_RiderFixedStartDate__c = system.now(),  // Fixed Start Date
            //RFO_RiderFixedEndDate__c = system.now(),    // Fixed End Date
            //RFO_AdditionalLeaseRateFactor__c = 6,                                  // Additional Lease Rate Factor
            RFO_PerModCostPerCar__c = 6,                                           // Per Mod Cost Per Car
            RFO_IncreaseEffectiveUpon__c = 'Issuance Of Mandate',            // Increase Effective Upon
            RFO_LesseeRightofTermination__c = 'Yes',                                 // Lessee Right of Termination
            RFO_NotesComments__c = 'test',                                           // Notes/Comments
            RFO_AutoRenewalTermTermMonths__c = 6,                                  // Auto Renewal Term - Term Months
            RFO_RenewalDaysNotice__c = 6,                                          // Renewal - Days Notice
            RFO_RenewalRateChange__c = 6,                                            // Renewal Rate Change
            RFO_AutoRenewal__c = 'Yes',                                              // Auto-Renewal
            RFO_PurchaseOptionMonths__c = 1,                                       // Purchase Option - Months
            RFO_PurchaseOptionNoticeDays__c = 2,                                   // Purchase Option - Notice Days
            RFO_PurchaseOptionValue__c = 2,                                          // Purchase Option - Value
            RFO_EarlyTerminationNoticeRequired__c = 2,                               // Early Termination - Notice Required
            RFO_EarlyTerminationCost__c = 4,                                         // Early Termination - Cost
            RFO_EarlyTerminationQuantity__c = 7,                                   // Early Termination - Quantity
            RFO_ExcessMileageMethod__c = 'Rider Average',                            // Excess Mileage Method
            RFO_ExcessMileagePremium__c = 6,                                         // Excess Mileage Premium
            RFO_MileageLimit__c = 6,                                               // Mileage Limit
            RFO_ContractStatusNotes__c = '6',                                        // Contract Status Notes
            RFO_CreditApproved__c = false,                                           // Credit Approved
            RFO_ContractRiderAuditComplete__c = false,                               // Contract/Rider Audit Complete
            RFO_1stCarAssignedRiderRateValidated__c = false,                         // 1st Car Assigned - Rider Rate Validated
            RFO_LastCarAssignedCarValidated__c = false,                              // Last Car Assigned - Car # Validated
            RFO_LastCarAssignedCarOwnersValidated__c = false                        // Last Car Assigned - Car Owners Validated
        );
        System.assertEquals(rider.RFO_AutoRenewal__c,'Yes');
        
        return rider;
    }
    /**
* Create Asset test data
**/ 
    public static List<Asset> createAssetRecord(id accountRecordId){
        List<Asset> assetList = new List<Asset>(); 
        Asset asst = new Asset();
        asst.Name = 'Test Asset';
        asst.RFO_File__c = 'T1099';
        asst.AccountId = accountRecordId;
        assetList.add(asst);
        System.assertEquals(asst.AccountId, accountRecordId);
        
        return assetList;
    }
    /**
* Create QuoteTeam test data
**/     
    public static RFO_QuoteTeams__c createQuoteTeam(){
        User userQuoteTeam = new User();
        userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
        //userQuoteTeam.RFO_Contracts__c = True;
        userQuoteTeam.RFO_Engineering__c = True;
        userQuoteTeam.RFO_Estimating__c = True;
        userQuoteTeam.RFO_PortfolioManagement__c = True;
        userQuoteTeam.RFO_PricingSummary__c = True;
        userQuoteTeam.RFO_ProductionPlanning__c = True;
        userQuoteTeam.RFO_AccountManager__c = True;
        userQuoteTeam.RFO_Sales__c = True;
        Database.insert(userQuoteTeam);
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c(
            Name = 'Test',                               // QuoteTeams Name
            RFO_PortfolioMember__c = userQuoteTeam.id,  // Portfolio Management
            RFO_EngineeringMember__c = userQuoteTeam.id,  // Engineering
            RFO_PlanningMember__c = userQuoteTeam.id,     // Production Planning
            RFO_EstimatingMember__c = userQuoteTeam.id,   // Estimating
            RFO_PricingMember__c = userQuoteTeam.id,      // Pricing /*RFO_ContractsMember__c = userQuoteTeam.id,    // Contract*/
            RFO_SalesMember__c = userQuoteTeam.id     // Sales
        );
        System.assertEquals(quoteTeamRecord.RFO_PortfolioMember__c, userQuoteTeam.Id);
        return quoteTeamRecord;
    }
    public static RFO_QuoteTeams__c createQuoteTeamUpdated(){
        User userQuoteTeam = new User();
        userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
        Database.insert(userQuoteTeam);
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c(
            Name = 'Test',                               // QuoteTeams Name
            Region__c = 'Eastern',
            Type__c = 'Tank'
        );
        System.assertEquals(quoteTeamRecord.Name, 'Test');
        return quoteTeamRecord;
    }
    
    /** Create a Quote Team member **/
    public static Quote_Team_Member__c createQuoteTeamMember(SBQQ__Quote__c quoteRec,User userQuoteTeam){
        Quote_Team_Member__c quotteammem = new Quote_Team_Member__c(); 
        quotteammem.Role__c = 'Engineering';
        quotteammem.User__c = userQuoteTeam.id;
        quotteammem.Quote__c = quoteRec.id;
        System.assertEquals(quotteammem.Role__c, 'Engineering');
        return quotteammem;
    }
    /**
* Create Product test data
**/
    public static Product2 createProduct(){
        Product2 productRec = new Product2(
            Name = '12,831 wg - CI, 300#, 263',        // Product Name
            RFO_RiskBookType__c = 'Tank Car Pressure',   // Risk Book Type
            RFO_STDCarType__c = 'Tank Car Pressure',     // ARCI Car Type
            RFO_FinanceType__c = 'Tankcar Pressure',     // Finance Type
            RFO_Qty__c = 1200,                        // Quantity
            RFO_CarTypeGroupName__c = 'Tank',            // Product Division
            RFO_CarSeriesDesc__c = 'Tank Car Pressure',  // Product Series
            RFO_TypeDesc__c = 'High Pressure Large',     // Product Type
            RFO_Category__c = 'Tankcar Pressure'        // Category
        );
        System.assertEquals(productRec.RFO_Qty__c,1200.00);
        
        return productRec;
    }
    
    /**
*   Test method: utilityCls_TestMethod
**/ 
    private static testMethod void utilityCls_TestMethod(){
        Test.startTest();
        //RFO_Utility.createErrorLogRecordFuture(String errorMessage, String ObjectName, String Source, String className, String methodName);
        //RFO_Utility.createErrorLogRecord(String errorMessage, String ObjectName, String Source, String className, String methodName);
        
        RFO_Utility.createErrorLogRecordFuture('test error msg', 'testObj', 'Trigger', 'testClsName', 'testMethodName');
        RFO_Utility.createErrorLogRecord('test error msg', 'testObj', 'Trigger', 'testClsName', 'testMethodName');
        
        // System.assert(riderRecord!=null);
        //   System.assertEquals(createErrorLogRecordFuture.RFO_ErrorMessage__c=errorMessage);
        
        Test.stopTest();
        
    }
    
    /**
*   Creating CPQ Quote list with quote teams
**/ 
    
    public static List<SBQQ__Quote__c> createQuoteList(Opportunity opp){
        List<SBQQ__Quote__c> quoteLst = new List<SBQQ__Quote__c>();
        RFO_QuoteTeams__c quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
        Database.insert(quoteTeamRec);  
        
        SBQQ__Quote__c qt1 = RFO_Utility_Test.createQuote(opp); 
        qt1.RFO_QuoteTeam__c =  quoteTeamRec.id; 
        qt1.RFO_ProposalRefreshStatus__c = 'Resubmit for Pricing';   // Proposal Refresh Status
        qt1.RFO_ProposalRefreshRequired__c = '';                      // Proposal Refresh Required
        qt1.RFO_DaysUntilProposalExpires__c = '30'; 
        qt1.RFO_DaysBeforeProposalRefresh__c=30;
        qt1.RFO_QuoteStage__c= 'Approve to Quote';
        qt1.SBQQ__Primary__c = False;
        System.assertEquals(qt1.SBQQ__Opportunity2__c, opp.Id);
        quoteLst.add(qt1);
        
        
        SBQQ__Quote__c qt2 = RFO_Utility_Test.createQuote(opp);
        qt2.RFO_QuoteTeam__c =  quoteTeamRec.id; 
        qt2.RFO_ProposalRefreshRequired__c = '';                  // Proposal Refresh Required
        qt2.RFO_DaysUntilProposalExpires__c = '30'; 
        qt2.RFO_DaysBeforeProposalRefresh__c=0;  
        qt2.RFO_QuoteStage__c= 'Approve to Quote';
        qt2.SBQQ__Primary__c = False;
        quoteLst.add(qt2);
        
        SBQQ__Quote__c qt3 =  RFO_Utility_Test.createQuote(opp);
        qt3.RFO_QuoteTeam__c =  quoteTeamRec.id; 
        qt3.RFO_ProposalRefreshRequired__c = 'Yes';                  // Proposal Refresh Required
        qt3.RFO_DaysUntilProposalExpires__c = '0 days until Proposal Expires'; 
        qt3.RFO_DaysBeforeProposalRefresh__c=0;  
        qt3.RFO_QuoteStage__c= 'Approve to Quote';   // Proposal Refresh Status
        qt3.SBQQ__Primary__c = False;
        qt3.RFO_ProposalExpired__c='';
        quoteLst.add(qt3);
        
        SBQQ__Quote__c qt4 = RFO_Utility_Test.createQuote(opp);
        qt4.RFO_QuoteTeam__c =  quoteTeamRec.id; 
        qt4.RFO_ProposalRefreshRequired__c = 'Yes';                  // Proposal Refresh Required
        qt4.RFO_DaysUntilProposalExpires__c = '30'; 
        qt4.RFO_DaysBeforeProposalRefresh__c=0;  
        qt4.RFO_QuoteStage__c= 'Approve to Quote';   // Proposal Refresh Status
        qt4.RFO_ProposalExpired__c='';
        qt4.SBQQ__Primary__c = False;
        quoteLst.add(qt4);      
        
        SBQQ__Quote__c qt5 = RFO_Utility_Test.createQuote(opp);
        Id recordTypeIdNewCarLease = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName()
            .get('RFO_New').getRecordTypeId();
        Id recordTypeIdExistingCarLease= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName()
            .get('RFO_Existing').getRecordTypeId(); 
        qt5.RFO_QuoteTeam__c=quoteTeamRec.id;  
        qt5.RFO_PortfolioManagementSectionComplete__c =' ' ;   // Porfolio Management section complete check
        qt5.RFO_PortfolioManagementSectionComplete__c ='No' ;  
        qt5.RFO_ProdPlanSectionComplete__c='';
        qt5.RecordtypeId=RecordTypeIdNewCarLease;       //Quote Record type= New Car Lease 
        quoteLst.add(qt5);      
        
        SBQQ__Quote__c qt6 = RFO_Utility_Test.createQuote(opp);
        qt6.RFO_QuoteTeam__c =  quoteTeamRec.id; 
        qt6.RFO_ProposalRefreshRequired__c = 'Yes';                  // Proposal Refresh Required
        qt6.RFO_DaysUntilProposalExpires__c = '29'; 
        qt6.RFO_DaysBeforeProposalRefresh__c=30;  
        qt6.RFO_QuoteStage__c= 'Approve to Quote';
        qt6.SBQQ__Primary__c = False;
        quoteLst.add(qt6);
        
        
        database.insert(quoteLst);
        System.debug('quoteLst' +quoteLst);
        return quoteLst;
    }
    public static List<Opportunity> createTankOpportunities1(Account acc, Contact cont){
        Pricebook2 sobj = createPricebook();
        update sobj;
        List<Opportunity> oppList = new List<Opportunity>();
        Id recordTypeIdTank = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Tank').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = recordTypeIdTank;                           // opportunity record type
        opp.Pricebook2Id = sobj.id;
        opp.AccountId= acc.Id;                                         // Account
        opp.Name = 'Test Opportunity';                                 // opportunity Name
        opp.StageName = 'Ready To Quote';                                   // Stage
        opp.CloseDate = Date.newInstance(2019, 05, 25);                // Close Date
        opp.RFO_Quantity__c = 2;                              // Quantity
        opp.RFO_MaximumQuantity__c = 2;
        opp.TotalOpportunityQuantity = 2; 
        opp.RFO_ExpectedCarstoTrinity__c = 3;                          // Expected cars to Trinity
        opp.RFO_ConfidenceLevel__c = 'High';                           // Confidence Level
        opp.RFO_MarketSegment__c = 'Petrochemicals';                   // Petro Chemicals
        opp.RFO_PreferredNewExisting__c = 'New';                       // Preferred New/Existing
        opp.RFO_ProductType__c = 'High Pressure Large';                // Product Type
        opp.RFO_ClosedDate__c = Date.newInstance(2019, 05, 25);// Closed Date
        opp.RFO_CustomerExpectedDeliveryStartDate__c = Date.newInstance(2019, 05, 25); // Customer Expected Delivery Date
        opp.Type = 'Additional Business';        // Basis for Transaction
        opp.RFO_LiningRequired__c ='Yes'; 
        opp.RFO_IsOpportunityConverted__c = true;
        opp.RFO_Mileage__c = 2;
        opp.RFO_MileageFee__c = 3;
        opp.RFO_ProposalDueDate__c = Date.newInstance(2019, 08, 31);
        opp.RFO_SDSReceived__c = 'Yes';
        opp.RFO_CarSpec__c = 'Trinity';  
        opp.RFO_InteriorBlast__c = 'Prep for Lining'; 
        opp.RFO_LiningSystem__c = 'AQUAFL';
        opp.RFO_LostDtl_TransactionType__c  = 'Net Lease'; 
        opp.RFO_LeaseTermsRequestedMonths__c = 90;
        opp.RFO_RenewalDueDate__c  = Date.newInstance(2019, 10, 31);
        opp.RFO_CustomerExpectedDeliveryCompleteDate__c = Date.newInstance(2019, 10, 31);
        opp.RFO_CustomerExpectedDeliveryRate__c = '9';
        List<RFO_Commodity__c> commd=RFO_Utility_Test.createCommodity();
        insert commd;
        system.debug('commd' +commd[0].id);
        opp.RFO_Commodity__c=commd[0].id;
        opp.RFO_ProposalContact__c=cont.id;
        // Lining Required
        oppList.add(opp);
        System.assertEquals(opp.RFO_LiningRequired__c, 'Yes');
        return oppList;
    }
    public static List<Contact> createContact1(Account acc){
        List<Contact> cntList = new List<Contact>();
        Contact contactRec = new Contact(
            FirstName = 'Faluni'+string.valueOf(system.now().millisecond()) + string.valueOf(system.now().minute()) + string.valueOf(system.now().second()),         // FirstName
            LastName = 'Blazen'+string.valueOf(system.now().millisecond()) + string.valueOf(system.now().minute()) + string.valueOf(system.now().second()),            // LastName
            RFO_Status__c = 'Active',                                               // Status
            Email = 'Faluni.Blazen'+string.valueOf(system.now().millisecond()) + string.valueOf(system.now().minute()) + string.valueOf(system.now().second())+'@trin.net',                                  // Email
            AccountId = acc.id,                                          // Account Name
            Phone = '(806) 301-0261',                                               // Phone
            RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
            Fax = '(806) 391-7528'                                                 // Fax
        );
        cntList.add(contactRec);
        System.assertEquals(contactRec.AccountId, acc.id);
        
        return cntList;
    }
    
    /* Added By Vihari  ALPHA - 743 */
    /* Method to create Change Order*/
    public static List<RFO_ChangeOrder__c> createChangeOrders(Order o, RFO_Asset_File__c aFile){
		List<RFO_ChangeOrder__c> coList = new List<RFO_ChangeOrder__c>();
        coList.add(new RFO_ChangeOrder__c(Name = 'testing', RFO_ChangeOrderLetter__c = 'T', RFO_ChangeDueto__c = 'Advise cost plus pricing', RFO_Change_Order_Month__c = 'Test Month', RFO_OrderID__c=o.id, RFO_AssetFile__c=aFile.id));
        coList.add(new RFO_ChangeOrder__c(Name = 'testing2', RFO_ChangeOrderLetter__c = 'TT', RFO_ChangeDueto__c = 'Advise cost plus pricing', RFO_Change_Order_Month__c = 'Test Month', RFO_OrderID__c=o.id, RFO_AssetFile__c=aFile.id));
		
        return coList;
    }
    
    /* Method to create Change Order LIne ITems*/
    public static List<RFO_ChangeOrderLineItem__c> createChangeOrderLineItems(List<RFO_ChangeOrder__c> coTestList){
		List<RFO_ChangeOrderLineItem__c> coliList = new List<RFO_ChangeOrderLineItem__c>();
        for(RFO_ChangeOrder__c coTest: coTestList){
        	coliList.add(new RFO_ChangeOrderLineItem__c(Name = '1', RFO_ChangeOrderLineItemComments__c = 'testing',RFO_ChangeDetailPrice__c=125, RFO_ChangeOrderID__c = coTest.Id));
        	coliList.add(new RFO_ChangeOrderLineItem__c(Name = '2', RFO_ChangeOrderLineItemComments__c = 'testing',RFO_ChangeDetailPrice__c=125, RFO_ChangeOrderID__c = coTest.Id));
    	}
       
        return coliList;
    }
    /* End ALPHA - 739 */
}