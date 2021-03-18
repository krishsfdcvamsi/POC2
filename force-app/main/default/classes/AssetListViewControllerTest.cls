@isTest
public class AssetListViewControllerTest {
   public static Id pricebookId = Test.getStandardPricebookId();
    @testSetup
    public static void testSetup(){
        Product2 prod = new Product2(Name = 'Test Prod2', 
                                     Family = 'Hardware');
        insert prod;
        
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        insert new Pricebook2(Name='Standard Price Book', isActive=true);
    }
    
    @isTest
    public static void getAssets(){
        
        Account account = new Account(Name = 'test');
        insert account;
        Order order = new Order(AccountId = account.Id,EffectiveDate = System.today(),Status='Draft',Pricebook2Id = pricebookId,RFO_RANumber__c = '432432432');

        insert order;
        insert new Asset(Name='Test',AccountId = account.Id,RFO_FileOrder__c= order.Id,RFO_RANumber__c = 432432432);
        AssetListViewController.getAssetList(order.Id);
        AssetListViewController.getOrder(order.Id);
    }
}