public without sharing class AssetListViewController {
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssetList(Id orderId){
        Order orderSO  = new Order();
        orderSO = [SELECT Id,RFO_RANumber__c FROM Order WHERE Id =: orderId];
        return [SELECT Id,Name,RFO_ActualCapacity__c,RFO_LightWeight__c,RFO_GRL__c,
                RFO_StencilSpec__c,RFO_DateBuilt__c,RFO_File__c,RFO_ModelDescription__c,
                RFO_MfgPlant__c,RFO_DOTClass__c,RFO_CarType__c 
                FROM Asset WHERE RFO_RANumber__c =: Decimal.valueOf(orderSO.RFO_RANumber__c)];
    }
    
    @AuraEnabled(cacheable=true)
    public static string getOrder(Id orderId){
        return [SELECT Id,Name,RecordType.DeveloperName  
                FROM Order WHERE Id =: orderId].RecordType.DeveloperName;
    }
    
}