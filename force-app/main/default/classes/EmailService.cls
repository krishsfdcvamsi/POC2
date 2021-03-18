/* Class Name : EmailService
 * Description : Service Class for all email related services 
 * Created By : Vihari Vanga
 * Created On : 9/23/20
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 9/23/20                    Vihari Vanga                       ALPHA - 738
 * 10/20/20            		  Vihari Vanga              	     ALPHA - 771
 * 11/29/20                   Vihari Vanga                       ALPHA - 1693
 */
public with sharing class EmailService {
  
 
 /* Method to Query Email Templates 
  * @param templateName - developername of the email template record
  * @param fieldAPINames - List of api names of the field to be queried
  * 
  * @retunrs List<EmailTemplate> - list of Email Templates
  */
    public static List<EmailTemplate> getEmailTemplates(String templateName, List<String> fieldAPINames){
        String commaSepratedFields = '';
        if(fieldAPINames!=null){
            for(string fld:fieldAPINames){
                if (String.isBlank(commaSepratedFields)){
                    commaSepratedFields = fld;
                }
                else{
                    commaSepratedFields = commaSepratedFields + ', ' + fld;
                }
            }
        }
            
        String queryString = 'Select ' + commaSepratedFields + ' From EmailTemplate where DeveloperName =:templateName';
    
        List<EmailTemplate> lstEmailTemplates =  Database.query(queryString);
        return lstEmailTemplates;
    }
    
    /* Added by vihari ALPHA - 1693*/
    /* Method to Query Email Templates and return map with key as developername and value as template
  * @param List<templateName> - Set of developername of the email template record
  * @param fieldAPINames - List of api names of the field to be queried
  * 
  * @retunrs Map<String,EmailTemplate> - map of Email Templates with key as developer name and value as template
  */
    public static Map<String,EmailTemplate> getEmailTemplatesMap(Set<String> templateNames, List<String> fieldAPINames){
        String commaSepratedFields = '';
        
        if(fieldAPINames!=null){
            for(string fld:fieldAPINames){
                if (String.isBlank(commaSepratedFields)){
                    commaSepratedFields = fld;
                }
                else{
                    commaSepratedFields = commaSepratedFields + ', ' + fld;
                }
            }
        }
            
        String queryString = 'Select ' + commaSepratedFields + ' From EmailTemplate where DeveloperName IN :templateNames';
    	
        List<EmailTemplate> lstEmailTemplates =  Database.query(queryString);
        Map<String,EmailTemplate> templateMap = new Map<String,EmailTemplate>();
        if(lstEmailTemplates.size()>0){
            for(EmailTemplate et: lstEmailTemplates)templateMap.put(et.DeveloperName, et);
        }
		
        return templateMap;
    }
    
 /* Method to Query OrgwideEmailAddress and return map
  * @param Set<emailAddress> - set of address of the orgwideEmailAddress
  * 
  * @retunrs MAP<String,OrgWideEmailAddress> - org wide email address map with key as address and values as  OrgWideEmailAddress
  */
    public static Map<String,OrgWideEmailAddress> getOrdWideEmailAddresses(Set<String> emailAddress){
        String queryString = 'Select id, Address from OrgWideEmailAddress where Address IN :emailAddress';
         Map<String,OrgWideEmailAddress> owaMap = new  Map<String,OrgWideEmailAddress>();
        for(OrgWideEmailAddress owa: Database.query(queryString)){
            owaMap.put(owa.address, owa);
    	}
        return owaMap;
    }
    /* End ALPHA -1693 */
    
 /* Method to Query OrgwideEmailAddress
  * @param emailAddress - address of the orgwideEmailAddress
  * 
  * @retunrs OrgWideEmailAddress - org wide email address queried
  */
    public static OrgWideEmailAddress getOrdWideEmailAddress(String emailAddress){
        String queryString = 'Select id, Address from OrgWideEmailAddress where Address =:emailAddress LIMIT 1';
        return Database.query(queryString);
    }
    
 
    
 /* Method to send  Email Notification
  * @param inputs - List of instance of Input wrapper
  * 
  */
    @InvocableMethod(label='Send Email Notification' description='Sends Emails to the passed Recipients list')
    public static void sendEmailNotification(List<Input> inputs){
        //Input inp = inputs[0];
        System.debug('Email Inputs'+inputs);
        /* Added by vihari ALPHA - 1693*/
        List<messaging.singleemailmessage> emailList = new List<messaging.singleemailmessage>();
        Set<String> templateNames = new Set<String>();
        Set<String> orgWideEmails = new Set<String>();
        Set<String> userIds = new Set<String>();
        for(Input inp : inputs){
            templateNames.add(inp?.templateName);
            orgWideEmails.add(inp?.senderEmail);
            userIds.addAll(new Set<String>(inp.userIds));
        }
        orgWideEmails.add(System.Label.noreply_trin_net);// Adding Default org wide email address to the set
        Map<String,EmailTemplate> templateMap= getEmailTemplatesMap(templateNames,new List<String>{'Id', 'HTMLValue', 'Subject', 'DeveloperName'});
        Map<String,OrgWideEmailAddress> oweaMap = getOrdWideEmailAddresses(orgWideEmails);
        Map<Id,User> userMap = UserService.getUserMap(new List<String>(userIds));
        try{               
        	for (Input inp : inputs) {
                /* End ALPHA -1693 */
                //Get Email Template
                //Commented by Vihari ALPHA - 1693
                //List<EmailTemplate> lstEmailTemplates = getEmailTemplates(inp.templateName,new List<String>{'Id', 'HTMLValue', 'Subject', 'DeveloperName'});
                EmailTemplate template = templateMap.get(inp.templateName);
    
                //Get OrdWideEmailAddress
                ////Commented by Vihari ALPHA - 1693
                //OrgWideEmailAddress owea = getOrdWideEmailAddress(String.isNotBlank(inp.senderEmail)?inp.senderEmail:System.Label.noreply_trin_net);
                OrgWideEmailAddress owea = oweaMap.get(String.isNotBlank(inp.senderEmail)?inp.senderEmail:System.Label.noreply_trin_net);
                Set<String> recipients = new Set<String>();
    
                for(String u:inp.userIds){
                    if(userMap?.get(u)!=null)recipients.add(userMap.get(u).email);  
                }
    
                if(recipients.size()>0 && template!=null){//Changed by Vihari ALPHA - 1693
                    
    
                    Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(template.Id, null, inp.relatedTo) ;
                    
                    message.setSaveAsActivity(false);
                    if ( owea != null ) {
                        message.setOrgWideEmailAddressId(owea.Id);
                    }
                    message.toAddresses = new List<String>(recipients);
                    emailList.add(message);
                }
			}
        	if(!Test.isRunningTest())// Do not send email if running from test class
            	Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emailList);
        }catch(Exception e){
            System.debug('Error'+e.getMessage()+'**'+e.getStackTraceString());
            if(!RFO_Utility.runningInASandbox() || Test.isRunningTest())
                throw e;
        }
            
        //}
    }
    
     /* Wrapper Class */
    public class Input {
        @InvocableVariable(label='Recipient User List' description='List of User Ids who should recieve notification' required=true)
        public List<String> userIds;
        @InvocableVariable(label='Related To' description='Id of the related to record' required=true)
        public Id relatedTo;
        @InvocableVariable(label='Email Template Developer Name' description='Developer Name of the Email Template' required=true)
        public String templateName;
        @InvocableVariable(label='Sender Email Address' description='Email Address of the Sender')
        public String senderEmail;
        
  	}
}