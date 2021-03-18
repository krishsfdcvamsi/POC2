/* Class Name : RiderService
 * Description : RiderService Class for Rider Object
 * Created By : Ashish Reddy
 * Created On : 10/01/20
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/01/20                    Ashish Reddy                      ALPHA - 166
 * 11/16/20					   Vihari Vanga					     ALPHA - 22
 */
public with sharing class RiderService {
 




 /* Method to Query AllRidersByOrderId
  * @param orderIds - Set<Id> of the order records 
  * 
  * @retunrs Map<Id,List<RFO_Rider__c>> 
  */ 
    public static Map<Id,List<RFO_Rider__c>> getAllRidersByOrderId( Set<Id> orderIds){
        Map<Id,List<RFO_Rider__c>> orderIdToAllRidersMap = new Map<Id,List<RFO_Rider__c>>();
        for(RFO_Rider__c rider: [select id, RFO_Status__c, RFO_AvgBeginCharge__c, RFO_OrderID__c from RFO_Rider__c where RFO_OrderID__c in:orderIds]){







            if(orderIdToAllRidersMap.containsKey(rider.RFO_OrderID__c)){
                List<RFO_Rider__c> riderList = orderIdToAllRidersMap.get(rider.RFO_OrderID__c);
                riderList.add(rider);
                orderIdToAllRidersMap.put(rider.RFO_OrderID__c, riderList);
            }else {
                List<RFO_Rider__c> riderList = new List<RFO_Rider__c>();
                riderList.add(rider);
                orderIdToAllRidersMap.put(rider.RFO_OrderID__c, riderList);
            }
        }  
        return orderIdToAllRidersMap;

    }

    /* Method to Query getAllRidersByAccountIds
    * @param orderIds - Set<Id> of the order records 
    * @return Map<Id,List<RFO_Rider__c>> 
    */
    public static Map<Id,List<RFO_Rider__c>> getAllRidersByAccountIds(Set<Id> setAccountId){
        Map<Id,List<RFO_Rider__c>> accIdToAllRidersMap = new Map<Id,List<RFO_Rider__c>>();
        for (RFO_Rider__c rider: [SELECT Id, Name, RFO_RiderType__c, RFO_Account__c, RFO_RiderNumber__c, RFO_TotalOfCars__c, Assumed_of_Cars__c, RFO_OriginalMaturityDate__c, RFO_CurrentMaturityDate__c, Assumption__c, RFO_RiderRate__c, RFO_Term__c,
                                 RFO_TASRiderId__c, RFO_RiderAverageBeginDate__c, RFO_RiderAverageEndDate__c, RFO_Status__c FROM RFO_Rider__c WHERE RFO_Account__c IN:setAccountId ORDER BY Name]) {
            if (accIdToAllRidersMap.containsKey(rider.RFO_Account__c)) {
                List<RFO_Rider__c> riderList = accIdToAllRidersMap.get(rider.RFO_Account__c);
                riderList.add(rider);
                accIdToAllRidersMap.put(rider.RFO_Account__c, riderList);
            }else {
                List<RFO_Rider__c> riderList = new List<RFO_Rider__c>();
                riderList.add(rider);
                accIdToAllRidersMap.put(rider.RFO_Account__c, riderList);
            }
        }
        return accIdToAllRidersMap;
    }


}