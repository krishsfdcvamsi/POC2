/*
Author Name   : I. Martinez 
Created Date  : June 27, 2019
Description   : Class with methods to make Webservice callouts

History
*
* 27JUN2019 | I Martinez | US:38.03.09 | Initial version used to sync Contract records with TAS
* 20AUG2019 | I Martinez | D-0875 | Exception Handling: API Callout responses
* 20OCT2019 | I Martinez | Deploy | Added adjustable timeout per Trinity's request as some take long to process
									-Noted potential issue with concurrent long running process limit
*/
public class RFO_WebServiceCallout {
/* 
* Method Name: createContract
*/
    @future(callout=true)
    public static void createContract(Id recId, String endpoint, String restMethod, Integer messageId, String payload, String iLogExtId)
    {
        //************************************************************************************
        //**** URI: https://dev-api.trinityrail.com:8431/tst/v1/contract/api/contract
        //************************************************************************************

        RFO_EventNotification eventNotifications = new RFO_EventNotification();

        String notificationTitle = RFO_Constant.NOTIFICATION_TAS_SUCCESS;
        String notificationType = RFO_Constant.NOTIFICATION_TYPE_SUCCESS;
        String notificationMsg;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);

        //Standard Trinity URI headers
        request.setHeader(System.Label.RFO_Header1, messageId == null ? System.Label.RFO_1 : String.valueOf(messageId));
        request.setHeader(System.Label.RFO_Header2, System.Label.RFO_Railforce);
        request.setHeader(System.Label.RFO_Header3, RFO_Constant.LEASING);
        request.setHeader(System.Label.RFO_Header4, RFO_Constant.APPLICATION_JSON);
        request.setBody(payload);
        request.setMethod(restMethod);
		request.setTimeout(RFO_GlobalCallOut.setCalloutTime('Contract')); // Adjustable timeout

        Http http = new Http();

        try{
            HttpResponse response = http.send(request);

            Map<String, Object> responseBody = RFO_IntegrationUtility.getResponseBody(response);
            notificationMsg = String.valueOf(responseBody.get(RFO_Constant.MESSAGE));

            //Update the Integration Log with the API callout response
            RFO_IntegrationUtility.updateIntegrationLogStatus(response.getStatusCode(), iLogExtId, payload, response.getBody());

            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() == 200) {
                if (restMethod == RFO_Constant.POST_METHOD) {
                    if (responseBody.containsKey(RFO_Constant.CONTRACTID)) {
                        Contract contractRec = new Contract(Id = (Id)iLogExtId.left(18)
                                                        , RFO_ContractId__c = String.valueOf(responseBody.get(RFO_Constant.CONTRACTID))
                                                        , RFO_TasSyncStatus__c = RFO_Constant.SYNC_SUCCEEDED); 
                        Database.upsert(contractRec);
                    } else {
                        notificationType = RFO_Constant.NOTIFICATION_TYPE_ERROR;
                        notificationTitle = RFO_Constant.NOTIFICATION_TAS_FAILURE;
                    }
                    
                } else {
                    Contract contractRec = new Contract(Id = (Id)iLogExtId.left(18)
                                                        , RFO_TasSyncStatus__c = RFO_Constant.SYNC_SUCCEEDED);
                    Database.upsert(contractRec);
                }
                
            } else {
                notificationType = RFO_Constant.NOTIFICATION_TYPE_ERROR;
                notificationTitle = RFO_Constant.NOTIFICATION_TAS_FAILURE;
                Contract contractRec = new Contract(Id = (Id)iLogExtId.left(18)
                                                    , RFO_TasSyncStatus__c = RFO_Constant.SYNC_FAILED);
                Database.upsert(contractRec);
            }
        }catch(Exception e){
            notificationType = RFO_Constant.NOTIFICATION_TYPE_ERROR;
            notificationTitle = RFO_Constant.NOTIFICATION_TAS_FAILURE;
            notificationMsg = 'The following exception has occurred: ' + e.getMessage();
        }
        eventNotifications .type(notificationType) .title(notificationTitle) .message(notificationMsg) 
                           .sendToCurrentUser() .event('ContractSync') .recordId(recId) .addNotification() .publishNotificationEvent();
        RFO_GlobalCallOut.feedItemCreation(String.valueOf(recId), notificationTitle + '\n' + notificationMsg);
    }

}