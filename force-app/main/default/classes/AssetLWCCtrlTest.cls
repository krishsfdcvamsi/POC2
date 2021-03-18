@isTest
global class AssetLWCCtrlTest implements HttpCalloutMock{
     global HTTPResponse respond(HTTPRequest request) {
         // Create a fake response
         HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
         res.setBody('{"Drawing__c":"BTM OUTLET ARRGMT"}');
         res.setStatusCode(200);
         return res;
     }

     @isTest static void testgetAssetDrawingsList() {
        Account acc=new Account();
        acc.Name='Acc name';
        insert acc;
        
        Contact con=new Contact();
        con.AccountId=acc.Id;
        con.FirstName = 'Test1';
        con.LastName = 'Contact 1234';
        insert con;
         
        Asset asset=new Asset();
        asset.Name='Asset Test';
        asset.RFO_TASId__c = '625902';
        asset.AccountId=acc.Id;
        asset.ContactId=con.Id;
        insert asset;

        RFO_IntegrationLinks__c integrationLink = new RFO_IntegrationLinks__c();
        integrationLink.RFO_APILink__c='api_link';
        integrationLink.Name = 'AssetDrawings';
        insert integrationLink;
         
        Asset foundAsset = [SELECT Id FROM Asset WHERE RFO_TASId__c = '625902' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AssetLWCCtrlTest());
        string res = AssetLWCCtrl.getAssetDrawingsList(foundAsset.Id);
        Test.stopTest();  

        System.assertEquals(res, '{"Drawing__c":"BTM OUTLET ARRGMT"}');
    }

}