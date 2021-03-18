global class RFO_RiderSurveyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
	global Database.QueryLocator start(Database.BatchableContext bc){
        String surveyStartingDate = label.Post_Delivery_Rider_Survey_Start;
        if(String.isEmpty(surveyStartingDate)){
            surveyStartingDate = '2019-10-01';
        }
        return Database.getQueryLocator('SELECT Id, Name, RFO_TankFreight__c, RFO_ContractName__c, RFO_TotalOfCars__c,RFO_RiderType__c, RFO_RiderNumberSuffix__c, Rider_Name_Ends_Zero__c, RFO_Account__c, Account_Name__c, RFO_AvgBeginCharge__c, Survey_Sent_Time__c FROM RFO_Rider__c WHERE Survey_Sent_Time__c = null AND RFO_Account__c != null AND RFO_AvgBeginCharge__c != null AND RFO_RiderNumberSuffix__c=\'0\' AND (RFO_RiderType__c=\'Net Lease\' OR RFO_RiderType__c=\'Full Service Lease\') AND RFO_AvgBeginCharge__c = LAST_N_DAYS:'+label.Post_Delivery_Rider_Survey_LastNdays+' AND RFO_AvgBeginCharge__c >' +surveyStartingDate);
    }
    global void execute(Database.BatchableContext bc,  List<RFO_Rider__c> riderList){
        system.debug('Returned total riders :: '+riderList.size());
        Date rider_survey_start_date_const = date.valueOf('2019-10-01');
        String surveyStartingDate = label.Post_Delivery_Rider_Survey_Start;
      	String rider_Survey_urlStr = label.Post_Delivery_Rider_URL;
        Map<Id, RFO_Rider__c> updateRiderMap = new Map<Id, RFO_Rider__c>();
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        Map<Id, Contact> eligibleContactMap = new Map<Id, Contact>();
        Set<String> surveyadminUsers = new Set<String>();
        Set<String> surveyBusinessUsers = new Set<String>();
        Set<Id> grpUserIds = new Set<Id>();
        for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_System_Admin'])
        {
            grpUserIds.add(member.UserOrGroupId);
        }
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            surveyadminUsers.add(u.email);
        }
        grpUserIds.clear();
        for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_Business_Admin'])
        {
            grpUserIds.add(member.UserOrGroupId);
        }
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            surveyBusinessUsers.add(u.email);
        }
        grpUserIds.clear();
        try{
            rider_survey_start_date_const = date.valueOf(surveyStartingDate);
        }catch(Exception e){
            rider_survey_start_date_const = date.valueOf('2019-10-01');
            system.debug(e);
        }
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
            List<Account> accounts = [Select Id, ownerId, owner.Email, RFO_Enact_60_days_survey_rule_Rider__c, (Select  ContactId, Contact.FirstName,  Contact.LastName,  Contact.Email,  Contact.Name,  Contact.RFO_ContactRole__c, Contact.Post_Delivery_Time__c  From AccountContactRelations) from Account where Id IN : accountIds];
            List<AccountTeamMember> accountTeams = [Select AccountId,TeamMemberRole,UserId,user.email,user.name FROM AccountTeamMember WHERE AccountId IN:accountIds AND TeamMemberRole IN:AccountTeamRoles];
        	List<EmailTemplate> lstEmailTemplates =  [SELECT Id, HTMLValue, Subject, DeveloperName from EmailTemplate where DeveloperName IN ('Survey_Lease_Project_Avg_Begin_Charge', 'Survey_contact_not_exists_in_account_alert') order by DeveloperName];    
            if (lstEmailTemplates.size()<2) { return; } //exit since templates are not available
            Id notifyCDMId = lstEmailTemplates[0].Id;
            Id surveyTemplateId = lstEmailTemplates[1].Id;
            String surveyEmailTemplateHTMLMain = lstEmailTemplates[1].HTMLValue;
            OrgWideEmailAddress owea = [select id, Address from OrgWideEmailAddress where Address =:System.Label.noreply_trin_net LIMIT 1];
        	List<Messaging.SingleEmailMessage> surveyMails = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> contactNotExistsMails = new List<Messaging.SingleEmailMessage>();
            List<String> escalationEmails = new List<String>();
            escalationEmails.addAll(surveyadminUsers);
            escalationEmails.addAll(surveyBusinessUsers);
            for(AccountTeamMember atm:accountTeams){
                accountTeamMap.put(atm.AccountId,atm);
            }
            for(RFO_Rider__c rider : riderList){
        		for(Account acc : accounts){
                	if(acc.Id == rider.RFO_Account__c){

                        String accountOwnerEmail = acc.owner.Email;

                        List<Contact> allSurveyContacts = new List<Contact>();
                        List<Contact> eligibleSurveyContacts = new List<Contact>();
                        Boolean surveyContactExists = false;
                        String CDM ='';
                        String cdmEmail = '';
                        AccountTeamMember atm1 = accountTeamMap.get(rider.RFO_Account__c);
                        if(atm1!=null){
                            CDM=atm1.user.name;
                            cdmEmail = atm1.user.email;
                        }
                        for(AccountContactRelation acr: acc.AccountContactRelations){
                            Contact objCon = extractContact(acr);
                            boolean contactRoleExists= false;
                            if(objCon!=null && objCon.FirstName!=null){
                            	allSurveyContacts.add(objCon);
                                if(objCon.RFO_ContactRole__c!=null){
                                    String[] roles = objCon.RFO_ContactRole__c.split(';');
									for(String r : roles){
										if(r==label.Survey_Contact_Rider_Order){
                                			surveyContactExists = true;
											contactRoleExists = true;
                                    		system.debug('Survey Contact exists flag set is done');
                            			}
                        			}
                                }
                            }
                            if(contactRoleExists){
                                if(objCon.Email!=null){
                                    if(rider.Rider_Name_Ends_Zero__c == 'YES' && 
                           				rider.RFO_AvgBeginCharge__c!=null &&
                           				rider.Survey_Sent_Time__c==null 
                                   		//&&(objCon.Post_Delivery_Time__c==null ||  
                                         //(objCon.Post_Delivery_Time__c!=null && objCon.Post_Delivery_Time__c.Date().daysBetween(system.today()) > 60))
                          			){
                                        if(!eligibleContactMap.containskey(objCon.id)){
                                            if(acc.RFO_Enact_60_days_survey_rule_Rider__c){
                                                if((objCon.Post_Delivery_Time__c==null || (objCon.Post_Delivery_Time__c!=null && objCon.Post_Delivery_Time__c.Date().daysBetween(system.today()) > 60))){
                                                	eligibleSurveyContacts.add(objCon);
                                            		eligibleContactMap.put(objCon.Id, objCon);
                                                    System.debug('Contacts added to Map '+objCon.id + ' for Rider:'+rider.Name);
                                                }
                                            }else{
                                                eligibleSurveyContacts.add(objCon);
                                            	eligibleContactMap.put(objCon.Id, objCon);
                                                System.debug('Contacts added to Map '+objCon.id + ' for Rider:'+rider.Name);
                                            }
                                            
                                        }
                                    }
                                }//email not null
                            }//role
                        }//contacts
                        //Send Emails to Survey Contacts
                        system.debug('eligibleSurveyContacts size ::'+eligibleSurveyContacts.size()+' for Rider::'+rider.Name);
                        for(Contact objCon: eligibleSurveyContacts){
                            List<String> toEmails = new List<String>();
                            List<String> bccEmails = new List<String>();
                            String surveyEmailTemplateHTML = surveyEmailTemplateHTMLMain;
                        	String UrlStringFromConstant = Rider_Survey_urlStr;
                        	String UrlStrOrdId = UrlStringFromConstant.replace('<RIDER_ID>',String.valueOf(rider.Id)).trim();
                        	String UrlStrContactId = UrlStrOrdId.replace('<CONTACT_ID>',String.valueOf(objCon.Id)).trim();
                        	String UrlStrAccountId = UrlStrContactId.replace('<ACCOUNT_ID>',String.valueOf(rider.RFO_Account__c)).trim();
                            
                        	String UrlStrAccountName = UrlStrAccountId.replace('<Company name>',String.valueOf(rider.Account_Name__c)).trim();
                        	String UrlStrContactName = UrlStrAccountName.replace('<Full name>',String.valueOf(objCon.FirstName)+' '+String.valueOf(objCon.LastName)).trim();
                        	String UrlStrCDM = UrlStrContactName.replace('<TrinityRail Customer Delivery Manager Name>',String.valueOf(CDM)).trim();
                        	String UrlStrContactEmail = UrlStrCDM.replace('<Email address>',String.valueOf(objCon.Email)).trim();
                        	
                            String UrlStr =UrlStrContactEmail.trim();
                        	System.debug('UrlStr is constructed =='+UrlStr + ' for Rider::'+rider.Name);
							String surveyEmailTemplateHTML_totalCars = '';
                            String surveyEmailTemplateHTML_riderType = '';
                            String surveyEmailTemplateHTML_riderName = '';
                            String surveyEmailTemplateHtml_tankfreight = '';
                            String surveyEmailTemplateHtml_contractId = '';
                            /*
                            if(rider.RFO_TotalOfCars__c!=null){
                        		surveyEmailTemplateHTML_totalCars = surveyEmailTemplateHTML.replace('{!RFO_Rider__c.RFO_TotalOfCars__c}',String.valueOf(rider.RFO_TotalOfCars__c));
                        	}
                        	else{
                            	surveyEmailTemplateHTML_totalCars = surveyEmailTemplateHTML.replace('{!RFO_Rider__c.RFO_TotalOfCars__c}',' ');
                        	}
                            if(rider.RFO_RiderType__c!=null){
                        		surveyEmailTemplateHTML_riderType = surveyEmailTemplateHTML_totalCars.replace('{!RFO_Rider__c.RFO_RiderType__c}',String.valueOf(rider.RFO_RiderType__c));
                        	}
                        	else{
                            	surveyEmailTemplateHTML_riderType = surveyEmailTemplateHTML_totalCars.replace('{!RFO_Rider__c.RFO_RiderType__c}',' ');
                        	}*/
                            
                            
                            if(rider.RFO_TankFreight__c!=null){
                                surveyEmailTemplateHtml_tankfreight = surveyEmailTemplateHTML.replace('{!RFO_Rider__c.RFO_TankFreight__c}',String.valueOf(rider.RFO_TankFreight__c));
                            }else{
                               surveyEmailTemplateHtml_tankfreight = surveyEmailTemplateHTML.replace('{!RFO_Rider__c.RFO_TankFreight__c}','rail');
                            }
                            if(rider.RFO_ContractName__c!=null){
                                surveyEmailTemplateHtml_contractId = surveyEmailTemplateHtml_tankfreight.replace('{!RFO_Rider__c.RFO_ContractName__c}',String.valueOf(rider.RFO_ContractName__c));
                            }else{
                                surveyEmailTemplateHtml_contractId = surveyEmailTemplateHtml_tankfreight.replace('{!RFO_Rider__c.RFO_ContractName__c}','a recent lease');
                            }
                            //surveyEmailTemplateHTML_riderName = surveyEmailTemplateHTML_riderType.replace('{!RFO_Rider__c.Name}',String.valueOf(rider.Name));
                        	
                            //String surveyEmailTemplateHTML_URL = surveyEmailTemplateHTML_riderName.replace('{RIDERSURVEYURL}', UrlStr);
                            String surveyEmailTemplateHTML_URL = surveyEmailTemplateHtml_contractId.replace('{RIDERSURVEYURL}', UrlStr);
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            //mail.setTemplateId(surveyTemplateId);
                            mail.setHtmlBody(surveyEmailTemplateHTML_URL);
                            system.debug('Mail body constructed'+surveyEmailTemplateHTML_URL);
                            mail.setSaveAsActivity(false);
                            if ( owea != null ) {
                				mail.setOrgWideEmailAddressId(owea.Id);
            				}
                            toEmails.add(objCon.email);
            				//toEmails.addAll(surveyadminUsers);
            				if(accountTeamMap.get(rider.RFO_Account__c)!=null){
                            	bccEmails.add(accountTeamMap.get(rider.RFO_Account__c).user.email);
                            }
                            //bccEmails.addAll(surveyadminUsers);
                            bccEmails.addAll(escalationEmails);
                            System.debug(toEmails);
                            mail.setSubject('Please take a short survey about your recent TrinityRail order');
            				mail.setToAddresses(toEmails);
                            if(cdmEmail!=null && cdmEmail.length()>1){
                            	bccEmails.add(cdmEmail);
                        	}


                            if(accountOwnerEmail!=null && accountOwnerEmail.length()>1){
                                bccEmails.add(accountOwnerEmail);
                            }
                            
                            System.debug('BCC EMAILS ###'+bccEmails);
                            System.debug('TO EMAILS ###'+toEmails);
                            mail.setBccAddresses(bccEmails);


            				mail.setWhatId(rider.id); // merge field
            				surveyMails.add(mail);
                            //Set Survey Sent Time
                            rider.Survey_Sent_Time__c = system.now();
                        	objCon.Post_Delivery_Time__c = system.now();
                            updateRiderMap.put(rider.Id, rider);
                        	updateContactMap.put(objCon.Id, objCon);
                            system.debug('Mail Template added to List for the contact:'+objCon.Email+ ' for rider:'+rider.Name);
                    	}//forloop
                        
                        
                        if(!surveyContactExists && rider.Rider_Name_Ends_Zero__c == 'YES' && 
                           				rider.RFO_AvgBeginCharge__c!=null &&
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
                        
                    }
                }//for acct
            }//for riderlist
            system.debug('FINAL Survey Mail Size:: '+surveyMails.size());
            if(surveyMails.size()>0){
            	try{
                	Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(surveyMails);
                    system.debug('survey mail Sent success');
            	}catch(Exception e){
                	system.debug(e);
            	}
            }
            system.debug('FINAL contactNotExistsMails Size:: '+contactNotExistsMails.size());
            if(contactNotExistsMails.size()>0){
                try{
                	Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(contactNotExistsMails);
                    system.debug('contact not exists mail Sent success');
            	}catch(Exception e){
                	system.debug(e);
            	}
            }
            
            system.debug('updateContactMap.size()=='+updateContactMap.size());
        	if(updateContactMap.size()>0){
            	List<Contact> updateContactList = new List<Contact>();
            	updateContactList = updateContactMap.values();
            	update updateContactList;
            	system.debug('Updated the contact object');
        	}
        	
        	List<RFO_Rider__c> updatedRiderList = new List<RFO_Rider__c>();
        	updatedRiderList = updateRiderMap.values();
            system.debug('Total updated riders '+updatedRiderList.size());
        	if(updatedRiderList.size()>0){
        		update updatedRiderList;
                system.debug('Updated Riders');
        	}


            
        }
        
    }
    public static Contact extractContact(AccountContactRelation acr){
        Contact c = new Contact();
        if(acr!=null){
        	c.Id = acr.ContactId;
        	c.FirstName = acr.Contact.FirstName;
        	c.LastName = acr.Contact.LastName;
        	c.Email = acr.Contact.Email;
        	c.RFO_ContactRole__c = acr.Contact.RFO_ContactRole__c;
        	c.Post_Delivery_Time__c = acr.Contact.Post_Delivery_Time__c;
        }
        
        return c;
    }
        
	global void finish(Database.BatchableContext bc){
        
    }     
}