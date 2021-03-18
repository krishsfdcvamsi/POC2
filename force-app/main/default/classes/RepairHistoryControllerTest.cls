/************************************************************************************************************************************************** 
 * Class Name : Repair Histor Controller
 * Description : As a customer user I want to be able to see a list of “Repair History” report on the customer digital portal.
 * 				So that I can use that data to perform some analysis on my repair expenditures. 
 * Author : Sai Anudeep
 * Created On : 11/26/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/26/20                    Sai Anudeep                       BETA - 96 Added custom filters to pull the report.
      
 **************************************************************************************************************************************************/

@isTest
public class RepairHistoryControllerTest {
    
    @isTest
    public static void getRepairHistoryTest(){
        insert new AssetRepairHistory__c();

         Account account = new Account(Name = 'test');
        insert account;
        Test.startTest();
        RepairHistoryController.getAccounts();
        RepairHistoryController.getRiderNumbers(account.Id, '12');
        RepairHistoryController.getRiderNumbers(null, 'test');

        Test.stopTest();
    }
}