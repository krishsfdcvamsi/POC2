@isTest
public class lwcCustomLookupControllerTest {
    static testmethod void lookUpTestMethod(){
        TEST.startTest();
        List<Account> accList = new List<Account>();
		accList = CPQUTILITYTEST.createProspectAccounts();
        Database.insert(accList);
        lwcCustomLookupController.getResults('Account','Name','37 B');
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities(accList[0]);
        // oppList[0].StageName = 'Quoting';                    
        Database.insert(oppList);
        lwcCustomLookupController.getResultsWithParent('Opportunity','Name','AccountId',accList[0].Id,'Test ');
        TEST.stopTest();
    }
}