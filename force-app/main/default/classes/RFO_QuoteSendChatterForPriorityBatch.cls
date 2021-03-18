/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 28 May 2019
* @Description :This class is used to send Chatter Notification if Priority field value is 'Escalated Priority'.
**/

global class RFO_QuoteSendChatterForPriorityBatch implements Database.Batchable<sObject>, Schedulable {


    global void execute(SchedulableContext sc)
    {
        // We now call the batch class to be scheduled
        RFO_QuoteSendChatterForPriorityBatch quoBatch = new RFO_QuoteSendChatterForPriorityBatch();
       
        // Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
        //String cronStr = '0 0 6 * * ?'; //Daily 6AM CST
        //System.schedule('Quotes Send Chatter For Priority', cronStr, quoBatch);
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executeBatch(quoBatch, 200);
    }
        
    global Database.QueryLocator start(Database.BatchableContext BC) {
     DateTime DT = DateTime.newInstance(2019, 10, 21);
        return Database.getQueryLocator([SELECT Id,Name, RFO_Priority__c, RFO_PriorityDate__c, RFO_Link__c  FROM SBQQ__Quote__c WHERE RFO_Priority__c = 'Escalated Priority'
         AND createdDate >=:DT  AND  (RFO_QuoteTeam__c!=NULL OR RFO_QuoteTeam__c!='')]);
    }

    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> quoteList) {       
        List<SBQQ__Quote__c> quoteUpdatelist = new List<SBQQ__Quote__c>();
        if(!quoteList.isEmpty()){
            List<FeedItem> listFeed = new List<FeedItem>(); 
                    
            for(SBQQ__Quote__c quot : quoteList){  
              FeedItem feed = new FeedItem();
              
              if(quot.RFO_PriorityDate__c != null){
               
                Date date1 = quot.RFO_PriorityDate__c;

                Integer Prioritydays = (date1).daysBetween(system.today());
 
               if(Prioritydays > 1 && quot.RFO_Priority__c == 'Escalated Priority'){
                    feed.ParentId = quot.id;
                    feed.Body = 'Quote ['+quot.Name+'] is a HIGH PRIORITY quote. Please complete ASAP ';                          
                    listFeed.add(feed);
                }
            }
          }
          
            if(listFeed.size()>0){
                      insert listFeed;
              }   
        }
   }

    global void finish(Database.BatchableContext bc) {
        
    }
}