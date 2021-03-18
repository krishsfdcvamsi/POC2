/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 22 May 2019
* @Description : This class is to Send AssetFile and File SPlit info to TAS and update File Number n salesforce
*                
**/
public class RFO_AssetFileTriggerHandler implements ITriggerHandler{
    public static Boolean TriggerDisabled = false;
    public String RecordStatus;
    RFO_TriggerSetting__mdt caseTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='AssetFileTrigger'];
    /**
 * Checks to see if the trigger has been disabled either by custom setting or by running code
**/
    public Boolean IsDisabled()
    {
        if (caseTrigger.RFO_Active__c)
            return TriggerDisabled;
        else
            return true;
    }
/**
 * update file type, file number and order number for file split fields.
 **/
    public void BeforeInsert(List<SObject> newItems) 
    {
        try{
            for (RFO_Asset_File__c assetFile : (List<RFO_Asset_File__c>)newItems)
            {
                RFO_AssetFileTriggerHelper.updateAssetFile(assetFile);
            }
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
/**
 * update integration id field on asset file
 **/
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try{
            for(RFO_Asset_File__c assetFile : (List<RFO_Asset_File__c>)newItems.values())
            {
                RFO_AssetFileTriggerHelper.updateAssetFile(assetFile);
            }
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
/**
 * create asset file in TAS by sending info to mule server
 **/
    public void AfterInsert(Map<Id, SObject> newItems) {
        try{
            RecordStatus = RFO_Constant.RECORD_CREATED;
            RFO_AssetFileTriggerHelper.createAssetFileInTAS(newItems,RecordStatus);
			
			List<RFO_Asset_File__c> assetFileUpdateList = new List<RFO_Asset_File__c>();
             Map<id,RFO_Asset_File__c> assetFileNew = (Map<id,RFO_Asset_File__c>)newItems;
            Map<id,List<RFO_Asset_File__c>> assetFileNewMap = new Map<id,List<RFO_Asset_File__c>>();
             for(RFO_Asset_File__c assetfile: assetFileNew.values()){
                if(assetfile.RFO_Status__c != '' || assetfile.RFO_Status__c != NULL){ 
                    assetFileUpdateList.add(assetfile);
                  assetFileNewMap.put(assetfile.RFO_OrderNumber__c, assetFileUpdateList);
                } 
                
            }
            if(!assetFileNewMap.isEmpty()){       
            RFO_AssetFileTriggerHelper.updateAssetfilestatus(assetFileNewMap);
         }
            
        }
        
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
/**
 * send asset file or fle split info to TAS
 **/
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try{
            RecordStatus = RFO_Constant.RECORD_UPDATED;
            RFO_AssetFileTriggerHelper.createAssetFileInTAS(newItems,RecordStatus);
			
			List<RFO_Asset_File__c> assetFileUpdateList1 = new List<RFO_Asset_File__c>();
             Map<id,RFO_Asset_File__c> assetFileNewlist = (Map<id,RFO_Asset_File__c>)newItems;
            Map<id,List<RFO_Asset_File__c>> assetFileNewMap1 = new Map<id,List<RFO_Asset_File__c>>();
 Map<id,RFO_Asset_File__c> assetFileOld = (Map<id,RFO_Asset_File__c>)oldItems;
  for(RFO_Asset_File__c assetfile: assetFileNewlist.values()){
                if(assetfile.RFO_Status__c != assetFileOld.get(assetfile.id).RFO_Status__c){ 
                    assetFileUpdateList1.add(assetfile);
                  assetFileNewMap1.put(assetfile.RFO_OrderNumber__c, assetFileUpdateList1);
                } 
                
            }
    if(!assetFileNewMap1.isEmpty()){       
            RFO_AssetFileTriggerHelper.updateAssetfilestatus(assetFileNewMap1);
         }
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
}