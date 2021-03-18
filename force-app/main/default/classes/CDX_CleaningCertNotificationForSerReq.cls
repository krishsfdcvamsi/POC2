global without sharing  class CDX_CleaningCertNotificationForSerReq implements Database.Batchable <sobject>,Database.Stateful
{
  private  RFO_ShopIncident__c serviceReqToProcess;
    private  Account acToProcess;
     global CDX_CleaningCertNotificationForSerReq(RFO_ShopIncident__c serviceReq)
    {
       serviceReqToProcess=serviceReq;
        acToProcess=new Account();
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
acToProcess=[select id from Account where id=:serviceReqToProcess.RFO_Customer__c];
 
    System.debug('acToProcess>>>>'+acToProcess);
   
 
 return Database.getquerylocator([select id,name,email,CDX_Cleaning_Certificate_Notifications__c FROM Contact where AccountId=:acToProcess.id ]);
       }

global void execute(Database.BatchableContext bc, List < Contact > contList)
{
  // Id  acToEmailId=contList[0].accountId;

 System.debug('acToProcessId>>>>'+acToProcess.Id);
     List<String> emailForNotifications=new List<String>();
      List<Id> contListForNotifications=new List<Id>();
    for(Contact con:contList)
    {
        if(con.CDX_Cleaning_Certificate_Notifications__c==true && (con.email !=null ||con.email.trim()==''))
        {
     
      emailForNotifications.add(con.email);
        } 
        
    }
    List<AccountContactRelation> acConRel=[SELECT AccountId, ContactId, IsDirect, RFO_ContactType__c, Id, IsActive FROM AccountContactRelation where accountId=:acToProcess.Id and IsDirect=false ];
    System.debug('acConRel'+acConRel);
    for(AccountContactRelation acRel:acConRel)
    {
      contListForNotifications.add(acRel.ContactId);  
    }
     System.debug('contListForNotifications'+contListForNotifications);
    
 List<Contact>contListForEmail= [select email  FROM Contact where id in:contListForNotifications];
    
       for(Contact con:contListForEmail)
    {
       
     
      emailForNotifications.add(con.email);
       
        
    }
    
  
  String emailBody='<!DOCTYPE html><html><head><title>Service Request Notification</title></head><body><p>Hello,<br><br>A cleaning certificate is available for Service Request:&nbsp;'+serviceReqToProcess.RFO_SIRef__c+'.<br><br>Shop:&nbsp;'+serviceReqToProcess.RFO_ShopName__c+ '<br>Shop Location:&nbsp;'+serviceReqToProcess.RFO_Location__c+' <br>Account:&nbsp;'+serviceReqToProcess.RFO_Customer__r.name+' <br>Primary Contact:&nbsp;'+serviceReqToProcess.CDX_Primary_Contact__r.name+'<br>Primary Contact Email:&nbsp;'+serviceReqToProcess.CDX_Primary_Contact__r.email+'<br><br>Please navigate to this link to view and download the certificate:&nbsp;'+serviceReqToProcess.CDX_Detail_Link__c+'<br><br>You are receiving this email notification because you were listed as an informed party when this service request was submitted.<br><br>TrinityRail<br>2525 N Stemmons Fwy, Dallas, TX 75207<br>800-277-8844<br>support.trinityrail.com<br>© 2019 TrinityRail<br></p></body></html>';
   
    System.debug('emailForNotifications'+emailForNotifications);
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'noreply@trin.net'];
     mail.setToAddresses(emailForNotifications);
     mail.setSubject('TrinityRail: Cleaning Certificate Available for SR '+serviceReqToProcess.RFO_SIRef__c);
   mail.setOrgWideEmailAddressId(owea.Id);
    mail.setHtmlBody(emailBody);
   
     mails.add(mail);
    Messaging.sendEmail(mails);
      
}

global void finish(database.BatchableContext bc) 
{
    
}
/*public static void sendNotification(RFO_ShopIncident__c serviceReqToProcess)
{
    System.debug('entered in sendNotificTIONmETHOD');
 Account ac=[select id from Account where id=:serviceReqToProcess.RFO_Customer__c];
    System.debug('ac'+ac);
     List<Contact> contList=new List<Contact>();
        List<Contact> contListForNotifications=new List<Contact>();
 contList=[select id,name,email,CDX_SR_Notification_Preference__c FROM Contact where AccountId=:ac.id];
    System.debug('contList'+contList);
  
     List<String> emailForNotifications=new List<String>();
     
    for(Contact con:contList)
    {
        if(con.CDX_SR_Notification_Preference__c==true && (con.email !=null ||con.email.trim()==''))
        {
      contListForNotifications.add(con);  
      emailForNotifications.add(con.email);
        } 
        
    }
  //String emailBody='<!DOCTYPE html><html><head><title>Service Request Notification</title></head><body><p>Hello,<br><br>A cleaning certificate is available for Service Request #'+serviceReqToProcess.RFO_SIRef__c+'.<br><br>Shop:'+serviceReqToProcess.RFO_ShopName__c+ '<br>Shop Location:'+serviceReqToProcess.RFO_Location__c+' <br>Account:'+serviceReqToProcess.RFO_Customer__c+' <br>Primary Contact:'+serviceReqToProcess.CDX_Primary_Contact__c+'<br>Primary Contact Email:'+serviceReqToProcess.CDX_Primary_Contact__r.email+'<br><br>Please navigate to this link to view and download the certificate:'+serviceReqToProcess.CDX_Detail_Link__c+'<br><br>You are receiving this email notification because you were listed as an informed party when this service request was submitted.<br><br>TrinityRail<br>2525 N Stemmons Fwy, Dallas, TX 75207<br>800-631-4420<br>support.trinityrail.com<br>© 2019 TrinityRail<br></p></body></html>';
  System.debug('emailForNotifications'+emailForNotifications);
      EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='CDX_CleaningCertificateTemplate'];
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      for(Contact con: contListForNotifications)
      {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setTemplateID(et.Id); 
    mail.setTargetObjectId(con.id);
   mail.setSaveAsActivity(false);
     mails.add(mail);
}
 Messaging.sendEmail(mails,false);
} */
}