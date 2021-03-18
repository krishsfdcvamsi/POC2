/**
 * @Author      : Accenture  
 * @Version     : 1.0
 * @Created Date: 8th July 2019
 * @Description : Implements the Schedulable base class to execute schedule class. 
 *                The class schedules the batch job and run on specified interval.
 **/
global class RFO_CreateRenewalManagementOpty_Schedule implements Schedulable
{
     /**
     *   This method executes the batch class based on provided BatchSize.
     **/
    global void execute(SchedulableContext sc)
    {
        // We now call the batch class to be scheduled
        RFO_CreateRenewalManagementOpty_Batch b = new RFO_CreateRenewalManagementOpty_Batch();
       
        // Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
        //String cronStr = '0 0 1 * * ?'; //Daily 1AM CST
        //System.schedule('Process Opportunities', cronStr, b);
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executeBatch(b, 5);
    }
   
}