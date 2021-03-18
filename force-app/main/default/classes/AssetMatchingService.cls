public class AssetMatchingService {
    
    
    public void ProcessMatchingResults(List<Asset_Lines__c> newAssetGroupLines)
    {
        
        
        //if matching algorithm does not have sfdc asset id (based on integration)
        if(RequiresMappingToSfdcAssetId())
        {
            this.FindAssetByExternalIdAndSetSfdcIdOnAssetLine(newAssetGroupLines) ;
        }
    }
    public void DeleteOldAssetMatches(List<Asset_Group__c> newAssetGroup)
    {
        set<id> newAssetGroupSet=new set<id>();
        set<id> opportunityIds= new set<id>();
        
        for(Asset_Group__c ag : newAssetGroup)
        {
            opportunityIds.add(ag.opportunity__c);
            // newAssetGroupSet.add(ag.id);
        }
        
        List<Asset_Group__c> oldMatchesToDelete = [select id from Asset_Group__c where opportunity__c in : opportunityIds
                                                   AND Quote_Line__c = NULL and MatchingAlgorithmResult__c=true];
        
        
        Database.DeleteResult[] drList = Database.delete(oldMatchesToDelete, false);
        for(Database.DeleteResult dr: drList)
        {
            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted asset group with ID: ' + dr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('fields that affected this error: ' + err.getFields());
                }
            }
        }
        
    }
    @TestVisible
    private void FindAssetByExternalIdAndSetSfdcIdOnAssetLine (List<Asset_Lines__c> newAssetGroupLines)
    {
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        Map<string, Asset_Lines__c> externalAssetIdToAssetLineMap = new Map<string, Asset_Lines__c>();
        for(Asset_Lines__c al : newAssetGroupLines)
        {
            if(!string.isEmpty(al.ExternalAssetId__c))
            {
                externalAssetIdToAssetLineMap.put(al.ExternalAssetId__c,al);
            }
            
        }
        assetMap = new Map<Id, Asset>([select id, RFO_TASId__c from asset where RFO_TASId__c in :externalAssetIdToAssetLineMap.keySet()]);
        for(Asset a : assetMap.values())
        {
            for(string eaId : externalAssetIdToAssetLineMap.keyset())
            {
                if(eaId.equalsIgnoreCase(a.RFO_TASId__c))
                {
                    externalAssetIdToAssetLineMap.get(eaId).Asset__c = a.id;
                }
            }
        }
    }
    private boolean RequiresMappingToSfdcAssetId()
    {
        boolean returnVal=false;
        try
        {
            List<CPQSettings__mdt> iterationControl= [SELECT MasterLabel, QualifiedApiName, Value__c, Active__c from  CPQSettings__mdt 
                                                      WHERE QualifiedApiName ='RequiresMappingToSfdcAssetId' 
                                                      AND Active__c=true Limit 1];
            
            if(iterationControl.size()>0)
            {
                returnVal= boolean.valueOf(iterationControl[0].Value__c);
            }
        }
        catch(exception e)
        {
            system.debug(e.getMessage());
            
        }
        return returnVal;
        
        
        
    }
    
}