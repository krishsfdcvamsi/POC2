/************************************************************************************************************************************************** 
 * Class Name : AlertJobChecker
 * Description : Update Alert Completion Status For Alert Notifications
 * Author : Haseeb
 * Created On : 10/19/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/19/20                    Haseeb                       	ALPHA - 771, Updates Alert status to Completed if the Related to Criteria is True.
 * 
 **************************************************************************************************************************************************/
global class AlertJobChecker implements Database.Batchable<sObject>, Schedulable {
    
    //map<objectName,fieldName> from Custom Metadata
    map<string,list<string>> objField = new map<string,list<string>>();
    
    global AlertJobChecker(){
        constructObjField();
    }
    //Returns all the alert records where completed flag is false
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Completed__c,Related_To__c,Related_To_Field_Name__c,Related_To_Object_Name__c FROM Alert__c where Completed__c = false';
        return Database.getQueryLocator(query);
    }
    //Updates alerts completed flag to true when related to object field flag is true
    global void execute(Database.BatchableContext BC, List<Alert__c>scope){
        map<String,list<string>> mapsObjectRecords = new map<string,list<string>>();
        map<string,sObject> mapObjectIdSobjectRec = new map<string,sObject>();
        mapsObjectRecords = getMapsObjectRecords(scope);
        mapObjectIdSobjectRec = getUpgradedMapSobjectRecord(mapsObjectRecords);
        Alert__c[] alertsToUpdate = updateAlerts(mapObjectIdSobjectRec, scope);
        if(alertsToUpdate.size() > 0)
            update alertsToUpdate;
    }
    global void finish(Database.BatchableContext BC){}
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AlertJobChecker());
    }
    //Constructs a map of object name and list of field names from custom metadata type alert settings
    global void constructObjField(){
        list<Alert_Setting__mdt> alertSettingList = [select DeveloperName,Object_Name__c,Field_name__c from Alert_Setting__mdt];
        for(Alert_Setting__mdt es : alertSettingList){
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
    //Returns a map of object name and list of record Ids for each object
    public map<String,list<string>> getMapsObjectRecords(list<Alert__c> scope){
        map<String,list<string>> mapsObjectRecords = new map<string,list<string>>();
        for(Alert__c a : scope){
            if(!mapsObjectRecords.containsKey(a.Related_To_Object_Name__c)){
                list<string> recordList = new list<string>();
                recordList.add(a.Related_To__c);
                mapsObjectRecords.put(a.Related_To_Object_Name__c,recordList);
            }
            else{
                list<string> listIdRecords = mapsObjectRecords.get(a.Related_To_Object_Name__c);
                listIdRecords.add(a.Related_To__c);
                mapsObjectRecords.put(a.Related_To_Object_Name__c,listIdRecords);
            }
            //system.debug('~~ Map: '+mapsObjectRecords);
            
        }
        return mapsObjectRecords;
    }
    //Returns a map of record Id and sObject
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
    //Returns a list of Alert records to be updated
    public list<Alert__c> updateAlerts(map<String,sObject> mapObjectIdSobjectRec, list<Alert__c> scope){
        list<Alert__c> AlertsToUpdate = new list<Alert__c>();
        for(Alert__c a : scope){
            if(a.Related_To_Field_Name__c != null && mapObjectIdSobjectRec.containsKey(a.Related_To__c) && mapObjectIdSobjectRec.get(a.Related_To__c).get(a.Related_To_Field_Name__c) == True){
                a.Completed__c = True;
                AlertsToUpdate.add(a);
            }
        }
        return AlertsToUpdate;
    }
}