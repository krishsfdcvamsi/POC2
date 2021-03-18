global class RFO_ChatterNotificationOnQuote implements Database.Batchable<sObject>, Schedulable{  
    
    global void execute(SchedulableContext sc)
    {  
        // We now call the batch class to be scheduled
        RFO_ChatterNotificationOnQuote quoBatch = new RFO_ChatterNotificationOnQuote();
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executeBatch(quoBatch, 200);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime DT = DateTime.newInstance(2019, 10, 21);
        Id NewId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_New').getRecordTypeId();
        return Database.getQueryLocator([SELECT Id,Name,CreatedDate,RecordTypeID,RFO_PortfolioManagementSection_Started__c,
                                         RFO_PricingSectionStarted__c,RFO_EngineeringSectionStarted__c,
                                         RFO_ProductionPlanningSection_Started__c,RFO_EstimatingSectionStarted__c,
                                         RFO_PortfolioManagementSectionComplete__c,
                                         RFO_EngineeringSectionComplete__c,RFO_EstimatingSectionCompleted__c,
                                         RFO_ProdPlanSectionComplete__c,RFO_PricingSectionComplete__c,SBQQ__Opportunity2__r.AccountId,
                                         SBQQ__Opportunity2__r.RecordTypeId,SBQQ__Opportunity2__r.Account.RecordTypeId
                                         FROM SBQQ__Quote__c where  createdDate >=:DT AND RecordTypeID =:NewId]);
    }
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> quoteList) {
        List<FeedItem> listFeed = new List<FeedItem>();
        Id prosRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_Prospect).getRecordTypeId();
        Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_Customer).getRecordTypeId();
        Id thrdparsalesRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_ThirdPartySales').getRecordTypeId();
        Id tPProsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_ThirdPartyProspect).getRecordTypeId();
        ID optytankId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Tank').getRecordTypeId();
        ID optyfreightId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Freight').getRecordTypeId();
        Id NewId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_New').getRecordTypeId(); 
        string chatterPaulmsg ='';
        string chatterStevemsg ='';
        
        Map<id,SBQQ__Quote__c> quotesMap = new Map<id,SBQQ__Quote__c>();
        Set<SBQQ__Quote__c> paulQuotsLst = new Set<SBQQ__Quote__c>();
        Set<SBQQ__Quote__c> steveQuotsLst = new Set<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> totalQuotsLst = new List<SBQQ__Quote__c>();
        Set<String> quotNamesSet = new Set<String>();
         FeedItem FeedQuote = new FeedItem();
        FeedItem FeedQuote2 = new FeedItem();
        
        if(!quoteList.isEmpty()){
            system.debug('****quoteList Count '+quoteList.size());
            
            for(SBQQ__Quote__c quot : quoteList)
            {   
                DateTime quotecreatedate=quot.CreatedDate;
                DateTime currentdate= System.Now();
                Integer diffdays=quotecreatedate.Date().daysBetween(currentdate.Date());
                if(diffdays>=3){
                    
                    if(quot.SBQQ__Opportunity2__r.RecordTypeId == optyfreightId){
                        if(quot.SBQQ__Opportunity2__r.Account.RecordTypeId == prosRecordTypeId || quot.SBQQ__Opportunity2__r.Account.RecordTypeId == custRecordTypeId){
                            paulQuotsLst.add(quot);
                        }
                    }
                    else if(quot.SBQQ__Opportunity2__r.RecordTypeId == optytankId){ 
                        if(quot.SBQQ__Opportunity2__r.Account.RecordTypeId == thrdparsalesRecordTypeId || quot.SBQQ__Opportunity2__r.Account.RecordTypeId == tPProsRecordTypeId){
                            steveQuotsLst.add(quot);
                        }
                    }
                    
                }
            }
        }
        
        if(!paulQuotsLst.isEmpty()){
           
            for(SBQQ__Quote__c quot : paulQuotsLst)
            {   
                Boolean PortflioSection = false;
                Boolean EngSection = false;
                Boolean EstmSection = false;
                Boolean ProdPlanSection = false;
                Boolean PricingSection = false;
                Boolean paulFeed = false;
                Boolean steveFeed = false;
                
                
                if(quot.RFO_PortfolioManagementSection_Started__c=='Yes' && quot.RFO_PortfolioManagementSectionComplete__c !='Yes'){
                    chatterPaulmsg += 'Portfolio Section'+'\n';
                    PortflioSection = true;
                }
                
                if(quot.RFO_EngineeringSectionStarted__c=='Yes' && quot.RFO_EngineeringSectionComplete__c!='Yes'){
                    chatterPaulmsg+='Engineering Section'+'\n';
                    EngSection =true;
                    
                }
                if(quot.RFO_EstimatingSectionStarted__c=='Yes' && quot.RFO_EstimatingSectionCompleted__c!='Yes'){
                    chatterPaulmsg+='Estimating Section'+'\n';
                    EstmSection = true;
                }
                
                if(quot.RFO_ProductionPlanningSection_Started__c=='Yes' && quot.RFO_ProdPlanSectionComplete__c!='Yes'){
                    chatterPaulmsg+='Production Planning Section'+'\n';
                    ProdPlanSection=true;
                }
                
                if(quot.RFO_PricingSectionStarted__c=='Yes' && quot.RFO_PricingSectionComplete__c!='Yes'){
                    chatterPaulmsg+='Pricing Section'+'\n';
                    PricingSection = true;
                }
                
                
                if(PortflioSection == true || EngSection == true || ProdPlanSection == true || EstmSection == true || PricingSection == true){
                    chatterPaulmsg += 'Please fill sections on Quote '+quot.name+'\n';
                    
                                    
                }
            }
        }
        
        if(chatterPaulmsg != ''){
            FeedQuote.ParentId = System.Label.RFO_PaulRogers;
                FeedQuote.body = chatterPaulmsg;
                    listFeed.add(FeedQuote);
        }
        
        if(!steveQuotsLst.isEmpty()){
            for(SBQQ__Quote__c quot : steveQuotsLst)
            {   
                Boolean PortflioSection = false;
                Boolean EngSection = false;
                Boolean EstmSection = false;
                Boolean ProdPlanSection = false;
                Boolean PricingSection = false;
                Boolean paulFeed = false;
                Boolean steveFeed = false;
                
                
                if(quot.RFO_PortfolioManagementSection_Started__c=='Yes' && quot.RFO_PortfolioManagementSectionComplete__c !='Yes'){
                    chatterStevemsg += 'Portfolio Section'+'\n';
                    PortflioSection = true;
                }
                
                if(quot.RFO_EngineeringSectionStarted__c=='Yes' && quot.RFO_EngineeringSectionComplete__c!='Yes'){
                    chatterStevemsg+='Engineering Section'+'\n';
                    EngSection =true;
                    
                }
                if(quot.RFO_EstimatingSectionStarted__c=='Yes' && quot.RFO_EstimatingSectionCompleted__c!='Yes'){
                    chatterStevemsg+='Estimating Section'+'\n';
                    EstmSection = true;
                }
                
                if(quot.RFO_ProductionPlanningSection_Started__c=='Yes' && quot.RFO_ProdPlanSectionComplete__c!='Yes'){
                    chatterStevemsg+='Production Planning Section'+'\n';
                    ProdPlanSection=true;
                }
                
                if(quot.RFO_PricingSectionStarted__c=='Yes' && quot.RFO_PricingSectionComplete__c!='Yes'){
                    chatterStevemsg+='Pricing Section'+'\n';
                    PricingSection = true;
                }
                
                
                if(PortflioSection == true || EngSection == true || ProdPlanSection == true || EstmSection == true || PricingSection == true){
                    chatterStevemsg += 'Please fill sections on Quote '+quot.name+'\n';
                    
                  
                    
                }
            }
        }
        
        if(chatterStevemsg != ''){
            FeedQuote2.ParentId = System.Label.RFO_SteveWalden;
            FeedQuote2.body = chatterStevemsg;
            listFeed.add(FeedQuote2);
            
        }
        
        
        
        
        if(listFeed.size()>0){ 
            insert listFeed;
        } 
    }
    
    
    global void finish(Database.BatchableContext bc) {
        
    }
}