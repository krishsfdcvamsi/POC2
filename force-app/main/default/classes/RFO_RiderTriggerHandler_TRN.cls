public class RFO_RiderTriggerHandler_TRN {  
    
    public static void updateContactId(List<RFO_Rider__c> riderList){
      System.debug('INSIDE updateContactId');
       
      List<Id> accountIds = new List<Id>();
        
        for(RFO_Rider__c rider : riderList){
            if(rider.RFO_Account__c!=null){
            accountIds.add(rider.RFO_Account__c);
            }
            if(rider.RFO_RiderNumberSuffix__c!=null && rider.RFO_RiderNumberSuffix__c =='0'){
                rider.Rider_Name_Ends_Zero__c = 'YES';
            }
            else{
                rider.Rider_Name_Ends_Zero__c = 'NO';
            }
        }
        
        if(accountIds.size()>0){
          List<Account> accounts = [Select Id, (Select Id,FirstName, LastName, RFO_ContactRole__c From Contacts) from Account where Id IN : accountIds];
          for(RFO_Rider__c rider : riderList){
            for(Account acc : accounts){
                  if(acc.Id == rider.RFO_Account__c){
                      system.debug('Contact List ::'+acc.Contacts.size());
                      for(Contact objCon: acc.Contacts){
                      	system.debug('objCon.RFO_ContactRole__c =='+objCon.RFO_ContactRole__c);
                      	if(objCon.RFO_ContactRole__c!=null && objCon.RFO_ContactRole__c.contains('Survey Contact')){
                        	System.debug('Inside contact exists');
                            rider.ContactId__c = objCon.Id;
                            rider.Survey_Contact_Id__c = objCon.Id;
                            System.debug('Inside contact exists '+rider.ContactId__c);
                        }
                    }
                  }
              }
          }
        }
    }
	public static void processSurvey(Map<Id,SObject> mapSObjOld, List<SObject> sObjList){
        System.debug('INSIDE processSurvey');
        Map<Id,RFO_Rider__c> mapRiderOld = (Map<Id,RFO_Rider__c>) mapSObjOld;
        List<RFO_Rider__c> riderList = (List<RFO_Rider__c>) sObjList;

    	List<Id> accountIds = new List<Id>();
        for(RFO_Rider__c rider : riderList){
            if(rider.RFO_Account__c!=null){
        		accountIds.add(rider.RFO_Account__c);
            }
            if(rider.RFO_RiderNumberSuffix__c!=null && rider.RFO_RiderNumberSuffix__c =='0'){
                rider.Rider_Name_Ends_Zero__c = 'YES';
            }
            else{
                rider.Rider_Name_Ends_Zero__c = 'NO';
            }
        }
        Set<String> AccountTeamRoles = new Set<String>{label.Customer_Delivery_Manager};
        if(accountIds.size()>0){
            Map<id,AccountTeamMember> accountTeamMap = new Map<id,AccountTeamMember>();
            List<Account> accounts = [Select Id, (Select Id,FirstName, LastName, Email, RFO_ContactRole__c, Post_Delivery_Time__c From Contacts) from Account where Id IN : accountIds];
            List<AccountTeamMember> accountTeams = [Select AccountId,TeamMemberRole,UserId,user.email FROM AccountTeamMember WHERE AccountId IN:accountIds AND TeamMemberRole IN:AccountTeamRoles];
        	List<EmailTemplate> lstEmailTemplates =  [SELECT Id, Body, Subject, DeveloperName from EmailTemplate where DeveloperName IN ('Survey_Lease_Project_Avg_Begin_Charge', 'Survey_contact_not_exists_in_account_alert') order by DeveloperName];    
            if (lstEmailTemplates.size()<2) { return; } //exit since templates are not available
       		Id notifyCDMId = lstEmailTemplates[0].Id;
            Id surveyTemplateId = lstEmailTemplates[1].Id;
            List<Contact> updateContactList = new List<Contact>();
            OrgWideEmailAddress owea = [select id, Address from OrgWideEmailAddress where Address =:System.Label.noreply_trin_net LIMIT 1];
        	List<Messaging.SingleEmailMessage> surveyMails = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> contactNotExistsMails = new List<Messaging.SingleEmailMessage>();
            
            List<String> escalationEmails = new List<String>();
            escalationEmails.add('alagiri.muthiah@trin.net');
            
            for(AccountTeamMember atm:accountTeams){
                accountTeamMap.put(atm.AccountId,atm);
            }
            
            for(RFO_Rider__c rider : riderList){
        		for(Account acc : accounts){
                	if(acc.Id == rider.RFO_Account__c){
                    	List<String> toEmails =  new List<String>();
                        
                        List<Contact> allSurveyContacts = new List<Contact>();
                        List<Contact> eligibleSurveyContacts = new List<Contact>();
                        system.debug('Inside Rider=Account and Contact List ::'+acc.Contacts.size());
                    	for(Contact objCon: acc.Contacts){
                        	system.debug('objCon.RFO_ContactRole__c =='+objCon.RFO_ContactRole__c);
                			if(objCon.RFO_ContactRole__c!=null && objCon.RFO_ContactRole__c.contains('Survey Contact')){
                    			System.debug('Inside contact exists');
                                allSurveyContacts.add(objCon);
                            	if(objCon.Email!=null){
                                	//RFO_Rider__c oldRider = mapRiderOld.get(rider.Id);
                        			if(rider.Rider_Name_Ends_Zero__c == 'YES' && 
                           				mapRiderOld.get(rider.Id).RFO_RiderAverageBeginDate__c==null &&
                           				rider.RFO_RiderAverageBeginDate__c!=null &&
                           				rider.Survey_Sent_Time__c==null &&
                                   		(objCon.Post_Delivery_Time__c==null ||  
                                         (objCon.Post_Delivery_Time__c!=null && objCon.Post_Delivery_Time__c.Date().daysBetween(system.today()) > 60))
                          			){
                                        system.debug('CONDITION PASSED');
                                        eligibleSurveyContacts.add(objCon);
                                        rider.ContactId__c = objCon.Id;
                            			rider.Survey_Contact_Id__c = objCon.Id;
                                    }
                                }
                                
                                
                            }//role
                		}//contacts
                        //Send Emails to Survey Contacts
                        system.debug('eligibleSurveyContacts size ::'+eligibleSurveyContacts.size());
                        String contactIds = '';
                        for(Contact objCon: eligibleSurveyContacts){
                            contactIds = contactIds + objCon.Id + '||';
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTemplateId(surveyTemplateId);
                            mail.setSaveAsActivity(false);
                            mail.setTargetObjectId(objCon.Id);// should be a contact to get the merge fields in template
            				if ( owea != null ) {
                				mail.setOrgWideEmailAddressId(owea.Id);
            				}
                            toEmails.add('alagiri.muthiah@trin.net');
            				mail.setToAddresses(toEmails);
            				mail.setWhatId(rider.id); // merge field
            				surveyMails.add(mail);
                            //Set Survey Sent Time
                            rider.Survey_Sent_Time__c = system.now();
                        	objCon.Post_Delivery_Time__c = system.now();
                            updateContactList.add(objCon);
                            system.debug('toEmails :: '+toEmails);
                    	}//forloop
                        system.debug('contactIds for a given Rider :: '+ contactIds + ' for Rider :'+rider.Name);
                        //Update the contact Ids
                        rider.Survey_Sent_Contact_Ids__c = contactIds;
                        
                        if(allSurveyContacts.size() < 1 && rider.Rider_Name_Ends_Zero__c == 'YES' && 
                           				mapRiderOld.get(rider.Id).RFO_RiderAverageBeginDate__c==null &&
                           				rider.RFO_RiderAverageBeginDate__c!=null &&
                           				rider.Survey_Sent_Time__c==null){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTemplateId(notifyCDMId);
                            mail.setSaveAsActivity(false);
                            mail.setTargetObjectId(System.Label.GetFeedBack_Contact);// should be a contact to get the merge fields in template
            				if ( owea != null ) {
                				mail.setOrgWideEmailAddressId(owea.Id);
            				}
							if(accountTeamMap.get(rider.RFO_Account__c)!=null){
                            	escalationEmails.add(accountTeamMap.get(rider.RFO_Account__c).user.email);
                            }
            				mail.setToAddresses(escalationEmails);
            				mail.setWhatId(rider.id); // merge field
                            contactNotExistsMails.add(mail);
							system.debug('escalationEmails :: '+escalationEmails);                                            
                        }
                        
                        
                    }//rider account
            	}//Account list
                
            }//riderList
            system.debug('Survey Mail Size:: '+surveyMails.size());
            if(surveyMails.size()>0){
            	try{
                	Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(surveyMails);
                    system.debug('survey mail Sent success');
            	}catch(Exception e){
                	system.debug(e);
            	}
            }
            system.debug('contactNotExistsMails Size:: '+contactNotExistsMails.size());
            if(contactNotExistsMails.size()>0){
                try{
                	Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(contactNotExistsMails);
                    system.debug('contact not exists mail Sent success');
            	}catch(Exception e){
                	system.debug(e);
            	}
            }
            
            if(updateContactList.size()>0){
                update updateContactList;
            }
        }
    }
}