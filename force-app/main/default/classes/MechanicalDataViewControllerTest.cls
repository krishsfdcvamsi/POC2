@isTest
public class MechanicalDataViewControllerTest {

    @isTest static void MechanicalDataMethod() {
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Third Party Sales').getRecordTypeId();

        Account acc=new Account();
        acc.Name='Acc name';
        acc.recordTypeId = RecordTypeId;
        insert acc;
        
        Contact con=new Contact();
        con.AccountId=acc.Id;
        con.FirstName = 'Test1';
        con.LastName = 'Contact 1234';
        insert con;
         
        Asset asset=new Asset();
        asset.Name='Asset Test';
        asset.RFO_TASId__c = '625902';
        asset.AccountId=acc.Id;
        asset.ContactId=con.Id;
        insert asset;

       MechanicalData__c mechData = new MechanicalData__c();
       mechData.Name = 'test name';
       mechData.Asset__c = asset.Id;
       mechData.TAS_Asset_ID__c = '232343fd';
       insert mechData;
       
       MechanicalDataViewController.getMechanicalData(string.valueOf(asset.Id));
       MechanicalDataViewController.getMechanicalData(string.valueOf(mechData.Id));
    }
}