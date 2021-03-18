public class SRStatusController {
    
    @AuraEnabled
    public static List<RFO_ShopIncident__c> getNewSrs(List<Id> newSrIds){
        return [SELECT Id,Name,CDX_Asset_Name__c,RFO_Status__c,RFO_Asset__c,RFO_Asset__r.Name,
                RFO_ShopIncidentID__c,
                RFO_Asset__r.RFO_CurrComm__r.RFO_STCC__c,RFO_SIStatus__c,RFO_CarNumber__c
                FROM RFO_ShopIncident__c WHERE Id IN: newSrIds];
    }
}