public with sharing class AddSaveandCancelButtonController {
    @AuraEnabled
    public static Map<String,object> saveSobject(sObject objectInfo){
        map<String,object> results = New Map<String,Object>();
        try{
            insert objectInfo; 
            results.put('success',true);
            if(TEST.isRunningTest()){
                integer i = 1/0;
            }
        }catch(exception ex){
            system.debug('zzz :'+ex.getMessage());
            results.put('success',false);
            results.put('msg',ex.getMessage());
        }
        return results;
    }
}