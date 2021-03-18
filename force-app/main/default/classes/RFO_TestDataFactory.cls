/*
Author Name   : I. Martinez
Created Date  : August 15, 2019 
Description   : RFO_TestDataFactory

History
*
* 15JAUG2019 | I Martinez |  | Initial version 
*/
@isTest
public class RFO_TestDataFactory {

    /** @createRole: Returns the userRole object corresponding to the roleName
    *** Parameters: roleDevName, roleName, doInsert; 
    **/
    public static UserRole createRole(String roleDevName, String roleName, Boolean doInsert){
        UserRole userRole = new UserRole(DeveloperName = roleDevName, Name = roleName);
        if (doInsert) { Database.insert(userRole); }
        return userRole;
    }

    /** @getRole: Returns the userRole object corresponding to the DeveloperName
    *** Parameters: roleDevName, doInsert; 
    **/
    public static UserRole getRole(String roleDevName){
        UserRole userRole = [Select Id, Name, DeveloperName From UserRole where DeveloperName = :roleDevName Limit 1];
        return userRole;
    }

    /** @getProfile: Returns the ProfileId corresponding to the profileName
    *** Parameters: profileName; 
    **/
    public static Id getProfileId(String profileName){
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
        return profileId;
    }

    /** @getPermisionSetId: Returns the PermissionSetId corresponding to the permissionSetName
    *** Parameters: permissionSetName; 
    **/
    public static Id getPermisionSetId(String permissionSetName){
        Id psId = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1].Id;
        return psId;
    }

    /** @assignPermisionSet: Assigns a permission set to the user
    *** Parameters: permissionSetName, userId; 
    **/
    public static void assignPermisionSet(String permissionSetName, Id userId){
        Id psId = getPermisionSetId(permissionSetName);
        Database.insert(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = psId));
    }

    /** @createUser
    *** Parameters: profileName, roleName, doInsert; Returns User object
    **/
    public static User createUser(Id profileId, Id roleId, String userName, Boolean doInsert){
        User userRecord = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = userName,
            Username = userName,
            CompanyName = 'Testing Co',
            Title = 'testTitle',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = roleId
        );
        if (doInsert) { Database.insert(userRecord); }

        return userRecord;
    }

    /** @getRecordType: Returns the record type Id for the object and record type name
    *** Parameters: objectName, recordTypeName; Returns recordTypeId
    **/
    public static Id getRecordType(String objectName, String recordTypeName){
        Id recordTypeId = [Select id From RecordType Where sObjectType = :objectName 
                                                       and RecordType.Name = :recordTypeName Limit 1].Id;
        return recordTypeId;
    }

    /** @createAccount: Returns an account
    *** Parameters: Name, recordTypeName,doInsert; Returns Account
    **/
    public static Account createAccount(String name, Id recordTypeId, Boolean doInsert){
        Account newAccount = new account(
            Name = name,
            Description = 'TEST - Account Description',
            recordTypeid = recordTypeId,
            Phone = '999-999-9999',
            RFO_Region__c = 'Region 1',
            RFO_AccountStatus__c = 'Active'
        );
        
        if(doInsert){ Database.insert(newAccount); }

        return newAccount;
    }

    /** @createContract: Returns an Contract
    *** Parameters: Name, accountId,doInsert; Returns contract
    **/
    public static Contract createContract(String name, Id accountId, Boolean doInsert){
        Contract newContract = new Contract(
            AccountId = accountId,
            Name = name,
            Description = 'TEST - Contract Description',
            RFO_ContractDescription__c = name,
            RFO_ContractDate__c = date.today(),
            Status = RFO_Constant.CONTRACT_STAUS_NEW,
            RFO_Notes__c = 'TEST - Notes',
            RFO_ContractType__c = RFO_Constant.CONTRACT_TYPE_NET_LEASE
        );
        
        if(doInsert){ Database.insert(newContract); }

        return newContract;
    }

/* 
* custom setting insertion - #customSetting RFO_IntegrationLinks__c
*/
    @Future
    public static void createIntegrationLinks(String integrationLinkName, String integrationLinkvalue) {
        RFO_IntegrationLinks__c links = new RFO_IntegrationLinks__c();
        links.name = integrationLinkName;
        links.RFO_APILink__c = integrationLinkvalue;
        
        Database.insert(links);
    }
/* 
* custom setting insertion - #customSetting RFO_IntegrationLinks__c
*/
    @Future
    public static void asyncCreateCustomerAccount(String slsUserLanId) {
        // Create Commercial Customer Account for the Contract
        Id commercialAccountRTId = RFO_TestDataFactory.getRecordType(RFO_Constant.ACCOUNT_OBJECT, 'Customer');
        User slsUser = [Select Id From User Where Lan_Id__c = :slsUserLanId Limit 1];
        Account customerAcct = createAccount('TEST - Commercial Customer Account', commercialAccountRTId, false);
            customerAcct.OwnerId = slsUser.Id;
            customerAcct.CreatedbyId = slsUser.Id;
            customerAcct.LastModifiedById = slsUser.Id;
            customerAcct.RFO_SalesRepStartDate__c = Date.today();
            customerAcct.RFO_TASId__c = '8899';
            Database.insert(customerAcct);    
    }
}