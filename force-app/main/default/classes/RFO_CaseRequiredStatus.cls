/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 8 May 2019
* @Description : Required field of request line item on change of case status
**/
public with sharing class RFO_CaseRequiredStatus {
/**
 * fire validation on case status change
 **/
    public static void errorMessageOnCaseStatus(Map<Id,Case> caseMap) {
        String errorMessage='';
        Map<String,Set<String>> requiredFieldMap = new Map<String,Set<String>>();   
        Map<String,String> errorMessageMap = new Map<String,String>();
        Set<String> temp =  new Set<String>();
        String fieldLabelName;
        Integer count = 0;
        Set<String> fieldAPINameTemp = new Set<String>();
        Map<Id,String> caseIdStatusMap = new Map<Id,String>();
        Map<String,String> changeReqMap = new Map<String,String>();
        //current records id and status of change request 
        for(Case caseRecord : caseMap.values()) {
            if(caseRecord.RFO_NewCarLineItemCount__c==trigger.oldMap.get(caseRecord.Id).get('RFO_NewCarLineItemCount__c')){
               caseIdStatusMap.put(caseRecord.id,caseRecord.status);
            }            
        }
        try{
        for(RFO_ChangeRequestRequiredStatus__mdt request : 
            [Select RFO_Field__c,RFO_RecordTypeName__c,RFO_Active__c,RFO_FieldLabelName__c,RFO_Status__c From RFO_ChangeRequestRequiredStatus__mdt where RFO_Active__c=TRUE Limit 49999]) {
                changeReqMap.put(request.RFO_Field__c,request.RFO_FieldLabelName__c);
                temp = new Set<String>();
                if(requiredFieldMap.containsKey(request.RFO_RecordTypeName__c + request.RFO_Status__c)) {
                    temp = requiredFieldMap.get(request.RFO_RecordTypeName__c + request.RFO_Status__c);
                }
                temp.add(request.RFO_Field__c);
                requiredFieldMap.put(request.RFO_RecordTypeName__c + request.RFO_Status__c,temp);
                fieldAPINameTemp.add(request.RFO_Field__c);
            }
            // Changed by Ramesh added status field RFO_CustomerApproval__c
        String dynamicSOQL = 'Select Name,Recordtype.Name,RFO_ChangeRequestID__c, '; 
        for(String str : fieldAPINameTemp) {
            dynamicSOQL+= RFO_Constant.BLANK_SPACE+str+RFO_Constant.COMMA;
        }
        Set<Id> caseSet = caseMap.keySet();
         dynamicSOQL += ' id from RFO_ChangeRequestLineItem__c where RFO_ChangeRequestID__c in :caseSet';
         String caseCurrentStatus = '';
        List<RFO_ChangeRequestLineItem__c> changeRequestLineItem = Database.query(dynamicSOQL);
            // Changed by Ramesh
            Boolean approvedLineItem = false;
            Boolean RejectedLineItem = false;
        for (RFO_ChangeRequestLineItem__c changeLineItemRecord : changeRequestLineItem) {
            errorMessage = errorMessage!=''?errorMessage.removeEnd(RFO_Constant.COMMA)+RFO_Constant.BLANK_SPACE:'';
            caseCurrentStatus = caseIdStatusMap.get(changeLineItemRecord.RFO_ChangeRequestID__c);
            if(requiredFieldMap.containsKey(changeLineItemRecord.Recordtype.Name + caseCurrentStatus)) {
                count = 0;
                for(String fieldApiName : requiredFieldMap.get(changeLineItemRecord.Recordtype.Name + caseCurrentStatus)) {
                    if(changeLineItemRecord.get(fieldApiName)==null || changeLineItemRecord.get(fieldApiName)=='' )  
                    {
                        if(count>0){
                            errorMessage += RFO_Constant.BLANK_SPACE+changeReqMap.get(fieldApiName)+RFO_Constant.COMMA;
                        }
                        else{
                            errorMessage += 'The list of required fields missed on \n'+changeLineItemRecord.Recordtype.Name+' - '+changeLineItemRecord.Name+' are: \n';
                        	errorMessage += RFO_Constant.BLANK_SPACE+changeReqMap.get(fieldApiName)+RFO_Constant.COMMA;//+String.valueOf(changeReqMap.get(fieldApiName));//
                        }
                        count = count+1;
                        errorMessageMap.put(changeLineItemRecord.RFO_ChangeRequestID__c,errorMessage.removeEnd(RFO_Constant.COMMA)); 
                    }
                    
                }
            }
            
            // Changed by Ramesh Start
            if(changeLineItemRecord.RFO_CustomerApproval__c == 'Approved'){
                approvedLineItem = true;
            }  else if(changeLineItemRecord.RFO_CustomerApproval__c == 'Rejected'){
                RejectedLineItem = true;
            } 
            //  Changed by Ramesh End
            
        }
            system.debug('approvedLineItem'+approvedLineItem);
            system.debug('RejectedLineItem'+RejectedLineItem);
            for (RFO_ChangeRequestLineItem__c changeLineItemRecord : changeRequestLineItem) {
                caseCurrentStatus = caseIdStatusMap.get(changeLineItemRecord.RFO_ChangeRequestID__c);
                if( caseCurrentStatus == 'Change Analysis Approved' && !approvedLineItem){
                    errorMessageMap.put(changeLineItemRecord.RFO_ChangeRequestID__c,'Atleast one Change Request Line Items Should be Approved!'); 
                } 
                if( caseCurrentStatus == 'Change Analysis Rejected' && approvedLineItem ){
                    errorMessageMap.put(changeLineItemRecord.RFO_ChangeRequestID__c,'All Change Request Line Items Should be Rejected!'); 
                }
                if( caseCurrentStatus == 'Change Analysis Approved' || caseCurrentStatus == 'Change Analysis Rejected'){
                    if(changeLineItemRecord.RFO_CustomerApproval__c == null || changeLineItemRecord.RFO_CustomerApproval__c == ''){
                        errorMessageMap.put(changeLineItemRecord.RFO_ChangeRequestID__c,'One of the line items has a null Customer Approval value.'); 
                    } 
                }
            }
            
            
        }Catch(Exception e){
             RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.CASE_OBJECT,
                            RFO_Constant.TRIGER,'RFO_CaseRequiredStatus','errorMessageOnCaseStatus');     
        }
        //validation message here on change request 
        for(Case caseRecord : caseMap.values()) {
            if(errorMessageMap.containsKey(caseRecord.id)){
                caseRecord.addError(errorMessageMap.get(caseRecord.id), false);
            }    
        }
        
    } 
}