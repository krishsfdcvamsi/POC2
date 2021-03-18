global class RFO_OpportunityWithdrawRerunScheduler implements Schedulable{
	global void execute(SchedulableContext sc) 
    {
        RFO_OpportunityWithdrawRerunBatch  batch = new RFO_OpportunityWithdrawRerunBatch();
        database.executeBatch(batch);
    }
}