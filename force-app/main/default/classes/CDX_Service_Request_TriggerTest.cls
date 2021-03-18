@isTest
public class CDX_Service_Request_TriggerTest {
    
    static testmethod void triggerMethods() { 
        
        Account acc = new Account();
        acc.Name = 'My Test Account';
        acc.RFO_AccountOwner__c = 'Me';
        acc.CDX_CopyCDMOnEmail__c = true;
        insert acc;
        
        Contact con1 = new contact();
        con1.AccountId = acc.Id;
        con1.FirstName = 'Test';
        con1.LastName = 'Contact 1234';
        con1.Email = 'abcD@test.com';
        con1.CDX_SR_Notification_Preference__c=true;
        insert con1;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.userId = userInfo.getUserId();
        atm.TeamMemberRole = 'Customer Delivery Manager';
        atm.AccountAccessLevel = 'Edit';
        atm.accountId = acc.Id;
        insert atm;
        
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.userId = userInfo.getUserId();
        atm1.TeamMemberRole = 'Customer Delivery Director';
        atm1.AccountAccessLevel = 'Edit';
        atm1.accountId = acc.Id;
        insert atm1;
        
        Asset testAsset = new Asset();
        testAsset.name = 'Test Asset';
        testAsset.AccountId = acc.id;
        testAsset.RFO_CarType__c = 'Testing car type';
        testAsset.RFO_CarMark__c = 'Testing car mark';
        insert testAsset;
        
        RFO_ShopIncident__c shopInc1=new  RFO_ShopIncident__c();
        shopInc1.name='Test Service Request1';
        shopInc1.RFO_Asset__c=testAsset.id;
        shopInc1.RFO_Customer__c=acc.id;
        shopInc1.RFO_SIRef__c='22344';
        shopInc1.RFO_ShopName__c='www';
        shopInc1.RFO_Location__c='Location';
        shopInc1.CDX_Primary_Contact__c=con1.id;
        shopInc1.RFO_ShopIncidentID__c = 'A2342Cdfew';
        shopInc1.RFO_SIStatus__c = 'Cust. Submitted';
        insert shopInc1;
        
        shopInc1.Customer_Delivery_Director__c = null;
        shopInc1.CDX_Destination_Consignee__c = null;
        shopInc1.CDX_Freight_Forwarder__c = null;
        shopInc1.RFO_ShopInstruction__c = 'test';
        shopInc1.RFO_ShopIncidentID__c = null;
        update shopInc1;
        
        shopInc1.RFO_ShopIncidentID__c = 'ABCDEF';
        update shopInc1;
        
        try{
        delete shopInc1;
        }
        catch(Exception e){
            
        }
        //Cust. Submitted
    } 
}