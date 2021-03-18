@isTest
public class RF1_AccountsNoSurveyContactCtrlTest {
	@isTest
    private static void TestMethod1(){
        Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
		Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'feedC', Email='feedbackuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='FeedCase', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='feedbackuser@testorg.com');
    	insert u;
        
        
        Account ac = new Account();
        ac.Name = 'Test Account 12321';
        ac.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
		ac.Phone = '800-832-5452';          // Phone
		ac.RFO_Region__c = 'Class 1 Railroads';   // Region
		ac.RFO_AccountStatus__c = 'Active';
        ac.Type='Customer';
		//ac.OwnerId = u.id;
		insert ac;
        
        AccountTeamMember team = new AccountTeamMember(AccountId =ac.id,TeamMemberRole = 'Customer Delivery Manager',userId =u.id);
    	Contact con = new Contact (LastName = 'TestCon',FirstName = 'RF',AccountId = ac.id,email = 'test@t.com');
    	insert con;
    	insert team;
        
        Decimal pageNumber=1.0;
        Integer recordToDisplay=10;
         String surveyType = 'Survey Contact';
    	RF1_AccountsNoSurveyContactCtrl.AccountPagerWrapper accWr= RF1_AccountsNoSurveyContactCtrl.fetchAccount(pageNumber, recordToDisplay,surveyType);
        for(Account acct : accWr.accounts){
            system.debug(acct.Name);
        }
        
    }
}