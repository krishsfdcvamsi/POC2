/**
*   Test Class : RFO_CreateRenewalManagementOptyBatchTest
**/
@isTest
private Class RFO_CreateRenewalManagementOptyBatchTest{
/**
*   Test method with test data to pass batch class
**/
     @TestSetup
    static void createRecords(){
    ID optyRenewalRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY).getRecordTypeId(); 
    ID optyMangmntServRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId();
       
    // Account Creation        
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        Database.insert(accList); 
        
        //contract Creation
             
        Contract contr = 
            new Contract(AccountId = accList[0].id, RFO_ContractType__c= RFO_Constant.TEST, RFO_ContractDate__c=system.today());
        Database.insert(contr);
        
        //Rider Creation
        RFO_Rider__c rider=new RFO_Rider__c();
        rider=RFO_Utility_Test.createrider();
        rider.RFO_Account__c=accList[0].id;
        rider.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
        rider.RFO_AutoRenewal__c = RFO_Constant.NO;
        rider.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider.RFO_RiderType__c = RFO_Constant.MANAGEMENT_AGREEMENT;
        rider.RFO_IncreaseEffectiveUpon__c = RFO_Constant.COMPLETION_OF_MODIFICATION;
        rider.RFO_Contract__c=contr.id;
        Database.Insert(rider);
        
        //Rider Creation
        RFO_Rider__c rider1=new RFO_Rider__c();
        rider1=RFO_Utility_Test.createrider();
        rider1.RFO_Account__c=accList[0].id;
        rider1.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
        rider1.RFO_AutoRenewal__c = RFO_Constant.NO;
        rider1.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider1.RFO_RiderType__c = RFO_Constant.OPP_TRANS_TYPE_NET_LEASE;
        rider.RFO_IncreaseEffectiveUpon__c = RFO_Constant.COMPLETION_OF_MODIFICATION;
        rider1.RFO_Contract__c=contr.id;
        Database.Insert(rider1);
        
        // Opportunity Creation     
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = RFO_Utility_Test.createTankOpportunities(accList[0]);
        oppList[0].Recordtypeid = optyRenewalRtId;
        oppList[0].StageName = RFO_Constant.INITIATED;   
        oppList[0].RFO_RiderID__c=rider.id;   
        Database.insert(oppList);
        
        
        
    }
/**
*   Test method ridercheck
**/
      private static testmethod void ridercheck() {
        
        RFO_Rider__c rider=[Select id from RFO_Rider__c Limit 1];
        Opportunity  opp =[Select id,RFO_RiderID__c from Opportunity Limit 1];
        RFO_CreateRenewalManagementOpty_Batch renewalmgmnt = new RFO_CreateRenewalManagementOpty_Batch();
          Test.startTest();
        DataBase.executeBatch(renewalmgmnt);
        Test.stopTest();
        System.assertEquals(opp.RFO_RiderID__c,rider.id);
    }
}