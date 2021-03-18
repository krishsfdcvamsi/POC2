public class RFO_ProjectsTriggerHandler {
    
    public static void updateContactId(List<RFO_Projects__c> projectList){
        /*List<Id> accountIds = new List<Id>();
for(RFO_Projects__c project: projectList){
if(project.RFO_Account__c!=null ){
accountIds.add(project.RFO_Account__c);
}
}

if(accountIds.size()>0){
List<Account> accounts = [Select Id, (Select Id,FirstName, LastName, RFO_ContactRole__c From Contacts) from Account where Id IN : accountIds];
for(RFO_Projects__c project: projectList){
for(Account objAcc : accounts){
if(objAcc.Id == project.RFO_Account__c){
system.debug('Contact List ::'+objAcc.Contacts.size());
for(Contact objCon: objAcc.Contacts){
system.debug('objCon.RFO_ContactRole__c =='+objCon.RFO_ContactRole__c);
if(objCon.RFO_ContactRole__c!=null && objCon.RFO_ContactRole__c.contains('Compliance Project Survey Contact')){
System.debug('Inside contact exists');
project.Survey_Contact__c = objCon.Id;
project.Survey_Contact_Id__c = objCon.Id;
}
}
}
}
}
}*/
        
    }
    
    public static void processSurvey(Map<Id,RFO_Projects__c> mapProjectsOld, List<RFO_Projects__c> projectList){
        /*system.debug('Inside Process Survey');
Date compliance_survey_start_date_const = date.valueOf('2019-12-01');
String compliance_survey_start_date_str = label.Compliane_Survey_Start_Date;
String compliance_survey_start_month_str = label.Compliane_Survey_Start_Month;
String compliance_survey_start_year_str = label.Compliane_Survey_Start_Year;
String Compliance_Survey_URL = label.Compliance_Survey_URL;
String Compliance_Survey_urlStr = Compliance_Survey_URL.trim();


try{
string compliance_survey_start_date_string = compliance_survey_start_year_str + '-' + compliance_survey_start_month_str + '-' + compliance_survey_start_date_str ;
compliance_survey_start_date_const = date.valueOf(compliance_survey_start_date_string);
}catch(Exception e){
compliance_survey_start_date_const = date.valueOf('2019-12-01');
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
List<Account> accounts = [Select Id, (Select Id,FirstName, LastName, Email, Name, RFO_ContactRole__c, Compliance_Survey_Sent_Time__c  From Contacts) from Account where Id IN : accountIds];
List<AccountTeamMember> accountTeams = [Select AccountId,TeamMemberRole,UserId,user.email FROM AccountTeamMember WHERE AccountId IN:accountIds AND TeamMemberRole IN:AccountTeamRoles];
List<EmailTemplate> lstEmailTemplates =  [SELECT Id, HTMLValue, Subject, DeveloperName from EmailTemplate where DeveloperName IN ('Survey_for_Compliance_Project', 'Compliance_Survey_contact_not_exists_in_account_alert') order by DeveloperName];    
Id notifyCDMId = lstEmailTemplates[0].Id;
Id surveyTemplateId = lstEmailTemplates[1].Id;
String surveyEmailTemplateHTMLMain = lstEmailTemplates[1].HTMLValue;
//system.debug('surveyEmailTemplateHTMLMain==>'+surveyEmailTemplateHTMLMain);
List<Contact> updateContactList = new List<Contact>();
OrgWideEmailAddress owea = [select id, Address from OrgWideEmailAddress where Address =:System.Label.noreply_trin_net LIMIT 1];
List<Messaging.SingleEmailMessage> surveyMails = new List<Messaging.SingleEmailMessage>();
List<Messaging.SingleEmailMessage> contactNotExistsMails = new List<Messaging.SingleEmailMessage>();
List<String> escalationEmails = new List<String>();
escalationEmails.add('alagiri.muthiah@trin.net');
for(AccountTeamMember atm:accountTeams){
accountTeamMap.put(atm.AccountId,atm);
}

for(RFO_Projects__c proj: projectList){
system.debug('2: projects size '+projectList.size());
for(Account acc : accounts){
if(acc.Id == proj.RFO_Account__c){
system.debug('Account Id and Project Account are same - Inside If');
system.debug('proj.Last_Car_Ship_Date__c=='+proj.Last_Car_Ship_Date__c);
system.debug('compliance_survey_start_date_const=='+compliance_survey_start_date_const);
system.debug('proj.Last_Car_Ship_Date__c plus 10 days =='+proj.Last_Car_Ship_Date__c + 10);
String demandDriver = proj.RFO_DemandDriverName__c;
String projectName = proj.Name;
system.debug('DEMAND DRIVER NAME =='+demandDriver);
system.debug('PROJECT NAME =='+projectName);
List<String> toEmails =  new List<String>();
List<Contact> allSurveyContacts = new List<Contact>();
List<Contact> eligibleSurveyContacts = new List<Contact>();
if(proj.Last_Car_Ship_Date__c!=null && proj.Last_Car_Ship_Date__c + 10 < date.today()){
system.debug('Last car ship date plus 10 days is less than today date');
}
if(proj.Last_Car_Ship_Date__c!=null && proj.Last_Car_Ship_Date__c + 10 > date.today()){
system.debug('Last car ship date plus 10 days is greater than today date');
}
if(proj.Last_Car_Ship_Date__c > compliance_survey_start_date_const){
system.debug('Last car ship date is greater than compliance start date');
}
if(proj.Last_Car_Ship_Date__c < compliance_survey_start_date_const){
system.debug('Last car ship date is less than compliance start date');
}
for(Contact objCon: acc.Contacts){
if(objCon.RFO_ContactRole__c!=null && 
objCon.RFO_ContactRole__c.contains(label.Survey_Contact_Project_Compliance)){
system.debug('Inside when contact exists - email is '+objCon.Email);
allSurveyContacts.add(objCon);


if(
(proj.RFO_DemandDriverName__c=='Compliance' || proj.RFO_DemandDriverName__c=='HM-251') && 
proj.Last_Car_Ship_Date__c!=null && 
proj.Last_Car_Ship_Date__c > compliance_survey_start_date_const && 
proj.Last_Car_Ship_Date__c + 10 < date.today() && 
proj.Survey_Sent_Time__c==null && 
objCon.Email!=null && 
(objCon.Compliance_Survey_Sent_Time__c==null || 
(objCon.Compliance_Survey_Sent_Time__c!=null && 
objCon.Compliance_Survey_Sent_Time__c.Date().daysBetween(system.today()) > 60)))
{
System.debug('Inside the condition of 10 days');
eligibleSurveyContacts.add(objCon);
proj.Survey_Contact_Id__c = objCon.Id;
}
System.debug('Outside the condition of 10 days');

}
}//contacts for a project
//NOW SEND THE EMAIL 
system.debug('eligibleSurveyContacts size ::'+eligibleSurveyContacts.size() + ' for account == '+proj.RFO_Account__c);
system.debug('allSurveyContacts size ::'+allSurveyContacts.size() + ' for account == '+proj.RFO_Account__c);
String contactIds = '';

for(Contact objCon: eligibleSurveyContacts){
String surveyEmailTemplateHTML = surveyEmailTemplateHTMLMain;
contactIds = contactIds + objCon.Id + '||';
//String UrlStr = Compliance_Survey_urlStr + '?Projects_ID='+proj.Id+'&Projects_Demand_Driver_Name='+proj.RFO_DemandDriverName__C+'&Projects_Project_Name='+proj.Name+'&gf_q[7502214][15110015]='+objCon.Name+'&gf_q[7502214][15110016]='+proj.Account_Name__c+'&gf_q[7502214][15110017]='+objCon.Email;

String UrlStringFromConstant = Compliance_Survey_urlStr;
String UrlStrProjId = UrlStringFromConstant.replace('<PROJECT_ID>',String.valueOf(proj.Id)).trim();
String UrlStrProjName = UrlStrProjId.replace('<PROJECT_Name>',String.valueOf(proj.Name)).trim();
String UrlStrContactId = UrlStrProjName.replace('<CONTACT_ID>',String.valueOf(objCon.Id)).trim();
String UrlStrAccountId = UrlStrContactId.replace('<ACCOUNT_ID>',String.valueOf(proj.RFO_Account__c)).trim();
String UrlStrFullName = UrlStrAccountId.replace('<CONTACT_FULL_Name>',String.valueOf(objCon.Name)).trim();
String UrlStrEmail = UrlStrFullName.replace('<CONTACT_EMAIL>',String.valueOf(objCon.Email)).trim();
String UrlStrCompany = UrlStrEmail.replace('<CONTACT_COMPANY>',String.valueOf(proj.Account_Name__c)).trim();

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
if ( owea != null ) {
mail.setOrgWideEmailAddressId(owea.Id);
}
toEmails.add(objCon.email);
toEmails.add('alagiri.muthiah@trin.net');
mail.setSubject('Please take a short survey about your recent '+proj.RFO_DemandDriverName__c+' shopping event');
mail.setToAddresses(toEmails);
mail.setWhatId(proj.id); // merge field
surveyMails.add(mail);
//Set Survey Sent Time
proj.Survey_Sent_Time__c = system.now();
objCon.Compliance_Survey_Sent_Time__c = system.now();
updateContactList.add(objCon);
system.debug('toEmails :: '+toEmails);
}//forloop

if((proj.RFO_DemandDriverName__c=='Compliance' || proj.RFO_DemandDriverName__c=='HM-251') &&
proj.Last_Car_Ship_Date__c!=null &&
proj.Last_Car_Ship_Date__c > compliance_survey_start_date_const &&
proj.Last_Car_Ship_Date__c + 10 < date.today() &&
proj.Survey_Sent_Time__c==null &&
allSurveyContacts.size()<1
){
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setTemplateId(notifyCDMId);
mail.setSaveAsActivity(false);
mail.setTargetObjectId(System.Label.GetFeedBack_Contact);// should be a contact to get the merge fields in template
if ( owea != null ) {
mail.setOrgWideEmailAddressId(owea.Id);
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
system.debug('updateContactList.size()=='+updateContactList.size());
if(updateContactList.size()>0){
update updateContactList;
system.debug('Updated the contact object');
}*/
    } 
    public void OnBeforeInsert(List<RFO_Projects__c> newlstRec)
    {
        ProjectTriggerHelper.sendNotification(newlstRec,new Map<id,RFO_Projects__c>(),true,false);  //ALPHA-645, Lakshmi Malepati 
               
    }
    public void OnAfterInsert(List<RFO_Projects__c> newlstRec, Map <Id,RFO_Projects__c> newRecMap)
    {
        // ProjectTriggerHelper.stopOrderNotifications(newlstRec,new Map<id,RFO_Projects__c>(),true,false);  //ALPHA-581, Lakshmi Malepati    
        Map<String,RFO_Projects__c> projectsMap = new Map<String,RFO_Projects__c>();
        for(RFO_Projects__c newProject : newlstRec){
            if(newProject.SOW_Proposal_Status__c == 'Submitted'){
                projectsMap.put(newProject.Id,newProject);
            }
        }
        if(projectsMap.size()>0){
            ProjectTriggerHelper.sendSOWBellAlert(projectsMap);      
        }
        ProjectTriggerHelper.exitForIsProject(newRecMap);//ALPHA-1748, Lakshmi Malepati
    }
    public void OnBeforeUpdate(List<RFO_Projects__c> newlstRec, Map <Id,RFO_Projects__c> newRecMap,List<RFO_Projects__c> listOldRec, Map <Id,RFO_Projects__c> oldRecMap)
    {
        System.debug('handler Check');
        ProjectTriggerHelper.sendNotification(newlstRec,oldRecMap,false,true); //ALPHA-645, Lakshmi Malepati 
           }
    public void OnAfterUpdate(List<RFO_Projects__c> newlstRec, Map <Id,RFO_Projects__c> newRecMap,List<RFO_Projects__c> listOldRec, Map <Id,RFO_Projects__c> oldRecMap)
    {
        // ProjectTriggerHelper.stopOrderNotifications(newlstRec,oldRecMap,false,true); //ALPHA-581, Lakshmi Malepati 
        Map<String,RFO_Projects__c> projectsMap = new Map<String,RFO_Projects__c>();
        for(RFO_Projects__c newProject: newlstRec){
            if(newProject.SOW_Proposal_Status__c == 'Submitted' && oldRecMap.get(newProject.Id).SOW_Proposal_Status__c != 'Submitted'){
                projectsMap.put(newProject.Id,newProject);
            }
        }
        if(projectsMap.size()>0){
            ProjectTriggerHelper.sendSOWBellAlert(projectsMap);
        }
        ProjectTriggerHelper.exitForIsProject(newRecMap);//ALPHA-1748, Lakshmi Malepati
    }
    public void OnBeforeDelete(List<RFO_Projects__c> listOldRec, Map <Id,RFO_Projects__c> oldrecMap)
    {
        
    }
    public void OnAfterDelete(List<RFO_Projects__c> listOldRec, Map <Id,RFO_Projects__c> oldrecMap)
    {
    }
    /* Method Name: alertEngineers
* Created By: Ramesh
* Created Date: November 2020
* Jira: ALpha- 587 / 588
* Purpose: Engg users need system generated notification based on the following trigger event, "When the Project Workstation in RF1 is moved from Customer Delivery to Engineering.
*/
    
    public static void alertEngineers(List<RFO_Projects__c> newList, Map<id,RFO_Projects__c> oldMap){
        // declaring Variables
        TaskService tskService = new TaskService();
        List<Id> orderIds = new List<Id>(); 
        List<Id> orderIdsAlertI = new List<Id>(); 
        List<Id> orderIdsAlertII = new List<Id>(); // Alpha 588
        List<Id> userIdsI = new List<Id>();
        List<Id> userIdsII = new List<Id>(); // Alpha 588
        List<Alert__c> lstAlert = new List<Alert__c>();
        AlertService alertService = new AlertService();
        String projectId = '';
        String assignedTo = '';
        String Alert1List = '';
        String notificationMergeTitle = '';
        String notificationMergeBody = '';
        String ProjectName  = '';
        String ProjectNumber  = '';
        Alert__c alertObj;
        
        // Looping the new list of RFO_Projects__c
        for(RFO_Projects__c projRec : newList){
            // Checking RFO_Workstation__c is Engineering
            if(oldMap.get(projRec.Id).RFO_Workstation__c ==  RFO_Constant.Customer_Service && projRec.RFO_Workstation__c ==  RFO_Constant.Engineering && projRec.SOW_Proposal_Status__c != RFO_Constant.Submitted){
                // Assigning the values
                orderIds.add(projRec.Order__c); 
                projectId = projRec.id;
                ProjectNumber = 'Project# '+projRec.RFO_ProjectId__c;
                orderIdsAlertI.add(projRec.Order__c);
            }
            
            // Alpha 588 Start
            if(projRec.Start_Project_Workflow_Alert__c && oldMap.get(projRec.Id).Start_Project_Workflow_Alert__c != projRec.Start_Project_Workflow_Alert__c){
                // Assigning the values
                orderIds.add(projRec.Order__c); 
                projectId = projRec.id;
                ProjectNumber = 'Project# '+projRec.RFO_ProjectId__c;
                orderIdsAlertII.add(projRec.Order__c);
            }
            // Alpha 588 End
        }
        
        // Checking orderIds is not null
        if(orderIds.size() > 0){
            // Getting userids
            for(Project_Engineer__c objProjEng : [SELECT Engineer__c,Order__c from Project_Engineer__c where Order__c in: orderIds]){
                if(orderIdsAlertI.contains(objProjEng.Order__c))  userIdsI.add(objProjEng.Engineer__c); // Alpha-587
                if(orderIdsAlertII.contains(objProjEng.Order__c))  userIdsII.add(objProjEng.Engineer__c); // Alpha-588
            }
        }
        
        // Checking userIds is not null
        if(userIdsI.size() > 0){ 
            lstAlert.add(alertService.createAlert('Project_Workstation_Alert', null, string.join(userIdsI,';')+';', string.join(userIdsI,';')+';', null, projectId, ProjectNumber, null));
        }
        
        // Checking userIds is not null
        if(userIdsII.size() > 0){ 
            lstAlert.add(alertService.createAlert('Project_Workstation_Alert_II', null, string.join(userIdsII,';')+';', string.join(userIdsII,';')+';', null, projectId, ProjectNumber, null));
        }
        
        if(lstAlert.size() > 0){
            // Inserting Alert
            insert lstAlert;
        }
    }
    
    /* Method Name: alertEngineers
* Created By: Ramesh
* Created Date: November 2020
* Jira: ALpha- 587 / 588
* Purpose: Stop the alert when SOW Proposal Status equals 'submitted' and stop sending the alert when the Project Workstation has been changed to any other value other than 'Engineering'.
*/
    public static void stopAlertEngineers(List<RFO_Projects__c> newList){
        
        // Looping the new list of RFO_Projects__c
        for(RFO_Projects__c projRec : newList){
            // Checking RFO_Workstation__c is Engineering
            if(projRec.SOW_Proposal_Status__c == RFO_Constant.Submitted && projRec.Stop_Alert__c != true){
                projRec.Stop_Alert__c = true;
            }
            if(projRec.RFO_Workstation__c != RFO_Constant.Engineering)
                projRec.Start_Project_Workflow_Alert__c = false;  
            // Alpha 588 Start
            if(projRec.RFO_Workstation__c !=  RFO_Constant.Engineering){
                projRec.Stop_Alert_II__c = true;
            } else {
                projRec.Stop_Alert_II__c = false;
            }
            // Alpha 588 End
        }
        
    }
}