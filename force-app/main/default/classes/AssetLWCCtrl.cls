public with sharing class AssetLWCCtrl {

    @AuraEnabled(cacheable=true)
    public static string getAssetDrawingsList(String WiredAssetId) {
        system.debug('============='+WiredAssetId);
        Asset FoundAsset = new Asset();
        FoundAsset = [SELECT Id, RFO_TASId__c FROM Asset WHERE Id =: WiredAssetId LIMIT 1];

        system.debug('Asset ID: '+FoundAsset.Id+'  TAS ID: '+FoundAsset.RFO_TASId__c);
       
        HttpRequest req = new HttpRequest();
        Http http = new Http();        
        // String drawingsURL = 'https://dev-api.trinityrail.com:8431/sit4/v1/asset/api/asset/4258/keyDrawingss';

        string  LinkAssetDrawings = RFO_IntegrationLinks__c.getInstance('AssetDrawings').RFO_APILink__c;
        system.debug('LinkAssetDrawings:' + LinkAssetDrawings);

        String drawingsURL = LinkAssetDrawings + FoundAsset.RFO_TASId__c + '/keyDrawings';
        
        req.setHeader('x-correlation-id', '0035400000FzpciAAB20190619164132256');
        req.setHeader('client_id', '0035400000FzpciAAB20190619164132256');
        req.setHeader('client_secret', '0035400000FzpciAAB20190619164132256');

        req.setEndpoint(drawingsURL);
        req.setMethod('GET');
        
        HTTPResponse resp = http.send(req);
        System.debug('Drawings response---> '+ resp);
        if(resp.getBody() != null) {
            return resp.getBody();
            }
        else {
            return null;
            }
    }
}