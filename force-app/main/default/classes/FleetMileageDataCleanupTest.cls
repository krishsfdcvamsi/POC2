/* Class Name : FleetMileageDataCleanupTest
 * Description : Test Class for FleetMileageDataCleanupBatch 
 * Created By : Vihari Vanga
 * Created On : 1/21/21
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 1/21/21                    Vihari Vanga                       EPSI-653
 */
@isTest(seeAllData=false)
public class FleetMileageDataCleanupTest {
    @testSetup 
    static void setup() {
        Account account = new Account(Name = 'test');
        insert account;  
        
        List<Fleet_Mileage_Data__c> fmdList = new List<Fleet_Mileage_Data__c>();
        for(Integer i=0;i<200;i++){
            Fleet_Mileage_Data__c fmd = new Fleet_Mileage_Data__c(Account__c = account.Id, Month_Earned__c = '201801'); 
            fmdList.add(fmd);
        }
        
        insert fmdList;
    }
    
    private static testMethod void testExecute(){
        Test.StartTest();
        FleetMileageDataCleanupScheduler fmdcSchedule = new FleetMileageDataCleanupScheduler();
        FleetMileageDataCleanupBatch fmdcBatch =  new FleetMileageDataCleanupBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Fleet Mileage Data Cleanup Scheduler Check', sch, fmdcSchedule);
        fmdcSchedule.execute(null);//This line of code executes the batch class from scheduler class
        Test.stopTest();
        
        List<Fleet_Mileage_Data__c> fleetMileageList = new List<Fleet_Mileage_Data__c>();
        fleetMileageList = [Select id from Fleet_Mileage_Data__c];
        System.assertEquals(0, fleetMileageList.size());
    } 
    
    private static testMethod void testFinish(){
        Test.StartTest();
        FleetMileageDataCleanupBatch fmdcBatch =  new FleetMileageDataCleanupBatch();
        fmdcBatch.failedRecords = 1;
        Database.executeBatch(fmdcBatch);
        Test.stopTest();
        
        List<Fleet_Mileage_Data__c> fleetMileageList = new List<Fleet_Mileage_Data__c>();
        fleetMileageList = [Select id from Fleet_Mileage_Data__c];
        System.assertEquals(0, fleetMileageList.size());
    }
      	         
        
}