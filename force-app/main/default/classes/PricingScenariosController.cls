public class PricingScenariosController {
	@AuraEnabled
    public static List<Object> getallRecords(String quoteId){
        system.debug('quoteId>>>>>'+quoteId);
        List<Object> lstObjects = New List<Object>();
        for(SBQQ__QuoteLine__c objSBQQuoteLine : [SELECT 

                                                    Name,
                                                  	SBQQ__Description__c,
                                                  	RFO_PricingClassification__c,
                                            		SBQQ__Quantity__c,

                                            		RFO_LeaseQty__c,
                                                  	SBQQ__Product__c,
                                            		SBQQ__Product__r.Name,
                                                  	RFO_LeaseRate__c,

                                                    RFO_DirSaleQty__c,
                                            		RFO_LeaseType__c,
                                            		RFO_LeaseTerm__c,
                                                    SBQQ__ListPrice__c,
                                                    SBQQ__CustomerTotal__c,
                                                    SBQQ__NetTotal__c,
                                                    RFO_ROE__c,
                                                    RFO_IRR__c,
                                                    SBQQ__Group__c,
                                                    SBQQ__Group__r.Name,
                                                  	Net_Present_Value__c,
                                                  	Return__c

                                            		FROM SBQQ__QuoteLine__c 
                                          			WHERE SBQQ__Quote__c =:quoteId
                                         ]){

                        Map<String,object> objQuoteMap = new Map<String, Object> {
                            'Id'=> objSBQQuoteLine.Id,
                            'QuoteLineLink'=>'/'+objSBQQuoteLine.Id,

                            'LineName' 					=>  objSBQQuoteLine.Name,
                            'LineNameLink' 				=>  '/'+objSBQQuoteLine.Id,
                            'UnitPrice'					=>  objSBQQuoteLine.RFO_DirSaleQty__c,
                            'Group'						=>  objSBQQuoteLine.SBQQ__Group__r.Name,
                            'GroupLink'					=>  objSBQQuoteLine.SBQQ__Group__c,
                            'ListUnitPrice'				=>	objSBQQuoteLine.SBQQ__ListPrice__c, 
                            'CustomerTotal'				=>	objSBQQuoteLine.SBQQ__CustomerTotal__c,
                            'NetTotal' 					=>	objSBQQuoteLine.SBQQ__NetTotal__c,
                            'ROE'						=>	objSBQQuoteLine.RFO_ROE__c,
                            'IRR'						=>	objSBQQuoteLine.RFO_IRR__c,

                            'RFO_Description'=>   objSBQQuoteLine.SBQQ__Description__c,
                            'RFO_PricingClassification'=>  objSBQQuoteLine.RFO_PricingClassification__c,
                            'RFO_Quantity'  => objSBQQuoteLine.RFO_LeaseQty__c,
                            'PRODUCT'=>objSBQQuoteLine.SBQQ__Product__r.Name,
                            'PRODUCT_Id'=>'/'+objSBQQuoteLine.SBQQ__Product__c,   
                            'RFO_TotalLeaseTerm' => objSBQQuoteLine.RFO_LeaseTerm__c,
                            'RFO_LeaseType' => objSBQQuoteLine.RFO_LeaseType__c,
                            'RFO_LeaseRate' => objSBQQuoteLine.RFO_LeaseRate__c,

                                'Quantity' 			=> 	objSBQQuoteLine.RFO_LeaseQty__c,
                                'NPV' 				=> 	objSBQQuoteLine.Net_Present_Value__c,
                                'Return' 			=> 	objSBQQuoteLine.Return__c,

                                'Edit'=>false
                            //'Contact_Status' => objSBQQuote.Contact_Status__c,
                            //'actionDisabled' => false,
                            //'actionLabel'=>''   
                    };    
                        system.debug('objQuoteMap>>>>>>'+objQuoteMap);
                    lstObjects.add(objQuoteMap);

        }
        return lstObjects;
    }
    @AuraEnabled

    public static void deleteQuoteLine(Id quoteLineId){
        SBQQ__QuoteLine__c objQuoteLine	= New SBQQ__QuoteLine__c();
        objQuoteLine.id = quoteLineId;
        Delete objQuoteLine;

    }
}