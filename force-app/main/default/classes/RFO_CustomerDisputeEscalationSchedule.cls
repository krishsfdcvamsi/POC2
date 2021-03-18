global class RFO_CustomerDisputeEscalationSchedule implements Schedulable{
	global void execute(SchedulableContext sc) 
    {
        RFO_CustomerDisputeEscalationBatch  batch = new RFO_CustomerDisputeEscalationBatch();
        database.executeBatch(batch);
    }
}