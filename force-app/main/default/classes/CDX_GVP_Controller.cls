public with sharing class CDX_GVP_Controller {
    @AuraEnabled(cacheable=true)
    public static string getGVPList(String WiredAssetId) {
        Asset FoundAsset = new Asset();
        FoundAsset = [SELECT Id, RFO_TASId__c FROM Asset WHERE Id =: WiredAssetId LIMIT 1];
        System.debug('Asset ID: '+FoundAsset.Id+'  Recorded ID: '+FoundAsset.RFO_TASid__c);
        List<RFO_GVP__x> FoundGVP = new List<RFO_GVP__x>();
        FoundGVP = [SELECT Id, RFO_AssetID__c FROM RFO_GVP__x WHERE RFO_AssetID__c =: FoundAsset.RFO_TASId__c LIMIT 1];
        if(FoundGVP.size() > 0)
        {
            System.debug('RFO GVP ID: '+FoundGVP[0].Id);
            System.debug('RFO GVP Asset ID: '+FoundGVP[0].RFO_AssetID__c);
            
            return FoundGVP[0].Id;
        }
        return NULL;
    }   
}