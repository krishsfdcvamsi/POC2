/* Class Name : FleetMileageDataCleanupBatch
 * Description : Batch Class to delete old Fleet Mileage Data 
 * Created By : Vihari Vanga
 * Created On : 1/21/21
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 1/21/21                    Vihari Vanga                       EPSI-653
 */
global class FleetMileageDataCleanupBatch implements 
	Database.Batchable<sObject>,Database.stateful{
	
     private Integer numOfMonths;
     public Integer failedRecords = 0;
     private Integer totalRecords = 0;
     private List<Fleet_Mileage_Cleanup_Batch_Setting__mdt> settings = new List<Fleet_Mileage_Cleanup_Batch_Setting__mdt>();
     
     public FleetMileageDataCleanupBatch(){
     	settings = [Select Number_of_Months__c,Notification_Recipient_Email__c from Fleet_Mileage_Cleanup_Batch_Setting__mdt LIMIT 1];
        numOfMonths =  settings.size()>0 && settings[0].Number_of_Months__c!=null?Integer.valueOf(settings[0].Number_of_Months__c):-18;// Default to -18 months if no value found
            
     }
        
     global Database.QueryLocator start(Database.BatchableContext bc){
         Date expiryDate =  System.today().addMonths(numOfMonths);
        // collect the batches of records or objects to be passed to execute        
        return Database.getQueryLocator(            
            'SELECT Id From Fleet_Mileage_Data__c where Earned_Date__c<:expiryDate');
    }
        
    global void execute(Database.BatchableContext bc,  List<Fleet_Mileage_Data__c> records){
        // process each batch of records
            if(records.size()>0){
                totalRecords = totalRecords+records.size();
                List<Database.DeleteResult> drList = Database.delete(records,false);
                // Iterate through each returned result
				for(Database.DeleteResult dr : drList) {
    
        			// Operation failed, adder errors count to the variable            
        			if(dr.getErrors().size()>0) failedRecords = failedRecords+1;
           			
        		}
    		}
    }
       
        
    global void finish(Database.BatchableContext bc){
        if(failedRecords>0 && settings.size()>0 && settings[0].Notification_Recipient_Email__c!=null){
            try{
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                List<String> recipients = settings[0].Notification_Recipient_Email__c.split(',');
                OrgWideEmailAddress owea = EmailService.getOrdWideEmailAddress(System.Label.noreply_trin_net);
                message.toAddresses = new List<String>(recipients);
                message.subject = 'Fleet Mileage Data Cleanup Job Failure';
                
                String body = 'Processing of Fleet Mileage Data Cleanup has failed.';
                body +='<BR> Total Records - '+totalRecords;
                body +='<BR> Failed Records - '+failedRecords;
                
                message.setHtmlBody(body);
                message.setOrgWideEmailAddressId(owea?.Id);

                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                if(!Test.isRunningTest())// Do not send email if running from test class
                    Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(messages);
            }catch(Exception e){
                if(!RFO_Utility.runningInASandbox() || Test.isRunningTest())throw e;
            }
        }
    }
}