/* Class Name : AssetFileService
 * Description : Service Class for Asset_File__c Object
 * Created By : Vihari Vanga
 * Created On : 9/29/20
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 9/29/20                    Vihari Vanga                       ALPHA - 743
 */
public with sharing class AssetFileService {
    
 /* Method to Query Asset Files Record with related Change Orders
  * @param aIds - Set of Asset File record Ids to be queried
  * 
  * @retunrs List<RFO_Asset_File__c> - List<RFO_Asset_File__c> records queried
  */
    /*public static List<RFO_Asset_File__c> getAssetFilesWithChangeOrder(Set<Id> aIds){
        List<RFO_Asset_File__c> assetFiles = [Select id,RFO_OrdrOriginalUnitPrice__c, (Select id from Change_Orders__r Order By CreatedDate)
                                              from RFO_Asset_File__c where ID IN :aIds];
        return assetFiles;
    }*/  
    //Alpha-678, Haseeb, Returs a map of AssetFile Ids and AssetFiles with Assets
    public static map<id,RFO_Asset_File__c>  getAssetFileWithAssets(List<String> orderIds){
        return (new Map<Id,RFO_Asset_File__c>([Select Id,Name,UMLER_Status_Updated__c,RFO_OrderNumber__r.RFO_FirstShipWeek__c,
                                              (Select id,Name,UMLER_Status__c from Assets__r where UMLER_Status__c = 'Not Sent') from RFO_Asset_File__c 
                                               where RFO_OrderNumber__c in: orderIds]));
        
    }
    public static list<RFO_Asset_File__c> getAssetFileWithAssetsFromAssetFileIds(List<String> assetFileIds){
        return(new list<RFO_Asset_File__c>([Select Id,Name,UMLER_Status_Updated__c,RFO_OrderNumber__r.Id,RFO_OrderNumber__r.RFO_FirstShipWeek__c,
                                            RFO_OrderNumber__r.Trigger_UMLER_Check_Escalation__c, 
                                            (Select id,Name,UMLER_Status__c from Assets__r where UMLER_Status__c = 'Not Sent') from RFO_Asset_File__c where Id in: assetFileIds]));
    }
}