/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 10th Sep 2018
* @Description :Test class of RFO_OrderHandlerBatchJob controller 
**/ 

@isTest()
Public Class RFO_ProductQuantityCalcBatchJobTest{
    
    /**
*   Test method with test data to pass batch class
**/
    private static testmethod void prdQuantityCalc() 
    {
        List<Product2> lstPrd = new List<Product2>();
        List<Asset> lstAsset = new List<Asset>();
        Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        
        Account accnt = new Account(
            Name = 'BNSF',  // Account Name
            RecordTypeId = RecordTypeIdCustomer,           // Account Record Type
            Phone = '800-832-5452',          // Phone
            RFO_Region__c = 'Class 1 Railroads',   // Region
            RFO_AccountStatus__c = 'Active'         // Account Status
           
        );
        insert accnt;
        
        //insert Contact record
        Contact contactRec = new Contact(
            FirstName = 'Faluni',         // FirstName
            LastName = 'Blazen',            // LastName
            RFO_Status__c = 'Active',                                               // Status
            Email = 'Faluni.Blazen@trin.net',                                  // Email
            AccountId = accnt.id,                                          // Account Name
            Phone = '(806) 301-0261',                                               // Phone
            RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
            Fax = '(806) 391-7528'                                                 // Fax
        );
        insert contactRec;
        
        
        for(Integer i=0; i<100; i++)
        {
            Product2 prd = new Product2();
            prd.Name ='LPL'+i;
            lstPrd.add(prd);
        }
        insert lstPrd;
        
        List<Product2> prdListToUpdate = [select id, RFO_Qty__c from Product2 where id IN: lstPrd];
        update prdListToUpdate;
        Asset assetRec = new Asset(
            Name = 'TILX521182',                             // Asset Name
            Product2Id = prdListToUpdate[0].id,                    // Product
            AccountId = accnt.Id,                   // Account
            ContactId = contactRec.Id
        );
        insert assetRec;
        
        Test.startTest();
        RFO_ProductQuantityCalcBatchJob productBatch = new RFO_ProductQuantityCalcBatchJob();
        DataBase.executeBatch(productBatch); 
        
    }
}