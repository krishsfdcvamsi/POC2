/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 19 Dec 2019
* @Description :This Controller class is to check whether Change Request Refresh Date is 
* 				greater than any of line items Material Cost Date.
**/
public class RFO_ChangeRequestLineItemController {
    @AuraEnabled(cacheable=true)
    public static String showCRLIWarningMessage(String crliId)
    {
        List<RFO_ChangeRequestLineItem__c> changeReqlineItemList = new List<RFO_ChangeRequestLineItem__c>();
        String Message;
        RFO_ChangeRequestLineItem__c crliRec = [Select Id,RFO_MaterialsCostExpirationDate__c, Name, Recordtype.DeveloperName, 
                                                RFO_ChangeRequestID__c, RFO_ChangeRequestID__r.RFO_ChangeRequestRefreshDate__c 
                                                from RFO_ChangeRequestLineItem__c 
                                                where Id=:crliId limit 1];
        if(String.isNotBlank(String.valueOf(crliRec.RFO_MaterialsCostExpirationDate__c)) && 
           String.isNotBlank(String.valueOf(crliRec.RFO_ChangeRequestID__r.RFO_ChangeRequestRefreshDate__c)) && 
           crliRec.RFO_MaterialsCostExpirationDate__c<(crliRec.RFO_ChangeRequestID__r.RFO_ChangeRequestRefreshDate__c)){
               Message = crliRec.Name+' has Material Cost Expiration Date which is less than the Change Request Refresh Date';
           }
        return Message;
    }
}