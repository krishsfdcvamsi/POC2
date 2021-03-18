/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 
* @Description : This Class is used to different functionalityh on quote teams.

**/
public class RFO_QuoteTeamMemberHelper {
    public static void handleQuoteTeamMemberChanges(List<Quote_Team_Member__c> qtmList, Map<ID, Quote_Team_Member__c> qtmMap){
        System.debug('Inside handle Quote Team Member Changes:' + qtmList);
        
        Set<Id> quoteIdSet = new Set<Id>();
         
        for(Quote_Team_Member__c qtm : qtmList){
            quoteIdSet.add(qtm.Quote__c);
        }
        System.debug('quoteIdSet:' + quoteIdSet);
        
        Savepoint sp = Database.setSavepoint(); // setting savepoint
        
        
        try{
            //Delete all existing Quote Manual share records
            deleteQuoteShare(quoteIdSet);
            
            //Key QuoteID-UserID
            
            Map<String, SBQQ__Quote__Share> newQuoteShareMap = new Map<String, SBQQ__Quote__Share>();
            SBQQ__Quote__Share quoteShr;
            String keyStr;
            
            //Get current list of Quote team members and create new Quote share records
            for(Quote_Team_Member__c qtm: [select Id, Quote__c,Quote__r.Ownerid, Role__c, User__c
                                           from Quote_Team_Member__c 
                                           where Quote__c in :quoteIdSet
                                           and User__c != null ])
            {
                if(qtm.Quote__r.Ownerid != qtm.User__c){
                System.debug('quote team member: '+ qtm);
                keyStr = qtm.Quote__c + '-' + qtm.User__c;
                if(!newQuoteShareMap.containsKey(keyStr)){
                    quoteShr  = new SBQQ__Quote__Share();
                    quoteShr.ParentId = qtm.Quote__c;
                    quoteShr.UserOrGroupId = qtm.User__c;
                    quoteShr.AccessLevel = 'Edit';
                    quoteShr.RowCause = Schema.SBQQ__Quote__Share.RowCause.Manual;   
                    newQuoteShareMap.put(keyStr, quoteShr);
                }
                }
            }//for
            
            
            System.debug('Quote Share to insert : ' + newQuoteShareMap);
            
            if(!newQuoteShareMap.isEmpty()){
                List<Database.SaveResult> srList = Database.insert(newQuoteShareMap.values(),false);
                for(Database.SaveResult sr : srList){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            if(err.getStatusCode() != StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  && err.getMessage().contains('AccessLevel')){
                                qtmMap.get(sr.getId()).addError('Error while saving: Message:'+err.getMessage()+' Code:'+err.getStatusCode());
                            }
                        }
                    }
                }
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
    
    public static void deleteQuoteShare(Set<Id> quoteIdSet) {
        System.debug('Inside deleteQuoteShare : ' + quoteIdSet);
        List<SBQQ__Quote__Share> quoteShareList = [select Id 
                                                   from SBQQ__Quote__Share 
                                                   where ParentId in :quoteIdSet 
                                                   and RowCause = :Schema.SBQQ__Quote__Share.RowCause.Manual];
        //Delete Existing Quote Share records
        System.debug('Delete Existing Quote Share records : ' + quoteShareList);
        if(quoteShareList != null && !quoteShareList.isEmpty()){
            Database.delete(quoteShareList);          
        }
    }
    
    // Method to add and update Quote Team Members to the Public Group
    public static void addQuoteTeamMemToPublicGroup(List<Quote_Team_Member__c> qtmList,Map<Id,Quote_Team_Member__c> quotetTeamMemOldMap){
        system.debug('@@@@ quotetTeamMemOldMap'+quotetTeamMemOldMap);
        Map<id,Quote_Team_Member__c> filteredQTMap = new Map<id,Quote_Team_Member__c>();
        Map<Id,String> quoteTeamOldUserRoleIds = new Map<Id,String>();
        Set<Id> quoteTeamIds = new Set<Id>();
        for(Quote_Team_Member__c  qtm :qtmList){
            if(quotetTeamMemOldMap !=null && (quotetTeamMemOldMap.containsKey(qtm.Id))){
                if((qtm.User__c != quotetTeamMemOldMap.get(qtm.Id).User__c) || 
                   (qtm.Role__c != quotetTeamMemOldMap.get(qtm.Id).Role__c)){
                       filteredQTMap.put(qtm.Quote__c,qtm);
                       quoteTeamOldUserRoleIds.put(quotetTeamMemOldMap.get(qtm.Id).User__c,quotetTeamMemOldMap.get(qtm.Id).Role__c);
                   }
            } 
            else{
                quoteTeamIds.add(qtm.Id);
            }
            if(quotetTeamMemOldMap != null && !quotetTeamMemOldMap.isEmpty()){
                quoteTeamIds.add(qtm.Id);
            }
        }
       
        if(quoteTeamIds.Size()>0){
            deleteGroupMember(quoteTeamOldUserRoleIds,filteredQTMap.keySet());
            insertGroupMember(quoteTeamIds);
        }
    }
    
    @future
    public static void insertGroupMember(Set<Id> groupMembers){
        Map<Id, String> roleMap = new Map<Id, String>();
        Set<Id> quoteTeamIds = new Set<Id>();
        Map<String, Id> quoteTeamGroupMap = new Map<String, Id>();
        List<GroupMember> gmList = new List<GroupMember>();
        List<Quote_Team_Member__c> qtmList = [Select id, Role__c,User__c from Quote_Team_Member__c where id in :groupMembers];
        if(groupMembers.size() > 0){
            for(Quote_Team_Member__c  qtm :qtmList){
                if(qtm.Role__c=='Portfolio Management'){
                    roleMap.put(qtm.Id, 'RFO_CPQ_'+(qtm.Role__c).replace(' ','_'));
                }
                else if(qtm.Role__c=='Production Planning'){
                    roleMap.put(qtm.Id, 'RFO_CPQ_'+(qtm.Role__c).replace(' ',''));
                }
                else if(qtm.Role__c=='Engineering' || qtm.Role__c=='Estimating'){
                    roleMap.put(qtm.Id, 'RFO_CPQ_'+qtm.Role__c);
                }
                else if(qtm.Role__c=='Sales Admin'){
                    roleMap.put(qtm.Id, 'RFO_CPQ_Sales_Ops');
                }
                else{
                roleMap.put(qtm.Id, 'RFO_CPQ_'+qtm.Role__c);
                }
                
            }
            for(Group quoteTeamGroup : [select Id, Name, DeveloperName  from Group where DeveloperName  in :roleMap.values()]){
                quoteTeamGroupMap.put(quoteTeamGroup.DeveloperName, quoteTeamGroup.Id);
            }
            for(Quote_Team_Member__c  quoteTeam : qtmList){
                String roleName ='';
                if(quoteTeam.Role__c == 'Portfolio Management'){
                    roleName = (quoteTeam.Role__c).replace(' ','_');
                }else if(quoteTeam.Role__c=='Production Planning'){
                    roleName = (quoteTeam.Role__c).replace(' ','');
                }
                else if(quoteTeam.Role__c=='Engineering' || quoteTeam.Role__c=='Estimating'){
                    roleName = (quoteTeam.Role__c);
                }
                else if(quoteTeam.Role__c=='Sales Admin'){
                    roleName = 'Sales_Ops';
                }
                else{
                    roleName = quoteTeam.Role__c;
                }
                GroupMember gm = new GroupMember();
                gm.GroupId = quoteTeamGroupMap.get('RFO_CPQ_'+roleName);
                gm.UserOrGroupId = quoteTeam.user__c;
                gmList.add(gm);
            }
            if(gmList.size() > 0){
                Database.insert(gmList);
            }   
        }
    }
    
    
    @future
    public static void deleteGroupMember(Map<Id,String> groupMembersRoles,Set<Id> quoteTeamMembers){
        
        Set<String> rolesSet = new Set<String>();
        Map<Id, String> roleMap = new Map<Id, String>();
        Set<Id> quoteTeamIds = new Set<Id>();
        Map<String, Id> quoteTeamGroupMap = new Map<String, Id>();
        List<GroupMember> gmList = new List<GroupMember>();
        //quote team members list id in teammembers Users which are not in other quote team members		
        List<Quote_Team_Member__c> qtmList = [SELECT Id, Role__c,Quote__c,User__c 
                                              FROM Quote_Team_Member__c 
                                              WHERE User__c IN :groupMembersRoles.KeySet() 
                                              AND Quote__c NOT IN :quoteTeamMembers 
                                              AND Role__c IN :groupMembersRoles.values() LIMIT 49999];
        //Checking OLd User value in other Quote Team 
       
        if(qtmList.isEmpty()){
            for(String roleStr: groupMembersRoles.Values()){
                if(roleStr == 'Portfolio Management'){
                 rolesSet.add('RFO_CPQ_'+roleStr.replace(' ','_'));
                }
                else if(roleStr == 'Production Planning'){
                 rolesSet.add('RFO_CPQ_'+roleStr.replace(' ',''));
                }
                else if(roleStr=='Engineering' || roleStr=='Estimating'){
                    rolesSet.add('RFO_CPQ_'+roleStr);
                }
                else if(roleStr=='Sales Admin'){
                    rolesSet.add('RFO_CPQ_Sales_Ops');
                }
                else{
                    rolesSet.add('RFO_CPQ_'+roleStr);
                }
            }
        }
        
        //delete Old Engineering user from Engg Public Group
        if(groupMembersRoles != null && qtmList.isEmpty()){
           List<GroupMember> listGpMembers = [Select Id,Group.DeveloperName, UserOrGroupID 
                                               from GroupMember 
                                               where UserOrGroupID IN :groupMembersRoles.Keyset() 
                                               AND Group.DeveloperName IN :rolesSet LIMIT 49999 ];
            if(!listGpMembers.isEmpty()){
                try{
                    Database.delete(listGpMembers);      
                }
                catch(exception exp){
                    system.debug('============>'+exp.getStackTraceString());
                }
                       
            }  
        } 
    }
    
    public static void deleteQTMRecord(Map<Id,Quote_Team_Member__c> quotetTeamMemOldMap){
        Map<Id,String> quoteTeamOldUserRoleIds = new Map<Id,String>();
        Map<id,Quote_Team_Member__c> filteredQTMap = new Map<id,Quote_Team_Member__c>();
        for(Id  qtm :quotetTeamMemOldMap.keySet()){
            Quote_Team_Member__c oldItems = quotetTeamMemOldMap.get(qtm);
            filteredQTMap.put(oldItems.Quote__c,oldItems);
            quoteTeamOldUserRoleIds.put(oldItems.User__c,oldItems.Role__c);
        }
        if(!quotetTeamMemOldMap.isEmpty()){
            deleteGroupMember(quoteTeamOldUserRoleIds,filteredQTMap.keySet());
        }
    }
   
}