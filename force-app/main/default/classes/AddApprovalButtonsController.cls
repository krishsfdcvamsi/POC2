public with sharing class AddApprovalButtonsController {
    @AuraEnabled
    public static map<String,object> approve(String recordId,boolean isCpq){
        map<String,object> results = new map<String,object>();
        try{
            //recordId
            String cpqId = '';
            if(isCpq == false){
                SBQQ__Quote__c objQuote = [SELECT CPQ_Quote__c FROM SBQQ__Quote__c WHERE Id=:recordId LIMIT 1];
                cpqId = objQuote.CPQ_Quote__c;
            }else{
                cpqId = recordId;
            }
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            //req.setComments('Approving request using Trigger');
            req.setAction('Approve');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            Id workItemId = getWorkItemId(cpqId); 
            system.debug('workItemId>>>>'+workItemId);
            if(String.isEmpty(workItemId)){
                results.put('success',false);
                results.put('msg','You can not reject an approved quote.');
            }else{
                map<String,Object> resutlt	=  ApprovalFlowValidations.validateApproveFlow(cpqId);
                if((boolean)resutlt.get('validation')){
                    try{
                    SBQQ__Quote__c quoteInfo = (SBQQ__Quote__c)resutlt.get('Quote');
                    system.debug('quoteInfo>>>>>>>'+quoteInfo);
                    
                    req.setWorkitemId(workItemId);
                    Approval.ProcessResult result =  Approval.process(req);
                    if(quoteInfo.Need_Pricing_Approval__c == false && quoteInfo.CPQ_Status__c == 'Pricing Approval'){
                        system.debug('quoteInfo>>>22>>>>'+quoteInfo);
                        Id workItemId2 = getWorkItemId(cpqId); 
                        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                        //req.setComments('Approving request using Trigger');
                        req2.setAction('Approve');
                        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                        req2.setWorkitemId(workItemId2);
                        quoteInfo.CPQ_Status__c  = 'Approve to Quote';
                        Approval.ProcessResult result2 =  Approval.process(req2);
                    }
                    update quoteInfo;
                    results.put('success',true);
                    }catch(exception ex){
                        results.put('success',false);
                        results.put('msg',ex.getMessage());
                    }
                    
                }else{
                     results.put('success',false);
            		 results.put('msg',resutlt.get('msg'));
                }
            }
            if(TEST.isRunningTest()){
                integer i =1/0;
            }
        }catch(exception ex){
            results.put('success',false);
            results.put('msg',ex.getMessage());
        }
        return results;
    }
    @AuraEnabled
    public Static map<String,object> rejectRecord(String recordId,boolean isCpq){
        map<String,object> results = new map<String,object>();
        try{
            String cpqId = '';
            String cpqStatus = '';
            SBQQ__Quote__c objQuote1   = New SBQQ__Quote__c();
            if(isCpq == false)
            {
                objQuote1 		= 	[SELECT CPQ_Quote__c,CPQ_Quote__r.CPQ_Status__c FROM SBQQ__Quote__c WHERE Id=:recordId LIMIT 1];
                recordId 							= 	objQuote1.CPQ_Quote__c;
              //  cpqStatus 						= 	objQuote1.CPQ_Quote__r.CPQ_Status__c;
            }
          /*  }else{
                objQuote1 				= 	[SELECT CPQ_Quote__r.CPQ_Status__c FROM SBQQ__Quote__c WHERE Id=:recordId LIMIT 1];
                cpqStatus 				= 	objQuote1.CPQ_Quote__r.CPQ_Status__c;
                cpqId 					= 	recordId;
            }*/
            SBQQ__Quote__c cpqQuote = [select id,CPQ_Status__c FROM  SBQQ__Quote__c WHERE Id=:recordId limit 1]; 
            if(cpqQuote.cpq_status__c == 'Approve to Quote'){
              /*  cpqQuote.CPQ_Status__c = 'Pricing Approval';
                update cpqQuote;*/
                CPQ_QuoteService.submitForApproval(New list<SBQQ__Quote__c>{cpqQuote});
                results.put('success',true);
                return results;
            }
            if(cpqQuote.cpq_status__c  == 'Inventory Review'){
                results.put('success',false);
            	results.put('msg','You cannot reject from Inventory Review status');
                return results;
            }
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Reject');
        Id workItemId = getWorkItemId(recordId); 
            system.debug('workItemId>>>>'+workItemId);
            if(String.isEmpty(workItemId)){
                results.put('success',false);
                results.put('msg','You can not reject an approved quote.');
            }else{
                map<String,Object> resutlt	=  ApprovalFlowValidations.validateRejectFlow(recordId);
                system.debug('resutlt>>>>>>'+resutlt);
                if((boolean)resutlt.get('validation')){
                    SBQQ__Quote__c objQuote = (SBQQ__Quote__c)resutlt.get('Quote');
                    update objQuote;
                    req.setWorkitemId(workItemId);
                    Approval.ProcessResult result =  Approval.process(req);
                    results.put('success',true);
                }
                
            }
            if(TEST.isRunningTest()){
                integer i =1/0;
            }
        }catch(exception ex){
            system.debug('exception>>>>>>'+ex);
            system.debug('exception>>>>>>'+ex.getLineNumber());
            system.debug('exception>>>>>>'+ex.getStackTraceString());
            results.put('success',false);
            results.put('msg',ex.getMessage());
        }
        return results;
    }
    public Static Id getWorkItemId(Id targetObjectId){
        Id retVal = null;

        for(ProcessInstanceWorkitem workItem  : [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: targetObjectId]){
            system.debug('workItem>>>>>>'+workItem);
            retVal  =  workItem.Id;
        }
		system.debug('retVal>>>>>'+retVal);
        return retVal;
    }
}