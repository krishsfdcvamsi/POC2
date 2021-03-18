/* Class Name : AccountTeamMemberService
 * Description : Service Class for AccountTeamMember Object
 * Created By : Ashish Reddy
 * Created On : 10/28/20
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/28/20                   Ashish Reddy                       Alpha-679 
 * 10/23/20                   Ashish Reddy                       Alpha-680

 * 11/09/20				      Vihari                             Alpha-932

 */
public class AccountTeamMemberService {
    
 /* Method to Query  AccountTeamMembers
  * @param accountIds - Set<Id> of the Account Ids  
  * 
  * @returns Map<Id, List<AccountTeamMember>> 
  */   
 public static Map<Id, List<AccountTeamMember>> getAccountTeamMembersByAccId(Set<Id> accountIds){
     Map<Id, List<AccountTeamMember>> accountTeamMembersMap = new Map<Id, List<AccountTeamMember>>();
     for( AccountTeamMember acctTeamMember : [ Select Id, AccountId, UserId, TeamMemberRole from AccountTeamMember where AccountId in: accountIds]){
         if(accountTeamMembersMap.containsKey(acctTeamMember.AccountId)){
			 List<AccountTeamMember>  teamMemberList = accountTeamMembersMap.get(acctTeamMember.AccountId);    
             teamMemberList.add(acctTeamMember); accountTeamMembersMap.put(acctTeamMember.AccountId, teamMemberList);
         }else {
			 List<AccountTeamMember>  teamMemberList = new List<AccountTeamMember>();    
             teamMemberList.add(acctTeamMember);
             accountTeamMembersMap.put(acctTeamMember.AccountId, teamMemberList);             
         }
     }
       system.debug('accountTeamMembersMap'+accountTeamMembersMap);
    return accountTeamMembersMap;
 }
     

  /* Method to query CDM AccountTeamMember 
   * @param accIds - id's of account records whose CDM AccountMember should be queried
   * @return Map<String,String> - Id of the recordType queried 
   *
   */
    public static Map<String,AccountTeamMember> getAccountCDMMembers(Set<Id> accIds){
        Map<String,AccountTeamMember> accountToAccCDMTeamMap = new  Map<String,AccountTeamMember>();
        for(AccountTeamMember member: [Select id,UserId, AccountId from AccountTeamMember where AccountId IN :accIds and TeamMemberRole = :RFO_Constant.Account_Member_Role_CDM LIMIT 1]){
            accountToAccCDMTeamMap.put(member.AccountId, member);
        }
        return accountToAccCDMTeamMap;
    }
     

}