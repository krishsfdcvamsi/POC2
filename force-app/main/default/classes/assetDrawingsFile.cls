public  with sharing class assetDrawingsFile {

    @AuraEnabled(cacheable=true)
    public static string getFile(String drawingNumber) {
 
      HttpRequest req = new HttpRequest();
      Http http = new Http();        

      string  LinkAssetDrawings = RFO_IntegrationLinks__c.getInstance('AssetDrawings').RFO_APILink__c;
      string drawingsFileURL = LinkAssetDrawings + 'drawings/' + drawingNumber;
      String drawingsFileURLEncoded = drawingsFileURL.replace(' ', '%20');
      // String drawingsFileURLError =     'https://dev-api.trinityrail.com:8431/sit4/v1/asset/api/asset/drawings/A-222-W';
      
      system.debug('drawingsFileURL---> '+ drawingsFileURL);
      system.debug('drawingsFileURLEncoded---> '+ drawingsFileURLEncoded);

      req.setHeader('x-correlation-id', '0035400000FzpciAAB20190619164132256');
      req.setHeader('client_id', '0035400000FzpciAAB20190619164132256');
      req.setHeader('client_secret', '0035400000FzpciAAB20190619164132256');

      req.setEndpoint(drawingsFileURLEncoded);
      req.setMethod('GET');
    
      HTTPResponse resp = http.send(req);
  
      system.debug('resp---> '+ resp);
      if(resp.getStatusCode() == 200) {
        return resp.getBody();
      }

      return 'failed';
    }
}