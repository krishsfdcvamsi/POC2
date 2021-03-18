/**
* @Author      : Accenture  
* @Version     : 1.0
* @Created Date: 20 May 2019
* @Description :This class is to update the Days before proposal referesh field on quote.
**/
global class RFO_UpdateDaysBeforeProposalBatch implements Database.Batchable<sObject>, Schedulable {


    global void execute(SchedulableContext sc)
    {
        // We now call the batch class to be scheduled
        RFO_UpdateDaysBeforeProposalBatch quoBatch = new RFO_UpdateDaysBeforeProposalBatch();
       
        // Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
        //String cronStr = '0 0 6 * * ?'; //Daily 6AM CST
        //System.schedule('Quotes Days before proposal referesh', cronStr, quoBatch);
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executeBatch(quoBatch, 200);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
     DateTime DT = DateTime.newInstance(2019, 10, 21);
     Id ExistingId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_Existing').getRecordTypeId(); 
        return Database.getQueryLocator([SELECT Id,Name,RFO_DaysBeforeProposalRefresh__c,
        SBQQ__Opportunity2__r.Account.OwnerID,RFO_ProposalRefreshStatus__c,RFO_DaysUntilProposalExpires__c,RFO_ProposalExpired__c,RFO_ProposalRefreshRequired__c,RFO_QuoteStage__c  FROM SBQQ__Quote__c WHERE createdDate >=:DT  AND RFO_DaysBeforeProposalRefresh__c != null AND RFO_DaysBeforeProposalRefresh__c >= 0 AND  RecordTypeID =:ExistingId AND SBQQ__Opportunity2__r.RFO_NoQuote__c=false]);
    }
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> quoteList) {
        List<SBQQ__Quote__c> quoteUpdatelist = new List<SBQQ__Quote__c>();
        if(!quoteList.isEmpty()){   
        
            List<FeedItem> listFeed = new List<FeedItem>(); 
            
            for(SBQQ__Quote__c quot : quoteList)
            {   
                FeedItem feed = new FeedItem();   
        
                if(quot.RFO_DaysBeforeProposalRefresh__c > 0 && quot.RFO_ProposalRefreshRequired__c != 'Yes')
                {   
                    quot.RFO_DaysBeforeProposalRefresh__c = quot.RFO_DaysBeforeProposalRefresh__c-1;
                    quot.RFO_DaysUntilProposalExpires__c =  String.valueOf(Math.round(quot.RFO_DaysBeforeProposalRefresh__c));  
                    quoteUpdatelist.add(quot);
                    
                }else if(quot.RFO_DaysBeforeProposalRefresh__c == 0 && quot.RFO_ProposalRefreshRequired__c != 'Yes' ){
                 
                    quot.RFO_ProposalRefreshRequired__c= 'Yes' ; 
                        if(quot.RFO_QuoteStage__c=='Approve to Quote'){                  
                           quot.RFO_DaysBeforeProposalRefresh__c=60;
                           quot.RFO_DaysUntilProposalExpires__c =  '60 days until Proposal Expires';  
                        }
                    quoteUpdatelist.add(quot);                   
                }else if(quot.RFO_DaysBeforeProposalRefresh__c == 0 && quot.RFO_ProposalRefreshRequired__c == 'Yes' && quot.RFO_QuoteStage__c=='Approve to Quote' && quot.RFO_DaysUntilProposalExpires__c != '0 days until Proposal Expires'  ){
                                    
                    
                    quot.RFO_DaysBeforeProposalRefresh__c=60;
                    quot.RFO_DaysUntilProposalExpires__c =  '60 days until Proposal Expires';  
                     
                    quoteUpdatelist.add(quot);
                   
                }else if(quot.RFO_DaysBeforeProposalRefresh__c > 0 && quot.RFO_ProposalRefreshRequired__c == 'Yes'){
                  
                    quot.RFO_DaysBeforeProposalRefresh__c = quot.RFO_DaysBeforeProposalRefresh__c-1;
                    quot.RFO_DaysUntilProposalExpires__c =  ''+String.valueOf(Math.round(quot.RFO_DaysBeforeProposalRefresh__c))+' days until Proposal Expires';  
                    quoteUpdatelist.add(quot);
                }else if(quot.RFO_DaysBeforeProposalRefresh__c == 0 && quot.RFO_ProposalRefreshRequired__c == 'Yes' && quot.RFO_ProposalExpired__c != 'Yes' && quot.RFO_DaysUntilProposalExpires__c == '0 days until Proposal Expires' ){
                    
                    quot.RFO_ProposalExpired__c= 'Yes' ;
                    quoteUpdatelist.add(quot);
                }
                
                if(quot.RFO_ProposalRefreshRequired__c == 'Yes' && (quot.RFO_ProposalRefreshStatus__c == NULL || quot.RFO_ProposalRefreshStatus__c == ''))
                {               
                    feed.ParentId = quot.SBQQ__Opportunity2__r.Account.OwnerID;
                    feed.Body = 'Proposal Refresh is checked.Please update Proposal refresh Status'+quot.name+' - '+Label.RFO_URL_head+quot.id ;
                    listFeed.add(feed);
                }
            }
            
            if(listFeed.size()>0){
                insert listFeed;
            } 
            
        }
        Database.update(quoteUpdatelist);
    }
    global void finish(Database.BatchableContext bc) {
        
    }
}