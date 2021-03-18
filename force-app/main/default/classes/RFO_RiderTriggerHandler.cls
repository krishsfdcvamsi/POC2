/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 05th July 2019
* @Description : This class is to update Rider Renewal Opportunity
* 
History
*
* 09AUG2019 | I Martinez | US: undefined | Merged Trinity's enhancements code
**/
public class RFO_RiderTriggerHandler implements ITriggerHandler
{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
    RFO_TriggerSetting__mdt riderTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='RiderTrigger'];
     
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        if (riderTrigger.RFO_Active__c)
            return TriggerDisabled;
        else
            return true;
    }
 
 /*
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 02/26/21                    Ashish Reddy                      EPSI-811 - Updated Line 48 to 50.
 */    
    public void BeforeInsert(List<SObject> newItems) {
        try{
            RFO_RiderTriggerHelper.updateAccountName(newItems, NULL, RFO_Constant.RECORD_CREATED);
            RFO_RiderTriggerHandler_TRN.updateContactId(Trigger.new);
            RFO_RiderTriggerHelper.associateOpportunity(newItems); // Changed by RG
            /* Added By Vihari ALPHA -22 */
            List<RFO_Rider__c> cloneAssumptionRiderList = new List<RFO_Rider__c>();
            
            for(RFO_Rider__c rider: (List<RFO_Rider__c>)newItems){
                if(rider.isClone() ){
                    cloneAssumptionRiderList.add(rider);
                }
            }
            //Epsi-811- start
            if(cloneAssumptionRiderList.size()>0){
                RFO_RiderTriggerHelper.autoAssignFieldsForClonedRider(cloneAssumptionRiderList);// End by Vihari
            }//Epsi-811- End
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)  {
        try{
            RFO_RiderTriggerHelper.updateAccountName(newItems.values(), oldItems, RFO_Constant.RECORD_UPDATED);
            RFO_RiderTriggerHandler_TRN.processSurvey(Trigger.oldMap,Trigger.new);
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        Map<id,RFO_Rider__c> riderNewMap = (Map<id,RFO_Rider__c>)newItems;
        set<id> accountIds = new set<id>();
        for(RFO_Rider__c riderSO: riderNewMap.values()){ 
            if(riderSO.RFO_CurrentMaturityDate__c != null && riderSO.RFO_TotalActiveCars__c != null) {
                accountIds.add(riderSO.RFO_Account__c);
            }
        }
        
        // Madhava ALPHA-33 - Start 
        if(!accountIds.isEmpty()) {
            RFO_CoverageUtility.calculateRecommendedCoverage(RFO_CoverageUtility.getAccountFleet(accountIds),
                                                            RFO_CoverageUtility.getOpportunitesCount(accountIds),
                                                            RFO_CoverageUtility.getRidersCount(accountIds));
        }
        
        // Madhava ALPHA-33 - End
    }
    
    //Creates Renewal opportunity record for Rider object.
 /*
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/01/20                    Ashish Reddy                      ALPHA - 166
 */
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        set<id> accountIds = new set<id>();

        // Ashish ALPHA - 166 - Start 
        //Map<Id, Id> orderToRiderMap = new Map<Id, Id>();
        // Ashish ALPHA - 166 - End 

        try{
            RFO_RiderTriggerHelper.updateRenewalOpportunity(newItems, oldItems);
            List<RFO_Rider__c> riderFileUpdateList = new List<RFO_Rider__c>();
            Map<id,RFO_Rider__c> riderNewlist = (Map<id,RFO_Rider__c>)newItems;
            Map<id,List<RFO_Rider__c>> riderNewMap1 = new Map<id,List<RFO_Rider__c>>();
            Map<id,RFO_Rider__c> riderOldList = (Map<id,RFO_Rider__c>)oldItems;
            for(RFO_Rider__c assetfile: riderNewlist.values()){
                if(assetfile.RFO_Status__c != riderOldList.get(assetfile.id).RFO_Status__c){ 
                    riderFileUpdateList.add(assetfile);
                    riderNewMap1.put(assetfile.RFO_OrderID__c, riderFileUpdateList);
                } 



                 // Ashish ALPHA - 166 - Start 
               // if(assetfile.RFO_Status__c != riderOldList.get(assetfile.id).RFO_Status__c || assetfile.RFO_AvgBeginCharge__c != riderOldList.get(assetfile.id).RFO_AvgBeginCharge__c){
                  //  orderToRiderMap.put(assetfile.RFO_OrderID__c, assetfile.Id);
                //} // Ashish ALPHA - 166 - End 



            }

            if(!riderNewMap1.isEmpty()){       
                RFO_RiderTriggerHelper.updateOrderstatus(riderNewMap1);
            }



             // Ashish ALPHA - 166 - Start 
           // if(!orderToRiderMap.isEmpty()){       
           //     RFO_RiderTriggerHelper.updateEligibleOrdersToDeliveryComplete(orderToRiderMap);
          //  } // Ashish ALPHA - 166 - End 



        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}