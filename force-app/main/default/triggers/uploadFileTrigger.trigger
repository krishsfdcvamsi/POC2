//Files Uploaded from Chatter have recordtypeid empty, writing this trigger to assign default recordtype based on profile name

trigger uploadFileTrigger on FeedItem (after insert) {
    List<FeedItem> statusFeeds = trigger.new;
    for(FeedItem fd : statusFeeds)
    {
        if(fd.Type == 'ContentPost') 
        {
            //find all ContentVersion record types
            List<Schema.RecordTypeInfo> infos = Schema.SObjectType.ContentVersion.RecordTypeInfos;
            Id defaultRecordTypeId;

            //check each one
            for (Schema.RecordTypeInfo info : infos) {
                if (info.DefaultRecordTypeMapping) {
                    defaultRecordTypeId = info.RecordTypeId;
                }
            }

            //here is the default ContentVersion RecordType Id for the current user
            System.debug(defaultRecordTypeId);
            ContentVersion cv = [Select id, ContentDocumentId, Title, RecordTypeId from ContentVersion Where Id = :fd.RelatedRecordId ];
            System.debug(' ----------- Feed Body: ' + fd.Body);
            System.debug(' ----------- Document Id: : ' + cv.ContentDocumentId);
            System.debug(' ----------- Document Title: : ' + cv.Title);
            System.debug(' ----------- RecordTypeId: : ' + cv.RecordTypeId);
            cv.RecordTypeId = defaultRecordTypeId;
            cv.Trinity_File_Type__c = 'Other';
            update cv;
        }
    }
}