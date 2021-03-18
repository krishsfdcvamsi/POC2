@isTest
public class CDX_CommunityUtilityExtTest
{
   static testMethod void CDX_CommunityUtilityExtTest() 
    {   
        Account acc = new Account();
        acc.Name='Test 1';
        insert acc;
        
        Set<id> accountIds=new Set<id>();
        accountIds.add(acc.Id);
        
       
        
        Contact con=new Contact();
        con.AccountId = acc.Id;
        con.FirstName = 'Test1';
        con.LastName = 'Contact 1234';
        con.Email = 'abcd@test.com';
        con.CDX_Project_Notification_Preference__c = True;
        insert con;
        
        RFO_Projects__c testProj = new RFO_Projects__c();
        testProj.RFO_Account__c = acc.id;
        testProj.Name = 'testProject';
        insert testProj;
        
        system.assertNotEquals(testProj.Id, Null);
        
        CDX_Schedule__c scheduleObj = new  CDX_Schedule__c();
        scheduleObj.Name = 'testschedule';
        scheduleObj.CDX_Project__c = testProj.id;
        scheduleObj.CDX_Shop_Name__c = 'testShop';
        scheduleObj.CDX_Shop_Location__c = 'testLocation';
        insert scheduleObj;
        
       
        
        Test.startTest();
        List<CDX_ScheduleDetail__x> scheduleExternalList = new List<CDX_ScheduleDetail__x>();
        
        CDX_ScheduleDetail__x scheduleExternal = new CDX_ScheduleDetail__x();
        scheduleExternal.CDX_Projected_Customer_Release__c='10';
        scheduleExternal.CDX_Actual_Customer_Release__c='3';
        scheduleExternal.CDX_Actual_Cars_Arrived__c='2';
        //scheduleExternal.CDX_Average_Turn_Time__c='abc';
        scheduleExternal.CDX_Projected_Arrival__c='10.00';
        scheduleExternal.CDX_Projected_Cars_Complete__c='2';
       // scheduleExternal.CDX_WeekStartDate__c=Date.Today();
         
        scheduleExternalList.add(scheduleExternal);
        Test.stopTest();
        
        CDX_CommunityUtilityExt.GetWeekIds();
        CDX_CommunityUtilityExt.PrepareEmailBodyforSubscribedContacts(scheduleExternalList);
        //   CDX_CommunityUtility.SendEmailforAllEligibleContacts(accountIds,fakeDetailsList);
        String emailBody= CDX_CommunityUtilityExt.PrepareEmailBodyforSubscribedContacts(scheduleExternalList);
        // CDX_CommunityUtility.SendEmailforAllEligibleContacts(accountIds,scheduleExternalList);
        CDX_CommunityUtilityExt.SendEmailforAllSubscribedContacts(acc.Id,emailBody);
    } 
    
}