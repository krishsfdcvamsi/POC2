/* Scheduler class to send survey's to compliance projects when last car shipdate is populated */
global class RFO_ProjectComplianceSurveyScheduler implements Schedulable {
	global void execute(SchedulableContext sc) 
    {
        RFO_ProjectComplianceSurveyBatch batch = new RFO_ProjectComplianceSurveyBatch();
        database.executeBatch(batch);
    }
}