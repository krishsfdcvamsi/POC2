/************************************************************************************************************************************************** 
 * Class Name : DynamicComboBoxControllerTest
 * Description : Dynamic combo box for field search. Can be reused.
 * Author : Sai Anudeep
 * Created On : 11/21/20
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/21/20                    Sai Anudeep                       BETA - 95 Added custom filters to pull the report.
 * 03/04/21                    Sai Anudeep                       EPSI - 679 MRU SR Auto fill.	
      
 **************************************************************************************************************************************************/

@isTest
public class DynamicComboBoxControllerTest {
    
    @isTest
    public static void searchRecordsTest(){
        Test.startTest();
        DynamicComboBoxController.searchRecords('test', 'Asset', 'Name','', 'Name!=null', true);
        DynamicComboBoxController.searchRecords('test', 'Asset', 'Name','', 'Name!=null', false);
        DynamicComboBoxController.searchRecords(null, 'Asset', 'Name', '', 'Name!=null', false);
        DynamicComboBoxController.searchRecords(null, 'Asset', 'Name','', null, false);
        try{
        DynamicComboBoxController.searchRecords(null, 'Asset', 'test', null,null, true);
        }
        catch(Exception e){
            
        }
        Test.stopTest();
    }
}