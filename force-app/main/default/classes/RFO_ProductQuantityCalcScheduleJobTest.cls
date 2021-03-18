/**
 * @Author      : Accenture
 * @Version     : 1.0
 * @Created Date: 11th Sep 2018
 * @Description : Test class of RFO_OrderHandlerScheduleJob schedule class.
 **/ 

@isTest()
Public Class RFO_ProductQuantityCalcScheduleJobTest{
    
    /**
     *   Test method with test data for schedule class
     **/
    private static testmethod void prdScheduleTestMethod() 
    {
        Test.startTest();
        RFO_ProductQuantityCalcScheduleJob prdQuntSch = new RFO_ProductQuantityCalcScheduleJob();
        String prdQuntSchStr = '0 0 4 * * ?'; 
        system.schedule('Test Order Records Processing', prdQuntSchStr, prdQuntSch); 
        Test.stopTest();
    }
}