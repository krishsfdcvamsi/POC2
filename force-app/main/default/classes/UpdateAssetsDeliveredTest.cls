/* Name: UpdateAssetsDeliveredTest
 * Created By: MA
 */

@isTest
public class UpdateAssetsDeliveredTest {
    @testSetup
  static void dataSetUp(){
       //Create Account
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
       account acc1 =new account();
       acc1.Name = 'BNSF';  // Account Name
         acc1.RecordTypeId = recordTypeIdAccount;           // Account Record Type
         acc1.Phone = '800-832-5452';         
        insert acc1;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountAccessLevel = 'Read';
        atm.TeamMemberRole = 'Customer Delivery Manager';
        atm.AccountId = acc1.Id;
        atm.UserId = userInfo.getUserId();
        insert atm;     
        
        //Creat Contact
        Contact c = new contact();
        c.AccountId = acc1.Id;
        c.LastName = 'Blah';
        c.FirstName = 'Blah';
        c.Phone = '9999999999';
        c.RFO_ContactRole__c = 'Legal Contact';
        c.Email = 'Test@test.com';
        insert c;
        
        //Create Commodity
        RFO_Commodity__c commodity = new RFO_Commodity__c();
        commodity.Name = 'TESTCOMMODITY';
        commodity.RFO_Active__c = True;
        insert commodity;
        
        //Create Product
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.IsActive = True;
        insert p;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true,
            Name = 'Standard Price Book'
        );
        
        update standardPricebook;
                
        //Create PricebookEntry
        PricebookEntry PBE = new PricebookEntry();
        PBE.IsActive = True;
        PBE.Product2Id = p.Id;
        PBE.Pricebook2Id = standardPricebook.Id;
        PBE.UnitPrice = 1;
        //PBE.UseStandardPrice = True;
        insert PBE;
        
        //Create Order
        order o = new order();
        o.RecordTypeId = Schema.SObjectType.order.getRecordTypeInfosByDeveloperName().get('RFO_ExistingCar').getRecordTypeId();
        o.AccountId = acc1.id;
        o.Type = 'Lease';
        o.Status = 'Initiated';
        o.RFO_ProposalRequired__c = 'Yes';
        o.RFO_SignedProposalDate__c = system.today();
        o.RFO_TankorFreight__c = 'Tank';
        o.EffectiveDate = system.today();
        o.RFO_JobCostDetails__c = 'Test';
        o.RFO_CarType__c = '200# CI  ';
        o.RFO_LeaseRate__c = 1;
        o.RFO_LeaseTerms__c = 1;
        o.RFO_Commodity_lookup__c = commodity.Id;
        o.RFO_Product__c = p.Id;
        o.RFO_Quantity__c = 1;
        o.RFO_SubType__c = 'Full Service';
        o.RFO_OrderReviewMeetingDate__c = system.today();
        insert o;
        
        asset assetSO = new asset();
        assetSO.AccountId = acc1.Id;
        assetSO.RFO_BeginChargeDate__c = system.today().addDays(10);
        assetSO.RFO_FileOrder__c = o.Id;
        assetSO.Name = 'Test Asset_34234';
        insert assetSO;
        
    }
    static testMethod void UpdateCdmNameMethod(){
        Account accountSO = new Account();
        AccountTeamMember atm = new AccountTeamMember();
        asset assetSO = new asset();
        accountSO = [SELECT Id,Name FROM Account];
        atm = [SELECT Id,accountId,TeamMemberRole FROM AccountTeamMember];
        Order o = new Order();
        o = [select id,status,recordtype.name from order];
        assetSO = [SELECT Id,RFO_FileOrder__c,RFO_BeginChargeDate__c FROM asset];
        UpdateAssetsDeliveredSch uadSch = new UpdateAssetsDeliveredSch();
        System.schedule('Test Sch_12543543','0 12 * * * ?',uadSch);
        
        UpdateAssetsDeliveredBatch assetbatch = new UpdateAssetsDeliveredBatch();
        Database.executeBatch(assetbatch);
    }
    
}