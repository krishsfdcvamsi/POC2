/* 
Author Name   : I. Martinez
Created Date  : June 27, 2019
Description   : Utility class used to create/update records in the Integration Log and requests objects
                It returns a map of the record Id and unique message Id

History
*
* 27JUN2019 | I Martinez | US:38.03.09 | Initial version used to sync Contract records with TAS
* 04AUG2019 | I Martinez | US:38.03.09 | Change to update the restMethod if available in the payload (assumes a list)
*/
public with sharing class RFO_IntegrationUtility {
/*
* Method Name: createLogDetail
* Description: 
*/
    public static Map<Id, Integer> createLogDetail(Map<Id, Object> payloads
                                                , string objectName
                                                , string requestType
                                                , string URI
                                                , string method
                                                , string apexClass) {

        List<RFO_IntegrationLog__c> integrationLogList = new List<RFO_IntegrationLog__c>();
        Map<String, Object> payload = new Map<String, Object>();
        
        //Setup the Integration Log records needed from the payloads
        //Expects that the source record Id is used as the Map key in the payloads map
        RFO_IntegrationLog__c ilogRec = new RFO_IntegrationLog__c();
        for (Id ksId : payloads.keySet()) {
            payload = (Map<String, Object>) JSON.deserializeUntyped(JSON.Serialize(payloads.get(ksId)));
            method = payload.containsKey(RFO_Constant.PAYLOAD_PARAM_KEY_RESTMETHOD) 
                        ? (String)payload.get(RFO_Constant.PAYLOAD_PARAM_KEY_RESTMETHOD) : method;
            ilogRec = new RFO_IntegrationLog__c(
                RFO_IntegrationId__c = ksId + RFO_Constant.TILDE_SYMBOL+ method,  //record uniqueness
                RFO_Object__c = objectName,
                RFO_RecordID__c = ksId,
                RFO_RequestType__c = requestType,
                RFO_URI__c = URI,
                RFO_Method__c = method,
                RFO_Body__c = JSON.Serialize(payloads.get(ksId)),
                RFO_ApexClass__c = apexClass
            );
            integrationLogList.Add(ilogRec);
        }

        //Upsert the Integration Log records using the IntegrationId external field
        Schema.SObjectField externalId = RFO_IntegrationLog__c.Fields.RFO_IntegrationId__c;
        Database.UpsertResult[] ilResults = Database.upsert(integrationLogList, externalId, true);

        //Setup the Integration Request records needed from the payload and link them to the Integration Log (parent)
        List<RFO_IntegrationRequest__c> integrationReqstList = new List<RFO_IntegrationRequest__c>();
        RFO_IntegrationRequest__c irRec1 = new RFO_IntegrationRequest__c();
        RFO_IntegrationLog__c ilogReference = new RFO_IntegrationLog__c();
        for (Id ksId : payloads.keySet()) {

            //Initialize the Integration Request (child) record. Mainly used to keep track of the callout attempts
            //and generates a unique sequence number to be used as the Message Id required by MuleSoft
            irRec1 = new RFO_IntegrationRequest__c();

            //Virtual initialization of the parent record to obtain the parent reference (Id) needed to link the child
            //ilogReference = new RFO_IntegrationLog__c(RFO_IntegrationId__c = ksId + RFO_Constant.TILDE_SYMBOL + method);
			ilogReference = new RFO_IntegrationLog__c(RFO_IntegrationId__c = ksId + '~' + method);

            //Sets the reference to the parent record
            irRec1.RFO_IntegrationLog__r = ilogReference;
            
            integrationReqstList.Add(irRec1);
        }

        //Records in the Integration Requests objects are always inserted. Not intended for updates/upserts
        Database.SaveResult[] irResults = Database.insert(integrationReqstList, true);

        
        Set<Id> irIdSet = new  Set<Id>();
        // Iterate through each returned result
        for (Database.SaveResult sr : irResults) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                irIdSet.Add(sr.getId());
            }
        }
        
        //Prepare the map to return
        Map<Id, Integer> logDetails = new Map<Id, Integer>(); //SourceRecordId, MessageId (sequence number)
        for (RFO_IntegrationRequest__c irRec : [Select Id, Name, RFO_IntegrationLog__r.RFO_RecordID__c
                                                From RFO_IntegrationRequest__c
                                                Where Id in :irIdSet Limit  49999]) {
            logDetails.put(irRec.RFO_IntegrationLog__r.RFO_RecordID__c, integer.valueOf((irRec.Name).substring(4)));
        }
        
        return logDetails;
    }

    /*
    public static Map<Id, Object> addMessageId(Map<Id, Object> contractRequests, Map<Id, Object> requestsLogDetails) {
        for (Id crId : contractRequests.keySet()){
            //contractRequests.get(crId).put('messageId', requestsLogDetails.get(crId));
            System.debug('contractRequests.get(crId): '+contractRequests.get(crId));
        }
        System.debug('payload w/messageId: ' + contractRequests);

        return contractRequests;
    }
    */
/*
* Method Name: updateIntegrationLogStatus
* Description: 
*/
    public static void updateIntegrationLogStatus(Object statusCode
                                        , String integrationId
                                        , String payloadBody
                                        , String result){
        RFO_IntegrationLog__c ilRec = new RFO_IntegrationLog__c(RFO_StatusCode__c = string.valueof(statusCode)
                                                            , RFO_IntegrationId__c = integrationId
                                                            , RFO_Body__c = payloadBody
                                                            , RFO_Result__c = result);
        upsert ilRec RFO_IntegrationId__c;
    }

/** Returns a JSON format standard response */
    public static Map<String, Object> getResponseBody(HttpResponse response){
        Map<String, Object> returnResponseBody = new Map<String, Object>();

        //Set defaults
        String defaulStatus = response.getStatusCode() == 200 ? 
                                        RFO_Constant.INTGRN_RSPNS_STATUS_SUCCESS : 
                                        RFO_Constant.INTGRN_RSPNS_STATUS_FAILURE;
        String defaultMsg = response.getBody();

        //Try to deserialize response body
        try {
            Map<String, Object> responseBody1 = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if (responseBody1.containsKey(RFO_Constant.INTGRN_RSPNS_STATUS_KEY) == false) {
                responseBody1.put(RFO_Constant.INTGRN_RSPNS_STATUS_KEY, defaulStatus);
            }
            if (responseBody1.containsKey(RFO_Constant.INTGRN_RSPNS_MSG_KEY) == false) {
                responseBody1.put(RFO_Constant.INTGRN_RSPNS_MSG_KEY, defaultMsg);
            }
            returnResponseBody = responseBody1;
        }
        catch(Exception e) {
            //Response body is in JSON format build default one
            BasicResponseBody stdResponseBody = new BasicResponseBody();
            stdResponseBody.status = defaulStatus;
            stdResponseBody.message = defaultMsg;

            returnResponseBody = (Map<String, Object>) JSON.deserializeUntyped(JSON.Serialize(stdResponseBody));
        }
        return returnResponseBody;
    }

    public static void createIntegrationLogRecord(String objectName, String integrationId, String body, String URI, String result, 
    String statusCode, String methodType, String apexClass){
        RFO_IntegrationLog__c integrationLog = new RFO_IntegrationLog__c();
        System.debug('inserting into integration log---> '+ objectName);
        integrationLog.RFO_IntegrationId__c = integrationId + RFO_Constant.TILDE_SYMBOL+ methodType + Datetime.now().getTime();
        integrationLog.RFO_Object__c = objectName;
        integrationLog.RFO_Body__c = body;
        integrationLog.RFO_URI__c = URI;
        integrationLog.RFO_Result__c = result;
        integrationLog.RFO_StatusCode__c = statusCode;
        integrationLog.RFO_Method__c = methodType;
        integrationLog.RFO_ApexClass__c = apexClass;
        //upsert integrationLog RFO_IntegrationId__c;
        insert integrationLog;
        System.debug('inserted into integration log---> '+ objectName);

}

/** Compose the message (body) for a chatter post from an HTTPResponse object */
    // public static String getIntegrationChatterPostBody(HttpResponse response){
    //     String body;
    //     Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    //     body = 'Status Code: ' + response.getStatusCode() + ': ' + String.valueOf(results.get(RFO_Constant.MESSAGE));
    //     return body;
    // }
    /* BasicResponseBody */
    class BasicResponseBody{
        private String status;
        private String message;
    }

}