/** 
* @Author      : Accenture  
* @Version     : 1.0
* @Created Date: 21 May 2019
* @Description :
    This Class is Controller Class for 'RFO_NewQuoteLine' VF page.
    Description: This class is used for assigning Recordtype to new 'Quote Line Item' record based on Opportunity record(Parent Record).
    This Code will work only when API Names of Opportunity Record type and Quote Line Item Record type Should be same. 
**/ 
   
public class RFO_NewQuoteLineController{     
    
    public Id quoteId{get;set;}   
    public String recordTypeId {get;set;}   
    
    public RFO_NewQuoteLineController(ApexPages.StandardSetController controller) {
        quoteId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public RFO_NewQuoteLineController(ApexPages.StandardController controller) {    
         quoteId = ApexPages.currentPage().getParameters().get('id');

    }
    
    //Assigning Recordtype to new 'Quote Line Item' record based on Opportunity record Type
    public void quoteLineRecordType(){ 
    
        try
        {
                 SBQQ__Quote__c quo = [SELECT Id,RecordTypeId,SBQQ__Opportunity2__r.RecordTypeId FROM SBQQ__Quote__c WHERE Id =: quoteId LIMIT 1 ];         
            
                //API Names of Opportunity Record type and Quote Line Item Record type Should be same
                String recordTypeName =  Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(quo.SBQQ__Opportunity2__r.RecordTypeId).getDeveloperName();    
              
              if(recordTypeName != null && recordTypeName != ''){
                 Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();            
                     recordTypeId = quoteLineRecordTypeId;
              } 
         } 
         catch(Exception ex)
         {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));                         
         }      
    }   
}