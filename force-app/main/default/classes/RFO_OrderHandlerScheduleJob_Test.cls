/**
 *   Test class of RFO_OrderHandlerScheduleJob controller
 **/
@isTest()
Public Class RFO_OrderHandlerScheduleJob_Test{
    
    /**
     *   Test method with test data to pass schedule class
     **/
    private static testmethod void scheduleTestMethod1() 
    {
        Test.startTest();
        RFO_OrderHandlerScheduleJob sh1 = new RFO_OrderHandlerScheduleJob();
        String sch = '0 0 3 * * ?'; 
        system.schedule('Test Order Records Processing', sch, sh1); 
        Test.stopTest();
    }
}