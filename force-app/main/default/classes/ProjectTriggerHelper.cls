/************************************************************************************************************************************************** 
* Class Name : ProjectTriggerHelper
* Description : This class is the helper class of RFO_ProjectsTriggerHandler.
* Author : Lakshmi Malepati
*
* Modification Log:
* -----------------------------------------------------------------------------------------------------------------
* Date                       Developer                          Description
* -----------------------------------------------------------------------------------------------------------------
* 11/4/20                    Lakshmi Malepati                  ALPHA - 645, Sends 3 email and bell notifications when Project moves to Customer Delivery stage.
* 11/10/20                   Lakshmi Malepati                  ALPHA - 582, Sends 1 task and 3 bell notifications when Project moves to Capacity Planning stage.
* 12/10/20					 Lakshmi Malepati                  ALPHA - 1748, Exit criteria when order is linked with a project.

**************************************************************************************************************************************************/

public class ProjectTriggerHelper {
    //ALPHA-645, Lakshmi Malepati 
    //private static boolean flagvalue = false;
    /* Method to send notificarions 
* @param proLst - trigger.new project list
* @param prjRecMap - trigger.oldMap project map
* @param isInsert - true if this method is being called on insert
* @param isUpdate - true if this method is being called on update
*
* ALPHA - 645
*/
    public static void sendNotification(List<RFO_Projects__c> proLst,Map<Id,RFO_Projects__c> prjRecMap,
                                        boolean isInsert,boolean isUpdate) 
    {
        System.debug('Debug Log For Method Check');
        Set<String> orderId = new Set<String>();
        Id existingCar = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        for(RFO_Projects__c prjt: proLst) {
            System.debug('Debug Log For prjt.Name: '+prjt.Name);
            if(prjt.Order__c != null) {
                System.debug('Debug Log For : '+prjt.Order__c);
                orderId.add(prjt.Order__c);
            }    
        }
        Map<Id, Order> mapOrder = new Map<Id, Order>([SELECT Id, RecordTypeId From Order Where Id IN: orderId AND RecordTypeId  =: existingCar]);
        //To avoid recursion 
        //if(flagvalue == false ||Test.isRunningTest()) 
        //{
          //  flagvalue = true;
          System.debug('Debug Log For mapOrder: '+mapOrder);
            Set<Id> setAccIds = new Set<Id>();
            for(RFO_Projects__c prjt: proLst) {  
                System.debug('Debug Log For prjt.RFO_Account__c: '+prjt.RFO_Account__c);
                System.debug('Debug Log For mapOrder.containsKey(prjt.Order__c): '+mapOrder.containsKey(prjt.Order__c));
                System.debug('Debug Log For prjt.RFO_Workstation__c: '+prjt.RFO_Workstation__c);
                if(prjt.Order__c != null && mapOrder.containsKey(prjt.Order__c) &&  prjt.RFO_Account__c != null && (prjt.RFO_Workstation__c  != null && prjt.RFO_Workstation__c == RFO_Constant.Customer_Delivery) 
                   && (isInsert == true ||(isUpdate = true && prjt.RFO_Workstation__c != prjRecMap.get(prjt.Id).RFO_Workstation__c ))) 
                {
                    if( prjt.Stop_Email_Notification__c  == true) 
                        prjt.Stop_Email_Notification__c  = false;
                    setAccIds.add(prjt.RFO_Account__c);// Collecting account IDs 
                    System.debug('Debug Log For prjt.RFO_Account__c: '+prjt.RFO_Account__c);
                }
                
                if((prjt.RFO_Workstation__c != null && prjt.RFO_Workstation__c != RFO_Constant.Customer_Delivery) 
                   && (isInsert == true ||(isUpdate = true && prjt.RFO_Workstation__c != prjRecMap.get(prjt.Id).RFO_Workstation__c ))) 
                { 
                    prjt.Stop_Email_Notification__c  = true;
                }
            } 
            System.debug('setAccIds---'+setAccIds);
            if(!setAccIds.isEmpty()) 
            {
                AlertService objAS = new AlertService();
                //Fetching Account Team Member
                Map<Id,List<AccountTeamMember>> mapATM = AccountTeamMemberService.getAccountTeamMembersByAccId(setAccIds);
                List<Alert__c> lstAlert = new List<Alert__c>();
                
                for(RFO_Projects__c prjt: proLst) {
                    List<String> lstCDMRec = new List<String>();
                    List<String> lstCDDRec = new List<String>();
                    System.debug('prjt.RFO_Account__c' +prjt.RFO_Account__c);
                    System.debug('mapATM' +mapATM.get(prjt.RFO_Account__c));
                    System.debug('mapATM.containsKey(prjt.RFO_Account__c)' +mapATM.containsKey(prjt.RFO_Account__c));
                    
                    if(mapATM.containsKey(prjt.RFO_Account__c)) { 
                        
                        for(AccountTeamMember acctm: mapATM.get(prjt.RFO_Account__c)) {
                            //adding recipients in the list
                            if(acctm.TeamMemberRole.containsIgnoreCase(RFO_Constant.CUSTOMER_DELIVERY_MANAGER)){
                                lstCDMRec.add(acctm.UserId);
                            } else if(acctm.TeamMemberRole.containsIgnoreCase(RFO_Constant.CUSTOMER_DELIVERY_DIRECTOR)){
                                lstCDDRec.add(acctm.UserId);
                            }
                        }
                    }
                    
                    //creating Immediate Alert list
                    String strImpAlertList = objAS.getImmediateAlertRecipients(RFO_Constant.Project_Alert_MTD_Name, lstCDMRec);
                    //creating Alert list 1
                    String strAlertList1 = objAS.getAlert1Recipients(RFO_Constant.Project_Alert_MTD_Name, lstCDMRec);
                    //creating Alert list 2
                    String strAlertList2 = objAS.getAlert2Recipients(RFO_Constant.Project_Alert_MTD_Name, lstCDDRec);
                    
                    if(String.isNotBlank(strImpAlertList) 
                       || String.isNotBlank(strAlertList1)  
                       || String.isNotBlank(strAlertList2))  
                    {
                        String titleBody = '';
                        if(!Test.isRunningTest()) {
                            List<Object> parameters = new List<Object> {prjt.Name};
                                titleBody = objAS.mapAlertSetting.get(RFO_Constant.Project_Alert_MTD_Name).Immediate_Notification_Body__c != null ?
                                String.format(objAS.mapAlertSetting.get(RFO_Constant.Project_Alert_MTD_Name).Immediate_Notification_Body__c, parameters) :
                            'The Project Workstation for Project ' + prjt.Name + ' is set to Customer Delivery';
                        } else { 
                            titleBody = 'test message';
                        }
                        
                        Alert__c objA = objAS.createAlert(RFO_Constant.Project_Alert_MTD_Name, System.today(), strImpAlertList, 
                                                          strAlertList1,strAlertList2, prjt.Id, titleBody, titleBody);
                        lstAlert.add(objA); 
                    }
                }
                
                //Inserting Alert Record
                if(!lstAlert.isEmpty() && !Test.isRunningTest()) insert lstAlert;
            	System.debug('Debug Log For lstAlert: '+lstAlert);
            }
            
        //}
    }
    
    //End ALPHA-645, Lakshmi Malepati
    
   
    /*******************************************************************
* CreatedBy: Haseeb
* Created Date: Nov 23 2020
* Jira: Alpha-583
******************************************************************/
    Public static void sendSOWBellAlert(Map<String,RFO_Projects__c> projectsMap){
        
        //Check if there's an existing Alert record.
        Alert__c[] existingAlerts = [select id,Related_To__c from Alert__c where 
                                     Related_To__c in: projectsMap.keySet() and Completed__c = false and 
                                     Related_To_Object_Name__c = 'RFO_Projects__c' and Related_To_Field_Name__c = 'SOW_Status_Updated__c'];
        Set<string> existingAlertsSet = new Set<String>();
        for(Alert__c a : existingAlerts){
            existingAlertsSet.add(a.Related_To__c);
        }
        AlertService alertObjServ = new AlertService();
        List<Alert__c> alertList = new List<Alert__c>();
        for(RFO_Projects__c project: projectsMap.values()){
            if(!existingAlertsSet.contains(project.Id))
                alertList.add(alertObjServ.createAlert('SOW_Proposal', null, null, null, null, project.Id, null, 'Please update SOW Proposal Status for '+project.Name));
        }
        if(alertList.size()>0) insert alertList;
        
    }
   //ALPHA-1748, Lakshmi Malepati    
    /* Method for exit criteria
* @param ordLst - trigger.new project list
* @param ordRecMap - trigger.oldMap project map
* @param isInsert - true if this method is being called on insert
* @param isUpdate - true if this method is being called on update
*
* ALPHA - 1748
*/
    
    Public static void exitForIsProject(Map<Id,RFO_Projects__c> projectsMap){
        Set<String> setOId = new Set<String>();
        Id existingCar = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        for(RFO_Projects__c objP: projectsMap.values()) {
            if(objP.Order__c != null) {
                setOId.add(objP.Order__c);
            }
        }
        if(!setOId.isEmpty()) {
            Map<Id, Order> mapO = new Map<Id, Order>([Select Id, RecordTypeId, Stop_Email_Notification_isProject__c, Is_Project_Required__c , 
                                                      (Select Id  From Projects__r), (Select Id, Status From Tasks Where RecordType.DeveloperName = 'Escalation' Order By CreatedDate DESC)
                                                      From Order Where RecordTypeId =: existingCar AND Id IN: setOId]);
            List<Order> lstExOrder = new List<Order>(); 
            List<Task> lstT = new List<Task>();
            for(RFO_Projects__c objP: projectsMap.values()) {
                if(objP.Order__c != null && mapO.containsKey(objP.Order__c) 
                   && mapO.get(objP.Order__c).Projects__r.size() > 0 && !mapO.get(objP.Order__c).Tasks.isEmpty()
                    && mapO.get(objP.Order__c).Is_Project_Required__c) { 
                        Order objO = mapO.get(objP.Order__c);
                        objO.Stop_Email_Notification_isProject__c = true;
                        lstExOrder.add(objO);
                }
            }
            if(!lstExOrder.isEmpty()) update lstExOrder;
        }
    }
}