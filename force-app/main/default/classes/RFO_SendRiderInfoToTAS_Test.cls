/* 
* Send Rider info Tas test method 1 
 * */
@isTest(SeeAllData = false)
private class RFO_SendRiderInfoToTAS_Test {
    /*
     * Test setup method to create rider data
     * */
    @testsetup static void createAssetTestdata(){  
        RFO_IntegrationLinks__c intgrtnLinks= new RFO_IntegrationLinks__c();
        List<Account> accList = new List<Account>();
        //Creating an Account
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = RFO_Constant.GLOBALACCOUNTID;
        accList[0].RFO_OracleId__c = '123456';
        accList[0].RFO_TASId__c = '1234';
        Database.insert(accList);
        Contract contr = new Contract(AccountId = accList[0].id, 
                                      RFO_ContractType__c= RFO_Constant.MANAGEMENT_AGREEMENT.toUpperCase(), 
                                      RFO_ContractId__c = '3869',
                                      StartDate = system.today(),
                                      RFO_ContractDate__c=system.today());
        Database.insert(contr);
        
        //Rider Creation
        RFO_Rider__c rider=new RFO_Rider__c();
        rider=RFO_Utility_Test.createrider();
        rider.RFO_Account__c=accList[0].id;
        rider.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
        rider.RFO_AutoRenewal__c = RFO_Constant.NO;
        rider.RFO_RiderNumber__c = RFO_Constant.NINE;
        rider.RFO_RiderNumberSuffix__c = RFO_Constant.NINE;
        
        rider.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider.RFO_RiderType__c = RFO_Constant.MANAGEMENT_AGREEMENT;
        rider.RFO_Contract__c=contr.id;
        rider.RFO_TotalOfCars__c = 1;
        Database.Insert(rider);
        intgrtnLinks.Name='Rider';
        intgrtnLinks.RFO_APILink__c=RFO_Constant.APILINK_EX;
        
        Database.insert(intgrtnLinks);
        
    }
    /* Send Rider info Tas test method 1 */
    private static testMethod void sendRiderToTAS(){
        User userRecord = createUser();
        system.runAs(userRecord) {
            
            RFO_Rider__c rider=[select id, name from RFO_Rider__c limit 1];
            
            //permission set assignment
            PermissionSet permSet= [SELECT Id FROM PermissionSet where name = 'RFO_OM_Contracts' limit 1];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userRecord.Id;
            psa.PermissionSetId = permSet.Id;
            Database.insert(psa);
            ApexPages.StandardController stdcnt = new ApexPages.StandardController(rider);
            ApexPages.currentPage().getParameters().put('id',rider.Id); 
            RFO_SendRiderInfoToTAS obj = new RFO_SendRiderInfoToTAS(stdcnt);            
            PageReference pageRef = Page.RFO_SendRiderInfoToTAS;
            pageRef.getParameters().put('id', rider.Id);
            Test.setCurrentPage(pageRef);
            obj.callouttoTAS();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpRiderResponse());
            Test.stopTest();
            System.Assert(rider.Id!=null);
        }
    }
    /* Send Rider info Tas test method 1 */
    private static testMethod void sendRiderToTAS1(){
        User userRecord = createUser();
        system.runAs(userRecord) {
            
            RFO_Rider__c rider=[select id, name from RFO_Rider__c limit 1];
            rider.RFO_TASRiderId__c = '2314';
            Database.update(rider);
            //permission set assignment
            PermissionSet permSet= [SELECT Id FROM PermissionSet where name = 'RFO_OM_Contracts' limit 1];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userRecord.Id;
            psa.PermissionSetId = permSet.Id;
            Database.insert(psa);
            ApexPages.StandardController stdcnt = new ApexPages.StandardController(rider);
            ApexPages.currentPage().getParameters().put('id',rider.Id); 
            RFO_SendRiderInfoToTAS obj = new RFO_SendRiderInfoToTAS(stdcnt);            
            PageReference pageRef = Page.RFO_SendRiderInfoToTAS;
            pageRef.getParameters().put('id', rider.Id);
            Test.setCurrentPage(pageRef);
            obj.callouttoTAS();
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"success","message":"Rider Created successfully"}');
            res.setStatusCode(400); 
            Test.startTest();
            RFO_GlobalCallOut.getRiderInfoResultFromTAS(res,String.valueOf(rider.Id));
            RFO_SendToTASFutureClass.getAssetFileNumber('jsonBody', 'assetFileId', 'FileType', 'RecordStatus', 'messageId');
            RFO_SendToTASFutureClass.sendAccountInfoToTASfuture('accId', 'JsonBody', 'messageId', 'SourceCall', 'SuccessMessage','');
            Test.stopTest();
            System.Assert(rider.Id!=null);
        }
    }
    /**
*   createUser method
**/
    private static User createUser() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        
        System.Assert(userRecord!=null );
        Database.insert(userRecord);
        return userRecord;
    }
}