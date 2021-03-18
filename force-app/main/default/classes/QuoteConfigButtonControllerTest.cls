@isTest
public class QuoteConfigButtonControllerTest {
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
    }
    private static testMethod void createQuote(){
        Test.startTest();
    	Account accRec = [select id,ownerId,name from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        List<Opportunity> oppList2 = new List<Opportunity>();     
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
        //oppList[0].Quote_UI__c = '';
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1 = CPQUTILITYTEST.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
        Product2 productRec = RFO_Utility_Test.createProduct();
        productRec.isActive  = true;
        insert productRec;
        quote2 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQNoSkipValidation(oppList[0], quoteTeamRec,productRec,'CPQ');
       	insert quote2;
        quote1.CPQ_Quote__c = quote2.Id;
        insert quote1;
        QuoteConfigButtonController.getQuoteUIDetails(quote1.Id);
        QuoteConfigButtonController.configButton(quote1.Id);
        quote1.Quote_UI__c = 'CPQ Quote';
        update quote1;
        QuoteConfigButtonController.configButton(quote1.Id);
        quote1.Quote_UI__c = '';
        update quote1;
        QuoteConfigButtonController.configButton(quote1.Id);
        Test.stopTest();
    }
    
}