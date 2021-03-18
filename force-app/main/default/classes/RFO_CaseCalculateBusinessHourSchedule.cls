/* Scheduler class to schedule calculate business hours for closed case */
global class RFO_CaseCalculateBusinessHourSchedule implements Schedulable {
	global void execute(SchedulableContext sc) 
    {
        RFO_CaseCalculateBusinessHourBatch batch = new RFO_CaseCalculateBusinessHourBatch();
        database.executeBatch(batch);
    }
}