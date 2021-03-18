/* Class Name : ChangeRequestPricingRefreshBatch
 * Description : Batch Class to Update Change Request status when pricing date expires on Change Request Line Items
 * Created By : Vihari Vanga
 * Created On : 2/9/21
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 2/09/21                    Vihari Vanga                       EPSI-459
 */
global class ChangeRequestPricingRefreshBatch implements 
	Database.Batchable<sObject>,Database.stateful, Schedulable{
	
    // Changed by Ramesh Added record type 'Mid_Lease_Change_Request'
     global Database.QueryLocator start(Database.BatchableContext bc){
        // collect the batches of records or objects to be passed to execute
        Date expDate = System.TODAY();
         List<String> statusFilters = new List<String>{RFO_Constant.Case_Status_Rejected,RFO_Constant.Case_Status_Acknowledge, RFO_Constant.Case_Status_Cancelled,RFO_Constant.Case_Status_Closed,RFO_Constant.Order_Status_Materials_Planning,RFO_Constant.Case_Change_Analysis_Approved,RFO_Constant.Case_Change_Analysis_Rejected};
        return Database.getQueryLocator(            
            'SELECT Id,RFO_ChangeRequestID__c From RFO_ChangeRequestLineItem__c where Pricing_Expiry_Date__c = :expDate'
            +' AND RecordType.DeveloperName IN (\'RFO_ExistingCarChangeRequestLineItem\',\'Mid_Lease_Change_Request\')'
            +' AND RFO_ChangeRequestID__r.Status NOT IN :statusFilters');
         
    }
        
    global void execute(Database.BatchableContext bc,  List<RFO_ChangeRequestLineItem__c> records){
        // process each batch of records
        try{
        	if(records.size()>0){
                
                Set<Id> caseIds = new Set<Id>();
                List<Case> casesToBeUpdated = new List<Case>();
                for(RFO_ChangeRequestLineItem__c crli: records){
                    caseIds.add(crli.RFO_ChangeRequestID__c);
                }
                
                AlertService aService = new AlertService();
        		map<String,Alert_Setting__mdt> alertSettingsMap = aService.mapAlertSetting;
        		List<Alert__c> alerts = new List<Alert__c>();
        		String settingName = Label.Case_Pricing_Refresh_Alert_Setting_Name;
        		for(Case c:[Select id, Status, CaseNumber from Case where ID IN :caseIds]){
                    c.Status = RFO_Constant.Order_Status_Materials_Planning;
                    casesToBeUpdated.add(c);
                    // Check if  Pricing Refresh Alert custom metadata record exists 
                    if(alertSettingsMap.containsKey(settingName)){
		   				String immediateAlertList = aService.getImmediateAlertRecipients(settingName,null);
                        String notificationBody = String.format(alertSettingsMap.get(settingName).Immediate_Notification_Body__c,new List<Object>{c.CaseNumber});
           				Alert__c alert = aService.createAlert(settingName, null, immediateAlertList,
                               '', '', (String)c.Id, '', notificationBody);
                        alert.Completed__c = true;
           				alerts.add(alert);
                    }
        		}
                Database.update(casesToBeUpdated);   
                Database.insert(alerts);
    		}
        }catch(Exception e){
            System.debug('Exception'+e.getMessage());
            throw e;
        }
    }
       
        
    global void finish(Database.BatchableContext bc){
        System.debug('Test...5');
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ChangeRequestPricingRefreshBatch());
    }
    
}