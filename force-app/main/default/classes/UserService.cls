/* Class Name : UserService
 * Description : Service Class for all User Object
 * Created By : Vihari Vanga
 * Created On : 10/26/20
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/26/20                    Vihari Vanga                       ALPHA - 771
 * 11/29/20                    Vihari Vanga                       ALPHA - 1693
 */
public with sharing class UserService {
    
    /* Method to query users using user id's
	 * @param userIds - List of user id's to be queried
	 * @return List<User> - returns all user records with id's in the list passed
	 * */
	public static List<User> getUsers(List<String> userIds){
        List<User> uList =  new List<User>();
        uList = [Select id, username, email from User where ID IN :userIds and isActive=true];
        return uList;
	}
    
    /* Added by vihari ALPHA - 1693*/
    /* Method to query users using user id's 
	 * @param userIds - List of user id's to be queried
	 * @return Map<Id,User> - returns all user records with id's as key and value as User Record
	 * */
	public static Map<Id,User> getUserMap(List<String> userIds){
        Map<Id, User> uMap =  new Map<Id,User>([Select id, username, email from User where ID IN :userIds and isActive=true]);
        return uMap;
	}
}