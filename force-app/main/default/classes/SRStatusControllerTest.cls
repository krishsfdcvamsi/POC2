@isTest
public class SRStatusControllerTest {
    
    @isTest
    public static void getNewSrsTest(){
        List<Id> srIds = new List<Id>();
        Test.startTest();
        SRStatusController.getNewSrs(srIds);
        Test.stopTest();
    }
}