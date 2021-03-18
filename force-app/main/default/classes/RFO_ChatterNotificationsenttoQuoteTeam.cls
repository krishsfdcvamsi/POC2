global class RFO_ChatterNotificationsenttoQuoteTeam implements Database.Batchable<sObject>, Schedulable{  
    
    global void execute(SchedulableContext sc)
    {  
        // We now call the batch class to be scheduled
        RFO_ChatterNotificationsenttoQuoteTeam quoBatch = new RFO_ChatterNotificationsenttoQuoteTeam();
        
        // Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
        //String cronStr = '0 0 6 * * ?'; //Daily 6AM CST
        //System.schedule('Quotes Days before proposal referesh', cronStr, quoBatch);
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executeBatch(quoBatch, 200);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
    DateTime DT = DateTime.newInstance(2019, 10, 21);
        return Database.getQueryLocator([SELECT Id,Name,CreatedDate,RecordTypeID,RFO_PortfolioManagementSection_Started__c,
                                         RFO_PricingSectionStarted__c,RFO_EngineeringSectionStarted__c,
                                         RFO_ProductionPlanningSection_Started__c,RFO_EstimatingSectionStarted__c,
                                         RFO_PortfolioManagementSectionComplete__c,
                                         RFO_EngineeringSectionComplete__c,RFO_EstimatingSectionCompleted__c,
                                         RFO_ProdPlanSectionComplete__c,RFO_PricingSectionComplete__c,
                                         RFO_QuoteTeam__r.RFO_PortfolioMember__r.Name,RFO_QuoteTeam__r.RFO_EngineeringMember__r.Name,
                                         RFO_QuoteTeam__r.RFO_EstimatingMember__r.Name,RFO_QuoteTeam__r.RFO_PricingMember__r.Name,
                                         RFO_QuoteTeam__r.RFO_PlanningMember__r.Name  FROM SBQQ__Quote__c where  createdDate >=:DT AND  (RFO_QuoteTeam__c!=NULL OR RFO_QuoteTeam__c!='')]);
    }
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> quoteList) {
        List<FeedItem> listFeed = new List<FeedItem>();
        if(!quoteList.isEmpty())
        {   
            for(SBQQ__Quote__c quot : quoteList)
            {   
                FeedItem feed = new FeedItem();
                DateTime quotecreatedate=quot.CreatedDate;
                DateTime currentdate= System.Now();
                Integer diffdays=quotecreatedate.Date().daysBetween(currentdate.Date());
                string chattermsg='';
                if(diffdays>Integer.ValueOf(System.Label.RFO_Six)){
                    feed.ParentId = quot.id;
                    if(quot.RFO_PortfolioManagementSection_Started__c=='Yes' && quot.RFO_PortfolioManagementSectionComplete__c !='Yes' &&  String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_PortfolioMember__c)){
                        chattermsg+='@'+quot.RFO_QuoteTeam__r.RFO_PortfolioMember__r.Name+'\n';
                    }
                    if(quot.RFO_EngineeringSectionStarted__c=='Yes' && quot.RFO_EngineeringSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_EngineeringMember__c)){
                        chattermsg+='@'+quot.RFO_QuoteTeam__r.RFO_EngineeringMember__r.Name+'\n';
                        
                    }
                    if(quot.RFO_EstimatingSectionStarted__c=='Yes' && quot.RFO_EstimatingSectionCompleted__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_EstimatingMember__c)){
                        chattermsg+='@'+quot.RFO_QuoteTeam__r.RFO_EstimatingMember__r.Name+'\n';
                         
                    }
                    if(quot.RFO_ProductionPlanningSection_Started__c=='Yes' && quot.RFO_ProdPlanSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_PlanningMember__c)){
                        chattermsg+='@'+quot.RFO_QuoteTeam__r.RFO_PlanningMember__r.Name+'\n';
                        
                    }
                    if(quot.RFO_PricingSectionStarted__c=='Yes' && quot.RFO_PricingSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_PricingMember__c)){
                        chattermsg+='@'+quot.RFO_QuoteTeam__r.RFO_PricingMember__r.Name+'\n';
                        
                    }
                    chattermsg+='Please fill your section on Quote.' + '\n' +'Please Ignore if already filled.';       
                    feed.Body =chattermsg;
                    
                }
                
            }  
            
            
            if(listFeed.size()>0){  insert listFeed;
                                 } 
        }
    }
    global void finish(Database.BatchableContext bc) {
        
    }
}