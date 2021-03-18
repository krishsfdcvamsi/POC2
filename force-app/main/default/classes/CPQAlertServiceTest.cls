@isTest
public class CPQAlertServiceTest {
    private static Id qlrecordType_TRNTank= Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('RFO_Tank').getRecordTypeId();
    private static Id qlRecordType_CPQ  = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('CPQ_Config').getRecordTypeId();
	@testsetup static void createOptyTestdata(){
    	SBQQ.TriggerControl.disable();
        User u = CPQUTILITYTEST.createUserRecordForCPQ();
        insert u;
        List<account> lstAccs = New List<account>();
         //account acct = CPQUTILITYTEST.createProspectAccounts();
        for(account objAcc : CPQUTILITYTEST.createProspectAccounts()){
            objAcc.RFO_AccountOwner__c  = u.name;
        	objAcc.OwnerId = u.id;
            lstAccs.add(objAcc);
        }
        //account acct2 = CPQUTILITYTEST.createProspectAccounts()[0];
        //acct2.RFO_AccountOwner__c  = u.name;
        //acct2.OwnerId = u.id;
        //lstAccs.add(acct2);
        insert lstAccs;
        //need to remove irr components
        //two accounts..
        //two quotes--
        //Asset -- Commited.
        //one account...negative.test cases...
        //account a1=  
        List<Account> lstAccA1 		= [select id,Name,RFO_AccountOwner__c,owner.id from account];
        List<Contact> contactList 	= new List<Contact>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        contactList 					= CPQUTILITYTEST.createContact1(lstAccA1[0]);
        Database.insert(contactList);
        commodityList 					= CPQUTILITYTEST.createCommodity1();
        Database.insert(commodityList);
        Product2 objProduct 			= CPQUTILITYTEST.createProduct();
        objProduct.RFO_ModelId__c ='1234';
        insert objProduct;
        List<RFO_Commodity__c> lstCommi =  CPQUTILITYTEST.createCommodity1();
        insert lstCommi;
        List<Asset> lstAssets  						= New List<Asset>();
        lstAssets.add(CPQUTILITYTEST.createAsset(commodityList[0].Id,'TestAsset',objProduct.Id,lstAccA1[0]));
        lstAssets.add(CPQUTILITYTEST.createAsset(commodityList[0].Id,'TestAsset2',objProduct.Id,lstAccA1[1]));
        insert lstAssets;
        //rest
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(lstAccA1[0], contactList[0]);
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        test.startTest();
        SBQQ__Quote__c cpqQuote, existingQuote,cpqQuote2;
        //test.startTest();
        existingQuote = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objProduct, 'Existing');
        existingquote.RFO_Quantity__c 	= 100;
        existingQuote.SBQQ__Account__c	=lstAccA1[0].id;
        insert existingQuote;
        cpqQuote =CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQNoSkipValidation(oppList[0], quoteTeamRec,objProduct, 'CPQ');
        cpqQuote.Commercial_Quote__c 	= existingQuote.Id;
        cpqQuote.SBQQ__Account__c 		= lstAccA1[0].id;
        insert cpqQuote;
        cpqQuote2 =CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQNoSkipValidation(oppList[0], quoteTeamRec,objProduct, 'CPQ');
        cpqQuote2.Commercial_Quote__c 	= existingQuote.Id;
        cpqQuote2.SBQQ__Account__c 		= lstAccA1[0].id;
        insert cpqQuote2;
        test.stopTest();
        system.assertEquals(cpqQuote.Commercial_Quote__c, existingQuote.Id);
        //cpq line
        List<SBQQ__QuoteLine__c> lstQuotelines = New List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c cpqLine 			=  	CPQUTILITYTEST.createQuoteLine(cpqQuote,objProduct);
        cpqLine.RecordTypeId 				=	qlRecordType_CPQ;
        lstQuotelines.add(cpqLine);
        //insert cpqLine;
        SBQQ__QuoteLine__c cpqLine2 		=  	CPQUTILITYTEST.createQuoteLine(cpqQuote2,objProduct);
        cpqLine2.RecordTypeId 				=	qlRecordType_CPQ;
        lstQuotelines.add(cpqLine2);
        //insert cpqLine2;
        //qli.add(cpqLine2);
        insert lstQuotelines;
        List<Asset_Group__c> ags = new list<Asset_Group__c>();
        for(integer i =0;i<5;i++){
            Asset_Group__c ag = New Asset_Group__c();
            ag.Quote_Line__c = lstQuotelines[0].Id;
            ags.add(ag);
        }
         List<Asset_Group__c> ags2 = new list<Asset_Group__c>();
        for(integer i =0;i<5;i++){
            Asset_Group__c ag = New Asset_Group__c();
            ag.Quote_Line__c = lstQuotelines[1].Id;
            ags2.add(ag);
        } 
        insert ags;
        insert ags2;
        List<Asset_Lines__c> als = new list<Asset_Lines__c>();
        List<Asset> lstAssetsDuo =  [SELECT Id FROM Asset];
        system.debug('lstAssetsDuo>>>>>'+lstAssetsDuo.size());
        for(Asset_Group__c a : ags){
            for(integer b = 0; b<10; b++){
                Asset_Lines__c al 		=  New Asset_Lines__c();
                al.Asset__c 			= lstAssetsDuo[0].Id;
                al.Asset_Group__c 		= a.Id;
                als.add(al);
            }
            
        }
        List<Asset_Lines__c> als2 = new list<Asset_Lines__c>();
        for(Asset_Group__c a : ags2){
            for(integer b = 0; b<10; b++){
                Asset_Lines__c al 		=  New Asset_Lines__c();
                al.Asset__c 			= lstAssetsDuo[1].Id;
                al.Asset_Group__c 		= a.Id;
                als2.add(al);
            }
            
        }
        insert als;
        insert als2;
        
        
        account objAccOnAcc = CPQUTILITYTEST.createProspectAccounts()[0];
        insert objAccOnAcc;
        Contact  contactListOnAcc	= CPQUTILITYTEST.createContact1(objAccOnAcc)[0];
        insert contactListOnAcc;
        List<RFO_Commodity__c> commodityOneList = new List<RFO_Commodity__c>();
        commodityOneList 					= CPQUTILITYTEST.createCommodity1();
        Database.insert(commodityOneList);
        Product2 objProOneduct 			= CPQUTILITYTEST.createProduct();
        objProOneduct.RFO_ModelId__c 	='1235';
        insert objProOneduct;
        List<RFO_Commodity__c> lstCommiOne =  CPQUTILITYTEST.createCommodity1();
        insert lstCommiOne;
        
        Asset  objAsset = CPQUTILITYTEST.createAsset(commodityList[0].Id,'OnAccountAsset',objProduct.Id,objAccOnAcc);
        insert objAsset;
        
        
        Opportunity objOneOppo = CPQUTILITYTEST.createTankOpportunities1(objAccOnAcc, contactListOnAcc)[0];
        insert objOneOppo;
        RFO_QuoteTeams__c quoteTeamRecOne = new RFO_QuoteTeams__c();
        quoteTeamRecOne = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRecOne);
        
        SBQQ__Quote__c cpqQuote1, cpqQuote3;
        //test.startTest();
       
        cpqQuote1 =CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQNoSkipValidation(oppList[0], quoteTeamRec,objProduct, 'CPQ');
        cpqQuote1.Commercial_Quote__c 	= existingQuote.Id;
        cpqQuote1.SBQQ__Account__c 		= lstAccA1[0].id;
        insert cpqQuote1;
        cpqQuote3 =CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQNoSkipValidation(oppList[0], quoteTeamRec,objProduct, 'CPQ');
        cpqQuote3.Commercial_Quote__c 	= existingQuote.Id;
        cpqQuote3.SBQQ__Account__c 		= lstAccA1[0].id;
        insert cpqQuote3;
        /*
        SBQQ__QuoteLine__c cpqLine1 	=  	CPQUTILITYTEST.createQuoteLine(cpqQuote1,objProOneduct);
        cpqLine1.RecordTypeId 			=	qlRecordType_CPQ;
        SBQQ.TriggerControl.disable();
        insert cpqLine1;
        SBQQ__QuoteLine__c cpqLine3 	=  	CPQUTILITYTEST.createQuoteLine(cpqQuote3,objProOneduct);
        cpqLine3.RecordTypeId 			=	qlRecordType_CPQ;
        insert cpqLine3;
        Asset_Group__c agOne 			= New Asset_Group__c();
        agOne.Quote_Line__c 			= cpqLine1.Id;
        insert agOne;
        
        Asset_Group__c agOne2 	= New Asset_Group__c();
        agOne2.Quote_Line__c 	= cpqLine3.Id;
        insert agOne2;
        
        List<Asset_Lines__c> als3 = new list<Asset_Lines__c>();
        for(integer b = 0; b<5; b++){
                Asset_Lines__c alsss 		=  New Asset_Lines__c();
                alsss.Asset__c 				= objAsset.Id;
                alsss.Asset_Group__c 		= agOne.Id;
                als3.add(alsss);
            }
        List<Asset_Lines__c> als4 = new list<Asset_Lines__c>();
        for(integer b = 0; b<5; b++){
                Asset_Lines__c alsss 		=  New Asset_Lines__c();
                alsss.Asset__c 				= objAsset.Id;
                alsss.Asset_Group__c 		= agOne2.Id;
                als4.add(alsss);
            }
         insert als3;
         insert als4;
		*/
   }
   private static testMethod void processCommittedAssetsAlertsTest(){
        test.startTest();
     	List<asset_lines__c> lstAssetLines = [SELECT id, name, asset__c,asset__r.Name, asset_Group__r.quote_line__r.SBQQ__Quote__c,
                                                asset_Group__r.quote_line__r.SBQQ__Quote__r.sbqq__account__r.name,
                                                asset_Group__r.quote_line__r.SBQQ__Quote__r.commercial_quote__c, 
                                              	asset__r.RFO_CommittedTo__c
                                                FROM asset_lines__c 
                                                WHERE asset__r.Name ='TestAsset' 
                                              	OR asset__r.Name ='TestAsset2'];
       Set<String> setCPQQuoteIds = New Set<String>();
       for(SBQQ__Quote__c objCPQQuote : [SELECT Id FROM SBQQ__Quote__c Where RecordType.Name='CPQ']){
           setCPQQuoteIds.add(objCPQQuote.Id);
       }
       List<Alert__c> lstAlerts = [SELECT Id FROM Alert__c WHERE Related_To__c IN:setCPQQuoteIds];
       List<Task> lstTasks 		= [SELECT Id FROM Task WHERE WhatId IN:setCPQQuoteIds];
       System.assertEquals(0 , lstAlerts.size() );
       System.assertEquals(0 , lstTasks.size() );
       //assert there are no tasks or alerts.
       CPQAlertService.processCommittedAssetsAlerts(lstAssetLines);
       List<Alert__c> lstAlerts2 = [SELECT Id FROM Alert__c WHERE Related_To__c IN:setCPQQuoteIds];
       System.assertEquals(0, lstAlerts2.size());
       List<Task> lstTasks2 = [SELECT Id FROM Task WHERE WhatId IN:setCPQQuoteIds];
       System.assertEquals(0 , lstTasks2.size() );
       
       CPQAlertService.processCommittedAssetsAlerts(lstAssetLines); 
       
       List<Alert__c> lstAlerts4 = [SELECT Id FROM Alert__c WHERE Related_To__c IN:setCPQQuoteIds];
       //System.assertEquals(1, lstAlerts4.size());
       List<Task> lstTasks4 = [SELECT Id FROM Task WHERE WhatId IN:setCPQQuoteIds];
       //System.assertEquals(1 , lstTasks4.size() );
       
       
       database.executeBatch(new BatchJobsController('AssetCommitted'));
       /*
       List<asset_lines__c> lstAssetLines2 =  New List<asset_lines__c>();
       Set<String> quoteIds = New set<String>();
       for(asset_lines__c objAssetLine:[SELECT id, name, asset__c, asset_Group__r.quote_line__r.SBQQ__Quote__c,
                                                asset_Group__r.quote_line__r.SBQQ__Quote__r.sbqq__account__r.name,
                                                asset_Group__r.quote_line__r.SBQQ__Quote__r.commercial_quote__c, 
                                              	asset__r.RFO_CommittedTo__c
                                                FROM asset_lines__c Where asset__r.Name='OnAccountAsset']){
           lstAssetLines2.add(objAssetLine);
           quoteIds.add(objAssetLine.asset_Group__r.quote_line__r.SBQQ__Quote__c);
       }
       List<Alert__c> lstAlerts3 = [SELECT Id FROM Alert__c WHERE Related_To__c IN:quoteIds];
       System.assertEquals(0, lstAlerts2.size());
       List<Task> lstTasks3 = [SELECT Id FROM Task WHERE WhatId IN:quoteIds];
       System.assertEquals(0 , lstTasks2.size() );
       
       CPQAlertService.processCommittedAssetsAlerts(lstAssetLines); 
       List<Alert__c> lstAlerts5 = [SELECT Id FROM Alert__c WHERE Related_To__c IN:quoteIds];
       System.assertEquals(0, lstAlerts2.size());
       List<Task> lstTasks5 = [SELECT Id FROM Task WHERE WhatId IN:quoteIds];
       System.assertEquals(0 , lstTasks2.size() );
       */
       test.stopTest();
       //assert that corrrect number of alerts and tasks were created.
     }
    	//test negative use case
    	//
    	//two quotes, one account, asset committed
    	//assert that no alerts exist
    	//run the code
    	//assert that no alerts exist
    /*
    private static testMethod void processCommittedAssetsAlertsTest2(){
    	SBQQ.TriggerControl.disable();
        User u = CPQUTILITYTEST.createUserRecordForCPQ();
        insert u;
        account objAcc = CPQUTILITYTEST.createProspectAccounts()[0];
        Insert objAcc;
        List<Contact> contactList 	= new List<Contact>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        contactList 					= CPQUTILITYTEST.createContact1(objAcc);
        Database.insert(contactList);
        commodityList 					= CPQUTILITYTEST.createCommodity1();
        Database.insert(commodityList);
        Product2 objProduct 			= CPQUTILITYTEST.createProduct();
        objProduct.RFO_ModelId__c ='1234';
        insert objProduct;
        List<RFO_Commodity__c> lstCommi =  CPQUTILITYTEST.createCommodity1();
        insert lstCommi;
        List<Asset> lstAssets  						= New List<Asset>();
        lstAssets.add(CPQUTILITYTEST.createAsset(commodityList[0].Id,'TestAsset',objProduct.Id,objAcc));
        lstAssets.add(CPQUTILITYTEST.createAsset(commodityList[0].Id,'TestAsset2',objProduct.Id,objAcc));
        insert lstAssets;
        //rest
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(objAcc, contactList[0]);
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        test.startTest();
        SBQQ__Quote__c cpqQuote, existingQuote,cpqQuote2;
        //test.startTest();
        existingQuote = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objProduct, 'Existing');
        existingquote.RFO_Quantity__c 	= 100;
        existingQuote.SBQQ__Account__c	=objAcc.id;
        insert existingQuote;
        cpqQuote =CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQNoSkipValidation(oppList[0], quoteTeamRec,objProduct, 'CPQ');
        cpqQuote.Commercial_Quote__c 	= existingQuote.Id;
        cpqQuote.SBQQ__Account__c 		= objAcc.id;
        insert cpqQuote;
        cpqQuote2 =CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQNoSkipValidation(oppList[0], quoteTeamRec,objProduct, 'CPQ');
        cpqQuote2.Commercial_Quote__c 	= existingQuote.Id;
        cpqQuote2.SBQQ__Account__c 		= objAcc.id;
        insert cpqQuote2;
        test.stopTest();
        system.assertEquals(cpqQuote.Commercial_Quote__c, existingQuote.Id);
        //cpq line
        SBQQ__QuoteLine__c cpqLine 			=  	CPQUTILITYTEST.createQuoteLine(cpqQuote,objProduct);
        cpqLine.RecordTypeId 				=	qlRecordType_CPQ;
        insert cpqLine;
        SBQQ__QuoteLine__c cpqLine2 		=  	CPQUTILITYTEST.createQuoteLine(cpqQuote2,objProduct);
        cpqLine2.RecordTypeId 				=	qlRecordType_CPQ;
        insert cpqLine2;
        //qli.add(cpqLine2);
        List<Asset_Group__c> ags = new list<Asset_Group__c>();
        for(integer i =0;i<5;i++){
            Asset_Group__c ag = New Asset_Group__c();
            ag.Quote_Line__c = cpqLine.Id;
            ags.add(ag);
        }
         List<Asset_Group__c> ags2 = new list<Asset_Group__c>();
        for(integer i =0;i<5;i++){
            Asset_Group__c ag = New Asset_Group__c();
            ag.Quote_Line__c = cpqLine2.Id;
            ags2.add(ag);
        } 
        insert ags;
        insert ags2;
        List<Asset_Lines__c> als = new list<Asset_Lines__c>();
        List<Asset> lstAssetsDuo =  [SELECT Id FROM Asset];
        system.debug('lstAssetsDuo>>>>>'+lstAssetsDuo.size());
        for(Asset_Group__c a : ags){
            for(integer b = 0; b<10; b++){
                Asset_Lines__c al 		=  New Asset_Lines__c();
                al.Asset__c 			= lstAssetsDuo[0].Id;
                al.Asset_Group__c 		= a.Id;
                als.add(al);
            }
            
        }
        
        List<Asset_Lines__c> als2 = new list<Asset_Lines__c>();
        for(Asset_Group__c a : ags2){
            for(integer b = 0; b<10; b++){
                Asset_Lines__c al 		=  New Asset_Lines__c();
                al.Asset__c 			= lstAssetsDuo[1].Id;
                al.Asset_Group__c 		= a.Id;
                als2.add(al);
            }
            
        }
        insert als;
        insert als2;
    }
	*/
}