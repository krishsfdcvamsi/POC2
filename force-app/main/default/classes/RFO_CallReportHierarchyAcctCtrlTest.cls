@istest
private class RFO_CallReportHierarchyAcctCtrlTest {
    
    @testSetup
    private static void createTestData()
    {	
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        insert accList;
    }
    
	static testmethod void CallReportTest()
	{
    	Account a = [Select Id from account limit 1];
        RFO_CallReportHierarchyAcctCtrl.getCallReportsForHierachyAccounts(a.Id);
        system.debug('Test completed');
	}
}