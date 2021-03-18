public without sharing class CDX_GetAccountTeamMemberData {

    @AuraEnabled(cacheable=true)
    
    //Select AccountTeamMember data with associated AccountId  
    public static List<AccountTeamMember> getAccountTeamMemberList(String accId) {
   
       List<AccountTeamMember> atm = [Select
                                      Id, AccountId,TeamMemberRole, Title, user.id, user.name, user.phone, user.Email
                                      from AccountTeamMember 
                                      where AccountId=:accId]; 
        
        return atm;
    }
    
}