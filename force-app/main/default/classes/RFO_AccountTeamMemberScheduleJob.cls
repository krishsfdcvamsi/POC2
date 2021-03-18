/**
* @Author      : Accenture
* @Version     : 1.0  
* @Created Date: 1 July 2019
* @Description :This batch class is to send the account team member to TAS.
**/
global class RFO_AccountTeamMemberScheduleJob implements Schedulable {
 /**
     *   This method executes the batch class based on provided BatchSize.
     **/
    global void execute(SchedulableContext sc) 
    { 
        // We now call the batch class to be scheduled
        RFO_AccountTeamMemberBatch b = new RFO_AccountTeamMemberBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executeBatch(b, 1);
    }
   
}