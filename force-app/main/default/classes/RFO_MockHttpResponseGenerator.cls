/*
* Class Name: RFO_MockHttpResponseGenerator 
*/ 
@isTest
global class RFO_MockHttpResponseGenerator implements HttpCalloutMock {
/* 
*Implement this interface method 
*/
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       // System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //String response1 = '{"Response": [{"status": "Success", "globalId": 12989}]}';
        String response1 = '{"globalId" : 14139, "status" : "Success"}';
        System.assertEquals('GET', req.getMethod());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-root-correlation-id', '1');
        req.setHeader('x-trin-channel', 'RAILFORCE');
        req.setHeader('x-trin-business-domain', '');
        req.setTimeout(100000);
        res.setBody(response1);
        res.setStatusCode(200);        
        return res;
    }
}