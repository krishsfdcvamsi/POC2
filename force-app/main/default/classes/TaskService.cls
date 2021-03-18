/************************************************************************************************************************************************** 
 * Class Name : TaskService
 * Description : Service class for task creation and SOQL.
 * Author : Haseeb
 * Created On : 9/30/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 9/30/20                    Haseeb                       		ALPHA - 1078, Creates Escaltion Task from the passed in values.

 * 11/06/20                   Vihari                            ALPHA - 932          

 **************************************************************************************************************************************************/

global class TaskService {
    //Creates a map of escalation setting label and eslation setting metadata record
     global map<String,Escalation_Setting__mdt> mapEscalationSetting = new map<String,Escalation_Setting__mdt>();

    String taskRecordTypeId;
    public TaskService(){
        taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Escalation').getRecordTypeId();

        list<Escalation_Setting__mdt> escalationSettings = [select MasterLabel,Assigned_To__c,Business_Days__c,Escalation_1__c,Escalation_1_Criteria_Days__c,
                                                            Escalation_2__c,Escalation_2_Criteria_Days__c,Immediate_Notification__c,Immediate_Notification_Body__c,
                                                            Immediate_Notification_Title__c,Notification_Body__c,
                                                            Notification_Title__c,Notification_2_Body__c,Notification_2_Title__c,Task_Record_Type_ID__c,
                                                            Update_Assigned_To_When_Escalated__c,Task_Subject__c,
                                                            DeveloperName,Object_Name__c,Field_name__c from Escalation_Setting__mdt];
        for(Escalation_Setting__mdt es : escalationSettings){
            mapEscalationSetting.put(es.MasterLabel, es);
        }
        system.debug('~~~ Map Escalation: '+mapEscalationSetting);
    }
    //Returns Escalation Task based on the passed in values
    public Task createTaskEscalation(String escalationLabel, 
                                     Date calculationFromDate, 
                                     String assignedTo, 
                                     String escalation1AssignedTo, 
                                     String escalation2AssignedTo, 
                                     String relatedTo
                                    , String notificationMergeBody, 
                                     String notificationMergeTitle){
        System.debug('~~ Create Task');
        Task T = new Task();
        T.Escalation_Setting_Field_Name__c = mapEscalationSetting.get(escalationLabel).Field_name__c;

        T.RecordTypeId = taskRecordTypeId;

        T.Task_Job_Daily__c = TRUE;
        T.WhatId = relatedTo;
        T.Type = 'Other';                                
        T.Status = 'Not Started';
        if(notificationMergeBody != null)
        	T.Notification_Merge__c = notificationMergeBody;
        if(notificationMergeTitle != null)
            T.Notification_Merge_Title__c = notificationMergeTitle;
        T.Update_Assigned_To_When_Escalated__c = mapEscalationSetting.get(escalationLabel).Update_Assigned_To_When_Escalated__c;
        T.Subject = mapEscalationSetting.get(escalationLabel).Task_Subject__c;
        if(calculationFromDate != null)
        	T.ActivityDate = calculationFromDate;
        else
            T.ActivityDate = system.today();
        T.Business_Days__c = mapEscalationSetting.get(escalationLabel).Business_Days__c;
        //Assinged To
        if(assignedTo != null)
        	T.OwnerId = assignedTo;
        else
            T.OwnerId = mapEscalationSetting.get(escalationLabel).Assigned_To__c;
        //Escalation 1
        if(escalation1AssignedTo != null)
            T.Escalation_1_Assigned_To_Value__c = escalation1AssignedTo;
        else
            T.Escalation_1_Assigned_To_Value__c = mapEscalationSetting.get(escalationLabel).Escalation_1__c;
        //Escalation 2
        if(escalation2AssignedTo != null)
            T.Escalation_2_Assigned_To_Value__c = escalation2AssignedTo;
        else
            T.Escalation_2_Assigned_To_Value__c = mapEscalationSetting.get(escalationLabel).Escalation_2__c;
        //Escalation 1 Criteria Days
        T.Number_of_Days__c = mapEscalationSetting.get(escalationLabel).Escalation_1_Criteria_Days__c;
        //Escalation 2 Criteria Days
        T.Escalation_2_Criteria_Days__c = mapEscalationSetting.get(escalationLabel).Escalation_2_Criteria_Days__c;
        //Notification Settings
        T.Immediate_Notification__c = mapEscalationSetting.get(escalationLabel).Immediate_Notification__c;
        T.Immediate_Notification_Title__c = mapEscalationSetting.get(escalationLabel).Immediate_Notification_Title__c;
        T.Immediate_Notification_Body__c = mapEscalationSetting.get(escalationLabel).Immediate_Notification_Body__c;
        T.Notification_1_Title__c = mapEscalationSetting.get(escalationLabel).Notification_Title__c;
        T.Notification_1_Body__c = mapEscalationSetting.get(escalationLabel).Notification_Body__c;
        T.Notification_2_Title__c = mapEscalationSetting.get(escalationLabel).Notification_2_Title__c;
        T.Notification_2_Body__c = mapEscalationSetting.get(escalationLabel).Notification_2_Body__c;
        return T;
    }


    //Alpha-678, Haseeb


    public static list<task> getExistingUMLERTasks(set<Id> assetFileIds){
        list<task> existingTasks = new list<task>();
        existingTasks = [Select Id,WhatId,Description,Escalation_Setting_Field_Name__c from task 
                         where WhatId in: assetFileIds and RecordType.name = 'Escalation' and 
                         Escalation_Setting_Field_Name__c = 'UMLER_Status_Updated__c' and Status != 'Completed'];
        return existingTasks;
    }

    //End, Alpha-678
    

    public Task createTask(String subject, 
                           String status, 
                           String priority, 
                           String relatedTo, 
                           String ownerId){
        Task tsk 		= new Task();
        tsk.Subject 	= subject;
        tsk.Status 		= String.isNotBlank(status)?status:RFO_Constant.Task_Status_Open;
        tsk.Priority 	= String.isNotBlank(priority)?priority:RFO_Constant.Task_Priority_Normal;
        tsk.WhatId 		= relatedTo;
        tsk.OwnerId 	= ownerId;
        return tsk;
    }



}