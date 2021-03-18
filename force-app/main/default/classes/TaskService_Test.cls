/************************************************************************************************************************************************** 
 * Class Name : TaskService_Test
 * Description : Test Class for TaskService
 * Author : Haseeb
 * Created On : 10/01/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/01/20                    Haseeb                       		ALPHA - 1078, Tests Creation of Task escalation method.
 * 
 **************************************************************************************************************************************************/
@isTest
public class TaskService_Test {
    // Test create task escalation method in the TaskService class
    static testMethod void testCreateTaskEscalation(){
        //Create Account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        account acc1 =new account();
        acc1.Name = 'BNSF';  // Account Name
        acc1.RecordTypeId = recordTypeIdAccount;           // Account Record Type
        acc1.Phone = '800-832-5452';         
        insert acc1;
        Test.startTest();
        TaskService ts = new TaskService();
        task t1 = ts.createTaskEscalation('Asset File BOM Document', null, null, null, null, acc1.id, null, null);
        task t2 = ts.createTaskEscalation('Asset File BOM Document', system.today(), userInfo.getUserId(), 'test', 'test', acc1.id, 'test','test');
        system.assertEquals(False, t1 == null);
        system.assertEquals(False, t2 == null);
        Test.stopTest();
    }
}