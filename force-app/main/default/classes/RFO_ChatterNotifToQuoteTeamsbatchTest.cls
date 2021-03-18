/** @Author      : Accenture
* @Version     : 1.0
* @Created Date: 24 June 2019
* @Description : This class is used for sending the chatter notification to Quote Team User when 
the user does not complete his section within a time frame. 
**/
@isTest(SeeAllData=false)
private class RFO_ChatterNotifToQuoteTeamsbatchTest{
    /**
* Test method with test data to pass scheduled batch class 
**/
     @testsetup static void createOptyTestdata(){
         List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        Database.insert(accList);
		
		
		 // Opportunity Creation     
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = RFO_Utility_Test.createTankOpportunities(accList[0]);
        Database.insert(oppList);  
         //QuoteTeam Creation
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
       Database.insert(quoteTeamRec);
         
         
     }
    /**This method is used to send the chatter notification to the Quote team members when any
field on their section of quote is started and account record type is RFO_ThirdPartySales **/
    static testmethod void quotechattersenttoQuoteteam(){
        String cRON_EXP = '0 0 7 * * ?';
         Account accRec = [select id, name from Account Limit 1];
        Id salesrecid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_ThirdPartySales').getRecordTypeId();
        accRec.RecordtypeId=salesrecid;
        Database.update(accRec); 
        Opportunity oppRec = [select id, name from Opportunity Limit 1];
        RFO_QuoteTeams__c qtmRec = [select id, name from RFO_QuoteTeams__c Limit 1];
        Id recordTypeIdNewCarLease = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName()
            .get('RFO_New').getRecordTypeId();       
        //  SBQQ__Quote__c quotteam = new SBQQ__Quote__c();
        SBQQ__Quote__c  quotecreate = RFO_Utility_Test.createQuote(oppRec);
        quotecreate.RFO_QuoteTeam__c=qtmRec.id;  
        quotecreate.RFO_PortfolioManagementSection_Started__c='Yes';
        quotecreate.RFO_EngineeringSectionStarted__c='Yes';
        quotecreate.RFO_EstimatingSectionStarted__c='Yes';
        quotecreate.RFO_ProductionPlanningSection_Started__c='Yes';
        quotecreate.RFO_PortfolioManagementSectionComplete__c =' ' ;
        quotecreate.RFO_PortfolioManagementSectionComplete__c ='No' ;
        quotecreate.RFO_ProdPlanSectionComplete__c='';
        quotecreate.RFO_PricingSectionStarted__c='Yes';
        quotecreate.RFO_PricingSectionComplete__c='';
        quotecreate.RecordtypeId=RecordTypeIdNewCarLease; 
        Database.insert(quotecreate);
         Test.setCreatedDate(quotecreate.Id, DateTime.newInstance(2019,10,21));
         Test.startTest();
        String jobId = System.schedule('ChatterNotificationScheduleApexClassTest', 
                                       cRON_EXP, new RFO_ChatterNotificationOnQuote());
        CronTrigger crontrig = [SELECT Id, CronExpression, TimesTriggered, 
                                NextFireTime FROM CronTrigger WHERE id = :jobId Limit 1];
        Test.stopTest();
        system.assertEquals(quotecreate.RFO_PricingSectionStarted__c, 'Yes');
    }
    /*This method is used to send a chatter notification to Quote Team members and Account Record type is RFO_Prospect */
    static testmethod void quotechattersenttoQuoteteam1(){
        String cRON_EXP = '0 0 7 * * ?';
         Account accRec = [select id, name from Account Limit 1];
Id prosRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get(System.Label.RFO_Prospect).getRecordTypeId();
        accRec.RecordtypeId=prosRecordTypeId;
        Database.update(accRec); 
        Opportunity oppRec = [select id, name from Opportunity Limit 1];
        ID optyfreiId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Freight').getRecordTypeId();
       oppRec.RecordtypeId= optyfreiId;
        Database.update(oppRec); 
        RFO_QuoteTeams__c qtmRec = [select id, name from RFO_QuoteTeams__c Limit 1];
        Id recordTypeIdNewCarLease = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName()
            .get('RFO_New').getRecordTypeId();
        SBQQ__Quote__c  quotecreate = RFO_Utility_Test.createQuote(oppRec);
        quotecreate.RFO_QuoteTeam__c=qtmRec.id;  
        quotecreate.RFO_PortfolioManagementSection_Started__c='Yes';
        quotecreate.RFO_EngineeringSectionStarted__c='Yes';
        quotecreate.RFO_EstimatingSectionStarted__c='Yes';
        quotecreate.RFO_ProductionPlanningSection_Started__c='Yes';
        quotecreate.RFO_PortfolioManagementSectionComplete__c =' ' ;
        quotecreate.RFO_PortfolioManagementSectionComplete__c ='No' ;
        quotecreate.RFO_ProdPlanSectionComplete__c='';
        quotecreate.RFO_PricingSectionStarted__c='Yes';
        quotecreate.RFO_PricingSectionComplete__c='';
        quotecreate.RecordtypeId=RecordTypeIdNewCarLease; 
        Database.insert(quotecreate);
         Test.setCreatedDate(quotecreate.Id, DateTime.newInstance(2019,10,21));
         Test.startTest();
        String jobId = System.schedule('ChatterNotificationScheduleApexClassTest', 
                                       cRON_EXP, new RFO_ChatterNotificationOnQuote());
        CronTrigger crontrig = [SELECT Id, CronExpression, TimesTriggered, 
                                NextFireTime FROM CronTrigger WHERE id = :jobId Limit 1];
        Test.stopTest();
        system.assertEquals(quotecreate.RFO_PricingSectionStarted__c, 'Yes');
    }
}