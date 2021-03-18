public class RFO_SendAssetFileInfoToTAS {
    public String currentRecordId {get;set;}
    public RFO_Asset_File__c assetFile {get;set;}
    public Id userId;
    public String Message{get;set;}
    public Boolean userAccessFlag{get;set;}
    public RFO_Asset_File__c assetFileRec;
    String RecordStatus;
    public RFO_SendAssetFileInfoToTAS(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        userId = Userinfo.getUserId();
    }
    public void callouttoTAS(){
        try{
            assetFileRec = [Select id, RFO_IntegrationId__c, RFO_FileType__c, RFO_Quantity__c,
                            RFO_FileId__c, RFO_ParentFileNumber__c, RFO_ProductDivision__c, 
                            RFO_Term__c, RFO_PaymentAmount__c, RFO_RiderLeaseType__c, RFO_ContractType__c, 
                            RFO_isAdvanceOrder__c, RFO_ParentFileNumber__r.RFO_FileId__c, RFO_OrderNumber__c, 
                            RFO_OrderNumber__r.Account.Name, RFO_OrderNumber__r.Account.RFO_OracleId__c, 
                            RFO_OrderNumber__r.RFO_Commodity_lookup__r.RFO_STCC__c, RFO_FileNumber__c, RFO_CurrentQuantity__c  
                            from RFO_Asset_File__c Where id =: currentRecordId];
            userAccessFlag = true;
            if(assetFileRec.RFO_FileType__c!=null){
                if(assetFileRec.RFO_FileType__c==RFO_Constant.PARENT_ASSETFILE){
                    if(assetFileRec.RFO_FileNumber__c==null){
                        RecordStatus = RFO_Constant.RECORD_CREATED;
                    }
                    else if(assetFileRec.RFO_FileNumber__c!=null){
                        RecordStatus = RFO_Constant.RECORD_UPDATED;
                    }
                }
                else if(assetFileRec.RFO_FileType__c==RFO_Constant.FILESPLIT_ASSETFILE && assetFileRec.RFO_ParentFileNumber__c!=null){
                    RecordStatus = RFO_Constant.FILESPLIT_ASSETFILE;
                }
            }
            
            if(RecordStatus!=null){
                RFO_AssetFileTriggerHelper.requestAssetFileNumber(assetFileRec,RecordStatus);
                Message = 'Asset File Info has been sent to TAS.';
            }
        }
        catch(Exception e) { 
            //Message = '';
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    public PageReference reset() { 
        PageReference pageRef = new PageReference('/' + assetFileRec.Id);
        pageRef.setRedirect(true);
        return pageRef;
    } 
}