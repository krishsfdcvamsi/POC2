/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 26 Nov 2019
* @Description : This class is to Send Account Team Member info to TAS.
*                
**/
public class RFO_AccountTeamMemberTriggerHandler implements ITriggerHandler{
  public static Boolean TriggerDisabled = false;
    public String RecordStatus;
    static final string C_D_M = 'Customer Delivery Manager';
    RFO_TriggerSetting__mdt caseTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='AccountTeamMemberTrigger'];
    /**
 * Checks to see if the trigger has been disabled either by custom setting or by running code
**/
    public Boolean IsDisabled()
    {
        if (caseTrigger.RFO_Active__c)
            return TriggerDisabled;
        else
            return true;
    }
    /**
     * To restrict the user to create more than one Account team with same role
     * */
    public void BeforeInsert(List<SObject> newItems) 
    {
        try{
            RFO_AccountTeamMemberHelper.aTeamRestriction((List<AccountTeamMember>)newItems, null);
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
/**
     * To restrict the user to create more than one Account team with same role
     * */
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Set<Id> accountSet = new Set<Id>();
        Map<Id, List<String>> aTeamMap = new Map<Id, List<String>>();
        try{
            RFO_AccountTeamMemberHelper.aTeamRestriction((List<AccountTeamMember>)newItems.Values(), oldItems);
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
/**
 * Send Account Team info to tas
 **/
    public void AfterInsert(Map<Id, SObject> newItems) {
        try{
            Map<AccountTeamMember, String> aTeamNewMap = new Map<AccountTeamMember, String>();
            set<Id> accountIds = new set<Id>();
            for(AccountTeamMember aTeamRec : 
                [Select Id, AccountId, TeamMemberRole, Account.Owner.Lan_Id__c, 
                 Account.lastModifiedBy.Lan_Id__c, Account.RFO_TASId__c, User.Lan_Id__c, RFO_TASStatus__c 
                 FROM AccountTeamMember WHERE Id in:newItems.keySet()]){
                     if(aTeamRec.TeamMemberRole != RFO_Constant.SALES_MANAGER){
                         aTeamNewMap = RFO_AccountTeamMemberHelper.sendAccountTeamInfoToTAS(aTeamRec, RFO_Constant.TRIGER);
                     }
                 }
            RFO_AccountTeamMemberHelper.afterInsertUpdateCDMUser((List<AccountTeamMember>)newItems.Values()); // Alpha 165     
            for(AccountTeamMember atm : (List<AccountTeamMember>)newItems.values()) {
                if(atm.TeamMemberRole == C_D_M) {
                    accountIds.add(atm.accountId);
                }
            }
            if(!accountIds.isEmpty()) {
                Database.executeBatch(new UpdateCdmNameBatch(accountIds), 1);
            }
        }
        catch(Exception e) {  
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.ACCOUNT_TEAM_MEMBER,
                                                   RFO_Constant.TRIGER,'RFO_AccountTeamTriggerHandler','sendAccountTeamInfoToTAS');            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
/**
 * Send Account Team info to tas
 **/
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try{
            //Added By MA
            set<Id> accountIds = new set<Id>();
            map<id,AccountTeamMember> oldTeamMap = new map<id,AccountTeamMember>();
            for(AccountTeamMember atm : (List<AccountTeamMember>)newItems.values()) {
                if(atm.TeamMemberRole == C_D_M && atm.TeamMemberRole != oldTeamMap.get(atm.Id).TeamMemberRole) {
                    accountIds.add(atm.accountId);
                }
            }
            if(!accountIds.isEmpty()) {
                Database.executeBatch(new UpdateCdmNameBatch(accountIds), 1);
            }
            //End by MA
            if(!(System.isFuture() || System.isBatch())){
                Map<AccountTeamMember, String> aTeamNewMap = new Map<AccountTeamMember, String>();
                for(AccountTeamMember aTeamRec : 
                    [Select Id, AccountId, TeamMemberRole, Account.Owner.Lan_Id__c, Account.lastModifiedBy.Lan_Id__c, Account.RFO_TASId__c, User.Lan_Id__c, RFO_TASStatus__c FROM AccountTeamMember WHERE Id in:newItems.keySet()]){
                        if(aTeamRec.TeamMemberRole != RFO_Constant.SALES_MANAGER){
                            aTeamNewMap = RFO_AccountTeamMemberHelper.sendAccountTeamInfoToTAS(aTeamRec, RFO_Constant.TRIGER);
                        }
                    }
            }
            
            RFO_AccountTeamMemberHelper.updateCDMUser((List<AccountTeamMember>)newItems.Values(),(map<id,AccountTeamMember>)oldItems); // Alpha 165
        }
        catch(Exception e) {   
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.ACCOUNT_TEAM_MEMBER,
                                                   RFO_Constant.TRIGER,'RFO_AccountTeamTriggerHandler','sendAccountTeamInfoToTAS');
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems) {
        RFO_AccountTeamMemberHelper.afterDeleteUpdateCDMUser((List<AccountTeamMember>)oldItems.Values());
    }
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}