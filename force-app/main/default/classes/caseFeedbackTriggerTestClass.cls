@isTest
private class caseFeedbackTriggerTestClass
{
  static testmethod void emailSend()
  {
    List<Case_Feedback__c> caseFeeds = new List<Case_Feedback__c>();
    Account acc = new Account(name = 'Test Acc');
    insert Acc;
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User u = new User(Alias = 'feedC', Email='feedbackuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='FeedCase', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='feedbackuser@testorg.com');
    insert u;
    AccountTeamMember team = new AccountTeamMember(AccountId =acc.id,TeamMemberRole = 'Customer Delivery Manager',userId =u.id);
    Contact con = new Contact (LastName = 'TestCon',FirstName = 'RF',AccountId = acc.id,email = 'test@t.com');
    insert con;
    insert team;
    Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_Case').getRecordTypeId();
        
    Case testCase = new Case(AccountId =acc.id,subject = 'Test Case',contactId = con.id, RecordTypeId=RecordTypeIdCase);
    insert testCase;
    Case_Feedback__c feedC = new Case_Feedback__c(name = 'TestFeed',Account__c =acc.id,Contact__c =con.id,Case_Number__c =testCase.id, Source__c='Case', Is_Resolved__c = 'Yes',Rating__c = 'Satisfied', C_Satisfaction_with_support_info_receive__c='Very satisfied', FS_Overall_Satisfaction_with_FSR_s_visit__c='Very satisfied');
    Case_Feedback__c feedC2 = new Case_Feedback__c(name = 'TestFeed',Customer_Email_feed__c = 'test@t.com',Customer__c = 'Test Account in Test',Source__c='Lease Order Survey', Is_Resolved__c = 'Yes',Rating__c = 'Satisfied',C_Satisfaction_with_support_info_receive__c='Very satisfied', FS_Overall_Satisfaction_with_FSR_s_visit__c='Very satisfied');
    Case_Feedback__c feedC3 = new Case_Feedback__c(name = 'TestFeed',Customer_Email_feed__c = 'test@t.com',Customer__c = 'Test Account in Test',Source__c='Compliance Project Survey', Is_Resolved__c = 'Yes',Rating__c = 'Satisfied',C_Satisfaction_with_support_info_receive__c='Very satisfied', FS_Overall_Satisfaction_with_FSR_s_visit__c='Very satisfied');  
    Case_Feedback__c feedC4 = new Case_Feedback__c(name = 'TestFeed',Account__c =acc.id,Contact__c =con.id,Case_Number__c =testCase.id, Source__c='Field Service Survey', Is_Resolved__c = 'Yes',Rating__c = 'Satisfied', C_Satisfaction_with_support_info_receive__c='Very satisfied', FS_Overall_Satisfaction_with_FSR_s_visit__c='Very satisfied');
    caseFeeds.add(feedC);
    caseFeeds.add(feedC2);
    caseFeeds.add(feedC3);  
    caseFeeds.add(feedC4);  
      insert caseFeeds;

  }
}