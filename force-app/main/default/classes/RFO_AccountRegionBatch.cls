/*************************************************************
@Name: RFO_AccountRegionBatch
@Author: MA
@CreateDate: Sept 23, 2020
@JIRA : ALPHA - 44
@Description: This class is used to update coverage recomendation field to all the existing coverage plans
**************************************************************/
global class RFO_AccountRegionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'SELECT Id,RFO_Region__c,owner.Region__c FROM Account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc,  List<Account> accountList){ 
        list<Account> accountsUpdate = new list<Account>();
        for(Account acc : accountList) {
            acc.RFO_Region__c = acc.owner.Region__c;
            accountsUpdate.add(acc);
        }
        Database.update(accountsUpdate, false);
    }
    
    global void finish(Database.BatchableContext bc){

    }     
}