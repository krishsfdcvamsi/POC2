/* Name: CaseTriggerHandler
 * Created By: Haseeb
 * Created Date: September 2020
 * Jira: ALpha- 520 & 521
 * Purpose: Update Order Status based on the Case and ChangeRequestLineItem Status.
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/28/20                    Vihari Vanga						 ALPHA - 677
 */

public class CaseTriggerHandler {
    public static void updateOrderStatus(list<case> newList, map<id,case> oldMap){
        if(Trigger.isAfter && Trigger.isUpdate){
            system.Debug('~~~ Trigger Order Update');


            OrderStatusUpdateHelper.updateOrderStatus(newList, oldMap);


        }
        //Alpha - 521 End - Haseeb
        //Alpha - 520 Start - Ramesh
        if(Trigger.isAfter && Trigger.isInsert){


            OrderStatusUpdateHelper.changeOrderStatus(newList);
       //Alpha - 520 End - Ramesh


        }
    }
    
     /* Added by Vihari ALPHA-677*/
     public static void afterUpdate(List<Case> newList, Map<Id, Case> oldItems){
         Id newCarCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CASE_NewCar).getRecordTypeId();
         List<Case> newCarCases = new List<Case>();
         List<Case> newCarCasesInEngReview = new List<Case>();
         for(Case c:newList){
             
             if(c.RecordTypeId == newCarCaseRT){
              	newCarCases.add(c);
                 if(c.Engineering_Review_Started__c==true && c.Engineering_Review_Started__c!=oldItems.get(c.id).Engineering_Review_Started__c){
                     newCarCasesInEngReview.add(c);
                 }
             }
         }
         //Check if newCarCasesInEngReview list has values
         if(newCarCasesInEngReview.size()>0)RFO_CaseHelper.createAlert(newCarCasesInEngReview);
        
     }
     /*End Vihari Alpha-677 */
}