@isTest
public class OrderTriggerHandlerTest {
    // Changed by Ramesh Start
    @testSetup
    public static void testSetup(){
        //Create Product
        Product2 pro = RFO_Utility_Test.createProduct();
        pro.IsActive = true;
        Insert pro;
        
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
        
        
        //Create the PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = pro.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        List<Account> acclist = RFO_Utility_Test.createProspectAccounts();
        insert acclist;
        Account ac1 = [select id from Account limit 1];
        List<Opportunity> oppList = RFO_Utility_Test.createTankOpportunities(ac1);
        insert oppList;
        Opportunity oppRec = [select id from Opportunity limit 1];
        RFO_QuoteTeams__c quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
        insert quoteTeamRec;
        SBQQ__Quote__c quote = RFO_Utility_Test.createQuote(oppRec);
        quote.RFO_QuoteTeam__c = quoteTeamRec.id;
        quote.RFO_Product__c = pro.id;
        insert quote;
    }
    
    @isTest
	public static void updateContactIdTest(){ // Changed by Ramesh End
        Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        Id orderExstingCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId(); // Changed by Ramesh
        Id orderNewCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('New Car').getRecordTypeId(); // Changed by Ramesh
        Test.startTest();
        
        Account ac = new Account();
        ac.Name = 'Test Account 1';
        ac.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
		ac.Phone = '800-832-5452';          // Phone
		ac.RFO_Region__c = 'Class 1 Railroads';   // Region
		ac.RFO_AccountStatus__c = 'Active';
		//ac.OwnerId = usr1.id;
		insert ac;
        
        Account ac1 = new Account();
        ac1.Name = 'Test Account 2';
        ac1.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
		ac1.Phone = '800-832-5452';          // Phone
		ac1.RFO_Region__c = 'Class 1 Railroads';   // Region
		ac1.RFO_AccountStatus__c = 'Active';
		//ac.OwnerId = usr1.id;
		insert ac1;
        
		
        
        Contact cnt = new Contact(
			   FirstName = 'Tony', // FirstName
			   LastName = 'Alen',  // LastName
			   RFO_Status__c = 'Active', // Status
			   Email = 'Tony.Alen@trinity.net', // Email
			   AccountId = ac1.id, // Account Name
			   Phone = '(806) 381-0261', // Phone
			   //RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
			   RFO_ContactRole__c = 'Survey Contact',
			   Fax = '(806) 371-7528' // Fax
		   );
		insert cnt;
        
        Contact c1 = new Contact();
        c1.FirstName = 'Alagiri';
        c1.LastName = 'Muthiah';
        c1.RFO_Status__c = 'Active';
        c1.AccountId = ac.id;  
        c1.Email = 'alagiri.muthiah@trin.net';
        c1.RFO_ContactRole__c = 'Survey Contact';
        insert c1;	
        
        // Changed by Ramesh Start
        Product2 productRec = [select id from Product2 limit 1];
        SBQQ__Quote__c quoteRec = [select id from SBQQ__Quote__c limit 1];
        SBQQ__QuoteLine__c quoteline = RFO_Utility_Test.createQuoteLineLease(quoteRec, productRec);
        quoteline.RFO_CustSelected__c = True;
        quoteline.RFO_TransactionType__c = 'Lease';
        quoteline.SBQQ__Quote__c = quoteRec.Id;
        insert quoteline;
        // Changed by Ramesh End 
        
        List<Order> orderList = new List<Order>();
        Order ord = new Order();
        ord.AccountId = ac.Id;
        ord.Status = 'Active';
        ord.RecordTypeId = orderExstingCarRTId; // Changed by Ramesh
        ord.SBQQ__Quote__c = quoteRec.Id; // Changed by Ramesh
        ord.EffectiveDate = Date.today();
        
        Order ord1 = new Order();
        ord1.AccountId = ac1.Id;
        ord1.Status = 'Active';
        ord1.RecordTypeId = orderNewCarRTId; // Changed by Ramesh
        ord1.SBQQ__Quote__c = quoteRec.Id; // Changed by Ramesh
        ord1.EffectiveDate = Date.today();
        
		orderList.add(ord);
        orderList.add(ord1);
        
        insert orderList;
        
        OrderTriggerHandler.updateContactId(orderList);
        
        Test.stopTest(); 
        
        system.debug('order  is '+orderList.get(0).Id);
        //Order o = [Select Id, Survey_Contact__c from Order where Id = : orderList.get(0).Id];
        //system.debug('Order Survey contact '+o.Survey_Contact__c);
        
        //system.debug('order  is '+orderList.get(1).Id);
        //Order o1 = [Select Id, Survey_Contact__c from Order where Id = : orderList.get(1).Id];
        //system.debug('Order Survey contact '+o1.Survey_Contact__c);
        
        
    }
}