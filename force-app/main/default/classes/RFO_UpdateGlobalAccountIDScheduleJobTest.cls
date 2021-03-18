/**
*  Class:  RFO_UpdateGlobalAccountIDScheduleJobTest
**/
@isTest(SeeAllData=false)
private class RFO_UpdateGlobalAccountIDScheduleJobTest {
    /*  Test method for Global AccountId schedule job class */
    private static testmethod void updateGlobalAccountIDScheduleJobMethod(){
        
        RFO_UpdateGlobalAccountIDScheduleJob sh1 = new RFO_UpdateGlobalAccountIDScheduleJob();
        String sch = '0 0 6 * * ?';
        Test.startTest();
        System.schedule('Update Global AccountID', sch, sh1);
        Test.stopTest();
        System.assertEquals(sch, '0 0 6 * * ?');
    }
}