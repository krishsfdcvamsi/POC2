@isTest
global class assetDrawingFileTest implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('ABCD1234');
        res.setStatusCode(200);
        return res;
    }

    @isTest static void testgetFile() {

        RFO_IntegrationLinks__c integrationLink = new RFO_IntegrationLinks__c();
        integrationLink.RFO_APILink__c='api_link';
        integrationLink.Name = 'AssetDrawings';
        insert integrationLink;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new assetDrawingFileTest());
        string res = assetDrawingsFile.getFile('123456');
        Test.stopTest();  

        System.assertEquals(res, 'ABCD1234');
    }
}