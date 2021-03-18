/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 
* @Description : This Class is used to call team member helper actions.
                           
**/
public without sharing class RFO_TeamMemberHelper {
 
    /**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 
* @Description :This method adds quote team members from Quote Team assigned to Quote
**/ 
    public static void updateQuoteTeamMembers(List<RFO_TeamMembers__c> teamMemberList){
        System.debug('Inside updateQuoteTeamMembers:' + teamMemberList);
        //Set of Team IDs
        Set<Id> teamSet = new Set<Id>();
        List<RFO_TeamMembers__c> teamMemList = new List<RFO_TeamMembers__c>();
        List<RFO_TeamMembers__c> allTeamMembrsList = new List<RFO_TeamMembers__c>();
        //Map of TeamId, teamMemberlist
        Map<Id, List<RFO_TeamMembers__c>> teamMembersMap = new Map<Id, List<RFO_TeamMembers__c>>();
        
        //Map of TeamId, quotelist
        Map<Id, List<SBQQ__Quote__c>> teamQuoteMap = new Map<Id, List<SBQQ__Quote__c>>();
        
        for(RFO_TeamMembers__c teamMem : teamMemberList){
            if(teamMem.Team__c != null) teamSet.add(teamMem.Team__c);
            //teamMemList.add(teamMem);
            //teamMembersMap.put(teamMem.Team__c,teamMemList);
        }
        System.debug('teamSet : ' + teamSet);
        
        teamMemList = [select id,Team__c,Role__c,User__c from RFO_TeamMembers__c where Team__c IN:teamSet Limit 49999  ];
        
        for(RFO_TeamMembers__c teamMm: teamMemList){
          allTeamMembrsList.add(teamMm);  
          teamMembersMap.put(teamMm.Team__c,allTeamMembrsList);
        }
        
        List<SBQQ__Quote__c> quoteList = [select id,RFO_QuoteTeam__c from SBQQ__Quote__c where RFO_QuoteTeam__c IN:teamSet Limit 49999  ];
        //Get Team Members
        //
        for(SBQQ__Quote__c quoteTm : quoteList)
        {
            if(teamQuoteMap.containsKey(quoteTm.RFO_QuoteTeam__c))
            {
                //append
                teamQuoteMap.get(quoteTm.RFO_QuoteTeam__c).add(quoteTm);
            }else{
                //add new
                List<SBQQ__Quote__c> quoteTmList = new List<SBQQ__Quote__c>();
                quoteTmList.add(quoteTm);
                teamQuoteMap.put(quoteTm.RFO_QuoteTeam__c, quoteTmList);
            }
        }
        System.debug('teamMembersMap : ' + teamMembersMap);
        
        Savepoint sp = Database.setSavepoint(); // setting savepoint
        List<Quote_Team_Member__c> newQuoteTeamMemerList = new List<Quote_Team_Member__c>();
        Quote_Team_Member__c quoteTeamMemer;
        
        try{
            //Get list of members from team assigned to each Quote and delete
            deleteQuoteTeamMembers(quoteList);
            //loop thru quote
            for(SBQQ__Quote__c quote : quoteList){
                if(!(quote.RFO_QuoteTeam__c != null && teamQuoteMap.containsKey(quote.RFO_QuoteTeam__c))) continue;
                
                for(RFO_TeamMembers__c teamMember : teamMembersMap.get(quote.RFO_QuoteTeam__c)){
                    //assign Quote team members
                    quoteTeamMemer = new Quote_Team_Member__c();
                    quoteTeamMemer.Quote__c = quote.Id;
                    quoteTeamMemer.Role__c = teamMember.Role__c;
                    quoteTeamMemer.User__c = teamMember.User__c;
                    newQuoteTeamMemerList .add(quoteTeamMemer);
                }
            }
            //insert Quote Team members
            System.debug('insert Quote Team members : ' + newQuoteTeamMemerList);
            if(newQuoteTeamMemerList != null && !newQuoteTeamMemerList.isEmpty()){
                Database.insert(newQuoteTeamMemerList,false);
                System.debug('Created Quote Team members : ' + newQuoteTeamMemerList);
            }
            
        }catch(Exception e){ // handling exception
            System.debug('RFO_QuoteTeamMemberTriggerHandler Exception getCause : '+e.getCause());
            System.debug('RFO_QuoteTeamMemberTriggerHandler Exception getLineNumber : '+e.getLineNumber());
            System.debug('RFO_QuoteTeamMemberTriggerHandler Exception getMessage : '+e.getMessage());
            System.debug('RFO_QuoteTeamMemberTriggerHandler Exception getStackTraceString : '+e.getStackTraceString());
            Database.rollback( sp ); // roll back the DML transaction when error occured
            throw e;
        }
    }
    
    public static void deleteQuoteTeamMembers(List<SBQQ__Quote__c> quoteList) {
        System.debug('Inside deleteQuoteTeamMembers : ' + quoteList);
        List<Quote_Team_Member__c> quoteMemberList = [select Id 
                                                      from Quote_Team_Member__c 
                                                      where Quote__c in :quoteList];
        //Delete Existing Quote Member records
        System.debug('Delete Existing Quote Member records : ' + quoteMemberList);
        if(quoteMemberList != null && !quoteMemberList.isEmpty()){
            Database.delete(quoteMemberList);          
        }
    }
    
}