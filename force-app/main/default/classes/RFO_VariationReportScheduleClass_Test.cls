/**
 *   Test class of RFO_VariationReportScheduleClass controller
 **/
@isTest()
public class RFO_VariationReportScheduleClass_Test {

    /**
     *   Test method with test data for schedule class
     **/
    private static testmethod void scheduleTestMethod() 
    {
        List<RFO_ObjectsAPINames__c> apiList = new List<RFO_ObjectsAPINames__c>();
        RFO_ObjectsAPINames__c apis1 = new RFO_ObjectsAPINames__c(name='Account', RFO_ObjectLabelName__c='RFO_ObjectLabelName__c');
        RFO_ObjectsAPINames__c apis2 = new RFO_ObjectsAPINames__c(name='RFO_RiderGroup__c', RFO_ObjectLabelName__c='Rider Group');
        apiList.add(apis1);
        apiList.add(apis2);
        insert apiList;
        
        //Map<String, RFO_ObjectsAPINames__c> objectsApiCustSetgMap = RFO_ObjectsAPINames__c.getAll();
        
        RFO_VariationReportScheduleClass vrSch = new RFO_VariationReportScheduleClass();
        Test.startTest();
        String schTime = '0 0 3 * * ?';
        system.schedule('Variance Report Test', schTime, vrSch);
        Test.stopTest();
        System.debug('-after schedule class execution-');
    } // end of scheduleTestMethod
    
} // end of class RFO_VariationReportScheduleClass_Test