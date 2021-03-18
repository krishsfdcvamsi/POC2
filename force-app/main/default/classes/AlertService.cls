/************************************************************************************************************************************************** 
 * Class Name : AlertService
 * Description : Service class for Alert creation and SOQL.
 * Author : Haseeb
 * Created On : 10/26/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/26/20                    Haseeb                       	ALPHA - 771, Creates Alert from the passed in values.

 * 11/5/20					   Vihari						    ALPHA-677

 * 
 **************************************************************************************************************************************************/

public class AlertService {
    
    //Creates a map of Alert setting Developer and Alert setting metadata record
    public map<String,Alert_Setting__mdt> mapAlertSetting = new map<String,Alert_Setting__mdt>();
    public AlertService(){
        list<Alert_Setting__mdt> alertSettings = [select MasterLabel,Immediate_Alert_List__c,Business_Days__c,Alert_1_List__c,Alert_1_Criteria_Days__c,
                                                  Alert_2_List__c,Alert_2_Criteria_Days__c,Immediate_Notification__c,Immediate_Notification_Body__c,
                                                  Immediate_Notification_Title__c,Custom_Notification_1_Body__c,Alert_Level__c,
                                                  Custom_Notification_1_Title__c,Custom_Notification_2_Body__c,Custom_Notification_2_Title__c,
                                                  DeveloperName,Object_Name__c,Field_name__c from Alert_Setting__mdt];
        for(Alert_Setting__mdt a : alertSettings){
            mapAlertSetting.put(a.DeveloperName, a);
        }
        system.debug('~~~ Map Alert: '+mapAlertSetting);
    }
    //Returns Alert based on the passed in values
    public Alert__c createAlert(String DeveloperName, 
                                Date calculationFromDate, 
                                String ImmediateAlertList, 
                                String Alert1List, 
                                String Alert2List, 
                                String relatedTo, 
                                String notificationMergeTitle, 
                                String notificationMergeBody){
        Alert__c a = new Alert__c();
        a.Alert_Job_Daily__c = True;
        a.from_date__c = calculationFromDate == null ? system.today() : calculationFromDate;
        a.Immediate_Alert__c = mapAlertSetting.get(DeveloperName).Immediate_Notification__c;
        a.Immediate_Alert_List__c = ImmediateAlertList == null ? mapAlertSetting.get(DeveloperName).Immediate_Alert_List__c : ImmediateAlertList;
        a.Alert_1_List__c = Alert1List == null ? mapAlertSetting.get(DeveloperName).Alert_1_List__c : Alert1List;
        a.Alert_2_List__c = Alert2List == null ? mapAlertSetting.get(DeveloperName).Alert_2_List__c : Alert2List;
        a.Related_To__c = relatedTo;
        a.Alert_Level__c = mapAlertSetting.get(DeveloperName).Alert_Level__c; 
        a.Notification_Merge_Title__c = notificationMergeTitle != null ? notificationMergeTitle : null;
        a.Notification_Merge_Body__c = notificationMergeBody != null ? notificationMergeBody : null;
        //a.Alert_1_Criteria_Days__c = mapAlertSetting.get(DeveloperName).Alert_1_Criteria_Days__c;
        a.Alert_2_Criteria_Days__c = mapAlertSetting.get(DeveloperName).Alert_2_Criteria_Days__c;
        
        a.Number_of_Days__c = mapAlertSetting.get(DeveloperName).Alert_1_Criteria_Days__c;
        a.Related_To_Field_Name__c = mapAlertSetting.get(DeveloperName).Field_name__c;
        a.Related_To_Object_Name__c = mapAlertSetting.get(DeveloperName).Object_Name__c;
        a.Business_Days__c = mapAlertSetting.get(DeveloperName).Business_Days__c;
        a.Alert_Setting_Label__c = DeveloperName;
        return a;
    }

    
    /* Method to return all the immediateAlert recipients
	 * @param settingDeveloperName - developer name of Alert setting record
	 * @param recipients - user id list who should recieve alerts along with the list store in custom metadata
	 * 
	 * @return string - list of recipients seperated by ';'
	 */
    
    public string getImmediateAlertRecipients(String settingDeveloperName, List<String> recipients){
        system.debug('recipients'+recipients);
        String alertRecipients = mapAlertSetting.get(settingDeveloperName)?.Immediate_Alert_List__c;
        if(recipients?.size()>0){
        	for(String s:recipients){                
                if(alertRecipients!=null){
					if(!alertRecipients.contains(s))alertRecipients += alertRecipients.substring(alertRecipients.length()-1)!=';'?';' + s:s+';';
                }else{
                    alertRecipients=s+';';
                }
        	}
        }
        
        return  alertRecipients;
    }
    
    /* Method to return all the alert 1 recipients
	 * @param settingDeveloperName - developer name of Alert setting record
	 * @param recipients - user id list who should recieve alerts along with the list store in custom metadata
	 * 
	 * @return string - list of recipients seperated by ';'
	 */
    public string getAlert1Recipients(String settingDeveloperName, List<String> recipients){
        system.debug('recipients===='+recipients);
        String alertRecipients = mapAlertSetting.get(settingDeveloperName)?.Alert_1_List__c;
        if(recipients?.size()>0){
        	for(String s:recipients){                
                if(alertRecipients!=null){
					if(!alertRecipients.contains(s))alertRecipients += alertRecipients.substring(alertRecipients.length()-1)!=';'?';' + s:s+';';
                }else{
                    alertRecipients=s+';';
                }
        	}
        }
        system.debug('alertRecipients===='+alertRecipients);
        return  alertRecipients;
    }
    
    /* Method to return all the alert 2 recipients
	 * @param settingDeveloperName - developer name of Alert setting record
	 * @param recipients - user id list who should recieve alerts along with the list store in custom metadata
	 * 
	 * @return string - list of recipients seperated by ';'
	 */   
    public string getAlert2Recipients(String settingDeveloperName, List<String> recipients){
        String alertRecipients = mapAlertSetting.get(settingDeveloperName)?.Alert_2_List__c;
        if(recipients?.size()>0){
        	for(String s:recipients){                
                if(alertRecipients!=null){
					if(!alertRecipients.contains(s))alertRecipients += alertRecipients.substring(alertRecipients.length()-1)!=';'?';' + s:s+';';
                }else{
                    alertRecipients=s+';';
                }
        	}
        }
        
        return  alertRecipients;
    }

}