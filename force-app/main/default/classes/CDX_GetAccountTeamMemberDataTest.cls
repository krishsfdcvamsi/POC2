@isTest
public class CDX_GetAccountTeamMemberDataTest {
    
    static testMethod void myUnitTest() {
        
        Account acc = new Account();
        acc.Name = 'asd';
        insert acc;
        
        system.debug('Account'+acc );
        
        Test.startTest();
        CDX_GetAccountTeamMemberData.getAccountTeamMemberList(acc.Id);
        Test.stopTest();
        
    }
    
}