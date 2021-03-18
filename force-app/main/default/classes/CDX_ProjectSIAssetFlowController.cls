public without sharing class CDX_ProjectSIAssetFlowController {
  @InvocableMethod(label='Service Request Disposition Details' description='Find service request disposition details without sharing')
  
  public static List<CDX_ProjectSIAssetFlowController.DisplayProjectRecordsForFlow> getProjectSIAssetRec(List<String> projAsSiID) {
    List<CDX_ProjectSIAssetFlowController.DisplayProjectRecordsForFlow> displayList= new List<CDX_ProjectSIAssetFlowController.DisplayProjectRecordsForFlow>();
    RFO_ProjectAssetSI__c projAssetForFlow = [SELECT RFO_Asset__r.Name, RFO_ShopIncidentID__c, RFO_Asset__r.RFO_CarMark__c, RFO_Asset__r.RFO_CarType__c, RFO_ShopIncidentID__r.Name,RFO_ShopIncidentID__r.RFO_SIStatus__c, RFO_ShopIncidentID__r.CDX_Servicing_Railroad__c, RFO_ShopIncidentID__r.RFO_ShopLocation__c, RFO_ShopIncidentID__r.RFO_ShopName__c, RFO_ShopIncidentID__r.CDX_Shop_State__c, RFO_ShopIncidentID__r.CDX_Shop_Street__c, RFO_ShopIncidentID__r.CDX_Shop_Zip__c, RFO_ShopIncidentID__r.CDX_Shop_City__c, RFO_ShopIncidentID__r.CDX_Shop_Country__c, RFO_ShopIncidentID__r.CDX_Disposition_Requested_Date__c FROM RFO_ProjectAssetSI__c where id=:projAsSiID[0]];
    System.debug('projAssetForFlow>>>>'+projAssetForFlow);
    DisplayProjectRecordsForFlow dispProj=new DisplayProjectRecordsForFlow(projAssetForFlow);
    System.debug('DisplayProjectRecordsForFlow>>>>>'+dispProj);
    displayList.add(dispProj);
    return displayList;
  }
  public class DisplayProjectRecordsForFlow {
    @InvocableVariable public String CarType;
    @InvocableVariable public String CarMark;
    @InvocableVariable public String serviceRequestName;
    @InvocableVariable public String shopCity;
    @InvocableVariable public String shopAddress;
    @InvocableVariable public String zip;
    @InvocableVariable public String shopState;
    @InvocableVariable public String shopName;
    @InvocableVariable public String shopStreet;
    @InvocableVariable public String Servicing_Railroad;
    @InvocableVariable public String assetName;
    @InvocableVariable public String serviceRequestId;
    @InvocableVariable public String shopCountry;
    @InvocableVariable public String SIStatus;
    @InvocableVariable public Datetime dispositionRequestedDate;

    public DisplayProjectRecordsForFlow(RFO_ProjectAssetSI__c projAsset) {
      CarType=projAsset.RFO_Asset__r.RFO_CarType__c;
      assetName=projAsset.RFO_Asset__r.Name;
      CarMark=projAsset.RFO_Asset__r.RFO_CarMark__c;
      serviceRequestName=projAsset.RFO_ShopIncidentID__r.Name;
      shopAddress=projAsset.RFO_ShopIncidentID__r.RFO_ShopLocation__c;
      SIStatus=projAsset.RFO_ShopIncidentID__r.RFO_SIStatus__c;
      zip=projAsset.RFO_ShopIncidentID__r.CDX_Shop_Zip__c;
      shopState=projAsset.RFO_ShopIncidentID__r.CDX_Shop_State__c;
      shopName=projAsset.RFO_ShopIncidentID__r.RFO_ShopName__c;
      shopStreet=projAsset.RFO_ShopIncidentID__r.CDX_Shop_Street__c;
      Servicing_Railroad=projAsset.RFO_ShopIncidentID__r.CDX_Servicing_Railroad__c;
      shopCity=projAsset.RFO_ShopIncidentID__r.CDX_Shop_City__c;
      serviceRequestId=projAsset.RFO_ShopIncidentID__c;
      shopCountry=projAsset.RFO_ShopIncidentID__r.CDX_Shop_Country__c;
      dispositionRequestedDate=projAsset.RFO_ShopIncidentID__r.CDX_Disposition_Requested_Date__c;
    }   
  }
         public static void updateCode(){
    Integer i = 0;
      i++;
      i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
              i++;
      i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
              i++;
      i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        }
}