@isTest
global class RFO_HttpCalloutMock_Test implements HttpCalloutMock {

    global RFO_HttpCalloutMock_Test() {
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string bobyStr = '{"inputs": [{'
                            +'"title": "A new sales team lead is created.",'
                            +'"targetId": "00Q3D000007aALjUAM",'
                            +'"recipientIds": ["00546000001V9aWAAS","00546000001Veh2AAC"],'
                            +'"customNotifTypeId": "0ML3D0000004DHrWAM",'
                            +'"body": "A new sales team lead is created. click to view"}]}';
        res.setBody(bobyStr);
        res.setStatusCode(200);
        return res;
    }
}