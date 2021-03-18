/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 22 May 2019
* @Description :This class is to make a call to mule api and get the response.
* 20-10-19: Sabeeha- Made changes to this class to increase callout time.
**/
public class RFO_GlobalCallOut {
/**
 * Method to update the Global Account Id field on Account Record
 **/
    public static void getRFOGlobalAccountId(String accID){    
        HttpResponse response = sendRequest(accID);
        updateGlobalAccountID(response, accID);
        
    }
/**
 * Method to send request to Mule API URI to get the Global Account Id
 **/
    public static HttpResponse sendRequest(String accID){
        Http http = new Http();
        HttpResponse response;
        HttpRequest request = new HttpRequest();
        String url = RFO_IntegrationLinks__c.getInstance(RFO_Constant.ACCOUNT_OBJECT).RFO_APILink__c;
        String urlStr = url+accID;
        request.setEndpoint(urlStr);
        request.setMethod(RFO_Constant.GET_METHOD);
        request.setTimeout(setCallOutTime(RFO_Constant.ACCOUNT_OBJECT));
        request.setHeader(System.Label.RFO_Header1, System.Label.RFO_1);
        request.setHeader(System.Label.RFO_Header2, System.Label.RFO_Railforce);
        request.setHeader(System.Label.RFO_Header3, '');
        response = http.send(request);
        return response;
    }
/**
 * Method to update the Global account Id after getting the response from the mule server.
 **/
    public static void updateGlobalAccountID(HttpResponse response, String accID){
        List<Account> accNew = new List<Account>();
        List<Account> acc = new List<Account>();
        Map<String, Object> item = new Map<String, Object>();
        String response1;
        if (response.getStatusCode() == 200) {
            List<Object> res = generateRespone(response);
            if (res != null) {
                item = (Map<String, Object>)res[0];
                System.debug('payload: '+res);
                acc = [select Id, name, RFO_GlobalAccountID__c, RecordTypeId from Account where Id =:accID limit 1];
                for(Account a: acc){
                    a.RFO_GlobalAccountID__c = String.valueOf((Integer)item.get(System.Label.RFO_GlobalId));
                    a.RFO_AccountStatus__c = 'Active';
                    accNew.add(a);
                }
                update accNew;
            }
        }
        else {
            List<CollaborationGroup> chatterGroup = [Select id, name from CollaborationGroup where Name =:System.Label.RFO_DataManagement];
            if(chatterGroup != null && chatterGroup.size()>0){
                string grpID = chatterGroup[0].id;
                String resp= response.getBody ();
                FeedItem post = new FeedItem();
                post.ParentId = grpID;
                post.Body = System.label.RFO_GlobalIdErrorMess+'\n'+System.label.RFO_URL_head+accID;
                insert post;
                failureResponseChatterPost(response,accID);                
            }

        }
    }
/**
 * Method to Create/Update an Asset file and File Split in TAS and update the File Number in Salesforce.
 **/
    public static void getAssetFileNumber(String jsonBody, String assetFileId, String FileType, String RecordStatus, String messageId){    
        HttpResponse response = postAssetFileRequest(assetFileId, jsonBody, FileType, RecordStatus, messageId);
        updateAssetFileNumber(response, assetFileId, RecordStatus, FileType);
        
    }
/**
 * Method to send Asset File or File Split data to TAS through Mule server.
 **/
    public static HttpResponse postAssetFileRequest(String assetFileId, String jsonBody, String FileType, String RecordStatus,  String messageId){
        Http http = new Http();
        String url;
        String RequestMethod;
        HttpResponse response;
        HttpRequest request = new HttpRequest();
        if(FileType == RFO_Constant.PARENT_ASSETFILE){
            url = RFO_IntegrationLinks__c.getInstance(RFO_Constant.POST_PARENT_ASSET_FILE).RFO_APILink__c;
            if(RecordStatus == RFO_Constant.RECORD_CREATED){
                RequestMethod = RFO_Constant.POST_METHOD;
            }
            else if(RecordStatus == RFO_Constant.RECORD_UPDATED){
                RequestMethod = RFO_Constant.PUT_METHOD;
            }
        }
        else if(FileType == RFO_Constant.FILESPLIT_ASSETFILE){
            url = RFO_IntegrationLinks__c.getInstance(RFO_Constant.PUT_FILESPLIT_ASSET_FILE).RFO_APILink__c;
            RequestMethod = RFO_Constant.PUT_METHOD;
        }
        request.setEndpoint(url);
        request.setMethod(RequestMethod);
        request.setTimeout(setCallOutTime('AssetFile'));
        request.setHeader(System.Label.RFO_Header1, messageId!=null? messageId:System.Label.RFO_1);
        request.setHeader(System.Label.RFO_Header2, System.Label.RFO_Railforce);
        request.setHeader(System.Label.RFO_Header3, RFO_Constant.LEASING);
        request.setHeader(System.Label.RFO_Header4, RFO_Constant.APPLICATION_JSON);
        request.setBody(jsonBody);
        System.debug('Request: '+jsonBody);
        response = http.send(request);
        RFO_IntegrationUtility.updateIntegrationLogStatus(response.getStatusCode(), assetFileID+'~'+RequestMethod, jsonBody, response.getBody());
        return response;
    }
/**
 * Method to get the response from the TAS that Asset File or File Split has been created or updated in TAS and update the File Number in Salesforce.
 **/
    public static void updateAssetFileNumber(HttpResponse response, String assetFileID, String RecordStatus, String FileType){
        List<Object> res;
        String MessageBody;
        List<RFO_Asset_File__c> assetFileList = new List<RFO_Asset_File__c>();
        Map<String, Object> item = new Map<String, Object>(); 
        if(FileType == RFO_Constant.PARENT_ASSETFILE && RecordStatus == RFO_Constant.RECORD_CREATED){
            if (response.getStatusCode() == 200) {
                res = generateRespone(response);
                if (res != null) {
                    item = (Map<String, Object>)res[0];
                    System.debug('Response'+item);
                    for(RFO_Asset_File__c assetFile: [Select id, RFO_FileType__c, RFO_FileNumber__c, RFO_Suffix__c, RFO_IntegrationId__c from RFO_Asset_File__c Where id =:assetFileID]){
                        assetFile.RFO_FileNumber__c = String.valueOf(item.get(RFO_Constant.FILENUMBER));
                        if(assetFile.RFO_FileNumber__c!=null){
                            assetFile.RFO_IntegrationId__c = (assetFile.RFO_FileNumber__c+(assetFile.RFO_Suffix__c==null ?'': assetFile.RFO_Suffix__c));
                            assetFile.Name = assetFile.RFO_IntegrationId__c;
                        }
                        assetFileList.add(assetFile);
                        MessageBody = String.valueOf(item.get(RFO_Constant.MESSAGE));
                        //feedItemCreation(assetFileID,MessageBody);
                    }
                    try{
                        update assetFileList;
                        feedItemCreation(assetFileID,MessageBody);
                    }
                    catch(Exception e) {
                    	feedItemCreation(assetFileID,e.getMessage());
                    }
                }
            }
            else{
                try{
                    Map<String, Object> results = (Map<String, Object>)
                        JSON.deserializeUntyped(response.getBody());
                    feedItemCreation(assetFileID,'Response code: '+response.getStatusCode()+', Message: '+((String)results.get(RFO_Constant.MESSAGE)));
                }
                catch(Exception e) {
                    failureResponseChatterPost(response,assetFileID);
                }
            }
        }
        else if((FileType == RFO_Constant.PARENT_ASSETFILE && RecordStatus == RFO_Constant.RECORD_UPDATED) || (FileType == RFO_Constant.FILESPLIT_ASSETFILE)){
            if (response.getStatusCode() == 200) {
                res = generateRespone(response);
                if (res != null) {
                    item = (Map<String, Object>)res[0];
                    System.debug('Response: '+item);
                    MessageBody = String.valueOf(item.get(RFO_Constant.MESSAGE));
                    feedItemCreation(assetFileID,MessageBody);
                }
            }
            else{
                try{
                    Map<String, Object> results = (Map<String, Object>)
                        JSON.deserializeUntyped(response.getBody());
                    feedItemCreation(assetFileID,'Response code: '+response.getStatusCode()+', Message: '+((String)results.get(RFO_Constant.MESSAGE)));
                }
                catch(Exception e) {
                    failureResponseChatterPost(response,assetFileID);
                }
            }
        }
    }
/**
 * Method to send Account Owner or AccountteamMember changes to TAS
 **/
    public static void sendAccountInfoToTAS(String accId, String JsonBody, String messageId, String SourceCall, String SuccessMessage, String aTeamId){    
        HttpResponse response = sendAccountInfoToTASRequest(accId, JsonBody, messageId, SourceCall);
        getAccountInfoResultFromTAS(response, accID, SourceCall, SuccessMessage, aTeamId);
    }
/**
 * Method to send Account Owner, S&PRating, Moody's Rating and Account Team Member info to Mule Server.
 **/
    public static HttpResponse sendAccountInfoToTASRequest(String accId, String JsonBody, String messageId, String SourceCall){
        Http http = new Http();
        HttpResponse response;
        HttpRequest request = new HttpRequest();
        String url = RFO_IntegrationLinks__c.getInstance(RFO_Constant.ACCOUNT_TEAM_MEMBER).RFO_APILink__c;
        request.setEndpoint(url);
        request.setMethod(RFO_Constant.PUT_METHOD);
        request.setTimeout(setCallOutTime(RFO_Constant.ACCOUNT_TEAM_MEMBER));
        request.setHeader(System.Label.RFO_Header1, messageId!=null? messageId:System.Label.RFO_1);
        request.setHeader(System.Label.RFO_Header2, System.Label.RFO_Railforce);
        request.setHeader(System.Label.RFO_Header3, RFO_Constant.LEASING);
        request.setHeader(System.Label.RFO_Header4, RFO_Constant.APPLICATION_JSON);
        request.setBody(JsonBody);
        System.debug('Payload: '+JsonBody);
        response = http.send(request);
        System.debug('Response: '+response);
        RFO_IntegrationUtility.updateIntegrationLogStatus(response.getStatusCode(), accId+'~'+RFO_Constant.PUT_METHOD, jsonBody, response.getBody());

        /*if (SourceCall !=RFO_Constant.BATCH) {
            RFO_IntegrationUtility.updateIntegrationLogStatus(response.getStatusCode(), accId+'~'+RFO_Constant.PUT_METHOD, jsonBody, response.getBody());
        }*/
        return response;
    }
/**
 * Method to get the Response from Mule server whether the Account or Accountteam Member changes are synced to TAS successfully or not.
 **/
    public static void getAccountInfoResultFromTAS(HttpResponse response, String accId, String SourceCall, String SuccessMessage, String aTeamId){
        List<Object> res;
        String MessageBody;
        Map<String, Object> item = new Map<String, Object>(); 
        AccountTeamMember aTeamRec = new AccountTeamMember();
        Map<Id, String> feedItemCreationMap = new Map<Id, String>();
        RFO_AccountTeamMemberBatch batchClassObj = new RFO_AccountTeamMemberBatch();
        if (response.getStatusCode() == 200) {
            res = generateRespone(response);
            if (res != null) {
                item = (Map<String, Object>)res[0];
                if(aTeamId!='' && SourceCall==RFO_Constant.TRIGER){
                    aTeamRec.Id=aTeamId;
        			aTeamRec.RFO_TASStatus__c = RFO_Constant.SYNC_SUCCEEDED;
                	update aTeamRec;
                }
                MessageBody = SuccessMessage + String.valueOf(item.get(RFO_Constant.MESSAGE));
                feedItemCreation(accId,MessageBody);
            }
        }
        else{
            try{
                Map<String, Object> results = (Map<String, Object>)
                    JSON.deserializeUntyped(response.getBody());
                if(aTeamId!='' && SourceCall==RFO_Constant.TRIGER){
                    aTeamRec.Id=aTeamId;
        			aTeamRec.RFO_TASStatus__c = RFO_Constant.SYNC_FAILED;
                	update aTeamRec;
                }
                feedItemCreation(accId,'Account Team Integration Response code: '+response.getStatusCode()+', Message: '+((String)results.get(RFO_Constant.MESSAGE)));
            }
            catch(Exception e) {
                BasicResponseBody stdResponseBody = new BasicResponseBody();
                if(aTeamId!='' && SourceCall==RFO_Constant.TRIGER){
                    aTeamRec.Id=aTeamId;
        			aTeamRec.RFO_TASStatus__c = RFO_Constant.SYNC_FAILED;
                	update aTeamRec;
                }
                failureResponseChatterPost(response,accId);
            }
        }
    }
/**
 * Method to send Rider details to TAS when a rider is created or updated in salesforce.
 **/
    public static void getRiderId(String RiderID, String JsonBody, String messageId, String TASRiderId){    
        HttpResponse response = sendRiderInfoToTASRequest(RiderID, JsonBody, messageId, TASRiderId);
        getRiderInfoResultFromTAS(response, RiderID);
    }
/**
 * Method to send Rider record details to TAS to create or update a rider record in TAS.
 **/
    public static HttpResponse sendRiderInfoToTASRequest(String RiderID, String JsonBody, String messageId, String TASRiderId){
        Http http = new Http();
        HttpResponse response;
        HttpRequest request = new HttpRequest();
        String url = RFO_IntegrationLinks__c.getInstance(RFO_Constant.RIDER).RFO_APILink__c;
        request.setEndpoint(url);
        if(TASRiderId!=null && TASRiderId!='0'){
            request.setMethod(RFO_Constant.PUT_METHOD);
        }
        else {
            request.setMethod(RFO_Constant.POST_METHOD);
        }
        request.setTimeout(setCallOutTime(RFO_Constant.RIDER));
        String messa = messageId!=null? messageId:System.Label.RFO_1;
        request.setHeader(System.Label.RFO_Header1, messageId!=null? messageId:System.Label.RFO_1);
        request.setHeader(System.Label.RFO_Header2, System.Label.RFO_Railforce);
        request.setHeader(System.Label.RFO_Header3, RFO_Constant.LEASING);
        request.setHeader(System.Label.RFO_Header4, RFO_Constant.APPLICATION_JSON);
        request.setBody(JsonBody);
        response = http.send(request);
        RFO_IntegrationUtility.updateIntegrationLogStatus(response.getStatusCode(), RiderID+'~'+RFO_Constant.POST_METHOD, jsonBody, response.getBody());
        return response;
    }
/**
 * Method to get the response from the server whether Rider has been created or updated successfully in TAS or not.
 **/
    public static void getRiderInfoResultFromTAS(HttpResponse response, String RiderID){
        List<Object> res;
        String MessageBody;
        Map<String, Object> item = new Map<String, Object>(); 
        RFO_Rider__c riderRec = new RFO_Rider__c();
        riderRec.Id=RiderID;
        if (response.getStatusCode() == 200) {
            res = generateRespone(response);
            if (res != null) {
                item = (Map<String, Object>)res[0];
                riderRec.RFO_IntegrationStatus__c = 'Success';
                update riderRec;
                MessageBody = String.valueOf(item.get(RFO_Constant.MESSAGE));
                feedItemCreation(RiderID,MessageBody);
            }
        }
        else{
            try{
                Map<String, Object> results = (Map<String, Object>)
                    JSON.deserializeUntyped(response.getBody());
                feedItemCreation(RiderID,'Response code: '+response.getStatusCode()+', Message: '+((String)results.get(RFO_Constant.MESSAGE)));
            }
            catch(Exception e) {
                failureResponseChatterPost(response,RiderID);
            }
        }
    }    
/**
 * Common method to geneate response in desired format
 **/
    public static List<Object> generateRespone(HttpResponse response){
        String response1;
        response1= response.getBody ();
        if (!response1.contains('"Response":')) {
            if (response1.substring(0,1).equals('{')) {
                response1 = '[' + response1  + ']';
            }
            response1 = '{"Response": ' + response1 + '}'; 
        }
        Map<String, Object> responseBodyMap = (Map<String, Object>)
            JSON.deserializeUntyped(response1);
        List<Object> res = (List<Object>)responseBodyMap.get('Response');
        return res;
    }
/**
 * Common method to create a chatter post on the Record
 **/
    public static void feedItemCreation(String recordId, String message){
        FeedItem post = new FeedItem();
        post.ParentId = recordId;
        post.Body = message+'\n'+System.label.RFO_URL_head+recordId;
        insert post;
    }
    public static void failureResponseChatterPost(HttpResponse response, String recordId){
        BasicResponseBody stdResponseBody = new BasicResponseBody();
        stdResponseBody.status = RFO_Constant.INTGRN_RSPNS_STATUS_FAILURE;
        stdResponseBody.message = response.getBody();
        
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(JSON.Serialize(stdResponseBody));
        //System.debug('The following exception has occurred: ' + e.getMessage());
        feedItemCreation(recordId,'Response code: '+response.getStatusCode()+', Message: '+String.valueOf(results.get(RFO_Constant.MESSAGE)));
    }
    class BasicResponseBody{
        String status;
        String message;
    }
    public static Integer setCallOutTime(String serviceName){
        RFO_WebServiceCalloutSettings__mdt calloutSetting = 
            [Select id,RFO_TimeOut__c 
             from RFO_WebServiceCalloutSettings__mdt where DeveloperName=:serviceName];
        return calloutSetting.RFO_TimeOut__c!=null && calloutSetting.RFO_TimeOut__c>0
            ?Integer.valueOf(calloutSetting.RFO_TimeOut__c):10000;
    }
    /**
 * Method to send AccountteamMember changes from batch to TAS
 **/
    public static Map<AccountTeamMember, String> sendAccountInfofromTAStoBatch(String accId, String JsonBody, String messageId, String SourceCall, String SuccessMessage, String aTeamId){    
        Map<AccountTeamMember, String> newATeamMap = new Map<AccountTeamMember, String>();
        HttpResponse response = sendAccountInfoToTASRequest(accId, JsonBody, messageId, SourceCall);
        newATeamMap = getAccountInfoResult(response, accID, SuccessMessage, aTeamId);
        return newATeamMap;
    }
    public static Map<AccountTeamMember, String> getAccountInfoResult(HttpResponse response, String accId, String SuccessMessage, String aTeamId){
        List<Object> res;
        String MessageBody;
        Map<String, Object> item = new Map<String, Object>(); 
        AccountTeamMember aTeamRec = new AccountTeamMember();
        Map<AccountTeamMember, String> feedItemCreationMap = new Map<AccountTeamMember, String>();
        RFO_AccountTeamMemberBatch batchClassObj = new RFO_AccountTeamMemberBatch();
        if (response.getStatusCode() == 200) {
            res = generateRespone(response);
            if (res != null) {
                item = (Map<String, Object>)res[0];
                if (aTeamId!=''){
                    aTeamRec.Id=aTeamId;
                    aTeamRec.RFO_TASStatus__c = RFO_Constant.SYNC_SUCCEEDED;
                }
                MessageBody = SuccessMessage + String.valueOf(item.get(RFO_Constant.MESSAGE));
                feedItemCreationMap.put(aTeamRec, MessageBody);             
            }
        }
        else{
            try{
                Map<String, Object> results = (Map<String, Object>)
                    JSON.deserializeUntyped(response.getBody());
                aTeamRec.Id=aTeamId;
                aTeamRec.RFO_TASStatus__c = RFO_Constant.SYNC_FAILED;
                feedItemCreationMap.put(aTeamRec, 
                                        'Account Team Integration Response code: '+response.getStatusCode()+', Message: '+((String)results.get(RFO_Constant.MESSAGE)));
            }
            catch(Exception e) {
                BasicResponseBody stdResponseBody = new BasicResponseBody();
                aTeamRec.Id=aTeamId;
                aTeamRec.RFO_TASStatus__c = RFO_Constant.SYNC_FAILED;
                stdResponseBody.status = RFO_Constant.INTGRN_RSPNS_STATUS_FAILURE;
                stdResponseBody.message = response.getBody();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(JSON.Serialize(stdResponseBody));
                feedItemCreationMap.put(aTeamRec, 'Account Team Integration Response code: '+response.getStatusCode()+', Message: '+String.valueOf(results.get(RFO_Constant.MESSAGE)));
            }
        }
        return feedItemCreationMap;
    }
}