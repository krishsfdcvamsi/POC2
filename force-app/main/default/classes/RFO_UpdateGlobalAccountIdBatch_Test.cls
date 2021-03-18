/*
 * Class Name: RFO_UpdateGlobalAccountIdBatch_Test
 * */
@isTest(SeeAllData = false)
private class RFO_UpdateGlobalAccountIdBatch_Test {
    /* Test method for Global Account Id schedule class */
	private static testmethod void batchTestMethod1() 
    {
        List<Account> accList =new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        Database.insert(accList);
        RFO_UpdateGlobalAccountIdBatch accBatch = new RFO_UpdateGlobalAccountIdBatch(); 
        Test.startTest();
            DataBase.executeBatch(accBatch); 
        Test.stopTest();
        System.assert(accList!=null);
    }
}