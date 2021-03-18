global class RFO_OrderPlantNotificationBatch  implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{

    global Database.QueryLocator start(Database.BatchableContext bc){
       return Database.getQueryLocator(            
            'SELECT Id, Name, OrderNumber, AccountId, Account.RecordType.Name, Account_Name_Text__c, RFO_LineNumber__c, RFO_SellQuantity__c,RFO_CarType__c,RFO_CommodityName__c,RFO_File__c,RFO_Notify_New_Car_Plant_User_On_Defined__c, RFO_Product__r.Name, RFO_Quantity__c, Type FROM Order WHERE RFO_Notify_New_Car_Plant_User_On_Defined__c=true');
    }
    global void execute(Database.BatchableContext bc,  List<Order> orderList){ 
        if(orderList.size()>0){
            List<Id> orderIds = new List<Id>();
            for(Order o: orderList){
                orderIds.add(o.Id);
            }
            String orderPageUrl = URL.getSalesforceBaseUrl().toExternalForm() ;
            List<RFO_Asset_File__c> assetFiles = [SELECT Name, RFO_IntegrationId__c,RFO_CurrentPlant__r.Name,  RFO_CurrentPlant__r.RFO_AssemblyPlantCommercialDistList__c, RFO_CurrentPlant__r.RFO_AssemblyPlantThirdPartyDistList__c,RFO_CurrentPlant__r.RFO_AssemblyPlantDistributionList__c, RFO_OrderNumber__c from RFO_Asset_File__c where RFO_OrderNumber__c=:orderIds];
            System.debug('#### assetFiles:::'+assetFiles.size());
            Map<String,RFO_Asset_File__c> assetFileMap = new Map<String,RFO_Asset_File__c>();
            for(RFO_Asset_File__c asset : assetFiles){
                system.debug('>> asset.RFO_IntegrationId__c ::'+asset.RFO_IntegrationId__c);
                assetFileMap.put(asset.RFO_IntegrationId__c, asset);
            }
            System.debug('$$$$$$ assetFilesMap:::'+assetFileMap.size());
            //NewCar_Order_Defined_Status_Notification
            List<String> toAddresses = new List<String>();
            Set<Id> grpUserIds = new Set<Id>();
        	for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='NewCar_Order_Defined_Status_Notification'])
        	{
            	grpUserIds.add(member.UserOrGroupId);
        	}
        	if(grpUserIds.size()>0)
        	{
            	for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            	toAddresses.add(u.email);
        	}
        	grpUserIds.clear();
            
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        	
            OrgWideEmailAddress owea = [select id, Address from OrgWideEmailAddress where Address =:System.Label.noreply_trin_net LIMIT 1];
        	List<EmailTemplate> lstEmailTemplates =  [SELECT Id, HTMLValue, Subject, DeveloperName from EmailTemplate where DeveloperName IN ('RFO_New_Car_Order_Defined_Email_Template') order by DeveloperName];
        	Id notifyCDMId = lstEmailTemplates[0].Id; 
            String emailTemplateHTMLMain = lstEmailTemplates[0].HTMLValue;
        	for(Order ord : orderList){
            	system.debug('Order RFO_Notify_New_Car_Plant_User_On_Defined__c ::'+ord.RFO_Notify_New_Car_Plant_User_On_Defined__c);
                system.debug('ord.RFO_File__c ::'+ord.RFO_File__c);
                if(assetFileMap.containskey(ord.RFO_File__c)){
                    List<String> plantToAddresses = new List<String>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    RFO_Asset_File__c asset = (RFO_Asset_File__c)assetFileMap.get(ord.RFO_File__c);
                    system.debug('Account Rec '+ord.Account.RecordType.Name);
                    system.debug('ASSET FILE EXISTS ');
                    if(ord.Account.RecordType.Name.startsWithIgnoreCase('Third') && asset.RFO_CurrentPlant__r.RFO_AssemblyPlantThirdPartyDistList__c!=null){
                    	plantToAddresses.add(asset.RFO_CurrentPlant__r.RFO_AssemblyPlantThirdPartyDistList__c);
                        
                    }
                    if(!ord.Account.RecordType.Name.startsWithIgnoreCase('Third') && asset.RFO_CurrentPlant__r.RFO_AssemblyPlantCommercialDistList__c!=null){
                    	plantToAddresses.add(asset.RFO_CurrentPlant__r.RFO_AssemblyPlantCommercialDistList__c);
                        
                    }
                    String orderEmailTempMain = emailTemplateHTMLMain;
                    String orderEmailTempMain_customer = orderEmailTempMain.replace('{ORDER_ACCOUNT}',ord.Account_Name_Text__c);
                    String orderEmailTempMain_orderNbr = orderEmailTempMain_customer.replace('{ORDER_NUMBER}',ord.OrderNumber);
                    String orderEmailTempMain_file = orderEmailTempMain_orderNbr.replace('{ORDER_FILE}',ord.RFO_File__c);
                    String orderEmailTempMain_plant = orderEmailTempMain_file.replace('{ORDER_CURRENT_PLANT}',' '+asset.RFO_CurrentPlant__r.Name+' / '+ord.RFO_LineNumber__c);
                    String orderEmailTempMain_carType = orderEmailTempMain_plant.replace('{ORDER_CAR}',ord.RFO_Product__r.Name);
                    String orderEmailTempMain_quantity = orderEmailTempMain_carType.replace('{ORDER_QUANTITY}',String.valueOf(ord.RFO_Quantity__c));
                    String orderEmailTempMain_orderType = orderEmailTempMain_quantity.replace('{ORDER_TYPE}',ord.Type);
                    String orderEmailTempMain_orderLink = orderEmailTempMain_orderType.replace('{ORDER_LINK_URL}','Link: '+orderPageUrl+'/'+ord.Id);
                    mail.setHtmlBody(orderEmailTempMain_orderLink);
                    //mail.setTemplateId(notifyCDMId);
            		mail.setSaveAsActivity(false);
            		//mail.setTargetObjectId(System.Label.GetFeedBack_Contact);// should be a contact to get the merge fields in template
            		if ( owea != null ) {
            			mail.setOrgWideEmailAddressId(owea.Id);
            		}
                    mail.setSubject('Sales Order Notification '+ ord.RFO_File__c +' '+ord.Account_Name_Text__c);
                    plantToAddresses.addAll(toAddresses);
					mail.setToAddresses(plantToAddresses);
                    mail.setWhatId(ord.id); // merge field
                    system.debug(mail.getHtmlBody());
                    system.debug('O/p:: '+mail);
            		allMails.add(mail);
            		ord.RFO_Notify_New_Car_Plant_User_On_Defined__c=false;
                    plantToAddresses.clear();
                }
            	
        	}
        	if(allMails.size()>0){
            	try{
                	Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(allMails);
                	system.debug('Mail Sent success');
                	update orderList;
                	system.debug('data updated');
            	}catch(Exception e){
            		system.debug(e);
            	}
            }
        }//main if
        
    }
    global void finish(Database.BatchableContext bc){
        
    }   
}