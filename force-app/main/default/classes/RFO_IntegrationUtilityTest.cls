@isTest
public class RFO_IntegrationUtilityTest 
{
    Static testmethod void createLogDetailTest()
     {
        Test.startTest();
        Map<Id, Object> payloads = new Map<Id,Object>();
        List<RFO_Commodity__c> commList = RFO_Utility_Test.createCommodity();
        payloads.put(commList.get(0).Id, commList.get(0));
        RFO_IntegrationUtility.createLogDetail(payloads, 'objectName', 'GET', 'URI', 'method', 'apexClass');


        Test.stopTest();
    }

    Static testmethod void testupdateIntegrationLogStatus() {
        RFO_IntegrationUtility.updateIntegrationLogStatus(200, 'integrationId', 'payloadBody', 'success');

    }

    Static testmethod void testgetResponseBody() {
        HttpResponse response = new HttpResponse();
        RFO_IntegrationUtility.getResponseBody(response);

    }

    Static testmethod void testcreateIntegrationLogRecord() {
        RFO_IntegrationUtility.createIntegrationLogRecord('objectName', 'integrationId', 'body', 'URI', 'result', '200', 'GET', 'apexClass');

    }
}