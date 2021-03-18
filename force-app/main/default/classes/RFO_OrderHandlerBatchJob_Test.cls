/**
 *   Test class of RFO_OrderHandlerBatchJob controller
 **/
@isTest()
Public Class RFO_OrderHandlerBatchJob_Test{
    
    /**
     *   Test method with test data to pass batch class
     **/
    private static testmethod void batchTestMethod1() 
    {
        List<Order> lstOrd = new List<Order>();
        
        Account acc1 = new Account();
        acc1.Name = 'Shell';
        acc1.RFO_AccountRecordType__c = 'Customer';
        acc1.RFO_Region__c = 'Eastern';
        acc1.Type = 'Customer';
        insert acc1;
        
        //insert asset record
        Asset ast = new Asset();
        ast.accountId = acc1.id;
        ast.name = 'testAsset';
        ast.RFO_File__c = '12345';
        insert ast;
        
        for(Integer i=0; i<200; i++)
        {
            Order ord = new Order();
            ord.Name ='Name'+i;
            ord.accountID = acc1.id;
            ord.RFO_File__c = '1234'+i;
            ord.EffectiveDate = Date.today();
            ord.Status='Draft';
            lstOrd.add(ord );
        }
        insert lstOrd;
        
        Test.startTest();
            
            RFO_OrderHandlerBatchJob orderBatch = new RFO_OrderHandlerBatchJob();
            DataBase.executeBatch(orderBatch); 
            
        Test.stopTest();
    }
}