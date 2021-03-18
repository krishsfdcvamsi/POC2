@isTest
public class gapProcessSelectedCarsControllerTest {
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
		private static testMethod void gapProcessSelectedCars(){
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
            SBQQ__Quote__c quoteComm = CPQUTILITYTEST.createCPQPrimaryQuotewithProduct(oppList[0], quoteTeamRec,objPro);
            quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ',true);
            quote1.Commercial_Quote__c  = quoteComm.Id;
            insert quote1;
            SBQQ__QuoteLine__c objLine =  CPQUTILITYTEST.createQuoteLine(quote1,objPro);
            objLine.Need_Configuration__c = true;
            insert objLine;
            List<Asset_Group__c> lstAssetGroups = New List<Asset_Group__c>();
            Asset_Group__c objGroup = New Asset_Group__c();
    
            objGroup.Description__c = 'Test';
            objGroup.Quote_Line__c	=	Null;
            objGroup.Opportunity__c = quoteComm.SBQQ__Opportunity2__c;
            lstAssetGroups.add(objGroup);
            
            Asset_Group__c objGroup2 = New Asset_Group__c();
    
            objGroup2.Description__c = 'Test';
            objGroup2.Quote_Line__c	=	Null;
            objGroup2.Opportunity__c = quoteComm.SBQQ__Opportunity2__c;
            lstAssetGroups.add(objGroup2);
            insert lstAssetGroups;
            SBQQ__QuoteLineGroup__c objGroups = New SBQQ__QuoteLineGroup__c();
            objGroups.SBQQ__Quote__c = quote1.Id;
            objGroups.Name 				= 'As Configured';
            insert objGroups;
            gapProcessSelectedCarsController.getRecords(quote1.Id,200,0,'ASG');
            gapProcessSelectedCarsController.createLineItem(New List<String>{objGroup.Id},New List<String>(),quote1.Id);
            gapProcessSelectedCarsController.getListViewDetails(objGroup.Id);
            Test.stopTest();
        }
    private static testMethod void gapProcessSelectedCars2(){
        	Test.startTest();
        			Account accRec = [select id, name,OwnerId from Account Limit 1];
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
            SBQQ__Quote__c quoteComm = CPQUTILITYTEST.createCPQPrimaryQuotewithProduct(oppList[0], quoteTeamRec,objPro);
            quote1 = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objPro,'CPQ',true);
            quote1.Commercial_Quote__c  = quoteComm.Id;
            insert quote1;
            SBQQ__QuoteLine__c objLine =  CPQUTILITYTEST.createQuoteLine(quote1,objPro);
            objLine.Need_Configuration__c = true;
            insert objLine;
            List<Asset_Group__c> lstAssetGroups = New List<Asset_Group__c>();
            Asset_Group__c objGroup = New Asset_Group__c();
    
            objGroup.Description__c = 'Test';
            objGroup.Quote_Line__c	=	Null;
            objGroup.Opportunity__c = quoteComm.SBQQ__Opportunity2__c;
            lstAssetGroups.add(objGroup);
            
            Asset_Group__c objGroup2 = New Asset_Group__c();
    
            objGroup2.Description__c = 'Test';
            objGroup2.Quote_Line__c	=	Null;
            objGroup2.Opportunity__c = quoteComm.SBQQ__Opportunity2__c;
            lstAssetGroups.add(objGroup2);
            insert lstAssetGroups;
            SBQQ__QuoteLineGroup__c objGroups = New SBQQ__QuoteLineGroup__c();
            objGroups.SBQQ__Quote__c = quote1.Id;
            objGroups.Name 				= 'Need Configuration';
            insert objGroups;
            //gapProcessSelectedCarsController.getRecords(quote1.Id,200,0);
            //gapProcessSelectedCarsController.createLineItem(New List<String>{objGroup.Id},New List<String>(),quote1.Id);
            gapProcessSelectedCarsController.createLineItem(New List<String>(),New List<String>{objGroup2.Id},quote1.Id);
            Test.stopTest();
        }

}