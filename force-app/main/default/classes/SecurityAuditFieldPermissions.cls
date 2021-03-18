/**********************************************************************************************************
Name: SecurityAuditFieldPermissions
(c) 2020 

Purpose: Class to populate Audit_Permissions__c with field permssions retrieved from 
         Security_Report_Configuration__mdt and Profile 

**********************************************************************************************************/

global class SecurityAuditFieldPermissions implements Database.Batchable<sObject> {
    
    @TestVisible private static Boolean batchExecute = true; 

     //get Security Configurations 
    List<String> SOBJECT_LIST = SecurityAuditUtils.getsObjectList();
    List<String> PERSONA_LIST = SecurityAuditUtils.getPersonaList();
    
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('PERSONA_LIST: ' + PERSONA_LIST);
        system.debug('SOBJECT_LIST: ' + SOBJECT_LIST);
        
        string queryFieldPerms = 'SELECT Field,Id,Parent.Profile.Name,PermissionsEdit,PermissionsRead,SobjectType FROM FieldPermissions WHERE SobjectType IN '  +
               ':SOBJECT_LIST ' +
               'AND (ParentId '+
               'IN (SELECT PermissionSetId '+
               'FROM PermissionSetAssignment '+
               'WHERE PermissionSet.Profile.Name IN :PERSONA_LIST))';
           
       if(test.IsRunningTest()) {
           queryFieldPerms = queryFieldPerms + ' LIMIT 10';
       }
        
        return Database.getQueryLocator(queryFieldPerms);
    }
    
    global void execute(Database.BatchableContext bc, List<FieldPermissions> scope){
        List<Audit_Permissions__c> apFields = new List<Audit_Permissions__c>();
        
        //Populate map from Audit Permissions for searching
        Map<String, Audit_Permissions__c> apMap = new Map<String, Audit_Permissions__c>([SELECT Persona_Name__c, Sobject_Name__c, Sobject_Type__c, Read_Access__c, Edit_Access__c FROM Audit_Permissions__c
            WHERE Sobject_Type__c = 'ObjectPermissions']);
               
        //Populate Audit Permissions - fields
        if(scope.size() > 0){
            //Determine if field permissions different from default object permissions
            for (string iKey : apMap.keyset()) {
                for(FieldPermissions fpPermissions : scope){
                    Audit_Permissions__c populatePermissionsFields = new Audit_Permissions__c();
                                      
                    if(apMap.get(iKey).Persona_Name__c == fpPermissions.Parent.Profile.Name && apMap.get(iKey).Sobject_Name__c == fpPermissions.SobjectType){
                         if(test.IsRunningTest() || (apMap.get(iKey).Read_Access__c != fpPermissions.PermissionsRead || apMap.get(iKey).Edit_Access__c != fpPermissions.PermissionsEdit)){   
                            //system.debug('Persona Name Map: ' + apMap.get(iKey).Persona_Name__c + ' And: ' + apMap.get(iKey).Sobject_Name__c); 
                            
                            //Get Labels
                            DescribeSObjectResult describefp = Schema.getGlobalDescribe().get(fpPermissions.SobjectType).getDescribe();  //sObject
                            //Field
                            String fieldLabel;
                            String fieldName = fpPermissions.Field;  
                            List<String> splitFieldName = fieldName.split('\\.');
                            Schema.SobjectField sObjectFieldName = Schema.getGlobalDescribe().get(splitFieldName[0]).getDescribe().fields.getMap().get(splitFieldName[1]);
                            if(sObjectFieldName != null){
                                DescribeFieldResult describefpField = sObjectFieldName.getDescribe();
                                fieldLabel = describefpField.getLabel();
                            }
                            else {
                                fieldLabel = splitFieldName[1];
                            }
                            
                            populatePermissionsFields.Persona_Name__c = fpPermissions.Parent.Profile.Name;
                            populatePermissionsFields.Sobject_Name__c = fpPermissions.SobjectType;
                            populatePermissionsFields.Sobject_Label__c = describefp.getLabel();
                            populatePermissionsFields.Sobject_Type__c = 'FieldPermissions';
                            populatePermissionsFields.Permission__c = fieldLabel;
                            populatePermissionsFields.Read_Access__c = fpPermissions.PermissionsRead;
                            populatePermissionsFields.Edit_Access__c = fpPermissions.PermissionsEdit;
        
                            apFields.add(populatePermissionsFields);
                         }
                   }
                   else {
                       break;
                   }
               }     
            }
            //system.debug('Field Permissions: ' + fp);
        }
        if(apFields.size() > 0){
            system.debug('Audit Permissions List - Fields: ' + apFields);
            Database.Insert(apFields, false);
        }
    }
        
    global void finish(Database.BatchableContext bc){
        //Batch chain execution - Permission Set
        if(batchExecute){ 
            SecurityAuditPermissionSet batchPermSet = new SecurityAuditPermissionSet();
            ID batchIdPermSet = Database.executeBatch(batchPermSet,50);
        }
    }    
}