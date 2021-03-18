/**********************************************************************************************************
Name: SecurityAuditUtils
(c) 2020 

Purpose: Class to provide data from Security_Report_Configuration__mdt and Profile to 
         populate Audit_Permissions__c with permssions

**********************************************************************************************************/

public with sharing class SecurityAuditUtils {

  public static List<String> PERSONA_LIST = new List<String>();
  public static List<String> SOBJECT_LIST = new List<String>();
  public static List<String> PERMISSIONSET_LIST = new List<String>();
  public static List<String> RECORDTYPE_LIST = new List<String>();
  
  public static List<String> getPersonaList() {
    //get Persona Names
    List<Security_Report_Configuration__mdt> personaExpValues = [SELECT Persona_Exception__c FROM Security_Report_Configuration__mdt WHERE Active__c = true AND Persona_Exception__c != null];
    List<String> personaExpList = new List<String>();
    if(personaExpValues.size() > 0){
        for(Security_Report_Configuration__mdt px : personaExpValues){
            personaExpList.add(px.Persona_Exception__c);
        }
    }
    List<Profile> personaNameList = [SELECT Name FROM Profile WHERE (Createdby.Profile.Name = 'System Administrator' OR Createdby.Profile.Name = 'Production Support') AND UserType = 'Standard' AND UserLicense.Name = 'Salesforce'
        AND Profile.Name NOT IN :personaExpList]; 
    string personaNames;
    if(personaNameList.size() > 0){
        for(Profile p : personaNameList){
            PERSONA_LIST.add(p.Name);
        }
    }  
    return PERSONA_LIST;
  }
  
  public static List<String> getsObjectList() {
    //get sObject List
    List<Security_Report_Configuration__mdt> sObjectValues = [SELECT sObject_Name__c FROM Security_Report_Configuration__mdt WHERE Active__c = true AND sObject_Name__c != null];
    string sObjectList;
    if(sObjectValues.size() > 0){
        for(Security_Report_Configuration__mdt src : sObjectValues){
            SOBJECT_LIST.add(src.sObject_Name__c);
        }
    }
    return SOBJECT_LIST;
  }  
    
  public static List<String> getPermissionSetList() {  
    //get Permissionset List
    List<Security_Report_Configuration__mdt> permissionSetValues = [SELECT Permission_Set_Name__c FROM Security_Report_Configuration__mdt WHERE Active__c = true AND Permission_Set_Name__c != null];
    string permissionSetList;
    if(permissionSetValues.size() > 0){
        for(Security_Report_Configuration__mdt ps : permissionSetValues){
            PERMISSIONSET_LIST.add(ps.Permission_Set_Name__c);
        }
    }  
    return PERMISSIONSET_LIST;
  }
  /*
  public static List<String> getObjectRecordTypes(Schema.SObjectType objType){
    //get Recordtypes available
    List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
    if(infos.size() > 0){
        if(infos.size() > 1) {
            for(RecordTypeInfo i : infos) {
               if(i.isAvailable()){ 
                   if(i.getName() != 'Master'){
                       RECORDTYPE_LIST.add(i.getName());
                   }
               }
            }
        } 
        else {
            if(infos[0].getName() != 'Master'){
                RECORDTYPE_LIST.add(infos[0].getName());
            }
        }
    }
    return RECORDTYPE_LIST;
  }
  
  public static Map<String,Map<String,String>> getObjectRecordTypesbyProfile(List<String> personaNameList){
      MetadataService.MetadataPort service = new MetadataService.MetadataPort();
      service.timeout_x = 120000; 
  
      service.SessionHeader = new MetadataService.SessionHeader_element();
      service.SessionHeader.sessionId = UserInfo.getSessionId();
      
      Map<String,Map<String,String>> recordTypeInfo = new Map<String,Map<String,String>>();

      if(personaNameList.size() > 0){
          for(String personaName : personaNameList){
              system.debug('Persona Name: ' + personaName);
              MetadataService.IReadResult readResult = service.readMetadata('Profile', new String[] { personaName });
              MetadataService.Metadata[] records = readResult.getRecords();
                
              MetadataService.Profile p = (MetadataService.Profile)records[0];
              
              Map<String,String> recTypeMap = new Map<String,String>();
              
              for(MetadataService.ProfileRecordTypeVisibility recType : p.recordTypeVisibilities){
                  List<String> splitRTName = new List<String>();
                  String recTypeName;
                  if(recType.visible){
                      splitRTName = recType.recordtype.split('\\.');
                      
                      //Eliminate unnecessary namespace objects/fields
                      if(!splitRTName[0].contains('__')){
                          recTypeName = Schema.getGlobalDescribe().get(splitRTName[0]).getDescribe().getRecordTypeInfosByDeveloperName().get(splitRTName[1]).getName();
                          recTypeMap.put(splitRTName[0], recTypeName); 
                      }
                  }
                  recordTypeInfo.put(personaName, recTypeMap);
              }  
          }
      }
      system.debug('RecordType Info All: ' + recordTypeInfo);
      return recordTypeInfo;
  }
  */
}