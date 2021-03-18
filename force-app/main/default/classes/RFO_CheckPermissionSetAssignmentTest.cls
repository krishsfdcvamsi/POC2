/*
Author Name   : I. Martinez
Created Date  : August 15, 2019 
Description   : Test class

History
*
* 15JAUG2019 | I Martinez |  | Initial version 
*/
@IsTest
public with sharing class RFO_CheckPermissionSetAssignmentTest {
    /* testSetup: test data setup to be used during testing */
    @TestSetup
    static void testSetup(){

        // Get Profile Ids
        Id msProfileId = RFO_TestDataFactory.getProfileId(RFO_Constant.PROFILE_RFO_SALES);
        Id prodPlanProfileId = RFO_TestDataFactory.getProfileId(RFO_Constant.PROFILE_RFO_PORTFOLIO_CONTRACT_PRICING);

        // Get User Roles
        UserRole msUserRole = RFO_TestDataFactory.getRole('RFO_Business_Development_Mgt_Services_40');
        UserRole prodPlanUserRole = RFO_TestDataFactory.getRole('Production_Planning_60');

        // Crete Sales and Contract users
        User msUser = RFO_TestDataFactory.createUser(msProfileId, msUserRole.Id, 'testMgmtSrvcsUser@trin.net', false);
            msUser.Lan_Id__c = 'DAVISM_TST';
            Database.insert(msUser);
        User prodPlanUser = RFO_TestDataFactory.createUser(prodPlanProfileId, prodPlanUserRole.Id
                                                        , 'testProdPlanningUser@trin.net', false);
            prodPlanUser.Lan_Id__c = 'FLACKK_TST';
            Database.insert(prodPlanUser);

        // Assign the RFO OM Contract permission set to the contract user
        RFO_TestDataFactory.assignPermisionSet(RFO_Constant.PS_RFO_OM_MGMT_SRVCS, msUser.Id);
        RFO_TestDataFactory.assignPermisionSet(RFO_Constant.PS_RFO_OM_PROD_PLANNING, prodPlanUser.Id);

    }

    /* Positive test method*/
    @isTest static void chkPSA_Positive1() {

    	// List<Boolean> exceptions = new List<Boolean>();

        User prodPlanUser = [Select Id From User Where Lan_Id__c = 'FLACKK_TST' Limit 1];
        System.runAs(prodPlanUser){
            Test.startTest();
                List<RFO_CheckPermissionSetAssignment.CheckPermissionSetRequest> requests 
                                = new List<RFO_CheckPermissionSetAssignment.CheckPermissionSetRequest>();
                RFO_CheckPermissionSetAssignment.CheckPermissionSetRequest request 
                                = new RFO_CheckPermissionSetAssignment.CheckPermissionSetRequest();

                request.userId = prodPlanUser.Id;
                request.permissionSetName = RFO_Constant.PS_RFO_OM_PROD_PLANNING;
                requests.add(request);

                List<RFO_CheckPermissionSetAssignment.CheckPermissionSetResult> chkPSAResults 
                                = RFO_CheckPermissionSetAssignment.checkPermissionSetAssignment(requests);
            Test.stopTest();
            system.assert(chkPSAResults[0].permissionSetAssigned==true, 'Expected a true/positiive result');
        }
    }

    /* Negative test method*/
    @isTest static void chkPSA_Negative1() {

    	// List<Boolean> exceptions = new List<Boolean>();

        User msUser = [Select Id From User Where Lan_Id__c = 'DAVISM_TST' Limit 1];
        System.runAs(msUser){
            Test.startTest();
                List<RFO_CheckPermissionSetAssignment.CheckPermissionSetRequest> requests 
                                = new List<RFO_CheckPermissionSetAssignment.CheckPermissionSetRequest>();
                RFO_CheckPermissionSetAssignment.CheckPermissionSetRequest request 
                                = new RFO_CheckPermissionSetAssignment.CheckPermissionSetRequest();

                request.userId = msUser.Id;
                request.permissionSetName = RFO_Constant.PS_RFO_OM_PROD_PLANNING;
                requests.add(request);

                List<RFO_CheckPermissionSetAssignment.CheckPermissionSetResult> chkPSAResults 
                                = RFO_CheckPermissionSetAssignment.checkPermissionSetAssignment(requests);
            Test.stopTest();
            system.assert(chkPSAResults[0].permissionSetAssigned==false, 'Expected a false/negatiive result');
        }
    }
}