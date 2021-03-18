/*
* Class Name : RFO_TeamMemberHelperTest 
*/
@isTest(seeAllData = false)
public class RFO_TeamMemberHelperTest {
    @testsetup static void createQuoteTeamTestdata(){
        Id recordTypeIdMS = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Maintenance_services').getRecordTypeId();
        List<Account> accList = new List<Account>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c();
        SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
        //Creating an Account
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = '14098';
        accList[0].RFO_OracleId__c = '123456';
        accList[0].RFO_TASId__c = '1234';
        Database.insert(accList);
      //Creating an Opportunity
        opportunityList=RFO_Utility_Test.createTankOpportunities(accList[0]);
        opportunityList[0].StageName = 'Quoting';
        opportunityList[0].RecordTypeId = recordTypeIdMS;
        Database.insert(opportunityList);
        //Creating a QuoteTeam
        quoteTeamRecord = RFO_Utility_Test.createQuoteTeam();
        Database.insert(quoteTeamRecord);
         //Creating a CPQ Quote
        cpqQuoteList = RFO_Utility_Test.createCPQPrimaryQuote(opportunityList[0], quoteTeamRecord);
        cpqQuoteList.RFO_ProposalRefreshStatus__c = 'Resubmit for Pricing';   // Proposal Refresh Status
        cpqQuoteList.RFO_ProposalRefreshRequired__c = 'Yes';                  // Proposal Refresh Required
        cpqQuoteList.RFO_DaysUntilProposalExpires__c = '30'; 
        cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;
        Database.insert(cpqQuoteList);
        //User Creation
         User userQuoteTeam = new User();
        userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
        Database.insert(userQuoteTeam);
        // Creating a Quote Team member
         List<Quote_Team_Member__c> qtmList = new List<Quote_Team_Member__c>();
                Quote_Team_Member__c quotteammem = new Quote_Team_Member__c();
                      quotteammem = RFO_Utility_Test.createQuoteTeamMember(cpqQuoteList,userQuoteTeam);
                      qtmList.add(quotteammem );
                      Database.insert(qtmList);
       
       
        
    }  
    private static testMethod void createTeamMember(){
        RFO_QuoteTeams__c quoteteams = [select id from RFO_QuoteTeams__c Limit 1];
        Quote_Team_Member__c quoteTmmem =[Select id from Quote_Team_Member__c Limit 1];
        SBQQ__Quote__c quot=[select id from SBQQ__Quote__c Limit 1];
        User userQuoteTeam = new User();
        userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
        Database.insert(userQuoteTeam);
        RFO_TeamMembers__c teammem = new RFO_TeamMembers__c(); 
        teammem.Role__c = 'Engineering';
        teammem.User__c = userQuoteTeam.id;
        teammem.Team__c=quoteteams.id;
        Test.startTest();   
        
        insert teammem;
        teammem.Role__c = 'Pricing';
        update teammem;
        RFO_TeamMemberTriggerHandler objTMTH = new RFO_TeamMemberTriggerHandler();
        objTMTH.afterInsert(null);
        Test.stopTest();
    }
    private static testMethod void deleteTeamMember(){
        RFO_QuoteTeams__c quoteteams = [select id from RFO_QuoteTeams__c Limit 1];
        Quote_Team_Member__c quoteTmmem =[Select id from Quote_Team_Member__c Limit 1];
        SBQQ__Quote__c quot=[select id from SBQQ__Quote__c Limit 1];
         User userQuoteTeam = new User();
        userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
        Database.insert(userQuoteTeam);
        RFO_TeamMembers__c teammem = new RFO_TeamMembers__c(); 
         teammem.Role__c = 'Engineering';
         teammem.User__c = userQuoteTeam.id;
       teammem.Team__c=quoteteams.id;
      insert teammem;
         RFO_TeamMemberTriggerHandler obj= new RFO_TeamMemberTriggerHandler();
         Test.startTest();
              // obj.afterInsert(null);
      //obj.beforeInsert(null);
     //obj.beforeUpdate(null,null);
                obj.afterDelete(null);
               obj.beforeDelete(null);
                obj.afterUnDelete(null);
     obj.afterUpdate(null,null);
       
        Test.stopTest();  
         
      }
    
}