public class ContentDocumentLinkHandler {
    public static Boolean isInvoiceFileShared = false;
    
    public static void LaunchEvent(List<ContentDocumentLink> Links)
    {
        String chatterGroupName='Trinity Development';
        List<CollaborationGroup> chatterGroup = [select Id, Name from CollaborationGroup where name =: chatterGroupName];
        
        List<New_SI_File__e> publishEvents = new List<New_SI_File__e>();
        List<New_CCSS_Document__e> publishEvents2 = new List<New_CCSS_Document__e>(); 
       	List<User> userInformation = [select Id, Profile.Name from User where Id =: UserInfo.getUserId()];
        string CCSlbl = System.Label.CCS_Label;
        String SIlbl = System.label.CDX_SI_prefix;
        
        Set<Id> invoiceContentDocumentIds = new Set<Id>();
        for (ContentDocumentLink cdl : Links)
        {
            if(String.valueOf(cdl.LinkedEntityId).startsWith(SIlbl) && userInformation[0].Profile.Name != 'Integration User')
            {
                New_SI_File__e SIEvent = new New_SI_File__e();
                SIEvent.ContentDocumentID__c = cdl.ContentDocumentId; 
                SIEvent.LinkedEntityId__c = cdl.LinkedEntityId;
                SIEvent.ContentDocumentLinkID__c = cdl.id;
                SIEvent.UserID_CreatedBy__c = userInformation[0].Id;
                SIEvent.Source__c = 'RailforceOne';
                publishEvents.add(SIEvent);
            }
            
            if(String.valueOf(cdl.LinkedEntityId).startsWith(CCSlbl) && userInformation[0].Profile.Name != 'Integration User')
            {
                New_CCSS_Document__e ccssEvent=new New_CCSS_Document__e(); 
            	ccssEvent.ContentDocument_ID__c= cdl.ContentDocumentId; 
            	ccssEvent.LinkedEntityId__c=cdl.LinkedEntityId;
            	ccssEvent.ContentDocumentLink_ID__c=cdl.id;
            	ccssEvent.UserID_CreatedBy__c = userInformation[0].Id;
                ccssEvent.Source__c = 'RailforceOne';
            	publishEvents2.add(ccssEvent);
            }
            if(!isInvoiceFileShared){
                isInvoiceFileShared = false;
                if(String.valueOf(cdl.LinkedEntityId.getSobjectType()) == 'CDX_Invoice__c'){
                    invoiceContentDocumentIds.add(cdl.ContentDocumentId);
                }
                insertCdls(invoiceContentDocumentIds);
            }
        }
        
        
        if(publishEvents.size()>0)
        {
            
            Database.SaveResult[] srList = EventBus.publish(publishEvents);
            // Inspect publishing result 
            for (Database.SaveResult sr : srList) 
            {
                if (sr.isSuccess()) {
                    String BodyOfEvent='';
        			List<string> lsstr= new List<string> ();
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully event published');
                    
                    for(Object a:publishEvents)
                    {
                        lsstr.add(String.valueOf(a));
                    }
                    for(String s:  lsstr)
                    {
                        BodyOfEvent+=s;
                    }
                    
                    if (chatterGroup.size() != 0){
                        FeedItem post = new FeedItem();
                        //post.ParentId = UserInfo.getUserId() ;
                        post.ParentId = chatterGroup[0].id ;
                        post.Body=BodyOfEvent;
                        insert post;
                        System.debug('post'+post);
                    }                
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug(' fields that affected this error: ' + err.getFields()); 
                    }
                }
            }
        }
        
        if(publishEvents2.size()>0)
        {
            
            Database.SaveResult[] srList = EventBus.publish(publishEvents2);
            // Inspect publishing result 
            for (Database.SaveResult sr : srList) 
            {
                if (sr.isSuccess()) {
                    String BodyOfEvent='';
        			List<string> lsstr= new List<string> ();
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully event published');
                    
                    for(Object a:publishEvents2)
                    {
                        lsstr.add(String.valueOf(a));
                    }
                    for(String s:  lsstr)
                    {
                        BodyOfEvent+=s;
                    }
                    
                    if (chatterGroup.size() != 0){
                        FeedItem post = new FeedItem();
                        //post.ParentId = UserInfo.getUserId() ;
                        post.ParentId = chatterGroup[0].id ;
                        post.Body=BodyOfEvent;
                        insert post;
                        System.debug('post'+post);
                    }                
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug(' fields that affected this error: ' + err.getFields()); 
                    }
                }
            }
        }
        
        
    }
    
    //@future
    public static void insertCdls(Set<Id> invoiceContentDocumentIds){
        List<ContentDocumentLink> invoiceCdls = new List<ContentDocumentLink>();
        List<GroupMember> invoiceGrpMembers = [SELECT Id,UserOrGroupId FROM GroupMember WHERE Group.Name = 'InvoiceFiles'];
        
        for(Id invoiceContentDocumentId : invoiceContentDocumentIds){
            for(GroupMember gm : invoiceGrpMembers){
                if(UserInfo.getUserId() != gm.UserOrGroupId)
                    invoiceCdls.add(new ContentDocumentLink(LinkedEntityId=gm.UserOrGroupId,ShareType = 'C',ContentDocumentId=invoiceContentDocumentId));
            }
        }
        if(!invoiceCdls.isEmpty()){
            Database.insert(invoiceCdls,false);   
        }
    }
    // Start - Alpha-23, Haseeb, Validation: Restrict upload access when record type is not product and file type is not base car, Created Date: September 2020
    public static void validateCdlRT(list<contentDocumentLink> newCDLlist){
        list<string> CDIds = new list<string>();
        list<string> proIds = new list<string>();
        for(contentDocumentLink cdl : newCDLlist){
            if(cdl.LinkedEntityid.getSobjectType() == SobjectType.product2.getSobjectType()){
                proIds.add(cdl.LinkedEntityid);
                CDIds.add(cdl.ContentDocumentId);
            }
        }
        if(proIds.size()>0){
            map<id,ContentVersion> mapCVCD = new map<id,ContentVersion>([Select id,ContentDocumentID,RecordType.name,CreatedDate,Trinity_File_Type__c from ContentVersion where ContentDocumentId in: CDIds
                                                                        order by CreatedDate Desc]);
            Map<string,ContentVersion> mapCDCV =  new map<string,ContentVersion>();
            for(ContentVersion cv : mapCVCD.Values()){
                if(!mapCDCV.ContainsKey(cv.ContentDocumentId))
                    mapCDCV.put(cv.ContentDocumentId,cv);
            }
            system.debug('~~~ Content Version: '+mapCVCD.values());
            system.debug('~~~ 13');
            map<id,product2> promap = new map<id,product2>([Select id,HasBaseCarSpec__c from Product2 where id in: proIds]);
            system.debug('Promap~~: '+promap);
            
            for(contentDocumentLink cdl : newCDLlist){
                if(cdl.LinkedEntityid.getSobjectType() == SobjectType.product2.getSobjectType() && (promap.get(cdl.LinkedEntityid).hasbasecarspec__c==False || (mapCDCV.get(cdl.ContentDocumentId).RecordType.name != 'Product'
                  && mapCDCV.get(cdl.ContentDocumentId).Trinity_File_Type__c != 'Base Car Spec'))){
                    cdl.adderror('Please upload files only for Base Car Product of Type Base Car Spec');
                }
            }
        }
    }
    
    // End - Alpha-23
    // Start - Alpha - 741, Haseeb, update Asset File record with uploaded BOM field = True when a BOM Type file is uploaded for Asset file object record
    public static void updateAssetFile(list<contentDocumentLink> newCDLlist){
        list<RFO_Asset_File__c> assetFilesToUpdate = new list<RFO_Asset_File__c>();
        list<string> CDIds = filterCDL(newCDLlist);
        if(CDIds.size() > 0){
            Map<string,ContentVersion> mapCDCV = getContentDocs(CDIds);
            assetFilesToUpdate = getAssetFilesToUpdate(newCDLlist, mapCDCV);
            if(assetFilesToUpdate.size() > 0)
                update assetFilesToUpdate;
        }
    }
    //Returns list of CDL where linked Entity id sobject Type is Asset Files
    public static list<string> filterCDL(list<contentDocumentLink> newCDLlist){
        list<string> CDIds = new list<string>();
        for(contentDocumentLink cdl : newCDLlist){
            if(cdl.LinkedEntityid.getSobjectType() == SobjectType.RFO_Asset_File__c.getSobjectType()){
                CDIds.add(cdl.ContentDocumentId);
            }
        }
        return CDIds;
    }
    //Returns a map of contentDocumentId and contentVersion for the ids of CDL where linked entity id is asset file type
    public static Map<string,ContentVersion> getContentDocs(list<string> CDIds){
        Map<string,ContentVersion> mapCDCV =  new map<string,ContentVersion>();
        map<id,ContentVersion> mapCVCD = new map<id,ContentVersion>([Select id,ContentDocumentID,RecordType.name,CreatedDate,Trinity_File_Type__c from ContentVersion where ContentDocumentId in: CDIds
                                                                        order by CreatedDate Desc]);
        for(ContentVersion cv : mapCVCD.Values()){
                if(!mapCDCV.ContainsKey(cv.ContentDocumentId))
                    mapCDCV.put(cv.ContentDocumentId,cv);
            }
        return mapCDCV;
    }
    //Returns a list  of asset files to update if the content version record type is asset file with type BOM document
    public static list<RFO_Asset_File__c> getAssetFilesToUpdate(list<contentDocumentLink> newCDLlist, Map<string,ContentVersion> mapCDCV){
        list<RFO_Asset_File__c> assetFilesToUpdate = new list<RFO_Asset_File__c>();
        for(contentDocumentLink cdl : newCDLlist){
            if(cdl.LinkedEntityid.getSobjectType() == SobjectType.RFO_Asset_File__c.getSobjectType() && mapCDCV.get(cdl.ContentDocumentId).RecordType.name == 'Asset File' 
               && mapCDCV.get(cdl.ContentDocumentId).Trinity_File_Type__c == 'BOM Document'){
                   RFO_Asset_File__c assetFile = new RFO_Asset_File__c();
                   assetFile.Id = cdl.LinkedEntityId;
                   assetFile.BOM_File_Uploaded__c = True;
                   assetFilesToUpdate.add(assetFile);
               }
        }
        return assetFilesToUpdate;
    }
    // End - Alpha - 741, Haseeb
}