/************************************************************************************************************************************************** 
 * Class Name : Asset Files Controller
 * Description : Related Asset files with additional fields 
 * Author : Sai Anudeep
 * Created On : 11/17/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/17/20                    Sai Anudeep                       BETA - 193, Related Asset files with additional fields .
      
 **************************************************************************************************************************************************/


public class AssetFilesController {

    
    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssets(Id orderId){
        return [SELECT Id,Name,RFO_ModelDescription__c, RFO_ShopLocation__c, RFO_DOTClass__c, RFO_CarType__c, RFO_FileOrder__r.RFO_CarType__c,
                RFO_FileOrder__r.RFO_CurrentPlant__c,RFO_FileOrder__r.RecordType.Name, RFO_AssetFile__r.RFO_CurrentPlant__r.Name,

                (SELECT Id, Name, Asset_Name__c, Capacity__c,Light_Weight__c,Weight_Gross_Rail_Load_Stencilled__c,
                 DOT_Stencil_Class__c, Build_Date__c,File_Number__c FROM Asset_Mechanical__r WHERE Build_Date__c != null) 
                FROM Asset WHERE RFO_FileOrder__c =: orderId ];

    }
    
    @AuraEnabled(cacheable=true)
    public static List<RFO_Asset_File__c> getAssetFilesByOrderId(Id orderId){
        return [SELECT Id,Name,RFO_FileType__c,RFO_CurrentQuantity__c,RFO_CurrentPlant__c,
                RFO_CurrentPlant__r.Name FROM RFO_Asset_File__c WHERE RFO_OrderNumber__c =: orderId];
    }
    
    @AuraEnabled(cacheable=true)
    public static Order getOrder(Id orderId){
        return [SELECT Id,Name,RecordType.Name FROM Order WHERE Id =: orderId];
    }

}