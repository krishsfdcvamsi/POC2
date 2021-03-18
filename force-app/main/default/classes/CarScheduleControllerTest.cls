/************************************************************************************************************************************************** 
 * Class Name : Car Schedule Controller
 * Description : New Car Schedule on Order 
 * Author : Sai Anudeep
 * Created On : 11/19/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/19/20                    Sai Anudeep                       BETA - 193, New Car Schedule on Order from Asset file
      
 **************************************************************************************************************************************************/

@isTest
public class CarScheduleControllerTest {
    
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
    public static void getAssetFilesTest(){
        
        Account account = new Account(Name = 'test');
        insert account;
        Order order = new Order(AccountId = account.Id,EffectiveDate = System.today(),Status='Draft',Pricebook2Id = pricebookId);

        insert order;
        insert new Asset(Name='Test',AccountId = account.Id,RFO_FileOrder__c= order.Id);
        insert new RFO_Asset_File__c(Name= 'test',RFO_OrderNumber__c=order.Id,RFO_Quantity__c=5,RFO_RiderLeaseType__c='Per Diem');
        Test.startTest();
        CarScheduleController.getAssetFiles(order.Id);
        Test.stopTest();
    }
}