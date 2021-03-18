@isTest
global class CDX_ProjectFindScheduleExtTest implements HTTPCalloutMock
{
    global HTTPResponse respond(HTTPRequest request)
    {
        
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
         
        
   response.setBody('{"scheduleId":"a2o540000002YcZAAU"}');
     return response;
    }  

 static testMethod void scheduleTest() 
    {
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
        insert testProj;
        
        system.assertNotEquals(testProj.Id, Null);
                
        CDX_Schedule__c scheduleObj = new  CDX_Schedule__c();
        scheduleObj.Name = 'testschedule';
        scheduleObj.CDX_Project__c = testProj.id;
        scheduleObj.CDX_Shop_Name__c = 'testShop';
        scheduleObj.CDX_Shop_Location__c = 'testLocation';
        scheduleObj.Schedule_External_ID__c = 'test123';

        
        
        insert scheduleObj;
        
       
        
        List<CDX_Schedule__c> schList=new List<CDX_Schedule__c>();
        schList.add(scheduleObj);
        system.assertNotEquals(scheduleObj.Id, Null);   
        
         
        
      CDX_ProjectFindScheduleExt.getScheduleInfo(testProj.id);
      CDX_ProjectFindScheduleExt.getProject(testProj.id);
      CDX_ProjectFindScheduleExt.approveAllSchedules(testProj.id,'Test Comment');       
      CDX_ProjectFindScheduleExt.rejectAllSchedules(testProj.id,'Test Comment'); 
     CDX_ProjectFindScheduleExt.getScheduleDetails(scheduleObj.Name);
       CDX_ProjectFindScheduleExt.PendingSchedules(testProj.id);
        CDX_ProjectFindScheduleExt.ScheduleDetailsWrapper sch=new CDX_ProjectFindScheduleExt.ScheduleDetailsWrapper();
        CDX_ProjectFindScheduleExt.ScheduleDetailsWrapper sch1=new CDX_ProjectFindScheduleExt.ScheduleDetailsWrapper();
        //sch1.compareTo(sch);
          CDX_ProjectFindScheduleExt.ReturnCSV(testProj.id);
        
    }  
    

}