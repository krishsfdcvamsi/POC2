/**
* @Author      : Accenture  
* @Version     : 1.0
* @Created Date: 1 April 2019
* @Description :This class contains future methods to make a call to mule api.
**/
global class RFO_SendToTASFutureClass {
/**
 * future method called from trigger to update Global Account Id on Account
 **/
    @future(callout=true)
    public static void getGlobalAccountId(String accID)
    {   
        System.debug('accID'+accID);
        try {
            RFO_GlobalCallOut.getRFOGlobalAccountId(accID);            
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
/**
 * Future method called from Trigger to send Asset file or File Split info to TAS and to update the File Number in Salesforce
 **/
    @future(callout=true)
    public static void getAssetFileNumber(String jsonBody, String assetFileId, String FileType, String RecordStatus, String messageId)
    {
        String response;
        try {
            RFO_GlobalCallOut.getAssetFileNumber(jsonBody, assetFileId, FileType, RecordStatus, messageId);            
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
        //return response;
    }
/**
 * Future method called from Apex class to send Rider info to TAS
 **/
    @future(callout=true)
    public static void getRider(String RiderID, String JsonBody, String messageId, String TASRiderId)
    {
        String response;
        try {
            RFO_GlobalCallOut.getRiderId(RiderID, JsonBody, messageId, TASRiderId);            
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
/**
 * Future Method to send Account or Account Team Member to TAS
 **/
    @future(callout=true)
    public static void sendAccountInfoToTASfuture(String accId, String JsonBody, String messageId, String SourceCall, String SuccessMessage, String aTeamId){
        try {
            RFO_GlobalCallOut.sendAccountInfoToTAS(accID, JsonBody, messageId, SourceCall, SuccessMessage, aTeamId);            
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
        
}