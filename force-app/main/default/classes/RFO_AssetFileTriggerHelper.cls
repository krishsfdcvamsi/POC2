/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 22 May 2019
* @Description : This class is to Send AssetFile and File SPlit info to TAS and update File Number n salesforce
*                
**/
public class RFO_AssetFileTriggerHelper {
/**
 * METHOD TO UPDATE ASSET FILE NUMBER, ORDER NUMBER, FILE TYPE ON ASSET FILE SPLIT
 **/
    public static void updateAssetFile(RFO_Asset_File__c assetFile){
        if(assetFile.RFO_ParentFileNumber__c != null){
            assetFile.RFO_FileType__c = RFO_Constant.FILESPLIT_ASSETFILE;
            if(assetFile.RFO_FileNumber__c == null || assetFile.RFO_OrderNumber__c == null){
                RFO_Asset_File__c parentAssetFile = [select Id,RFO_FileNumber__c, RFO_OrderNumber__c from RFO_Asset_File__c where Id =:assetFile.RFO_ParentFileNumber__c];
                assetFile.RFO_FileNumber__c = parentAssetFile.RFO_FileNumber__c;
                assetFile.RFO_OrderNumber__c = parentAssetFile.RFO_OrderNumber__c;
            }
        }
        assetFile.RFO_IntegrationId__c = (assetFile.RFO_FileNumber__c==null ?'': assetFile.RFO_FileNumber__c)+(assetFile.RFO_Suffix__c==null ?'': assetFile.RFO_Suffix__c);
        if(assetFile.RFO_FileNumber__c!=null){
            assetFile.Name = assetFile.RFO_IntegrationId__c;
        } 
    }
/**
 * METHOD TO UPDATE OR CREATE ASSET FILE IN TAS
 **/
    public static void createAssetFileInTAS(Map<Id, SObject> newItems, String RecordStatus){
        List<RFO_Asset_File__c> assetFileList = [Select id, RFO_CurrentQuantity__c, RFO_IntegrationId__c, RFO_FileType__c, RFO_Quantity__c, RFO_FileId__c, RFO_ParentFileNumber__c, RFO_ProductDivision__c, RFO_Term__c, RFO_PaymentAmount__c, RFO_RiderLeaseType__c, RFO_ContractType__c, RFO_isAdvanceOrder__c, RFO_ParentFileNumber__r.RFO_FileId__c, RFO_OrderNumber__c, RFO_OrderNumber__r.Account.Name, RFO_OrderNumber__r.Account.RFO_OracleId__c, RFO_OrderNumber__r.RFO_Commodity_lookup__r.RFO_STCC__c, RFO_OrderNumber__r.RecordType.DeveloperName  from RFO_Asset_File__c Where id in :newItems.keySet()];
        if(!assetFileList.isEmpty()){
            for(RFO_Asset_File__c assetFile : assetFileList){
                requestAssetFileNumber(assetFile,RecordStatus);
            }
        }
    }
/**
 * METHOD TO GENERATE JSON PAYLOAD OF ASSET FILE
 **/
    public static void requestAssetFileNumber(RFO_Asset_File__c assetFile, String RecordStatus){
        String FileType;
        Id assetFileId;
        Id loggedinUserID;
        RFO_Asset_File__c assetRecord;
        Map<Id, Integer> requestsLogDetails;
        User loggedinUser = new User();
        try {
            loggedinUserID = Userinfo.getUserId();
            loggedinUser = [Select id, Lan_Id__c from User where id =:loggedinUserID];
            
            Map<String, Integer> contractTypeMap = createContractTypeMap();
            Map<String, Integer> riderLeaseTypeMap = createRiderLeaseTypeMap();
            
            List<DocumentClass> documentsList = new List<DocumentClass>();
            DocumentClass documents = new DocumentClass();
            //documents.fileStream = 'jvberi0xljqnjeljz9mncjqwnya';
            //documents.type = 4;
            //documents.extension = 'pdf';
            documentsList.add(documents);
            
            List<AssetClass> assetsList = new List<AssetClass>();
            
            AssetClass assets = new AssetClass();
            assets.quantity = Integer.valueOf(assetFile.RFO_CurrentQuantity__c);
            if(assetFile.RFO_OrderNumber__r.RFO_Commodity_lookup__r.RFO_STCC__c != null){
                assets.stcc = Integer.valueOf(assetFile.RFO_OrderNumber__r.RFO_Commodity_lookup__r.RFO_STCC__c);
            }
            else {
                assets.stcc = RFO_Constant.ZERO;
            }
            assetsList.add(assets);
            
            RequestBodyClass reqbody = new RequestBodyClass();
            
            IF((assetFile.RFO_FileType__c == RFO_Constant.FILESPLIT_ASSETFILE) || (assetFile.RFO_FileType__c == RFO_Constant.PARENT_ASSETFILE && RecordStatus == RFO_Constant.RECORD_UPDATED)){
                reqbody.fileNumber = assetFile.RFO_IntegrationId__c;
            }
            
            reqbody.transactionId = Integer.valueOf((assetFile.RFO_FileId__c).subString(3));
            reqbody.railforceOrderGuid = assetFile.Id;
            if(assetFile.RFO_FileType__c == RFO_Constant.FILESPLIT_ASSETFILE){
                reqbody.railforceParentOrderGuid = String.valueOF(assetFile.RFO_ParentFileNumber__c);
            }
            reqbody.lanId = loggedinUser.Lan_Id__c;
            IF(assetFile.RFO_FileType__c == RFO_Constant.PARENT_ASSETFILE){
                reqbody.parentTransactionId = RFO_Constant.ZERO;
            }
            else if(assetFile.RFO_FileType__c == RFO_Constant.FILESPLIT_ASSETFILE){
                reqbody.parentTransactionId = Integer.valueOf((assetFile.RFO_ParentFileNumber__r.RFO_FileId__c).subString(3));
            }
            if(contractTypeMap.containsKey(assetFile.RFO_ContractType__c)){
                reqbody.contractType = contractTypeMap.get(assetFile.RFO_ContractType__c);
            }
            
            reqbody.isAdvancedOrder = assetFile.RFO_isAdvanceOrder__c;
            if(assetFile.RFO_ProductDivision__c != null){
                reqbody.division = assetFile.RFO_ProductDivision__c.subString(0,1);
            }
            if(assetFile.RFO_OrderNumber__r.AccountId != null){                
                reqbody.customerName = assetFile.RFO_OrderNumber__r.Account.Name;
            }
            if(assetFile.RFO_OrderNumber__r.AccountId != null && assetFile.RFO_OrderNumber__r.Account.RFO_OracleId__c != null){
                reqbody.oracleId = Integer.valueOf(assetFile.RFO_OrderNumber__r.Account.RFO_OracleId__c);
            }
            else{
                reqbody.oracleId = RFO_Constant.ZERO;
            }
            if(riderLeaseTypeMap.containsKey(assetFile.RFO_RiderLeaseType__c)){
                reqbody.riderLeaseType = riderLeaseTypeMap.get(assetFile.RFO_RiderLeaseType__c);
            }
            
            reqbody.term = Integer.valueOf(assetFile.RFO_Term__c);
            if(assetFile.RFO_PaymentAmount__c != null){
                reqbody.paymentAmount = assetFile.RFO_PaymentAmount__c;
            }
            reqbody.documents = documentsList;
            reqbody.assets = assetsList;
            reqbody.orderType=assetFile.RFO_OrderNumber__r.RecordType.DeveloperName;// Added By Vihari EPSI-691
            String jsonReqBody = json.serialize(reqbody, true);
            
            Map<Id, Object> messageIdRequest = new Map<Id, Object>();
            messageIdRequest.put(assetFile.Id, reqbody);
            IF(assetFile.RFO_FileType__c == RFO_Constant.FILESPLIT_ASSETFILE){
                requestsLogDetails = RFO_IntegrationUtility.createLogDetail(  messageIdRequest
                                                                            , RFO_Constant.ASSETFILE_FILESPLIT
                                                                            , RFO_Constant.R_CREATE
                                                                            , '.'
                                                                            , RFO_Constant.PUT_METHOD
                                                                            , 'RFO_AssetFileTriggerHelper');
            }
            else If(assetFile.RFO_FileType__c == RFO_Constant.PARENT_ASSETFILE && RecordStatus == RFO_Constant.RECORD_UPDATED){
                requestsLogDetails = RFO_IntegrationUtility.createLogDetail(  messageIdRequest
                                                                            , RFO_Constant.ASSETFILE_OBJECT
                                                                            , RFO_Constant.R_UPDATE
                                                                            , '.'
                                                                            , RFO_Constant.PUT_METHOD
                                                                            , 'RFO_AssetFileTriggerHelper');
            }
            else If(assetFile.RFO_FileType__c == RFO_Constant.PARENT_ASSETFILE && RecordStatus == RFO_Constant.RECORD_CREATED){
                requestsLogDetails = RFO_IntegrationUtility.createLogDetail(  messageIdRequest
                                                                            , RFO_Constant.ASSETFILE_OBJECT
                                                                            , RFO_Constant.R_CREATE
                                                                            , '.'
                                                                            , RFO_Constant.POST_METHOD
                                                                            , 'RFO_AssetFileTriggerHelper');
            }
            
            reqbody.messageId = requestsLogDetails.get(assetFile.Id);//Integer.valueOf(dt.getTime());
            String jsonBody = json.serialize(reqbody, true);
            if(riderLeaseTypeMap.containsKey(assetFile.RFO_RiderLeaseType__c)){
                RFO_SendToTASFutureClass.getAssetFileNumber(jsonBody, assetFile.Id, assetFile.RFO_FileType__c, RecordStatus, String.valueOf(requestsLogDetails.get(assetFile.Id)));
            }
            else{
                FeedItem post = new FeedItem();
                post.ParentId = assetFile.Id;
                String Message = 'The rider data cannot be sent to TAS, because the selected Lease Type is invalid.';
                post.Body = Message+'\n'+System.label.RFO_URL_head+assetFile.Id;
                insert post;
            }
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }    
    }
/**
 *     Wrapper Class
 **/
    public class RequestBodyClass{
        public String fileNumber;
        public Integer messageId;
        public Integer transactionId;
        public String railforceOrderGuid;
        public String railforceParentOrderGuid;
        public String lanId;
        public Integer parentTransactionId;
        public Integer contractType;
        public Boolean isAdvancedOrder;
        public String division;
        public String customerName;
        public Integer oracleId;
        public Integer riderLeaseType;
        public Integer term;
        public Decimal paymentAmount;
        public String orderType;// Added By Vihari EPSI-691
        public List<RFO_AssetFileTriggerHelper.DocumentClass> documents;
        public List<RFO_AssetFileTriggerHelper.AssetClass> assets;        
    }
/**
 *     Wrapper Class
 **/
    public class DocumentClass{
        /*public String fileStream;
public Integer type;
public String extension;*/
    }
/**
 *     Wrapper Class
 **/
    public class AssetClass{
        public Integer quantity;
        public Integer stcc;
    }
/**
 * WRAPPER CLASS TO CREATE CONTRACT TYPE FIELD MAP
 **/
    public static Map<String, Integer> createContractTypeMap(){
        Map<String, Integer> contractTypeMap = new Map<String, Integer>();
        contractTypeMap.put(RFO_Constant.MANAGEMENT_SERVICE,1);
        contractTypeMap.put(RFO_Constant.MAINTENANCE_SERVICE,2);
        contractTypeMap.put(RFO_Constant.LEASE,3);
        contractTypeMap.put(RFO_Constant.FULL_SERVICE,4);
        contractTypeMap.put(RFO_Constant.PER_DIEM,7);
        contractTypeMap.put(RFO_Constant.OPP_TRANS_TYPE_DIRECT_SALE,24);
        return contractTypeMap;
    }
/**
 * WRAPPER CLASS TO CREATE RIDER LEASE TYPE FIELD MAP
 **/
    public static Map<String, Integer> createRiderLeaseTypeMap(){
        Map<String, Integer> riderLeaseTypeMap = new Map<String, Integer>();
        riderLeaseTypeMap.put(RFO_Constant.MANAGEMENT,1);
        riderLeaseTypeMap.put(RFO_Constant.MAINTENANCE,2);
        riderLeaseTypeMap.put(RFO_Constant.OPP_TRANS_TYPE_NET_LEASE,3);
        riderLeaseTypeMap.put(RFO_Constant.FULL_SERVICE,4);
        riderLeaseTypeMap.put(RFO_Constant.PER_DIEM,7);
        riderLeaseTypeMap.put(RFO_Constant.OPP_TRANS_TYPE_DIRECT_SALE,24);
        riderLeaseTypeMap.put(RFO_Constant.NO_CONTRACT,8);
        return riderLeaseTypeMap;
    }
	public static void updateAssetfilestatus(Map<id,List<RFO_Asset_File__c>> newItemsMap){
        
    Id orderExstingCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
    Id orderNewCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('New Car').getRecordTypeId();
        
    /*Added By Vihari EPSI-691*/
    Id orderRetankingCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Retanking').getRecordTypeId();
    /*End Vihari EPSI-691*/   
        
    List<RFO_Asset_File__c> assetFilesUpdatedList = new List<RFO_Asset_File__c>();
              Map<id,List<RFO_Asset_File__c>> orderAssetFileMap = new Map<id,List<RFO_Asset_File__c>>();
    List<Order> ordUpdateList = new List<Order>();
    Map<id,List<Order>> ordUpdateMap = new Map<id,List<Order>>();
    List<RFO_Asset_File__c> asstFileslist = new List<RFO_Asset_File__c>();
    List<RFO_Asset_File__c> asstFileslist1 = new List<RFO_Asset_File__c>();
    List<String> statusList= new List<String>();
    Set<String> statusSet= new Set<String>();
    List<List<String>> riderStatus = new List<List<String>> ();
    Map<id,List<String>> orderStatusFileMap = new Map<id,List<String>>();
              

assetFilesUpdatedList =[select id,RFO_OrderNumber__c,RFO_Status__c,RFO_OrderNumber__r.RecordTypeID,RFO_OrderNumber__r.Status from RFO_Asset_File__c where RFO_OrderNumber__c IN:newItemsMap.KeySet() AND ((RFO_OrderNumber__r.RecordTypeID =:orderNewCarRTId) OR (RFO_OrderNumber__r.RecordTypeID =:orderRetankingCarRTId)) Limit 49999];
system.debug('** assetFilesUpdatedList ****'+assetFilesUpdatedList);

    for(RFO_Asset_File__c assetFile: assetFilesUpdatedList){
        if(assetFile.RFO_Status__c=='In Progress' || assetFile.RFO_Status__c=='Cancelled'|| assetFile.RFO_Status__c=='Complete' ){
                             asstFileslist1.add(assetFile);
                            statusList.add(assetFile.RFO_Status__c);
        					statusSet.addAll(statusList);
       
                           orderStatusFileMap.put(assetFile.RFO_OrderNumber__c,statusList);
            }
    }
     riderStatus =orderStatusFileMap.values();
    for(RFO_Asset_File__c assetFile: asstFileslist1){
        if(!orderStatusFileMap.get(assetFile.RFO_OrderNumber__c).contains('In Progress')){
            system.debug('**** statusList *****'+statusList);
            if((statusSet.size() == 1 && !statusSet.contains('Cancelled')) || (statusSet.size() > 1)){
               assetFile.RFO_OrderNumber__r.Status = 'Order Complete';
               if(!ordUpdateMap.containsKey(assetFile.RFO_OrderNumber__c)){
                   ordUpdateList.add(assetFile.RFO_OrderNumber__r);
                   ordUpdateMap.put(assetFile.RFO_OrderNumber__c,ordUpdateList);
               }
            }
        }
    }

 if(ordUpdateList.size()>0){
  Database.update(ordUpdateList);
     system.debug('*** ordUpdateList Updated***'+ordUpdateList);
  }
            
}
}