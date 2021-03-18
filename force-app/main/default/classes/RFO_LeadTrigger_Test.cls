@isTest
public class RFO_LeadTrigger_Test { 

    private static testMethod void notificationMeth() { 
        Test.setMock(HttpCalloutMock.class, new RFO_HttpCalloutMock_Test());
        Lead leadSO = new Lead();
        leadSO.LeadSource = 'Email';
        leadSO.Status = 'Identified';
        leadSO.Company = 'Test Team';
        leadSO.firstName = 'test';
        leadSO.lastName = 'Name';
        insert leadSO;
    }
}