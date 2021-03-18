@isTest 
public class IdeaTriggerHandler_Test {
    @isTest static void createIdeaTestData(){
        User u = [Select Id from User WHERE Id =:UserInfo.getUserID()];
        System.runAs(u){
            User user1 = createuser1();
            User user2 = createuser2();
            User user3 = createuser3();
            User user4 = createuser4();
            User user5 = createuser5();
            User user6 = createuser6();
            User user7 = createuser7();
            User user8 = createuser8();
            
            Test.startTest();
            Idea__c i = new Idea__c();
            i.Idea_Type__c = 'Tank';
            i.Idea_Stage__c = 'Ideation';   
            i.Idea_Description__c = 'This idea is for testing only';
            i.Project_Leader__c = user1.id;
            i.Commercial_Member__c = user2.id;
            i.Technology_Member__c = user3.id;
            i.Marketing_Member__c = user4.id;
            i.Engineering_Member__c = user5.id;
            i.Legal_Member__c = user6.id;
            i.Product_Member__c = user7.id;
            i.Project_Engineer__c = user8.id;  
            insert i ;
            Test.stopTest();
            
            List<Idea__Share> ideaRecord = [SELECT Id, userorgroupid FROM Idea__Share];
            System.assertEquals(9,ideaRecord.size());
            i.Project_Engineer__c = null;
            update i;
            List<Idea__Share> ideaRecordUpdated = [SELECT Id, userorgroupid FROM Idea__Share];
            System.assertEquals(8,ideaRecordUpdated.size());
            
        }
    }
    
    
    
    private static User createUser1() {
        Profile profileId = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        Profile profileId1 = [Select Id, Name from Profile where Name =: 'Sales Customer' limit 1];
        UserRole roleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        UserRole salesReproleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        User usr = new User();
        usr.LastName = 'LIVESON';
        usr.FirstName='AMY';
        usr.Alias = 'aliv';
        usr.Email = 'amy.liveson@example.com';
        usr.Username = 'amy.liveson@example.com';
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US';
        usr.UserRoleId = roleId.id;
        database.insert(usr,false);
        return usr;
    }    
    
    private static User createUser2() {
        Profile profileId = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        Profile profileId1 = [Select Id, Name from Profile where Name =: 'Sales Customer' limit 1];
        UserRole roleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        UserRole salesReproleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        User usr = new User();
        usr.LastName = 'JACKSON';
        usr.FirstName='MICHELLE';
        usr.Alias = 'mjac';
        usr.Email = 'jackson.michelle@example.com';
        usr.Username = 'jackson.michelle@example.com';
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US';
        usr.UserRoleId = roleId.id;
        database.insert(usr,false);
        return usr;
    }    
    
    
    private static User createUser3() {
        Profile profileId = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        Profile profileId1 = [Select Id, Name from Profile where Name =: 'Sales Customer' limit 1];
        UserRole roleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        UserRole salesReproleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        User usr = new User();
        usr.LastName = 'RODREGIUEZ';
        usr.FirstName='JAMES';
        usr.Alias = 'jrod';
        usr.Email = 'james.rodreguez@example.com';
        usr.Username = 'james.rodreguez@example.com';
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US';
        usr.UserRoleId = roleId.id;
        database.insert(usr,false);
        return usr;
    }    
    
    private static User createUser4() {
        Profile profileId = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        Profile profileId1 = [Select Id, Name from Profile where Name =: 'Sales Customer' limit 1];
        UserRole roleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        UserRole salesReproleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        User usr = new User();
        usr.LastName = 'THOMAS';
        usr.FirstName='JONA';
        usr.Alias = 'jtho';
        usr.Email = 'jona.thomas@example.com';
        usr.Username = 'jona.thomas@example.com';
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US';
        usr.UserRoleId = roleId.id;
        database.insert(usr,false);
        return usr;
    }    
    
    
    private static User createUser5() {
        Profile profileId = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        Profile profileId1 = [Select Id, Name from Profile where Name =: 'Sales Customer' limit 1];
        UserRole roleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        UserRole salesReproleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        User usr = new User();
        usr.LastName = 'ZUCKERBURG';
        usr.FirstName='ALEXA';
        usr.Alias = 'azuc';
        usr.Email = 'alexa.zuckerburg@example.com';
        usr.Username = 'alexa.zuckerburg@example.com';
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US';
        usr.UserRoleId = roleId.id;
        database.insert(usr,false);
        return usr;
    }    
    
    
    private static User createUser6() {
        Profile profileId = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        Profile profileId1 = [Select Id, Name from Profile where Name =: 'Sales Customer' limit 1];
        UserRole roleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        UserRole salesReproleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        User usr = new User();
        usr.LastName = 'THOMPSON';
        usr.FirstName='TERRY';
        usr.Alias = 'jsiv';
        usr.Email = 'terry.thompson@example.com';
        usr.Username = 'terry.thompson@example.com';
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US';
        usr.UserRoleId = roleId.id;
        database.insert(usr,false);
        return usr;
    }    
    
    private static User createUser7() {
        Profile profileId = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        Profile profileId1 = [Select Id, Name from Profile where Name =: 'Sales Customer' limit 1];
        UserRole roleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        UserRole salesReproleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        User usr = new User();
        usr.LastName = 'ANDERSON';
        usr.FirstName='RYAN';
        usr.Alias = 'rand';
        usr.Email = 'ryan.anderson@example.com';
        usr.Username = 'ryan.anderson@example.com';
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US';
        usr.UserRoleId = roleId.id;
        database.insert(usr,false);
        return usr;
    }    
    
    
    private static User createUser8() {
        Profile profileId = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        Profile profileId1 = [Select Id, Name from Profile where Name =: 'Sales Customer' limit 1];
        UserRole roleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        UserRole salesReproleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        User usr = new User();
        usr.LastName = 'CAMERON';
        usr.FirstName='DANNY';
        usr.Alias = 'dcam';
        usr.Email = 'danny.cameron@example.com';
        usr.Username = 'dann.cameron@example.com';
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US';
        usr.UserRoleId = roleId.id;
        database.insert(usr,false);
        return usr;
    }    
    
    
    
}