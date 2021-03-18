/*************************************************************
@Name: RFO_CoverageRecommendationBatch
@Author: MA
@CreateDate: Sept 21, 2020
@JIRA : ALPHA - 33
@Description: This class is used to update coverage recomendation field to all the existing coverage plans
**************************************************************/
global class RFO_CoverageRecommendationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
    String query;
    public map<id,decimal> coverageMultipler = new map<id,decimal>();
    
    global RFO_CoverageRecommendationBatch() {
        query = 'SELECT Id,Name,RFO_TotalFleetCount__c,RFO_Market_Segments__c,ParentId,Owner.Name FROM Account'
                +' WHERE RFO_Market_Segments__c != null';
    }
    global RFO_CoverageRecommendationBatch(string marketSegment) { 
        query = 'SELECT Id,Name,RFO_TotalFleetCount__c,RFO_Market_Segments__c,ParentId,Owner.Name FROM Account'
                +' WHERE RFO_Market_Segments__c includes ( \''+marketSegment+'\')';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc,  List<Account> accountList){  
        set<Id> childAccountIds = new set<Id>();
        set<Id> parentAccountIds = new set<Id>();
        Account accSO = accountList[0]; // Since the scope is 1
        
        set<string> ownerNames = new set<string>();
        for(string str : System.Label.Canadian_Accounts.split(',')) {
            ownerNames.add(str.trim().toUpperCase());
        }
        set<String> segmentSet = new set<String>(accSO.RFO_Market_Segments__c.split(';'));
        if(segmentSet.contains('Crude Oil')) {
             if(ownerNames.contains(accSO.Owner.Name.toUpperCase())) { 
                accSO.RFO_Market_Segments__c = accSO.RFO_Market_Segments__c.replace('Crude Oil','Canadian Crude Oil');
             }
             else {
                 accSO.RFO_Market_Segments__c = accSO.RFO_Market_Segments__c.replace('Crude Oil','US Crude Oil');
             }
             update accSO;
        }
        
        for(Account acc : accountList) {
            if(acc.parentId != null) {
                childAccountIds.add(acc.Id);
            }
            else {
                parentAccountIds.add(acc.Id);
            }
        }
        if(!childAccountIds.isEmpty()) {
            coverageUnManaged(childAccountIds);
        }
        if(!parentAccountIds.isEmpty()) {
            updateRecommendation(parentAccountIds);
        }
    }
    
    public void coverageUnManaged(set<Id> accountIds) {
        list<RFO_CoveragePlan__c> cPlanList = new list<RFO_CoveragePlan__c>();
        for(RFO_CoveragePlan__c cPlan : getCoveragePlans(accountIds)) {
            
            cPlan.RFO_CoverageRecommendation__c = 'Not Managed';
            cPlanList.add(cPlan);
        }
        if(!cPlanList.isEmpty()) {
            Database.SaveResult[] updateCPList = Database.update(cPlanList, false);
        }
    }
    
    /***
        @Method : updateRecommendation
        @Description : Updates the coverage plan records based on calculations
        @return: none
    ***/
    public void updateRecommendation(set<Id> accountIds) {
        list<RFO_CoveragePlan__c> cPlanList = new list<RFO_CoveragePlan__c>();
        map<id,decimal> accountMap = getAccountFleet(accountIds);
        //Get the Rider active cars count w.r.t to account Ids
        map<id,decimal> ridersCount = RFO_CoverageUtility.getRidersCount(accountIds);
        //Get the Opportunity max quantity count w.r.t to account Ids
        map<id,decimal> opportunityCount = RFO_CoverageUtility.getOpportunitesCount(accountIds);
        Decimal totalValue;
        
        for(RFO_CoveragePlan__c cpSO : getCoveragePlans(accountIds)) {
            totalValue = 0;
            if(accountMap.containsKey(cpSO.RFO_AccountName__c)) {
                totalValue += accountMap.get(cpSO.RFO_AccountName__c);
            }
            if(opportunityCount.containsKey(cpSO.RFO_AccountName__c)) {
                totalValue += opportunityCount.get(cpSO.RFO_AccountName__c);
            }
            if(ridersCount.containsKey(cpSO.RFO_AccountName__c)) {
                totalValue += ridersCount.get(cpSO.RFO_AccountName__c);
            }
            if(coverageMultipler.containsKey(cpSO.RFO_AccountName__c)) {
                totalValue = totalValue * coverageMultipler.get(cpSO.RFO_AccountName__c);
            }
            
            if(totalValue >= 0) {
                cpSO.RFO_CoverageRecommendation__c = RFO_CoverageUtility.validateRange(totalValue);
                cPlanList.add(cpSO);
                system.debug('@@recomendation = '+cpSO.RFO_CoverageRecommendation__c);
            }
        }
        Database.SaveResult[] updateCPList;
        if(!cPlanList.isEmpty()) {
            updateCPList = Database.update(cPlanList, false);
        }
    }
    
    /***
        @Method : getAccountFleet
        @Description : gets the total fleet count value w.r.t Account ids
        @return: map<id,decimal>
    ***/
    public map<id,decimal> getAccountFleet(set<id> accountIds) {
        map<id,decimal> accountMap = new map<id,Decimal>();
        map<string,decimal> OutlookMap = RFO_CoverageUtility.getMarketOutlook();
        set<string> ownerNames = new set<string>();
        Decimal averageValue;
        Decimal increment;
        string segmentVal;
        for(string str : System.Label.Canadian_Accounts.split(',')) {
            ownerNames.add(str.trim().toUpperCase());
        }
        for(Account acc : [SELECT id,RFO_TotalFleetCount__c,RFO_Market_Segments__c,Owner.Name FROM Account 
                                WHERE Id IN : accountIds]) {
                                    
            if(acc.RFO_TotalFleetCount__c != null)
                accountMap.put(acc.id,acc.RFO_TotalFleetCount__c);
            if(acc.RFO_Market_Segments__c != null) {
                averageValue=0;
                increment=0;
                
                for(string segmentStr : acc.RFO_Market_Segments__c.split(';')) {
                    if(segmentStr == 'Crude Oil') {
                        account accSO = new account();
                        if(ownerNames.contains(acc.Owner.Name.toUpperCase())) {
                            segmentVal = 'Canadian Crude Oil';
                        }
                        else {
                            segmentVal = 'US Crude Oil';
                        }
                        segmentVal = segmentVal.toLowerCase();
                    }
                    else {
                        segmentVal = segmentStr.toLowerCase();
                    }
                    if(OutlookMap.containsKey(segmentVal)) {
                        averageValue += OutlookMap.get(segmentVal);
                        increment++;
                    }
                }
                if(increment > 0) {
                    averageValue = averageValue/increment;
                    coverageMultipler.put(acc.Id,averageValue);
                }
            }
        }
        return accountMap;
    }
    /***
        @Method : getCoveragePlans
        @Description : Query coverage plan records for the given account Ids
        @return: list<RFO_CoveragePlan__c>
    ***/
    public list<RFO_CoveragePlan__c> getCoveragePlans(set<Id> accountIds) {
        return [SELECT Id,RFO_CoverageRecommendation__c,RFO_AccountName__c FROM RFO_CoveragePlan__c
                    WHERE RFO_AccountName__c IN : accountIds AND RFO_RecordStatus__c = true];
    }

    global void finish(Database.BatchableContext bc){
    }     
}