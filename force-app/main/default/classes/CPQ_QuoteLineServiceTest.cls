@isTest
public class CPQ_QuoteLineServiceTest {
	@istest
    private static void updateBeforeGroups_Success2(){
        test.startTest();
        SBQQ.TriggerControl.disable();
      // Account Creation        
        List<Account> accList 				= 	new List<Account>();
        accList 							= 	CPQUTILITYTEST.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c 	= 	'14098';
       // accList[0].RFO_OracleId__c 		= 	'123456';
        accList[0].RFO_TASId__c 			= 	'1234';
        database.insert(accList);
        List<Contact> conList 				= 	new List<Contact>();
        conList								= 	CPQUTILITYTEST.createContact1(accList[0]);
        database.insert(conList);
        
        Contract contr = new Contract(AccountId = accList[0].id, RFO_ContractType__c=RFO_Constant.CONTRACT_TYPE_DIRECT_SALE ,
                                      RFO_ContractDate__c=system.today());
        Insert contr;
        //Product Creation
        Product2 prod=RFO_Utility_Test.createProduct();
        prod.IsActive = true;
        Database.insert(prod);
        
        //~~~
        PriceBook2 pb = new Pricebook2();
        pb.Id = Test.getStandardPricebookId();
        pb.IsActive = TRUE;
        update pb;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pb.Id;
        pbe.Product2Id =prod.id;
        pbe.IsActive = true;
        pbe.UnitPrice = 1;
        insert pbe;
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        commodityList 					= CPQUTILITYTEST.createCommodity1();
        Database.insert(commodityList);
        
        //Order Creation
        Order ordr = new Order();
        Id recordTypeIdExistingCar = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get(RFO_Constant.ORDER_EXISTINGCAR).getRecordTypeId();
        RFO_OrderTriggerHandler.triggerDisabled = false;
        ordr.RecordTypeId=recordTypeIdExistingCar;
        ordr.Status=RFO_Constant.INITIATED;
        ordr.AccountId=accList[0].id;
        ordr.Type=RFO_Constant.ORDER_TYPE_DIRECT_SALE;
        ordr.EffectiveDate = Date.newInstance(2020, 01, 25); 
        ordr.RFO_ProposalRequired__c = RFO_Constant.PROPOSAL_REQUIRED;
        ordr.RFO_Commodity_lookup__c=commodityList[0].id;
        ordr.RFO_TankorFreight__c = RFO_Constant.TANK_RECORD_TYPE;
        ordr.RFO_Quantity__c = 5;
        ordr.RFO_CarType__c = RFO_Constant.ORDER_CAR_TYPE;
        ordr.RFO_Product__c = prod.Id;
        database.insert(ordr);
        
        RFO_Rider__c rider2=new RFO_Rider__c();
        rider2=RFO_Utility_Test.createrider();
        rider2.RFO_Account__c=accList[0].id;
        rider2.RFO_Status__c =RFO_Constant.READY_FOR_DELIVERY;
        rider2.RFO_AutoRenewal__c =RFO_Constant.YES;
        rider2.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider2.RFO_RiderType__c = RFO_Constant.RIDER_TYPE;
        rider2.RFO_ProductType__c = RFO_Constant.TEST;
        rider2.RFO_Contract__c=contr.id;
        rider2.RFO_TotalOfCars__c = 2; 
        rider2.RFO_TotalActiveCars__c = 5;
        Database.insert(rider2);
        
        
        
        User userQuoteTeam 							= 	new User();
        userQuoteTeam 								= 	CPQUTILITYTEST.createUserRecordForCPQ();
        //  userQuoteTeam.RFO_Contracts__c 			= 	True;
        userQuoteTeam.RFO_Engineering__c 			= 	True;
        userQuoteTeam.RFO_Estimating__c 			= 	True;
        userQuoteTeam.RFO_PortfolioManagement__c 	= 	True;
        userQuoteTeam.RFO_PricingSummary__c 		= 	True;
        userQuoteTeam.RFO_ProductionPlanning__c 	= 	True;
        userQuoteTeam.RFO_AccountManager__c 		= 	True;
        userQuoteTeam.RFO_Sales__c 					= 	True;
        Database.insert(userQuoteTeam);
        
        List<Opportunity> oppList 	= new List<Opportunity>();
        oppList 					= CPQUTILITYTEST.createTankOpportunities1(accList[0],conList[0]);
        database.insert(oppList);
        
        RFO_QuoteTeams__c quoteTeamRec 	= 	new RFO_QuoteTeams__c(
            Name 						= 	'Test',                               // QuoteTeams Name
            RFO_PortfolioMember__c 		= 	userQuoteTeam.id,  // Portfolio Management
            RFO_EngineeringMember__c 	= 	userQuoteTeam.id,  // Engineering
            RFO_PlanningMember__c 		= 	userQuoteTeam.id,     // Production Planning
            RFO_EstimatingMember__c 	= 	userQuoteTeam.id,   // Estimating
            RFO_PricingMember__c 		= 	userQuoteTeam.id,      // Pricing
            // RFO_ContractsMember__c 	= 	userQuoteTeam.id,    // Contract
            RFO_SalesMember__c 			= 	userQuoteTeam.id,    // Sales
            Region__c					=	'Eastern',
            Type__c						=	'Tank'
        );
        database.insert(quoteTeamRec);
        
        Product2 productRec 	= RFO_Utility_Test.createProduct();
        productRec.isActive  	= true;
        insert productRec;
        // Quote Creation 
        SBQQ__Quote__c quote1 			= 	new SBQQ__Quote__c();
        quote1 							= 	RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
        Id Existing_RecTypeId 			= 	Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_Existing').getRecordTypeId();
        quote1.RFO_QuoteStage__c		=	'In Progress';
        quote1.RecordtypeId				=	Existing_RecTypeId;
        database.insert(quote1); 
        
        quote1.RFO_Product__c = productRec.id;
        quote1.RFO_QuoteStage__c = 'In Progress';
        TriggerDispatcher.isRecurrsiveAfterInsert 	= false;
        TriggerDispatcher.isRecurrsiveAfterUpdate 	= false;
        TriggerDispatcher.isRecurrsiveBeforeInsert 	= false;
        update quote1;
   		
        TriggerDispatcher.isRecurrsiveAfterInsert 	= false;
        TriggerDispatcher.isRecurrsiveAfterUpdate 	= false;
        TriggerDispatcher.isRecurrsiveBeforeInsert 	= false;
    	test.stopTest();
   
    	list<SBQQ__Quote__c> cpqQuote 		= [select id,RecordTypeId,Commercial_Quote__c,RFO_QuoteStage__c,CPQ_Quote__c,RFO_QuoteTeam__c,
                                         		SBQQ__Account__c,RFO_Product__c from SBQQ__Quote__c];
        Map<Id,SBQQ__Quote__c> mapQuotes 	= New Map<Id,SBQQ__Quote__c>();
        for(SBQQ__Quote__c objQuote : cpqQuote){
            mapQuotes.put(objQuote.Id,objQuote);
        }
        CPQ_QuoteService objQuoteHandler 			= New CPQ_QuoteService();
        objQuoteHandler.createCPQQuoteRecords(mapQuotes);
        List<SBQQ__QuoteLine__c> lstQuoteLine 		= New List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine 				= CPQUTILITYTEST.createQuoteLine(cpqQuote[0], productRec);
        lstQuoteLine.add(quoteLine);
        SBQQ__QuoteLine__c existingquoteLine 		= CPQUTILITYTEST.createQuoteLine(cpqQuote[0], productRec);
        lstQuoteLine.add(existingquoteLine);
        insert lstQuoteLine;
        list<SBQQ__QuoteLineGroup__c> groups 	= [select id from SBQQ__QuoteLineGroup__c];
        list<SBQQ__QuoteLine__c> lines 			= [select id,Custom_Group_Id__c,SBQQ__ProductOption__c,ParentLine__c,
                                          			SBQQ__Bundle__c from SBQQ__QuoteLine__c where SBQQ__Quote__c = :cpqQuote[0].id];
      
        //CPQ_QuoteLineService.updateBeforeGroups(lines);
        CPQ_QuoteLineService objQuotelIne 		= 	New CPQ_QuoteLineService();
        objQuotelIne.createAssetGroup(lines);
        objQuotelIne.updateQuantity(lines);
        
         
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = prod.Id;
        objAsset.AccountId = accList[0].Id;
        objAsset.CDX_Last_Shopped_Commodity__c = commodityList[0].Id;
        objAsset.RFO_DateBuilt__c= date.valueOf('2020-01-01');
        objAsset.IRR_Base_Cost__c = 100000.0;
        objAsset.Betterment_Asset_Key__c =500.0;
        objAsset.Residual_Curve_Id__c='3515';
        insert objAsset;
        
        List<Opportunity> oppListRen 	= 	new List<Opportunity>();
        oppListRen 						= 	CPQUTILITYTEST.createRenewalOpportunities(accList[0]);
        oppListRen[0].RFO_RiderID__c  		= rider2.Id;
        database.insert(oppListRen);
        
        RFO_RiderGroup__c  objRiderGroup  		= 	New RFO_RiderGroup__c();
        objRiderGroup.RFO_Rider__c  			= 	rider2.Id;
        objRiderGroup.RFO_RiderGroup__c			= 	'Test Rider Group';
        objRiderGroup.Name						=	'Test Rider Group Name';
        objRiderGroup.RFO_RiderGroupStatus__c	=	'Active';	
        insert objRiderGroup;
        
        RFO_RiderGroupAsset__c  objRiderGroupAsset =  New RFO_RiderGroupAsset__c();
        objRiderGroupAsset.RFO_Account__c		=	accList[0].Id;
        //objRiderGroupAsset.RFO_Active__c		= 	true;
        objRiderGroupAsset.RFO_Asset__c			=	objAsset.Id;
        objRiderGroupAsset.RFO_BeginChargeDate__c 	= system.today()-5;
        objRiderGroupAsset.RFO_EndChargeDate__c  	= system.today()+5;
        objRiderGroupAsset.RFO_RiderGroup__c	= 	objRiderGroup.Id;
        insert objRiderGroupAsset;
        SBQQ__Quote__c renewlQuote = New SBQQ__Quote__c();
        
        renewlQuote 	= 	CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQNoSkipValidation(oppListRen[0], 
                                                                                               quoteTeamRec,
                                                                                               productRec, 
                                                                                              'Renewal');
        Insert renewlQuote;
        List<SBQQ__QuoteLine__c> lstQuoteLineRenew 		= New List<SBQQ__QuoteLine__c>();
        //Renewals
        Id QuoyteLIneRenTypeId 							= 	Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('RFO_Renewals').getRecordTypeId();
        SBQQ__QuoteLine__c quoteLineRen 				= CPQUTILITYTEST.createQuoteLine(renewlQuote, productRec);
        quoteLineRen.RecordTypeId 						= QuoyteLIneRenTypeId;
        lstQuoteLineRenew.add(quoteLineRen);
        SBQQ__QuoteLine__c RenwalQuLine 				= CPQUTILITYTEST.createQuoteLine(renewlQuote, productRec);
        RenwalQuLine.RecordTypeId 						= QuoyteLIneRenTypeId;
        lstQuoteLineRenew.add(RenwalQuLine);
        insert lstQuoteLineRenew;
        Map<Id,SBQQ__QuoteLine__c> mapLinesRen 	= New Map<Id,SBQQ__QuoteLine__c>();
        list<Asset_Group__c> lstAssetGroups  = New List<Asset_Group__c>();
        for(SBQQ__QuoteLine__c objLine:lstQuoteLineRenew){
            Asset_Group__c  objGroup  = New Asset_Group__c();
            objGroup.Quote_Line__c = objLine.Id;
            objGroup.Opportunity__c	= oppListRen[0].Id;
            lstAssetGroups.add(objGroup);
           // lstQuoteLineRenew
            mapLinesRen.put(objLine.Id,objLine);
        }
        Insert lstAssetGroups;
         Product2 objProduct = CPQUTILITYTEST.createProduct();
        objProduct.RFO_ModelId__c ='1234';
        
        insert objProduct;
         User u = CPQUTILITYTEST.createUserRecordForCPQ();
        insert u;
        //account acct = CPQUTILITYTEST.createProspectAccounts()[0];
        //acct.RFO_AccountOwner__c  = u.name;
        //acct.OwnerId = u.id;
		//insert acct;
        
        
        //depreciation detailsLs
        List<Residual_Curve__c> rcs = new List<Residual_Curve__c>();
        List<Residual_Betterment__c> rbs = new List<Residual_Betterment__c>();
        DateTime accountingDate = date.valueOf('2020-12-31');
       
        for(integer g=1;g<10;g++){
            decimal d = decimal.valueOf(g);
            Residual_Curve__c rc = new Residual_Curve__c();
            rc.Residual_Curve_ID__c = objAsset.Residual_Curve_Id__c;
            rc.Residual_Percent__c = (1-(d/100));
            rc.Age_In_Months__c = g+10;
            system.debug('creating rc record '+rc);
            rcs.add(rc);
            
            Residual_Betterment__c rb= new Residual_Betterment__c();
            
            rb.Betterment_Asset_Key__c =  objAsset.Betterment_Asset_Key__c;
            rb.Accounting_Period__c =decimal.valueOf(accountingDate.year()+''+accountingDate.format('MM')+''+accountingDate.day());
            
            rb.Original_Betterment_Value__c = 5945.66;
            rb.Residual_Betterment_Value__c = rb.Original_Betterment_Value__c * rc.Residual_Percent__c;
            system.debug('creating rb record '+rb);
            rbs.add(rb);
            accountingDate = accountingDate.addMonths(1);
        }
        
        insert rcs;
        insert rbs;
        
        List<Assumed_Maintenance__c> ams = new List<Assumed_Maintenance__c>();
        
        Assumed_Maintenance__c am = new Assumed_Maintenance__c();
        
        am.Model_Id__c =  objProduct.RFO_ModelId__c;
        am.Lease_Type__c ='FULL SERVICE LEASE';
        am.Monthly_Maintenance_Amount__c=90.0;
        ams.add(am);
        
        Assumed_Maintenance__c am1 = new Assumed_Maintenance__c();
        
        am1.Model_Id__c =  objProduct.RFO_ModelId__c;
        am1.Lease_Type__c ='NET LEASE';
        am1.Monthly_Maintenance_Amount__c=00.0;
        ams.add(am1);
        
        insert ams; 
        List<asset_lines__c> lstAsslines = New List<asset_lines__c>();
        for(Asset_Group__c objAsGroup : lstAssetGroups){
            asset_lines__c objAssLine  = New asset_lines__c();
            objAssLine.Asset_Group__c 	= objAsGroup.Id;
            objAssLine.Asset__c  		= 	objAsset.Id;
            lstAsslines.add(objAssLine);
        }
        Insert lstAsslines;
        
        CPQ_QuoteLineService objQl = New CPQ_QuoteLineService();
        //objQl.createAssetGroupFromRider(mapLinesRen);
    }	
    @istest
    private static void updateBeforeGroups_Success3(){
        test.startTest();
      // Account Creation        
        List<Account> accList 				= new List<Account>();
        accList 							= CPQUTILITYTEST.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c 	= '14098';
       // accList[0].RFO_OracleId__c 		= '123456';
        accList[0].RFO_TASId__c 			= '1234';
        database.insert(accList);
        List<Contact> conList 				= new List<Contact>();
        conList								= CPQUTILITYTEST.createContact1(accList[0]);
        database.insert(conList);
        
        User userQuoteTeam 							= new User();
        userQuoteTeam 								= CPQUTILITYTEST.createUserRecordForCPQ();
        //  userQuoteTeam.RFO_Contracts__c 			= True;
        userQuoteTeam.RFO_Engineering__c 			= True;
        userQuoteTeam.RFO_Estimating__c 			= True;
        userQuoteTeam.RFO_PortfolioManagement__c 	= True;
        userQuoteTeam.RFO_PricingSummary__c 		= True;
        userQuoteTeam.RFO_ProductionPlanning__c 	= True;
        userQuoteTeam.RFO_AccountManager__c 		= True;
        userQuoteTeam.RFO_Sales__c 					= True;
        Database.insert(userQuoteTeam);
        
        List<Opportunity> oppList 	= new List<Opportunity>();
        oppList 					= CPQUTILITYTEST.createTankOpportunities1(accList[0],conList[0]);
        database.insert(oppList);
        
        RFO_QuoteTeams__c quoteTeamRec 	= 	new RFO_QuoteTeams__c(
            Name 						= 	'Test',                               // QuoteTeams Name
            RFO_PortfolioMember__c 		= 	userQuoteTeam.id,  // Portfolio Management
            RFO_EngineeringMember__c 	= 	userQuoteTeam.id,  // Engineering
            RFO_PlanningMember__c 		= 	userQuoteTeam.id,     // Production Planning
            RFO_EstimatingMember__c 	= 	userQuoteTeam.id,   // Estimating
            RFO_PricingMember__c 		= 	userQuoteTeam.id,      // Pricing
            // RFO_ContractsMember__c 	= 	userQuoteTeam.id,    // Contract
            RFO_SalesMember__c 			= 	userQuoteTeam.id,    // Sales
            Region__c					=	'Eastern',
            Type__c						=	'Tank'
        );
        database.insert(quoteTeamRec);
        
        Product2 productRec = RFO_Utility_Test.createProduct();
        productRec.isActive  = true;
        insert productRec;
        // Quote Creation 
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,productRec,'CPQ');
        //Id Existing_RecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_Existing').getRecordTypeId();
        quote1.RFO_QuoteStage__c='In Progress';
        //quote1.RecordtypeId=Existing_RecTypeId;
        database.insert(quote1); 
        
        quote1.RFO_Product__c 						= productRec.id;
        quote1.RFO_QuoteStage__c 					= 'In Progress';
        TriggerDispatcher.isRecurrsiveAfterInsert 	= false;
        TriggerDispatcher.isRecurrsiveAfterUpdate 	= false;
        TriggerDispatcher.isRecurrsiveBeforeInsert 	= false;
        update quote1;
   		
        TriggerDispatcher.isRecurrsiveAfterInsert 	= false;
        TriggerDispatcher.isRecurrsiveAfterUpdate 	= false;
        TriggerDispatcher.isRecurrsiveBeforeInsert 	= false;
    	test.stopTest();
   
    	list<SBQQ__Quote__c> cpqQuote 		= [select id,RecordTypeId,Commercial_Quote__c,RFO_QuoteStage__c,CPQ_Quote__c,RFO_QuoteTeam__c,
                                         		SBQQ__Account__c,RFO_Product__c from SBQQ__Quote__c];
        Map<Id,SBQQ__Quote__c> mapQuotes 	= New Map<Id,SBQQ__Quote__c>();
        for(SBQQ__Quote__c objQuote : cpqQuote){
            mapQuotes.put(objQuote.Id,objQuote);
        }
        CPQ_QuoteService objQuoteHandler = New CPQ_QuoteService();
        objQuoteHandler.createCPQQuoteRecords(mapQuotes);
         List<SBQQ__QuoteLine__c> lstQuoteLine = New List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine = CPQUTILITYTEST.createQuoteLine(cpqQuote[0], productRec);
        lstQuoteLine.add(quoteLine);
        SBQQ__QuoteLine__c existingquoteLine = CPQUTILITYTEST.createQuoteLine(cpqQuote[0], productRec);
        lstQuoteLine.add(existingquoteLine);
        insert lstQuoteLine;
        list<SBQQ__QuoteLineGroup__c> groups = [select id from SBQQ__QuoteLineGroup__c];
        list<SBQQ__QuoteLine__c> lines = [select id,Custom_Group_Id__c,SBQQ__ProductOption__c,ParentLine__c,
                                          SBQQ__Bundle__c from SBQQ__QuoteLine__c where SBQQ__Quote__c = :cpqQuote[0].id];
      
        //CPQ_QuoteLineService.updateBeforeGroups(lines);
        CPQ_QuoteLineService objQuotelIne = New CPQ_QuoteLineService();
        objQuotelIne.createAssetGroup(lines);
        objQuotelIne.updateQuantity(lines);
    }
}