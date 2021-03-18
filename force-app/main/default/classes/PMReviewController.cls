public class PMReviewController {
    @auraEnabled
    Public Static SBQQ__Quote__c getQuoteInfo(String quoteId){
        SBQQ__Quote__c objQuote = [SELECT RFO_Allowable_Annual_Mileage__c,Pricing_Supervisor_Review_Complete__c,RFO_BenchmarkRate__c,
                                  RFO_ExcessMileageFee__c,
                                  RFO_PricingNotes__c,
                                  RFO_PurchaseOptions__c,
                                  RFO_EarlyTermination__c,
                                  RFO_NonStandardTerms__c,
                                  RFO_EarlyTerminationDate__c,
                                  RFO_ProposalRequired__c,
                                  RFO_LessorLesseeSelector__c,
                                  RFO_TIH_PIH__c,
                                  RFO_ProteinTransport__c,
                                  RFO_CoalTransport__c,
                                  RFO_ProposalAttachments__c,
                                  RFO_LessorEntity__c,RFO_DeliveryLocation__c,RFO_FirstCarShipDays__c 
                                   FROM SBQQ__Quote__c WHERE Id=:quoteId];
        return objQuote;
    }
	@auraEnabled
    Public Static SBQQ__Quote__c getQuotePRoductInfo(String quoteId){
        SBQQ__Quote__c objQuote = [SELECT RFO_Product__c
                                   FROM SBQQ__Quote__c WHERE Id=:quoteId];
        return objQuote;
    }
}