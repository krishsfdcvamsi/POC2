global without sharing class CDX_ProjectFindScheduleExt 
{
    
    global class ScheduleDetailsWrapper {   //implements Comparable
        @AuraEnabled
        public Date StartDate;
        @AuraEnabled
        public String StartDateFormatted;
        @AuraEnabled
        public String ActualCarsArrived; 
        @AuraEnabled
        public String ActualCarsCompleted;
        @AuraEnabled
        public String ActualCustomerRelease;
        @AuraEnabled
        public String ProjectedCarsArrived;
        @AuraEnabled
        public String ProjectedCarsCompleted;
        @AuraEnabled
        public String ProjectedCustomerRelease;
        @AuraEnabled
        public String OGID;
        @AuraEnabled
        public String ActualCarsShipped;    //Added by MA BETA-233    
        
        //removed code by MA for BETA-233, Ascending in the query itself, so no need of a compareTo
        // Compare opportunities based on the opportunity amount.
        /*global Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
          
            
            ScheduleDetailsWrapper Compare = (ScheduleDetailsWrapper)compareTo;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if(StartDate == NULL && Compare.StartDate != NULL)
            {
                returnValue = 1;
            }
            //System.debug('Comparing: '+StartDate+'  and  '+Compare.StartDate);
            if (StartDate > Compare.StartDate) {
                // Set return value to a positive value
                returnValue = 1;
            } else if (StartDate < Compare.StartDate) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            return returnValue;      
        }*/
    }
 
    @AuraEnabled(cacheable=false)
    public static List<CDX_Schedule__c> getScheduleInfo(String ProjectID) {
        //Gets schedules based on project id inserted
        List<CDX_Schedule__c> Schlee = [SELECT ID, Schedule_External_ID__c, CDX_Project__c,Status__c,CDX_Approved_Rejected_By__c,CDX_Approved_Rejected_Date__c, 
                                        Name,CDX_Rejected_Date__c, CDX_Shop_Location__c, CDX_Shop_Name__c, CDX_Approved_By__c, 
                                        CDX_Approved_Date__c, CDX_Comment__c, CDX_Published_Date__c, CDX_Project__r.CDX_Count_of_Pending_Schedules__c 
                                        FROM CDX_Schedule__c
                                        WHERE CDX_Project__c =: ProjectID LIMIT 20];
        return Schlee;
    } 
    
    
    @AuraEnabled(cacheable=false)
    public static List<ScheduleDetailsWrapper> getScheduleDetails(String Schedule) {
        //Gets schedule deatials based on schedule id inserted
          List<CDX_ScheduleDetail__x> Schlee= new List<CDX_ScheduleDetail__x>();
        if(Test.isRunningTest())
        {
           HTTP http= new HTTP();
            HttpRequest request = new HttpRequest();
           request.setMethod('GET');
      
           CDX_ProjectFindScheduleExtTest conTest=new CDX_ProjectFindScheduleExtTest();
            HTTPResponse response=conTest.respond(request);
            
            System.debug(response.getBody());
         SchWrapper schWrap=new SchWrapper();
          schWrap=(SchWrapper)JSON.deserializeStrict((response.getBody()),SchWrapper.class); 
            System.debug('schWrap>>'+schWrap);
             
          CDX_ScheduleDetail__x obj=new  CDX_ScheduleDetail__x();
            obj.CDX_Schedule__c=schWrap.scheduleId;
            obj.CDX_Week__c = '291';
             System.debug('obj>>>'+obj);
            schlee.add(obj);
   
        } 
        else
        {
         Schlee = [SELECT ID, CDX_Actual_Cars_Arrived__c, CDX_WeekStartDate__c ,CDX_Actual_Cars_Completed__c, 
                    CDX_Actual_Customer_Release__c, CDX_Projected_Arrival__c, CDX_Projected_Cars_Complete__c, 
                    CDX_Projected_Customer_Release__c, CDX_Week__c, CDX_Actual_Cars_Shipped_by_Shop__c 
                    FROM CDX_ScheduleDetail__x
                    WHERE CDX_Schedule__c =: Schedule ORDER BY CDX_Week__c ASC NULLS LAST];
      
        }
        System.debug('Detail Size: '+Schlee.size());
        map<string, string> tWeekMap = new map<string, string>();
        
        for(TrinityWeek__mdt mdt : [SELECT Label, WeekShortName__c, WeekID__c, WeekStartDate__c, WeekEndDate__c, BusinessDays__c 
                                    FROM TrinityWeek__mdt 
                                    ORDER BY WeekID__c ASC]) {
            System.debug(mdt.WeekID__c);
            tWeekMap.put(mdt.WeekID__c, mdt.WeekShortName__c);
        }
        System.debug('tWeekMap Size: '+tWeekMap.size());
        List<ScheduleDetailsWrapper> Details = new List<ScheduleDetailsWrapper>();
        //modified code by MA for BETA-233
        for(CDX_ScheduleDetail__x x : Schlee) {   
            if(tWeekMap.containsKey(x.CDX_Week__c)) {
                ScheduleDetailsWrapper a = new ScheduleDetailsWrapper();
                a.StartDateFormatted = tWeekMap.get(x.CDX_Week__c);
                a.ActualCarsArrived = x.CDX_Actual_Cars_Arrived__c;
                a.ActualCarsCompleted = x.CDX_Actual_Cars_Completed__c;
                a.ActualCustomerRelease = x.CDX_Actual_Customer_Release__c;
                a.ProjectedCarsArrived = x.CDX_Projected_Arrival__c;
                a.ProjectedCarsCompleted = x.CDX_Projected_Cars_Complete__c;
                a.ProjectedCustomerRelease = x.CDX_Projected_Customer_Release__c;
                a.ActualCarsShipped = x.CDX_Actual_Cars_Shipped_by_Shop__c; //Added by MA BETA-233
                a.OGID = x.Id;       
                Details.add(a);
            }
        }
        System.debug('Wrapper Size: '+Details.size());
        //Details.sort();
        return Details;
    } 
    
    
    @AuraEnabled(cacheable=false)
    public static List<RFO_Projects__c> getProject(String ProjectID) 
    {
        //Gets schedule deatials based on schedule id inserted
        List<RFO_Projects__c> Project = [SELECT ID, CreatedById, RFO_ProjectDescription__c, RFO_ScheduledShopNameLocation__c, CDX_Start_Date__c 
                                         FROM RFO_Projects__c 
                                         WHERE ID =: ProjectID];
        
        
        
        return Project;
    } 
    
    @AuraEnabled(cacheable=false)
    public static  List<CDX_Schedule__c> approveAllSchedules(String ProjectID,String Comment)
    {
     
        boolean sel=false;
        List<CDX_Schedule__c> ScheduleToApprove =new List<CDX_Schedule__c>();  
        List<CDX_Schedule__c> Schlee = [SELECT ID,Status__c, CDX_Project__c, Schedule_External_ID__c, CDX_Approved_Rejected_Date__c, Name,CDX_Approved_Rejected_By__c, CDX_Rejected_Date__c,CDX_Shop_Location__c, CDX_Shop_Name__c, CDX_Approved_By__c, CDX_Approved_Date__c, CDX_Comment__c, CDX_Published_Date__c,CDX_Project__r.id 
                                        FROM CDX_Schedule__c
                                        WHERE CDX_Project__c =: ProjectID LIMIT 20];
        System.debug('Schlee is'+Schlee);
        set<id> productid=new set<id>();
        for(CDX_Schedule__c sch:Schlee)
        {
            productid.add(sch.CDX_Project__r.id);
            system.debug('productid'+productid);
            sch.CDX_Approved_Rejected_By__c=userInfo.getUserName();
            sch.CDX_Approved_Rejected_Date__c=System.today();
            sch.CDX_Comment__c=Comment;
            sch.Status__c='Approved';
            ScheduleToApprove.add(sch);

        }
         if(ScheduleToApprove.size()>0)
        {
            System.debug('ScheduleToApprove>>>>'+ScheduleToApprove);
            CDX_UpdateScheduleDetails.updateScheduleDetails(ScheduleToApprove);  
        }
        list<RFO_Projects__c> productlist=new list<RFO_Projects__c>();
        list<RFO_Projects__c> productupdate=new list<RFO_Projects__c>();
        productlist=[select id,CDX_Approved_Rejected_By__c,CDX_Approved_Rejected_Date__c from RFO_Projects__c where id=:productid];
        system.debug('productlist'+productlist);
        for(RFO_Projects__c pro:productlist)
        {
            RFO_Projects__c projectIns=new RFO_Projects__c();
            projectIns.id=pro.id;
            projectIns.CDX_Approved_Rejected_By__c=UserInfo.getFirstName()+' '+UserInfo.getLastName();
            projectIns.CDX_Approved_Rejected_Date__c=system.today();
            productupdate.add(projectIns);
        }
        system.debug('before productupdate'+productupdate);
        update productupdate;
        system.debug('After productupdate'+productupdate);

      
       update ScheduleToApprove;
       system.debug('ScheduleToApprove'+ScheduleToApprove);

        
        return ScheduleToApprove;
        
    }   
    @AuraEnabled(cacheable=false)
    public static  List<CDX_Schedule__c> rejectAllSchedules(String ProjectID,String Comment)
    {
        
        List<CDX_Schedule__c> ScheduleToReject =new List<CDX_Schedule__c>();
        List<CDX_Schedule__c> Schlee = [SELECT ID,Status__c, CDX_Project__c, Schedule_External_ID__c, Name,CDX_Approved_Rejected_By__c,CDX_Approved_Rejected_Date__c, CDX_Rejected_Date__c,CDX_Shop_Location__c, CDX_Shop_Name__c, CDX_Approved_By__c, CDX_Approved_Date__c, CDX_Comment__c, CDX_Published_Date__c,CDX_Project__r.id 
                                        FROM CDX_Schedule__c
                                        WHERE CDX_Project__c =:ProjectID];
        set<id> productid=new set<id>();
        for(CDX_Schedule__c sch:Schlee)
        {
            productid.add(sch.CDX_Project__r.id);
            sch.CDX_Approved_Rejected_By__c=userInfo.getUserName();
            sch.CDX_Comment__c=Comment;
            sch.CDX_Approved_Rejected_Date__c=System.today();
            sch.Status__c='Rejected';
            ScheduleToReject.add(sch);
            
        }
         if(ScheduleToReject.size()>0)
        {
            System.debug('ScheduleToReject>>>>'+ScheduleToReject);
            CDX_UpdateScheduleDetails.updateScheduleDetails(ScheduleToReject);  
        }
        list<RFO_Projects__c> productlist=new list<RFO_Projects__c>();
        list<RFO_Projects__c> productupdate=new list<RFO_Projects__c>();
        productlist=[select id,CDX_Approved_Rejected_By__c,CDX_Approved_Rejected_Date__c from RFO_Projects__c where id=:productid];
        for(RFO_Projects__c pro:productlist)
        {
             RFO_Projects__c projectIns=new RFO_Projects__c();
             projectIns.id=pro.id;
             projectIns.CDX_Approved_Rejected_By__c=UserInfo.getFirstName()+' '+UserInfo.getLastName();
             projectIns.CDX_Approved_Rejected_Date__c=system.today();
             productupdate.add(projectIns);
        }
        update productupdate;
        update ScheduleToReject;
        return ScheduleToReject;
        
        
    }  
  
    @AuraEnabled(cacheable=false)
    public static Boolean PendingSchedules(String ProjectID)
    {
         List<RFO_Projects__c> Project = [SELECT ID, CreatedById, RFO_ProjectDescription__c, RFO_ScheduledShopNameLocation__c, CDX_Start_Date__c 
                                         FROM RFO_Projects__c 
                                         WHERE ID =: ProjectID AND CDX_Count_of_Pending_Schedules__c > 0];
        
        
        if (Project.size() > 0)
            return true;
        
        return false;
    } 
    
    @AuraEnabled(cacheable=false)
    public static String ReturnCSV(String ProjectID)
    {
        String csv = '';
        List<CDX_Schedule__c> Scheds = getScheduleInfo(ProjectID);
        
        for(CDX_Schedule__c a : Scheds)
        {
            csv += 'Shop Name: '+a.CDX_Shop_Name__c+'\n';
            csv += 'Start Date, Scheduled Release By Customer, Actual Cars Release By Customer, Scheduled Arrival to Shop, '
                    +'Actual Arrival at Shop, Scheduled Cars Completed by Shop, Actual Cars Completed by Shop, Actual Cars Shipped by Shop\n';
            
            List<ScheduleDetailsWrapper> deets = getScheduleDetails(a.Schedule_External_ID__c);
            for(ScheduleDetailsWrapper d : deets)
            {
                String detailline = d.StartDateFormatted+', '+d.ProjectedCustomerRelease+', '+d.ActualCustomerRelease+', '+
                       d.ProjectedCarsArrived+', '+d.ActualCarsArrived+', '+
                       d.ProjectedCarsCompleted+', '+d.ActualCarsCompleted+', '+d.ActualCarsShipped;
                System.debug(detailline);
                detailline = detailline.replace('null', ' ');
                csv += detailline+'\n';
                
            }
            csv += '\n';
        }
        
        return csv;
    }
     global class SchWrapper
     {
        String scheduleId;
     }
     
    //Added by MA
    /*@AuraEnabled
    public static boolean hasActualCarsPerm() {
        return FeatureManagement.checkPermission('CDX_SchedulesAccess');  
    }*/
}