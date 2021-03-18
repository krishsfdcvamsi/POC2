@isTest
public class DisplaySchedulesOrderControllerTest {
    public static list<CDX_ScheduleDetail__x> getScheduleDetail(string scheduleId) {
        
        list<CDX_ScheduleDetail__x> schList  = new list<CDX_ScheduleDetail__x>();
        
        CDX_ScheduleDetail__x schDetail0 = new CDX_ScheduleDetail__x();
        schDetail0.CDX_Projected_Cars_Complete__c = '1';
        schDetail0.CDX_Actual_Cars_Completed__c = '1';
        schDetail0.CDX_Actual_Cars_Shipped_by_Shop__c = '1';
        schDetail0.CDX_Schedule__c = scheduleId;
        schDetail0.CDX_Week__c = '450';
        
        CDX_ScheduleDetail__x schDetail1 = new CDX_ScheduleDetail__x();
        schDetail1.CDX_Projected_Cars_Complete__c = '1';
        schDetail1.CDX_Actual_Cars_Completed__c = '1';
        schDetail1.CDX_Actual_Cars_Shipped_by_Shop__c = '1';
        schDetail1.CDX_Schedule__c = scheduleId;
        schDetail1.CDX_Week__c = '451';
        
        schList.add(schDetail0);
        schList.add(schDetail1);
        
        return schList;
        
    }  

    static testMethod void scheduleTest() {
        Account acc = new Account(name='Test Account'); 
        insert acc;
        system.assertNotEquals(acc.Id, Null);
        
        contact con = new contact();
        con.AccountId = acc.Id;
        con.FirstName = 'Test';
        con.LastName = 'Contact 123';
        con.Email = 'abc@test.com';
        insert con;
        
        RFO_Projects__c testProj = new RFO_Projects__c();
        testProj.RFO_Account__c = acc.id;
        testProj.Name = 'testProject';
        testProj.RFO_ProjectId__c = '2312F';
        testProj.RA_Number__c = 'A123';
        insert testProj;
        
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
        
        system.assertNotEquals(testProj.Id, Null);
        
        order o = new order();
        o.RecordTypeId = Schema.SObjectType.order.getRecordTypeInfosByDeveloperName().get('RFO_ExistingCar').getRecordTypeId();
        o.AccountId = acc.id;
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
        o.RFO_RANumber__c = 'A123';
        insert o;
        
        List<CDX_Schedule__c> schList=new List<CDX_Schedule__c>();
        CDX_Schedule__c scheduleObj = new  CDX_Schedule__c();
        scheduleObj.Name = 'testschedule';
        scheduleObj.CDX_Project__c = testProj.id;
        scheduleObj.CDX_Shop_Name__c = 'testShop';
        scheduleObj.CDX_Shop_Location__c = 'testLocation';
        scheduleObj.Schedule_External_ID__c = '11286F';
        
        CDX_Schedule__c scheduleObj1 = new  CDX_Schedule__c();
        scheduleObj1.Name = 'testschedule';
        scheduleObj1.CDX_Project__c = testProj.id;
        scheduleObj1.CDX_Shop_Name__c = 'testShop';
        scheduleObj1.CDX_Shop_Location__c = 'testLocation';
        scheduleObj1.Schedule_External_ID__c = '11286G';
        
        schList.add(scheduleObj);
        schList.add(scheduleObj1);
        insert schList;  
        
        DisplaySchedulesOrderController.getProjectList(o.Id);

    }  
    

}