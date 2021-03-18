/************************************************************************************************************************************************** 
 * Class Name : Asset Files Controller Test
 * Description : Related Asset files with additional fields 
 * Author : Sai Anudeep
 * Created On : 11/17/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/17/20                    Sai Anudeep                       BETA - 193, Related Asset files with additional fields .
      
 **************************************************************************************************************************************************/

@isTest
public class AssetFilesControllerTest {
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
        Order order = new Order(AccountId = account.Id,EffectiveDate = System.today(),Status='Draft',Pricebook2Id = pricebookId);

        insert order;
        insert new Asset(Name='Test',AccountId = account.Id,RFO_FileOrder__c= order.Id);
        Test.startTest();
        AssetFilesController.getAssets(order.Id);
        AssetFilesController.getOrder(order.Id);
        AssetFilesController.getAssetFilesByOrderId(order.Id);
        Test.stopTest();
    }
}