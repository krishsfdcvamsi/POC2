/***************************
* @author :Krishna V--
  This Batch Class for Sending Weekly emails whoever subscribed contacts for Project Scheduled Release Cars 
*/
global class CDX_WeeklyEmailScheduleDetailExt implements Database.Batchable<sObject>, Database.AllowsCallouts,  Schedulable {
    
    Set<String> scheduleIds;
    Set<Id> accountIds;
    Set<String> weekIds;
    List<Account> lstAccounts;
    List<CDX_Schedule__c> lstSchedule = new List<CDX_Schedule__c>();
    
    global CDX_WeeklyEmailScheduleDetailExt ()
    {
        System.debug('EXECUTING...');
        weekIds = CDX_CommunityUtilityExt.GetWeekIds();
           System.debug('weekIds'+weekIds);
        lstAccounts=new List<Account>();
        String accountQuery = 'select id,Name, (select id,Email from Contacts where CDX_Project_Notification_Preference__c =true )  from Account where Id in (select AccountId from Contact where CDX_Project_Notification_Preference__c =true ) Order By Name';
        lstAccounts = Database.Query(accountQuery); 
        
    }
    
     global Database.QueryLocator start(Database.BatchableContext BC) 
     {
          System.debug('lstAccounts'+lstAccounts);
         if(lstAccounts.size()>0)
         {
            accountIds = (new Map<Id,SObject>(lstAccounts)).keySet();
            String query = 'Select id, name, CDX_Shop_Name__c,Schedule_External_ID__c,CDX_Shop_Location__c, CDX_Project__r.name, CDX_Project__r.RFO_Account__c from CDX_Schedule__c where CDX_Project__r.RFO_Account__c in :accountIds';
            return Database.getQueryLocator(query);
        }
        else
        {
            System.debug('I did not find any accounts which contacts subscribed for Schedule Notification');
            return null;
        }
      
     }
    
    global void execute(Database.BatchableContext BC, List<CDX_Schedule__c> lstSchedule)
    {
        
        Map<Id,String> mapAccountEmailbody=new Map<Id,String>();
       if(lstAccounts.size()>0)
       {
           accountIds=new Set<Id>();  
           Set<String> scheduleIds = new Set<String>();
           if(lstSchedule.size()>0) {
               for(CDX_Schedule__c schedule : lstSchedule){
            		accountIds.add(schedule.CDX_Project__r.RFO_Account__c); 
                    if(schedule.Schedule_External_ID__c!=null){
                         	scheduleIds.add(schedule.Schedule_External_ID__c);
                    }    
               }    
       		}
              System.debug('scheduleIds'+scheduleIds);
           List<CDX_ScheduleDetail__x> scope =  new List<CDX_ScheduleDetail__x>();
           scope = CDX_ScheduleDetailExternalModel.findScheduleExternalById(scheduleIds,weekIds) ;
           System.debug('scope'+scope);
           Map<Id,List<CDX_ScheduleDetail__x>> mapAccountSchDtls=new Map<Id,List<CDX_ScheduleDetail__x>>();
           List<CDX_ScheduleDetail__x> lstSchDetails = new  List<CDX_ScheduleDetail__x>();
            for(CDX_Schedule__c objSch:lstSchedule)
            {
                 if(scope!=null){  
                    for(CDX_ScheduleDetail__x objSchDtls :scope)
                      {  
                      if(objSch.Schedule_External_ID__c!=null && objSch.Schedule_External_ID__c!='' && objSch.Schedule_External_ID__c==objSchDtls.CDX_Schedule__c) 
                          if(objSchDtls.CDX_Projected_Customer_Release__c !=  NULL)
                          	lstSchDetails.add(objSchDtls);  
                      }
                }    
                if(lstSchDetails.size()>0)
                  mapAccountSchDtls.put(objSch.CDX_Project__r.RFO_Account__c,lstSchDetails);
                  lstSchDetails = new  List<CDX_ScheduleDetail__x>();
             }
           System.debug('mapAccountSchDtls'+mapAccountSchDtls);
           for(Account account : lstAccounts)  
            {
                 List<CDX_ScheduleDetail__x> lstScheduleDetails =mapAccountSchDtls.get(account.Id);
                System.debug('lstScheduleDetails>>'+lstScheduleDetails);
                 if(lstScheduleDetails!=null && lstScheduleDetails.size()>0)
                 {
                    String emailBody = CDX_CommunityUtilityExt.PrepareEmailBodyforSubscribedContacts(lstScheduleDetails);
                       System.debug('emailBody>>'+emailBody);
                    if(emailBody!=null)  mapAccountEmailbody.put(account.Id,emailBody);
                 }
            }
       }
            System.debug('mapAccountEmailbody'+mapAccountEmailbody);
        List<Messaging.SingleEmailMessage> accountMails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> AllMails = new List<Messaging.SingleEmailMessage>();
        for(Id accountId : mapAccountEmailbody.keySet())  
          {
            String emailBody =mapAccountEmailbody.get(accountId);   Messaging.SingleEmailMessage mail;
            
              if(emailBody!=null)
               accountMails= CDX_CommunityUtilityExt.SendEmailforAllSubscribedContacts(accountid,emailBody);
              if(accountMails!=null)  AllMails.addAll(accountMails);  
          } 
            System.debug('accountMails'+accountMails);
          System.debug('AllMails'+AllMails);
        if(AllMails.size()>0) 
        {
            if(!Test.isRunningTest())
            Messaging.sendEmail(AllMails);
           /* try
       {
            Messaging.sendEmail(AllMails);
             }
           catch(Exception e)
            {
                System.debug('Exception>>'+e);
            }*/
            
        }}
        
    global void execute(SchedulableContext SC) {
        database.executebatch(new CDX_WeeklyEmailScheduleDetailExt());
    }
    global void finish(Database.BatchableContext BC)
    {
       
    } 

}