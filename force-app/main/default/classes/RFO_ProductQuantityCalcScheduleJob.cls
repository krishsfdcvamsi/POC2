/**
 * @Author      : Accenture
 * @Version     : 1.0
 * @Created Date: 11th Sep 2018 
 * @Description : Implements the Schedulable batch class to execute schedule class. 
 *                The class schedules the batch job and run on specified interval.
 **/

global class RFO_ProductQuantityCalcScheduleJob implements Schedulable
{
     /**
     *   This method executes the batch class based on provided BatchSize.
     **/
    global void execute(SchedulableContext sc)
    {
        // We now call the batch class to be scheduled
        RFO_ProductQuantityCalcBatchJob prdQuntSch = new RFO_ProductQuantityCalcBatchJob();
       
        // Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
        //String cronStr = '0 0 4 * * ?'; //Daily 4AM CST
        //System.schedule('Process Products', cronStr, prdQuntSch);
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executeBatch(prdQuntSch, 200);
    }
   
}