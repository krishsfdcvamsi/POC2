@isTest
public class BatchJobsControllerTest {
    
    @isTest(seealldata=true)
    private static void testAllBatch() {
        BatchJobsController batch;
        List<BatchSetting__mdt> settings = [select developerName from BatchSetting__mdt where active__c=true];
        if(settings != null && !settings.isEmpty()){
            for(BatchSetting__mdt setting : settings){
                batch = new BatchJobsController(setting.developerName);
                batch.execute(null, new List<SObject>());
            }
        }
    }
    @isTest()
    private static void testBatchFinish() {
        BatchJobsController batch;
        List<BatchSetting__mdt> settings = [select developerName from BatchSetting__mdt where active__c=true];
        if(settings != null && !settings.isEmpty()){
            for(BatchSetting__mdt setting : settings){
                batch = new BatchJobsController(setting.developerName);
                batch.finish(null);
            }
        }
    }

}