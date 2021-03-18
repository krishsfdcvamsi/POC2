public class AssetLineTriggerHandler{
    public void run(){
    	RFO_TriggerSetting__mdt assetLineTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='AssetLineTrigger' LIMIT 1];
        if (assetLineTrigger.RFO_Active__c){
            if(trigger.isInsert && trigger.isbefore){
                beforeInsert(Trigger.New);
            }
        }
    }
    public void beforeInsert(List<SObject> newItems) {
        system.debug('entered AssetLineTriggerHandler before insert');

        List<Asset_Lines__c> recrdsToProcess=new List<Asset_Lines__c>();
        for(sObject o : newItems)
        {
            Asset_Lines__c al = (Asset_Lines__c)o;
            if(al.MatchingAlgorithmResult__c)
            {
                recrdsToProcess.add(al);
            }
        }
        system.debug('processing ' +recrdsToProcess.size() + ' records');

        if(recrdsToProcess.size()>0)
        {
            AssetMatchingService aservice = new  AssetMatchingService();
        	aservice.ProcessMatchingResults(recrdsToProcess);
        }
       
    }

}