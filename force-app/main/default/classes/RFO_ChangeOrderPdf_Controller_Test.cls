/**
*   Test Class : RFO_ChangeOrderPdf_Controller_Test 
**/
@isTest()
private class RFO_ChangeOrderPdf_Controller_Test {
    /**
*   Test method with test data to pass batch class
**/
    
    private static testmethod void coPdfTestMethod() {
        RFO_ChangeOrder__c chngOrd = new RFO_ChangeOrder__c();
        Test.startTest();
        RFO_ChangeOrderPdf_Controller coPdf = new RFO_ChangeOrderPdf_Controller();
        ApexPages.StandardController stdcnt = new ApexPages.StandardController(chngOrd);
        RFO_ChangeOrderPdf_Controller coPdf1 = new RFO_ChangeOrderPdf_Controller(stdcnt);
        Test.stopTest();
    }
    
}