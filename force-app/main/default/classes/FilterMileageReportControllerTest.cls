/************************************************************************************************************************************************** 
 * Class Name : Filter Mileage Data Report Test
 * Description : As a customer user I want to be able to view “Fleet Mileage Details” for all of my assets.
 * 				 so that I can use the report for analysis and review of mileages that were used during the course of a specific duration. 
 * Author : Sai Anudeep
 * Created On : 11/21/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/21/20                    Sai Anudeep                       BETA - 95 Added custom filters to pull the report.
      
 **************************************************************************************************************************************************/

@isTest
public class FilterMileageReportControllerTest {
    
    @isTest
    public static void getFleetMileagesTest(){
        Account account = new Account(Name = 'test');
        insert account;
        
        Fleet_Mileage_Data__c fmd = new Fleet_Mileage_Data__c(Account__c = account.Id);
        insert fmd;
        
        Test.startTest();
        FilterMileageReportController.getAccounts();
        FilterMileageReportController.getRiderNumbers(account.Id, 'test');
        FilterMileageReportController.getRiderNumbers(null, 'test');
        Test.stopTest();
    }
}