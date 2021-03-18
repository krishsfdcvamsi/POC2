/* Name: ChangeRequestLineItemHandler
 * Created By: Haseeb and Ramesh
 * Created Date: September 2020
 * Jira: ALpha- 520, 521 & 523
 * Purpose: Update Order Status based on the Case and ChangeRequestLineItem Status. And Round Lease Rate Currency Field.
 */

public class ChangeRequestLineItemHandler {
    public static void updateOrderStatus(list<RFO_ChangeRequestLineItem__c> newList, map<id,RFO_ChangeRequestLineItem__c> oldMap){
		OrderStatusUpdateHelper.updateChangeRequestStatus(newList,oldMap);        
    }
    
//Changes Start by Ramesh - Alpha-523 - Making Lease Rate field value as rounded up to nearest $
    public static void RoundUpLeaseRate(list<RFO_ChangeRequestLineItem__c> newList){
        for(RFO_ChangeRequestLineItem__c crli : newList){
            if(crli.Lease_Rate__c != null)
                crli.Lease_Rate__c = Math.round(crli.Lease_Rate__c);
        }
    }
}