/* Name: OrderStatusUpdateHelperTest
 * Created By: Haseeb and Ramesh
 * Created Date: September 2020
 * Jira: ALpha- 520 & 521
 * Purpose: To test Order Status based on the Case and ChangeRequestLineItem Status.
 */

@isTest
public class OrderStatusUpdateHelperTest {
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
        insert ca;
        
        //Create Case[Change Request]
        Case ca1 = new Case();
        ca1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Existing Car Change Request').getRecordTypeId();
        ca1.AccountId = acc1.Id;
        ca1.RFO_ExistingCarChangeRequestType__c = 'Order Revision';
        ca1.status = 'Change Request Initiated';
        ca1.RFO_ChangeRequestReason__c = 'Other';
        ca1.RFO_ChangeType__c = 'Technical Spec Change';
        ca1.Origin = 'Customer Initiated';
        ca1.RFO_WhoPossessesCars__c = 'With Customer on Lease';
        ca1.RFO_NumberofCarsImpacted__c = 1;
        ca1.RFO_CarMarksNumber__c = 'Test';
        ca1.Description = 'Test';
        ca1.RFO_OrderID__c = o.Id;
        ca1.Status = 'Change Request Acknowledged';
        insert ca1;
        
        //Create Change Request Line Item
        RFO_ChangeRequestLineItem__c crli = new RFO_ChangeRequestLineItem__c();
        crli.RecordTypeId = Schema.SObjectType.RFO_ChangeRequestLineItem__c.getRecordTypeInfosByName().get('Existing Car Change Request Line Item').getRecordTypeId();
        crli.RFO_ChangeRequestID__c = ca.Id;
        crli.Name = 'Test CRLI';
        crli.RFO_PartDescription__c = 'Test';
        insert crli;
        
        RFO_ChangeRequestLineItem__c crli1 = new RFO_ChangeRequestLineItem__c();
        crli1.RecordTypeId = Schema.SObjectType.RFO_ChangeRequestLineItem__c.getRecordTypeInfosByName().get('Existing Car Change Request Line Item').getRecordTypeId();
        crli1.RFO_ChangeRequestID__c = ca.Id;
        crli1.Name = 'Test CRLI1';
        crli1.RFO_PartDescription__c = 'Test';
        //crli1.RFO_CustomerApproval__c = 'Rejected';
        crli1.Lease_Rate__c = 10.22;
        insert crli1;
    }
    static testMethod void testValidationOnOrder(){
        Order o = [select id,status,recordtype.name from order];
        o.status = 'Order in Process';
        test.startTest();
        try{
        	update o;
        }
        catch(exception e){
            system.assertEquals(e.getMessage().contains('Error: All change requests must be Acknowledged/Cancelled before changing order status'), true);
        }
        test.stopTest();
    }
    static testMethod void testValidationOnOrderComplete(){
        Order o = [select id,status,recordtype.name from order];
        o.status = 'Change Request Complete';
        test.startTest();
        try{
        	update o;
        }
        catch(exception e){
            system.assertEquals(e.getMessage().contains('Error: All change requests must be Approved/Rejected before changing order status'), true);
        }
        test.stopTest();
    }
    static testMethod void testOrderStatusUpdate(){
        list<RFO_ChangeRequestLineItem__c> CRLIs = [select id,RFO_CustomerApproval__c,RFO_ChangeRequestID__c from RFO_ChangeRequestLineItem__c];
        CRLIs[0].RFO_CustomerApproval__c = 'Approved';
        CRLIs[1].RFO_CustomerApproval__c = 'Rejected';
        Test.startTest();
        update CRLIs;
        system.assertEquals('Change Request Acknowledged', [select id,Status from case where id =: CRLIs[0].RFO_ChangeRequestID__c].Status);//Assert Case to Change Request Acknowledged
        System.assertEquals('Change Request Complete', [select id,Status from order].Status);//Assert Order to Change Request Complete
        CRLIs[0].RFO_CustomerApproval__c = 'Rejected';
        update CRLIs;
        system.assertEquals('Change Request Rejected', [select id,Status from case where id =: CRLIs[0].RFO_ChangeRequestID__c].Status);
        
        list<case> cases = [select id,Status from case];
        Cases[0].Status = 'Closed';
        Cases[1].Status = 'Closed';
        update cases;
        
        Cases[0].Status = 'Change Request Cancelled';
        update cases;
        System.assertEquals('Order in Process', [select id,Status from order].Status);//Assert Order to Order in Process
        Test.stopTest();
    }
    
}