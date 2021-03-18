global class RFO_ChatterNotiticationToQuoteTeamsbatch implements Database.Batchable<sObject>,Schedulable{

global void execute(SchedulableContext sc)
    {
        // We now call the batch class to be scheduled
        RFO_ChatterNotiticationToQuoteTeamsbatch quoBatch = new RFO_ChatterNotiticationToQuoteTeamsbatch();
       
        // Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
        //String cronStr = '0 0 6 * * ?'; //Daily 6AM CST
        //System.schedule('Quotes Days before proposal referesh', cronStr, quoBatch);
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executeBatch(quoBatch, 200);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    DateTime DT = DateTime.newInstance(2019, 10, 21);
     return Database.getQueryLocator([SELECT Id,Name,CreatedDate,RecordTypeID,RFO_PortfolioManagementSectionComplete__c,
        RFO_EngineeringSectionComplete__c,RFO_EstimatingSectionCompleted__c,RFO_ProdPlanSectionComplete__c,RFO_PricingSectionComplete__c,
        RFO_QuoteTeam__r.RFO_PortfolioMember__c,RFO_QuoteTeam__r.RFO_EngineeringMember__c,RFO_QuoteTeam__r.RFO_EstimatingMember__c,
        RFO_QuoteTeam__r.RFO_PricingMember__c,RFO_QuoteTeam__r.RFO_PlanningMember__c FROM SBQQ__Quote__c where  createdDate >=:DT  AND  (RFO_QuoteTeam__c!=NULL OR RFO_QuoteTeam__c!='') ]);
    }
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> quoteList) {
    Id newid = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_New').getRecordTypeId();
    Id existingid = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_Existing').getRecordTypeId(); 
     List<FeedItem> listFeed = new List<FeedItem>();
               
        if(!quoteList.isEmpty()){   
          
            for(SBQQ__Quote__c quot : quoteList)
            {   
                    FeedItem portfeed = new FeedItem();
                    FeedItem engfeed = new FeedItem(); 
                    FeedItem estfeed = new FeedItem(); 
                    FeedItem pricingfeed = new FeedItem(); 
                    FeedItem prdplnfeed= new FeedItem();
                    DateTime quotecreatedate=quot.CreatedDate;
                    DateTime currentdate= System.Now();
                    Integer diffdays=quotecreatedate.Date().daysBetween(currentdate.Date());
                    String ss;
                    
                    if( (quot.RecordTypeID==newid || quot.RecordTypeID==existingid)&&
                        (diffdays>=2 || diffdays>=1) && 
                        (quot.RFO_PortfolioManagementSectionComplete__c!='Yes' || 
                        quot.RFO_EngineeringSectionComplete__c!='Yes' ||
                        quot.RFO_EstimatingSectionCompleted__c!='Yes' ||
                        quot.RFO_PricingSectionComplete__c!='Yes' ||
                        quot.RFO_ProdPlanSectionComplete__c!='Yes' )){
                            
                         ss = 'SLA for Quote '+quot.name+' has been exceeded for'+'\n';   
                         
                        if(quot.RecordTypeID==newid){                   
                            if(diffdays>=2 ){
                            if(quot.RFO_PortfolioManagementSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_PortfolioMember__c)){
                             ss += 'Portfolio Management'+'\n';
                                portfeed.ParentId = quot.RFO_QuoteTeam__r.RFO_PortfolioMember__c;
                                portfeed.Body ='SLA for Quote '+quot.name+' has been exceeded ....please review.' ;
                                listFeed.add(portfeed);
                                }
                            if(quot.RFO_EngineeringSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_EngineeringMember__c)){
                                ss += 'Engineering'+'\n';
                                engfeed.ParentId = quot.RFO_QuoteTeam__r.RFO_EngineeringMember__c;
                                engfeed.Body ='SLA for Quote '+quot.name+' has been exceeded ....please review.' ;
                                listFeed.add(engfeed);
                                }
                            if(quot.RFO_EstimatingSectionCompleted__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_EstimatingMember__c)){
                                ss += 'Estimating'+'\n';
                                estfeed.ParentId = quot.RFO_QuoteTeam__r.RFO_EstimatingMember__c;
                                estfeed.Body ='SLA for Quote '+quot.name+' has been exceeded ....please review.' ;
                                listFeed.add(estfeed);
                                }
                            if(quot.RFO_PricingSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_PricingMember__c)){
                                ss += 'Pricing'+'\n';
                                pricingfeed.ParentId = quot.RFO_QuoteTeam__r.RFO_PricingMember__c;
                                pricingfeed.Body ='SLA for Quote '+quot.name+' has been exceeded ....please review.' ;
                                listFeed.add(pricingfeed);
                                }   
                            }
                        else if(diffdays>=1){
                            if(quot.RFO_ProdPlanSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_PlanningMember__c)){
                                ss += 'Production Planning'+'\n';
                                    prdplnfeed.ParentId = quot.RFO_QuoteTeam__r.RFO_PlanningMember__c;
                                    prdplnfeed.Body ='SLA for Quote '+quot.name+' has been exceeded ....please review.' ;
                                    listFeed.add(prdplnfeed);
                                    }
                            }               
                        }
                        else if(quot.RecordTypeID==existingid){
                            if(diffdays>=1 ){
                            if(quot.RFO_PortfolioManagementSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_PortfolioMember__c)){
                             ss += 'Portfolio Management'+'\n';
                                portfeed.ParentId = quot.RFO_QuoteTeam__r.RFO_PortfolioMember__c;
                                portfeed.Body ='SLA for Quote '+quot.name+' has been exceeded ....please review.' ;
                                listFeed.add(portfeed);
                                }
                            if(quot.RFO_EngineeringSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_EngineeringMember__c)){
                              ss += 'Engineering'+'\n';
                                engfeed.ParentId = quot.RFO_QuoteTeam__r.RFO_EngineeringMember__c;
                                engfeed.Body ='SLA for Quote '+quot.name+' has been exceeded ....please review.' ;
                                listFeed.add(engfeed);
                                }
                            if(quot.RFO_EstimatingSectionCompleted__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_EstimatingMember__c)){
                             ss += 'Estimating'+'\n';
                                estfeed.ParentId = quot.RFO_QuoteTeam__r.RFO_EstimatingMember__c;
                                estfeed.Body ='SLA for Quote '+quot.name+' has been exceeded ....please review.' ;
                                listFeed.add(estfeed);
                                }
                            if(quot.RFO_PricingSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_PricingMember__c)){
                                ss += 'Pricing'+'\n';
                                pricingfeed.ParentId = quot.RFO_QuoteTeam__r.RFO_PricingMember__c;
                                pricingfeed.Body ='SLA for Quote '+quot.name+' has been exceeded ....please review.' ;
                                listFeed.add(pricingfeed);
                                }
                            if(quot.RFO_ProdPlanSectionComplete__c!='Yes' && String.isNotBlank(quot.RFO_QuoteTeam__r.RFO_PlanningMember__c)){
                             ss += 'Production Planning'+'\n';
                                prdplnfeed.ParentId = quot.RFO_QuoteTeam__r.RFO_PlanningMember__c;
                                prdplnfeed.Body ='SLA for Quote '+quot.name+' has been exceeded ....please review.' ;
                                listFeed.add(prdplnfeed);
                                }   
                            }
                        }
                        
                        ss += '....please review.';
                        FeedItem jamalfeed = new FeedItem();
                        jamalfeed.ParentId = System.Label.RFO_JamalWashington;
                        jamalfeed.Body =ss ;
                        listFeed.add(jamalfeed);
                         
                    }   
                
            }
            if(listFeed.size()>0){
                Database.insert(listFeed);
            } 
        }
    }
global void finish(Database.BatchableContext bc) {
        
    }
}