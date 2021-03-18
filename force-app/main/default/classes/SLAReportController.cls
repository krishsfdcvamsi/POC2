public class SLAReportController {
   
	@auraEnabled
    Public Static List<ProcessInstanceNode> getApprovalHistory(String QuoteId){
        List<ProcessInstanceNode> stepsInfo = New List<ProcessInstanceNode>();
    	SBQQ__Quote__c objQuote = [SELECT CPQ_Quote__c,CPQ_Quote__r.Name FROM SBQQ__Quote__c WHERE Id=:QuoteId LIMIT 1];
       	List<ProcessInstance> lstProcessInstance = [SELECT Id FROM ProcessInstance WHERE 
                                                    TargetObjectId=:objQuote.CPQ_Quote__c];
        if(!lstProcessInstance.isEmpty()){
            
            for(ProcessInstanceNode objNode :[SELECT Id, 
                                             	NodeStatus, 
												ProcessNodeName,
                                            	createdDate,
                                            	CompletedDate,
                                              	LastActorId,
												ProcessInstanceId,
                                              	LastActor.Name,
												ElapsedTimeInDays,
                                                ElapsedTimeInHours
                                            	FROM ProcessInstanceNode 
                                           		WHERE ProcessInstanceId IN :lstProcessInstance 
                                              	ORDER BY CompletedDate DESC]){
                     	stepsInfo.add(objNode);
                
            }
            system.debug('stepsInfo>>>>>>>'+stepsInfo);
        
        }
        
        return stepsInfo;
	}
}