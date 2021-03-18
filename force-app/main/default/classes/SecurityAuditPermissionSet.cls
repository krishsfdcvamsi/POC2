/**********************************************************************************************************
Name: SecurityAuditPermissionSet
(c) 2020 

Purpose: Class to populate Audit_Permissions__c with permission set data retrieved from 
         Security_Report_Configuration__mdt

**********************************************************************************************************/

global class SecurityAuditPermissionSet implements Database.Batchable<sObject> {
    //get Security Configurations 
    List<String> SOBJECT_LIST = SecurityAuditUtils.getsObjectList();
    List<String> PERMISSIONSET_LIST = SecurityAuditUtils.getPermissionSetList();
    
    List<Audit_Permissions__c> apPS = new List<Audit_Permissions__c>();
    
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('PERMISSIONSET_LIST: ' + PERMISSIONSET_LIST);
        system.debug('SOBJECT_LIST: ' + SOBJECT_LIST);
        
        string queryPermissionSet = 'SELECT Label, ' +
        '(SELECT SobjectType,PermissionsCreate,PermissionsDelete,PermissionsEdit,PermissionsModifyAllRecords,PermissionsRead,PermissionsViewAllRecords FROM ObjectPerms WHERE SobjectType IN :SOBJECT_LIST), ' +
        '(SELECT SobjectType,Field,PermissionsRead, PermissionsEdit FROM FieldPerms WHERE SobjectType IN :SOBJECT_LIST), ' +
        '(SELECT AssigneeId,Assignee.Name FROM Assignments) ' +
        'FROM PermissionSet ' +
        'WHERE Label IN :PERMISSIONSET_LIST';
           
        if(test.IsRunningTest()) {
            queryPermissionSet = queryPermissionSet + ' LIMIT 10';
        }
        
        return Database.getQueryLocator(queryPermissionSet);
    }
    
     global void execute(Database.BatchableContext bc, List<PermissionSet> scope){
        //Populate Audit Permissions - permission sets
        if(scope.size() > 0){
            for(PermissionSet psPermissions : scope){
                
                //ObjectPerms
                for(ObjectPermissions obPerms : psPermissions.ObjectPerms){
                    Audit_Permissions__c populatePermissionsPSOb = new Audit_Permissions__c();
                    
                    //DescribeSObjectResult describeobPerms = Schema.getGlobalDescribe().get(obPerms.SobjectType).getDescribe();
                    
                    populatePermissionsPSOb.Persona_Name__c = psPermissions.Label;
                    populatePermissionsPSOb.Permission_Set__c = true;
                    populatePermissionsPSOb.Sobject_Name__c = obPerms.SobjectType;
                    //populatePermissionsPSOb.Sobject_Label__c = describeobPerms.getLabel();
                    populatePermissionsPSOb.Sobject_Type__c = 'ObjectPermissions';
                    populatePermissionsPSOb.Read_Access__c = obPerms.PermissionsRead;
                    populatePermissionsPSOb.Edit_Access__c = obPerms.PermissionsEdit;
                    populatePermissionsPSOb.Create_Access__c = obPerms.PermissionsCreate;
                    populatePermissionsPSOb.Delete_Access__c = obPerms.PermissionsDelete;
                    populatePermissionsPSOb.Modify_All_Access__c = obPerms.PermissionsModifyAllRecords;
                    populatePermissionsPSOb.View_All_Access__c = obPerms.PermissionsViewAllRecords;
                    
                    apPS.add(populatePermissionsPSOb);
                }
                
                //FieldPerms
                for(FieldPermissions fdPerms : psPermissions.FieldPerms){
                    Audit_Permissions__c populatePermissionsPSFd = new Audit_Permissions__c();
                    /*
                    //Get Labels
                    DescribeSObjectResult describefdPerms = Schema.getGlobalDescribe().get(fdPerms.SobjectType).getDescribe();  //sObject
                    //Field
                    String fieldLabel;
                    String fieldName = fdPerms.Field;  
                    List<String> splitFieldName = fieldName.split('\\.');
                    Schema.SobjectField sObjectFieldName = Schema.getGlobalDescribe().get(splitFieldName[0]).getDescribe().fields.getMap().get(splitFieldName[1]);
                    if(sObjectFieldName != null){
                        DescribeFieldResult describefdPermsField = sObjectFieldName.getDescribe();
                        fieldLabel = describefdPermsField.getLabel();
                    }
                    else {
                        fieldLabel = splitFieldName[1];
                    }
                    */
                    populatePermissionsPSFd.Persona_Name__c = psPermissions.Label;
                    populatePermissionsPSFd.Permission_Set__c = true;
                    populatePermissionsPSFd.Sobject_Name__c = fdPerms.SobjectType;
                    //populatePermissionsPSFd.Sobject_Label__c = describefdPerms.getLabel();
                    populatePermissionsPSFd.Sobject_Type__c = 'FieldPermissions';
                    //populatePermissionsPSFd.Permission__c = fieldLabel;
                    populatePermissionsPSFd.Permission__c = fdPerms.Field;
                    populatePermissionsPSFd.Read_Access__c = fdPerms.PermissionsRead;
                    populatePermissionsPSFd.Edit_Access__c = fdPerms.PermissionsEdit;
                    
                    apPS.add(populatePermissionsPSFd);
                }
                
                //Assignments
                for(PermissionSetAssignment assignPerms : psPermissions.Assignments){
                    Audit_Permissions__c populatePermissionsPSAssign = new Audit_Permissions__c();
                    
                    populatePermissionsPSAssign.Persona_Name__c = psPermissions.Label;
                    populatePermissionsPSAssign.Permission_Set__c = true;
                    populatePermissionsPSAssign.Sobject_Type__c = 'PermissionSetAssigned';
                    populatePermissionsPSAssign.Assigned_To__c = assignPerms.AssigneeId;
                    
                    apPS.add(populatePermissionsPSAssign);
                }
            }        
        }
        
        if(apPS.size() > 0){
            system.debug('Audit Permissions List - Permission Set: ' + apPS);
            Database.Insert(apPS, false);
        }      
    }
    
    global void finish(Database.BatchableContext bc){
    }    
}