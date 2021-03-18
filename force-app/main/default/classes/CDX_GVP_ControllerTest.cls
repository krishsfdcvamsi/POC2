@isTest
public class CDX_GVP_ControllerTest {
@isTest static void getGVPListTest()
    {
       Account acc = new Account(name='Test Account'); 
        insert acc;
        system.assertNotEquals(acc.Id, Null);
        
         contact con = new contact();
        con.AccountId = acc.Id;
        con.FirstName = 'Test';
        con.LastName = 'Contact 123';
        con.Email = 'abc@test.com';
        insert con;
        
        Asset objAsset = new Asset();
        objAsset.AccountId = acc.Id;
        objAsset.ContactId = con.Id;
        objAsset.Name = 'Test';
        objAsset.RFO_TASId__c ='123511';
        insert objAsset;
        
        test.startTest();
        CDX_GVP_Controller.getGVPList(objAsset.id);
        
        CDX_RetrieveGVPExternalData.getGVPExternalData(objAsset.RFO_TASID__c);
        //gvplist = new CDX_RetrieveGVPExternalData();
       // gvplist
        test.stopTest();
    }
}