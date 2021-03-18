/* Class Name : OrderDefinedNotificationHandler
 * Description : Class to handle notiication when order is defined
 * Created By : Vihari Vanga
 * Created On : 9/22/20
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 9/22/20                    Vihari Vanga                       ALPHA - 738 - Send Email Notification
 */
public with sharing class OrderDefinedNotificationHandler {
    
    /* This is a invocable Method to send Email Notification to the Recipients passed
     * @params inputs - List<Input> where Input is a wrapper class with List<recipientsIds> and String orderId
     */
    
    @InvocableMethod(label='Send Order Defined Email' description='Sends Order Defined Emails to the passed Recipients list')
    public static void sendEmailNotification(List<Input> inputs){
        Input inp = inputs[0];
        // Get the Order by passing Order Id
        Order ord = OrderService.getOrder(inp.orderId, new List<String>{'Id', 'Name', 'OrderNumber', 'AccountId', 'Account.RecordType.Name', 'Account_Name_Text__c', 'RFO_LineNumber__c', 'RFO_SellQuantity__c','RFO_CarType__c','RFO_CommodityName__c','RFO_File__c', 'RFO_Product__r.Name','RFO_Quantity__c','Type'});
        
        //Get Email Template
        List<EmailTemplate> lstEmailTemplates = EmailService.getEmailTemplates('RFO_New_Car_Order_Defined_Email_Template',new List<String>{'Id', 'HTMLValue', 'Subject', 'DeveloperName'});
        
        //Get OrdWideEmailAddress
        OrgWideEmailAddress owea = EmailService.getOrdWideEmailAddress(System.Label.noreply_trin_net);
        if(ord!=null && lstEmailTemplates.size()>0){
                        
            Id notifyCDMId = lstEmailTemplates[0].Id;
            
            String emailTemplateHTMLMain = lstEmailTemplates[0].HTMLValue;
            
            System.debug('Order Returned'+ord);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String orderPageUrl = URL.getSalesforceBaseUrl().toExternalForm() ;
            
            String orderEmailTempMain = emailTemplateHTMLMain;
            String orderEmailTempMain_customer = orderEmailTempMain.replace('{ORDER_ACCOUNT}',ord.Account_Name_Text__c!=null?ord.Account_Name_Text__c:'');
            String orderEmailTempMain_orderNbr = orderEmailTempMain_customer.replace('{ORDER_NUMBER}',ord.OrderNumber!=null?ord.OrderNumber:'');
            String orderEmailTempMain_file = orderEmailTempMain_orderNbr.replace('{ORDER_FILE}',ord.RFO_File__c!=null?ord.RFO_File__c:'');
            String orderEmailTempMain_plant = orderEmailTempMain_file.replace('{ORDER_CURRENT_PLANT}',' '+asset.RFO_CurrentPlant__r.Name!=null?asset.RFO_CurrentPlant__r.Name+' / '+ord.RFO_LineNumber__c:'');
            String orderEmailTempMain_carType = orderEmailTempMain_plant.replace('{ORDER_CAR}',ord.RFO_Product__r.Name!=null?ord.RFO_Product__r.Name:'');
            String orderEmailTempMain_quantity = orderEmailTempMain_carType.replace('{ORDER_QUANTITY}',ord.RFO_Quantity__c!=null?String.valueOf(ord.RFO_Quantity__c):'');
            String orderEmailTempMain_orderType = orderEmailTempMain_quantity.replace('{ORDER_TYPE}',ord.Type!=null?ord.Type:'');
            String orderEmailTempMain_orderLink = orderEmailTempMain_orderType.replace('{ORDER_LINK_URL}','Link: '+orderPageUrl+'/'+ord.Id);
            mail.setHtmlBody(orderEmailTempMain_orderLink);
            mail.setSaveAsActivity(false);
            if ( owea != null ) {
                mail.setOrgWideEmailAddressId(owea.Id);
            }
            mail.setSubject('Sales Order Notification '+ ord.RFO_File__c +' '+ord.Account_Name_Text__c);
            mail.setToAddresses(inp.recipientIds);
            mail.setWhatId(ord.id); // merge field
            system.debug(mail.getHtmlBody());
            try{
                if(!Test.isRunningTest())// Do not send email if running from test class
                Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new List<messaging.singleemailmessage>{mail});
                system.debug('Mail Sent success');
            }catch(Exception e){

                if(!RFO_Utility.runningInASandbox())// Added by Vihari V ENV-18 

                throw e;
            }
        }
    }
    
    /* Wrapper Class */
    public class Input {
        @InvocableVariable(label='Email Recipients' description='List of Email Addresses who should recieve notification' required=true)
        public List<String> recipientIds;
        @InvocableVariable(label='Order Id' description='Id of the order triggering the email' required=true)
        public Id orderId;
        
  }




}