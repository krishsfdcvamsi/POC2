@IsTest
public with sharing class RFO_ContractSyncControllerTest {

    /* testSetup: test data setup to be used during testing */
    @TestSetup
    static void testSetup(){
        RFO_TestDataFactory.createIntegrationLinks(RFO_Constant.LABEL_URI_CONTRACT, RFO_Constant.APILINK_EX);

        // Get Profile Ids
        Id slsProfileId = RFO_TestDataFactory.getProfileId(RFO_Constant.PROFILE_RFO_SALES);
       Id contractProfileId = RFO_TestDataFactory.getProfileId(RFO_Constant.PROFILE_SYSTEM_ADMIN);

        // Get User Roles
        UserRole slsUserRole = RFO_TestDataFactory.getRole('Inside_Sales_30');
        UserRole contractUserRole = RFO_TestDataFactory.getRole('Sales_Customer_30');

        // Crete Sales and Contract users
        User slsUser = RFO_TestDataFactory.createUser(slsProfileId, slsUserRole.Id, 'testSlsUser@trin.net', false);
            slsUser.Lan_Id__c = 'FREYM_TST';
            Database.insert(slsUser);
        User contractUser = RFO_TestDataFactory.createUser(contractProfileId, contractUserRole.Id, 'testContractUser@trin.net', false);
            contractUser.Lan_Id__c = 'HARRISB2_TST';
            Database.insert(contractUser);

        // Assign the RFO OM Contract permission set to the contract user
        RFO_TestDataFactory.assignPermisionSet(RFO_Constant.RFO_OM_CONTRACT_PS, contractUser.Id);

        RFO_TestDataFactory.asyncCreateCustomerAccount('FREYM_TST');

    }

    /* contractSync_Positive1: test Contract creation by a contract user */
    @isTest static void contractSync_Positive1() {

    	List<Boolean> exceptions = new List<Boolean>();

        Account customerAcct = [Select Id, RFO_TASId__c From Account Where Name = 'TEST - Commercial Customer Account' Limit 1];
  
        String httpResponseBody = '{"contractId": "C-123456", "status": "success","message": "Contract created successfully"}';
        RFO_HTTPMockFactory mock = new RFO_HTTPMockFactory(200, 'Success', httpResponseBody, new Map<String,String>());
        
        Test.setMock(HttpCalloutMock.class, mock);

        User contractUser = [Select Id From User Where Lan_Id__c = 'HARRISB2_TST' Limit 1];
        // Id customerAccountId = [Select Id From Account Where Name = 'TEST - Commercial Customer Account' Limit 1].Id;
        System.runAs(contractUser){
            Test.startTest();
                Contract newContract = RFO_TestDataFactory.createContract('TEST - Contract Name', customerAcct.Id, true);
                RFO_ContractSyncController.syncContractToTAS(newContract.Id);
                
                Contract newContract2 = RFO_TestDataFactory.createContract('TEST - Existing Contract Name', customerAcct.Id, false);
                newContract2.RFO_ContractId__c = '1234';
                newContract2.RFO_ExecuteDate__c = Date.today();
                Database.insert(newContract2);
                RFO_ContractSyncController.syncContractToTAS(newContract2.Id);
            Test.stopTest();
            system.assert([Select Count() From Contract Where RFO_ContractDescription__c = 'TEST - Contract Name' Limit 10] != 0
                          , 'Contract user was unable to create Contract');
            system.assert([Select Count() From Contract Where RFO_ContractDescription__c = 'TEST - Existing Contract Name' Limit 10] != 0
                          , 'Contract user was unable to create Contract');
        }
    }
    /* contractSync_Positive2: test Contract creation with the Account TAS Id */
    @isTest static void contractSync_Positive2() {

    	List<Boolean> exceptions = new List<Boolean>();

        Account customerAcct = [Select Id, RFO_TASId__c From Account Where Name = 'TEST - Commercial Customer Account' Limit 1];
        customerAcct.RFO_TASId__c = null;
        Database.update(customerAcct);

  
        String httpResponseBody = '{"contractId": "C-123456", "status": "success","message": "Contract created successfully"}';
        RFO_HTTPMockFactory mock = new RFO_HTTPMockFactory(200, 'Success', httpResponseBody, new Map<String,String>());
        
        Test.setMock(HttpCalloutMock.class, mock);

        User contractUser = [Select Id From User Where Lan_Id__c = 'HARRISB2_TST' Limit 1];
        // Id customerAccountId = [Select Id From Account Where Name = 'TEST - Commercial Customer Account' Limit 1].Id;
        System.runAs(contractUser){
            Test.startTest();
                Contract newContract3 = RFO_TestDataFactory.createContract('TEST - Contract without Account.TASId', customerAcct.Id, true);
                RFO_ContractSyncController.syncContractToTAS(newContract3.Id);
            Test.stopTest();
            system.assert([Select Count() From Contract Where RFO_ContractDescription__c = 'TEST - Contract without Account.TASId' 
                                                          and RFO_ContractId__c = 'C-123456' Limit 10] == 0
                        , 'Contract user was able to create Contract');
        }
    }

    /* contractSync_Negative1: test Contract creation without the Contract Id returned */
    @isTest static void contractSync_Negative1() {

    	List<Boolean> exceptions = new List<Boolean>();

        Id customerAcctId = [Select Id From Account Where Name = 'TEST - Commercial Customer Account' Limit 1].Id;

        String httpResponseBody = '{"contractId": "", "status": "success","message": "Contract created successfully"}';
        RFO_HTTPMockFactory mock = new RFO_HTTPMockFactory(200, 'Success', httpResponseBody, new Map<String,String>());
        
        Test.setMock(HttpCalloutMock.class, mock);

        User contractUser = [Select Id From User Where Lan_Id__c = 'HARRISB2_TST' Limit 1];
        // Id customerAccountId = [Select Id From Account Where Name = 'TEST - Commercial Customer Account' Limit 1].Id;
        System.runAs(contractUser){
            Test.startTest();
                Contract newContract = RFO_TestDataFactory.createContract('TEST - Contract Name', customerAcctId, true);
                RFO_ContractSyncController.syncContractToTAS(newContract.Id);
            Test.stopTest();
            system.assert([Select Count() From Contract Where RFO_ContractDescription__c = 'TEST - Contract Name' 
                                                          and RFO_ContractId__c = null Limit 10] != 0
                        , 'Expected contract record without TAS Id');
        }
    }

    /* contractSync_Negative2: test Contract creation with 500 error returned */
    @isTest static void contractSync_Negative2() {

    	List<Boolean> exceptions = new List<Boolean>();

        Id customerAcctId = [Select Id From Account Where Name = 'TEST - Commercial Customer Account' Limit 1].Id;

        String httpResponseBody = '{"contractId": "", "status": "error","message": "Server Error"}';
        RFO_HTTPMockFactory mock = new RFO_HTTPMockFactory(500, 'Success', httpResponseBody, new Map<String,String>());
        
        Test.setMock(HttpCalloutMock.class, mock);

        User contractUser = [Select Id From User Where Lan_Id__c = 'HARRISB2_TST' Limit 1];
        // Id customerAccountId = [Select Id From Account Where Name = 'TEST - Commercial Customer Account' Limit 1].Id;
        System.runAs(contractUser){
            Test.startTest();
                Contract newContract = RFO_TestDataFactory.createContract('TEST - Contract Name', customerAcctId, true);
                RFO_ContractSyncController.syncContractToTAS(newContract.Id);
            Test.stopTest();
            system.assert([Select Count() From Contract Where RFO_ContractDescription__c = 'TEST - Contract Name'
                                                          and RFO_ContractId__c = null Limit 10] != 0
                        , 'Expected contract record without TAS Id');
        }
    }

    /* contractSync_Negative3: test Contract creation with 500 error returned */
    @isTest static void contractSync_Negative3() {

    	List<Boolean> exceptions = new List<Boolean>();

        Id customerAcctId = [Select Id From Account Where Name = 'TEST - Commercial Customer Account' Limit 1].Id;

        String httpResponseBody = '{"contractId": ""}';
        RFO_HTTPMockFactory mock = new RFO_HTTPMockFactory(500, 'Success', httpResponseBody, new Map<String,String>());
        
        Test.setMock(HttpCalloutMock.class, mock);

        User contractUser = [Select Id From User Where Lan_Id__c = 'HARRISB2_TST' Limit 1];
        // Id customerAccountId = [Select Id From Account Where Name = 'TEST - Commercial Customer Account' Limit 1].Id;
        System.runAs(contractUser){
            Test.startTest();
                Contract newContract = RFO_TestDataFactory.createContract('TEST - Contract Name', customerAcctId, true);
                RFO_ContractSyncController.syncContractToTAS(newContract.Id);
            Test.stopTest();
            system.assert([Select Count() From Contract Where RFO_ContractDescription__c = 'TEST - Contract Name'
                                                          and RFO_ContractId__c = null Limit 10] != 0
                        , 'Expected contract record without TAS Id');
        }
    }

    /* contractSync_Negative4: test Contract creation with 500 error returned */
    @isTest static void contractSync_Negative4() {

    	List<Boolean> exceptions = new List<Boolean>();

        Id customerAcctId = [Select Id From Account Where Name = 'TEST - Commercial Customer Account' Limit 1].Id;

        String httpResponseBody = 'Gateway timeout';
        RFO_HTTPMockFactory mock = new RFO_HTTPMockFactory(504, 'Success', httpResponseBody, new Map<String,String>());
        
        Test.setMock(HttpCalloutMock.class, mock);

        User contractUser = [Select Id From User Where Lan_Id__c = 'HARRISB2_TST' Limit 1];
        // Id customerAccountId = [Select Id From Account Where Name = 'TEST - Commercial Customer Account' Limit 1].Id;
        System.runAs(contractUser){
            Test.startTest();
                Contract newContract = RFO_TestDataFactory.createContract('TEST - Contract Name', customerAcctId, true);
                RFO_ContractSyncController.syncContractToTAS(newContract.Id);
            Test.stopTest();
            system.assert([Select Count() From Contract Where RFO_ContractDescription__c = 'TEST - Contract Name' 
                                                          and RFO_ContractId__c = null Limit 10] != 0
                        , 'Expected contract record without TAS Id');
        }
    }
}