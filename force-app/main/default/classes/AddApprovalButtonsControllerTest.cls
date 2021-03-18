@isTest
public class AddApprovalButtonsControllerTest {
    @testsetup static void createOptyTestdata(){
        List<Account> accList = new List<Account>();
        accList = CPQUTILITYTEST.createProspectAccounts();
        Database.insert(accList);
        List<Contact> contactList = new List<Contact>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        contactList = CPQUTILITYTEST.createContact1(accList[0]);
        Database.insert(contactList);
        commodityList = CPQUTILITYTEST.createCommodity1();
        Database.insert(commodityList);
        Product2 objProducr = CPQUTILITYTEST.createProduct();
        insert objProducr;
        List<RFO_Commodity__c> lstCommi =  CPQUTILITYTEST.createCommodity1();
        insert lstCommi;
    }
    //breaking approvals into several tests to reduce CPU time. 
    private static testMethod void APApprove_InventoryReview_PricingApproval(){
        
        Account accRec = [select id, name,OwnerId from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Product2 objPro = [select id, name from Product2 Limit 1];
        RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = objPro.Id;
        objAsset.AccountId = accRec.Id;
        objAsset.RFO_CarType__c = 'Test Car Type';
        objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
        insert objAsset;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
        //oppList[0].Quote_UI__c = '';
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        SBQQ__Quote__c commercialQuote = new SBQQ__Quote__c();
        SBQQ__Quote__c quote3 = new SBQQ__Quote__c();
        commercialQuote = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'Existing');
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
        commercialQuote.RFO_FleetOpsDeliveryTime__c = 'Today';
        commercialQuote.RFO_PurchaseOptions__c = 'YES';
        commercialQuote.RFO_EarlyTermination__c = 'Yes';
        commercialQuote.RFO_NonStandardTerms__c =  'No';
        commercialQuote.RFO_DeliveryLocation__c =  'Yes';
        commercialQuote.RFO_FirstCarShipDays__c =  '10';
        commercialQuote.RFO_Allowable_Annual_Mileage__c = 10;
        commercialQuote.RFO_ExcessMileageFee__c = 5000.0;
        insert commercialQuote;
        quote1.Commercial_Quote__c = commercialQuote.id;
        quote1.CPQ_Status__c = 'Pricing';
        insert quote1;
        Test.startTest();
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(quote1.Id);
        app.setProcessDefinitionNameOrId('CPQ_SLAProcess');
        Approval.ProcessResult result = Approval.process(app);
        
        AddApprovalButtonsController.approve(quote1.Id,true);
        SBQQ__QuoteLine__c quoteLine =  CPQUTILITYTEST.createQuoteLine(quote1,objPro);
        insert quoteLine;
        SBQQ__Quote__c quote2 = [SELECT CPQ_Status__c,SBQQ__LineItemCount__c,
                                 Need_Config_Count__c,Skipp_GapProcess__c,
                                 Commercial_Quote__r.RFO_FleetOpsDeliveryTime__c,
                                 Commercial_Quote__r.RFO_PurchaseOptions__c,
                                 Commercial_Quote__r.RFO_EarlyTermination__c,
                                 Commercial_Quote__r.RFO_NonStandardTerms__c,
                                 Commercial_Quote__r.RFO_DeliveryLocation__c,
                                 Commercial_Quote__r.RFO_FirstCarShipDays__c,
                                 Commercial_Quote__r.RFO_Allowable_Annual_Mileage__c,
                                 
                                 
                                 Commercial_Quote__r.RFO_ExcessMileageFee__c,
                                 Commercial_Quote__r.Freight_Charge__c
                                 
                                 
                                 FROM SBQQ__Quote__c WHERE Id=:Quote1.Id];
        
        quote2.CPQ_Status__c = 'Inventory Review';
        update quote2;
        AddApprovalButtonsController.approve(quote2.Id,true);
        
        AddApprovalButtonsController.approve(quote2.Id,true);
        AddApprovalButtonsController.rejectRecord(quote2.Id,true);
        
        
        System.assert(true);
        Test.stopTest();
    }
    private static testMethod void APApprove_Pricing_Engineering(){
        
        Account accRec = [select id, name,OwnerId from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Product2 objPro = [select id, name from Product2 Limit 1];
        RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = objPro.Id;
        objAsset.AccountId = accRec.Id;
        objAsset.RFO_CarType__c = 'Test Car Type';
        objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
        insert objAsset;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
        //oppList[0].Quote_UI__c = '';
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        SBQQ__Quote__c commercialQuote = new SBQQ__Quote__c();
        SBQQ__Quote__c quote3 = new SBQQ__Quote__c();
        commercialQuote = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'Existing');
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
        commercialQuote.RFO_FleetOpsDeliveryTime__c = 'Today';
        commercialQuote.RFO_PurchaseOptions__c = 'YES';
        commercialQuote.RFO_EarlyTermination__c = 'Yes';
        commercialQuote.RFO_NonStandardTerms__c =  'No';
        commercialQuote.RFO_DeliveryLocation__c =  'Yes';
        commercialQuote.RFO_FirstCarShipDays__c =  '10';
        commercialQuote.RFO_Allowable_Annual_Mileage__c = 10;
        commercialQuote.RFO_ExcessMileageFee__c = 5000.0;
        insert commercialQuote;
        quote1.Commercial_Quote__c = commercialQuote.id;
        insert quote1;
        Test.startTest();
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(quote1.Id);
        app.setProcessDefinitionNameOrId('CPQ_SLAProcess');
        Approval.ProcessResult result = Approval.process(app);
        AddApprovalButtonsController.approve(quote1.Id,true);
        SBQQ__QuoteLine__c quoteLine =  CPQUTILITYTEST.createQuoteLine(quote1,objPro);
        insert quoteLine;
        SBQQ__Quote__c quote2 = [SELECT CPQ_Status__c,SBQQ__LineItemCount__c,
                                 Need_Config_Count__c,Skipp_GapProcess__c,
                                 Commercial_Quote__r.RFO_FleetOpsDeliveryTime__c,
                                 Commercial_Quote__r.RFO_PurchaseOptions__c,
                                 Commercial_Quote__r.RFO_EarlyTermination__c,
                                 Commercial_Quote__r.RFO_NonStandardTerms__c,
                                 Commercial_Quote__r.RFO_DeliveryLocation__c,
                                 Commercial_Quote__r.RFO_FirstCarShipDays__c,
                                 Commercial_Quote__r.RFO_Allowable_Annual_Mileage__c,
                                 
                                 
                                 Commercial_Quote__r.RFO_ExcessMileageFee__c,
                                 Commercial_Quote__r.Freight_Charge__c
                                 
                                 
                                 FROM SBQQ__Quote__c WHERE Id=:Quote1.Id];
        
        quote2.CPQ_Status__c = 'Pricing';
        update quote2;
        AddApprovalButtonsController.approve(quote2.Id,true);
        
        quote2.CPQ_Status__c = 'Engineering';
        update quote2;
        AddApprovalButtonsController.approve(quote2.Id,true);
        AddApprovalButtonsController.approve(quote2.Id,true);
        
        
        Test.stopTest();
    }
     private static testMethod void APApprove_Pricing_HandleRequiredFieldsmissing(){
        
        Account accRec = [select id, name,OwnerId from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Product2 objPro = [select id, name from Product2 Limit 1];
        RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = objPro.Id;
        objAsset.AccountId = accRec.Id;
        objAsset.RFO_CarType__c = 'Test Car Type';
        objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
        insert objAsset;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
        //oppList[0].Quote_UI__c = '';
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        SBQQ__Quote__c commercialQuote = new SBQQ__Quote__c();
        SBQQ__Quote__c quote3 = new SBQQ__Quote__c();
        commercialQuote = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'Existing');
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
       // commercialQuote.RFO_FleetOpsDeliveryTime__c = 'Today';
        commercialQuote.RFO_PurchaseOptions__c = 'YES';
       /* commercialQuote.RFO_EarlyTermination__c = 'Yes';
        commercialQuote.RFO_NonStandardTerms__c =  'No';
        commercialQuote.RFO_DeliveryLocation__c =  'Yes';
        commercialQuote.RFO_FirstCarShipDays__c =  '10';*/
        commercialQuote.RFO_Allowable_Annual_Mileage__c = 10;
        commercialQuote.RFO_ExcessMileageFee__c = 5000.0;
        insert commercialQuote;
        quote1.Commercial_Quote__c = commercialQuote.id;
        insert quote1;
        Test.startTest();
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(quote1.Id);
         app.setProcessDefinitionNameOrId('CPQ_SLAProcess');
        Approval.ProcessResult result = Approval.process(app);
        AddApprovalButtonsController.approve(quote1.Id,true);
        SBQQ__QuoteLine__c quoteLine =  CPQUTILITYTEST.createQuoteLine(quote1,objPro);
        insert quoteLine;
        SBQQ__Quote__c quote2 = [SELECT CPQ_Status__c,SBQQ__LineItemCount__c,
                                 Need_Config_Count__c,Skipp_GapProcess__c,
                                 Commercial_Quote__r.RFO_FleetOpsDeliveryTime__c,
                                 Commercial_Quote__r.RFO_PurchaseOptions__c,
                                 Commercial_Quote__r.RFO_EarlyTermination__c,
                                 Commercial_Quote__r.RFO_NonStandardTerms__c,
                                 Commercial_Quote__r.RFO_DeliveryLocation__c,
                                 Commercial_Quote__r.RFO_FirstCarShipDays__c,
                                 Commercial_Quote__r.RFO_Allowable_Annual_Mileage__c,
                                 
                                 
                                 Commercial_Quote__r.RFO_ExcessMileageFee__c,
                                 Commercial_Quote__r.Freight_Charge__c
                                 
                                 
                                 FROM SBQQ__Quote__c WHERE Id=:Quote1.Id];
        
        quote2.CPQ_Status__c = 'Pricing';
        update quote2;
        AddApprovalButtonsController.approve(quote2.Id,true);
		quote2.CPQ_Status__c = 'Planning';
        update quote2;
        AddApprovalButtonsController.approve(quote2.Id,true);        
        Test.stopTest();
    }
    private static testMethod void APApprovePart_PricingApproval(){
        
        Account accRec = [select id, name,OwnerId from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Product2 objPro = [select id, name from Product2 Limit 1];
        RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = objPro.Id;
        objAsset.AccountId = accRec.Id;
        objAsset.RFO_CarType__c = 'Test Car Type';
        objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
        insert objAsset;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
        //oppList[0].Quote_UI__c = '';
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        SBQQ__Quote__c commercialQuote = new SBQQ__Quote__c();
        commercialQuote = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'Existing');
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
        Schema.DescribeFieldResult fieldResult = SBQQ__Quote__c.Freight_Charge__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        commercialQuote.Freight_Charge__c = 'Collect (RR Should Send Invoice Directly to Lessee)';
        commercialQuote.RFO_FleetOpsDeliveryTime__c = 'Today';
        commercialQuote.RFO_PurchaseOptions__c = 'YES';
        commercialQuote.RFO_EarlyTermination__c = 'Yes';
        commercialQuote.RFO_NonStandardTerms__c =  'No';
        commercialQuote.RFO_DeliveryLocation__c =  'Yes';
        commercialQuote.RFO_FirstCarShipDays__c =  '10';
        commercialQuote.RFO_Allowable_Annual_Mileage__c = 10;
        commercialQuote.RFO_ExcessMileageFee__c = 5000.0;
        insert commercialQuote;
        quote1.Commercial_Quote__c = commercialQuote.id;
        insert quote1;
        Test.startTest();
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(quote1.Id);
        app.setProcessDefinitionNameOrId('CPQ_SLAProcess');
        Approval.ProcessResult result = Approval.process(app);
        AddApprovalButtonsController.approve(quote1.Id,true);
        SBQQ__QuoteLine__c quoteLine =  CPQUTILITYTEST.createQuoteLine(quote1,objPro);
        insert quoteLine;
        SBQQ__Quote__c quote2 = [SELECT CPQ_Status__c,SBQQ__LineItemCount__c,
                                 Need_Config_Count__c,Skipp_GapProcess__c,
                                 Commercial_Quote__r.RFO_FleetOpsDeliveryTime__c,
                                 Commercial_Quote__r.RFO_PurchaseOptions__c,
                                 Commercial_Quote__r.RFO_EarlyTermination__c,
                                 Commercial_Quote__r.RFO_NonStandardTerms__c,
                                 Commercial_Quote__r.RFO_DeliveryLocation__c,
                                 Commercial_Quote__r.RFO_FirstCarShipDays__c,
                                 Commercial_Quote__r.RFO_Allowable_Annual_Mileage__c,
                                 
                                 
                                 Commercial_Quote__r.RFO_ExcessMileageFee__c,
                                 Commercial_Quote__r.Freight_Charge__c
                                 
                                 
                                 FROM SBQQ__Quote__c WHERE Id=:Quote1.Id];
        
       
        
        quote2.CPQ_Status__c = 'Pricing Approval';
        update quote2;
        AddApprovalButtonsController.approve(quote2.Id,true);
                
        System.assert(true);//we are here if no exceptions during approval
        Test.stopTest();
    }
    private static testMethod void APApprovePart_PricingApproval_HandleFailFreightChargeValidationPricing(){
        
        Account accRec = [select id, name,OwnerId from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Product2 objPro = [select id, name from Product2 Limit 1];
        RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = objPro.Id;
        objAsset.AccountId = accRec.Id;
        objAsset.RFO_CarType__c = 'Test Car Type';
        objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
        insert objAsset;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
        //oppList[0].Quote_UI__c = '';
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        SBQQ__Quote__c commercialQuote = new SBQQ__Quote__c();
        commercialQuote = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'Existing');
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
        Schema.DescribeFieldResult fieldResult = SBQQ__Quote__c.Freight_Charge__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        commercialQuote.Freight_Charge__c 					= 'Collect (RR Should Send Invoice Directly to Lessee)';
        commercialQuote.RFO_FleetOpsDeliveryTime__c 		= 'Today';
        commercialQuote.RFO_PurchaseOptions__c 				= 'YES';
        commercialQuote.RFO_EarlyTermination__c 			= 'Yes';
        commercialQuote.RFO_NonStandardTerms__c 			=  'No';
        commercialQuote.RFO_DeliveryLocation__c 			=  'Yes';
        commercialQuote.RFO_FirstCarShipDays__c 			=  '10';
        commercialQuote.RFO_Allowable_Annual_Mileage__c 	= 10;
        commercialQuote.RFO_ExcessMileageFee__c 			= 5000.0;
        insert commercialQuote;
        quote1.Commercial_Quote__c = commercialQuote.id;
        insert quote1;
        Test.startTest();
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(quote1.Id);
         app.setProcessDefinitionNameOrId('CPQ_SLAProcess');
        Approval.ProcessResult result = Approval.process(app);
        AddApprovalButtonsController.approve(quote1.Id,true);
        SBQQ__QuoteLine__c quoteLine =  CPQUTILITYTEST.createQuoteLine(quote1,objPro);
        insert quoteLine;
        SBQQ__Quote__c quote2 = [SELECT CPQ_Status__c,SBQQ__LineItemCount__c,
                                 Need_Config_Count__c,Skipp_GapProcess__c,
                                 Commercial_Quote__r.RFO_FleetOpsDeliveryTime__c,
                                 Commercial_Quote__r.RFO_PurchaseOptions__c,
                                 Commercial_Quote__r.RFO_EarlyTermination__c,
                                 Commercial_Quote__r.RFO_NonStandardTerms__c,
                                 Commercial_Quote__r.RFO_DeliveryLocation__c,
                                 Commercial_Quote__r.RFO_FirstCarShipDays__c,
                                 Commercial_Quote__r.RFO_Allowable_Annual_Mileage__c,
                                 
                                 
                                 Commercial_Quote__r.RFO_ExcessMileageFee__c,
                                 Commercial_Quote__r.Freight_Charge__c
                                 
                                 
                                 FROM SBQQ__Quote__c WHERE Id=:Quote1.Id];
        
       
        
        quote2.CPQ_Status__c = 'Pricing';
        update quote2;
        AddApprovalButtonsController.approve(quote2.Id,true);
                
        System.assert(true);//we are here if no exceptions during approval
        Test.stopTest();
    }
     private static testMethod void APApprovePart_PricingApproval_HandleFailFreightChargeValidation(){
        
        Account accRec = [select id, name,OwnerId from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Product2 objPro = [select id, name from Product2 Limit 1];
        RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = objPro.Id;
        objAsset.AccountId = accRec.Id;
        objAsset.RFO_CarType__c = 'Test Car Type';
        objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
        insert objAsset;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
        //oppList[0].Quote_UI__c = '';
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        SBQQ__Quote__c commercialQuote = new SBQQ__Quote__c();
        commercialQuote = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'Existing');
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
        Schema.DescribeFieldResult fieldResult = SBQQ__Quote__c.Freight_Charge__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        commercialQuote.Freight_Charge__c 					= 'Collect (RR Should Send Invoice Directly to Lessee)';
        commercialQuote.RFO_FleetOpsDeliveryTime__c 		= 'Today';
        commercialQuote.RFO_PurchaseOptions__c 				= 'YES';
        commercialQuote.RFO_EarlyTermination__c 			= 'Yes';
        commercialQuote.RFO_NonStandardTerms__c 			=  'No';
        commercialQuote.RFO_DeliveryLocation__c 			=  'Yes';
        commercialQuote.RFO_FirstCarShipDays__c 			=  '10';
        commercialQuote.RFO_Allowable_Annual_Mileage__c 	= 10;
        commercialQuote.RFO_ExcessMileageFee__c 			= 5000.0;
        insert commercialQuote;
        quote1.Commercial_Quote__c = commercialQuote.id;
        insert quote1;
        Test.startTest();
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(quote1.Id);
         app.setProcessDefinitionNameOrId('CPQ_SLAProcess');
        Approval.ProcessResult result = Approval.process(app);
        AddApprovalButtonsController.approve(quote1.Id,true);
        SBQQ__QuoteLine__c quoteLine =  CPQUTILITYTEST.createQuoteLine(quote1,objPro);
        insert quoteLine;
        SBQQ__Quote__c quote2 = [SELECT CPQ_Status__c,SBQQ__LineItemCount__c,
                                 Need_Config_Count__c,Skipp_GapProcess__c,
                                 Commercial_Quote__r.RFO_FleetOpsDeliveryTime__c,
                                 Commercial_Quote__r.RFO_PurchaseOptions__c,
                                 Commercial_Quote__r.RFO_EarlyTermination__c,
                                 Commercial_Quote__r.RFO_NonStandardTerms__c,
                                 Commercial_Quote__r.RFO_DeliveryLocation__c,
                                 Commercial_Quote__r.RFO_FirstCarShipDays__c,
                                 Commercial_Quote__r.RFO_Allowable_Annual_Mileage__c,
                                 
                                 
                                 Commercial_Quote__r.RFO_ExcessMileageFee__c,
                                 Commercial_Quote__r.Freight_Charge__c
                                 
                                 
                                 FROM SBQQ__Quote__c WHERE Id=:Quote1.Id];
        
       
        
        quote2.CPQ_Status__c = 'Pricing Approval';
        update quote2;
        AddApprovalButtonsController.approve(quote2.Id,true);
                
        System.assert(true);//we are here if no exceptions during approval
        Test.stopTest();
    }
    private static testMethod void APReject(){
        Test.startTest();
        Account accRec = [select id, name,OwnerId from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Product2 objPro = [select id, name from Product2 Limit 1];
        RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = objPro.Id;
        objAsset.AccountId = accRec.Id;
        objAsset.RFO_CarType__c = 'Test Car Type';
        objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
        insert objAsset;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
        //oppList[0].Quote_UI__c = '';
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
        insert quote1;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(quote1.Id);
        app.setProcessDefinitionNameOrId('CPQ_SLAProcess');
        Approval.ProcessResult result = Approval.process(app);
        AddApprovalButtonsController.rejectRecord(quote1.Id,true);
        Test.stopTest();
    }
    private static testMethod void APApprove1(){
        Test.startTest();
        Account accRec = [select id, name,OwnerId from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Product2 objPro = [select id, name from Product2 Limit 1];
        RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = objPro.Id;
        objAsset.AccountId = accRec.Id;
        objAsset.RFO_CarType__c = 'Test Car Type';
        objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
        insert objAsset;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
        //oppList[0].Quote_UI__c = '';
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
        insert quote1;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(quote1.Id);
        app.setProcessDefinitionNameOrId('CPQ_SLAProcess');
        Approval.ProcessResult result = Approval.process(app);
        AddApprovalButtonsController.approve(quote1.Id,false);
        Test.stopTest();
    }
    private static testMethod void APReject1(){
        Test.startTest();
        Account accRec = [select id, name,OwnerId from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Product2 objPro = [select id, name from Product2 Limit 1];
        RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = objPro.Id;
        objAsset.AccountId = accRec.Id;
        objAsset.RFO_CarType__c = 'Test Car Type';
        objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
        insert objAsset;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
        //oppList[0].Quote_UI__c = '';
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
        insert quote1;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(quote1.Id);
        app.setProcessDefinitionNameOrId('CPQ_SLAProcess');
        Approval.ProcessResult result = Approval.process(app);
        AddApprovalButtonsController.rejectRecord(quote1.Id,false);
        Test.stopTest();
    }
}