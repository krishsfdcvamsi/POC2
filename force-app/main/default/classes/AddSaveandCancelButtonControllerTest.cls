@isTest
public class AddSaveandCancelButtonControllerTest {
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
		private static testMethod void QuoteContainer(){
        	Test.startTest();
            	Account accRec = [select id,ownerId,name from Account Limit 1];
        			Contact contRec = [select id, name from Contact Limit 1];
            Product2 objPro = [select id, name from Product2 Limit 1];
            RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
            Asset  objAsset = New Asset();
            objAsset.Name = 'TestAsset';
            objAsset.Product2Id  = objPro.Id;
            objAsset.AccountId = accRec.Id;
            objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
            insert objAsset;
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = CPQUTILITYTEST.createTankOpportunities1(accRec, contRec);
            //oppList[0].Quote_UI__c = '';
            system.debug('AddSaveandCancelButtonControllerTest.beforeoppInsert');
            Database.insert(oppList);
            system.debug('AddSaveandCancelButtonControllerTest.afteroppInsert');
            RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
            system.debug('AddSaveandCancelButtonControllerTest.beforeQTeams');
            try{
                 Database.insert(quoteTeamRec);
            }
            catch(exception ee)
            {
                system.debug('qteam ex: '+ee.getMessage());
            }
           
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            system.debug('AddSaveandCancelButtonControllerTest.beforeQuotes');
            quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
           
            try{
                  insert quote1;
            }
            catch(exception ee)
            {
                system.debug('quote ex: '+ee.getMessage());
            }
            system.debug('AddSaveandCancelButtonControllerTest.afterQuote');
           List<RFO_Commodity__c> commd= CPQUTILITYTEST.createCommodity1();
        	insert commd;
            Id recordTypeIdCustomerSpecBox = Schema.SObjectType.Customer_Spec__c.getRecordTypeInfosByDeveloperName().get('Box_Car').getRecordTypeId();
            Customer_Spec__c objcust = New Customer_Spec__c();
            objcust.recordTypeId  = recordTypeIdCustomerSpecBox;
            objcust.Opportunity_lookup__c = oppList[0].Id;
			objcust.Commodity__c		=	commd[0].Id;
            objcust.Loading_City__c		=	'Test';
            objcust.Maximum_Quantity_of_Cars__c	=	10;

            //insert objcust;
            system.debug('zzzhere');
            AddSaveandCancelButtonController.saveSobject(objcust);
            Test.stopTest();
        	
        }
}