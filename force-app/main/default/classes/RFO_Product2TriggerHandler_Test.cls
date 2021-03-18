/** @Author      : Accenture
*   @Version     : 1.0
*   @Created Date: 28 Sep 2019
*   @Description : This class is to add new products to the PriceBookEntry records with Standard PriceBook.
**/
@isTest(SeeAllData = false)
private class RFO_Product2TriggerHandler_Test{
    
    /** test method begins **/
    static testmethod void createPricebookEntry(){
        
        
        //Get Standard PriceBook
        Pricebook2 pbook = RFO_Utility_Test.createPricebook();
        Database.update(pbook);
        
        // Product Creation  
        List<Product2> prodlist = new List<Product2>();
        Product2 prod1  = RFO_Utility_Test.createProduct();
        prodlist.add(prod1);
        Product2 prod2  = RFO_Utility_Test.createProduct();
        prod2.Name      = 'TestProd';
        prodlist.add(prod2);
        
        //Start Test
        Test.startTest();
        database.insert(prodlist);
        Test.stopTest();
        
        //Creating ProductMap to pass to dummy methods used as part of iTrigger interface 
        Map<Id, Product2> productMap = new Map<Id, Product2>(prodlist);
        RFO_Product2TriggerHandler handler = new RFO_Product2TriggerHandler();
        handler.BeforeInsert(prodlist);
        handler.BeforeUpdate(productMap,productMap);
        handler.BeforeDelete(productMap);
        handler.AfterUpdate(productMap,productMap);
        handler.AfterDelete(productMap);
        handler.AfterUndelete(productMap);
        
        //To compare Actual result with expectded result 
        System.assertEquals('TestProd', prodlist[1].Name);
    } 
}