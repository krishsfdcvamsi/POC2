Public without sharing class ApprovalFlowValidations {
    Public static map<string,object>  validateApproveFlow(String QuoteId){
        string validationResult;
        list<Hurdle_Rate__c> hurdleRateList = [select id,Hurdle_Rate__c,Confirmation_Date__c from Hurdle_Rate__c order by Confirmation_Date__c DESC limit 1];
        SBQQ__Quote__c quote = [SELECT CPQ_Status__c,SBQQ__LineItemCount__c,
                                Need_Config_Count__c,Skipp_GapProcess__c,Commercial_Quote__c,Need_Pricing_Approval__c,
                                Commercial_Quote__r.RFO_FleetOpsDeliveryTime__c,
                                Commercial_Quote__r.RFO_PurchaseOptions__c,
                                Commercial_Quote__r.RFO_EarlyTermination__c,
                                Commercial_Quote__r.RFO_NonStandardTerms__c,
                                Commercial_Quote__r.RFO_DeliveryLocation__c,
                                Commercial_Quote__r.RFO_FirstCarShipDays__c,
                                Commercial_Quote__r.RFO_Allowable_Annual_Mileage__c,
                                Commercial_Quote__r.RFO_ExcessMileageFee__c,
                                Commercial_Quote__r.RFO_OpportunityRecordType__c,
                                Commercial_Quote__r.Freight_Charge__c
                                FROM SBQQ__Quote__c WHERE Id=:QuoteId];
        
        system.debug('quote>>>>>>'+quote.Commercial_Quote__r.RFO_EarlyTermination__c);
        system.debug('quote>>>>>>'+quote.Commercial_Quote__r.RFO_NonStandardTerms__c);
        system.debug('quote>>>>>>'+quote.Commercial_Quote__r.RFO_DeliveryLocation__c);
        system.debug('quote>>>>>>'+quote.Commercial_Quote__r.RFO_FirstCarShipDays__c);
        system.debug('quote>>>>>>'+quote.Commercial_Quote__r.Freight_Charge__c);
        system.debug('quote>>>>>>'+quote.Commercial_Quote__r.RFO_Allowable_Annual_Mileage__c);
        system.debug('quote>>>>>>'+quote.Commercial_Quote__r.RFO_ExcessMileageFee__c);
        
        
       Map<string,object> resultMap 	= 	New Map <string,object>();
        // Validations for Inventory Review stage
        if(quote.CPQ_Status__c == 'Inventory Review'){
            if(quote.SBQQ__LineItemCount__c > 0){ 
                //if(quote.Need_Config_Count__c > 0){
                  //  quote.Skipp_GapProcess__c = False;
                    quote.CPQ_Status__c = 'Engineering';
                    resultMap.put('validation',true);
                    resultMap.put('Quote',quote);
                    return resultMap;
               /* }else{
                    quote.CPQ_Status__c = 'Planning';
                    quote.Skipp_GapProcess__c = True;
                    resultMap.put('validation',true);
                    resultMap.put('Quote',quote);
                    return resultMap;                    
                } */
            }
            if(quote.SBQQ__LineItemCount__c == null || quote.SBQQ__LineItemCount__c == 0){
                resultMap.put('validation',false);
                resultMap.put('Quote',quote);
                resultMap.put('msg','CPQ quote need to have Quote lines to Move forward');
            }
        }   
        // Validations for Gap Analysis stage
       if(quote.CPQ_Status__c == 'Engineering'){
                quote.CPQ_Status__c = 'Estimating';
                resultMap.put('validation',true);
                resultMap.put('Quote',quote);
                return resultMap;    
 
       }
       // Validations for Material & Labor Cost stage
       if(quote.CPQ_Status__c == 'Estimating'){
 		   quote.CPQ_Status__c = 'Planning';
           resultMap.put('validation',true);
           resultMap.put('Quote',quote);
           return(resultMap);
       }
       // Validations for Planning & Delivery stage
       if(quote.CPQ_Status__c == 'Planning'){
           if(quote.Commercial_Quote__r.RFO_FleetOpsDeliveryTime__c != null){
				quote.CPQ_Status__c = 'Pricing';
               	resultMap.put('validation',true);
           		resultMap.put('Quote',quote);
           		return(resultMap);               
           }else{
                resultMap.put('validation',false);
           		resultMap.put('msg','Please update Delivery Time on the Quote');
                return(resultMap);               
           }
       }
       // Validations for Pricing & PM Review stage
       if(quote.CPQ_Status__c == 'Pricing'){
           quote.Need_Pricing_Approval__c = False;
            if(!string.isBlank(quote.Commercial_Quote__r.RFO_PurchaseOptions__c)  &&
            	!string.isBlank(quote.Commercial_Quote__r.RFO_EarlyTermination__c) &&
                !string.isBlank(quote.Commercial_Quote__r.RFO_NonStandardTerms__c) &&
                !string.isBlank(quote.Commercial_Quote__r.RFO_DeliveryLocation__c) &&
                !string.isBlank(quote.Commercial_Quote__r.RFO_FirstCarShipDays__c) &&
                !string.isBlank(quote.Commercial_Quote__r.Freight_Charge__c) &&
                quote.Commercial_Quote__r.RFO_Allowable_Annual_Mileage__c > 0 &&
                quote.Commercial_Quote__r.RFO_ExcessMileageFee__c > 0){
                list<SBQQ__QuoteLine__c> pricingScenarios = [select RFO_LeaseQty__c,RFO_LeaseTerm__c,return__c from SBQQ__QuoteLine__c
                                                             where SBQQ__Quote__c = :quote.Commercial_Quote__c AND
                                                             RFO_CustSelected__c = true limit 1];
                
                if(pricingScenarios.size() > 0){
                if ((quote.Commercial_Quote__r.RFO_OpportunityRecordType__c == 'Tank' && pricingScenarios[0].RFO_LeaseQty__c >= 20) ||
                   (quote.Commercial_Quote__r.RFO_OpportunityRecordType__c == 'Freight' && pricingScenarios[0].RFO_LeaseQty__c >= 40) ||
                   (pricingScenarios[0].return__c < hurdleRateList[0].Hurdle_Rate__c) ||
                   (pricingScenarios[0].RFO_LeaseTerm__c >= 60)){
                   	quote.Need_Pricing_Approval__c = True;     
                }}
			    quote.CPQ_Status__c = 'Pricing Approval';
           	    resultMap.put('validation',true);
           		resultMap.put('Quote',quote);
           	    return(resultMap);               
            }else{
                resultMap.put('validation',false);
           		resultMap.put('msg','Required fields missing on the Quote');
                return(resultMap);               
           }
       }
       if(quote.CPQ_Status__c == 'Pricing Approval'){
				quote.CPQ_Status__c = '	Approve to Quote';
           	    resultMap.put('validation',true);
           		resultMap.put('Quote',quote);
           	    return(resultMap);

       }
       return resultMap; 
    }
    Public static map<string,object> validateRejectFlow(String quoteId){
        
        SBQQ__Quote__c quote = [SELECT CPQ_Status__c,Skipp_GapProcess__c,Need_Pricing_Approval__c FROM SBQQ__Quote__c WHERE Id=:quoteId];
    	map<string,object> resultMap = new map<string,object>();
        map<integer,string> values = ApprovalFlowValidations.getStatusOptions();
        integer currentPos = ApprovalFlowValidations.getPositionOfCurrentStatus(quote.CPQ_Status__c,values);
        if(quote.CPQ_Status__c == 'Approve to Quote' && quote.Need_Pricing_Approval__c == True)
           currentPos = currentPos-2;
        if(quote.CPQ_Status__c == 'Inventory Review'){
			resultMap.put('validation',false);
           	resultMap.put('msg','You cannot reject from Inventory Review status');
       		resultMap.put('Quote',quote);
      		return resultMap;            
        }
        else{
        	quote.CPQ_Status__c = values.get(currentPos-1);
       		resultMap.put('validation',true);
       		resultMap.put('Quote',quote);
      		return resultMap;
        }
    }
    @testvisible
    private static Map<integer,String> getStatusOptions()
    {
        Map<integer,String> values= new Map<integer,String>();
        Schema.DescribeFieldResult fieldResult = SBQQ__Quote__c.CPQ_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        integer i=1;
        for( Schema.PicklistEntry pickListVal : ple){
            values.put(i,pickListVal.getValue());
            system.debug(picklistval.getValue());
            i++;
        } 
        return values;
    }
    private static integer getPositionOfCurrentStatus(string status, Map<integer,String> values){
        for(integer pos : values.keyset()){
            if(status==values.get(pos)) return pos;
        }
        return null;
    }

}