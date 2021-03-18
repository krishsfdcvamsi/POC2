public class RFO_ExternalObjectFilterController {
    @TestVisible private static list<RFO_AssetExternal__x> mockedAssetlist = new List<RFO_AssetExternal__x>();
@AuraEnabled
    public static List<RFO_AssetExternal__x> getAssetExternal(string AID) {
        List<RFO_AssetExternal__x> AssetExt = new List<RFO_AssetExternal__x>();
         Asset AssetRec =new asset();
         AssetRec=[SELECT Id, Name, RFO_TASId__c FROM Asset where id=:AID];
        
        if(!Test.isRunningTest()){       
         AssetExt=[SELECT Id, CreatedDate__c,Name__c, Price__c, Product2Id__c, PurchaseDate__c,Quantity__c, RFO_ActualCapacity__c, Assigned_To__c, RFO_CarMark__c, RFO_CarNumber__c, RFO_CarOwner__c, RFO_CarSubStatus__c, RFO_CarType__c, 
                 RFO_Committed_To__c, RFO_CurrentCommodity__c, RFO_DOTClass__c, RFO_DesignatedCapacity__c, 
                 RFO_File__c, RFO_GRL__c, RFO_LightWeight__c, RFO_LocationStatus__c, RFO_Manufacturer__c, RFO_MfgPlant__c, RFO_ModelDescription__c, RFO_Previous_Commodity__c, RFO_RANumber__c, RFO_RAType__c, RFO_ShipDate__c, RFO_StencilSpec__c, RFO_TASId__c, 
                 RFO_TRNumber__c, RFO_TRType__c, SerialNumber__c, Status__c, UsageEndDate__c, RFO_CarCondition__c, RFO_Destination__c, RFO_StatusDate__c, 
                 RFO_EventStation__c, RFO_LinktoEngineeringSpec__c, RFO_PreviousCommodityStartDate__c, RFO_CurrentCommodityStartDate__c, RFO_DateBuilt__c,
                 RFO_LE__c, RFO_Origin__c, RFO_PortfolioStatus__c FROM RFO_AssetExternal__x where RFO_TASId__c=:AssetRec.RFO_TASId__c];
        //Add isAccessible() check
        }
        else{
          AssetExt.addAll(mockedAssetlist);  
        }
        return AssetExt;
    }
    
    @AuraEnabled
    public static RFO_InvoiceExternal__x getInvoiceLink(string AID) {
                RFO_InvoiceExternal__x inv=new RFO_InvoiceExternal__x();

         if(!Test.isRunningTest()){
        inv=[select Id,RFO_LinktoInvoice__c from RFO_InvoiceExternal__x where Id=:AID];
         }
        return inv;
    }
}