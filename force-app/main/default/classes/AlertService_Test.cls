/************************************************************************************************************************************************** 
 * Class Name : AlertService_Test
 * Description : Test Class for TaskService
 * Author : Haseeb
 * Created On : 10/26/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/26/20                    Haseeb                       	ALPHA - 771, Test Alert Creation of createAlert Method.
 * 
 **************************************************************************************************************************************************/
@isTest
public class AlertService_Test {

    static testMethod void setup(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = : RFO_Constant.SALES_PROFILE LIMIT 1];
        List<User> usrList =  new List<User>();
        
        User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason.liveston@example.com',
                            Username = 'jason.liveston@example.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        usrList.add(usr);
        User usr2 = new User(LastName = 'LIVESON',
                             FirstName='JASO',
                             Alias = 'jsiv',
                             Email = 'jaso.liveson@example.com',
                             Username = 'jaso.liveson@example.com',
                             ProfileId = profileId.id,
                             TimeZoneSidKey = 'GMT',
                             LanguageLocaleKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             LocaleSidKey = 'en_US',
                             isActive = true,
                             RFO_Engineering__c = true
                            );
        usrList.add(usr2);
        Database.insert(usrList);
    }
    

	static testMethod void testCreateAlert(){
        
        Test.startTest();
        AlertService a = new AlertService();
        //a.createAlert(DeveloperName, calculationFromDate, ImmediateAlertList, Alert1List, Alert2List, relatedTo, notificationMergeTitle, notificationMergeBody)
        Alert__c a1 = a.createAlert('Change_Request_Engineering_Review', null, null, null, null, 'Test', null, null);
        Alert__c a2 = a.createAlert('Change_Request_Engineering_Review', system.today(), userInfo.getUserId(), 'test', 'test', 'test', 'test', 'test');
        system.assertEquals(False, a1 == null);
        system.assertEquals(False, a2 == null);
        Test.stopTest();
    }

    
    static testMethod void testGetImmediateAlertRecipients(){
        
        Test.startTest();
        AlertService a = new AlertService();
        User u = [select id from user Limit 1];
        String engReviewAlert = Label.Case_Engineering_Review_AlertSetting_Name;
        
        String immediateAlertList = a.getImmediateAlertRecipients(engReviewAlert,new List<String>{u.id});

        system.assertEquals(False, immediateAlertList == null);
        Test.stopTest();
    }
    
    static testMethod void testGetAlert1Recipients(){
        
        Test.startTest();
        AlertService a = new AlertService();
        User u = [select id from user Limit 1];
        String engReviewAlert = Label.Case_Engineering_Review_AlertSetting_Name;
        
        String alert1List = a.getAlert1Recipients(engReviewAlert,new List<String>{u.id});

        system.assertEquals(False, alert1List == null);
        Test.stopTest();
    }
    
    static testMethod void testGetAlert2Recipients(){
        
        Test.startTest();
        AlertService a = new AlertService();
        User u = [select id from user Limit 1];
        String engReviewAlert = Label.Case_Engineering_Review_AlertSetting_Name;
        
        String alert2List = a.getAlert2Recipients(engReviewAlert,new List<String>{u.id});

        system.assertEquals(False, alert2List == null);
        Test.stopTest();
    }

}