public class BulletinBoardController {
    
    @AuraEnabled
    public static List<Bulletin_Board__c> getBulletinPoints(){
        List<Bulletin_Board__c> bulletinPoints = new List<Bulletin_Board__c>();
        bulletinPoints = [SELECT Id,Name,RecordType.Name,URL_Link__c,Long_Description__c,Start_Date__c,
                          Expiry_Date__c FROM Bulletin_Board__c
                WHERE Status__c = 'Approved' AND Start_Date__c<=TODAY AND Expiry_Date__c >= TODAY AND RecordType.Name='CD Announcement'
                ORDER BY CreatedDate DESC];
        
        bulletinPoints.addAll([SELECT Id,Name,RecordType.Name,URL_Link__c,Long_Description__c,Start_Date__c,
                               Expiry_Date__c FROM Bulletin_Board__c
                WHERE Status__c = 'Approved' AND Start_Date__c<=TODAY AND Expiry_Date__c >= TODAY AND RecordType.Name='CD Enhancement'
                ORDER BY CreatedDate DESC]);
        
        return bulletinPoints;
    }
}