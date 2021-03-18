@isTest
public class RiderContractFilesControllerTest {
    
    @isTest
    public static void getFileIdsTest(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RFO_IsConvertedAccount__c  = false;
        acc.BillingCountry = 'US';
        acc.BillingCity = 'NY';
        acc.BillingState = 'NY';
        acc.BillingPostalCode = '12345';
        acc.BillingStreet = 'aa';
        acc.BillingLatitude = 0.7894;
        acc.BillingLongitude = 1.00002;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert acc;
        Contract cr = new Contract();
        cr.AccountId = acc.Id;
        insert cr;
        //cr.
        RFO_Rider__c rider = new RFO_Rider__c();
        rider.RFO_Contract__c = cr.Id;
        rider.RFO_TotalOfCars__c = 5;
        rider.RFO_RiderRateType__c = 'Fixed';
        rider.RFO_Term__c = 2;
        rider.RFO_RenewalDaysNotice__c = 10;
        insert rider;
        
        CDX_Estimate__c ce = new CDX_Estimate__c();
        insert ce;
        
        Test.startTest();
        RiderContractFilesController.getFileIds(rider.Id);
        RiderContractFilesController.getEstimateFiles(ce.Id);
        Test.stopTest();
        //rider
    }
}