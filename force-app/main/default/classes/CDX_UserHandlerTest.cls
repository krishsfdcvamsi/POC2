@isTest
public class CDX_UserHandlerTest {
    
    public static testmethod List<User> GenerateUsers(){
        List<user> uu = new List<user>();
        
        UserRole urole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ].Id;
        adminUser.UserRoleId = [SELECT Id,name FROM UserRole where PortalType != 'CustomerPortal' LIMIT 1].Id;
        insert adminUser;
        
        System.runAs(adminUser) {
            Account acc = new Account();
            acc.Name = 'testaccount';
            insert acc;
            System.debug('acc'+acc);
            //id id1 = userinfo.getProfileId();
            
            List<contact> conToInsert = new List<contact>();
            for(Integer i=0; i<4 ; i++){
                contact con = new contact();
                con.AccountId= acc.Id;
                con.LastName = 'Testlast';
                con.FirstName = 'Testlast1';
                conToInsert.add(con);
            }
            insert conToInsert; 
            System.debug('conToInsert'+conToInsert);
            // profile p = [Select id, name from profile where id =:id1];
            
            profile p =[Select id, name from profile where name = 'CDX Customer'];
            
            // p.Name='CDX Customer';
            // insert p;
            
            User u = new User();     
            //u.AccountId=acc.id;
            u.ContactId = conToInsert[0].id;
            u.Alias = 'arvv1234';
            u.Email='arvqq@testorg.com';
            u.EmailEncodingKey='UTF-8';
            u.LastName='Testing';
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey='en_US'; 
            u.ProfileId = p.Id;
            u.TimeZoneSidKey='America/Los_Angeles';
            u.UserName='arv12304@gmail.com';
            //u.Lan_Id__c='arvqq-LAN';
            //u.UserRoleId=[SELECT Id FROM UserRole WHERE Name = 'Trinity Super User' LIMIT 1].Id;
            insert u;
        }
        return uu;
    }
    public static testmethod void CreateUser(){
         List<user> uu = new List<user>();
        
        UserRole urole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ].Id;
        adminUser.UserRoleId = [SELECT Id,name FROM UserRole where PortalType != 'CustomerPortal' LIMIT 1].Id;
        insert adminUser;
        
        System.runAs(adminUser) {
            Account acc = new Account();
            acc.Name = 'testaccount';
            insert acc;
            System.debug('acc'+acc);
            //id id1 = userinfo.getProfileId();
            
            List<contact> conToInsert = new List<contact>();
            for(Integer i=0; i<4 ; i++){
                contact con = new contact();
                con.AccountId= acc.Id;
                con.LastName = 'Testlast';
                con.FirstName = 'Testlast1';
                conToInsert.add(con);
            }
            insert conToInsert; 
            System.debug('conToInsert'+conToInsert);
            // profile p = [Select id, name from profile where id =:id1];
            
            profile p =[Select id, name from profile where name = 'CDX Customer'];
            
            // p.Name='CDX Customer';
            // insert p;
            
            User u = new User();     
            //u.AccountId=acc.id;
            u.ContactId = conToInsert[0].id;
            u.Alias = 'arvv1234';
            u.Email='arvqq@testorg.com';
            u.EmailEncodingKey='UTF-8';
            u.LastName='Testing';
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey='en_US'; 
            u.ProfileId = p.Id;
            u.TimeZoneSidKey='America/Los_Angeles';
            u.UserName='arv12304@gmail.com';
            //u.Lan_Id__c='arvqq-LAN';
            //u.UserRoleId=[SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1].Id;
            insert u;
        }   
    }
    
    public static testmethod void UpdateUser(){
         UserRole urole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ].Id;
        adminUser.UserRoleId = [SELECT Id,name FROM UserRole where PortalType != 'CustomerPortal' LIMIT 1].Id;
        insert adminUser;
        User u = new User();
        System.runAs(adminUser) {
            Account acc = new Account();
            acc.Name = 'testaccount';
            insert acc;
            System.debug('acc'+acc);
            //id id1 = userinfo.getProfileId();
            
            List<contact> conToInsert = new List<contact>();
            for(Integer i=0; i<4 ; i++){
                contact con = new contact();
                con.AccountId= acc.Id;
                con.LastName = 'Testlast';
                con.FirstName = 'Testlast1';
                conToInsert.add(con);
            }
            insert conToInsert; 
            System.debug('conToInsert'+conToInsert);
            // profile p = [Select id, name from profile where id =:id1];
            
            profile p =[Select id, name from profile where name = 'CDX Customer'];
            
            // p.Name='CDX Customer';
            // insert p;
            
                 
            //u.AccountId=acc.id;
            u.ContactId = conToInsert[0].id;
            u.Alias = 'arvv1234';
            u.Email='arvqq@testorg.com';
            u.EmailEncodingKey='UTF-8';
            u.LastName='Testing';
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey='en_US'; 
            u.ProfileId = p.Id;
            u.Region__c = 'Midwest';
            u.TimeZoneSidKey='America/Los_Angeles';
            u.UserName='arv12304@gmail.com';
            //u.Lan_Id__c='arvqq-LAN';
            //u.UserRoleId=[SELECT Id,name FROM UserRole where PortalType != 'CustomerPortal' LIMIT 1].Id;
            insert u;
        }   
        u.LastName = 'Tester';
        u.Region__c = 'Sales Ops';
        update u;
    }
    
}