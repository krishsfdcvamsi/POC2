public with sharing class lwcCustomLookupController {
    @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        system.debug(fieldName+'-------------'+ObjectName+'---++----------'+value);
        if(String.isNotEmpty(value))
            for(sObject so : Database.Query('Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\' LIMIT 10')) {
                String fieldvalue = (String)so.get(fieldName);
                sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
            }
        system.debug('sObjectResultList>>>>>>'+sObjectResultList);
        return sObjectResultList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getResultsWithParent(String ObjectName, 
                                                 String fieldName, 
                                                 String ParentField,
                                                 String ParentId,
                                                 String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        system.debug(fieldName+'-------------'+ObjectName+'---++----------'+value);
        String Query = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+ ParentField + ' = \'' + ParentId + '\' AND '+ fieldName+' LIKE \'%' + value + '%\' LIMIT 10';
        system.debug('Query>>>>>>>>>'+Query);
        if(String.isNotEmpty(value))
            
            for(sObject so : Database.Query('Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+ ParentField + ' = \'' + ParentId + '\' AND '+ fieldName+' LIKE \'%' + value + '%\' LIMIT 10')) {
                String fieldvalue = (String)so.get(fieldName);
                sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
            }
        system.debug('sObjectResultList>>>>>>'+sObjectResultList);
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
}