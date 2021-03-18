public class lookupAssetsMultiAC {
    
    @AuraEnabled
    public static Asset getAsset (Id recordId) {
        Asset asset = [SELECT Id, Name, RFO_CurrCommForm__c FROM Asset WHERE Id = :recordId];
        return asset;
    }
    
    @AuraEnabled
    public static AssetResponse getAssetById (Id recordId) {
        AssetResponse ar = new AssetResponse();
        List<RFO_ShopIncident__c> srs = [SELECT Id,Name FROM RFO_ShopIncident__c 
                                         WHERE RFO_Asset__c =: recordId AND 
                                         RFO_SIStatus__c IN('Active')];
        if(!srs.isEmpty())
            ar.isSRAvailable = true;
        
        Asset asset = [SELECT Id, Name,AccountId,CDX_Last_Shopped_Customer_Commodity__c,
                       RFO_CurrComm__r.RFO_STCC__c,RFO_CarNumber__c,RFO_FileNumber__c,RFO_CurrComm__c,
                       RFO_CurrComm__r.Name FROM Asset WHERE Id = :recordId];
        ar.asset = asset;
        System.debug('SR :'+ar);
        return ar;
    }
    
	@AuraEnabled
    public static String getAssetName (Id recordId) {
        String thisAsset = [SELECT Id, Name FROM Asset WHERE Id = :recordId].Name;
        return thisAsset;
    }
    
    @AuraEnabled
    public static String getAssetCommodity (Id recordId) {
        String thisCommodity = [SELECT Id, RFO_CurrCommForm__c FROM Asset WHERE Id = :recordId].RFO_CurrCommForm__c;
        return thisCommodity;
    }
    
    public class AssetResponse{
        @AuraEnabled
        public Asset asset;
        @AuraEnabled
        public Boolean isSRAvailable;
    }
    
}