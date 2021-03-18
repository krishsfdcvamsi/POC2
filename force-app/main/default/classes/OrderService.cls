/* Class Name : OrderService
 * Description : Service Class for Order Object
 * Created By : Vihari Vanga
 * Created On : 9/23/20
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 9/23/20                    Vihari Vanga                       ALPHA - 738




 * 10/02/20                   Ashish Reddy                       Alpha-166  - Added new method getOrdersByOrderIds




 */
public with sharing class OrderService {
  
 
 /* Method to Query Order Record
  * @param ordId - Id of the order record
  * @param fieldAPINames - List of api names of the field to be queried
  * 
  * @retunrs Order - order record queried
  */
 public static Order getOrder(Id ordId, List<String> fieldAPINames){
        String commaSepratedFields = '';
        if(fieldAPINames!=null){
            for(string fld:fieldAPINames){
                if (String.isBlank(commaSepratedFields)){
                    commaSepratedFields = fld;
                }
                else{
                    commaSepratedFields = commaSepratedFields + ', ' + fld;
                }
            }
        }
            
        String queryString = 'Select ' + commaSepratedFields + ' FROM Order WHERE id=:ordId limit 1';
        System.debug('##'+queryString);
        return Database.query(queryString);
    }





 /* Method to Query Order Records Map
  * @param orderIds - Set<Id> of the order records 
  * 
  * @retunrs Map<Id, Order> 
  */   
 public static Map<Id, Order> getOrdersByOrderIds(Set<Id> orderIds){
    Map<Id, Order> ordersByOrderIdsMap =  new Map<ID, Order>( [select id,status, Type, RecordType.Name, RecordType.DeveloperName, RFO_Product__c, RFO_Quantity__c   from Order where Id in: orderIds]);
    return ordersByOrderIdsMap;
 }









}