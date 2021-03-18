/**
 * @Author      : Accenture
 * @Version     : 1.0
 * @Created Date: 24th April 2018
 * @Description : Implements the Schedulable base class to execute schedule class. 
 *                The class schedules the batch job and run on specified interval.
 **/
global class RFO_OrderHandlerScheduleJob implements Schedulable
{
     /**
     *   This method executes the batch class based on provided BatchSize.
     **/
    global void execute(SchedulableContext sc)
    {
        // We now call the batch class to be scheduled
        RFO_OrderHandlerBatchJob b = new RFO_OrderHandlerBatchJob();
       
        // Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
        //String cronStr = '0 0 3 * * ?'; //Daily 3AM CST
        //System.schedule('Process Orders', cronStr, b);
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executeBatch(b, 5);
    }
   
}