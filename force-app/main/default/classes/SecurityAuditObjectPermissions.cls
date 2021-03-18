/**********************************************************************************************************
Name: SecurityAuditObjectPermissions
(c) 2020 

Purpose: Class to populate Audit_Permissions__c with object permssions retrieved from 
         Security_Report_Configuration__mdt and Profile 

**********************************************************************************************************/

global class SecurityAuditObjectPermissions implements Database.Batchable<sObject> {
    
    @TestVisible private static Boolean batchExecute = true; 
    
     //get Security Configurations 
    List<String> SOBJECT_LIST = SecurityAuditUtils.getsObjectList();
    List<String> PERSONA_LIST = SecurityAuditUtils.getPersonaList();
    //Map<String,Map<String,List<String>>> RECORDTYPE_INFO = SecurityAuditUtils.getObjectRecordTypesbyProfile(PERSONA_LIST);
    
    List<Audit_Permissions__c> ap = new List<Audit_Permissions__c>();
    
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('PERSONA_LIST: ' + PERSONA_LIST);
        system.debug('SOBJECT_LIST: ' + SOBJECT_LIST);
        
        string queryObjPerms = 'SELECT Parent.Profile.Name,PermissionsCreate,PermissionsDelete,PermissionsEdit,PermissionsModifyAllRecords,PermissionsRead,PermissionsViewAllRecords,SobjectType ' +
            'FROM ObjectPermissions WHERE SobjectType IN ' +
               ':SOBJECT_LIST ' +
                'AND (ParentId ' +
                'IN (SELECT PermissionSetId ' +
                'FROM PermissionSetAssignment ' +
                'WHERE PermissionSet.Profile.Name IN :PERSONA_LIST))';
           
       if(test.IsRunningTest()) {
           queryObjPerms = queryObjPerms + ' LIMIT 10';
       }
        
        return Database.getQueryLocator(queryObjPerms);
    }
    
    global void execute(Database.BatchableContext bc, List<ObjectPermissions> scope){
        //system.debug('Object Permissions: ' + scope);
        //List<Audit_Permissions__c> ap = new List<Audit_Permissions__c>();
    
        //Populate Audit Permissions - objects
        if(scope.size() > 0){
            for(ObjectPermissions opPermissions : scope){
                Audit_Permissions__c populatePermissions = new Audit_Permissions__c();
                
                DescribeSObjectResult describe = Schema.getGlobalDescribe().get(opPermissions.SobjectType).getDescribe();
                
                populatePermissions.Persona_Name__c = opPermissions.Parent.Profile.Name;
                populatePermissions.Sobject_Name__c = opPermissions.SobjectType;
                populatePermissions.Sobject_Label__c = describe.getLabel();
                populatePermissions.Sobject_Type__c = 'ObjectPermissions';
                populatePermissions.Read_Access__c = opPermissions.PermissionsRead;
                populatePermissions.Edit_Access__c = opPermissions.PermissionsEdit;
                populatePermissions.Create_Access__c = opPermissions.PermissionsCreate;
                populatePermissions.Delete_Access__c = opPermissions.PermissionsDelete;
                populatePermissions.Modify_All_Access__c = opPermissions.PermissionsModifyAllRecords;
                populatePermissions.View_All_Access__c = opPermissions.PermissionsViewAllRecords;
                
                //Populate Audit Permissions - recordtypes assigned
                /*Schema.SObjectType objType = Schema.getGlobalDescribe().get(opPermissions.SobjectType);
                List<String> availableRecordTypes = SecurityAuditUtils.getObjectRecordTypes(objType);
                
                    if(availableRecordTypes.size() > 0){
                        for(String rtPermissions : availableRecordTypes){
                            Audit_Permissions__c populatePermissionsRT = new Audit_Permissions__c();
                            
                            populatePermissionsRT.Persona_Name__c = opPermissions.Parent.Profile.Name;
                            populatePermissionsRT.Sobject_Name__c = opPermissions.SobjectType;
                            populatePermissionsRT.Sobject_Label__c = describe.getLabel();
                            populatePermissionsRT.Sobject_Type__c = 'RecordType';
                            populatePermissionsRT.Permission__c = rtPermissions;
                            populatePermissionsRT.Read_Access__c = opPermissions.PermissionsRead;
                            populatePermissionsRT.Edit_Access__c = opPermissions.PermissionsEdit;
                            populatePermissionsRT.Create_Access__c = opPermissions.PermissionsCreate;
                            populatePermissionsRT.Delete_Access__c = opPermissions.PermissionsDelete;
                            populatePermissionsRT.Modify_All_Access__c = opPermissions.PermissionsModifyAllRecords;
                            populatePermissionsRT.View_All_Access__c = opPermissions.PermissionsViewAllRecords;
                            
                            ap.add(populatePermissionsRT);
                            //system.debug('Record Type Permissions: ' + availableRecordTypes);
                            recordsProcessed = recordsProcessed + 1;
                        }
                    } 
                    */
                    ap.add(populatePermissions);
                    //system.debug('Object Permissions: ' + populatePermissions);
                    recordsProcessed = recordsProcessed + 1;
                    system.debug('Records Processed ObjPerms: ' + recordsProcessed);
            }
            
            System.debug(recordsProcessed + ' number of records processed');
            system.debug('Audit Permissions List: ' + ap.size());
            if(ap.size() > 0){
                Database.Insert(ap, false);
            } 
        }   
    }    
    
    global void finish(Database.BatchableContext bc){
        //Batch chain execution - Field Permissions
        if(batchExecute){ 
            SecurityAuditFieldPermissions batchFieldPerms = new SecurityAuditFieldPermissions();
            ID batchIdFieldPerms = Database.executeBatch(batchFieldPerms,100);
        }
    }    
}