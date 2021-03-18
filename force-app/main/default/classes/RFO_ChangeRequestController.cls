/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 19 Dec 2019
* @Description :This Controller class is to check whether Change Request Refresh Date is 
* 				greater than any of line items Material Cost Date.
**/
public class RFO_ChangeRequestController {
    @AuraEnabled(cacheable=true)
    public static String showWarningMessage(String caseId)
    {
        List<RFO_ChangeRequestLineItem__c> changeReqlineItemList = new List<RFO_ChangeRequestLineItem__c>();
        Integer count=0;
        String Message ='';
        Case caseRec = [Select Id, Recordtype.DeveloperName, RFO_ChangeRequestRefreshDate__c
                       from Case where Id =: caseId limit 1];
        if(String.isNotBlank(String.valueOf(caseRec.RFO_ChangeRequestRefreshDate__c))){
            changeReqlineItemList = [Select Id, RFO_MaterialsCostExpirationDate__c, Name 
                                     from RFO_ChangeRequestLineItem__c 
                                     where (RFO_ChangeRequestID__c =:caseRec.Id and 
                                            Recordtype.DeveloperName='RFO_NewCarChangeRequestLineItem')];
        	if(!changeReqlineItemList.isEmpty()){
                for(RFO_ChangeRequestLineItem__c changeReqlineItem : changeReqlineItemList){
                    if(String.isNotBlank(String.valueOf(changeReqlineItem.RFO_MaterialsCostExpirationDate__c)) && 
                       changeReqlineItem.RFO_MaterialsCostExpirationDate__c < caseRec.RFO_ChangeRequestRefreshDate__c)
                    {
                        count = count+1;
                        if(count>1){
                            Message = 'Multiple Change Request Line Items has Material Cost Expiration Date which is less than the Change Request Refresh Date.';
                        }
                        else if(count==1){
                        	Message = changeReqlineItem.Name+' has Material Cost Expiration Date which is less than the Change Request Refresh Date.';
                        }
                    }
                }
            }
        }
        return Message;
    }
}