/***************************
* @author :Krishna V--
  This is Test Class for Sending Weekly mails for Project Scheduled Release Cars
*/
@isTest
private class CDX_WeeklyEmailScheduleDetailExtTest 
{
    
    @isTest
    public static void cdxWeeklyEmailScheduleDetailExt(){
        try{
           // Database.executeBatch(new CDX_WeeklyEmailScheduleDetailExt());
        }
        catch(Exception e){
            
        }
    }
    static testMethod void CDX_WeeklyEmailScheduleDetailExtTest() 
    {
        TrinityWeek__mdt myMdt= new TrinityWeek__mdt();
        myMdt.WeekID__c='393';
        myMdt.WeekStartDate__c=Date.today().addDays(-7);
        myMdt.BusinessDays__c='5';
        myMdt.WeekEndDate__c=Date.today();
        myMdt.Label='Testmdt';
        system.debug('testweekdata'+myMdt);
        
        Set<String> weekIds  = new Set<String>();
        Date weekstartdate=Date.today().addDays(-7);
        
        List<TrinityWeek__mdt> mdtList = [SELECT Label, WeekID__c, WeekStartDate__c, WeekEndDate__c, BusinessDays__c from TrinityWeek__mdt where WeekStartDate__c >= :weekstartdate ];
        System.debug('mdtList'+mdtList);
        
        for(TrinityWeek__mdt mdt:mdtList ){
            weekIds.add(mdt.WeekID__c);  
        }
        system.debug('weekid'+weekIds);
        //insert myMdt;
        
        List<Account> lstAccount= new List<Account>();
        for(Integer i=0 ;i <20;i++)
        {
            Account acc = new Account();
            acc.Name ='SAG Name '+i;
            lstAccount.add(acc);
        }
        insert lstAccount;
        Integer iCount=1;
        List<Contact> lstContact=new List<Contact>();
       for(Account accnt:lstAccount )      
       {
        contact con = new contact();
        con.AccountId = accnt.Id;
        con.FirstName = 'Test';
        con.LastName = 'Contact 123';
        con.Email = 'abc'+iCount+'@test.com';
        con.CDX_Project_Notification_Preference__c = True;
        lstContact.add(con);
        iCount++;
       }
        insert lstContact;
        Integer jCount=1;
        list<RFO_Projects__c> lstProjects =new list<RFO_Projects__c>();
        for(Account accnt:lstAccount )      
       { 
        RFO_Projects__c testProj = new RFO_Projects__c();
        testProj.RFO_Account__c = accnt.id;
        testProj.Name = 'testProject '+jCount;
        lstProjects.add(testProj);
            jCount++;
       }
          insert lstProjects;  
        Integer kCount=1;
        List<CDX_Schedule__c> scheduleObjList=new List<CDX_Schedule__c>();
         CDX_Schedule__c scheduleObj = new  CDX_Schedule__c();
        
        for(RFO_Projects__c testProj:lstProjects )      
        { 
         
        scheduleObj = new  CDX_Schedule__c();
        scheduleObj.Name = 'testschedule '+ kCount;
        scheduleObj.CDX_Project__c = testProj.id;
        scheduleObj.CDX_Shop_Name__c = 'testShop';
        scheduleObj.CDX_Shop_Location__c = 'testLocation';
        scheduleObj.Schedule_External_ID__c = '124567'+kCount;
           
        scheduleObjList.add(scheduleObj);
        kCount++;
        }   
        insert scheduleObjList;
        Set<String> scheduleIds;
         if(scheduleObjList.size()>0)
            scheduleIds = (new Map<String,SObject>(scheduleObjList)).keySet();
        List<String> lstSchIds = new List<String>(scheduleIds);

        system.assertNotEquals(scheduleIds, Null); 
        
       // Test.setMock(HttpCalloutMock.class, new CDX_ScheduleExternalCalloutMock()); 
        
            /*CDX_ScheduleExternal__x objScheduleDetailExt= new CDX_ScheduleExternal__x();

            objScheduleDetailExt.CDX_Week__c=  myMdt.WeekID__c;
            objScheduleDetailExt.CDX_Schedule__c=scheduleObj.id;
            objScheduleDetailExt.CDX_Projected_Customer_Release__c=3;
            objScheduleDetailExt.CDX_Actual_Customer_Release__c=4;
            objScheduleDetailExt.CDX_Average_Turn_Time__c='2';
            objScheduleDetailExt.CDX_Projected_Arrival__c=2; 
            objScheduleDetailExt.CDX_Projected_Cars_Complete__c=1;
            Database.insertAsync(objScheduleDetailExt) ;
            
            system.assertNotEquals(objScheduleDetailExt.Id, Null);
        
               
        List<CDX_ScheduleExternal__x> lstScheduleDetail=[Select ExternalId,CDX_Schedule__r.CDX_Shop_Location__c, CDX_Schedule__r.Name, CDX_Week__c, CDX_Projected_Customer_Release__c, CDX_Schedule__r.CDX_Project__r.RFO_Account__c from  CDX_ScheduleExternal__x where (CDX_Week__c IN :weekIds )];
        system.debug('fk========================='+lstScheduleDetail);
        */
      Test.startTest();
        
        List<CDX_ScheduleDetail__x> lstScheduleList=new List<CDX_ScheduleDetail__x>();
        CDX_ScheduleDetail__x objScheduleExternal1= new CDX_ScheduleDetail__x ();
        objScheduleExternal1.ExternalId='TestobjScheduleExternal1';
        if(weekIds.size()>0) {
            objScheduleExternal1.CDX_Week__c = new list<string>(weekIds)[0];
        }
        else {
            objScheduleExternal1.CDX_Week__c='393';
        }

        objScheduleExternal1.CDX_Schedule__c=lstSchIds[0];
        objScheduleExternal1.CDX_Projected_Customer_Release__c='3';
        objScheduleExternal1.CDX_Actual_Customer_Release__c='4';
        //objScheduleExternal1.CDX_Average_Turn_Time__c='2';
        objScheduleExternal1.CDX_Projected_Arrival__c='2'; 
        objScheduleExternal1.CDX_Projected_Cars_Complete__c='1';
        objScheduleExternal1.CDX_Schedule__c = '1245671';
        lstScheduleList.add(objScheduleExternal1);
        
        CDX_ScheduleDetail__x objScheduleExternal2= new CDX_ScheduleDetail__x ();
        objScheduleExternal2.ExternalId='TestobjScheduleExternal2';
        if(weekIds.size()>1){
            objScheduleExternal2.CDX_Week__c= new list<string>(weekIds)[1];
        }
        else {
            objScheduleExternal1.CDX_Week__c='393';
        }

        objScheduleExternal2.CDX_Schedule__c=lstSchIds[1];
        objScheduleExternal2.CDX_Projected_Customer_Release__c='3';
        objScheduleExternal2.CDX_Actual_Customer_Release__c='4';
        //objScheduleExternal2.CDX_Average_Turn_Time__c='2';
        objScheduleExternal2.CDX_Projected_Arrival__c='2'; 
        objScheduleExternal2.CDX_Projected_Cars_Complete__c='1';
      
        
        CDX_ScheduleDetailExternalModel.mockedScheduleExternal.add(objScheduleExternal1);
        CDX_ScheduleDetailExternalModel.mockedScheduleExternal.add(objScheduleExternal2);
        List<CDX_ScheduleDetail__x> lstScheduleListTest= CDX_ScheduleDetailExternalModel.findScheduleExternalById(scheduleIds,weekIds) ;
        system.assertNotEquals(lstScheduleListTest, Null);
        CDX_WeeklyEmailScheduleDetailExt batch = new CDX_WeeklyEmailScheduleDetailExt();
        DataBase.executeBatch(batch); 
        Database.QueryLocator ql = batch.start(null);
        batch.execute(null,scheduleObjList);
        //  batch.Finish(null);
        String sch = '0  00 1 3 * ?';
        system.schedule('Test Schedule', sch, batch);
        
        Test.stopTest(); 
        
    }  
    
}