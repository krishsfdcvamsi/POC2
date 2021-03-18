@isTest
public class ProductOptionsListViewControllerTest {
	static testmethod void ProductOptionsTestMethod(){
        TEST.startTest();
        Product2 objProduct = CPQUTILITYTEST.createProduct();
        insert objProduct;
        	ProductOptionsListViewController.saveProductOption('Gasket','Lx2000',15,750,100,4,'Please increase the labor rate',objProduct.Id);
        ProductOptionsListViewController.saveProductOption('Gasket','Lx2000',15,750,100,4,'Please increase the labor rate','');
         TEST.stopTest();
	}
}