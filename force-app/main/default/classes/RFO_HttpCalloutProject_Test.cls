@isTest
global class RFO_HttpCalloutProject_Test implements HttpCalloutMock {

    global RFO_HttpCalloutProject_Test() {
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string bobyStr = '[{'
                            +'"projectId": 100,'
                            +'"CDX_Week": 101,'
                            +'"actualCarsReleasedByCustomer": 0,'
                            +'"actualCarsShippedByShop": 0,'
                            +'"actualCompletedCarsByShop": 0,'
                            +'"arrivedCarsToShop": 0,'
                            +'"currentProjectedOutCarsByShop": 0,'
                            +'"customerReleasedCars": 1'
                            +'},'
                            +'{'
                            +'"projectId": 101,'
                            +'"CDX_Week": 102,'
                            +'"actualCarsReleasedByCustomer": 0,'
                            +'"actualCarsShippedByShop": 0,'
                            +'"actualCompletedCarsByShop": 0,'
                            +'"arrivedCarsToShop": 0,'
                            +'"currentProjectedOutCarsByShop": 0,'
                            +'"customerReleasedCars": 1'
                            +'},'
                            +'{'
                            +'"projectId": 103,'
                            +'"CDX_Week": 2,'
                            +'"actualCarsReleasedByCustomer": 0,'
                            +'"actualCarsShippedByShop": 0,'
                            +'"actualCompletedCarsByShop": 0,'
                            +'"arrivedCarsToShop": 0,'
                            +'"currentProjectedOutCarsByShop": 0,'
                            +'"customerReleasedCars": 1'
                          +'}]';
        res.setBody(bobyStr);
        res.setStatusCode(200);
        return res;
    }
}