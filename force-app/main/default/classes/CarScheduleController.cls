/************************************************************************************************************************************************** 
 * Class Name : Car Schedule Controller
 * Description : New Car Schedule on Order 
 * Author : Sai Anudeep
 * Created On : 11/19/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/19/20                    Sai Anudeep                       BETA - 193. New Car schedule Based by Order and Asset File.
      
 **************************************************************************************************************************************************/



public without sharing class CarScheduleController {

    
    
    
    @AuraEnabled(cacheable=true)
    public static List<RFO_Asset_File__c> getAssetFiles(Id orderId){
        return [SELECT Id,Name,RFO_IntegrationId__c,RFO_OrderNumber__r.RFO_BPCSCustomerNumber__c,
                RFO_OrderNumber__r.RFO_CarType__c,RFO_OrderNumber__r.Account_Name_Text__c,
                RFO_OrderNumber__r.RFO_CurrentPlant__c,RFO_OrderNumber__r.RecordType.Name,
                RFO_CurrentPlant__r.Name,
                (SELECT Id,Name,RFO_CarType__c FROM Assets__r),
                (SELECT Id,Name,Due_Date__c,Committed__c,Scheduled_Actuals__c FROM Order_Schedule__r) FROM RFO_Asset_File__c WHERE RFO_OrderNumber__c =: orderId];
    }
}