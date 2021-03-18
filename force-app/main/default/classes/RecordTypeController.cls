public with sharing class RecordTypeController {
    @AuraEnabled
    public string defaultRecordTypeId {get; set;}
    @AuraEnabled
    public Map<Id, String> RecordTypes {get; set;}
    public RecordTypeController() {

    }
    @AuraEnabled(cacheable=true)    
    public static RecordTypeController getRecordTypeValues(String objectName){
        RecordTypeController obj = new RecordTypeController();
        Map<Id, String> recordtypeMap = new Map<Id, String>();
        //Get all record types of Contact object
        List<Schema.RecordTypeInfo> recordTypeInfoList = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();
        for(RecordTypeInfo info: recordTypeInfoList) {
            //Check record type is available for current user profile
            if(info.isAvailable()) {
                //Check master record type
                if(info.getName() != 'Master' && info.getName().trim() != ''){
                    recordtypeMap.put(info.getRecordTypeId(), info.getName());
                }
                //Get the default record type for current user profile
                if(info.isDefaultRecordTypeMapping()){
                    obj.defaultRecordTypeId = info.getRecordTypeId();
                }
            }
        }    
        obj.RecordTypes = recordtypeMap;
        return obj;
    }
}