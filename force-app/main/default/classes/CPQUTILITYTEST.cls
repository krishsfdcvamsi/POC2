@isTest
public class CPQUTILITYTEST {
    public static List<RecordType> rList = new List<RecordType>();
    public static List<Account> createProspectAccounts2(){
        List<Account> accList = new List<Account>();
        rList= [Select id From RecordType Where sObjectType = 'Account'and RecordType.Name = 'Prospect' Limit 1];
        Account act =new account();
        act.Name = '73 Building Products';  // Account Name
        act.recordTypeid = rlist[0].id;           // Account Record Type
        act.Phone = '800-832-5415';          // Phone
        act.RFO_Region__c = 'Class Railroads';   // Region
        act.RFO_AccountStatus__c = 'Active';
        act.ownerId = userInfo.getUserId();
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
	public static List<Account> createProspectAccounts(){
        List<Account> accList = new List<Account>();
        rList= [Select id From RecordType Where sObjectType = 'Account'and RecordType.Name = 'Prospect' Limit 1];
        Account act 				=		new account();
        act.Name 					= 		'37 Building Products';  // Account Name
        act.recordTypeid 			= 		rlist[0].id;           // Account Record Type
        act.Phone 					= 		'800-832-5451';          // Phone
        act.RFO_Region__c 			= 		'Class 1 Railroads';   // Region
        act.RFO_AccountStatus__c	= 		'Active';
        act.ownerId 				= 		userInfo.getUserId();
        accList.add(act);
        
        Account ac1 				=		new account();
        ac1.Name 					= 		'testghy1';  // Account Name
        ac1.recordTypeid 			= 		rlist[0].id;           // Account Record Type
        ac1.Phone 					= 		'800-832-5453';          // Phone
        ac1.RFO_Region__c 			= 		'Class 1 Railroads';   // Region
        ac1.RFO_AccountStatus__c 	= 	'Active';
        accList.add(ac1);
        
        Account ac2 				=		new account();
        ac2.Name 					= 		'yuntion';  // Account Name
        ac2.recordTypeid 			= 		rlist[0].id;           // Account Record Type
        ac2.Phone 					= 		'800-832-5452';          // Phone
        ac2.RFO_Region__c 			= 		'Class 1 Railroads';   // Region
        ac2.RFO_AccountStatus__c 	= 		'Active';
        accList.add(ac2);
        
        System.assertEquals(ac2.RFO_AccountStatus__c, 'Active');
        
        return accList;
    }
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
        opp.Requirement_Status__c  = 'Test Requirements';
        opp.RFO_RenewalDueDate__c  = Date.newInstance(2019, 10, 31);
        opp.RFO_CustomerExpectedDeliveryCompleteDate__c = Date.newInstance(2019, 10, 31);
        opp.RFO_CustomerExpectedDeliveryRate__c = '9';
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
    
    public static List<Opportunity> createRenewalOpportunities(Account acc){
        Pricebook2 sobj = createPricebook();
        update sobj;
        List<Opportunity> oppList = new List<Opportunity>();
        Id recordTypeIdTank = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Renewals').getRecordTypeId();
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
        opp.Requirement_Status__c  = 'Test Requirements';
        opp.RFO_RenewalDueDate__c  = Date.newInstance(2019, 10, 31);
        opp.RFO_CustomerExpectedDeliveryCompleteDate__c = Date.newInstance(2019, 10, 31);
        opp.RFO_CustomerExpectedDeliveryRate__c = '9';
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
     public static RFO_QuoteTeams__c createQuoteTeam(){
        User userQuoteTeam = new User();
        userQuoteTeam = createUserRecordForCPQ();
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
    public static SBQQ__Quote__c createCPQPrimaryQuote(Opportunity opp ,RFO_QuoteTeams__c quoteTeamRec){
        Id recordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
        RFO_SkipValidations__c skipvalidation = new RFO_SkipValidations__c();
        skipvalidation.RFO_skip__c = false;
        insert skipvalidation;
        
        SBQQ__Quote__c qte = new SBQQ__Quote__c();
        qte.recordTypeId = recordType;
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
        System.assertEquals(qte.SBQQ__Opportunity2__c, opp.Id);
        return qte;
    }
    
    public static List<Opportunity> createTankOpportunities1(Account acc, Contact cont){
        Pricebook2 sobj = createPricebook();
        update sobj;
        List<Opportunity> oppList = new List<Opportunity>();
        Id recordTypeIdTank = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Tank').getRecordTypeId();
        system.debug('zzz'+recordTypeIdTank);
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
        opp.OwnerId = acc.ownerId;
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
        opp.Requirement_Status__c  = 'Test Requirements';
        List<RFO_Commodity__c> commd=createCommodity1();
        insert commd;
        system.debug('commd' +commd[0].id);
        opp.RFO_Commodity__c=commd[0].id;
        opp.RFO_ProposalContact__c=cont.id;
        // Lining Required
        oppList.add(opp);
        System.assertEquals(opp.RFO_LiningRequired__c, 'Yes');
        return oppList;
    }
    public static Product2 createProduct(){
        Product2 productRec = new Product2(
            Name = '12,831 wg - CI, 300#, 263',        // Product Name
            RFO_RiskBookType__c = 'Tank Car Pressure',   // Risk Book Type
            RFO_STDCarType__c = 'Tank Car Pressure',     // ARCI Car Type
            RFO_FinanceType__c = 'Tankcar Pressure',     // Finance Type
            RFO_Qty__c = 1200,							// Quantity
            IsActive = true, 
            RFO_CarTypeGroupName__c = 'Tank',            // Product Division
            RFO_CarSeriesDesc__c = 'Tank Car Pressure',  // Product Series
            RFO_TypeDesc__c = 'High Pressure Large',     // Product Type
            RFO_Category__c = 'Tankcar Pressure'        // Category
        );
        System.assertEquals(productRec.RFO_Qty__c,1200.00);
        
        return productRec;
    }
    public static SBQQ__Quote__c createCPQPrimaryQuotewithProduct2(Opportunity opp ,
                                                                  RFO_QuoteTeams__c quoteTeamRec,
                                                                  Product2 Product,String ownerId){
        //Id RecordTypeIdNewCarLease = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_New').getRecordTypeId();
        /*
                                                                      RFO_SkipValidations__c skipvalidation = RFO_SkipValidations__c.getValues(ownerId);
         
       	if(skipvalidation  == null){
            		RFO_SkipValidations__c newskipvalidation  = new RFO_SkipValidations__c();
                    newskipvalidation.RFO_skip__c = false;
        			insert newskipvalidation;                                                       
        }
        
		*/        
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
        System.assertEquals(quot.SBQQ__Opportunity2__c, opp.Id);
        Pricebook2 sobj = createPricebook();
        update sobj;
        return quot;
    }
    public static SBQQ__Quote__c createCPQPrimaryQuotewithProduct(Opportunity opp ,
                                                                  RFO_QuoteTeams__c quoteTeamRec,
                                                                  Product2 Product){
        //Id RecordTypeIdNewCarLease = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_New').getRecordTypeId();
        RFO_SkipValidations__c skipvalidation = new RFO_SkipValidations__c();
        skipvalidation.RFO_skip__c = false;
        upsert skipvalidation;
        
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
        System.assertEquals(quot.SBQQ__Opportunity2__c, opp.Id);
        Pricebook2 sobj = createPricebook();
        update sobj;
        return quot;
    }
    public static SBQQ__Quote__c createCPQPrimaryQuotewithProductCPQ(Opportunity opp ,
                                                                     RFO_QuoteTeams__c quoteTeamRec,
                                                                     Product2 Product,
                                                                     String recordTypeName
                                                                    ){
        Id recTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        RFO_SkipValidations__c skipvalidation = new RFO_SkipValidations__c();
        skipvalidation.RFO_skip__c = false;
     
        if( recordTypeName != 'Existing')
        	insert skipvalidation;
        
        SBQQ__Quote__c quot = new SBQQ__Quote__c();
        quot.RFO_QuoteTeam__c =  quoteTeamRec.id;
        quot.RecordTypeId = recTypeId;
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
        System.assertEquals(quot.SBQQ__Opportunity2__c, opp.Id);
        Pricebook2 sobj = createPricebook();
        update sobj;
        return quot;
    }
    public static SBQQ__Quote__c createCPQPrimaryQuotewithProductCPQNoSkipValidation(Opportunity opp ,
                                                                     RFO_QuoteTeams__c quoteTeamRec,
                                                                     Product2 Product,
                                                                     String recordTypeName
                                                                     
                                                                    ){
        Id recTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
       
        SBQQ__Quote__c quot = new SBQQ__Quote__c();
        quot.RFO_QuoteTeam__c =  quoteTeamRec.id;
        quot.RecordTypeId = recTypeId;
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
        System.assertEquals(quot.SBQQ__Opportunity2__c, opp.Id);
        Pricebook2 sobj = createPricebook();
        update sobj;
        return quot;
    }
    public static SBQQ__Quote__c createCPQPrimaryQuotewithProductCPQ(Opportunity opp ,
                                                                     RFO_QuoteTeams__c quoteTeamRec,
                                                                     Product2 Product,
                                                                     String recordTypeName,
                                                                     boolean avoidCustomSettings
                                                                    ){
        Id recTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        RFO_SkipValidations__c skipvalidation = new RFO_SkipValidations__c();
        skipvalidation.RFO_skip__c = false;
     
        if( recordTypeName != 'Existing' && avoidCustomSettings == false)
        	insert skipvalidation;
        
        SBQQ__Quote__c quot 					= new SBQQ__Quote__c();
        quot.RFO_QuoteTeam__c 					=  quoteTeamRec.id;
        quot.RecordTypeId 						= recTypeId;
        quot.SBQQ__Opportunity2__c 				= opp.Id; // Opportunity
        quot.RFO_QuoteStatus__c 				='Estimating'; // Quote Status
        quot.SBQQ__Primary__c 					= True; // Primary Quote
        quot.RFO_Product__c 					= Product.id;
        quot.RFO_BAdateCapture__c 				= Date.newInstance(2019, 05, 30);
        quot.RFO_ProposalRefreshStatus__c 		= RFO_Constant.PROPOSAL_FRESH_STATUS;   // Proposal Refresh Status
        quot.RFO_ProposalRefreshRequired__c 	= RFO_Constant.YES;                  // Proposal Refresh Required
        quot.RFO_DaysUntilProposalExpires__c 	= '30'; 
        quot.RFO_DaysBeforeProposalRefresh__c	= 30;
        quot.RFO_BusinessAwarded__c				='Yes';
        quot.SBQQ__Ordered__c 					= True;
        System.assertEquals(quot.SBQQ__Opportunity2__c, opp.Id);
        Pricebook2 sobj = createPricebook();
        update sobj;
        return quot;
    }
    public static Pricebook2 createPricebook(){
        Pricebook2 sobj = new Pricebook2(
            Name = 'Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
            
        );
        System.assertEquals(sobj.Name, 'Standard Price Book');
        
        return sobj;
    }
    Public Static Asset createAsset(String commodityListId,String strName,String ProductId,Account objAcc){
        Asset  objAsset 							= New Asset();
        objAsset.Name 								= strName;
        objAsset.Product2Id  						= ProductId;
        objAsset.AccountId 							= objAcc.Id;
        objAsset.CDX_Last_Shopped_Commodity__c 		= commodityListId;
        objAsset.RFO_DateBuilt__c					= date.valueOf('2020-01-01');
        objAsset.IRR_Base_Cost__c 					= 100000.0;
        objAsset.Betterment_Asset_Key__c 			=	500.0;
        objAsset.Residual_Curve_Id__c				=	'3515';
        objAsset.RFO_CommittedTo__c					=	objAcc.Name;
        objAsset.RFO_CarSubStatus__c				=	'Committed';
        return objAsset;
    }
    
     public static SBQQ__QuoteLine__c createQuoteLine(SBQQ__Quote__c quot, Product2 Product)
    {
        SBQQ__QuoteLine__c qtl1 = new SBQQ__QuoteLine__c();
        //RFO_Tank
        Id recordTypeIdTank = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('RFO_Tank').getRecordTypeId();
        qtl1.SBQQ__Quote__c = quot.id;
        qtl1.recordTypeId = recordTypeIdTank;
        qtl1.RFO_QuoteLookup__c=quot.id;
        qtl1.RFO_TransactionType__c='Lease';

        qtl1.RFO_LeaseRate__c = 5000;

        qtl1.RFO_DirSaleQty__c=10;
        qtl1.SBQQ__Product__c =  Product.id;
        return qtl1;
    }
}