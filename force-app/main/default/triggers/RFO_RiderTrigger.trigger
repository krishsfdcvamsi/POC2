trigger RFO_RiderTrigger on RFO_Rider__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    TriggerDispatcher.Run(new RFO_RiderTriggerHandler());
    
 /*
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/01/20                   Madhava                            ALPHA - 33

* 10/08/20                   Ashish Reddy                      ALPHA - 166

 * This piece of code is not executed when an update happens from the TAS.
 * This a strange behhaviour, so covering the same logic here only for this specific use case
 */    
    
   

    try{   
        if(trigger.isAfter) {
            if(trigger.isUpdate) {
                // Ashish ALPHA - 166 - Start 
                Map<Id, Id> orderToRiderMap = new Map<Id, Id>();
                // Ashish ALPHA - 166 - End 

            set<id> accountIds = new set<id>();
            for(RFO_Rider__c riderSO: trigger.new) {
                if(riderSO.RFO_CurrentMaturityDate__c != null && riderSO.RFO_TotalActiveCars__c != null
                    && (riderSO.RFO_CurrentMaturityDate__c != trigger.oldMap.get(riderSO.Id).RFO_CurrentMaturityDate__c
                    || riderSO.RFO_TotalActiveCars__c != trigger.oldMap.get(riderSO.Id).RFO_TotalActiveCars__c)) {
    
                    accountIds.add(riderSO.RFO_Account__c);
                }

                    // Ashish ALPHA - 166 - Start 
                    if(riderSO.RFO_Status__c != trigger.oldMap.get(riderSO.Id).RFO_Status__c || riderSO.RFO_AvgBeginCharge__c != trigger.oldMap.get(riderSO.Id).RFO_AvgBeginCharge__c){
                        orderToRiderMap.put(riderSO.RFO_OrderID__c, riderSO.Id);
                    } // Ashish ALPHA - 166 - End 

            }
            if(!accountIds.isEmpty()) {
                system.debug('@@ check Coverage value');
                RFO_CoverageUtility.calculateRecommendedCoverage(RFO_CoverageUtility.getAccountFleet(accountIds),
                                                                RFO_CoverageUtility.getOpportunitesCount(accountIds),
                                                                RFO_CoverageUtility.getRidersCount(accountIds));
            } 

                // Ashish ALPHA - 166 - Start 
                if(!orderToRiderMap.isEmpty()){       
                    RFO_RiderTriggerHelper.updateEligibleOrdersToDeliveryComplete(orderToRiderMap);
                } // Ashish ALPHA - 166 - End 
                
            }
        }
        
    } catch(Exception e) {            
        System.debug('The following exception has occurred: ' + e.getMessage());            

    }
    
}