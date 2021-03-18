global class RFO_QuoteRenewalEffSetScheduler  implements Schedulable{
	global void execute(SchedulableContext sc) 
    {
        RFO_QuoteRenewalEffSetBatch batch = new RFO_QuoteRenewalEffSetBatch();
        database.executeBatch(batch);
    }
}