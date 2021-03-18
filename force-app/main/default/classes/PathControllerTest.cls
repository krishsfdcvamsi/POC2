@isTest
public class PathControllerTest {
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
    private static testMethod void PathController(){
        	Test.startTest();
        	Account accRec = [select id, name,ownerId from Account Limit 1];
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
        	PathController.getQuoteStatus(quote1.Id);
         	Test.stopTest();
        }
}