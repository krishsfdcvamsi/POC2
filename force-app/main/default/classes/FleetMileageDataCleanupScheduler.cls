/* Class Name : FleetMileageDataCleanupScheduler
 * Description : Scheduler Class to schedule  FleetMileageDataCleanupBatch 
 * Created By : Vihari Vanga
 * Created On : 1/21/21
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 1/21/21                    Vihari Vanga                       EPSI-653
 */
global class FleetMileageDataCleanupScheduler Implements Schedulable{

    global void execute(SchedulableContext sc){
        
        FleetMileageDataCleanupBatch fmdcBatch = new FleetMileageDataCleanupBatch();
        database.executeBatch(fmdcBatch,2000);  
    
    }
          
}