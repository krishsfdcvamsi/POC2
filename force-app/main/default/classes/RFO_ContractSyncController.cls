/*
Author Name   : I. Martinez
Created Date  : June 27, 2019 
Description   : Controller class used by the RFO_ContractSync lightning component to sync the Contract record with TAS

History
*
* 27JUN2019 | I Martinez | US:38.03.09 | Initial version used to sync Contract records with TAS
* 15JUL2019 | I Martinez | FB:SIT-W2-IM-071519 | Added the Executed Date to the payload and used the Account.SalesRepStartDate
* 20AUG2019 | I Martinez | D-0875 | Exception Handling: check for API required fields
*/
public with sharing class RFO_ContractSyncController {
/*
* Method Name: syncContractToTAS 
*/

    /* syncContractToTAS: responsible for sending contract data to TAS */
    @AuraEnabled
    public static void syncContractToTAS (Id contractId){
        try{
            RFO_EventNotification eventNotifications = new RFO_EventNotification();
            String msg='';
            Map<Id, Contract> contractMap = new Map<Id, Contract>([Select Id, Name From Contract where Id = :contractId Limit 49999]);

            eventNotifications .type('info') .title('Update TAS') .message('Process started')
                            .sendToCurrentUser() .event('ContractSync') .recordId(contractId) 
                            .addNotification() .publishNotificationEvent();
            Map<Id, Object> contractRequests = generateContractPayload(contractMap.keySet());
            
            string restMethod = RFO_Constant.POST_METHOD;
            string endpoint = RFO_IntegrationLinks__c.getInstance(RFO_Constant.LABEL_URI_CONTRACT).RFO_APILink__c;

            Map<Id, Integer> requestsLogDetails = RFO_IntegrationUtility.createLogDetail(  contractRequests
                                                                                        , RFO_Constant.CONTRACT_OBJECT
                                                                                        , RFO_Constant.R_CREATE
                                                                                        , endpoint
                                                                                        , restMethod
                                                                                    , 'RFO_ContractSyncController.syncContractToTAS');
            
            for (Id ksId : contractRequests.keySet()) {
                if (((Map<String, Object>)contractRequests.get(ksId)).containsKey(RFO_Constant.CONTRACTID)) {
                    restMethod = RFO_Constant.PUT_METHOD;
                }
                RFO_WebServiceCallout.createContract(ksId, endpoint, restMethod, requestsLogDetails.get(ksId)
                                            , JSON.Serialize(contractRequests.get(ksId)), ksId+RFO_Constant.TILDE_SYMBOL+restMethod);
                msg = 'Request submitted for contract '
                    +String.valueOf(((Map<String, Object>)contractRequests.get(ksId)).get('transactionId')).leftPad(8,'0');
                eventNotifications .type('info') .title('Update TAS') .message(msg) .sendToCurrentUser() .event('ContractSync') 
                                .recordId(ksId) .addNotification() .publishNotificationEvent();
            }
            eventNotifications .type('info') .title('Update TAS') .message('Update request process ended. TAS response pending')
                                .sendToCurrentUser() .event('ContractSync') .recordId(contractId) 
                                .addNotification() .publishNotificationEvent();
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
/*
* Method Name: generateContractPayload
*/
    private static Map<Id, Object> generateContractPayload(Set<Id> ContractIds) {

        RFO_EventNotification eventNotifications = new RFO_EventNotification();

        Map<Id, Object> contractRequests = new Map<Id, Object>(); //Contract.Id, contractRequest
		Map<String, object> contractSlsRep = new Map<String, object>();
        Map<String, Object> contractRequest = new Map<String, Object>();
        Map<String, Integer> contractTypeMap = createContractTypeMap();

        String validationErrors='';
        String invalidTypeErrors='';
        String messageTitle='';

        //Pull the Contract details for the ContractIds in scope
        for (Contract contractRec : [Select Id, LastModifiedBy.Lan_Id__c, Createdby.Lan_Id__c, Account.Owner.Lan_Id__c, Account.RFO_SalesRepStartDate__c
                                            , Name, Description, ActivatedBy.Lan_Id__c, ActivatedDate, CreatedDate, RFO_ContractDate__c
                                            , Account.Name, Account.Description, Status, RFO_Notes__c, RFO_ContractId__c, Account.LastModifiedDate
                                            , StartDate, Account.RFO_TASId__c, RFO_ContractType__c, ContractNumber, RFO_ExecuteDate__c
                                       From Contract
                                      Where Id in :ContractIds Limit 49999]) {
            contractRequest = new Map<String, Object>();

            //Validate required fields
            validationErrors = contractRec.RFO_ContractType__c == null ? ', Contract type' : '';
            validationErrors += contractRec.Account.RFO_TASId__c == null ? ', Account TAS Id' : '';
            validationErrors += contractRec.RFO_ContractDate__c == null ? ', Contract Date' : '';
            if (validationErrors != null && validationErrors != '') {
                validationErrors = 'TAS required field(s) missing: ' + validationErrors.substringAfter(', ');
            } 
            if (contractRec.RFO_ContractType__c != null && !contractTypeMap.containsKey(contractRec.RFO_ContractType__c)) {
                invalidTypeErrors = 'TAS does not accept this Contract Type: ' + contractRec.RFO_ContractType__c;
                validationErrors = validationErrors != '' ? validationErrors + '\n' + invalidTypeErrors : '';
            }

            //Check if any validation errors were found
            if (validationErrors != null && validationErrors != '') {

                //Publish error to user and record
                messageTitle = RFO_Constant.NOTIFICATION_TAS_FAILURE;
                eventNotifications  .type(RFO_Constant.NOTIFICATION_TYPE_ERROR) .title(messageTitle) .message(validationErrors)
                                    .sendToCurrentUser() .event('ContractSync') .recordId(contractRec.Id) .addNotification();
                validationErrors = messageTitle + ' \n' + validationErrors;
                RFO_GlobalCallOut.feedItemCreation(String.valueOf(contractRec.Id), validationErrors);
            }else {
                if (contractRec.RFO_ContractId__c != null) {
                    contractRequest.put(RFO_Constant.CONTRACTID, contractRec.RFO_ContractId__c);
                    contractRequest.put(RFO_Constant.PAYLOAD_PARAM_KEY_RESTMETHOD, RFO_Constant.PUT_METHOD);
                } else {
                    contractRequest.put(RFO_Constant.PAYLOAD_PARAM_KEY_RESTMETHOD, RFO_Constant.POST_METHOD);
                }
                if (contractRec.RFO_ExecuteDate__c != null) {
                    contractRequest.put('executedDate', (Datetime)contractRec.RFO_ExecuteDate__c);
                }
                contractRequest.put('lastModifiedBy', contractRec.LastModifiedBy.Lan_Id__c != NULL? contractRec.LastModifiedBy.Lan_Id__c : '');
                contractRequest.put('createdBy', contractRec.Createdby.Lan_Id__c != NULL? contractRec.Createdby.Lan_Id__c : '');
                contractRequest.put('contractDate', (Datetime)contractRec.RFO_ContractDate__c);
                contractRequest.put('transactionId', Integer.valueOf(contractRec.ContractNumber));
                contractRequest.put('notes', contractRec.RFO_Notes__c != NULL? contractRec.RFO_Notes__c : 'none');
                contractRequest.put('railforceContractGuid', contractRec.Id);
                contractRequest.put('accountId', contractRec.Account.RFO_TASId__c);
                contractRequest.put('contractType', contractRec.RFO_ContractType__c);
                if (contractRec.RFO_ContractId__c == null) {
                    contractSlsRep = new Map<String, object>();
                    contractSlsRep.put('lanId', contractRec.Account.Owner.Lan_Id__c != NULL? contractRec.Account.Owner.Lan_Id__c : 'none');
                    contractSlsRep.put('startDate', contractRec.Account.RFO_SalesRepStartDate__c != NULL 
                                                    ? contractRec.Account.RFO_SalesRepStartDate__c : contractRec.Account.LastModifiedDate);
                    contractRequest.put('salesRepresentative', contractSlsRep);
                }
                contractRequests.put(contractRec.Id, contractRequest);
            }
        }
        eventNotifications .publishNotificationEvent();
        return contractRequests;
    }

/**
 * wrapper class for ContractType Map
 **/    
    static Map<String, Integer> createContractTypeMap(){
        Map<String, Integer> contractTypeMap = new Map<String, Integer>();
        contractTypeMap.put('MANAGEMENT AGREEMENT',1);
        contractTypeMap.put('MAINTENANCE AGREEMENT',2);
        contractTypeMap.put('NET LEASE',3);
        contractTypeMap.put('FULL SERVICE LEASE',4);
        contractTypeMap.put('PURCHASE &  SALE AGREEMENT',5);
        contractTypeMap.put('PER DIEM',7);
        contractTypeMap.put('DIRECT SALE',24);
        return contractTypeMap;
    }

/* Subclass to capture exceptions */
   class RFO_ContractSyncControllerException extends Exception {}

}