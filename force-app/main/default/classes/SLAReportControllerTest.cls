@isTest
public class SLAReportControllerTest {
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
        			Account accRec = [select id,name,OwnerId from Account Limit 1];
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
            Database.insert(oppList);
            RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
            Database.insert(quoteTeamRec);
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ');
            insert quote1;
            SBQQ__Quote__c commercialQuote = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'Existing');
            commercialQuote.RFO_FleetOpsDeliveryTime__c = 'Today';
        	commercialQuote.RFO_PurchaseOptions__c = 'YES';
            commercialQuote.RFO_EarlyTermination__c = 'Yes';
            commercialQuote.RFO_NonStandardTerms__c =  'No';
            commercialQuote.RFO_DeliveryLocation__c =  'Yes';
            commercialQuote.RFO_FirstCarShipDays__c =  '10';
            commercialQuote.RFO_Allowable_Annual_Mileage__c = 10;
            commercialQuote.RFO_ExcessMileageFee__c = 5000.0;
            commercialQuote.CPQ_Quote__c = quote1.Id;
            insert commercialQuote;
            SBQQ__QuoteLine__c objLine =  CPQUTILITYTEST.createQuoteLine(quote1,objPro);
            insert objLine;
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(quote1.id);
            Approval.ProcessResult result = Approval.process(app);
            SLAReportController.getApprovalHistory(commercialQuote.Id);
            Test.stopTest();
        }
}