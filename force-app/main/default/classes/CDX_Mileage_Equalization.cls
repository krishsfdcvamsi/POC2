public with sharing class CDX_Mileage_Equalization {
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> GetMileageEqualization(String UserID)
    {
        //List of content version objects to be used later
        List<ContentVersion>ReturnList = new List<ContentVersion>();
        
        
        //Finds user
        System.debug('User ID: '+UserID.substring(0, 15));
        List<User> FoundUser = [SELECT ID, AccountId, ContactId 
                                FROM User 
                                WHERE ID =: UserID.substring(0, 15)];
        System.debug('User List Size: '+FoundUser.size());
        List<AccountContactRelation> Relationships = [SELECT AccountId,ContactId,IsActive FROM AccountContactRelation WHERE IsActive = true AND ContactId =: FoundUser[0].ContactId];
        for (AccountContactRelation Relation : Relationships)
        {
            //Finds account from user
            List<Account> FoundAccount = [SELECT ID, Name FROM Account WHERE ID =: Relation.AccountId];
            System.debug('Account List Size: '+FoundAccount.size());
            
            //Finds links from account
            List<ContentDocumentLink> FoundLinks = [SELECT ID, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: FoundAccount[0].ID];
            System.debug('The '+FoundAccount[0].Name+' account has '+FoundLinks.size()+' links attached to it');
            
            //For each link query the content version
            Set<String> contentDocIDs = new Set<String>(); 
            for(ContentDocumentLink Link : FoundLinks)
            {
                contentDocIDs.add(Link.ContentDocumentId); 
            }   
                 
             List<ContentVersion> FoundVersion = [SELECT ID, Title, CreatedDate, Community_Account__c, Community_URL__c, ContentDocumentId, FileExtension FROM ContentVersion WHERE ContentDocumentId IN: contentDocIDs AND IsLatest = true AND Trinity_File_Type__c = 'Mileage Statement'];
             for(ContentDocumentLink Link : FoundLinks) 
             {
                //If there is one, fill in the needed fields and add it to the list
                if(FoundVersion.size() > 0)
                {
                    for(ContentVersion contentVersion : foundVersion)
                    {
                        if(contentVersion.ContentDocumentId == Link.ContentDocumentId)
						{
                           contentVersion.Community_Account__c = FoundAccount[0].Name;
                   		   contentVersion.Community_URL__c = '/s/file/'+Link.ContentDocumentId;
                           System.debug(contentVersion.Title+' link  with an id of '+FoundVersion[0].ContentDocumentId);
                           System.debug('---'+contentVersion.Title+' id: '+FoundVersion[0].ID);
                           ReturnList.add(contentVersion);
                     }
                }
            }            
          }  
        }
        System.debug('Return List Size: '+ReturnList.size());
        return ReturnList;
    }
}