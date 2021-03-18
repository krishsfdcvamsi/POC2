global class RFO_RiderSurveyScheduler implements Schedulable {
    global void execute(SchedulableContext sc) 
    {
        RFO_RiderSurveyBatch batch = new RFO_RiderSurveyBatch();
        database.executeBatch(batch);
    }
}