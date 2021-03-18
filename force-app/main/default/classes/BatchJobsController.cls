global class BatchJobsController implements Database.Batchable<sObject> { 
   
    private String batchSettingname;
    private BatchSetting__mdt batch;
    
    
    public BatchJobsController(String settingIn) {
    	batchSettingname = settingIn;
        batch = [SELECT developerName, query__c,nextjob__c 
                 				FROM BatchSetting__mdt
                                WHERE active__c=true 
                 				AND developerName =:batchSettingname][0];//if no settings found, batch will fail
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       system.debug('zzz '+batch.DeveloperName);
       string query='';
       query = batch.Query__c;
       system.debug(query);
        if(string.isNotEmpty(query)){
            return Database.getQueryLocator(query);
        }
        else{
            return Database.getQueryLocator('select id from account limit 1');//if we dont have a query, return something so engine runs.
        }
        
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> scope){
    	system.debug('zzz '+batch.DeveloperName);
        
        switch on batch.DeveloperName{
            when 'AssetCommitted'{
                CPQAlertService.processCommittedAssetsAlerts(scope);
            }
        }
    }
   
    global void finish(Database.BatchableContext BC) {
        system.debug(batch.DeveloperName);
        if(string.isNotEmpty(batch.nextjob__c)){
            BatchJobsController  b = new BatchJobsController(batch.nextjob__c);
            Database.executeBatch(b, 200);   
        }
     
    }
}