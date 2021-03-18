/**
* @Author      : Accenture  
* @Version     : 1.0
* @Created Date: 23 May 2019
* @Description :This Schedule class is to update the run the batch class RFO_UpdateGlobalAccountIdBatch.
**/
global class RFO_UpdateGlobalAccountIDScheduleJob implements Schedulable
{
     /**
     *   This method executes the batch class based on provided BatchSize.
     **/
    global void execute(SchedulableContext sc) 
    { 
        // We now call the batch class to be scheduled
        RFO_UpdateGlobalAccountIdBatch btchId = new RFO_UpdateGlobalAccountIdBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize), We are sending only one record per request as mule is not accepting list of records
        database.executeBatch(btchId, 1);
    }
   
}