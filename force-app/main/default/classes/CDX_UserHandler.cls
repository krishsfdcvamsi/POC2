public without sharing class CDX_UserHandler {
    
    public static void CheckUserAccount(List<User> usr){
        
        Set<Id> accId = new Set<Id>();
        
        for(User u : usr){
            accId.add(u.AccountId);
        }
        
        List<User> userList = [select
                               id, Name, isActive, profile.name, Profile.UserLicense.Name, AccountId 
                               from User
                               where AccountId =:accId and isActive=true and (profile.name='CDX Customer' or profile.name='CDX Customer - Super User')];
        
        // system.debug('Account User '+userList.size());
        // Find current login user profile name
        // 
        id id1 = userinfo.getProfileId();
        profile pro = [Select id, name from profile where id =:id1];
        system.debug('proforUserHandler'+pro);
    
        if(pro.name=='CDX Customer' || pro.name=='CDX Customer - Super User'){
            for(User u:usr){
                if(userList.size() > 3){ u.addError('This account has reached its user limit, please contact your customer delivery manager to add an additional customer portal user');
                }
            }
        }
        
    }
    
    
    public static void publishNewUserRecord(List<User> usr){
 
        // ID for "Trinity Development" chatter group
        String chatterGroupId = Label.CDX_Dev_Group;
        List<CollaborationGroup> chatterGroup = [SELECT ID, Name FROM CollaborationGroup WHERE ID =: chatterGroupId LIMIT 1];      
        
        List<New_User__e> newUserEvents = new List<New_User__e>();
        
        for(User newUser : usr) {  
            New_User__e userEvent = new New_User__e();         
            userEvent.ID__c = newUser.ID;
            userEvent.alias__C = newUser.Alias;
            userEvent.username__c = newUser.Username;
            userEvent.FirstName__c = newUser.FirstName;
            userEvent.LastName__c = newUser.LastName;
            userEvent.Phone__c = newUser.Phone;
            userEvent.Email__c = newUser.Email;
            userEvent.UserType__c = newUser.UserType;
            userEvent.ProfileID__c = newUser.ProfileId;
            userEvent.AccountID__c = newUser.AccountId;
            userEvent.LAN_ID__c = newUser.Lan_Id__c;
            newUserEvents.add(userEvent);
        }         
        
        if(newUserEvents.size() > 0) {         
            Database.SaveResult[] srList = EventBus.publish(newUserEvents);
            
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    String BodyOfEvent = 'New User record created: ';
                    List<string> lsstr = new List<string> ();
                    
                    for(Object a : newUserEvents) {
                        lsstr.add(String.valueOf(a));
                    }
                    for(String s : lsstr) {
                        BodyOfEvent += s;
                    }
                    if (chatterGroup.size() != 0){
                        FeedItem post = new FeedItem();
                        //post.ParentId = UserInfo.getUserId() ;
                        post.ParentId = chatterGroup[0].id ;
                        post.Body=BodyOfEvent;
                        insert post;
                        System.debug('post'+post);
                    }                    
                } 
                else {                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }   
    }
    
    
    public static void publishUpdatedUserRecord(List<User> usr){

        // ID for "Trinity Development" chatter group
        String chatterGroupId = Label.CDX_Dev_Group;
        List<CollaborationGroup> chatterGroup = [SELECT ID, Name FROM CollaborationGroup WHERE ID = :chatterGroupId LIMIT 1];       
        
        List<Updated_User__e> updatedUserEvents = new List<Updated_User__e>();
        
        for(User newUser : usr) {
            Updated_User__e userEvent = new Updated_User__e();         
            userEvent.ID__c = newUser.ID;
            userEvent.alias__C = newUser.Alias;
            userEvent.username__c = newUser.Username;
            userEvent.FirstName__c = newUser.FirstName;
            userEvent.LastName__c = newUser.LastName;
            userEvent.Phone__c = newUser.Phone;
            userEvent.Email__c = newUser.Email;
            userEvent.UserType__c = newUser.UserType;
            userEvent.ProfileID__c = newUser.ProfileId;
            userEvent.AccountID__c = newUser.AccountId; 
            userEvent.LAN_ID__c = newUser.Lan_Id__c;
            updatedUserEvents.add(userEvent);
        }     
        
        if(updatedUserEvents.size() > 0) {        
            Database.SaveResult[] srList = EventBus.publish(updatedUserEvents);
            
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    String BodyOfEvent = 'User record updated: ';
                    List<string> lsstr = new List<string> ();
                    
                    for(Object a : updatedUserEvents) {
                        lsstr.add(String.valueOf(a));
                    }
                    for(String s : lsstr) {
                        BodyOfEvent += s;
                    }
                    if (chatterGroup.size() != 0){
                        FeedItem post = new FeedItem();
                        //post.ParentId = UserInfo.getUserId() ;
                        post.ParentId = chatterGroup[0].id ;
                        post.Body=BodyOfEvent;
                        insert post;
                        System.debug('post'+post);
                    }                   
                } 
                else {                   
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }    
    }
    
    public static void updateAccounts(list<User> userNewList, map<Id,User> usersOldMap) {
        map<id,string> userIdMap = new map<id,string>();
        list<Account> accountList = new list<Account>();
        for(User u : userNewList) {
            if(u.Region__c != usersOldMap.get(u.Id).Region__c) {
                userIdMap.put(u.Id,u.Region__c);
            }
        }
        if(!userIdMap.isEmpty()) {
            for(Account acc : [SELECT Id,RFO_Region__c,OwnerId FROM Account WHERE OwnerId IN : userIdMap.keySet()]) {
                if(userIdMap.containsKey(acc.OwnerId)) {
                    acc.RFO_Region__c = userIdMap.get(acc.OwnerId);
                    accountList.add(acc);
                }
            }
            if(!accountList.isEmpty()) {
                update accountList;
            }
        }
    }
}