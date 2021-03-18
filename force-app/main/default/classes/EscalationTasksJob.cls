/************************************************************************************************************************************************** 
 * Class Name : EscalationTasksJob
 * Description : Update Task Completion Status For Escalation Notifications
 * Author : Haseeb
 * Created On : 9/26/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 9/26/20                    Haseeb                       		ALPHA - 1078, Updates Task status to Completed if the Related to Criteria is True.
 * 
 **************************************************************************************************************************************************/

global class EscalationTasksJob implements Database.Batchable<sObject>, Schedulable{
    
    //map<objectName,fieldName> from Custom Metadata
    map<string,list<string>> objField = new map<string,list<string>>();
    
    //Alpha-1078, Haseeb, Constructs a map of object name and field name from custom metadata escalation settings
    global EscalationTasksJob(){
        constructObjField();
    }
    //Alpha-1078, Haseeb, Returns all the tasks that are not completed with record type Escalation
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,subject, Whatid,what.type,recordtype.name,Escalation_Setting_Field_Name__c FROM Task where status != \'Completed\' and recordType.name = \'Escalation\' and whatid != null';
        return Database.getQueryLocator(query);
    }
    
    //Alpha-1078, Haseeb, Updates each task record to completed if the related to record criteria is met.
    global void execute(Database.BatchableContext BC, List<task>scope){
        map<String,list<string>> mapsObjectRecords = new map<string,list<string>>();
        map<string,sObject> mapObjectIdSobjectRec = new map<string,sObject>();
        mapsObjectRecords = getMapsObjectRecords(scope);
        mapObjectIdSobjectRec = getUpgradedMapSobjectRecord(mapsObjectRecords);
        list<Task> tasksToUpdate = updateTasks(mapObjectIdSobjectRec,scope);
        if(tasksToUpdate.size() > 0)
            update tasksToUpdate;
        
    }
    
    global void finish(Database.BatchableContext BC){}
    //Alpha-1078, Haseeb, Executes Batch Job
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EscalationTasksJob());
    }
    //Alpha-1078, Haseeb, Constructs a map of object and list of Fields
    global void constructObjField(){
        list<Escalation_Setting__mdt> escalationSettings = [select DeveloperName,Object_Name__c,Field_name__c from Escalation_Setting__mdt];
        for(Escalation_Setting__mdt es : escalationSettings){
            if(es.Object_Name__c != null && es.Field_name__c != null){
                if(!objField.containsKey(es.Object_Name__c)){
                    list<string> fieldNames = new list<string>();
                    fieldNames.add(es.Field_name__c);
                	objField.put(es.Object_Name__c, fieldNames);
                }
                else{
                    list<string> fieldNames = objField.get(es.Object_Name__c);
                    fieldNames.add(es.Field_name__c);
                    objField.put(es.Object_Name__c, fieldNames);
                }
            }
                
        }
    }
    //Alpha-1078, Haseeb, Returns a map<sobjects,ListofRecordsId> related to tasks
    public map<String,list<string>> getMapsObjectRecords(list<task> scope){
        map<String,list<string>> mapsObjectRecords = new map<string,list<string>>();
        for(task t : scope){
            if(!mapsObjectRecords.containsKey(t.what.type)){
                list<string> recordList = new list<string>();
                recordList.add(t.WhatId);
                mapsObjectRecords.put(t.what.type,recordList);
            }
            else{
                list<string> listIdRecords = mapsObjectRecords.get(t.what.type);
                listIdRecords.add(t.WhatId);
                mapsObjectRecords.put(t.what.type,listIdRecords);
            }
            //system.debug('~~ Map: '+mapsObjectRecords);
        
    }
        return mapsObjectRecords;
    }
    
    //Alpha-1078, Haseeb, Returns an Upgraded mapsObjectRecord map<objectName, List<sObject>>
    public map<string,sObject> getUpgradedMapSobjectRecord(map<String,list<string>> mapsObjectRecords){
        map<string,sObject> mapObjectIdSobjectRec = new map<string,sObject>();
        for(string s : mapsObjectRecords.keySet()){
            if(s != null  && objField.get(s) != null){
                list<string> recids = mapsObjectRecords.get(s);
                set<string> setObjField = new set<string>(objField.get(s));
                string query = 'Select id, '+string.join(new list<string>(setObjField),',') +' From ' + s +' where id in :recids';
                list<sObject> obj = database.query(query);
                for(sObject o : obj){
                	mapObjectIdSobjectRec.put(o.id, o);
                }
            }
        }
        return mapObjectIdSobjectRec;
    }
    //Alpha-1078, Haseeb, Returns a list of tasks to update if the related to record criteria is true
    public list<task> updateTasks(map<String,sObject> mapObjectIdSobjectRec, list<task> scope){
        list<task> tasksToUpdate = new list<task>();
        for(Task t : scope){
            if(t.Escalation_Setting_Field_Name__c != null && mapObjectIdSobjectRec.containsKey(t.WhatId) && mapObjectIdSobjectRec.get(t.WhatId).get(t.Escalation_Setting_Field_Name__c) == True){
                t.Status = 'Completed';
                tasksToUpdate.add(t);
            }
        }
        return tasksToUpdate;
    }
}