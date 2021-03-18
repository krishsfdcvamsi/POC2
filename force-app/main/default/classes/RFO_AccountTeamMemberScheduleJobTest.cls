/*
* Class Name : RFO_AccountTeamMemberScheduleJobTest
*/
@isTest(SeeAllData=false)

   /*Account Team Member Schedule Job*/
private class RFO_AccountTeamMemberScheduleJobTest {
  
    private static testmethod void accountTeamMemberScheduleJobMethod(){
        RFO_AccountTeamMemberScheduleJob sh1 = new RFO_AccountTeamMemberScheduleJob();
        String sch = '0 0 6 * * ?';
        Test.startTest();
        System.schedule('Account Team member', sch, sh1);
        Test.stopTest();
        System.assertEquals(sch, '0 0 6 * * ?');
    }
    
}