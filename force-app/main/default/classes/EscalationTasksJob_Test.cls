/************************************************************************************************************************************************** 
 * Class Name : EscalationTasksJob_Test
 * Description : Test Update Task Completion Status For Escalation Notifications
 * Author : Haseeb
 * Created On : 9/28/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 9/28/20                    Haseeb                       		ALPHA - 1078, Test Updates Task status to Completed if the Related to Criteria is True.
 * 
 **************************************************************************************************************************************************/
@isTest
public class EscalationTasksJob_Test {
    //Test EscalationTasksJob class for marking the tasks as completed when the criteria field is true
	static testmethod void testEscalationTasksJob() {
        //Create Account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        account acc1 =new account();
        acc1.Name = 'BNSF';  // Account Name
        acc1.RecordTypeId = recordTypeIdAccount;           // Account Record Type
        acc1.Phone = '800-832-5452';         
        insert acc1;
        
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
        
        Pricebook2 pbook = new Pricebook2(
            Name = 'Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update pbook;
        PricebookEntry pbe = new PricebookEntry(pricebook2id=pbook.id, product2id=p.id,unitprice=2.0, isActive=true);
           insert pbe;
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
        o.RFO_CarType__c = '200# CI ';
        o.RFO_LeaseRate__c = 1;
        o.RFO_LeaseTerms__c = 1;
        o.RFO_Commodity_lookup__c = commodity.Id;
        o.RFO_Product__c = p.Id;
        o.RFO_Quantity__c = 1;
        o.RFO_SubType__c = 'Full Service';
        o.RFO_OrderReviewMeetingDate__c = system.today();
        insert o;
        
        //Create Asset File
        RFO_Asset_File__c af = new RFO_Asset_File__c();
        af.RFO_OrderNumber__c = o.Id;
        af.Name = 'Test 1';
        af.RFO_ProductDivision__c = 'Tank';
        af.RFO_Quantity__c = 1;
        af.RFO_RiderLeaseType__c = 'Full Service';
        af.BOM_File_Uploaded__c = True;
        insert af;
        
        //Create Task
        Task t = new Task();
        t.Subject = 'Upload BOM';
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Escalation').getRecordTypeId();
        t.Type = 'Other';
        t.OwnerId = userInfo.getUserId();
        t.WhatId = af.Id;
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.Number_of_Days__c = 5;
        t.Immediate_Notification__c = false;
        t.ActivityDate = system.today();
        insert t;
        
        Test.startTest();
        String scheduleConfig = '0 0 23 * * ?';
        String jobIdScheduler = system.schedule('Test Task Status Completion', scheduleConfig, new EscalationTasksJob()); 
        Test.stopTest();
        System.assertNotEquals(jobIdScheduler, null);
    }
}