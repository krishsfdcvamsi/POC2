/***
* Class Name: RFO_ChangeOrderPdf_Controller  
***/
public with sharing class RFO_ChangeOrderPdf_Controller{
/***
* Constructor with param
***/
    public RFO_ChangeOrderPdf_Controller(ApexPages.StandardController controller) {
    }
    
    public List<RFO_ChangeOrder__c> RecordsCOList {get; set;}
    public List<RFO_ChangeOrderLineItem__c> COLI_List {get;set;}
/***
* Constructor 
***/
    public RFO_ChangeOrderPdf_Controller(){
        RecordsCOList = [select RFO_AccountName__c,RFO_ChangeOrderLetter__c, RFO_ERPMfgCustomerNumber__c,RFO_IssuedBy__r.Name,RFO_AssetFile__c,
                RFO_CurrentUnitPrice__c,RFO_ChangeDueto__c,RFO_OrderID__c,RFO_TotalChangeAmount__c,RFO_TotalChangeCost__c,RFO_TotalChangeMargin__c 
                from RFO_ChangeOrder__c Limit 49999];
         COLI_List = [select RFO_Date__c,RFO_ChangeDetailMargin__c,RFO_ChangeDetailCost__c,RFO_TotalChangeDetailAmount__c ,RFO_ChangeOrderLineItemComments__c
                      from RFO_ChangeOrderLineItem__c Limit 49999];
    }
}