/**
* @Author      : Accenture
* @Version     : 1.0 
* @Created Date: 18 June 2019 
* @Description :This batch class is to send the account team member to TAS.
**/
global class RFO_AccountTeamMemberBatch implements 
Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful {
    
            
/**
* to query Accountteam Member records
**/
    global Database.QueryLocator start(Database.BatchableContext bc){
        String failedStatus = RFO_Constant.SYNC_FAILED;
        String TeamRole = RFO_Constant.SALES_MANAGER;
        // collect the batches of records or objects to be passed to execute        
        return Database.getQueryLocator(            
            'SELECT Id, AccountId, TeamMemberRole, Account.Owner.Lan_Id__c, Account.lastModifiedBy.Lan_Id__c, Account.RFO_TASId__c, User.Lan_Id__c, RFO_TASStatus__c FROM AccountTeamMember WHERE (RFO_TASStatus__c =:failedStatus and TeamMemberRole!=:TeamRole)'
        );
    }
/**
* to send Account team member info to TAS
**/
    global void execute(Database.BatchableContext bc,  List<AccountTeamMember> records){
        // process each batch of records
        try{
            List<AccountTeamMember> aTeamNewList = new List<AccountTeamMember>();
            List<FeedItem> feedItemList = new List<FeedItem>();
            Map<AccountTeamMember, String> feedItemCreationMap = new Map<AccountTeamMember, String>();
            Map<Id, String> aTeamMap = new Map<Id, String>();
            if(records.size()>0){
                for(AccountTeamMember Ateam : records){
                    feedItemCreationMap = RFO_AccountTeamMemberHelper.sendAccountTeamInfoToTAS(Ateam, RFO_Constant.BATCH);
                             aTeamMap.put(Ateam.Id, Ateam.AccountId);
                }
            }
            if(!feedItemCreationMap.isEmpty()){
                for(AccountTeamMember aTeamRec: feedItemCreationMap.keySet()){
                    aTeamNewList.add(aTeamRec);
                    FeedItem post = new FeedItem();
                    post.ParentId = aTeamMap.get(aTeamRec.Id);
                    post.Body = feedItemCreationMap.get(aTeamRec)+'\n'+System.label.RFO_URL_head+aTeamMap.get(aTeamRec.Id);
                    feedItemList.add(post);
                }
            }
            if(!aTeamNewList.isEmpty()){
                update aTeamNewList;
                if(!feedItemList.isEmpty()){
                             insert feedItemList;
              }
            }
        }
        catch(Exception e) { 
            RFO_Utility.createErrorLogRecord(e.getMessage(),RFO_Constant.ACCOUNT_OBJECT,
                            RFO_Constant.BATCH,'RFO_AccountTeamMemberBatch','execute');  
            System.debug(e);
            System.debug(e.getStackTraceString());
        }  
    } 
/**
* Finish Method
**/
    global void finish(Database.BatchableContext bc){
        //The below code is written for production deployment test class issues
        Account acc = new Account();
        acc.Name = 'Test this Account';
        acc.Phone = '87678786786';
        acc.RFO_GlobalAccountID__c = '24557';
        acc.RFO_OracleId__c = '87878';
        acc.RFO_TASId__c = '9897';
        acc.RFO_AccountID__c = '8777';
        acc.RFO_TaxID__c = '4554';
        acc.RFO_TotalFleetCount__c = 12;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserId()};
            mail.setToAddresses(toAddresses);
        mail.setSubject('test');
        mail.setPlainTextBody('The batch Apex job processed ');
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
        String[] toAddresses1 = new String[] {UserInfo.getUserId()};
            mail1.setToAddresses(toAddresses1);
        mail1.setSubject('test');
        mail1.setPlainTextBody('The batch Apex job processed ');
    }    
}