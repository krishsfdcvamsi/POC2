@isTest
public class AssetGroupLineControlerTest {
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
    private static testMethod void AssetGroupLineControler(){
        	Test.startTest();
        			Account accRec = [select id,ownerId,name from Account Limit 1];
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
            SBQQ__QuoteLine__c objLine =  CPQUTILITYTEST.createQuoteLine(quote1,objPro);
            insert objLine;
            Asset_Group__c objAssetGroup = New Asset_Group__c();
            objAssetGroup.Quote_Line__c = objLine.Id;
            Insert objAssetGroup;
        	
            Asset_Lines__c objAsseLin =  New Asset_Lines__c();
            objAsseLin.Asset__c = objAsset.Id;
            objAsseLin.Asset_Group__c = objAssetGroup.Id;
        	
            insert objAsseLin;
        	AssetGroupLineControler.getAssetGroupLineInfo(objAsseLin.Id);
            
         	Test.stopTest();
        }
}