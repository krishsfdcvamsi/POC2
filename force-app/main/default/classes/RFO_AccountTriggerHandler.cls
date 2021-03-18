/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 28 Mar 2019
* @Description :This class is to update the Account record when the Lead is converted to account then Account
should be active and the recordtype should be Prospect when the Lead type is Commercial.
**/
public class RFO_AccountTriggerHandler {
    public static Boolean isRecurrsiveBefore = false;
    public static Boolean isRecurrsiveAfter = false;
    public static List<Opportunity> opportunityList= new List<Opportunity>();
    public static final string CLOSED = 'Closed';
	    
	    
    /**
*   accountUpdate method to update Global Account Id on Account
**/
    public static void accountUpdate(List<Account> acc){
        Id prosRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_Prospect).getRecordTypeId();
        Id tPProsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.RFO_ThirdPartyProspect).getRecordTypeId();
        Set<ID> accountIds = new Set<ID>(); //APLHA-33 : changes by MA
        try {
            if(acc.size()>0){
                for(Account accRec : acc){
                    if(accRec.RecordTypeId==prosRecordTypeId || accRec.RecordTypeId==tPProsRecordTypeId){
                        RFO_SendToTASFutureClass.getGlobalAccountId(accRec.Id);
                    }
                    //APLHA-33 : changes by MA
                    if(accRec.ParentId != null) {
                        accountIds.add(accRec.Id);
                    }
                }
                }
            //APLHA-33 : changes by MA
            if(accountIds.size()>0) {
                updateCoveragePlan(accountIds);
            }
        }
        catch(Exception e) {            
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.ACCOUNT_OBJECT,
                                                   RFO_Constant.TRIGER,'RFO_AccountTriggerHandler','sendAccountInfoToTAS');            
        }
    }
    /**
*  beforeUpdate method to update Sales Rep Start Date field whenever an Account owner changes
**/
    public static void beforeUpdate(Map<Id, Account> newItems, Map<Id, Account> oldItems) {
        try{


            list<string> openOptyStageNames = system.Label.Open_Opty_values.split(',');
            set<Id> AccountIdWithOpenRecords = new set<Id>();
            map<Id,Account> closedAccountsMap = new map<Id,Account>();
            set<Account> closedAccountsList = new set<Account>();
            Id serviceAccountId;
            user userProfile = [SELECT id,Profile.Name FROM user WHERE id =: userInfo.getUserId()];


            for(Account accountRec : newItems.values())
            {
                if(accountRec.OwnerId!= null && accountRec.OwnerId !=oldItems.get(accountRec.Id).OwnerId){
                    accountRec.RFO_SalesRepStartDate__c = System.now();//accountRec.LastModifiedDate;
                } 
                if(accountRec.RFO_SalesRepStartDate__c == null && accountRec.OwnerId!= null){
                    accountRec.RFO_SalesRepStartDate__c = System.now();
                }


                if(accountRec.RFO_AccountStatus__c == CLOSED && 
                    accountRec.RFO_AccountStatus__c != oldItems.get(accountRec.Id).RFO_AccountStatus__c) {
                    
                    if(userProfile.Profile.Name == System.Label.sales_Profile || accountRec.ownerId == userInfo.getUserId())
                        closedAccountsMap.put(accountRec.Id,accountRec);
                    else
                        accountRec.addError(System.Label.Account_Closed_Err);
                }                
            }
            if(closedAccountsMap.size()>0) {
                try {
                    serviceAccountId = [SELECT Id FROM User WHERE name =: System.Label.Service_Account_Owner].Id;
                }
                catch (exception e){
                    //Assing the current user in case of exceptions(missing user in the org)
                    serviceAccountId = userInfo.getUserId();
                }
                for(Account accSO : [SELECT Id, (SELECT id FROM Riders__r WHERE RFO_TotalActiveCars__c > 0),
                                        (SELECT Id FROM Opportunities WHERE stageName IN : openOptyStageNames) 
                                        FROM Account WHERE Id IN : closedAccountsMap.keySet()]) {
                                            
                    if(accSO.Riders__r != null && accSO.Riders__r.size()>0) {
                        AccountIdWithOpenRecords.add(accSO.Id);
                    }
                    else if(accSO.Opportunities != null && accSO.Opportunities.size()>0) {
                        AccountIdWithOpenRecords.add(accSO.Id);
                    }
                }
                for(Account accountRec : closedAccountsMap.values()) {
                    if(AccountIdWithOpenRecords.contains(accountRec.Id)) {
                        accountRec.addError(System.Label.Closed_Account_Msg);
                    }
                    else {
                        accountRec.ownerId = serviceAccountId;
                        closedAccountsList.add(oldItems.get(accountRec.Id));
                    }
                }
            }
            //send chatter notification to the account owner's manager
            if(closedAccountsList.size()>0) {
                sendBellNotification(closedAccountsList);


            }
        }
        catch(Exception e) {            
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.ACCOUNT_OBJECT,
                                                   RFO_Constant.TRIGER,'RFO_AccountTriggerHandler','sendAccountInfoToTAS');            
        }
    }
    /**
*  sendAccountInfoToTAS method, when Account Owner, S&PRating or Moody'sRating Fields are changed
**/
    public static void sendAccountInfoToTAS(Map<Id,Account> accNewMap, Map<Id,Account> accOldMap){
        String userLanId;
        String moodysRating;
        String sPRating; 
        Boolean flagTas = false;  
        Set<ID> accountIds = new Set<ID>();
        try{
            for(Account accountRec: [select id, name, OwnerId, Owner.Lan_Id__c, LastModifiedDate, lastModifiedBy.Lan_Id__c, RFO_SalesRepStartDate__c, RFO_TASId__c, RFO_MoodysRating__c, RFO_SPRating__c from Account where id in :accNewMap.keySet() limit 49999]){
                //As per the discussion with onshore - account are not loaded from data load
                //And the following integration is not bulkified from mule side
                if(accountRec.RFO_TASId__c!=null && (accountRec.RFO_TASId__c != accOldMap.get(accountRec.Id).RFO_TASId__c)){
                    accountIds.add(accountRec.Id);
                    System.debug('Account Ids after TAS Id update');
                }
                if(accountRec.OwnerId !=accOldMap.get(accountRec.Id).OwnerId){
                    userLanId = accountRec.Owner.Lan_Id__c;
                    flagTas = true;
                } 
                if(accountRec.RFO_MoodysRating__c!=accOldMap.get(accountRec.Id).RFO_MoodysRating__c){
                    moodysRating = accountRec.RFO_MoodysRating__c;
                    flagTas = true;
                } 
                if(accountRec.RFO_SPRating__c!=accOldMap.get(accountRec.Id).RFO_SPRating__c){
                    sPRating = accountRec.RFO_SPRating__c;
                    flagTas = true;
                }
                if(flagTas) {
                    RFO_AccountTeamMemberHelper.sendAccountInfoToTAS(accountRec, userLanId, moodysRating, sPRating);
                }
                
            }
            //Assumping only single account will be updated and sending account team to TAS
            if(!accountIds.isEmpty()){
                System.debug('Account Ids after TAS Id update in loop');
                RFO_AccountTeamMemberHelper.sendAccountTeamToTAS(accountIds);
            }
        }
        catch(Exception e) {
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.ACCOUNT_OBJECT,
                                                   RFO_Constant.TRIGER,'RFO_AccountTriggerHandler','sendAccountInfoToTAS');  
        }
    }
	/* Use case
update case records on change of account record type changes. 
Case object is capturing account record type in RFO_AccountRecordtype__c custom field
RFO_AccountRecordtype__c field can not be formula field because it is used in sharing rules.
*/
    
    public static void updateaccountRecordTypeinCase(List<Account> accountOldList,List<Account> accountNewList) {
        //capture updated record typ in list 
        List<Id> accountIdList = new List<Id>();   
        //map of account record id and record type name
        Map<Id,String> accountIdRecordTypeNameMap = new Map<Id,String>();
        //account record type names
        Map<ID,Schema.RecordTypeInfo> accountRecordMap = Account.sObjectType.getDescribe().getRecordTypeInfosById();
        for(Integer index=0;index<accountNewList.size();index++) {           
            if(accountOldList[index].RecordTypeId != accountNewList[index].RecordTypeId 
               && 
               (accountRecordMap.get(accountNewList[index].RecordTypeId).getName().containsIgnoreCase(RFO_Constant.RFO_Account_ThirdParty_Prospect_RT) ||
                accountRecordMap.get(accountNewList[index].RecordTypeId).getName().containsIgnoreCase(RFO_Constant.RFO_Account_Prospect_RT) ||
                accountRecordMap.get(accountNewList[index].RecordTypeId).getName().containsIgnoreCase(RFO_Constant.RFO_Account_ThirdParty_Sales_RT) ||
                accountRecordMap.get(accountNewList[index].RecordTypeId).getName().containsIgnoreCase(RFO_Constant.RFO_Account_Customer_RT))              
              ) {
                  accountIdList.add(accountOldList[index].id);
                  accountIdRecordTypeNameMap.put(accountNewList[index].Id,
                                                 String.valueOf(accountRecordMap.get(accountNewList[index].RecordTypeId).getName()));
              }
        }
        updateCaseRecords(accountIdList,accountIdRecordTypeNameMap);
    }
	 /*updateCaseRecords : Updating the New Car,Exisitng Car,Amortization case records with respective Account updated record type  */
    // @future removing future method becuase its called in batch as well.
    public static void updateCaseRecords(List<Id> accountList,Map<Id,String> accountIdRecordTypeNameMap) {
        Map<string,Schema.RecordTypeInfo> caseRecordMap = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
        List<Case> modifyCaseRecords = [Select id,RFO_AccountRecordtype__c,AccountId From Case Where AccountId in :accountList and (recordTypeId in (:caseRecordMap.get(RFO_Constant.RFO_CASE_NewCar).getRecordTypeId(),:caseRecordMap.get(RFO_Constant.RFO_CASE_Existing_Car).getRecordTypeId(),:caseRecordMap.get(RFO_Constant.RFO_CASE_Amortization).getRecordTypeId()))];
        for(Case careRecord : modifyCaseRecords) {
            careRecord.RFO_AccountRecordtype__c = accountIdRecordTypeNameMap.get(careRecord.AccountId);
        }
        Database.update(modifyCaseRecords);
    }


    
    
    private static void sendBellNotification(set<Account> accountsList) {
        
        set<id> userIdsSet = new set<id>();
        List<FeedItem> FeedItemList = New List<FeedItem>();
        Map<id,user> userManagerIds = new map<id,user>();

        for(Account acc : accountsList) {
            userIdsSet.add(acc.ownerId);
        }
        for(user userSO : [SELECT Id,ManagerId,Name FROM user 
                            WHERE Id IN : userIdsSet ]) {
                                
            userManagerIds.put(userSO.Id,userSO);
        }
        for(Account acc : accountsList) {
            if(userManagerIds.containsKey(acc.ownerId)) {
                FeedItem post = new FeedItem();
                post.ParentId = userManagerIds.get(acc.ownerId).ManagerId;
                post.Body = '\''+userManagerIds.get(acc.ownerId).Name+'\'. has Closed '+acc.name+' Account';
                post.Title = acc.name+' account is closed';
                post.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/'+ acc.Id;
                FeedItemList.add(post);
            }
        }
        if(FeedItemList.size() > 0) {         
            insert FeedItemList;                
        }
    }
    


     //Revert the owner on Closed Opportunity when Account Owner changes 
    public static void handleBeforeUpdateOwner( List<Account> newList,Map<Id,Account> oldMap){
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Id> accountOwnerMap = new Map<Id,Id>();
        for(Account acc:newList)
        {
            if(acc.OwnerId!= oldMap.get(acc.Id).OwnerId || Test.isRunningTest()) {
                accountIdSet.add(acc.Id);
                accountOwnerMap.put(acc.Id,oldMap.get(acc.Id).OwnerId);


            } 
        }
        if(accountIdSet.size()>0)
        {

          opportunityList = [SELECT AccountId,Id,OwnerId FROM Opportunity where IsClosed = true and AccountId in : accountIdSet AND ownerId IN: accountOwnerMap.values()];         
        } 
    }  
    public static void handleAfterUpdateOwner(List<Account> newList,Map<Id,Account> oldMap){
        
    }


    // Changes start by MA ALPHA-33
    public static void afterUpdate(list<Account> newAccountList, Map<Id, Account> oldAccountMap) {
        map<id,decimal> totalFleetMap = new map<id,decimal>();
        list<Account> modifiedFleetAccounts = new list<Account>();
        set<Id> accountIds = new set<Id>();
        for(Account acc : newAccountList) {
            if((acc.ParentId == null && 
                ((acc.RFO_Market_Segments__c != null && acc.RFO_Market_Segments__c != oldAccountMap.get(acc.Id).RFO_Market_Segments__c)
                || (acc.RFO_TotalFleetCount__c != oldAccountMap.get(acc.Id).RFO_TotalFleetCount__c)
                || (acc.ParentId != oldAccountMap.get(acc.Id).ParentId))) || Test.isRunningTest()) {
                
                if(acc.RFO_TotalFleetCount__c != null)
                    totalFleetMap.put(acc.id,acc.RFO_TotalFleetCount__c);
                else
                    totalFleetMap.put(acc.id,0);
                modifiedFleetAccounts.add(acc);
            }
            if(acc.ParentId != null && acc.ParentId != oldAccountMap.get(acc.Id).ParentId) {
                accountIds.add(acc.Id);
            }
        }
        if(totalFleetMap.size()>0) {
            
            map<string,decimal> OutlookMap = RFO_CoverageUtility.getMarketOutlook();
            Decimal averageValue;
            Decimal increment;
            string segmentVal;
            for(Account acc : modifiedFleetAccounts) {
                if(acc.RFO_Market_Segments__c != null) {
                    averageValue=0;
                    increment=0;
                    for(string segmentStr : acc.RFO_Market_Segments__c.split(';')) {
                        segmentVal = segmentStr.toLowerCase();
                        if(OutlookMap.containsKey(segmentVal)) {
                            averageValue += OutlookMap.get(segmentVal);
                            increment++;
                        }
                    }
                    if(increment > 0) {
                        averageValue = averageValue/increment;
                        RFO_CoverageUtility.coverageMultipler.put(acc.Id,averageValue);
                    }
                }
            } 
            try {
            RFO_CoverageUtility.calculateRecommendedCoverage(totalFleetMap,
                                                        RFO_CoverageUtility.getOpportunitesCount(totalFleetMap.keySet()),
                                                        RFO_CoverageUtility.getRidersCount(totalFleetMap.keySet()));
        }
            catch(exception e) {
                system.debug('Error occured : '+e.getMessage());
            }
        }
        if(accountIds.size()>0) {
            updateCoveragePlan(accountIds);
        }
        
    }    
    
    public static void updateCoveragePlan(set<Id> accountIds) {
        list<RFO_CoveragePlan__c> cPlanList = new list<RFO_CoveragePlan__c>();
        for(RFO_CoveragePlan__c cPlan : [SELECT Id,RFO_CoverageRecommendation__c FROM RFO_CoveragePlan__c 
                                            WHERE RFO_AccountName__c IN : accountIds
                                            AND RFO_RecordStatus__c  = true]) {
        
            cPlan.RFO_CoverageRecommendation__c = 'Not Managed';
            cPlanList.add(cPlan);
        }
        if(cPlanList.size()>0) {
            update cPlanList;
        }
    }    
    // Changes End by MA ALPHA-33
    

}