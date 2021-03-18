public with sharing class CDX_ScheduleDetailExternalModel {
    @TestVisible private static List<CDX_ScheduleDetail__x> mockedScheduleExternal = new List<CDX_ScheduleDetail__x>();

    public static List<CDX_ScheduleDetail__x> findScheduleExternalById(Set<String> scheduleIds, Set<String> weekIds) {
        System.debug('IN SCHEDULE DETAIL MODELS');
        //List<CDX_ScheduleExternal__x> lstScheduleExternal = (!mockedScheduleExternal.isEmpty()) ? mockedScheduleExternal : [
            List<CDX_ScheduleDetail__x> lstScheduleExternal = new List<CDX_ScheduleDetail__x>();
         List<CDX_ScheduleDetail__x> lstScheduleExternalInitial = new List<CDX_ScheduleDetail__x>();
          List<CDX_ScheduleDetail__x> lstScheduleExternalFinal = new List<CDX_ScheduleDetail__x>();
         System.debug('weekIds in externalModel'+weekIds);
        System.debug('scheduleIds in externalModel'+scheduleIds);
         
        /* lstScheduleExternal = (!mockedScheduleExternal.isEmpty()) ? mockedScheduleExternal : [  
            SELECT  ExternalId, CDX_Schedule__r.CDX_Shop_Name__c ,CDX_Schedule__r.CDX_Shop_Location__c,CDX_Schedule__c, CDX_Schedule__r.Name, CDX_Week__c, CDX_Projected_Customer_Release__c, CDX_WeekStartDate__c 
            FROM  CDX_ScheduleDetail__x WHERE CDX_Schedule__c in :scheduleIds and (CDX_Week__c IN :weekIds )];*/
      
         if(Test.isRunningTest())
        {
           
          lstScheduleExternalInitial=mockedScheduleExternal.clone();
        }
        else
        {
        lstScheduleExternalInitial=[SELECT  ExternalId, CDX_Schedule__r.CDX_Shop_Name__c ,CDX_Schedule__r.CDX_Shop_Location__c,CDX_Schedule__c, CDX_Schedule__r.Name, CDX_Week__c, CDX_Projected_Customer_Release__c, CDX_WeekStartDate__c 
            FROM  CDX_ScheduleDetail__x WHERE CDX_Schedule__c in :scheduleIds];
        }
      /*  lstScheduleExternalInitial=[SELECT  ExternalId, CDX_Schedule__r.CDX_Shop_Name__c ,CDX_Schedule__r.CDX_Shop_Location__c,CDX_Schedule__c, CDX_Schedule__r.Name, CDX_Week__c, CDX_Projected_Customer_Release__c, CDX_WeekStartDate__c 
            FROM  CDX_ScheduleDetail__x WHERE CDX_Schedule__c in :scheduleIds];*/
       
        System.debug(' lstScheduleExternalInitial>>>'+ lstScheduleExternalInitial);
        
        for(CDX_ScheduleDetail__x x:lstScheduleExternalInitial)
        {
             System.debug('x.CDX_Week__c>>>'+x.CDX_Week__c);
            System.debug('x.CDX_Schedule__c>>>'+x.CDX_Schedule__c);
           
            for(String s:weekIds) 
           {
               System.debug('s for week>>>'+s);
               if(s.equals(x.CDX_Week__c))
               {
                 System.debug('entered in if');
                   lstScheduleExternalFinal.add(x);
               }
           }
        }
          System.debug('lstScheduleExternalFinal>>>'+ lstScheduleExternalFinal);
               
        lstScheduleExternal = (!mockedScheduleExternal.isEmpty()) ? mockedScheduleExternal : lstScheduleExternalFinal.clone();                        
          
      System.debug('lstScheduleExternal>>>>'+ lstScheduleExternal);
       return (lstScheduleExternal.size() > 0) ? lstScheduleExternal : null;
       
    } 
}