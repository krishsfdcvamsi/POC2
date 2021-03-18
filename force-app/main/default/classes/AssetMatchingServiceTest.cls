@istest
public class AssetMatchingServiceTest {
    
    @TestSetup
    private static void Setup()
    {
        // list<Asset_Lines__c> assetLines = new List<Asset_Lines__c>();
        //create records needed to create asset
        setupRelatedObjects();
        //load those records
        Account accRec = [select id, name from Account Limit 1];
        Contact contRec = [select id, name from Contact Limit 1];
        Product2 objPro = [select id, name from Product2 Limit 1];
        Opportunity opp = [select id,name from Opportunity limt1];
        RFO_Commodity__c objCom =  [select id, name from RFO_Commodity__c Limit 1];
        List<Asset_Group__c> agList= new List<Asset_Group__c>();
        for(integer i=0;i<5;i++)
        {
            
            
            Asset_Group__c ag = New Asset_Group__c();
            // objAssetGroup.Quote_Line__c = objLine.Id;
            ag.opportunity__c = opp.id;
            ag.MatchingAlgorithmResult__c = true;
            agList.add(ag);
            /*   Insert ag;
*/
        }
        insert agList;
        system.debug('zzz assetmatchservice test created ag ' + agList.size());
        for(asset_group__c ag: agList)
        {
            list<Asset_Lines__c> assetLines = new List<Asset_Lines__c>();
            system.debug('zzz '+ag.id);
            for(integer j=0;j<10;j++)
            {
                
                Asset  objAsset = New Asset();
                objAsset.Name = 'TestAsset '+j;
                objAsset.Product2Id  = objPro.Id;
                objAsset.AccountId = accRec.Id;
                objAsset.CDX_Last_Shopped_Commodity__c = objCom.Id;
                insert objAsset;
                Asset_Lines__c agl =  New Asset_Lines__c();
                agl.Asset__c = objAsset.Id;
                agl.Asset_Group__c = ag.Id;
                assetLines.add(agl);
                system.debug('zzz '+ ag.Id);
            }
            
            insert assetLines;
        }
        
    }
    private static void setupRelatedObjects()
    {
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
        List<Opportunity> objOpp = CPQUTILITYTEST.createTankOpportunities(accList[0]);
        insert objOpp;
    }
    @istest
    private static void ProcessMatchingResults_Success(){
        list<Asset_Lines__c> assetLines = new List<Asset_Lines__c>();
        Opportunity opp = [select id,name from Opportunity limit 1];
        Asset objAsset = [select id,name from Asset limit 1];
        Asset_Group__c ag = New Asset_Group__c();
        ag.opportunity__c = opp.id;
        ag.MatchingAlgorithmResult__c = true;
        system.assertEquals(5, [select id from asset_group__c].size(), 'we do not have all 5 groups created in test setup');
        Insert ag;
        system.assertEquals(1, [select id from asset_group__c].size(), 'we did not delete the 5 old asset groups as intended');
        for(integer j=0;j<10;j++)
        {
            Asset_Lines__c agl =  New Asset_Lines__c();
            agl.Asset__c = objAsset.Id;
            agl.Asset_Group__c = ag.Id;
            assetLines.add(agl);
        }
        insert assetLines;
        Asset_Lines__c atl = [Select id,Asset_Match__c from Asset_Lines__c limit 1 ];
        atl.Asset_Match__c  = 20;
        update atl;
        system.assertEquals(10, [select id from Asset_Lines__c].size(), 'expecting 10 asset lines, found: ' + [select id from Asset_Lines__c].size());
    }
    
}