global class RFO_OrderSurveyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
	global Database.QueryLocator start(Database.BatchableContext bc){
        String surveyStartingDate = label.Post_Delivery_Order_Survey_Start;
        if(String.isEmpty(surveyStartingDate)){
            surveyStartingDate = '2019-10-01';
        }
        return Database.getQueryLocator(            
            'SELECT Id, Name, OrderNumber, AccountId, Account_Name_Text__c, RFO_TotalCurrentQuantity__c,RFO_TankorFreight__c,  First_Ship_Week_Survey_Sent_Time__c,  RFO_FirstShipWeek__c, RFO_LastShipWeek__c, Last_Ship_Week_Survey_Sent_Time__c, RFO_SellQuantity__c,RFO_CarType__c,RFO_CommodityName__c,RFO_File__c  FROM Order WHERE RFO_File__c!=null AND (RFO_FirstShipWeek__c != null OR RFO_LastShipWeek__c != null) and (First_Ship_Week_Survey_Sent_Time__c = null OR Last_Ship_Week_Survey_Sent_Time__c = null) and Type=\'Direct Sale\' AND ((RFO_FirstShipWeek__c > '+surveyStartingDate+' AND RFO_FirstShipWeek__c= LAST_N_DAYS:'+label.Post_Delivery_Order_Survey_LastNdays+' ) OR (RFO_LastShipWeek__c > '+surveyStartingDate+' AND RFO_LastShipWeek__c=LAST_N_DAYS:'+label.Post_Delivery_Order_Survey_LastNdays+') )');
    }
    
    global void execute(Database.BatchableContext bc,  List<Order> orderList){ 
        system.debug('PROGRAM STARTED');
        system.debug('Label label.Survey_Contact_Rider_Order '+label.Survey_Contact_Rider_Order);
    	Date order_survey_start_date_const = date.valueOf('2019-12-01');
        String surveyStartingDate = label.Post_Delivery_Order_Survey_Start;
		String order_Survey_URL = label.Post_Delivery_Order_URL;
        String Order_Survey_urlStr = Order_Survey_URL.trim();
        System.debug('Order_Survey_urlStr::'+Order_Survey_urlStr);
        Map<Id, Order> updateOrderMap = new Map<Id, Order>();
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
            order_survey_start_date_const = date.valueOf(surveyStartingDate);
        }catch(Exception e){
            order_survey_start_date_const = date.valueOf('2019-10-01');
            system.debug(e);
        }
        Set<String> AccountTeamRoles = new Set<String>{label.Customer_Delivery_Manager};
        List<Id> accountIds = new List<Id>();
        if(!orderList.isEmpty()) { 
            for(Order ord: orderList){
                accountIds.add(ord.AccountId);
            }
        }
        system.debug('order_survey_start_date_const::'+order_survey_start_date_const);
        Map<id,AccountTeamMember> accountTeamMap = new Map<id,AccountTeamMember>();
        List<Account> accounts = [Select Id, ownerId, owner.Email, RFO_Enact_60_days_survey_rule_New_Order__c, (Select  ContactId, Contact.FirstName,  Contact.LastName,  Contact.Email,  Contact.Name,  Contact.RFO_ContactRole__c, Contact.Post_Delivery_Time__c  From AccountContactRelations) from Account where Id IN : accountIds];
        List<AccountTeamMember> accountTeams = [Select AccountId,TeamMemberRole,UserId,user.email, user.name FROM AccountTeamMember WHERE AccountId IN:accountIds AND TeamMemberRole IN:AccountTeamRoles];
        List<EmailTemplate> lstEmailTemplates =  [SELECT Id, HTMLValue, Subject, DeveloperName from EmailTemplate where DeveloperName IN ('Order_Survey', 'Survey_contact_not_exists_for_Order') order by DeveloperName];    
       	
        Id surveyTemplateId = lstEmailTemplates[0].Id;
        Id notifyCDMId = lstEmailTemplates[1].Id;
        String surveyEmailTemplateHTMLMain = lstEmailTemplates[0].HTMLValue;
        
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        Map<Id, Contact> eligibleContactMap = new Map<Id, Contact>();
        OrgWideEmailAddress owea = [select id, Address from OrgWideEmailAddress where Address =:System.Label.noreply_trin_net LIMIT 1];
        List<Messaging.SingleEmailMessage> surveyMails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> contactNotExistsMails = new List<Messaging.SingleEmailMessage>();
        List<String> escalationEmails = new List<String>();
        escalationEmails.addAll(surveyadminUsers);
        escalationEmails.addAll(surveyBusinessUsers);
        for(AccountTeamMember atm:accountTeams){
        	accountTeamMap.put(atm.AccountId,atm);
        }
        
        for(Order ord: orderList){
            for(Account acc : accounts){
                if(acc.Id == ord.AccountId){
                    system.debug('Order Id ::'+ord.Id + ' and '+ord.Name + '  and '+ord.Account_Name_Text__c);
                	List<Contact> allSurveyContacts = new List<Contact>();
                    List<Contact> eligibleSurveyContacts = new List<Contact>();
                    Boolean surveyContactExists = false;
                    Boolean firstWeek = false;
                    Boolean lastWeek = false;
                    String CDM ='';
                    String cdmEmail = '';

                    String accountOwnerEmail = acc.owner.Email;

                    AccountTeamMember atm1 = accountTeamMap.get(ord.AccountId);
                    if(atm1!=null){
                       CDM=atm1.user.name;
                       cdmEmail=atm1.user.email;
                    }
                    if(ord.RFO_File__c!=null && ord.RFO_FirstShipWeek__c!=null && ord.RFO_FirstShipWeek__c + 30 < date.today() && ord.First_Ship_Week_Survey_Sent_Time__c ==null && ord.RFO_FirstShipWeek__c > order_survey_start_date_const ){
                        firstWeek = true;        
                    }
                    if(ord.RFO_File__c!=null && ord.RFO_LastShipWeek__c!=null && ord.RFO_LastShipWeek__c + 30 < date.today() && ord.Last_Ship_Week_Survey_Sent_Time__c ==null && ord.RFO_LastShipWeek__c > order_survey_start_date_const ){
                    	lastWeek = true;        
                    }
                    system.debug('ord.RFO_File__c:'+ord.RFO_File__c+'  ord.RFO_FirstShipWeek__c:'+ord.RFO_FirstShipWeek__c+' RFO_LastShipWeek__c:'+ord.RFO_LastShipWeek__c);
                    for(AccountContactRelation acr: acc.AccountContactRelations){
                        Contact objCon = extractContact(acr);
                        boolean contactRoleExists= false;
                        System.debug('Contact Name :: '+objCon.firstName + ' and Role:: '+objCon.RFO_ContactRole__c);
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
                        
                        if(objCon!=null && objCon.FirstName!=null){
                            allSurveyContacts.add(objCon);
                        }
                        System.debug('Post_Delivery_Time__c '+objCon.Post_Delivery_Time__c+' objCon.Email:'+objCon.Email+'  contactId:'+objCon.Id);
                        if(objCon.RFO_ContactRole__c!=null 
                               && contactRoleExists 
                               && ord.RFO_File__c!=null 
                               && ord.RFO_FirstShipWeek__c > order_survey_start_date_const
                               && ord.RFO_FirstShipWeek__c!=null && ord.RFO_FirstShipWeek__c + 30 < date.today() && ord.First_Ship_Week_Survey_Sent_Time__c ==null  
                               //&& (objCon.Post_Delivery_Time__c==null || (objCon.Post_Delivery_Time__c!=null && objCon.Post_Delivery_Time__c.Date().daysBetween(system.today()) > 60))
                          ){
                                if(!eligibleContactMap.containskey(objCon.id)){
                                	if(acc.RFO_Enact_60_days_survey_rule_New_Order__c){
                                        if((objCon.Post_Delivery_Time__c==null || (objCon.Post_Delivery_Time__c!=null && objCon.Post_Delivery_Time__c.Date().daysBetween(system.today()) > 60))){
                                        	eligibleSurveyContacts.add(objCon);
                                        	eligibleContactMap.put(objCon.Id, objCon);
                                        }
                                	}
                                    else{
                                        eligibleSurveyContacts.add(objCon);
                                        eligibleContactMap.put(objCon.Id, objCon);
                                    }
                                    System.debug('Order is eligible for survey last week');
                                }
                        }
                        if(objCon.RFO_ContactRole__c!=null 
                               && contactRoleExists
                           	   && ord.RFO_File__c!=null
                               && ord.RFO_LastShipWeek__c > order_survey_start_date_const
                               && ord.RFO_LastShipWeek__c!=null && ord.RFO_LastShipWeek__c + 30 < date.today() && ord.Last_Ship_Week_Survey_Sent_Time__c ==null  
                               //&& (objCon.Post_Delivery_Time__c==null || (objCon.Post_Delivery_Time__c!=null && objCon.Post_Delivery_Time__c.Date().daysBetween(system.today()) > 60))
                          ){
                                   if(!eligibleContactMap.containskey(objCon.id)){
                                       if(acc.RFO_Enact_60_days_survey_rule_New_Order__c){
                                           if((objCon.Post_Delivery_Time__c==null || (objCon.Post_Delivery_Time__c!=null && objCon.Post_Delivery_Time__c.Date().daysBetween(system.today()) > 60))){
                                              eligibleSurveyContacts.add(objCon);
                                       		  eligibleContactMap.put(objCon.Id, objCon); 
                                           }
                                       }else{
                                       		eligibleSurveyContacts.add(objCon);
                                       		eligibleContactMap.put(objCon.Id, objCon);
                                	   }
                                       System.debug('Order is eligible for survey last week');
                                   }	
                                    	
                        }
                        
                    }//contacts for order
                    for(Contact objCon: eligibleSurveyContacts){
                    	List<String> toEmails = new List<String>();
                        List<String> bccEmails = new List<String>();
                        String surveyEmailTemplateHTML = surveyEmailTemplateHTMLMain;
                        //System.debug(surveyEmailTemplateHTML);
                        String UrlStringFromConstant = Order_Survey_urlStr;
                        //System.debug(UrlStringFromConstant);
                        String UrlStrOrdId = UrlStringFromConstant.replace('<ORDER_ID>',String.valueOf(ord.Id)).trim();
                        String UrlStrContactId = UrlStrOrdId.replace('<CONTACT_ID>',String.valueOf(objCon.Id)).trim();
                        String UrlStrAccountId = UrlStrContactId.replace('<ACCOUNT_ID>',String.valueOf(ord.AccountId)).trim();
                        
                        String UrlStrAccountName = UrlStrAccountId.replace('<Company name>',String.valueOf(ord.Account_Name_Text__c)).trim();
                        String UrlStrContactName = UrlStrAccountName.replace('<Full name>',String.valueOf(objCon.FirstName)+' '+String.valueOf(objCon.LastName)).trim();
                        String UrlStrCDM = UrlStrContactName.replace('<TrinityRail Customer Delivery Manager Name>',String.valueOf(CDM)).trim();
                        String UrlStrContactEmail = UrlStrCDM.replace('<Email address>',String.valueOf(objCon.Email)).trim();
                        	
                        
                        String UrlStr =UrlStrContactEmail.trim();
                        System.debug('UrlStr=='+UrlStr + ' orderNum::'+ord.Name);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        //{!Order.RFO_SellQuantity__c} {!Order.RFO_CarType__c} {!Order.RFO_Commodity__c} ({!Order.RFO_File__c})
                        
                        /*String surveyEmailTemplateHTML_sellQty = '';
                        if(ord.RFO_SellQuantity__c!=null){
                        	surveyEmailTemplateHTML_sellQty = surveyEmailTemplateHTML.replace('{!Order.RFO_SellQuantity__c}',String.valueOf(ord.RFO_SellQuantity__c));
                        }
                        else{
                            surveyEmailTemplateHTML_sellQty = surveyEmailTemplateHTML.replace('{!Order.RFO_SellQuantity__c}',' ');
                        }
                        String surveyEmailTemplateHTML_carType = '';
                        if(ord.RFO_CarType__c!=null){
                            surveyEmailTemplateHTML_carType = surveyEmailTemplateHTML_sellQty.replace('{!Order.RFO_CarType__c}',ord.RFO_CarType__c);
                        }else{
                            surveyEmailTemplateHTML_carType = surveyEmailTemplateHTML_sellQty.replace('{!Order.RFO_CarType__c}',' ');
                        }
						*/
                        String surveyEmailTemplateHTML_TtlCurrQty = '';
                        if(ord.RFO_TotalCurrentQuantity__c!=null){
                        	surveyEmailTemplateHTML_TtlCurrQty = surveyEmailTemplateHTML.replace('{!Order.RFO_TotalCurrentQuantity__c}',String.valueOf(ord.RFO_TotalCurrentQuantity__c));
                        }
                        else{
                            surveyEmailTemplateHTML_TtlCurrQty = surveyEmailTemplateHTML.replace('{!Order.RFO_TotalCurrentQuantity__c}',' ');
                        }
                        String surveyEmailTemplateHTML_commodity = '';
                        if(ord.RFO_CommodityName__c!=null){
                            surveyEmailTemplateHTML_commodity = surveyEmailTemplateHTML_TtlCurrQty.replace('{!Order.RFO_CommodityName__c}',ord.RFO_CommodityName__c);
                            //surveyEmailTemplateHTML_commodity = surveyEmailTemplateHTML_carType.replace('{!Order.RFO_CommodityName__c}',ord.RFO_CommodityName__c);
                        }else{
                            //surveyEmailTemplateHTML_commodity = surveyEmailTemplateHTML_carType.replace('{!Order.RFO_CommodityName__c}',' ');
                            surveyEmailTemplateHTML_commodity = surveyEmailTemplateHTML_TtlCurrQty.replace('{!Order.RFO_CommodityName__c}',' ');
                        }
                        
                        String surveyEmailTemplateHTML_tankfreight = '';
                        if(ord.RFO_TankorFreight__c!=null){
                        	surveyEmailTemplateHTML_tankfreight = surveyEmailTemplateHTML_commodity.replace('{!Order.RFO_TankorFreight__c}',String.valueOf(ord.RFO_TankorFreight__c));
                        }
                        else{
                            surveyEmailTemplateHTML_tankfreight = surveyEmailTemplateHTML_commodity.replace('{!Order.RFO_TankorFreight__c}','rail');
                        }
                        
                        /*
                        String surveyEmailTemplateHTML_file = '';
                        if(ord.RFO_File__c!=null){
                            surveyEmailTemplateHTML_file = surveyEmailTemplateHTML_commodity.replace('{!Order.RFO_File__c}',ord.RFO_File__c);
                        }else{
                            surveyEmailTemplateHTML_file = surveyEmailTemplateHTML_commodity.replace('{!Order.RFO_File__c}', ' ');
                        }*/
                        
                        //String surveyEmailTemplateHTML_URL = surveyEmailTemplateHTML_file.replace('{ORDERSURVEYURL}', UrlStr);
                        String surveyEmailTemplateHTML_URL = surveyEmailTemplateHTML_tankfreight.replace('{ORDERSURVEYURL}', UrlStr);
                        //system.debug(surveyEmailTemplateHTML_URL);
                        mail.setHtmlBody(surveyEmailTemplateHTML_URL);
                        mail.setSaveAsActivity(false);
                        if ( owea != null ) {
            				mail.setOrgWideEmailAddressId(owea.Id);
            			}
                        toEmails.add(objCon.email);
                        if(cdmEmail!=null && cdmEmail.length()>1){
                            bccEmails.add(cdmEmail);
                        }

                        if(accountOwnerEmail!=null && accountOwnerEmail.length()>1){
                            bccEmails.add(accountOwnerEmail);
                        }

            			bccEmails.addAll(escalationEmails);
                        System.debug(toEmails);
                        mail.setSubject('Please take a short survey about your recent TrinityRail order');
                        if(accountTeamMap.get(ord.AccountId)!=null){
                           	bccEmails.add(accountTeamMap.get(ord.AccountId).user.email);
                        }
            			mail.setToAddresses(toEmails);
                        mail.setBccAddresses(bccEmails);
            			mail.setWhatId(ord.id); // merge field
            			surveyMails.add(mail);
            			//Set Survey Sent Time
                        if(firstWeek){
                            ord.First_Ship_Week_Survey_Sent_Time__c = system.now();
                        }
                        if(lastWeek){
                            ord.Last_Ship_Week_Survey_Sent_Time__c = system.now();
                        }
            			objCon.Post_Delivery_Time__c = system.now();
            			updateOrderMap.put(ord.Id, ord);
                        updateContactMap.put(objCon.Id, objCon);
            			system.debug('## toEmails :: '+toEmails+ ' Order#'+ord.Name+ ' ==> ord Num '+ord.OrderNumber);
                        system.debug('## bccEmails :: '+bccEmails);
                    }//for loop eligible survey
                    
                    
                    if(!surveyContactExists && (firstWeek || lastWeek)){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateId(notifyCDMId);
                        mail.setSaveAsActivity(false);
                        mail.setTargetObjectId(System.Label.GetFeedBack_Contact);// should be a contact to get the merge fields in template
            			if ( owea != null ) {
                			mail.setOrgWideEmailAddressId(owea.Id);
            			}
						if(accountTeamMap.get(ord.AccountId)!=null){
                           	escalationEmails.add(accountTeamMap.get(ord.AccountId).user.email);
                        }
            			mail.setToAddresses(escalationEmails);
            			mail.setWhatId(ord.id); // merge field
                        
                        contactNotExistsMails.add(mail);
                    }//nocontact email
                }//acc if
            }//acc
        }//order list
        
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
        //Call update orderList to update survey Sent time
        List<Order> updatedOrderList = new List<Order>();
        updatedOrderList = updateOrderMap.values();
        if(updatedOrderList.size()>0){
        	update updatedOrderList;
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