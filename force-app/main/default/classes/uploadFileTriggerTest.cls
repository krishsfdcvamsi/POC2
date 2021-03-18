@isTest
public class uploadFileTriggerTest
 {
    Static testmethod void uploadFileTriggerTest() {

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test.pdf';
        cv.Trinity_File_Type__c ='Other';
        cv.PathOnClient = 'test';
        cv.VersionData = Blob.valueOf('Test Content');
	    cv.IsMajorVersion = true;
        insert cv;

        FeedItem FI = new FeedItem();
        FI.Type = 'ContentPost';
        FI.RelatedRecordId = cv.Id;
        FI.ParentId = UserInfo.getUserId();
        insert FI;
    } 
}