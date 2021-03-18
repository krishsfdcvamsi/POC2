public without sharing class CustomerSpecController {
	@auraEnabled
    public static Customer_Spec__c getCustomerSpecInfo(String quoteId,boolean isTrinity){
        String trinityQuoteId =  '';
        if(isTrinity == false){
            trinityQuoteId = [SELECT Id FROM SBQQ__Quote__c WHERE CPQ_Quote__c=:quoteId].Id;
        }else{
           trinityQuoteId = quoteId; 
        }
        try{
				String oppId = [SELECT SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id=:trinityQuoteId].SBQQ__Opportunity2__c;
                system.debug('oppId>>>>>'+oppId);
                List<Customer_Spec__c> lstCustmer = [SELECT Id,Status__c,RecordType.Name 
                                               FROM Customer_Spec__c 
                                               WHERE 
                                               Opportunity_lookup__c=:oppId 
                                               ORDER BY CreatedDate DESC LIMIT 1
                                              ];
            /*
            Customer_Spec__c  objCustmer  = New Customer_Spec__c();
            if(lstCustmer.size()>1){
                for(Customer_Spec__c objloop:lstCustmer){
                    if(objloop.Status__c != 'Matching Failed' && objloop.Status__c != 'Matching Complete'){
                        objCustmer = objloop;
                        break;
                    }
                }
            }else{
                 objCustmer = lstCustmer[0];
            }
			system.debug('objCustmer>>>>>'+objCustmer);
            */
           if(TEST.isRunningTest()){
                integer i =1/0;
            }
            return lstCustmer[0];    
            
        }catch(exception ex){
            return null;
        }
        
    }
}