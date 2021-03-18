/**
*   Test Class : RFO_RiderTriggerHandler_Test
**/
@isTest
Public Class RFO_RiderTriggerHandler_Test{
    
/**
*   Test method: riderCreation
**/
      @testsetup static void riderCreation(){
        
        // Account Creation        
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        Database.insert(accList);
        
        //contract Creation
        Contract contr =RFO_TestDataFactory.createContract('test', accList[0].id, true);
        Test.startTest();
        //Rider Creation
        RFO_Rider__c rider=new RFO_Rider__c();
        rider=RFO_Utility_Test.createrider();
        rider.RFO_Account__c=accList[0].id;
        rider.RFO_Status__c ='Ready for Delivery';
        rider.RFO_AutoRenewal__c ='No';
        rider.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider.RFO_RiderType__c = RFO_Constant.MANAGEMENT_AGREEMENT;
        rider.RFO_ProductType__c = 'test';
        rider.RFO_Contract__c=contr.id;
        rider.RFO_IncreaseEffectiveUpon__c = 'Completion of Modification';
        Database.insert(rider);
        rider.RFO_TotalActiveCars__c = 10;
        update rider;
        
        //Rider Creation
        RFO_Rider__c rider1=new RFO_Rider__c();
        rider1=RFO_Utility_Test.createrider();
        rider1.RFO_Account__c=accList[0].id;
        rider1.RFO_Status__c ='Ready for Delivery';
        rider1.RFO_AutoRenewal__c ='No';
        rider1.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider1.RFO_RiderType__c = 'Net Lease';
        rider1.RFO_ProductType__c = 'test';
        rider1.RFO_Contract__c=contr.id;
        Database.insert(rider1);
        
        Database.delete(rider1);
        Test.stopTest();
    }
/**
*   Test method: updateRider
**/ 
    private static testMethod void updateRider(){
       
            RFO_Rider__c riderRecord = [select id, name from RFO_Rider__c Limit 1];
            RFO_RiderTriggerHandler riderHandler = new RFO_RiderTriggerHandler();
            //riderHandler.AfterUpdate();
            System.assert(riderRecord!=null);
        Map<Id, SObject> oldItems = new Map<Id, SObject>();
        oldItems.put(riderRecord.Id,riderRecord);
        Test.startTest();
        riderHandler.AfterUndelete(oldItems);
        Test.stopTest();
    }
    
}