public class CDX_TestDataFactory
{
 
    public static void createTestData()
    {
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
              Trinity_File_Type__c = 'OTMA'
            //recordTypeId ='Other'
        );
        insert contentVersionInsert;
       
      
        
    }
                               
    
}