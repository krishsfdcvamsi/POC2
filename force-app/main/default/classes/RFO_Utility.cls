/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 23 July 2019
* @Description :This utility class is used for common methods.
* 
* Modification Log:
*------------------------------------------------------------------------------------------------------------------
* Date                       Developer                          Description
*------------------------------------------------------------------------------------------------------------------
* 10/6/20                    Vihari Vanga                       ENV - 18
*/
public class RFO_Utility {

    //Method to create Error Log records - used in triggers 
    @future
    public static void createErrorLogRecordFuture(String errorMessage, String ObjectName, 
        String Source, String className, String methodName){
        RFO_ErrorLog__c errorLogObj = new RFO_ErrorLog__c();
        errorLogObj.RFO_Source__c = Source;
        errorLogObj.RFO_Object__c = ObjectName;
        errorLogObj.RFO_ErrorMessage__c = errorMessage;
        errorLogObj.RFO_ClassName__c = className;
        errorLogObj.RFO_MethodName__c = methodName;
        insert errorLogObj;        
    }
    //used in batch class - @future mehtod can not called from batch class
    public static void createErrorLogRecord(String errorMessage, String ObjectName, 
        String Source, String className, String methodName){
        RFO_ErrorLog__c errorLogObj = new RFO_ErrorLog__c();
        errorLogObj.RFO_Source__c = Source;
        errorLogObj.RFO_Object__c = ObjectName;
        errorLogObj.RFO_ErrorMessage__c = errorMessage;
        errorLogObj.RFO_ClassName__c = className;
        errorLogObj.RFO_MethodName__c = methodName;
        insert errorLogObj;        
    }
    
    /* Added by Vihari ENV-18 */
    /* Method to check if the current org is a sandbox or not
     * @retunrs boolean - true if it's a sandbox and false if it's not
     */
    public static Boolean runningInASandbox(){
        return [Select IsSandbox from organization LIMIT 1].IsSandbox;
    }
    /* End Vihari ENV-18 */

}