/* Class for fetching external data from GVP Object */

public inherited sharing class CDX_RetrieveGVPExternalData
{
 // Method to  retrieve data from external GVP object.
 
@AuraEnabled(Cacheable = true)
    
public static List< RFO_GVP__x> getGVPExternalData(String asId)
{
 List<  RFO_GVP__x> GVPExternalList= [select Id,ExternalId,DisplayUrl,RFO_AssetID__c,RFO_Carrier__c,RFO_Destination__c,RFO_EventStation__c,RFO_LE__c,RFO_Origin__c,RFO_Status__c,RFO_StatusDate__c,RFO_STCC__c,RFO_STCCDescription__c,RFO_TrainID__c from RFO_GVP__x where RFO_AssetID__c=:asId order by RFO_StatusDate__c desc Limit 1];
 
 return GVPExternalList ;  
}
    
}