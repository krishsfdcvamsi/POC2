public class RFO_OrderController {  
    @AuraEnabled public Order orderRecord {get;set;}
    
    @AuraEnabled 
    public static Order getOrderDetails(String orderId){
        Order ord = [SELECT Id, Name, OrderNumber, ContractId, Type, AccountId, RFO_PriceClassification__c, 
                     RFO_LeaseTerms__c, RFO_LeaseRate__c, RFO_Commodity_lookup__c, RFO_Quantity__c,
                     RFO_ReportingMarks__c, RFO_RunningNumbers__c, RFO_CarType__c
                     FROM Order where Id = :orderId];
        System.debug('ord :'+ord);
        return ord;
    }
    
}