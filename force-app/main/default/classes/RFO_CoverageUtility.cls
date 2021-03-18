public class RFO_CoverageUtility {
    
    public static map<id,decimal> coverageMultipler = new map<id,decimal>();
    
    public static void calculateRecommendedCoverage(map<id,decimal> totalFleetMap, map<id,decimal> opportunitesCount, map<id,decimal> ridersCount) {
        
        list<RFO_CoveragePlan__c> coverageList = new list<RFO_CoveragePlan__c>();
        Decimal totalValue;
        Decimal coverageMultiper=0;
        for(RFO_CoveragePlan__c cpSO : [SELECT Id,RFO_CoverageRecommendation__c,RFO_AccountName__c FROM RFO_CoveragePlan__c 
                                                WHERE RFO_AccountName__c IN : totalFleetMap.keySet()
                                                AND RFO_RecordStatus__c = true]) {
            
            totalValue = 0;
            if(totalFleetMap.containsKey(cpSO.RFO_AccountName__c)) {
                totalValue += totalFleetMap.get(cpSO.RFO_AccountName__c);
            }
            if(opportunitesCount.containsKey(cpSO.RFO_AccountName__c)) {
                totalValue += opportunitesCount.get(cpSO.RFO_AccountName__c);
            }
            if(ridersCount.containsKey(cpSO.RFO_AccountName__c)) {
                totalValue += ridersCount.get(cpSO.RFO_AccountName__c);
            }
            if(coverageMultipler.containsKey(cpSO.RFO_AccountName__c)) {
                totalValue = totalValue * coverageMultipler.get(cpSO.RFO_AccountName__c);
            }
            cpSO.RFO_CoverageRecommendation__c = validateRange(totalValue);
            system.debug('@@recomendation = '+totalValue);
            coverageList.add(cpSO);
        }
        if(coverageList.size()>0) {
            update coverageList;
        }
    }
    
    public static map<id,decimal> getRidersCount(set<id> accountIds) {
        map<id,decimal> riderMap = new map<id,Decimal>();
        decimal activeCarsCount;
        Date nextyearDt = system.today().addYears(1);
        for(RFO_Rider__c riderSO : [SELECT id,RFO_Account__c,RFO_TotalActiveCars__c FROM RFO_Rider__c 
                                WHERE RFO_Account__c IN : accountIds 
                                AND RFO_CurrentMaturityDate__c >= TODAY AND RFO_CurrentMaturityDate__c <: nextyearDt]) {
                                    
            activeCarsCount = riderSO.RFO_TotalActiveCars__c != null?riderSO.RFO_TotalActiveCars__c:0;
            if(riderMap.containsKey(riderSO.RFO_Account__c)) {
                activeCarsCount += riderMap.get(riderSO.RFO_Account__c);
            }
            riderMap.put(riderSO.RFO_Account__c,activeCarsCount);
        }
        return riderMap;
    }
    
    public static map<id,decimal> getOpportunitesCount(set<id> accountIds) {
        map<id,decimal> optyMap = new map<id,Decimal>();
        decimal maxQuantityCount;
        set<String> optyStages = new set<String>{'Closed-Won','Closed-Withdrawn','Closed-Renewed','Closed-Termination','Closed-Lost'};
        for(opportunity opp : [SELECT id,RFO_MaximumQuantity__c,accountId FROM opportunity 
                                WHERE accountId IN : accountIds 
                                AND (recordType.name = 'Tank' OR recordType.name = 'Freight')
                                AND CreatedDate >= : Date.Today().addDays(-365) 
                                AND StageName NOT IN : optyStages]) {            // Added by MA Alpha-33
            maxQuantityCount = opp.RFO_MaximumQuantity__c != null?opp.RFO_MaximumQuantity__c:0;
            if(optyMap.containsKey(opp.accountId)) {
                maxQuantityCount += optyMap.get(opp.accountId);
            }
            optyMap.put(opp.accountId,maxQuantityCount);
        }
        return optyMap;
    }
    
    public static map<id,decimal> getAccountFleet(set<id> accountIds) {
        map<id,decimal> accountMap = new map<id,Decimal>();
        map<string,decimal> OutlookMap = getMarketOutlook();
        Decimal averageValue;
        Decimal increment;
        string segmentVal;
        for(Account acc : [SELECT id,RFO_TotalFleetCount__c,RFO_Market_Segments__c FROM Account 
                                WHERE Id IN : accountIds]) {
                                    
            if(acc.RFO_TotalFleetCount__c != null)
                accountMap.put(acc.id,acc.RFO_TotalFleetCount__c);
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
                    coverageMultipler.put(acc.Id,averageValue);
                }
            }
        }
        return accountMap;
    }
    
    public static map<string,decimal> getMarketOutlook() {
        map<string,decimal> outlookMap = new map<string,Decimal>();
        for(Market_Outlook__c mOutlook : [SELECT id,Market_Segment__c,Coverage_Multiplier__c FROM Market_Outlook__c ]) {
                                    
            if(mOutlook.Market_Segment__c != null && mOutlook.Coverage_Multiplier__c!=null)    
                outlookMap.put(mOutlook.Market_Segment__c.toLowerCase(),Decimal.valueOf(mOutlook.Coverage_Multiplier__c));
        }
        return outlookMap;
    }
    
    
    
    // Begin Added by MA Alpha-33
    public static string validateRange(Decimal fleetValue) {
        String recommendation;
        if(fleetValue >= 0 && fleetValue < 10)
            recommendation = 'Minimal';
        else if(fleetValue >= 10 && fleetValue < 50)
            recommendation = 'Inside Medium';
        else if(fleetValue >= 50 && fleetValue < 100)
            recommendation = 'Inside High';
        else if(fleetValue >= 100 && fleetValue < 500)
            recommendation = 'Low';
        else if(fleetValue >= 500 && fleetValue < 3000)
            recommendation = 'Medium';
        else if(fleetValue >= 3000 && fleetValue < 8000)
            recommendation = 'High';
        else if(fleetValue >= 8000)
            recommendation = 'Maximum';
        return recommendation;
    }
    
    // End by MA Alpha-33

}