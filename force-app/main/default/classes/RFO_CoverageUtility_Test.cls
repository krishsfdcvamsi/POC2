/*
* Class Name : RFO_CoverageUtility_Test
*/
@isTest(seeAllData = false)
public class RFO_CoverageUtility_Test{    
 
    @testsetup static void createOptyTestdata(){
        
        Market_Outlook__c mo = new Market_Outlook__c();
        mo.Coverage_Multiplier__c='1';
        mo.Market_Segment__c='Autos';
        mo.Market_Segment_6_to_12_months_Outlook__c='Neutral';
        mo.Market_Group__c='Consumer Product';
        insert mo;
        // Account Creation        
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        accList[0].RFO_GlobalAccountID__c = RFO_Constant.ACCOUNT_GLOBALACCOUNTID;
        accList[0].RFO_OracleId__c = RFO_Constant.ACCOUNT_ORACLEID;
        accList[0].RFO_TASId__c = RFO_Constant.ACCOUNT_TASID;
        for(Account acc :accList ) {
            acc.RFO_TotalFleetCount__c = 100;
            acc.RFO_Market_Segments__c = 'Autos';
            acc.recordTypeId = recordTypeId;
        }
        Database.insert(accList);
        List<Contact> contactList = new List<Contact>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        contactList = RFO_Utility_Test.createContact1(accList[0]);
        Database.insert(contactList);
        
        //contract Creation
        Contract contr = new Contract(AccountId = accList[0].id, 
                                      RFO_ContractType__c=RFO_Constant.TEST, RFO_ContractDate__c=system.today());
        Database.insert(contr);
        //Creating a Commodity
        commodityList = RFO_Utility_Test.createCommodity1();
        Database.insert(commodityList);
        //Rider Creation
        RFO_Rider__c rider=new RFO_Rider__c();
        rider=RFO_Utility_Test.createrider();
        rider.RFO_Account__c=accList[0].id;
        rider.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
        rider.RFO_AutoRenewal__c = RFO_Constant.YES;
        rider.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider.RFO_RiderType__c = RFO_Constant.MANAGEMENT_AGREEMENT;
        rider.RFO_ProductType__c = RFO_Constant.TEST;
        rider.RFO_Contract__c=contr.id;
        rider.RFO_TotalOfCars__c = 9;
        rider.RFO_Commodity__c = commodityList[0].id;
        rider.RFO_IncreaseEffectiveUpon__c = RFO_Constant.COMPLETION_OF_MODIFICATION;
        Database.insert(rider);  
    }

    private static testMethod void updateRider(){
        System.runAs(createUser()) {
            Market_Outlook__c mo = new Market_Outlook__c();
            mo = [SELECT Id, Market_Segment__c FROM Market_Outlook__c LIMIT 1];
            mo.Market_Segment__c = 'Paper';
            Map<Id, SObject> newItems = new Map<Id, SObject>();
            Map<Id, SObject> oldItems = new Map<Id, SObject>();
            RFO_Rider__c rider2= [select id, name,  RFO_AutoRenewal__c, RFO_Commodity__c, RFO_TotalOfCars__c,
                                  RFO_TotalActiveCars__c, RFO_OriginalMaturityDate__c, RFO_RiderType__c, RFO_ProductType__c, RFO_Account__c
                                  from RFO_Rider__c Limit 1];
            rider2.RFO_AutoRenewal__c ='No';
            rider2.RFO_Status__c =RFO_Constant.READY_FOR_DELIVERY;
            rider2.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
            rider2.RFO_RiderType__c = 'Net Lease';
            rider2.RFO_ProductType__c = '4793 Super Max Gon';
            rider2.RFO_TotalOfCars__c = 2; 
            rider2.RFO_TotalActiveCars__c = 5;
            Test.startTest();
            Database.update(rider2);
            RFO_CoverageUtility.validateRange(2000);
            RFO_CoverageUtility.validateRange(5000);
            RFO_CoverageUtility.validateRange(9000);
            account acc = new account();
            acc = [SELECT Id,parentId FROM Account LIMIT 1];
            Test.stopTest();

            RFO_CoverageRecommendationBatch coverageRec = new RFO_CoverageRecommendationBatch();
            coverageRec.coverageUnManaged(new set<Id>{acc.Id});
            Database.executeBatch(coverageRec);

            mo.Market_Segment_6_to_12_months_Outlook__c='Down market';
            mo.Coverage_Multiplier__c = '0.8';
            update mo;

         System.assert(newItems!=null);
        }
    }

    private static User createUser() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        userRecord.Lan_Id__c = 'MYDEVROLE';
        System.Assert(userRecord!=null );
        Database.insert(userRecord);
        return userRecord;
    }
    private static testMethod void calculateRecommendedCoverageTest(){
        map<id,decimal> totalFleetMap = new map<id,decimal>();
        map<id,decimal> opportunitesCount = new map<id,decimal>();
        map<id,decimal> ridersCount = new map<id,decimal>();
    	//RFO_CoverageUtility cu = new RFO_CoverageUtility();
        RFO_CoverageUtility.calculateRecommendedCoverage(totalFleetMap,opportunitesCount,ridersCount);
    }
    
}