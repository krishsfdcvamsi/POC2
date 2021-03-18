/*
* Class Name: RFO_MockHttpAccountOwnerResponse
*/
@isTest
global class RFO_MockHttpAccountOwnerResponse implements HttpCalloutMock {
/* 
*Implement this interface method 
*/
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       // System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //String response1 = '{"Response": [{"status": "Success", "globalId": 12989}]}';
        String response1 = '{"status":"success","message":"synced successfully"}';
        //System.assertEquals('{"salesRepresentative":{"startDate":"2019-07-30T11:36:41","lanId":"FREYM"},"lastModifiedBy":"SMARTTD","accountId":6953}', req.getBody());
        System.assertEquals('PUT', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-root-correlation-id', '1');
        req.setHeader('x-trin-channel', 'RAILFORCE');
        req.setHeader('x-trin-business-domain', 'LEASING');
        req.setTimeout(100000);
        res.setBody(response1);
        res.setStatusCode(200);
        return res;
    }
}