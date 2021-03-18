global class RFO_CustomerDisputeEscalationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
    global Database.QueryLocator start(Database.BatchableContext bc){
        Id recordTypeIdCustomerDispute = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_Customer_Disputes').getRecordTypeId();
        return Database.getQueryLocator('Select CaseNumber, Subject, status, CreatedDate, RFO_Resolving_Dispute_Start_Time__c, RFO_Awaiting_on_customer_start_time__c,RFO_Awaiting_on_payment_start_time__c, ownerId, accountId, account.Name,owner.Name from Case where IsClosed=false and recordTypeId=\''+recordTypeIdCustomerDispute+'\'');
    }
    global void execute(Database.BatchableContext bc,  List<Case> caseList){ 
        System.debug('Process started '+caseList.size());
        List<Id> userIds = new List<Id>();
        List<Messaging.SingleEmailMessage> escalationEmails = new List<Messaging.SingleEmailMessage>();
        BusinessHours bh = [SELECT Id, Name FROM BusinessHours WHERE IsDefault=true];
        List<EmailTemplate> lstEmailTemplates =  [SELECT Id, Body, Subject, DeveloperName from EmailTemplate where DeveloperName='Customer_Dispute_Escalation'];    
        String subjectTemplate = lstEmailTemplates[0].Subject;
        String BodyTemplate = lstEmailTemplates[0].Body;
        for(Case c: caseList){
            userIds.add(c.OwnerId);
        }
        List<User> ownerList = [SELECT Id, ManagerId, Manager.Email, Name,profileId, profile.Name FROM User where Id in:userIds];
        Map<id,User> userMap = new Map<id,User>();
        for(User u : ownerList){
            userMap.put(u.Id,u);
        }
        
        for(Case c: caseList){
            system.debug('Entered Case List');
            
            Double resolvingDisputeDays=0.0;
            Double awaitingOnCustomerDays=0.0;
            Double awaitingOnPaymentDays=0.0;
            if(c.status==label.Case_Resolving_Dispute){
                if(c.RFO_Resolving_Dispute_Start_Time__c==null){
                    c.RFO_Resolving_Dispute_Start_Time__c= c.CreatedDate;
                }
                system.debug('Inside If of Resolving Dispute');
                resolvingDisputeDays=calculateBusinessDays(bh,c.RFO_Resolving_Dispute_Start_Time__c, Datetime.now());
                system.debug('resolvingDisputeDays == '+resolvingDisputeDays);
            }
            if(c.status==label.Case_Awaiting_On_Customer){
                awaitingOnCustomerDays=calculateBusinessDays(bh,c.RFO_Awaiting_on_customer_start_time__c, Datetime.now());
            }
            /*
if(c.status==label.Case_Awaiting_On_Payment){
awaitingOnPaymentDays=calculateBusinessDays(bh,c.RFO_Awaiting_on_payment_start_time__c, Datetime.now());
}*/
            String subject = subjectTemplate;
            String body = bodyTemplate;
            User owner = userMap.get(c.OwnerId);
            Messaging.SingleEmailMessage mail = null;
            if(resolvingDisputeDays > 1.0){
                system.debug('About to call getEmail Message method '+c);
                mail = getEmailMessage(c,Integer.valueOf(resolvingDisputeDays), owner, subject, body);
                system.debug('mail has returned');
            }
            if(awaitingOnCustomerDays > 1.0){
                mail = getEmailMessage(c,Integer.valueOf(awaitingOnCustomerDays), owner, subject, body);
            }
            System.debug('## resolvingDisputeDays=='+resolvingDisputeDays+ ' Integer val =='+Integer.valueOf(resolvingDisputeDays));
            System.debug('## awaitingOnCustomerDays=='+awaitingOnCustomerDays+ ' Integer val =='+Integer.valueOf(awaitingOnCustomerDays));
            
            /*
			if(awaitingOnPaymentDays > 1.0){
				mail = getEmailMessage(c,awaitingOnPaymentDays, owner, toAddress, subject, body);
			}*/
            if(mail!=null){
                escalationEmails.add(mail);
            }
        }//for		
        system.debug('### Number of Escalation emails == '+escalationEmails.size());
        if(escalationEmails.size()>0){
            try{
                Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(escalationEmails);
                system.debug('Escalation mails Sent successfully');
            }catch(Exception e){
                system.debug(e);
            }
        }
        /*
Task[] tasks = [SELECT Id, AccountId,ActivityDate,CreatedDate,IsClosed,OwnerId,RFO_Status__c,Status,Subject,IsReassigned__c FROM Task WHERE isclosed=false and IsReassigned__c = false and WhatId in :caseList];
List<Id> taskuserIds = new List<Id>();
for(Task t: tasks){
taskuserIds.add(t.OwnerId);
}
List<User> taskownerList = [SELECT Id, ManagerId, Manager.Email, Name,profileId, profile.Name FROM User where Id in:taskuserIds];
Map<id,User> taskOwnerMap = new Map<id,User>();
for(User u : taskownerList){
taskOwnerMap.put(u.Id,u);
}

List<Task> toUpdateTaskList = new List<Task>();
for (Task t : tasks) {
Double businessDays=calculateBusinessDays(bh,t.createdDate, Datetime.now());
if(businessDays >=2.0){
User u = taskOwnerMap.get(t.ownerId);
t.OwnerId=u.ManagerId;
t.IsReassigned__c=true;
}
}
*/
    }
    
    public static Messaging.SingleEmailMessage getEmailMessage(Case c, Integer businessDays, User owner,String subject,String body){
        List<String> toAddress = new List<String>();
        System.debug(c+' - '+businessDays + ' - ' + owner + ' - '+  subject );
        String toEmail = '';
        String subjectdays = '';
        String subjectcaseNumber=subject.replace('{!Case.CaseNumber}', c.CaseNumber);
        String subjectAccountName = subjectcaseNumber.replace('{!Case.Account}', c.account.name);
        String bodyCaseNumber = body.replace('{!Case.CaseNumber}', c.CaseNumber);
        String ownerName='';
        if(c.owner!=null){
            if(c.owner.Name!=null){
                ownerName = c.owner.Name;
            }
            else{
                ownerName = '';
            }
        }
        else{
            ownerName = '';
        }
        
        String bodyCaseOwnerName = bodyCaseNumber.replace('{!Case.OwnerFullName}', ownerName);
        String bodyNumberDays='';
        if(businessDays == Integer.valueOf(label.Customer_Dispute_first_level_escalation_days)){
            if(owner.ManagerId!=null){
                toEmail = owner.Manager.Email;
                toAddress.add(toEmail);
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            subjectdays = subjectAccountName.replace('<days>', label.Customer_Dispute_first_level_escalation_days);
            mail.setSubject(subjectdays);
            bodyNumberDays = bodyCaseOwnerName.replaceAll('<days>', label.Customer_Dispute_first_level_escalation_days);
            mail.setPlainTextBody(bodyNumberDays);
            if(toAddress.size()>0){
                mail.setToAddresses(toAddress);
                //escalationEmails.add(mail);
                return mail;
            }
        }
        if(businessDays == Integer.valueOf(label.Customer_Dispute_second_level_escalation_days)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            subjectdays = subjectAccountName.replace('<days>', label.Customer_Dispute_second_level_escalation_days);
            mail.setSubject(subjectdays);
            bodyNumberDays = bodyCaseOwnerName.replaceAll('<days>', label.Customer_Dispute_second_level_escalation_days);
            mail.setPlainTextBody(bodyNumberDays);
            if(owner.profile.Name==label.profile_CDM){
                toEmail = label.Customer_Dispute_Third_Level_Approver;
                toAddress.add(toEmail);
            }
            if(owner.profile.Name==label.profile_Accounting){
                toEmail = label.Customer_Dispute_Second_Level_Approver;
                toAddress.add(toEmail);
            }
            if(toAddress.size()>0){
                mail.setToAddresses(toAddress);
                //escalationEmails.add(mail);
                return mail;
                
            }
        }
        if(businessDays == Integer.valueOf(label.Customer_Dispute_third_level_escalation_days)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            subjectdays = subjectAccountName.replace('<days>', label.Customer_Dispute_third_level_escalation_days);
            mail.setSubject(subjectdays);
            bodyNumberDays = bodyCaseOwnerName.replaceAll('<days>', label.Customer_Dispute_third_level_escalation_days);
            mail.setPlainTextBody(bodyNumberDays);
            if(owner.profile.Name==label.profile_Accounting){
                toEmail = label.Customer_Dispute_Third_Level_Approver;
                toAddress.add(toEmail);
            }
            if(toAddress.size()>0){
                mail.setToAddresses(toAddress);
                //escalationEmails.add(mail);
                return mail;
            }   
        }
        system.debug('About to return null');
        return null;
    }
    public static Double calculateBusinessDays(BusinessHours bh, DateTime open, DateTime close){
        Decimal CaseAgeBusinessHours = BusinessHours.diff(bh.Id, open, close)/3600000.0;
        Decimal caseAgeBusinessDays = CaseAgeBusinessHours/8; 
        Double caseAgeBusinessDaysRounded = caseAgeBusinessDays.setScale(2,System.RoundingMode.HALF_UP);
        return caseAgeBusinessDaysRounded;
    }
    global void finish(Database.BatchableContext bc){
        
    }
	    /*public static Double calculateBusinessHours(BusinessHours bh, DateTime open, DateTime close){
Decimal CaseAgeBusinessHours = BusinessHours.diff(bh.Id, open, close)/3600000.0;
Double CaseAgeBusinessHoursRounded = CaseAgeBusinessHours.setScale(2,System.RoundingMode.HALF_UP);
return CaseAgeBusinessHoursRounded;
}*/    
    
}