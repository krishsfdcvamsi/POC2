@isTest(SeeAllData=true)
public class CDX_ProjectSIAssetFlowControllerTest

{
    static testMethod void myUnitTest() {
 	Account acc = new Account();
        acc.Name = 'My Test Account';
        acc.RFO_AccountOwner__c = 'Me';
        acc.CDX_CopyCDMOnEmail__c = true;
        insert acc;
        
        Asset testAsset = new Asset();
        testAsset.name = 'Test Asset';
        testAsset.AccountId = acc.id;
        testAsset.RFO_CarType__c = 'Testing car type';
        testAsset.RFO_CarMark__c = 'Testing car mark';
        insert testAsset;
    
    RFO_Projects__c proj =new RFO_Projects__c();
    proj.RFO_Account__c = acc.id;
    proj.Name = 'Test';
        insert proj;
        
    	RFO_ProjectAssetSI__c psia = new RFO_ProjectAssetSI__c();
        psia.RFO_Asset__c = testAsset.id;
        psia.RFO_Project__c = proj.id;
        psia.Name = 'TestProjectSIAsset';
        insert psia;
        
        
      
        Test.startTest();
     
        CDX_ProjectSIAssetFlowController.DisplayProjectRecordsForFlow psidsi = new CDX_ProjectSIAssetFlowController.DisplayProjectRecordsForFlow (psia);
        
        
            
            
        Test.stopTest();
        
        
    
    } 
    
    static testmethod void updateCode(){
    CDX_ProjectSIAssetFlowController.updateCode();        
    }
}