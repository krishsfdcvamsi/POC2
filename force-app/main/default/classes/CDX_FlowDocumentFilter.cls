public class CDX_FlowDocumentFilter {

    @InvocableMethod
    public static List<List<ContentVersion>> FilterDocuments (List<List<ContentDocumentLink>> CDL)
    {
        
        if(CDL.size() > 0)
        {
            System.debug('CDL SIZE: '+CDL.size());
            System.debug('FIRST ROW SIZE: '+CDL[0].size());
            System.debug('FIRST ROW CONTAINS: '+CDL[0]);
        }

        //Creates ID list from 
        Set<Id> CDLID = new Set<Id>(); 
        for(ContentDocumentLink link : CDL[0])
        {
            Id LinkID = link.ContentDocumentId;
            System.debug('ID RETRIEVED: '+LinkID);
            CDLID.add(LinkID);
        }
        
        //Queries content version from list of Ids along with other filters
        List<ContentVersion> cons = [SELECT Id, Title, Trinity_File_Type__c, RecordTypeId, 
                                     FileExtension, CreatedDate, ContentDocumentId, 
                                     ContentModifiedDate, CDX_File_Location__c
                                     FROM ContentVersion
                                     WHERE IsLatest = True AND ContentDocumentId in: CDLID
                                     AND Trinity_File_Type__c != NULL
                                     ORDER BY CreatedDate DESC];
        
        //Sets file location field based on linked entitiy
        for (ContentVersion cv : cons)
        {
            for(ContentDocumentLink link : CDL[0])
            {
                if(link.ContentDocumentId == cv.ContentDocumentId)
                {
                    String s1 = String.valueof(link.LinkedEntityId);
                    if (s1.startsWith('001'))
                        cv.CDX_File_Location__c = 'Account';
                    else
                        cv.CDX_File_Location__c = 'Customer Commodity';
                }
            }
        }
        System.debug('CONTENT VERSIONS RECIEVED: '+cons.size());
        
        //Creates return list and returns adds the content version list to it
        List<List<ContentVersion>> returnlist = new List<List<ContentVersion>>();
        returnlist.add(cons);
		System.debug('RETURN LIST SIZE: '+returnlist.size());
        
        return returnlist;
    }
}