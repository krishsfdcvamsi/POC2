/* Class Name : ChangeRequestPricingRefreshBatchTest
 * Description : Test class for ChangeRequestPricingRefreshBatch
 * Created By : Vihari Vanga
 * Created On : 2/11/21
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 2/11/21                    Vihari Vanga                       EPSI-459
 */
@isTest(seeAllData=false)
public class ChangeRequestPricingRefreshBatchTest {
	@testSetup
	static void dataSetUp(){
       //Create Account
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
	   	account acc1 =new account();
	   	acc1.Name = 'BNSF';  // Account Name
       	acc1.RecordTypeId = recordTypeIdAccount;           // Account Record Type
       	acc1.Phone = '800-832-5452';         
        insert acc1;
        
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
        o.RecordTypeId = Schema.SObjectType.order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        o.AccountId = acc1.id;
        o.Type = 'Lease';
        o.Status = 'Initiated';
        o.RFO_ProposalRequired__c = 'Yes';
        o.RFO_SignedProposalDate__c = system.today();
        o.RFO_TankorFreight__c = 'Tank';
        o.EffectiveDate = system.today();
        o.RFO_JobCostDetails__c = 'Test';
        o.RFO_CarType__c = '200# CI	';
        o.RFO_LeaseRate__c = 1;
        o.RFO_LeaseTerms__c = 1;
        o.RFO_Commodity_lookup__c = commodity.Id;
        o.RFO_Product__c = p.Id;
        o.RFO_Quantity__c = 1;
        o.RFO_SubType__c = 'Full Service';
        o.RFO_OrderReviewMeetingDate__c = system.today();
        insert o;
        
        //Create Case[Change Request]
        List<Case> cList = new List<Case>();
        Case ca = new Case();
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Existing Car Change Request').getRecordTypeId();
        ca.AccountId = acc1.Id;
        ca.RFO_ExistingCarChangeRequestType__c = 'Order Revision';
        ca.status = 'Change Request Initiated';
        ca.RFO_ChangeRequestReason__c = 'Other';
        ca.RFO_ChangeType__c = 'Technical Spec Change';
        ca.Origin = 'Customer Initiated';
        ca.RFO_WhoPossessesCars__c = 'With Customer on Lease';
        ca.RFO_NumberofCarsImpacted__c = 1;
        ca.RFO_CarMarksNumber__c = 'Test';
        ca.Description = 'Test';
        ca.RFO_OrderID__c = o.Id;
        cList.add(ca);
        
        //Create Case[Change Request]
        Case ca1 = new Case();
        ca1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Existing Car Change Request').getRecordTypeId();
        ca1.AccountId = acc1.Id;
        ca1.RFO_ExistingCarChangeRequestType__c = 'Order Revision';
        ca1.status = 'Change Request Rejected';
        ca1.RFO_ChangeRequestReason__c = 'Other';
        ca1.RFO_ChangeType__c = 'Technical Spec Change';
        ca1.Origin = 'Customer Initiated';
        ca1.RFO_WhoPossessesCars__c = 'With Customer on Lease';
        ca1.RFO_NumberofCarsImpacted__c = 1;
        ca1.RFO_CarMarksNumber__c = 'Test';
        ca1.Description = 'Test';
        ca1.RFO_OrderID__c = o.Id;
        cList.add(ca1);
        insert cList;
        
       
        
        List<RFO_ChangeRequestLineItem__c> crlilist = new List<RFO_ChangeRequestLineItem__c>();
        //Create Change Request Line Item
        RFO_ChangeRequestLineItem__c crli = new RFO_ChangeRequestLineItem__c();
        crli.RecordTypeId = Schema.SObjectType.RFO_ChangeRequestLineItem__c.getRecordTypeInfosByName().get('Existing Car Change Request Line Item').getRecordTypeId();
        crli.RFO_ChangeRequestID__c = cList[0].Id;
        crli.Name = 'Test CRLI';
        crli.RFO_PartDescription__c = 'Test';
        crli.RFO_PriceAmount__c = 100.00;
        crli.Pricing_Expiry_Date__c = System.Today();
        crlilist.add(crli);
        
        
        RFO_ChangeRequestLineItem__c crli1 = new RFO_ChangeRequestLineItem__c();
        crli1.RecordTypeId = Schema.SObjectType.RFO_ChangeRequestLineItem__c.getRecordTypeInfosByName().get('Existing Car Change Request Line Item').getRecordTypeId();
        crli1.RFO_ChangeRequestID__c = cList[0].Id;
        crli1.Name = 'Test CRLI1';
        crli1.RFO_PartDescription__c = 'Test';
        //crli1.RFO_CustomerApproval__c = 'Rejected';
        crli1.Lease_Rate__c = 10.22;
        crli1.RFO_PriceAmount__c = 325.00;
        crli1.Pricing_Expiry_Date__c = System.Today()+1;
        crlilist.add(crli1);
        
        RFO_ChangeRequestLineItem__c crli2 = new RFO_ChangeRequestLineItem__c();
        crli2.RecordTypeId = Schema.SObjectType.RFO_ChangeRequestLineItem__c.getRecordTypeInfosByName().get('Existing Car Change Request Line Item').getRecordTypeId();
        crli2.RFO_ChangeRequestID__c = cList[1].Id;
        crli2.Name = 'Test CRLI1';
        crli2.RFO_PartDescription__c = 'Test';
        crli2.Lease_Rate__c = 10.22;
        crli2.RFO_PriceAmount__c = 325.00;
        crli2.Pricing_Expiry_Date__c = System.Today();
        crlilist.add(crli2);
        insert crlilist;
    }
    
    private static testMethod void testExecute(){
        Test.StartTest();
        ChangeRequestPricingRefreshBatch crprBatch = new ChangeRequestPricingRefreshBatch();
        String scheduleConfig = '0 0 2 * * ?';
        String jobIdScheduler = system.schedule('Test Change Pricing Refresh',scheduleConfig, new ChangeRequestPricingRefreshBatch());
        crprBatch.execute(null); 
        Test.stopTest();
        
        List<Case> cases = [Select id, Status from Case];
        System.assertEquals(RFO_Constant.Order_Status_Materials_Planning,Cases[0].Status);
    } 
    
}