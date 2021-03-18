@isTest
public class CDX_MechanicalDataControllerTest {
@isTest static void getMechanicalDataExternalTest()
    {
       Account acc = new Account(name='Test Account'); 
        acc.RFO_AccountOwner__c = 'Me';
        acc.CDX_CopyCDMOnEmail__c = true;
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
        CDX_MechanicalDataController.getMechanicalDataExternal(objAsset.id);
		CDX_Mechanical_Data_Object_Finder.getMechanicalList(objAsset.id);      
        test.stopTest();
    }
}