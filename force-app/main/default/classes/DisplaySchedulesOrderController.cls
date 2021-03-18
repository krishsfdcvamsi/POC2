public class DisplaySchedulesOrderController {
    
    static Order orderSO;
    static Integer currentWeekNo;
    static map<string,string> trinityMap = new map<string,string>();
    static map<string,string> monthMap = new map<string,string>{'1' => 'Jan','2' => 'Feb','3' => 'Mar','4' => 'Apr',
                                                                '01' => 'Jan','02' => 'Feb','03' => 'Mar','04' => 'Apr',
                                                                '5' => 'May','6' => 'June','7' => 'July','8' => 'Aug',
                                                                '05' => 'May','06' => 'June','07' => 'July','08' => 'Aug',
                                                                '9' => 'Sep','09' => 'Sep','10' => 'Oct','11' => 'Nov','12' => 'Dec'};
    
    @AuraEnabled(cacheable=true) 
    public static projectCls getProjectList(Id orderId) {
        projectCls projectWrap = new projectCls();
        map<string,CDX_Schedule__c> scheduleMap = new map<string,CDX_Schedule__c>();
        try {
            orderSO = [SELECT Id,accountId,RFO_RANumber__c FROM Order WHERE id =: orderId];
            if(orderSO.RFO_RANumber__c != null) {
                RFO_Projects__c projectSO = [SELECT Id,Name,RFO_ProjectId__c 
                                                FROM RFO_Projects__c 
                                                WHERE RA_Number__c =: orderSO.RFO_RANumber__c LIMIT 1];
                projectWrap.actualName = projectSO.Name;
                projectWrap.projectName = projectSO.Name.replaceAll('/','').replaceAll('#','');
                projectWrap.projectId = projectSO.RFO_ProjectId__c;
                projectWrap.projectRecordId = projectSO.Id;
                projectWrap.completedCars = new scheduleCars();
                projectWrap.actualCompletedCars = new scheduleCars();
                projectWrap.actualshippedCars = new scheduleCars();
                projectWrap.weekList = getWeeks();
                for(CDX_Schedule__c sch : [SELECT Id,Schedule_External_ID__c,CDX_Shop_Name__c,CDX_Shop_Location__c  
                                            FROM CDX_Schedule__c 
                                            WHERE CDX_Project__c =: projectSO.Id]) {
                    
                    scheduleMap.put(sch.Schedule_External_ID__c,sch);
                }
                system.debug('@--- '+scheduleMap.keySet());
                map<string,schdulesClass> pastScheduleMap = new map<string,schdulesClass>();
                list<CDX_ScheduleDetail__x> schList = new list<CDX_ScheduleDetail__x>();
                for(string scheduleId : scheduleMap.keySet()) {
                    for(CDX_ScheduleDetail__x schDetail : getScheduleDetail(scheduleId)) {
                        
                        if(schDetail.CDX_Week__c != null) {
                            string completedCars 
                                = schDetail.CDX_Projected_Cars_Complete__c != null ? schDetail.CDX_Projected_Cars_Complete__c :'0';
                            string actualCompletedCars
                                = schDetail.CDX_Actual_Cars_Completed__c != null ? schDetail.CDX_Actual_Cars_Completed__c :'0';
                            string actualshippedCars
                                = schDetail.CDX_Actual_Cars_Shipped_by_Shop__c != null ? schDetail.CDX_Actual_Cars_Shipped_by_Shop__c :'0';
                            if(Integer.valueOf(schDetail.CDX_Week__c) >= currentWeekNo) {
                                if(Integer.valueOf(schDetail.CDX_Week__c) == currentWeekNo) {
                                    projectWrap.completedCars.week0 += Integer.valueOf(completedCars);
                                    projectWrap.actualCompletedCars.week0 += Integer.valueOf(actualCompletedCars);
                                    projectWrap.actualshippedCars.week0 += Integer.valueOf(actualshippedCars);
                                }
                                else if(Integer.valueOf(schDetail.CDX_Week__c) == (currentWeekNo+1)) {
                                    projectWrap.completedCars.week1 += Integer.valueOf(completedCars);
                                    projectWrap.actualCompletedCars.week1 += Integer.valueOf(actualCompletedCars);
                                    projectWrap.actualshippedCars.week1 += Integer.valueOf(actualshippedCars);
                                }
                                else if(Integer.valueOf(schDetail.CDX_Week__c) == (currentWeekNo+2)) {
                                    projectWrap.completedCars.week2 += Integer.valueOf(completedCars);
                                    projectWrap.actualCompletedCars.week2 += Integer.valueOf(actualCompletedCars);
                                    projectWrap.actualshippedCars.week2 += Integer.valueOf(actualshippedCars);
                                }
                                else if(Integer.valueOf(schDetail.CDX_Week__c) == (currentWeekNo+3)) {
                                    projectWrap.completedCars.week3 += Integer.valueOf(completedCars);
                                    projectWrap.actualCompletedCars.week3 += Integer.valueOf(actualCompletedCars);
                                    projectWrap.actualshippedCars.week3 += Integer.valueOf(actualshippedCars);
                                }
                                else if(Integer.valueOf(schDetail.CDX_Week__c) == (currentWeekNo+4)) {
                                    projectWrap.completedCars.week4 += Integer.valueOf(completedCars);
                                    projectWrap.actualCompletedCars.week4 += Integer.valueOf(actualCompletedCars);
                                    projectWrap.actualshippedCars.week4 += Integer.valueOf(actualshippedCars);
                                }
                                else {
                                    projectWrap.completedCars.weekNth += Integer.valueOf(completedCars);
                                    projectWrap.actualCompletedCars.weekNth += Integer.valueOf(actualCompletedCars);
                                    projectWrap.actualshippedCars.weekNth += Integer.valueOf(actualshippedCars);
                                }
                            }
                            else if(trinityMap.containsKey(schDetail.CDX_Week__c) && schDetail.CDX_Week__c != '0'){
                                schdulesClass schPast;
                                if(pastScheduleMap.containsKey(schDetail.CDX_Schedule__c)) {
                                    schPast = pastScheduleMap.get(schDetail.CDX_Schedule__c);
                                    string weekId = trinityMap.get(schDetail.CDX_Week__c);
                                    weekId = weekId.split('/')[1]+'-'+monthMap.get(weekId.split('/')[0]);
                                    schPast.weekName.add(weekId);
                                    string noOfCars = completedCars;
                                    string noOfCars1 = actualCompletedCars;
                                    string noOfCars2 = actualshippedCars;
                                    schPast.noOfCars.add(noOfcars);
                                    schPast.noOfCars1.add(noOfCars1);
                                    schPast.noOfCars2.add(noOfCars2);
                                }
                                else {
                                    schPast = new schdulesClass();
                                    schPast.ScheduleName = scheduleMap.get(schDetail.CDX_Schedule__c).CDX_Shop_Name__c;
                                    schPast.ScheduleLocation = scheduleMap.get(schDetail.CDX_Schedule__c).CDX_Shop_Location__c ;
                                    schPast.typeName = 'Scheduled Cars Completed by Shop';
                                    schPast.typeName1 = 'Actual Cars Completed by Shop';
                                    schPast.typeName2 = 'Actual Cars Shipped by Shop';
                                    string weekId = trinityMap.get(schDetail.CDX_Week__c);
                                    weekId = weekId.split('/')[1]+'-'+monthMap.get(weekId.split('/')[0]);
                                    schPast.weekName = new list<string>{weekId};
                                    string noOfCars = completedCars;
                                    string noOfCars1 = actualCompletedCars;
                                    string noOfCars2 = actualshippedCars;
                                    schPast.noOfCars = new list<string>{noOfCars};
                                    schPast.noOfCars1 = new list<string>{noOfCars1};
                                    schPast.noOfCars2 = new list<string>{noOfCars2};
                                    pastScheduleMap.put(schDetail.CDX_Schedule__c, schPast);
                                }
                            }
                        }
                    }
                }
                schdulesClass schPastTotal = new schdulesClass();
                schPastTotal.ScheduleName = 'Roll Up Summary (All Shops)';
                schPastTotal.ScheduleLocation = '';
                schPastTotal.typeName = 'Scheduled Cars Completed by Shop';
                schPastTotal.typeName1 = 'Actual Cars Completed by Shop';
                schPastTotal.typeName2 = 'Actual Cars Shipped by Shop';
                list<schdulesClass> schPastList = new list<schdulesClass>();
                schPastList.addAll(pastScheduleMap.values());
                schPastTotal.weekName = schPastList[0].weekName;
                list<string> noOfCarsTotal = new list<string>();
                list<string> noOfCarsTotal1 = new list<string>();
                list<string> noOfCarsTotal2 = new list<string>();
                for(integer i=0; i < schPastTotal.weekName.size(); i++) {
                    Integer count=0;
                    Integer count1=0;
                    Integer count2=0;
                    for(string scheduleIds : pastScheduleMap.keySet()) {
                        count += Integer.valueOf(pastScheduleMap.get(scheduleIds).noOfCars[i]);
                        count1 += Integer.valueOf(pastScheduleMap.get(scheduleIds).noOfCars1[i]);
                        count2 += Integer.valueOf(pastScheduleMap.get(scheduleIds).noOfCars2[i]);
                    }
                    noOfCarsTotal.add(string.valueOf(count));
                    noOfCarsTotal1.add(string.valueOf(count1));
                    noOfCarsTotal2.add(string.valueOf(count2));
                }
                schPastTotal.noOfCars = noOfCarsTotal;
                schPastTotal.noOfCars1 = noOfCarsTotal1;
                schPastTotal.noOfCars2 = noOfCarsTotal2;
                schPastList.add(0,schPastTotal);
                projectWrap.pastScheduleList = schPastList;
                return projectWrap;
            }
            else {
                return projectWrap;
            }
        }
        catch(exception e) {
            system.debug('error : '+e.getMessage()+'. at line number '+e.getLineNumber());
            return projectWrap;
        }
    }
    
    public static list<CDX_ScheduleDetail__x> getScheduleDetail(string scheduleId) {
        list<CDX_ScheduleDetail__x> schList1 = new list<CDX_ScheduleDetail__x>();
        if(Test.isRunningTest()) {
            schList1 = DisplaySchedulesOrderControllerTest.getScheduleDetail(scheduleId);
        }
        else {
            schList1 = [SELECT Id,CDX_Week__c,CDX_Schedule__c,CDX_Projected_Cars_Complete__c,
                            CDX_Actual_Cars_Completed__c,CDX_Actual_Cars_Shipped_by_Shop__c 
                            FROM CDX_ScheduleDetail__x 
                            WHERE CDX_Schedule__c =: scheduleId 
                            ORDER BY CDX_Week__c ASC NULLS LAST];
        }
        return schList1;
    }
    
    public class projectCls {
        @AuraEnabled public string projectName;
        @AuraEnabled public string actualName;
        @AuraEnabled public string projectId;
        @AuraEnabled public string projectRecordId;
        @AuraEnabled public list<weekCls> weekList;
        @AuraEnabled public scheduleCars completedCars;
        @AuraEnabled public scheduleCars actualCompletedCars;
        @AuraEnabled public scheduleCars actualshippedCars;
        @AuraEnabled public list<schdulesClass> pastScheduleList;
    }
    
    public class scheduleCars {
        @AuraEnabled public Integer week0;
        @AuraEnabled public Integer week1;
        @AuraEnabled public Integer week2;
        @AuraEnabled public Integer week3;
        @AuraEnabled public Integer week4;
        @AuraEnabled public Integer weekNth;
        
        public scheduleCars() {
            week0 = 0;
            week1 = 0;
            week2 = 0;
            week3 = 0;
            week4 = 0;
            weekNth = 0;
        }
    }
    
    public class weekCls {
        @AuraEnabled public string weekNo;
        @AuraEnabled public string weekName;
        
    }
    
    public class schdulesClass {
        
        @AuraEnabled public string ScheduleName;
        @AuraEnabled public string ScheduleLocation;
        @AuraEnabled public string typeName;
        @AuraEnabled public string typeName1;
        @AuraEnabled public string typeName2;
        @AuraEnabled public list<string> weekName;
        @AuraEnabled public list<string> noOfCars;
        @AuraEnabled public list<string> noOfCars1;
        @AuraEnabled public list<string> noOfCars2;
    }
        
    //This method is used to get the current week number from custom metadata
    public static list<weekCls> getWeeks() {
        Date todayDate = system.today();
        list<weekCls> weekNames = new list<weekCls>();
        Integer i=0;
        currentWeekNo=0;
        for( TrinityWeek__mdt mdt : [SELECT  WeekID__c, WeekShortName__c,WeekEndDate__c  
                                        FROM TrinityWeek__mdt 
                                        ORDER BY WeekID__c ASC]) {
             
            trinityMap.put(mdt.WeekID__c,mdt.WeekShortName__c);
            if(mdt.WeekEndDate__c >= todayDate) {
                if(currentWeekNo == 0) {            
                    currentWeekNo = Integer.valueOf(mdt.WeekID__c);
                }
                if(i<=4) {
                    weekCls w = new weekCls();
                    w.weekNo = mdt.WeekShortName__c;
                    if(i==0) {
                        w.weekName = 'Current Week';
                    }
                    else {
                        w.weekName = 'Current + '+ i;
                    }
                    weekNames.add(w);
                }
                i++;
            }
            
        }
        system.debug('weekNames = '+weekNames);
        return weekNames;
    }

}