/*
 * Test class for BulletinBoardController,BulletinBoardTrigger,BulletinBoardTriggerHandler
*/
@isTest
public class BulletinBoardControllerTest {
    
    @isTest
    public static void getBulletinPointsTest(){
        Bulletin_Board__c bb = new Bulletin_Board__c();
        bb.Name = 'Test';
        bb.Start_Date__c = System.today();
        bb.Expiry_Date__c = System.today().addDays(3);
        bb.Long_Description__c = 'Test';
        bb.RecordTypeId = Schema.SObjectType.Bulletin_Board__c.getRecordTypeInfosByName().get('CD Announcement').getRecordTypeId();
        insert bb;
        
        Bulletin_Board__c bb2 = new Bulletin_Board__c();
        bb2.Name = 'Test';
        bb2.Start_Date__c = System.today();
        bb2.Expiry_Date__c = System.today().addDays(3);
        bb2.Long_Description__c = 'Test';
        bb2.RecordTypeId = Schema.SObjectType.Bulletin_Board__c.getRecordTypeInfosByName().get('CD Enhancement').getRecordTypeId();
        insert bb2;
        bb.Status__c = 'Approved';
        update bb;
        BulletinBoardController.getBulletinPoints();
    }
}