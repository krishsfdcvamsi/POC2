/* 
* Rider Controller Test class
* */
@isTest(seeAllData = false)
public class RFO_RiderControllerTest {
    /*
* create Order test data setup method
* */
    @testsetup static void createAssetTestdata(){ 
        Test.startTest();
        // Account Creation        
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].Name = RFO_Constant.ACCOUNT_NAME;
        Database.insert(accList);
        
        //contract Creation
        Contract contr = new Contract(AccountId = accList[0].id, RFO_ContractType__c=RFO_Constant.CONTRACT_TYPE_DIRECT_SALE ,
                                      RFO_ContractDate__c=system.today());
        Database.insert(contr);
        
        //Start - Test to view Contract Files related to Rider record - Tina Wilburn 
        //Contract File Creation
        ContentVersion contentVersion = new ContentVersion(Title = 'TestContractFile', PathOnClient = 'ContractFile1.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true, Trinity_File_Type__c = 'Image');
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title = 'TestContractFile'];

        //ContentDocumentLink Record Creation 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = contr.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        //End - Test to view Contract Files related to Rider record
        
        //Rider Creation
        RFO_Rider__c rider=new RFO_Rider__c();
        rider=RFO_Utility_Test.createrider();
        rider.RFO_Account__c=accList[0].id;
        rider.RFO_Status__c =RFO_Constant.READY_FOR_DELIVERY;
        rider.RFO_AutoRenewal__c =RFO_Constant.YES;
        rider.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider.RFO_RiderType__c = RFO_Constant.RIDER_TYPE;
        rider.RFO_ProductType__c = RFO_Constant.TEST;
        rider.RFO_Contract__c=contr.id;
        rider.RFO_TotalOfCars__c = 2; 
        rider.RFO_TotalActiveCars__c = 5;
        Database.insert(rider);
        
        Test.stopTest();
    }
    private static testMethod void riderControllerTest(){
        User userRecord = RFO_Utility_Test.createUserRecord();
        system.runAs(userRecord) {
            List<RFO_Rider__c> riderList = [Select Id,Name,RFO_OriginalMaturityDate__c FROM RFO_Rider__c limit 49999];
            RFO_RiderController.getRiderDetails(riderList[0].id);
            RFO_RiderController temp = new RFO_RiderController();
            FileViewerController.getRelatedFilesByRecordId(riderList[0].id);  //Test to view Contract Files related to Rider record - Tina Wilburn
            system.assertequals(riderList!= null, true);
    }
}
}