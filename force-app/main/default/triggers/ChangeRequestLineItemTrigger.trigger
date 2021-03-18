/* Name: ChangeRequestLineItemTrigger
 * Created By: Haseeb and Ramesh
 * Created Date: September 2020
 * Jira: ALpha- 520, 521 & 523
 * Purpose: Update Order Status based on the Case and ChangeRequestLineItem Status. And Round Lease Rate Currency Field.
 */

trigger ChangeRequestLineItemTrigger on RFO_ChangeRequestLineItem__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
        ChangeRequestLineItemHandler.UpdateOrderStatus(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        ChangeRequestLineItemHandler.RoundUpLeaseRate(Trigger.new);
    }
}