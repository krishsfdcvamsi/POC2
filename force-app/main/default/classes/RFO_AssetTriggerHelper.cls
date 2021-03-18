/**
* @Author      : Accenture  
* @Version     : 1.0
* @Created Date: 17th June 2019
* @Description : This class is to create OrderAsset record
*                
**/
public class RFO_AssetTriggerHelper {
    /*Method to create an Order Asset Record when an Asset is created with a file number 
        associated with Asset File related File Number
    */
    public static void createOrderAsset(Map<Id,sObject> newItems) {
        
        List<String> filenumbers = new List<String>();
        Map<Id, RFO_Asset_File__c> assetFileMap;
        Map<String, Id> assetFileNumberMap = new Map<String, Id>();
        List<RFO_OrderAsset__c> orderAssetList = new List<RFO_OrderAsset__c>();
        Database.SaveResult[] srList;
        for(Asset assetRec: [Select Id, RFO_File__c from Asset where Id in :newItems.keySet()]){
            filenumbers.add(assetRec.RFO_File__c);
            assetFileNumberMap.put(assetRec.RFO_File__c, assetRec.id);
        }                
        assetFileMap = new Map<Id, RFO_Asset_File__c>([Select Id, Name, RFO_FileNumber__c, RFO_OrderNumber__c, RFO_FileType__c 
            from RFO_Asset_File__c where RFO_FileNumber__c in :filenumbers and RFO_FileType__c = 'Plain' and RFO_OrderNumber__c!=null]);        
        RFO_OrderAsset__c orderAssetRec;
        if(!(assetFileMap.isEmpty())){  
            try {                        
                for(RFO_Asset_File__c assetFile : assetFileMap.values()){                                                       
                        orderAssetRec = new RFO_OrderAsset__c();
                        orderAssetRec.RFO_AssetName__c =assetFileNumberMap.get(assetFile.RFO_FileNumber__c); 
                      orderAssetRec.Name = assetFile.RFO_FileNumber__c;
                      orderAssetRec.RFO_OrderNumber__c =assetFile.RFO_OrderNumber__c;
                        orderAssetList.add(orderAssetRec);                                        
                    }
                    insert orderAssetList;
                }catch(Exception e) {                         
                        RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.ORDERASSET,
                            RFO_Constant.TRIGER,'RFO_AssetTriggerHelper','createOrderAsset');
                }
            } 
    }
    /****************************************************************************************************************
     * Method Name: checkUMLERStatus
     * Created By: Haseeb
     * Created Date: 10/29/2020
     * Jira Number: Alpha-678
     ****************************************************************************************************************/
    public static void checkUMLERStatus(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        //Map<AssetFile,Set<asset>>
        Map<String,Set<Asset>> mapAssetFileAssets = new Map<String,Set<Asset>>();
        List<RFO_Asset_File__c> assetFilesWithAssets = new List<RFO_Asset_File__c>();
        List<String> assetFileIds = filterAssetFiles(newItems, oldItems);
        if(assetFileIds.size()>0){
            List<Order> ordersToEscalate = new List<Order>();
            assetFilesWithAssets = AssetFileService.getAssetFileWithAssetsFromAssetFileIds(assetFileIds);
            System.debug('~~~ Asset Files With Assets: '+assetFilesWithAssets);
            for(RFO_Asset_File__c assetFile : assetFilesWithAssets){
                if(assetFile.Assets__r.size()>0){
                    assetFile.UMLER_Status_Updated__c = False;
                    Order o = new Order(Id = assetFile.RFO_OrderNumber__r.Id ,
                                       Trigger_UMLER_Check_Escalation__c = assetFile.RFO_OrderNumber__r.Trigger_UMLER_Check_Escalation__c == True ? False : True);
                    ordersToEscalate.add(o);
                    System.debug('~~~ o'+o);
                }
                else{
                    assetFile.UMLER_Status_Updated__c = True;
                }
            }
            update assetFilesWithAssets;
            if(ordersToEscalate.size()>0){
                System.debug('~~ Update Order :'+ordersToEscalate);
                TriggerDispatcher.isRecurrsiveAfterUpdate = False;
                update ordersToEscalate;
            }
        }
    }
    //Filters out Assets for which if the UMLERStatus is changed or Not Sent
    public static list<string> filterAssetFiles(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        List<String> assetFileIds = new List<String>();
        for(Asset a : (Asset[]) newItems.values()){
            if(oldItems != null){
              if(a.UMLER_Status__c != oldItems.get(a.Id).get('UMLER_Status__c') ){
                  assetFileIds.add(a.RFO_AssetFile__c);
              }
            }
            else{
                if(a.UMLER_Status__c == 'Not Sent')
                    assetFileIds.add(a.RFO_AssetFile__c);
            }
        }
        return assetFileIds;
    }
    static final string EXISTING_ORDER = 'RFO_ExistingCar';
    static final string NEW_ORDER = 'RFO_NewCar';
    
    static final string ASSIGNED = 'Assigned';
    public static void assetsDelivered(set<Id> orderIds) {
        list<Order> orderList = new list<Order>();
        Integer count;
        for(order orderSO : [SELECT Id,of_Assets_Delivered__c,recordType.developerName,
                                (SELECT Id,Status,RFO_BeginChargeDate__c FROM Assets1__r WHERE Status =: ASSIGNED OR RFO_BeginChargeDate__c >= TODAY) 
                                FROM Order WHERE Id IN : orderIds]) {
                                    
            if(orderSO.Assets1__r != null) {
                count = 0;
                if(orderSO.recordType.developerName == NEW_ORDER || orderSO.recordType.developerName == RFO_Constant.ORDER_Retanking) {
                    for(Asset assetSO : orderSO.Assets1__r) {
                        if(assetSO.Status == ASSIGNED) {
                            count++;
                        }
                    }
                    
                }
                else if(orderSO.recordType.developerName == EXISTING_ORDER) {
                    for(Asset assetSO : orderSO.Assets1__r) {
                        if(assetSO.RFO_BeginChargeDate__c >= System.today()) {
                            count++;
                        }
                    }
                }
                orderSO.of_Assets_Delivered__c = count;
                orderList.add(orderSO);
            }
        }
        if(!orderList.isEmpty()) {
            update orderList;
        }
    }
    
    /* Update related Order with  total count of asset tied to the order
	 * Method Name: updateAssetCountOnOrder
	 * Added By - Vihari
	 * User Story: Alpha-530
     **/
    public static void updateAssetCountOnOrder(List<Asset> newItems){
        Map<Id, List<Asset>> orderToAssetMap = new Map<Id, List<Asset>>();
        List<Order> orderListToUpdate = new List<Order>();
        
        for(Asset a: newItems){
            if(!orderToAssetMap.containsKey(a.RFO_FileOrder__c))orderToAssetMap.put(a.RFO_FileOrder__c,new List<Asset>{a});
            
            else orderToAssetMap.get(a.RFO_FileOrder__c).add(a);
        }
        
        List<AggregateResult> AggregateResultList = [Select RFO_FileOrder__c,Count(id)totalAssets from Asset where RFO_FileOrder__c IN :orderToAssetMap.keySet() group by RFO_FileOrder__c]; 
		
        if(AggregateResultList != null && AggregateResultList.size() > 0){ 
            for(AggregateResult aggr:AggregateResultList){ 
            	Order o = new Order(id=(Id)aggr.get('RFO_FileOrder__c'), Total_Asset_Count__c=(Decimal)aggr.get('totalAssets'));
                orderListToUpdate.add(o);
                orderToAssetMap.remove((Id)aggr.get('RFO_FileOrder__c'));
            }
       
        }
        
        if(orderToAssetMap.keySet().size()>0){
            for(Id oId: orderToAssetMap.keySet()){
                Order o = new Order(id = oId, Total_Asset_Count__c = 0);
                orderListToUpdate.add(o);
            }
        }
        if(orderListToUpdate.size()>0){
            try{
            	Database.update(orderListToUpdate);
            }catch(Exception e){
                throw e;
            }
        }
        
    }
}