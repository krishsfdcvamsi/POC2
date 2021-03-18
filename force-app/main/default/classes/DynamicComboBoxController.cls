/************************************************************************************************************************************************** 
 * Class Name : DynamicComboBoxController
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
public class DynamicComboBoxController {
    
    public static Boolean matchAnyString = false;
    
    @AuraEnabled
    public static List<sObject> searchRecords(String searchText, String sObjectName, String fieldName, String additionalFields,  String whereClause, Boolean matchAny){
        matchAnyString = matchAny;
        return searchRecords(searchText, sObjectName, fieldName,additionalFields, whereClause);
    }
    
   // @AuraEnabled
    public static List<sObject> searchRecords(String searchText, String sObjectName, String fieldName, String additionalFields, String whereClause){
        
        try{
            String query = '';
            if(searchText != null && searchText != ''){
                query = 'SELECT Id,'+ fieldName + (additionalFields != null && additionalFields != '' ? ' ,'+additionalFields : '');
                query += ' FROM '+sObjectName+' WHERE '+fieldName+'!=null AND ';
                if(matchAnyString){
                    query += fieldName+' LIKE \'%'+searchText+'%\'';
                }
                else{query += fieldName+' LIKE \''+searchText+'%\'';}
            }
            else{
                query = 'SELECT Id,'+fieldName + (additionalFields != null && additionalFields != '' ? ' ,'+additionalFields : '');
                query += ' FROM '+sObjectName+' WHERE '+fieldName+'!=null ';
            }
            if(whereClause != null && whereClause != ''){
                if(query.contains('WHERE')){
                    query += ' AND '+whereClause;
                }
                else{
                    query += ' WHERE '+whereClause;
                }
            }
            query += ' LIMIT 5';
            System.debug(query+'  '+whereClause);
            List<sObject> searcResults = Database.query(query);
            System.debug(searcResults);
            return searcResults;
        }
        catch(Exception e){
            System.debug(e.getStackTraceString());
            throw new AuraException(e.getMessage());
        }
    }
}