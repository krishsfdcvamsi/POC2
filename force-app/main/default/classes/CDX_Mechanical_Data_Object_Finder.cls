public with sharing class CDX_Mechanical_Data_Object_Finder {
    @AuraEnabled(cacheable=true)
    public static string getMechanicalList(String WiredAssetId) {
        Asset FoundAsset = new Asset();
        FoundAsset = [SELECT Id, RFO_TASId__c FROM Asset WHERE Id =: WiredAssetId LIMIT 1];
        System.debug('Asset ID: '+FoundAsset.Id+'  Recorded ID: '+FoundAsset.RFO_TASid__c);
        List<CDX_MechanicalDataExternal__x> FoundMecha = new List<CDX_MechanicalDataExternal__x>();
        FoundMecha = [SELECT Id, CDX_Asset__c, CDX_AccountId__c, CDX_A_End_Coupler__c FROM CDX_MechanicalDataExternal__x WHERE CDX_Asset__c =: FoundAsset.RFO_TASId__c LIMIT 1];
  
        if(FoundMecha.size()>0){
            System.debug('RFO MechData ID: '+FoundMecha[0].Id);
            System.debug('RFO MechData Asset ID: '+FoundMecha[0].CDX_Asset__c);
        
            return FoundMecha[0].Id;
        }
        
  		return null;
    }   
}