public class MechanicalDataViewController {
    
    @AuraEnabled
    public static string getMechanicalData(string assetId) {
        try {
            Id mechId = [SELECT Id FROM MechanicalData__c WHERE Asset__c =: assetId LIMIT 1].Id;
            return mechId;
        }
        catch(exception e) {
            return null;
        }
    }

}