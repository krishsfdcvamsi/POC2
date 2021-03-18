public class AssetGroupTriggerHandler{

    public void beforeInsert(List<Asset_Group__c> newItems) {
    
        system.debug('entered AssetGroupTriggerHandler before insert. Processing ' +newItems.size() + ' records');

        List<Asset_Group__c> recrdsToProcess=new List<Asset_Group__c>();
        for(Asset_Group__c ag : newItems)
        {
          
            if(ag.MatchingAlgorithmResult__c)
            {
                recrdsToProcess.add(ag);
            }
        }
        if(recrdsToProcess.size()>0)
        {
            AssetMatchingService aservice = new  AssetMatchingService();
        	aservice.DeleteOldAssetMatches(recrdsToProcess);
        }
       

    }
}