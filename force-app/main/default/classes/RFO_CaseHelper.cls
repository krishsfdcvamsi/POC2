/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 8th Sep 2018
* @Modified Date: 21st May 2019
* @Modified Date: 10th Sep 2020 for Customer Disputes EPSI 362/363
* @Modified Reason: bypass the Case assignment for New car Existing Car recordtypes.-Sabeeha Syed
* @Description :This class is to assign case owner as Customer Delivery Manager/Deliver account team role users.
If none of account team members found then it will assign to Customer Delivery Queue.

History
*
* 15JUL2019 | I Martinez | FB:SIT-W2-IM-071519 | The caseAssignment method was originally designed for the record types created
during Phase 1/2. Additional record types have been created in phase 3 and as part 
of the Customer Digital project. This modification will ensure that only the cases
wih the intended record types are assigned with this method  (RFO_Case and RFO_Closed_Case).
*/

public with sharing class RFO_CaseHelper {
    /**
* Assigning a case owner to Customer_Delivery queue when a case is created with recordtype "Case"
**/
    public static void caseAssignment (List<Case> caseList){
        Map<Id, Id> contactIdsMap = new Map<Id, Id>();
        List<Id> accountIds = new List<Id>{};
            List<case> cselistToUpdate = new List<Case>();
        Map<Id, Id> accountDeptOwnerRetainMap = new Map<Id, Id>();
        Map<Id, Id> contactsMapToUpdate = new Map<Id, Id>();
        Id stdCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CASE) != null ? Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CASE).getRecordTypeId() : null;
        Id closedCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CLOSED_CASE) != null ? Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_CLOSED_CASE).getRecordTypeId() : null;
        
        Set<Id> grpUserIds = new Set<Id>();
        for(GroupMember member:[SELECT UserOrGroupId  fROM GroupMember where group.developername  ='Case_No_owner_Change'])
            grpUserIds.add(member.UserOrGroupId);
        if(grpUserIds.size()>0)
        {
            for(User u:[SELECT id,email  fROM user where id IN:grpUserIds])
                accountDeptOwnerRetainMap.put(u.id, u.id);
        }
        grpUserIds.clear();
        
        if(caseList != null){
            for (Case theCase: [select id,contactid,accountId,RFO_CaseAcountsCDMCDDFlag__c,ownerId 
                                from case 
                                where id in:caseList 
                                and (recordTypeId in (:stdCaseRT,:closedCaseRT)) 
                                and Origin != 'Portal'
                                Limit 49999]){ 
                                    cselistToUpdate.add(theCase);
                                    if(theCase.ContactId != null){
                                        contactIdsMap.put(theCase.ContactId, null);
                                    }
                                }
        }
        
        if(!cselistToUpdate.isEmpty() && !contactIdsMap.isEmpty()){
            for(Contact cont: [select AccountId from Contact where id IN: contactIdsMap.keySet() Limit 50000]){
                accountIds.add(cont.AccountId);
                contactIdsMap.put(cont.Id, cont.AccountId);
            }    
            
            Group queueInfo = [select Id from Group where  Type =: RFO_Constant.QUEUE AND DeveloperName =: RFO_Constant.CUSTOMER_DELIVERY_QUEUE LIMIT 1];
            Map<id, AccountTeamMember> acctsToUpdate = new Map<id, AccountTeamMember>([Select Id, UserId,TeamMemberRole,AccountId From AccountTeamMember Where AccountId IN :accountIds AND (TeamMemberRole =: RFO_Constant.CUSTOMER_DELIVERY_MANAGER OR TeamMemberRole =: RFO_Constant.CUSTOMER_DELIVERY_DIRECTOR) Limit 50000] );
            
            if(acctsToUpdate.size()>0){
                for(AccountTeamMember accTM: acctsToUpdate.values()){
                    if(accTM.TeamMemberRole.equals(RFO_Constant.CUSTOMER_DELIVERY_MANAGER)){
                        contactsMapToUpdate.put(accTM.AccountId, accTM.UserId);
                        break;
                    }
                    else if(accTM.TeamMemberRole.equals(RFO_Constant.CUSTOMER_DELIVERY_DIRECTOR)){
                        contactsMapToUpdate.put(accTM.AccountId, accTM.UserId);
                    }
                }
            }
            
            list<case> casesToUpdate = new list<Case>();
            for (Case theCase: cselistToUpdate) {
                Id accId = contactIdsMap.get(theCase.ContactId);
                if(contactsMapToUpdate.containsKey(accId)){
                    if(!accountDeptOwnerRetainMap.containsKey(theCase.ownerId)){
                        theCase.OwnerId = contactsMapToUpdate.get(accId);
                        
                    }
                    theCase.RFO_CaseAcountsCDMCDDFlag__c = true;
                    casesToUpdate.add(theCase); 
                }
                else {
                    if(!accountDeptOwnerRetainMap.containsKey(theCase.ownerId)){
                        theCase.OwnerId = queueInfo.id;
                    }
                    theCase.RFO_CaseAcountsCDMCDDFlag__c = false;
                    casesToUpdate.add(theCase);
                    
                }
                
            }
            try {
                
                if(!casesToUpdate.isEmpty()){
                    system.enqueueJob(new RFO_UpdateCasesQueueable(casesToUpdate));
                }
            }
            catch(DmlException e) {
                RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.CASE_OBJECT,
                                                       RFO_Constant.TRIGER,'RFO_CaseHelper','caseAssignment');           
            }
            
        }
    }
    public static void Account_CaseUpdate(List<Case> caseList){
        for(Case c:caseList){
            String strRecordDevName = Schema.SObjectType.case.getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName();
            System.debug('Record Developer Name ====> '+strRecordDevName);
            if(c.AccountId !=null &&(strRecordDevName =='General_Request'||strRecordDevName == 'Service_Request' || strRecordDevName == 'CDX_Closed_Case'|| strRecordDevName == 'Billing_Contact_Change' )){
                c.Account_Case__c = c.AccountId;
            }
            
        }
    }
    
    public static void validateAccountContactRelation(List<Case> caseList){
        Set<Id> accountIds = new Set<Id>();
        for(Case c : caseList){
            accountIds.add(c.AccountId);
        }
        List<Account> accountList = [Select Id, Name, owner.email, (Select  ContactId, Contact.FirstName,  Contact.LastName,  Contact.Email,  Contact.Name,  Contact.RFO_ContactRole__c  From AccountContactRelations) from Account acc where Id = :accountIds];        
        String invalidContactErrMsg = label.RFO_Case_Contact_Invalid;
        for(Case c : caseList){
            boolean contactExists = false;
            for(Account acc : accountList){
                if(c.AccountId==acc.Id){
                    for(AccountContactRelation acr: acc.AccountContactRelations){
                        if(acr.ContactId==c.ContactId){
                            contactExists = true;
                        }
                    }
                }
            }
            String strRecordDevName = Schema.SObjectType.case.getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName();
            if(!contactExists && accountList.size()>0 && strRecordDevName!='RFO_ExistingCarChangeRequest' && strRecordDevName!='RFO_AmortizationRevisionChangeRequest'&& strRecordDevName!='RFO_NewCarChangeRequest'){
                c.addError(invalidContactErrMsg, false);
            }
        }
    }
    
    //Calculate Business hours for Closed/Resolving Dispute/Awaiting on Customer/Awaiting on Payment
    //@Author Giri 
    public static void updateStatusAndClockTime(List<Case> caseList, Map<Id, Case> oldCases){
        
        BusinessHours bh = [SELECT Id, Name FROM BusinessHours WHERE IsDefault=true];
        Task[] tasks = [select Id, WhatId from Task where WhatId in :caseList];
        for(Case c : caseList){
            String strRecordDevName = Schema.SObjectType.case.getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName();
            Case oldcase = oldCases.get(c.Id);
            if(oldcase.status!=label.Case_Closed && c.status==label.Case_Closed){
                calculateBusinesshoursdaysForClosed(c,bh,tasks);    
            }
            
            if(oldcase.status==label.Case_Resolving_Dispute && c.status==label.Case_Awaiting_On_Customer){
                c.RFO_Resolving_Dispute_End_Time__c = DateTime.now();
                c.RFO_Awaiting_on_customer_start_time__c=DateTime.now();
                if(c.RFO_Resolving_Dispute_Start_Time__c==null){
                    c.RFO_Resolving_Dispute_Start_Time__c=c.CreatedDate;
                }
                if(c.RFO_Resolving_Dispute_Start_Time__c!=null && c.RFO_Resolving_Dispute_End_Time__c!=null){
                    c.RFO_Resolving_Dispute_Age_Hours__c=calculateBusinessHours(bh,c.RFO_Resolving_Dispute_Start_Time__c,c.RFO_Resolving_Dispute_End_Time__c);
                    c.RFO_Resolving_Dispute_Age_Days__c=calculateBusinessDays(bh,c.RFO_Resolving_Dispute_Start_Time__c,c.RFO_Resolving_Dispute_End_Time__c);    
                }
                
            }
            if(oldcase.status==label.Case_Resolving_Dispute && c.status==label.Case_Awaiting_On_Payment){
                if(c.RFO_Resolving_Dispute_Start_Time__c==null){
                    c.RFO_Resolving_Dispute_Start_Time__c=c.CreatedDate;
                }
                c.RFO_Resolving_Dispute_End_Time__c = DateTime.now();
                c.RFO_Awaiting_on_customer_start_time__c=DateTime.now();
                c.RFO_Awaiting_on_customer_End_time__c=DateTime.now();
                c.RFO_Awaiting_on_payment_start_time__c=DateTime.now();
            }
            if(oldcase.status==label.Case_Resolving_Dispute && c.status==label.Case_Closed){
                if(c.RFO_Resolving_Dispute_Start_Time__c==null){
                    c.RFO_Resolving_Dispute_Start_Time__c=c.CreatedDate;
                }
                c.RFO_Resolving_Dispute_End_Time__c = DateTime.now();
                c.RFO_Awaiting_on_customer_start_time__c=DateTime.now();
                c.RFO_Awaiting_on_customer_End_time__c=DateTime.now();
                c.RFO_Awaiting_on_payment_start_time__c=DateTime.now();
                c.RFO_Awaiting_on_payment_end_time__c=DateTime.now();
            }
            
            if(oldcase.status==label.Case_Awaiting_On_Customer && c.status==label.Case_Awaiting_On_Payment){
                c.RFO_Awaiting_on_customer_end_time__c = DateTime.now();
                c.RFO_Awaiting_on_payment_start_time__c=DateTime.now();
                if(c.RFO_Awaiting_on_customer_start_time__c!=null && c.RFO_Awaiting_on_customer_end_time__c!=null){
                    c.RFO_Awaiting_on_customer_age_hours__c=calculateBusinessHours(bh,c.RFO_Awaiting_on_customer_start_time__c,c.RFO_Awaiting_on_customer_end_time__c);
                    c.RFO_Awaiting_on_customer_age_days__c=calculateBusinessDays(bh,c.RFO_Awaiting_on_customer_start_time__c,c.RFO_Awaiting_on_customer_end_time__c);    
                }
            }
            if(oldcase.status==label.Case_Awaiting_On_Customer && c.status==label.Case_Closed){
            	c.RFO_Awaiting_on_customer_end_time__c = DateTime.now();
                c.RFO_Awaiting_on_payment_start_time__c=DateTime.now();
                c.RFO_Awaiting_on_payment_end_time__c=DateTime.now();
            }
            /*
            if(oldcase.status==label.Case_Awaiting_On_Customer && c.status==label.Case_Commercial_Decision){
                c.RFO_Awaiting_on_customer_end_time__c=DateTime.now();
                c.RFO_Commercial_Decision_Start_Time__c = DateTime.now();
                if(c.RFO_Awaiting_on_customer_start_time__c!=null && c.RFO_Awaiting_on_customer_end_time__c!=null){
                    c.RFO_Awaiting_on_customer_age_hours__c=calculateBusinessHours(bh,c.RFO_Awaiting_on_customer_start_time__c,c.RFO_Awaiting_on_customer_end_time__c);
                    c.RFO_Awaiting_on_customer_age_days__c=calculateBusinessDays(bh,c.RFO_Awaiting_on_customer_start_time__c,c.RFO_Awaiting_on_customer_end_time__c);    
                }
            }
            if(oldcase.status==label.Case_Commercial_Decision && c.status==label.Case_Awaiting_On_Payment){
                c.RFO_Commercial_Decision_End_Time__c = DateTime.now();
                c.RFO_Awaiting_on_payment_start_time__c=DateTime.now();
                if(c.RFO_Commercial_Decision_Start_Time__c!=null && c.RFO_Commercial_Decision_End_Time__c!=null){
                    c.RFO_commercial_decision_age_hours__c=calculateBusinessHours(bh,c.RFO_Commercial_Decision_Start_Time__c,c.RFO_Commercial_Decision_End_Time__c);
                    c.RFO_commercial_decision_age_days__c=calculateBusinessDays(bh,c.RFO_Commercial_Decision_Start_Time__c,c.RFO_Commercial_Decision_End_Time__c);    
                }
            }*/
            if(oldcase.status==label.Case_Awaiting_On_Payment && c.status==label.Case_Closed){
                c.RFO_Awaiting_on_payment_end_time__c = DateTime.now();
                if(c.RFO_Awaiting_on_payment_start_time__c!=null && c.RFO_Awaiting_on_payment_end_time__c!=null){
                    c.RFO_Awaiting_on_payment_age_hours__c=calculateBusinessHours(bh,c.RFO_Awaiting_on_payment_start_time__c,c.RFO_Awaiting_on_payment_end_time__c);
                    c.RFO_Awaiting_on_payment_age_days__c=calculateBusinessDays(bh,c.RFO_Awaiting_on_payment_start_time__c,c.RFO_Awaiting_on_payment_end_time__c);    
                }
            }    
            
            
            
        }
    }
    //@Author Giri 
    public static void calculateBusinesshoursdaysForClosed(Case c, BusinessHours bh,Task[] tasks){
        if(c.status==label.Case_Closed && c.ClosedDate!=null){
            c.Task_Associated__c = 0;
            boolean taskAssociatedFlag = false;
            for (Task t : tasks) {
                if(t.WhatId == c.id){
                    c.Task_Associated__c = 1;
                    taskAssociatedFlag = true;
                }
                
            }
            c.FCR_Case__c=0;
            Decimal CaseAgeBusinessHours = BusinessHours.diff(bh.Id, c.CreatedDate, c.ClosedDate)/3600000.0;
            Double CaseAgeBusinessHoursRounded = CaseAgeBusinessHours.setScale(2,System.RoundingMode.HALF_UP);
            c.Case_Age_Business_Hour__c = CaseAgeBusinessHoursRounded;
            if(CaseAgeBusinessHoursRounded <= 8.00 && !taskAssociatedFlag){
                c.FCR_Case__c=1;
            }
            Decimal caseAgeBusinessDays = CaseAgeBusinessHours/8; 
            //System.debug('Business Days Before Rounded ::'+caseAgeBusinessDays);
            Double caseAgeBusinessDaysRounded = caseAgeBusinessDays.setScale(2,System.RoundingMode.HALF_UP);
            System.debug('Business Days ::'+caseAgeBusinessDaysRounded);
            c.Case_Age_In_Business_Days__c = caseAgeBusinessDaysRounded;
        }
    }
    
    public static Double calculateBusinessHours(BusinessHours bh, DateTime open, DateTime close){
        Decimal CaseAgeBusinessHours = BusinessHours.diff(bh.Id, open, close)/3600000.0;
        Double CaseAgeBusinessHoursRounded = CaseAgeBusinessHours.setScale(2,System.RoundingMode.HALF_UP);
        return CaseAgeBusinessHoursRounded;
    }
    
    public static Double calculateBusinessDays(BusinessHours bh, DateTime open, DateTime close){
        Decimal CaseAgeBusinessHours = BusinessHours.diff(bh.Id, open, close)/3600000.0;
        Decimal caseAgeBusinessDays = CaseAgeBusinessHours/8; 
        Double caseAgeBusinessDaysRounded = caseAgeBusinessDays.setScale(2,System.RoundingMode.HALF_UP);
        return caseAgeBusinessDaysRounded;
    }
 
  //Changed by RG Start Alpha-676
    /**
    * @Author      : Ramesh
    * @Description : Checking if the checkbox is true/false & Task will be created only upon check box is True from false.
    * */
    public static void newCarAlertEstimatingStart(List<Case> caseList, Map<Id, Case> oldCases){
        // Variables
        TaskService tskService = new TaskService();
        List<Task> lstTask = new List<Task>();
        
        // Looping case list
        for(Case c : caseList){
            // adding filter conditions
            Id newCarRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_NewCarChangeRequest').getRecordTypeId();
            if(oldCases != null && oldCases.get(c.id) != null 
                && oldCases.get(c.id).New_Car_Alert_Estimating_Start__c != c.New_Car_Alert_Estimating_Start__c  
                && c.New_Car_Alert_Estimating_Start__c 
                && c.RecordTypeId == newCarRecType 
                && (c.Status == RFO_Constant.Material_Cost_Review || c.Status == RFO_Constant.Operations_Review) ){
                
                // Adding task in list by calling createTaskEscalation method 
                lstTask.add(tskService.createTaskEscalation('New Car Alert Estimating', c.Escalation__c,Null, NULL, NULL, c.id, Null,  NULL));
            }
        }
        
        // checking list is not empty
        if(lstTask.size() > 0){
            insert lstTask;
        }
    }
    //Changed by RG End Alpha-676

    

    /* Added By Vihari ALPHA - 677
	 * Method to create Alerts
     * @param cases - list of cases for which alerts need to be created
     */
    public static void createAlert(List<Case> cases){
        AlertService aService = new AlertService();
        map<String,Alert_Setting__mdt> alertSettingsMap = aService.mapAlertSetting;
        Map<Id, List<String>> orderEngineersMap = new Map<Id,List<String>>();
        Set<Id> orderIds = new Set<Id>();
        List<Alert__c> alerts = new List<Alert__c>();
        String engReviewAlert = Label.Case_Engineering_Review_AlertSetting_Name;
        for(Case c:cases){
           orderIds.add(c.RFO_OrderID__c); 
        }
        
        for(Project_Engineer__c pe:[Select id,Engineer__c,Order__c from Project_Engineer__c where Order__c IN :orderIds]){
            if(!orderEngineersMap.containsKey(pe.Order__c))orderEngineersMap.put(pe.Order__c,new List<String>{pe.Engineer__c});
            
            else orderEngineersMap.get(pe.Order__c).add(pe.Engineer__c);
        }
        
        for(Case c: cases){
            
		   String immediateAlertList = aService.getImmediateAlertRecipients(engReviewAlert,orderEngineersMap.get(c.RFO_OrderID__c));
          
           String alert1List = aService.getAlert1Recipients(engReviewAlert,orderEngineersMap.get(c.RFO_OrderID__c));
               
           String alert2List = aService.getAlert2Recipients(engReviewAlert,orderEngineersMap.get(c.RFO_OrderID__c));

            

            
           Alert__c alert = aService.createAlert(engReviewAlert, c.Order_FirstShipWeek__c, immediateAlertList,
                               alert1List, alert2List, (String)c.Id, '', '');
           alerts.add(alert);
        }
        
        try{
            database.insert(alerts);
        }catch(Exception e){
            throw e;
        }
        
    }
 
}