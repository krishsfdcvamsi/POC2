global class RFO_OrderSurveyScheduler implements Schedulable {
    global void execute(SchedulableContext sc) 
    {
        RFO_OrderSurveyBatch batch = new RFO_OrderSurveyBatch();
        database.executeBatch(batch);
    }
}