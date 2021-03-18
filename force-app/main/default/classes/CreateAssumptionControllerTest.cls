/* Class Name : CreateAssumptionControllerTest
 * Description : Test Class for all CreateAssumptionController class
 * Created By : Vihari Vanga
 * Created On : 11/09/20
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/09/20                    Vihari Vanga                       ALPHA - 22
 */

@isTest(SeeAllData = false)
private class CreateAssumptionControllerTest {

    static List<Account> listAccount;
    static List<RFO_Rider__c> objRiderList = new List<RFO_Rider__c>();

    static{
        createTestData();
    }

    static void createTestData(){
        // - Create Account
        listAccount = new List<Account>();
        listAccount = RFO_Utility_Test.createProspectAccounts();
        listAccount[0].Name = RFO_Constant.ACCOUNT_NAME;
        listAccount[1].Name = RFO_Constant.ACCOUNT_NAME_TEST;
        Database.insert(listAccount);
        // - Create Contract
        Contract objContract = new Contract(AccountId = listAccount[0].Id, RFO_ContractType__c = RFO_Constant.CONTRACT_TYPE_DIRECT_SALE, RFO_ContractDate__c = system.today());
        Database.insert(objContract);
        // - Create Riders
        RFO_Rider__c objRider = new RFO_Rider__c();
        objRider = RFO_Utility_Test.createrider();
        objRider.RFO_Account__c = listAccount[0].Id;
        objRider.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
        objRider.RFO_AutoRenewal__c = RFO_Constant.YES;
        objRider.RFO_OriginalMaturityDate__c = system.today().AddDays(2);
        objRider.RFO_RiderType__c = RFO_Constant.RIDER_TYPE;
        objRider.RFO_ProductType__c = RFO_Constant.TEST;
        objRider.RFO_Contract__c = objContract.id;
        objRider.RFO_TotalOfCars__c = 2; 
        objRider.RFO_TotalActiveCars__c = 5;
        objRiderList.add(objRider);
        
        RFO_Rider__c objRider2 = new RFO_Rider__c();
        objRider2 = RFO_Utility_Test.createrider();
        objRider2.RFO_Account__c = listAccount[0].Id;
        objRider2.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
        objRider2.RFO_AutoRenewal__c = RFO_Constant.YES;
        objRider2.RFO_OriginalMaturityDate__c = system.today().AddDays(2);
        objRider2.RFO_RiderType__c = RFO_Constant.RIDER_TYPE;
        objRider2.RFO_ProductType__c = RFO_Constant.TEST;
        objRider2.RFO_Contract__c = objContract.id;
        objRider2.RFO_TotalOfCars__c = 2; 
        objRider2.RFO_TotalActiveCars__c = 5;
        objRiderList.add(objRider2);
        
        Database.insert(objRiderList);
    }

    static testMethod void testGetAccountRiders(){
        Test.startTest();
        List<RFO_Rider__c> listRider = CreateAssumptionController.getAccountRiders(listAccount[0].Id);
        System.assertNotEquals(null, listRider);
        Test.stopTest();
    }

    static testMethod void testCreateAssumption(){
        Assumption__c objAssumption = new Assumption__c();
        objAssumption.Source_Account__c = listAccount[0].Id;
        objAssumption.Destination_Account__c = listAccount[1].Id;
        Test.startTest();
        CreateAssumptionController.AssumptionResult objAssumptionResult = CreateAssumptionController.createAssumption(objAssumption, new List<RFO_Rider__c>{objRiderList[0]}, new List<RFO_Rider__c>());
        System.assertNotEquals(null, objAssumptionResult);
        
        // Create another rider for same assumption
        
        CreateAssumptionController.AssumptionResult objAssumptionResult2 = CreateAssumptionController.createAssumption(objAssumption, new List<RFO_Rider__c>{objRiderList[1]}, new List<RFO_Rider__c>());
		System.assertNotEquals(null, objAssumptionResult2);
        Test.stopTest();
    }
    
    static testMethod void testCreateAssumptionFailed(){
        Assumption__c objAssumption = new Assumption__c();
        objAssumption.Source_Account__c = null;
        objAssumption.Destination_Account__c = listAccount[1].Id;
        Test.startTest();
        
        CreateAssumptionController.AssumptionResult objAssumptionResult = CreateAssumptionController.createAssumption(objAssumption, objRiderList, new List<RFO_Rider__c>());
        System.assertEquals(true, String.isNotBlank(objAssumptionResult.strErrorMessage));
        Test.stopTest();
    }
}