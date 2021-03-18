public class QuoteContainerController {
	@auraEnabled
    Public Static String getQuoteInfo(String QuoteId){
         String cpqQuoteId	='';
        try{
            cpqQuoteId  			= [SELECT CPQ_Quote__c FROM SBQQ__Quote__c WHERE Id=:QuoteId].CPQ_Quote__c;
        }catch(exception e){
           system.debug(e.getMessage());
           system.debug(e.getStackTraceString());
        }
        
        return cpqQuoteId;
       
    }
    @auraEnabled
    Public Static String getReportInfo(){
         String ReportId	='';
        try{
           // ReportId 				= [Select id From Report WHERE Name ='Quote Status Report-CPQ Records' LIMIT 1].Id;
        	//Equipment Availability Report
        	ReportId 				= [Select id From Report WHERE Name ='Equipment Availability Report' LIMIT 1].Id;
        }catch(exception e){
           system.debug(e.getMessage());
           system.debug(e.getStackTraceString());
        }
        
        return ReportId;
       
    }
}