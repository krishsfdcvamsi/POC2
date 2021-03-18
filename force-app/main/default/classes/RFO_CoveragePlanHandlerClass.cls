/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 4th-Oct-2018
* @Description :Class - RFO_CoveragePlanHandlerClass 
*               Create new coverage plan record on coverage plan change.
**/
public class RFO_CoveragePlanHandlerClass {
    public static Boolean isRecurrsive = true;
    Public static Set<Id> setOfIDs = new Set<Id>();
    Public static Set<Id> setOfCPIDs = new Set<Id>();
    public final static String RFO_ACT = 'RFO_Active';
    public final static String RFO_INACT = 'RFO_Inactive';
    public final static String COM_SALES = 'RFO_Commercial_Sales';
    Private Id activeRecordTypeId = Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get(RFO_ACT).getRecordTypeId();
    private Id inActiveRecordTypeId = Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get(RFO_INACT).getRecordTypeId();
    private Id commSalesRecordTypeId = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get(COM_SALES).getRecordTypeId();
    public static boolean callrepotRecursionCheck = false;
    List<RFO_CoveragePlan__c> activeCPlanListToinsert = new List<RFO_CoveragePlan__c>();
    public final static String APPROVE = 'Approved';
    public final static String REJECT = 'Rejected';
    public final static String NOT_MANAGED = 'Not Managed';
    public final static String SYS_ADMIN = 'System Administrator';
    public final static String NUL = '';
    
    /**
    * @Author      : Accenture
    * Method Name  : callReportForActualContactDate
    * @Created Date: 4th-Oct-2018
    * @Description : Method call from Call Report Trigger when call report Status=Completed, #HashTag=#FaceToFace.
    *                Then it will inactivate existing active Coverage Plan record and creates new coverage plan record with Active.
    **/ 
    public void  callReportForActualContactDate(Map<Id, Call_Report__c> callReportsNewMap,Map<Id, Call_Report__c> callReportsOldMap){

        List<Call_Report__c> callReportsCompletedList = new List<Call_Report__c>();
        Set<ID> accounttsIdsSet = new Set<ID>();
        Map<ID, Call_Report__c> accountWithCallReportMap =new Map<ID, Call_Report__c>();
        List<RFO_CoveragePlan__c> activeCovPlanList = new List<RFO_CoveragePlan__c>();
        List<RFO_CoveragePlan__c> inactiveCPlanListToUpdate = new List<RFO_CoveragePlan__c>();
        List<RFO_CoveragePlan__c> activeCPlanListCallReportsToinsert = new List<RFO_CoveragePlan__c>();
        Map<ID, RFO_CoveragePlan__c> existingActiveCPlanMap = new Map<ID, RFO_CoveragePlan__c>();
        List<String> coveragePlanValuesList = new List<String>{'Maximum', 'High','Medium', 'Low', 'Minimal'}; 
        List<String> cpInsidePlanValuesList = new List<String>{'Inside High','Inside Medium'}; 
        set<Id> accountIds = new set<Id>();
        Map<Id,RFO_CoveragePlan__c> allCovPlan = new Map<Id,RFO_CoveragePlan__c>();
        

              


        for(Call_Report__c cr : callReportsNewMap.values()) {

           if(cr.RFO_Status__c == 'Completed' && cr.RecordTypeId == commSalesRecordTypeId && cr.Call_Report_Completed__c!= true) {

                if(callReportsOldMap!= null){
                    if(cr.RFO_Status__c!=callReportsOldMap.get(cr.Id).RFO_Status__c ){
                        
                            accounttsIdsSet.add(cr.Account__c);
                        
            }
                } else{
                    accounttsIdsSet.add(cr.Account__c);
                }
            }


            //APLHA-69 : Start Changes by MA 
            if(callReportsOldMap != null && cr.Previous_Call_Date__c != null && cr.Call_Date__c <= cr.Previous_Call_Date__c
                && cr.RFO_Status__c == 'Completed' ) {
                //Add Account ID in AccountIds list
                accountIds.add(cr.Account__c);
            }
            //End of changes by MA


        }
            if(!callReportsNewMap.keyset().isEmpty()){
                
                callReportsCompletedList = [SELECT id, Call_Date__c, Account__c, Account__r.ownerId, CreatedDate,RFO_Hashtags__c FROM Call_Report__c 
                                                WHERE RFO_Status__c='Completed' 
                                                AND RecordType.name ='Commercial Sales' 
                                                AND Account__c IN : accounttsIdsSet
                                            ORDER BY Call_Date__c DESC LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())];
            }
        if(!callReportsCompletedList.isEmpty()){
            for(Call_Report__c crRec: callReportsCompletedList){
                if(accountWithCallReportMap.containsKey(crRec.Account__c)) {
                    if(accountWithCallReportMap.get(crRec.Account__c).Call_Date__c < crRec.Call_Date__c)


                        accountWithCallReportMap.put(crRec.Account__c,crRec);
                }
                else {
                    accountWithCallReportMap.put(crRec.Account__c,crRec);
                }


            }
        }
        
        if(!accounttsIdsSet.isEmpty()){
            activeCovPlanList = [SELECT id,RFO_AccountName__c, RFO_AccountOwner__c, RFO_AccountName__r.ownerId, RFO_CoveragePlan__c,RFO_Notes__c,RFO_CoverageRecommendation__c,RFO_NextScheduledContactDate__c,RFO_CoveragePlanApprovalStatus__c,  
                				 RFO_ActualContactDate__c, RFO_ReasonForCoverageChange__c,RFO_CoverageChangeDetails__c,RFO_SalesLastPhoneCallDate__c,  RFO_SalesLastFacetoFaceDate__c,RecordTypeId,RFO_PriorValueOfCoveragePlan__c
                                 FROM RFO_CoveragePlan__c WHERE RFO_AccountName__c IN:accounttsIdsSet 
                                 AND RFO_RecordStatus__c=true LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())];
        
            for(Account a: [Select Id,(Select id,RFO_SalesLastFacetoFaceDate__c from Coverage_Plans__r ORDER BY RFO_SalesLastFacetoFaceDate__c DESC limit 1  ) from Account where Id IN :accounttsIdsSet]){
                allCovPlan.put(a.id, a.Coverage_Plans__r);
            }
        }
        System.debug('activeCovPlanList size() ='+activeCovPlanList.size());
        if(!activeCovPlanList.isEmpty()){
            for(RFO_CoveragePlan__c aCPRec: activeCovPlanList){
                System.debug('Coverage Plan ::'+aCPRec);
                Call_Report__c callReportRec = accountWithCallReportMap.get(aCPRec.RFO_AccountName__c);
                System.debug('Call Report '+callReportRec);
                System.debug('covmap'+allCovPlan);
                System.debug('max value'+ allCovPlan.get(aCPRec.RFO_AccountName__c).RFO_SalesLastFacetoFaceDate__c);
                if( (callReportRec.Call_Date__c > allCovPlan.get(aCPRec.RFO_AccountName__c).RFO_SalesLastFacetoFaceDate__c)  ){
                if(coveragePlanValuesList.contains(aCPRec.RFO_CoveragePlan__c) && callReportRec.RFO_Hashtags__c.contains('#FaceToFace')){
                    if(aCPRec.RFO_CoveragePlanApprovalStatus__c =='Sent For Approval' || aCPRec.RFO_CoveragePlanApprovalStatus__c == 'Pending Approval'){
                        aCPRec.RFO_SalesLastFacetoFaceDate__c = accountWithCallReportMap.get(aCPRec.RFO_AccountName__c).Call_Date__c;
                        aCPRec.RFO_CallReport__c = accountWithCallReportMap.get(aCPRec.RFO_AccountName__c).id;
                        inactiveCPlanListToUpdate.add(aCPRec);
                    }
                    else{
                        aCPRec.RFO_ActualContactDate__c = accountWithCallReportMap.get(aCPRec.RFO_AccountName__c).Call_Date__c;
                        aCPRec.RFO_CallReport__c = accountWithCallReportMap.get(aCPRec.RFO_AccountName__c).id;
                        aCPRec.RFO_RecordStatus__c = false;
                        aCPRec.RecordTypeId = inActiveRecordTypeId;
                        inactiveCPlanListToUpdate.add(aCPRec);
                        existingActiveCPlanMap.put(aCPRec.RFO_AccountName__c, aCPRec);
                    }
                }
                else if(aCPRec.RFO_CoveragePlan__c == NOT_MANAGED && (aCPRec.RFO_CoveragePlanApprovalStatus__c =='Sent For Approval' || aCPRec.RFO_CoveragePlanApprovalStatus__c == 'Pending Approval') && callReportRec.RFO_Hashtags__c.contains('#FaceToFace')){
                    aCPRec.RFO_SalesLastFacetoFaceDate__c = accountWithCallReportMap.get(aCPRec.RFO_AccountName__c).Call_Date__c;
                    aCPRec.RFO_CallReport__c = accountWithCallReportMap.get(aCPRec.RFO_AccountName__c).id;
                    inactiveCPlanListToUpdate.add(aCPRec);
                }
                else if(cpInsidePlanValuesList.contains(aCPRec.RFO_CoveragePlan__c) && !String.isEmpty(callReportRec.RFO_Hashtags__c)){
                    aCPRec.RFO_ActualContactDate__c = accountWithCallReportMap.get(aCPRec.RFO_AccountName__c).Call_Date__c;
                    aCPRec.RFO_CallReport__c = accountWithCallReportMap.get(aCPRec.RFO_AccountName__c).id;
                    aCPRec.RFO_RecordStatus__c = false;
                    aCPRec.RecordTypeId = inActiveRecordTypeId;
                    inactiveCPlanListToUpdate.add(aCPRec);
                    existingActiveCPlanMap.put(aCPRec.RFO_AccountName__c, aCPRec);
                }
                } 
            }
        }
    
    if(!inactiveCPlanListToUpdate.isEmpty()){
        Database.update(inactiveCPlanListToUpdate);
    }
    
    if(!existingActiveCPlanMap.isEmpty()){
        activeCPlanListCallReportsToinsert = createNewActiveCP(existingActiveCPlanMap);
        for(RFO_CoveragePlan__c newCP: activeCPlanListCallReportsToinsert){
            newCP.RFO_SalesLastFacetoFaceDate__c = existingActiveCPlanMap.get(newCP.RFO_AccountName__c).RFO_ActualContactDate__c;
            if(accountIds != null && accountIds.contains(newCP.RFO_AccountName__c))
                newCP.Id = existingActiveCPlanMap.get(newCP.RFO_AccountName__c).Id;
        }
    }       
    
    if(!activeCPlanListCallReportsToinsert.isEmpty()){
        Database.upsert(activeCPlanListCallReportsToinsert);
    }
}

    /**
    * @Author      : Accenture
    * Method Name  : logACallToCreateNewCP
    * @Created Date: 4th-Oct-2018
    * @Description : This method executes from Task trigger. 
    *                When Log a Call record is created for Active Coverage Plan,
    *                then inactivates existing Coverage Plan record and creates new active Coverage Plan record.
    **/
public void logACallToCreateNewCP(Map<Id, Task> TaskNewMap){
    List<Task> logCallList = new List<Task>();
    Map<ID, DateTime> logACallWhatIdsDateMap = new Map<ID, DateTime>();
    List<RFO_CoveragePlan__c> activeCPlanListWithCallLogs = new List<RFO_CoveragePlan__c>();
    Map<ID, RFO_CoveragePlan__c> existingActiveCPlansMap = new Map<ID, RFO_CoveragePlan__c>();
    List<RFO_CoveragePlan__c> inactiveCPlanListToUpdate = new List<RFO_CoveragePlan__c>();
    List<RFO_CoveragePlan__c> activeCPlanListLogaCallToinsert = new List<RFO_CoveragePlan__c>();
    
    if(!TaskNewMap.keyset().isEmpty()){
        logCallList = [SELECT Id, subject, WhatId, WhoId, CreatedDate, CreatedById, Tasksubtype FROM Task WHERE Tasksubtype='Call' AND 
                       ID IN: TaskNewMap.keyset() ORDER BY CreatedDate DESC LIMIT 49999];  
    }
    
    if(!logCallList.isEmpty()){
        for(Task logACall : logCallList ){
            String cp_prefix = Schema.SObjectType.RFO_CoveragePlan__c.getKeyPrefix();
            String idPrefix = String.valueOf(logACall.Whatid).substring(0,3);
            if(cp_prefix.equals(idPrefix)){
                logACallWhatIdsDateMap.put(logACall.Whatid, logACall.CreatedDate);
            }
        }
    }
    
    if(!logACallWhatIdsDateMap.isEmpty()){
        activeCPlanListWithCallLogs = [SELECT id,RFO_AccountName__c, RFO_AccountOwner__c, RFO_AccountName__r.ownerId, RFO_CoveragePlan__c,RFO_Notes__c,RFO_CoverageRecommendation__c,RFO_NextScheduledContactDate__c,RFO_CoveragePlanApprovalStatus__c,  
                                       RFO_ActualContactDate__c, RFO_ReasonForCoverageChange__c,RFO_CoverageChangeDetails__c,RFO_SalesLastPhoneCallDate__c, RFO_SalesLastFacetoFaceDate__c,RecordTypeId, RFO_PriorValueOfCoveragePlan__c
                                       FROM RFO_CoveragePlan__c WHERE ID IN:logACallWhatIdsDateMap.keyset() AND RFO_RecordStatus__c=true AND RFO_CoveragePlanApprovalStatus__c!='Sent For Approval' AND RFO_CoveragePlanApprovalStatus__c != 'Pending Approval' AND RFO_CoveragePlan__c in ('Minimal','Inside High','Inside Medium')  LIMIT 49999 ];
    }
    
    if(!activeCPlanListWithCallLogs.isEmpty()){
        for(RFO_CoveragePlan__c activeCovPlan: activeCPlanListWithCallLogs){
            if(activeCovPlan.RFO_AccountName__c != null){
                DateTime createdDte = logACallWhatIdsDateMap.get(activeCovPlan.id);
                Date actualContactDate = date.newinstance(createdDte.year(), createdDte.month(), createdDte.day());
                activeCovPlan.RFO_ActualContactDate__c = actualContactDate;
                activeCovPlan.RFO_RecordStatus__c = false;
                activeCovPlan.RecordTypeId = inActiveRecordTypeId;
                inactiveCPlanListToUpdate.add(activeCovPlan);
                existingActiveCPlansMap.put(activeCovPlan.RFO_AccountName__c, activeCovPlan);
                
            } 
        }
    }
    
    if(!inactiveCPlanListToUpdate.isEmpty()){
        Database.update(inactiveCPlanListToUpdate);
    }
    
    if(!existingActiveCPlansMap.isEmpty()){
        activeCPlanListLogaCallToinsert = createNewActiveCP(existingActiveCPlansMap);
        for(RFO_CoveragePlan__c newCP: activeCPlanListLogaCallToinsert){
            newCP.RFO_SalesLastPhoneCallDate__c = existingActiveCPlansMap.get(newCP.RFO_AccountName__c).RFO_ActualContactDate__c;
            newCP.RFO_SalesLastFacetoFaceDate__c =  existingActiveCPlansMap.get(newCP.RFO_AccountName__c).RFO_SalesLastFacetoFaceDate__c;
        }
    }
    
    if(!activeCPlanListLogaCallToinsert.isEmpty()){
        Database.insert(activeCPlanListLogaCallToinsert);
    }
}


/**
* @Author      : Accenture
* Method Name  : createNewActiveCP
* @Created Date: 4th-Oct-2018
* @Description : This method is helper for creating active coverage plans. 
*                
**/  

public List<RFO_CoveragePlan__c> createNewActiveCP(Map<ID, RFO_CoveragePlan__c> existingActiveCPlanMap){
    if(!existingActiveCPlanMap.isEmpty()){
        RFO_CoveragePlan__c newCP = new RFO_CoveragePlan__c();
        for(RFO_CoveragePlan__c cp: existingActiveCPlanMap.Values()){
            if(existingActiveCPlanMap.containsKey(cp.RFO_AccountName__c)){
                //RFO_CoveragePlan__c newCP = new RFO_CoveragePlan__c();
                newCP.RFO_RecordStatus__c = true;
                newcp.RecordTypeId = activeRecordTypeId;
                newCP.OwnerId = cp.RFO_AccountName__r.ownerId;
                newCP.RFO_AccountName__c = cp.RFO_AccountName__c;
                if(existingActiveCPlanMap.get(cp.RFO_AccountName__c).RFO_CoveragePlanApprovalStatus__c == 'Sent For Approval' ||
                   existingActiveCPlanMap.get(cp.RFO_AccountName__c).RFO_CoveragePlanApprovalStatus__c == 'Pending Approval'){
                       newCP.RFO_CoveragePlan__c=existingActiveCPlanMap.get(cp.RFO_AccountName__c).RFO_PriorValueOfCoveragePlan__c;
                   }
                else{
                    newCP.RFO_CoveragePlan__c=cp.RFO_CoveragePlan__c;
                }
                newCP.RFO_CoverageRecommendation__c=cp.RFO_CoverageRecommendation__c;
                //Commented based on EPSI-661
                //newCP.RFO_ReasonForCoverageChange__c = cp.RFO_ReasonForCoverageChange__c;
                //newCP.RFO_CoverageChangeDetails__c=cp.RFO_CoverageChangeDetails__c;
                activeCPlanListToinsert.add(newCP);
            }
        }
    }
    return activeCPlanListToinsert;
} // end of createNewActiveCP

/**
* @Author      : Accenture
* @Created Date: 4th-Oct-2018
* @Description : This method calls from Coverage Plan trigger.
*                Creates new Coverage Plan record once changed coverage plan is approved.
**/
public void createNewCPafterCPlanChangeApproved(Map<Id, RFO_CoveragePlan__c> oldCPsMap, Map<Id, RFO_CoveragePlan__c> newCPMap){
    
    //System.debug('--after update -within createNewCPafterCPlanChangeApproved method-');
    List<RFO_CoveragePlan__c> updateCPlanList = new List<RFO_CoveragePlan__c>();
    //List<RFO_CoveragePlan__c> inActiveCPlanList = new List<RFO_CoveragePlan__c>();
    List<RFO_CoveragePlan__c> insertCPlanList = new List<RFO_CoveragePlan__c>();
    List<RFO_CoveragePlan__c> activeCPlanList = new List<RFO_CoveragePlan__c>();
    Set<ID> actIdsSet = new Set<ID>();
    //Map<ID, Date> logCallCreatedDateMap = new Map<ID, Date>();
    Map<ID, RFO_CoveragePlan__c> existingActiveCpMap = new Map<ID, RFO_CoveragePlan__c>();
    //Map<String,RFO_Level20Roles__c> all20RolesCustomSettingsMap = RFO_Level20Roles__c.getAll();
    String roleName;
    if(userinfo.getUserRoleId()!=null)
        roleName=[Select Id,Name from UserRole where Id=:userinfo.getUserRoleId() limit 50000].Name;
    
    activeCPlanList = [SELECT id,RFO_AccountName__c, RFO_AccountOwner__c, RFO_CoveragePlan__c, 
                       RFO_CoverageRecommendation__c, RFO_ActualContactDate__c, RFO_ReasonForCoverageChange__c, RFO_CoverageChangeDetails__c, 
                       //RFO_SalesLastContactDate__c, 
                       RFO_SalesLastFacetoFaceDate__c, RFO_SalesLastPhoneCallDate__c ,
                       CreatedById, CreatedDate, RFO_CoveragePlanApprovalStatus__c, RFO_PriorValueOfCoveragePlan__c,RFO_NextScheduledContactDate__c,RFO_AccountName__r.owner.managerid, RecordTypeId
                       FROM RFO_CoveragePlan__c WHERE ID IN:newCPMap.keyset() AND RFO_RecordStatus__c=true LIMIT 49999 ];
    //System.debug('--activeCPlanList --'+activeCPlanList);
    
    if(!activeCPlanList.isEmpty()){
      //  if(all20RolesCustomSettingsMap.containskey(roleName)){
        for(RFO_CoveragePlan__c cp: activeCPlanList){
            if(!RFO_CoveragePlanHandlerClass.SetOfIDs.contains(cp.Id)){
                RFO_CoveragePlanHandlerClass.SetOfIDs.add(cp.Id);
                
                if(cp.RFO_CoveragePlanApprovalStatus__c==APPROVE){
                    //below thing to be update once approved against the Active Coverage Plan.
                    actIdsSet.add(cp.RFO_AccountName__c);
                    cp.RFO_RecordStatus__c = false;
                    cp.RecordTypeId = inActiveRecordTypeId;

                    //Commenting the below line by Giri for Incident#10228011 EPSI-661

                    //cp.RFO_CoveragePlan__c = cp.RFO_PriorValueOfCoveragePlan__c;
                    if(cp.RFO_PriorValueOfCoveragePlan__c == NOT_MANAGED){
                        cp.RFO_SalesLastFacetoFaceDate__c = null ;
                        cp.RFO_SalesLastPhoneCallDate__c = null ;
                        cp.RFO_NextScheduledContactDate__c = null;
                        cp.RFO_PlanningStatus__c = NUL;
                    }
                    //System.debug('--with in approved --'+cp);
                    
                }else if(cp.RFO_CoveragePlanApprovalStatus__c==REJECT && cp.RFO_PriorValueOfCoveragePlan__c != null){
                    cp.RFO_CoveragePlan__c = cp.RFO_PriorValueOfCoveragePlan__c;
                    if(cp.RFO_PriorValueOfCoveragePlan__c == NOT_MANAGED){
                        cp.RFO_SalesLastFacetoFaceDate__c = null ;
                        cp.RFO_SalesLastPhoneCallDate__c = null ;
                        cp.RFO_NextScheduledContactDate__c = null;
                        cp.RFO_PlanningStatus__c = NUL;
                    }
                    cp.RFO_PriorValueOfCoveragePlan__c=NUL;
                    //System.debug('--with in rejected --'+cp);
                    //System.debug('--4--'+cp);
                }
                updateCPlanList.add(cp);
                existingActiveCpMap.put(cp.Id,cp);
                //System.debug('--after addinng cps updateCPlanList--'+updateCPlanList);
                //System.debug('--after addinng cps existingActiveCpMap--'+existingActiveCpMap);
            }
         }
       // }
    }
    
    //csCPcheck();
    
    if (!updateCPlanList.isEmpty()){
        database.update(updateCPlanList);
    }
    
    //System.debug('--@@@@@@@@@@@updateCPlanList--'+updateCPlanList);
    RFO_CoveragePlan__c newCP = new RFO_CoveragePlan__c();
    for(RFO_CoveragePlan__c CP: updateCPlanList){
        
        if(CP.RFO_CoveragePlanApprovalStatus__c==APPROVE ){
            //System.debug('--within insert--');
            if(actIdsSet.contains(cp.RFO_AccountName__c) ){
                //System.debug('--#$#$#$%--');
                
                newCP.RFO_RecordStatus__c = true;
                newcp.RecordTypeId = activeRecordTypeId;
                newCP.OwnerId = existingActiveCpMap.get(cp.Id).RFO_AccountName__r.ownerId;
                newCP.RFO_AccountName__c = existingActiveCpMap.get(cp.Id).RFO_AccountName__c;
                newCP.RFO_CoveragePlan__c = newCPMap.get(cp.Id).RFO_CoveragePlan__c;
                newCP.RFO_CoverageRecommendation__c=existingActiveCpMap.get(cp.Id).RFO_CoverageRecommendation__c;

                //Commented for EPSI-661

                //newCP.RFO_ReasonForCoverageChange__c=existingActiveCpMap.get(cp.Id).RFO_ReasonForCoverageChange__c;
                //newCP.RFO_CoverageChangeDetails__c=existingActiveCpMap.get(cp.Id).RFO_CoverageChangeDetails__c;
                
                DateTime dtTime = existingActiveCpMap.get(cp.Id).createdDate;
                Date createdDate = date.newinstance(dtTime.year(), dtTime.month(), dtTime.day());
                newCP.RFO_SalesLastFacetoFaceDate__c = existingActiveCpMap.get(cp.Id).RFO_SalesLastFacetoFaceDate__c ;
                newCP.RFO_SalesLastPhoneCallDate__c = existingActiveCpMap.get(cp.Id).RFO_SalesLastPhoneCallDate__c ;
                if(existingActiveCpMap.get(cp.Id).RFO_CoveragePlan__c == NOT_MANAGED && newCPMap.get(cp.Id).RFO_CoveragePlan__c != NOT_MANAGED){
                    //System.debug('#######SSTT3');
                    newCP.RFO_SalesLastFacetoFaceDate__c = System.Today() ;
                    newCP.RFO_SalesLastPhoneCallDate__c = System.Today() ;
                }
                
                if(newCPMap.get(cp.Id).RFO_CoveragePlan__c == NOT_MANAGED){
                    newCP.RFO_SalesLastFacetoFaceDate__c = null ;
                    newCP.RFO_SalesLastPhoneCallDate__c = null ;
                    newCP.RFO_NextScheduledContactDate__c = null;
                    newCP.RFO_PlanningStatus__c = NUL;
                }
                //System.debug('--4--'+newCP);
                insertCPlanList.add(newCP);
            }
        }
    }
    
    //System.debug('--4-()(&^-'+insertCPlanList);
    if(insertCPlanList.size()>0)
        database.insert(insertCPlanList);
    //System.debug('--4-#$#-'+insertCPlanList);
    
} // end of method createNewCPafterCPlanChangeApproved 

/**
* @Author      : Accenture
* @Created Date: 4th-Oct-2018
* @Description : This method calls from Coverage Plan trigger when System Admin creates new active Coverage Plan record.
**/
public void createNewCPwithAdmin(Map<Id, RFO_CoveragePlan__c> oldCPMap, Map<Id, RFO_CoveragePlan__c> newCPMap){
    //try{
    List<RFO_CoveragePlan__c> cpList = new List<RFO_CoveragePlan__c>();
    List<RFO_CoveragePlan__c> cpOwnerUpdateList = new List<RFO_CoveragePlan__c>();      
    Set<Id> accountIds = new Set<Id>();
    Set<Id> cpIds = new Set<Id>();
    //Map<Id, UserId> actOwnerIds = new Map<Id, UserId>();
    List<RFO_CoveragePlan__c> newCPsList = new List<RFO_CoveragePlan__c>();
    String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId() limit 50000].Name;
    
    if(profileName == SYS_ADMIN){ 
        /* newCPsList =[select Id,RFO_SalesLastFacetoFaceDate__c,RFO_CoveragePlan__c,RFO_SalesLastPhoneCallDate__c,RFO_NextScheduledContactDate__c,RFO_PlanningStatus__c, RFO_RecordStatus__c, RFO_AccountName__c,RFO_AccountName__r.ownerId, RecordTypeId from RFO_CoveragePlan__c where Id IN: newCPMap.KeySet()  LIMIT 50000];*/
        //System.debug('****newCPsList*****' +newCPsList);
        for(RFO_CoveragePlan__c cp : [select Id,RFO_SalesLastFacetoFaceDate__c,RFO_CoveragePlan__c,RFO_SalesLastPhoneCallDate__c,RFO_NextScheduledContactDate__c,RFO_PlanningStatus__c, RFO_RecordStatus__c, RFO_AccountName__c,RFO_AccountName__r.ownerId, RecordTypeId from RFO_CoveragePlan__c where Id IN: newCPMap.KeySet()  LIMIT 50000]){
            //System.debug('*****FOR ******');
            //System.debug('*****IF ******'+RFO_CoveragePlanHandlerClass.SetOfIDs.contains(cp.Id));
            
            if(!RFO_CoveragePlanHandlerClass.SetOfCPIDs.contains(cp.Id)){
                RFO_CoveragePlanHandlerClass.SetOfCPIDs.add(cp.Id);
                if(cp.RFO_RecordStatus__c == true){
                    accountIds.add(cp.RFO_AccountName__c);
                    cp.OwnerId = cp.RFO_AccountName__r.ownerId;
                    cp.RecordTypeId = activeRecordTypeId;
                    //System.debug('@@@@@RFO_A '+ cp);
                    if(cp.RFO_CoveragePlan__c == NOT_MANAGED){
                        cp.RFO_SalesLastFacetoFaceDate__c = null ;
                        cp.RFO_SalesLastPhoneCallDate__c = null ;
                        cp.RFO_NextScheduledContactDate__c = null;
                        cp.RFO_PlanningStatus__c = NUL;
                    }
                    cpIds.add(cp.id);
                    cpOwnerUpdateList.add(cp);
                }
            }
        }
        
        /* cpList = [SELECT id,RFO_RecordStatus__c, RecordTypeId FROM RFO_CoveragePlan__c 
                  WHERE RFO_RecordStatus__c=true AND RFO_AccountName__c IN:accountIds AND Id NOT IN:cpIds limit 50000]; */
        for(RFO_CoveragePlan__c cp: [SELECT id,RFO_RecordStatus__c, RecordTypeId FROM RFO_CoveragePlan__c 
                  WHERE RFO_RecordStatus__c=true AND RFO_AccountName__c IN:accountIds AND Id NOT IN:cpIds limit 50000]){
            cp.RFO_RecordStatus__c=false;
            cp.RecordTypeId = inActiveRecordTypeId;
            cpOwnerUpdateList.add(cp);
        }
        if (!cpOwnerUpdateList.isEmpty()){
            database.update(cpOwnerUpdateList);
        }
    } 
} // end of method createNewCPwithAdmin

/**
* @Author      : Accenture
* @Created Date: 4th-Oct-2018
* @Description : This method calls from Coverage Plan trigger when Account Owner's Manager changes Coverage Plan on active Coverage Plan record.
**/
public void createNewCPforManager (Map<Id, RFO_CoveragePlan__c> oldCPsMap, Map<Id, RFO_CoveragePlan__c> newCPsMap){
    List<RFO_CoveragePlan__c> newCPlist = new List<RFO_CoveragePlan__c>();
    List<RFO_CoveragePlan__c> cplnsInsertList = new List<RFO_CoveragePlan__c>();
    List<RFO_CoveragePlan__c> newCPlistToUpdate = new List<RFO_CoveragePlan__c>();
    Map<id,RFO_CoveragePlan__c> oldcpMAP = new Map<id,RFO_CoveragePlan__c>();
    Map<id,RFO_CoveragePlan__c> newcpCreateMap = new Map<id,RFO_CoveragePlan__c>();
    
    Map<String,RFO_Level20Roles__c> all20RolesMap = RFO_Level20Roles__c.getAll();
    String roleName;
    if(userinfo.getUserRoleId()!=null)
        roleName=[Select Id,Name from UserRole where Id=:userinfo.getUserRoleId() limit 50000].Name;
    //System.debug('*******roleName*******'+roleName);
    //System.debug('*******all20RolesMap.containskey(roleName)*******'+all20RolesMap.containskey(roleName));
    //System.debug('*******oldCPsMap*******'+oldCPsMap);
    //System.debug('*******newCPsMap*******'+newCPsMap);
    //System.debug('*******STST*******'+newCPsMap);
    if(oldCPsMap.values() != null){
        for(RFO_CoveragePlan__c oldCP: oldCPsMap.values()){
            oldcpMAP.put(oldCP.id,oldCP);
        }
    }
    /* newCPlist = [SELECT id,RFO_AccountName__c, RFO_AccountOwner__c, RFO_CoveragePlan__c, 
                 RFO_CoverageRecommendation__c, RFO_ActualContactDate__c, RFO_ReasonForCoverageChange__c, RFO_CoverageChangeDetails__c, 
                 //RFO_SalesLastContactDate__c, 
                 RFO_SalesLastFacetoFaceDate__c, RFO_SalesLastPhoneCallDate__c ,
                 CreatedById, CreatedDate, RFO_CoveragePlanApprovalStatus__c, RFO_PriorValueOfCoveragePlan__c,RFO_AccountName__r.ownerid, RFO_AccountName__r.owner.managerid, RecordTypeId
                 FROM RFO_CoveragePlan__c WHERE ID IN:newCPsMap.keyset() AND RFO_RecordStatus__c=true LIMIT 50000]; */
    for(RFO_CoveragePlan__c newCP: [SELECT id,RFO_AccountName__c, RFO_AccountOwner__c, RFO_CoveragePlan__c, 
                 RFO_CoverageRecommendation__c, RFO_ActualContactDate__c, RFO_ReasonForCoverageChange__c, RFO_CoverageChangeDetails__c, 
                 //RFO_SalesLastContactDate__c, 
                 RFO_SalesLastFacetoFaceDate__c, RFO_SalesLastPhoneCallDate__c ,
                 CreatedById, CreatedDate, RFO_CoveragePlanApprovalStatus__c, RFO_PriorValueOfCoveragePlan__c,RFO_AccountName__r.ownerid, RFO_AccountName__r.owner.managerid, RecordTypeId
                 FROM RFO_CoveragePlan__c WHERE ID IN:newCPsMap.keyset() AND RFO_RecordStatus__c=true LIMIT 50000]){
        if((newCP.RFO_CoveragePlanApprovalStatus__c != REJECT) && 
           newCP.RFO_CoveragePlan__c != oldcpMAP.get(newCP.id).RFO_CoveragePlan__c && 
           (userinfo.getUserId() == newCP.RFO_AccountName__r.owner.managerid || all20RolesMap.containskey(roleName))) {
               
               newCP.RFO_RecordStatus__c=false;
               newCP.RecordTypeId = inActiveRecordTypeId;
               newCP.RFO_CoveragePlan__c = oldcpMAP.get(newCP.id).RFO_CoveragePlan__c;
               newCP.RFO_AccountName__c=oldcpMAP.get(newCP.id).RFO_AccountName__c;
               //System.debug('IF LOOP'+newCP.RFO_RecordStatus__c);
               newCPlistToUpdate.add(newCP);
               newcpCreateMap.put(newCP.id, newCP);
               //System.debug('******newCPlistToUpdateST'+newCPlistToUpdate);
           }
        
        else if((newCP.RFO_CoveragePlanApprovalStatus__c == REJECT) && 
                newCP.RFO_CoveragePlan__c != oldcpMAP.get(newCP.id).RFO_CoveragePlan__c && 
                (userinfo.getUserId() == newCP.RFO_AccountName__r.owner.managerid || all20RolesMap.containskey(roleName))) {
                    
                    newCP.RFO_RecordStatus__c=false;
                    newCP.RecordTypeId = inActiveRecordTypeId;
                    newCP.RFO_CoveragePlan__c = oldcpMAP.get(newCP.id).RFO_CoveragePlan__c;
                    newCP.RFO_AccountName__c=oldcpMAP.get(newCP.id).RFO_AccountName__c;
                    //System.debug('ELSE IF LOOP'+newCP.RFO_RecordStatus__c);
                    newCPlistToUpdate.add(newCP);
                    newcpCreateMap.put(newCP.id, newCP);
                    //System.debug('******newCPlistToUpdateST'+newCPlistToUpdate);
                }
    }
    if(!newCPlistToUpdate.isEmpty()){
        database.update(newCPlistToUpdate);
    }
    
    //System.debug('#######newCPlistToUpdateST'+newCPlistToUpdate);
    RFO_CoveragePlan__c newCP = new RFO_CoveragePlan__c();
    for(RFO_CoveragePlan__c nCP: newCPlistToUpdate){
        if(newcpCreateMap.containskey(ncp.id)){
            //RFO_CoveragePlan__c newCP = new RFO_CoveragePlan__c();
            newCP.RFO_RecordStatus__c = true;
            newcp.RecordTypeId = activeRecordTypeId;
            newCP.OwnerId = newcpCreateMap.get(ncp.Id).RFO_AccountName__r.ownerId;
            newCP.RFO_AccountName__c = newcpCreateMap.get(ncp.Id).RFO_AccountName__c;
            newCP.RFO_CoveragePlan__c = newCPsMap.get(ncp.Id).RFO_CoveragePlan__c;
            newCP.RFO_CoverageRecommendation__c=newcpCreateMap.get(ncp.Id).RFO_CoverageRecommendation__c;
            //Commented EPSI-661
            newCP.RFO_ReasonForCoverageChange__c=newcpCreateMap.get(ncp.Id).RFO_ReasonForCoverageChange__c;
            newCP.RFO_CoverageChangeDetails__c=newcpCreateMap.get(ncp.Id).RFO_CoverageChangeDetails__c;
            
            DateTime dtTime = newcpCreateMap.get(ncp.Id).createdDate;
            newCP.RFO_SalesLastFacetoFaceDate__c = newcpCreateMap.get(ncp.Id).RFO_SalesLastFacetoFaceDate__c ;
            newCP.RFO_SalesLastPhoneCallDate__c = newcpCreateMap.get(ncp.Id).RFO_SalesLastPhoneCallDate__c ;
            //System.debug('#######SSTT1nCP.Id'+nCP.Id);
            //System.debug('#######SSTT1oldcpMAP'+oldcpMAP);
            //System.debug('#######SSTT1newCPsMap'+newCPsMap);
            //System.debug('#######SSTT1'+oldcpMAP.get(ncp.id).RFO_CoveragePlan__c);
            //System.debug('#######SSTT2'+newCPsMap.get(ncp.Id).RFO_CoveragePlan__c);
            //System.debug('#######SSTT1'+oldcpMAP.get(ncp.id).RFO_CoveragePlanApprovalStatus__c);
            //System.debug('#######SSTT2'+newCPsMap.get(ncp.Id).RFO_CoveragePlanApprovalStatus__c);
            //System.debug('#######SSTT3.1userinfo.getUserId()'+userinfo.getUserId());
            //System.debug('#######SSTT3.2newCP.RFO_AccountName__r.ownerid'+oldcpMAP.get(ncp.id).RFO_AccountName__r.OwnerId);
            System.debug('#######SSTT3.3newCP.RFO_AccountName__r.ownerid'+newcpCreateMap.get(ncp.Id).RFO_AccountName__r.ownerId);
            System.debug('#######SSTT3.3newCP.RFO_AccountName__r.ownerid'+newcpCreateMap.get(ncp.Id).RFO_AccountName__r.owner.ManagerId);
            if(oldcpMAP.get(ncp.id).RFO_CoveragePlan__c == NOT_MANAGED && oldcpMAP.get(ncp.id).RFO_CoveragePlanApprovalStatus__c == APPROVE){
                //System.debug('#######SSTT3');
                newCP.RFO_SalesLastFacetoFaceDate__c = System.Today() ;
                newCP.RFO_SalesLastPhoneCallDate__c = System.Today() ;
            }
            if(oldcpMAP.get(ncp.id).RFO_CoveragePlan__c == NOT_MANAGED && (userinfo.getUserId() == newcpCreateMap.get(ncp.Id).RFO_AccountName__r.ownerId || (userinfo.getUserId() != newcpCreateMap.get(ncp.Id).RFO_AccountName__r.ownerId && userinfo.getUserId() == newcpCreateMap.get(ncp.Id).RFO_AccountName__r.owner.managerid))){
                //system.debug('#######SSTT4');
                newCP.RFO_SalesLastFacetoFaceDate__c = System.Today() ;
                newCP.RFO_SalesLastPhoneCallDate__c = System.Today() ;
            }
            if(newCPsMap.get(ncp.Id).RFO_CoveragePlan__c == NOT_MANAGED){
                newCP.RFO_SalesLastFacetoFaceDate__c = null ;
                newCP.RFO_SalesLastPhoneCallDate__c = null ;
                newCP.RFO_NextScheduledContactDate__c = null;
                newCP.RFO_PlanningStatus__c = NUL;
            }
            //System.debug('***ncp***'+newCP);
            cplnsInsertList.add(newCP);
        }
    }
    if(!cplnsInsertList.isEmpty()){
        database.insert(cplnsInsertList);
    }
} // end of method createNewCPforManager

    public void coverageCalculations(list< RFO_CoveragePlan__c> newCpList){
        
        set<Id> accountIds = new set<Id>();
        set<Id> parentIds = new set<Id>();
        
        for(RFO_CoveragePlan__c cpSO : newCpList) {
            if(cpSO.RFO_AccountName__c != null) {
                accountIds.add(cpSO.RFO_AccountName__c);
            }
        }
        
        if(accountIds.size() > 0) {
            for(account acc : [SELECT Id FROM Account WHERE Id IN : accountIds AND ParentId = null]) {
                parentIds.add(acc.Id);
            }
            system.debug('parentIds.size()::'+parentIds.size());
            if(parentIds.size()>0) {
                map<id,decimal> accountMap = RFO_CoverageUtility.getAccountFleet(parentIds);
                map<id,decimal> ridersCount = RFO_CoverageUtility.getRidersCount(parentIds);
                map<id,decimal> opportunityCount = RFO_CoverageUtility.getOpportunitesCount(parentIds);
            	map<id,decimal> coverageMultipler = RFO_CoverageUtility.coverageMultipler;
            	Decimal totalValue;
                system.debug('accountMap::'+accountMap+'   ridersCount::'+ridersCount+'  opportunityCount::'+opportunityCount+'   coverageMultipler::'+coverageMultipler);
            
            	for(RFO_CoveragePlan__c cpSO : newCpList) {
                    if(cpSO.RFO_Coverage_Calculated__c==null){
                        cpSO.RFO_Coverage_Calculated__c='Cvgplan Calc::';
                    }
                	totalValue = 0;
                    cpSO.RFO_Coverage_Calculated__c= cpSO.RFO_Coverage_Calculated__c +'  ttlVal = 0';
                    
                	if(accountMap.containsKey(cpSO.RFO_AccountName__c)) {
                    	totalValue += accountMap.get(cpSO.RFO_AccountName__c);
                        cpSO.RFO_Coverage_Calculated__c = cpSO.RFO_Coverage_Calculated__c + ' Acct Ttl::'+ accountMap.get(cpSO.RFO_AccountName__c);
                	}
                	if(opportunityCount.containsKey(cpSO.RFO_AccountName__c)) {
                    	totalValue += opportunityCount.get(cpSO.RFO_AccountName__c);
                        cpSO.RFO_Coverage_Calculated__c = cpSO.RFO_Coverage_Calculated__c + ' Opp Cnt::'+ opportunityCount.get(cpSO.RFO_AccountName__c);
                	}
                	if(ridersCount.containsKey(cpSO.RFO_AccountName__c)) {
                    	totalValue += ridersCount.get(cpSO.RFO_AccountName__c);
                        cpSO.RFO_Coverage_Calculated__c = cpSO.RFO_Coverage_Calculated__c + ' Rider Cnt::'+ ridersCount.get(cpSO.RFO_AccountName__c);
                	}
                    cpSO.RFO_Coverage_Calculated__c = cpSO.RFO_Coverage_Calculated__c + ' ttl bef mltpr::'+ totalValue;
                	if(coverageMultipler.containsKey(cpSO.RFO_AccountName__c)) {
                    	totalValue = totalValue * coverageMultipler.get(cpSO.RFO_AccountName__c);
                        cpSO.RFO_Coverage_Calculated__c = cpSO.RFO_Coverage_Calculated__c + ' cvgMltpr ::'+ coverageMultipler.get(cpSO.RFO_AccountName__c);
                	}
                    system.debug('totalValue::'+totalValue);
                    cpSO.RFO_Coverage_Calculated__c = cpSO.RFO_Coverage_Calculated__c + ' Final totalValue::'+ totalValue;
                	if(totalValue >= 0) {
                    	cpSO.RFO_CoverageRecommendation__c = RFO_CoverageUtility.validateRange(totalValue);
                    	system.debug('@@recomendation = '+cpSO.RFO_CoverageRecommendation__c);
                	}
            	}
        	}
            else {
                for(RFO_CoveragePlan__c cpSO : newCpList) { 
                    cpSO.RFO_CoverageRecommendation__c = 'Not Managed';
                }
            }
        }
        getCoveragePlanValue(accountIds,newCpList);
    }
    //EPSI-534 : Start Changes by FA
    public static void getCoveragePlanValue(Set<Id> accountIdSet,list< RFO_CoveragePlan__c> newCpList){

        Map<Id,RFO_CoveragePlan__c> accCpmap = new  Map<Id,RFO_CoveragePlan__c>();
        for(Account a : [select Id,(select Id,RFO_CoveragePlan__c from Coverage_Plans__r ORDER BY CreatedDate DESC LIMIT 1 ) from Account where Id IN :accountIdSet])
        {
            if(a.Coverage_Plans__r.size()>0){
               accCpmap.put(a.Id,a.Coverage_Plans__r) ;  
            }
        }
        for(RFO_CoveragePlan__c cpSO : newCpList){
            if(accCpmap.containsKey(cpSO.RFO_AccountName__c)){
                cpSO.RFO_CoveragePlan__c= accCpmap.get(cpSO.RFO_AccountName__c).RFO_CoveragePlan__c ;
            }
            else{
                cpSO.RFO_CoveragePlan__c= cpSO.RFO_CoverageRecommendation__c;
            }
        }
    }
     //EPSI-534 : End Changes by FA
} //end of RFO_CoveragePlanHandlerClass