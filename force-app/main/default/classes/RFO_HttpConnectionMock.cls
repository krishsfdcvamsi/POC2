@isTest
global class RFO_HttpConnectionMock implements HttpCalloutMock {
 global HTTPResponse respond(HTTPRequest req) {   
     
     string  response1='{ "Response": [ { "RFO_Origin": "JUNCTION CITY, KS", "RFO_Destination": "MTVERNON, IN", "RFO_EventStation": "MTVERNON,IN", "RFO_Status": "Placement-Actual", "RFO_TrainID": "", "RFO_STCC": "", "RFO_STCCDescription": "", "RFO_StatusDate": "2014-08-31 00:20:00", "RFO_Carrier": "EVWR", "RFO_LE": "E", "RFO_AssetID": 280725, "RFO_StageID": 109345519 } ] }';  
   
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setTimeout(100000);    
        res.setBody(response1);
        res.setStatusCode(200);
        return res;
    }
}