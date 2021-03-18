global class UpdateAssetsDeliveredSch implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new UpdateAssetsDeliveredBatch(), 200); 
    }
}