/************************************************************************************************************************************************** 
 * Class Name : DailyBatch
 * Description : Schedule class for the daily CPQ Alert service.
 * This class queries the BatchSetting custom meta data to get the first daily job(Alert service) and executes it.
 * CPQ Alert service is scheduled to run at 7AM and 12PM daily. 
 * Author : Vamshidhar Jupelly
 * Story : US-0002124/ALPHA-1906 
 * Created On : 3/16/2021
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 
 **************************************************************************************************************************************************/
global class DailyBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<BatchSetting__mdt> batch = [select developerName, query__c, id, nextjob__c from BatchSetting__mdt
                                         where active__c=true and developerName ='DailyJob' ];
        if(batch.size()>0)
        {
            string firstDailyJob = batch[0].nextjob__c;
            
            BatchJobsController b = new BatchJobsController(firstDailyJob);
            Database.executeBatch(b, 200);
        }
    }
    
}