/**
* @Author      : Accenture  
* @Version     : 1.0
* @Created Date: 17th June 2019
* @Description : This class is to create OrderAsset record
*                
**/
public class RFO_AssetTriggerHandler implements ITriggerHandler
{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
    RFO_TriggerSetting__mdt caseTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='AssetTrigger'];
     
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        if (caseTrigger.RFO_Active__c)
            return TriggerDisabled;
        else
            return true;
    }
 
    public void BeforeInsert(List<SObject> newItems) 
    {
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
/**
 * Method to create Order Asset Record when an Asset is created with a file number associated with Asset File related File Number
 **/
    public void AfterInsert(Map<Id, SObject> newItems) {
        set<Id> orderIds = new set<Id>();
        for(Asset assetSO : (list<Asset>)newItems.values()) {
            if(assetSO.Status == 'Assigned' || assetSO.RFO_BeginChargeDate__c >= System.today()) {
                orderIds.add(assetSO.RFO_FileOrder__c);
            }
        }
        try{
            if(!orderIds.isEmpty()) {
                RFO_AssetTriggerHelper.assetsDelivered(orderIds);
            }
            RFO_AssetTriggerHelper.createOrderAsset(newItems);
            RFO_AssetTriggerHelper.checkUMLERStatus(newItems, null);
            //Added by Vihari Alpha-530
            RFO_AssetTriggerHelper.updateAssetCountOnOrder((List<Asset>)newItems.values());
            // End ALPHA-530
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        set<Id> orderIds = new set<Id>();
        list<Asset> assetList = (list<Asset>)newItems.values();
        map<Id,Asset> oldAssetMap = (Map<Id,Asset>)oldItems;
        for(Asset assetSO : assetList) {
            if((assetSO.Status == 'Assigned' && assetSO.Status != oldAssetMap.get(assetSO.Id).Status)
                || (assetSO.RFO_BeginChargeDate__c >= System.today() && assetSO.RFO_BeginChargeDate__c != oldAssetMap.get(assetSO.Id).RFO_BeginChargeDate__c)) {
                    
                orderIds.add(assetSO.RFO_FileOrder__c);
            }
        }
        if(!orderIds.isEmpty()) {
            RFO_AssetTriggerHelper.assetsDelivered(orderIds);
        }
        RFO_AssetTriggerHelper.checkUMLERStatus(newItems, oldItems);
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {
         //Added by Vihari Alpha-530
        try{
            RFO_AssetTriggerHelper.updateAssetCountOnOrder((List<Asset>)oldItems.values());
        }
        catch(Exception e) {            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
        // End Alpha-530
    }
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}