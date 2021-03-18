global class RFO_OrderPlantNotificationScheduler  implements Schedulable{
    
    
	global void execute(SchedulableContext sc) 
    {
        RFO_OrderPlantNotificationBatch batch = new RFO_OrderPlantNotificationBatch();
        database.executeBatch(batch);
    }
}