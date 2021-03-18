/************************************************************************************************************************************************** 
 * Class Name : SRMobileSearchController
 * Description : As a customer user I want to select address and contact from drop down in Mobile Service Request Page.
 * 	 			 add new address and new contact from CDP.
 * Author : Sai Anudeep
 * Created On : 03/02/2021
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 03/04/21                    Sai Anudeep                       EPSI - 679 MRU SR Auto fill.	
      
 **************************************************************************************************************************************************/

public class SRMobileSearchController {
    
    @AuraEnabled
    public static User getCurrentUser(){
        return [SELECT Id,ContactId,Contact.AccountId FROM User WHERE /*ContactId = '003q000001BHrnHAAT'*/ Id =: UserInfo.getUserId()];
    }
}