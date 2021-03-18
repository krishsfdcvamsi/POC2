/*************************************************************
@Name: UpdateCdmNameBatch
@Author: MA
@CreateDate: Nov 16, 2020
@JIRA : BETA-194
@Description: updates customer delivery name to the order
**************************************************************/
global class UpdateCdmNameBatch implements Database.Batchable<sObject> {
    
    string query = null;
    set<Id> accountIds = new set<Id>();
    
    global UpdateCdmNameBatch() {
        query = 'select Id,name from account where id IN '
                            +'(SELECT accountId FROM AccountTeamMember WHERE TeamMemberRole = \'Customer Delivery Manager\')';
    }
    
    global UpdateCdmNameBatch(set<Id> accountIds) {
        this.accountIds = accountIds;
        query = 'select Id,name from account where id IN : accountIds';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc,  List<Account> accountList){ 
        Id accountId = accountList[0].Id;
        list<AccountTeamMember> teamMember = [select Id, User.Name, TeamMemberRole FROM AccountTeamMember 
                                                WHERE AccountId =: accountId
                                                AND TeamMemberRole = 'Customer Delivery Manager'];
        if(!teamMember.isEmpty()) {
            list<Order> orderList = new list<Order>();
            for(Order orderSO : [SELECT Id,CDM_Name__c FROM Order WHERE accountId =: accountId AND StatusCode = 'Draft']) {
                orderSO.CDM_Name__c = teamMember[0].User.Name;
                orderList.add(orderSO);
            }
            Database.update(orderList, false);
        }
    }
    
    global void finish(Database.BatchableContext bc){

    }     
}