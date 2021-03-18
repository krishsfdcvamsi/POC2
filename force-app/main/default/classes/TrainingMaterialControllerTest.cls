@isTest
public class TrainingMaterialControllerTest {
    
    @testSetup
    public static void setup(){
        ContentWorkspace cw = new ContentWorkspace();
        cw.Name = 'Test '+String.valueOf(System.now());
        insert cw;
    }
    
    @isTest
    public static void trainingMaterialTest(){
        
        ContentWorkspace cw = [SELECT Id,RootContentFolderId FROM ContentWorkspace LIMIT 1];
        Test.startTest();
        
        ContentFolder cf = new ContentFolder();
        cf.Name = 'Test 1';
        cf.ParentContentFolderId = cw.RootContentFolderId;
        insert cf;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.SharingPrivacy = 'N';
        insert cv;
        
        System.debug([SELECT Id,RootContentFolderId FROM ContentWorkspace]);
        TrainingMaterialController.getTrainingMaterials();
        TrainingMaterialController.getTrainingFilesAndFolders();
        TrainingMaterialController.getTrainigFolders();
        TrainingMaterialController.getMyDocuments();
        TrainingMaterialController.getTrainingFilesAndFolders();
        Test.stopTest();
        
    }
}