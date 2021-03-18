@isTest
public class RecordTypeControllerTest {
	static testmethod void RecordTypeTestMethod(){
        TEST.startTest();
        	RecordTypeController.getRecordTypeValues('Account');
         TEST.stopTest();
	}
}