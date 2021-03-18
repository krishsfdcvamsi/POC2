Public class CaseFeedbackTriggerHandler
{
    public static void populateAccountTeam(List<Case_Feedback__c> newCaseFeedbackList)
    {
        Set<String> AccountTeamRoles = new Set<String>{label.Customer_Delivery_Director,label.Customer_Delivery_Manager};
        Set<Id> accountIds = new Set<Id>();
        Map<id,List<AccountTeamMember>> accountTeamMap = new Map<id,List<AccountTeamMember>>();
        for(Case_Feedback__c feed:newCaseFeedbackList)
        {
            if(feed.Case_Number__c == null && feed.Customer_Email_feed__c != null)
            {
                String cDMmail = feed.Customer_Email_feed__c;
                List<Contact> conList = [Select id,name from Contact where email =:cDMmail];
                if(conList!= null && conList.size()>0)
                    feed.Contact__c = conList[0].id;
            }
            if(feed.Case_Number__c == null && feed.Customer__c != null)
            {
                String accountSearchText = feed.Customer__c;
                List<Account> accList = [Select id,name from Account where name =:accountSearchText];
                if(accList!= null && accList.size()>0)
                    feed.Account__c = accList[0].id;
                else if((accountSearchText.contains(' ') && (accountSearchText.split(' ').size() == 4 || accountSearchText.split(' ').size()  == 3 || accountSearchText.split(' ').size()  == 2) )|| !accountSearchText.contains(' '))
                {
                    accountSearchText = accountSearchText+'%';
                    accList = [Select id,name from Account where name LIKE:accountSearchText];
                    if(accList!= null && accList.size()>0)
                        feed.Account__c = accList[0].id;
                }
                else if(accountSearchText.contains(' ') && accList== null)
                {
                    if(accountSearchText.split(' ').size()>=3)
                    {
                        accountSearchText = accountSearchText.substring(0,accountSearchText.indexOf(' ')+2)+'%';
                        accList = [Select id,name from Account where name LIKE:accountSearchText];
                    }
                    else if(accountSearchText.split(' ').size()==2 || accountSearchText.split(' ').size()==3 && accList== null)
                    {
                        accountSearchText = accountSearchText.substring(0,accountSearchText.indexOf(' ')+1)+'%';
                        accList = [Select id,name from Account where name LIKE:accountSearchText];
                    }
                    else if(accountSearchText.split(' ').size()==2 && accList== null)
                    {
                        accountSearchText = accountSearchText.substring(0,accountSearchText.indexOf(' ')+0)+'%';
                        accList = [Select id,name from Account where name LIKE:accountSearchText];
                    }
                    if(accList!= null && accList.size()>0)
                        feed.Account__c = accList[0].id;
                }
                
            }
            if(feed.Account__c != null)
                accountIds.add(feed.Account__c);    
        }
        //account Team Users
        if(accountIds.size()>0)
        {                                   
            for(AccountTeamMember accTeam:[Select AccountId,TeamMemberRole,UserId,user.email FROM AccountTeamMember WHERE AccountId IN:accountIds AND TeamMemberRole IN:AccountTeamRoles]){
                if(accountTeamMap.containsKey(accTeam.AccountId))
                {
                    accountTeamMap.get(accTeam.AccountId).add(accTeam);
                }
                else
                    accountTeamMap.put(accTeam.AccountId,new List<AccountTeamMember>{accTeam});
            }   
        }
        for(Case_Feedback__c feed:newCaseFeedbackList)
        {
            if(accountTeamMap.size()>0 && accountTeamMap.containsKey(feed.Account__c))
            {
                for(AccountTeamMember accTeam: accountTeamMap.get(feed.Account__c))
                {
                    if(accTeam.TeamMemberRole == label.Customer_Delivery_Manager)
                        feed.Customer_Delivery_Manager__c = accTeam.UserId;
                    else
                        feed.Customer_Delivery_Director__c = accTeam.UserId;
                }
            }
        }
    }
    //after insert feedback received Alert to Account Team
    public static void sendFeedbackEmail(List<Case_Feedback__c> newCaseFeedbackList)
    {
        Set<String> AccountTeamRoles = new Set<String>{label.Customer_Delivery_Director,label.Customer_Delivery_Manager,label.Sales_Manager, label.Sales_Rep};
        Set<String> ratings = new Set<String>{label.Rating_for_Escalation_1, label.Rating_for_Escalation_2, label.Rating_for_Escalation_3, label.Rating_for_Escalation_4,label.Rating_for_Escalation_5, label.Rating_for_Escalation_6,label.Rating_for_Escalation_7,label.Rating_for_Escalation_8,label.Rating_for_Escalation_9,label.Rating_for_Escalation_10,label.Rating_for_Escalation_11,label.Rating_for_Escalation_12};
        Set<String> allSurveyAlertUsers = new Set<String>();
        Set<String> allSurveyEscalateUsers = new Set<String>();
        
        
        Set<String> RiderUsers = new Set<String>();
        Set<String> RiderEscalateUsers = new Set<String>();
        Set<String> FieldSurveyUsers = new Set<String>();
        Set<String> FieldSurveyEscalateUsers = new Set<String>();
        Set<String> complianceProjectUsers = new Set<String>();
        Set<String> complianceProjectEscalateUsers = new Set<String>();
        Set<String> caseEscalateUsers = new Set<String>();
        Set<String> OrderUsers = new Set<String>();
        Set<String> OrderEscalateUsers = new Set<String>();
        
        
        
        
        Set<Id> grpUserIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Id> caseToOwnerIds = new Map<Id,Id>();
        Map<id,Set<String>> accountTeamMailIdMap = new Map<id,Set<String>>();
        for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_All_Alert_Group'])
        {
            grpUserIds.add(member.UserOrGroupId);
        }
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            allSurveyAlertUsers.add(u.email);
        }
        grpUserIds.clear();
        
        for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_All_Escalation_Group'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            allSurveyEscalateUsers.add(u.email);
        }
        grpUserIds.clear();
        ////
        
		for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_Order_Alert_Group'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            OrderUsers.add(u.email);
        }
        grpUserIds.clear();

		for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_Order_Escalation_Group'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            OrderEscalateUsers.add(u.email);
        }
        grpUserIds.clear();

		for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_Project_Alert_Group'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            complianceProjectUsers.add(u.email);
        }
        grpUserIds.clear();


		for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_Project_Escalation_Group'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            complianceProjectEscalateUsers.add(u.email);
        }
        grpUserIds.clear();
		        
        for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_Fieldservice_Alert_Group'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            FieldSurveyUsers.add(u.email);
        }
        grpUserIds.clear();


		for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_Fieldservice_Escalation_Group'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            FieldSurveyEscalateUsers.add(u.email);
        }
        grpUserIds.clear();
		
		for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_Case_Escalation_Group'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            caseEscalateUsers.add(u.email);
        }
        grpUserIds.clear();
        
        for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_Rider_Alert_Group'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            RiderUsers.add(u.email);
        }
        grpUserIds.clear();
        
        for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Survey_Rider_Escalation_Group'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
            RiderEscalateUsers.add(u.email);
        }
        grpUserIds.clear();
        
        
        
        
        //Get Accounts
        for(Case_Feedback__c feed:newCaseFeedbackList)
        {
            if(feed.Case_Number__c != null)
                caseIds.add(feed.Case_Number__c);
            if(feed.Account__c != null)
                accountIds.add(feed.Account__c);
        }
        if(caseIds.size()>0)
        {
            for(Case caseNum:[Select id,ownerid from case where id IN :caseIds])
            {
                caseToOwnerIds.put(caseNum.id,caseNum.ownerId);
            }
        }
        //account Team User emails
        if(accountIds.size()>0)
        {                                   
            for(AccountTeamMember accTeam:[Select AccountId,TeamMemberRole,UserId,user.email FROM AccountTeamMember WHERE AccountId IN:accountIds AND TeamMemberRole IN:AccountTeamRoles]){
                if(accountTeamMailIdMap.containsKey(accTeam.AccountId))
                {
                    accountTeamMailIdMap.get(accTeam.AccountId).add(accTeam.user.email);
                }
                else
                    accountTeamMailIdMap.put(accTeam.AccountId,new Set<String>{accTeam.user.email});
            }
            for(Account acclist:[Select Id, OwnerId,Ownership,RFO_AccountOwner__c, Owner.Id, Owner.Email FROM Account where ID in:accountIds]){
                if(accountTeamMailIdMap.containsKey(acclist.id)){
                    accountTeamMailIdMap.get(acclist.id).add(acclist.owner.email);
                }
                else{
                	accountTeamMailIdMap.put(acclist.id, new Set<String>{acclist.owner.Email});
                }
            }
            
        }
        
        
        OrgWideEmailAddress owea = [select id, Address from OrgWideEmailAddress where Address =:System.Label.noreply_trin_net LIMIT 1];
        List<Messaging.SingleEmailMessage> feedbackMails = new List<Messaging.SingleEmailMessage>();
        
        List<EmailTemplate> lstEmailTemplates =  [SELECT Id, Body, Subject, DeveloperName from EmailTemplate where DeveloperName IN ('Case_Feedback_Alert_H', 'Survey_Alert_ComplianceProject_H', 'Survey_Alert_FieldService_CallReport', 'Survey_Alert_PostDelivery_Rider_H', 'Survey_Alert_PostDelivery_Direct_Sale_H') order by DeveloperName];    
       
        Id caseFeedBackSurveyId = lstEmailTemplates[0].Id;
        Id complianceProjectSurveyId = lstEmailTemplates[1].Id;
        Id fieldServiceSurveyId = lstEmailTemplates[2].Id;
        Id postDeliverySurveyDirectSaleId = lstEmailTemplates[3].Id;
        Id postDeliverySurveyId = lstEmailTemplates[4].Id;
        
        for(Case_Feedback__c feed:newCaseFeedbackList)
        {
            List<String> toEmails =  new List<String>();
            if(feed.Account__c != null && accountTeamMailIdMap.size()>0 && accountTeamMailIdMap.containsKey(feed.Account__c))
                toEmails.addAll(accountTeamMailIdMap.get(feed.Account__c));
            toEmails.addAll(allSurveyAlertUsers);
            
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if(feed.Source__c == 'Lease Order Survey'){
                toEmails.addAll(allSurveyEscalateUsers);
                if(feed.Rider_Name__c!=null){
                    if(ratings.contains(feed.Order_delivery_support__c) || ratings.contains(feed.Time_to_receive_rail_car__c) || ratings.contains(feed.Quality_of_rail_car__c) || ratings.contains(feed.Recommend_TrinityRail_on_this_experience__c)){
                        toEmails.addAll(RiderEscalateUsers);
                    }
                	toEmails.addAll(RiderUsers);
                    mail.setTemplateId(postDeliverySurveyId);
                }
                if(feed.Order_Id__c!=null){
                    if(ratings.contains(feed.Order_delivery_support__c) || ratings.contains(feed.Time_to_receive_rail_car__c) || ratings.contains(feed.Quality_of_rail_car__c) || ratings.contains(feed.Recommend_TrinityRail_on_this_experience__c)){
                        toEmails.addAll(OrderEscalateUsers);
                    }
                    toEmails.addAll(OrderUsers);
                    mail.setTemplateId(postDeliverySurveyDirectSaleId);
                }
                
                
            }else if(feed.Source__c=='Compliance Project Survey'){
                if(ratings.contains(feed.C_Satisfaction_with_support_info_receive__c) || ratings.contains(feed.C_Satisfaction_with_out_of_service_time__c) || ratings.contains(feed.C_Satisfaction_with_overall_experience__c) || ratings.contains(feed.C_Satisfaction_with_schedule_provided__c) ||  ratings.contains(feed.C_Satisfaction_with_quality_work_by_shop__c) || ratings.contains(feed.C_Likelihood_to_recommend__c))
                { 
                    toEmails.addAll(allSurveyEscalateUsers);
                    toEmails.addAll(complianceProjectEscalateUsers);
                }
                toEmails.addAll(complianceProjectUsers);
                mail.setTemplateId(complianceProjectSurveyId);
            }else if(feed.Source__c=='Field Service Survey'){
                if(ratings.contains(feed.FS_Overall_Satisfaction_with_FSR_s_visit__c) || ratings.contains(feed.FS_Satisfaction_with_FSR_Preparedness__c) || ratings.contains(feed.FS_Satisfaction_with_FSR_Professionalism__c) || ratings.contains(feed.FS_Satisfaction_with_FSR_Tech_Knowledge__c))
                { 
                    toEmails.addAll(allSurveyEscalateUsers);
                    toEmails.addAll(FieldSurveyEscalateUsers);
                }
                toEmails.addAll(FieldSurveyUsers);
                mail.setTemplateId(fieldServiceSurveyId);
            }else{
                if(ratings.contains(feed.rating__c) || ratings.contains(feed.Likelihood_to_recommend_Cases__c))
                {
                    toEmails.addAll(allSurveyEscalateUsers);
                    toEmails.addAll(caseEscalateUsers);
                }
                mail.setTemplateId(caseFeedBackSurveyId);
            }
            
            //mail.setTemplateId(lstEmailTemplates[0].Id);
            
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(System.Label.GetFeedBack_Contact);// should be a contact to get the merge fields in template
            if ( owea != null ) {
                mail.setOrgWideEmailAddressId(owea.Id);
            }
            system.debug('To Emails '+toEmails);
            mail.setToAddresses(toEmails);
            mail.setWhatId(feed.id); // merge field
            feedbackMails.add(mail);
        }
        try{
       		Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(feedbackMails);
        }catch(Exception e){
            system.debug(e);
        }
    }
}