global class RFO_ProjectComplianceSurveyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
        
	global Database.QueryLocator start(Database.BatchableContext bc){
        String surveyStartingDate = label.Compliance_Project_Survey_Start_Date;
        if(String.isEmpty(surveyStartingDate)){
            surveyStartingDate = '2019-10-01';
        }
        return Database.getQueryLocator(            
            'SELECT Account_Name__c,Id,Last_Car_Ship_Date__c,Name,RFO_Account__c,RFO_DemandDriverName__c,RFO_Status__c,Survey_Sent_Time__c FROM RFO_Projects__c WHERE Last_Car_Ship_Date__c != null and survey_sent_time__c = null and Last_Car_Ship_Date__c > 2019-06-30 and Last_Car_Ship_Date__c=LAST_N_DAYS:'+label.Compliance_Project_Survey_LastNdays);
    }
        
    global void execute(Database.BatchableContext bc,  List<RFO_Projects__c> projectList){   
    	Date compliance_survey_start_date_const = date.valueOf('2019-10-01');
        String surveyStartingDate = label.Compliance_Project_Survey_Start_Date;
        String Compliance_Survey_urlStr = label.Compliance_Survey_URL;
        Map<Id, RFO_Projects__c> updateProjectMap = new Map<Id, RFO_Projects__c>();
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
            compliance_survey_start_date_const = date.valueOf(surveyStartingDate);
        }catch(Exception e){
            compliance_survey_start_date_const = date.valueOf('2019-10-01');
            system.debug(e);
        }
        
        
        Set<String> AccountTeamRoles = new Set<String>{label.Customer_Delivery_Manager};
        List<Id> accountIds = new List<Id>();
        if(!projectList.isEmpty()) { 
            for(RFO_Projects__c proj: projectList){
                accountIds.add(proj.RFO_Account__c);
            }
        }
        system.debug('1: accountIds'+accountIds.size());
        Map<id,AccountTeamMember> accountTeamMap = new Map<id,AccountTeamMember>();
        List<Account> accounts = [Select Id, ownerId, owner.Email,RFO_Enact_60_days_survey_rule_Projects__c, (Select  ContactId, Contact.FirstName,  Contact.LastName,  Contact.Email,  Contact.Name,  Contact.RFO_ContactRole__c, Contact.Compliance_Survey_Sent_Time__c  From AccountContactRelations) from Account where Id IN : accountIds];
        List<AccountTeamMember> accountTeams = [Select AccountId,TeamMemberRole,UserId,user.email,user.name FROM AccountTeamMember WHERE AccountId IN:accountIds AND TeamMemberRole IN:AccountTeamRoles];
        List<EmailTemplate> lstEmailTemplates =  [SELECT Id, HTMLValue, Subject, DeveloperName from EmailTemplate where DeveloperName IN ('Survey_for_Compliance_Project', 'Compliance_Survey_contact_not_exists_in_account_alert') order by DeveloperName];    
       	Id notifyCDMId = lstEmailTemplates[0].Id;
        Id surveyTemplateId = lstEmailTemplates[1].Id;
        String surveyEmailTemplateHTMLMain = lstEmailTemplates[1].HTMLValue;
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        //OrgWideEmailAddress owea = [select id, Address from OrgWideEmailAddress where Address =:System.Label.noreply_trin_net LIMIT 1];
        List<OrgWideEmailAddress> oweaList = [select id, Address from OrgWideEmailAddress LIMIT 100];
        Id oweaId = null;
        for(OrgWideEmailAddress owea : oweaList){
            if(owea.Address == System.Label.Compliance_Project_From_Email_Chase_Greene){
                oweaId = owea.Id;
            }
            else{
                oweaId = owea.Id;
            }
        }
        // where Address =:System.Label.Compliance_Project_From_Email_Chase_Greene
        
        List<Messaging.SingleEmailMessage> surveyMails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> contactNotExistsMails = new List<Messaging.SingleEmailMessage>();
        List<String> escalationEmails = new List<String>();
        escalationEmails.addAll(surveyadminUsers);
        escalationEmails.addAll(surveyBusinessUsers);
        for(AccountTeamMember atm:accountTeams){
        	accountTeamMap.put(atm.AccountId,atm);
        }
        
        //Iterate and get accounts with contacts only project compliance role
        //
        //
        for(RFO_Projects__c proj: projectList){
            system.debug('2: projects size '+projectList.size());
            system.debug('2a: project::'+proj);
        	for(Account acc : accounts){
            	if(acc.Id == proj.RFO_Account__c){
                    String demandDriver = proj.RFO_DemandDriverName__c;
                    String projectName = proj.Name;
                    List<Contact> allSurveyContacts = new List<Contact>();
                    List<Contact> eligibleSurveyContacts = new List<Contact>();
                    Boolean surveyContactExists = false;
                    String CDM ='';
                    String cdmEmail = '';
                    String accountOwnerEmail = acc.owner.Email;
                    AccountTeamMember atm1 = accountTeamMap.get(proj.RFO_Account__c);
                    if(atm1!=null){
                       CDM=atm1.user.name;
                       cdmEmail=atm1.user.email;
                    }
                    for(AccountContactRelation acr: acc.AccountContactRelations){
                        Contact objCon = extractContact(acr);
                        if(objCon!=null && objCon.FirstName!=null){
                            allSurveyContacts.add(objCon);
                            if(objCon.RFO_ContactRole__c!=null && objCon.RFO_ContactRole__c.contains(label.Survey_Contact_Project_Compliance)){
                                surveyContactExists = true;
                            }
                        }
                        if(objCon.RFO_ContactRole__c!=null && 
                           objCon.RFO_ContactRole__c.contains(label.Survey_Contact_Project_Compliance)){
                        	system.debug('Inside when contact exists - email is '+objCon.Email);
                            if(
                                (proj.RFO_DemandDriverName__c=='Compliance' || proj.RFO_DemandDriverName__c=='HM-251') && 
                                proj.Last_Car_Ship_Date__c!=null && 
                                proj.Last_Car_Ship_Date__c > compliance_survey_start_date_const && 
                                proj.Last_Car_Ship_Date__c + 10 < date.today() && 
                                proj.Survey_Sent_Time__c==null && 
                                objCon.Email!=null  
                                //&&(objCon.Compliance_Survey_Sent_Time__c==null || 
                                // (objCon.Compliance_Survey_Sent_Time__c!=null && 
                                //  objCon.Compliance_Survey_Sent_Time__c.Date().daysBetween(system.today()) > 60))
                            )
                            	{
                                    if(acc.RFO_Enact_60_days_survey_rule_Projects__c){
                                        if((objCon.Compliance_Survey_Sent_Time__c==null || (objCon.Compliance_Survey_Sent_Time__c!=null && objCon.Compliance_Survey_Sent_Time__c.Date().daysBetween(system.today()) > 60))){
                                    		System.debug('Inside the condition of 10 days');
                                    		eligibleSurveyContacts.add(objCon);
                                    		proj.Survey_Contact_Id__c = objCon.Id;        
                                        }
                                    }else{
                                        System.debug('Inside the condition of 10 days');
                                    	eligibleSurveyContacts.add(objCon);
                                    	proj.Survey_Contact_Id__c = objCon.Id;
                                    }
                                    
                                }
                                System.debug('Outside the condition of 10 days');
                            
                        }
                    }//contacts for a project
                    //NOW SEND THE EMAIL 
        			system.debug('eligibleSurveyContacts size ::'+eligibleSurveyContacts.size() + ' for account == '+proj.RFO_Account__c);
					system.debug('allSurveyContacts size ::'+allSurveyContacts.size() + ' for account == '+proj.RFO_Account__c);
			        String contactIds = '';
                    
        			for(Contact objCon: eligibleSurveyContacts){
                        List<String> toEmails =  new List<String>();
                        List<String> bccEmails = new List<String>();
                        String surveyEmailTemplateHTML = surveyEmailTemplateHTMLMain;
        				contactIds = contactIds + objCon.Id + '||';
                        //String UrlStr = Compliance_Survey_urlStr + '?Projects_ID='+proj.Id+'&Projects_Demand_Driver_Name='+proj.RFO_DemandDriverName__C+'&Projects_Project_Name='+proj.Name+'&gf_q[7502214][15110015]='+objCon.Name+'&gf_q[7502214][15110016]='+proj.Account_Name__c+'&gf_q[7502214][15110017]='+objCon.Email;
            			
                        String UrlStringFromConstant = Compliance_Survey_urlStr;
                        String UrlStrProjId = UrlStringFromConstant.replace('<PROJECT_ID>',String.valueOf(proj.Id)).trim();
                        String UrlStrProjName = UrlStrProjId.replace('<PROJECT_Name>',String.valueOf(proj.Name)).trim();
                        String UrlStrContactId = UrlStrProjName.replace('<CONTACT_ID>',String.valueOf(objCon.Id)).trim();
                        String UrlStrAccountId = UrlStrContactId.replace('<ACCOUNT_ID>',String.valueOf(proj.RFO_Account__c)).trim();
                        String UrlStrFullName = UrlStrAccountId.replace('<First and last name>',String.valueOf(objCon.firstName + ' '+ objCon.lastName)).trim();
                        String UrlStrEmail = UrlStrFullName.replace('<Email address>',String.valueOf(objCon.Email)).trim();
                        String UrlStrCompany = UrlStrEmail.replace('<Company name>',String.valueOf(proj.Account_Name__c)).trim();
                        
                        String UrlStr =UrlStrCompany.trim();
                        System.debug('UrlStr=='+UrlStr);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        String surveyEmailTemplateHTML_Demand = surveyEmailTemplateHTML.replace('{!RFO_Projects__c.RFO_DemandDriverName__c}',demandDriver);
                        String surveyEmailTemplateHTML_ProjName = surveyEmailTemplateHTML_Demand.replace('{!RFO_Projects__c.Name}', projectName);
                        String surveyEmailTemplateHTML_URL = surveyEmailTemplateHTML_ProjName.replace('{PROJECTSURVEYURL}', UrlStr);
                        
                        mail.setHtmlBody(surveyEmailTemplateHTML_URL);
            			//mail.setTemplateId(surveyTemplateId);
            			mail.setSaveAsActivity(false);
                        //mail.setTargetObjectId(objCon.Id);// should be a contact to get the merge fields in template
            			if ( oweaId != null ) {
            				mail.setOrgWideEmailAddressId(oweaId);
            			}
                        toEmails.add(objCon.email);
                        if(cdmEmail!=null && cdmEmail.length()>1){
                            bccEmails.add(cdmEmail);
                        }
                        if(accountOwnerEmail!=null && accountOwnerEmail.length()>1){
                            bccEmails.add(accountOwnerEmail);
                        }
            			bccEmails.addAll(escalationEmails);
                        if(accountTeamMap.get(proj.RFO_Account__c)!=null){
                        	bccEmails.add(accountTeamMap.get(proj.RFO_Account__c).user.email);
                        }
                        mail.setSubject('Please take a short survey about your recent '+proj.RFO_DemandDriverName__c+' shopping event');
            			mail.setToAddresses(toEmails);
                        mail.setBccAddresses(bccEmails);
            			mail.setWhatId(proj.id); // merge field
            			surveyMails.add(mail);
            			//Set Survey Sent Time
            			proj.Survey_Sent_Time__c = system.now();
            			objCon.Compliance_Survey_Sent_Time__c = system.now();
            			updateProjectMap.put(proj.Id, proj);
                        updateContactMap.put(objCon.Id, objCon);
            			system.debug('toEmails :: '+toEmails);
        			}//forloop
                    
                    if((proj.RFO_DemandDriverName__c=='Compliance' || proj.RFO_DemandDriverName__c=='HM-251') &&
                       proj.Last_Car_Ship_Date__c!=null &&
                       proj.Last_Car_Ship_Date__c > compliance_survey_start_date_const &&
                       proj.Last_Car_Ship_Date__c + 10 < date.today() &&
                       proj.Survey_Sent_Time__c==null && !surveyContactExists){
                           
                        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        	mail.setTemplateId(notifyCDMId);
                        	mail.setSaveAsActivity(false);
                        	mail.setTargetObjectId(System.Label.GetFeedBack_Contact);// should be a contact to get the merge fields in template
            				if ( oweaId != null ) {
                				mail.setOrgWideEmailAddressId(oweaId);
            				}
							if(accountTeamMap.get(proj.RFO_Account__c)!=null){
                           		escalationEmails.add(accountTeamMap.get(proj.RFO_Account__c).user.email);
                        	}
            				mail.setToAddresses(escalationEmails);
            				mail.setWhatId(proj.id); // merge field
                        
                        	contactNotExistsMails.add(mail);
                    	}
                }//acctId match
            }//accts
		}//for loop main
        system.debug('surveyMails.size()=='+surveyMails.size());
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
        system.debug('updateContactMap.size()=='+updateContactMap.size());
        if(updateContactMap.size()>0){
            List<Contact> updateContactList = new List<Contact>();
            updateContactList = updateContactMap.values();
            system.debug('Size of updateContactList about to update is '+updateContactList.size());
        	update updateContactList;
            system.debug('Updated the contact object');
        }
        //Call update ProjectList to update survey Sent time
        List<RFO_Projects__c> updatedProjectList = new List<RFO_Projects__c>();
        updatedProjectList = updateProjectMap.values();
        if(updatedProjectList.size()>0){
        	update updatedProjectList;
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
        	c.Compliance_Survey_Sent_Time__c = acr.Contact.Compliance_Survey_Sent_Time__c;
        }
        
        return c;
    }
        
	global void finish(Database.BatchableContext bc){
        
    }     
}