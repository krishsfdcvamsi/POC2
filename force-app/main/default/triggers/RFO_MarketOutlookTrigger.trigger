trigger RFO_MarketOutlookTrigger on Market_Outlook__c (after update) {

    if(trigger.isAfter) {
        
        if(trigger.isUpdate) {
            for(Market_Outlook__c mo : trigger.new) {    
                if(mo.Coverage_Multiplier__c != trigger.oldMap.get(mo.Id).Coverage_Multiplier__c) {
                    RFO_CoverageRecommendationBatch RecBatch = new RFO_CoverageRecommendationBatch(mo.Market_Segment__c);
                    Database.executeBatch(RecBatch,1);
                }
            }
        }
    
    }

}