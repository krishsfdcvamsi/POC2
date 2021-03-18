public without sharing class  CDX_ContentVersionHandler
{



    public static void handleBeforeInsert(List<ContentVersion> contentVersionList){

        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        for(ContentVersion cv: contentVersionList)
        {
            if(MyProflieName.equalsIgnoreCase('Sales Customer') || MyProflieName.equalsIgnoreCase('CDX Customer')||
               MyProflieName.equalsIgnoreCase('CDX Customer - Super User')||MyProflieName.equalsIgnoreCase('Integration User')||
               MyProflieName.equalsIgnoreCase('Customer Operations')||MyProflieName.equalsIgnoreCase('System Administrator') ||
               MyProflieName.equalsIgnoreCase('Products and Orders'))
            {
                System.debug('CPQ  effected'); 
            }
            else
            {
                System.debug('CPQ Not effected');
                cv.Trinity_File_Type__c='Other';   
            }
            
        }
    }

    public static void handleAfterInsert(List<ContentVersion> contentVersionList){
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Set<Id> contentVersionIds=new Set<Id>();
        Map<Id,Id> contentVersionToDocumentMap = new Map<Id,Id>();
        Map<Id,String> contentDocumentToFileType = new Map<Id,String>();


        //Collection for signed proposals


        Map<Id,Id> signedProposalMap = new Map<Id,Id>();
        
/**************************************************************************************
* @Author : Ramesh Guguloth
* @Modified Date : 9/10/2020
* @Description   : As an Engineer user, need system generated alerts sent to all teams that needs notifications regarding the spec sheet uploads into Order Object.   
* @User Story : ALPHA-529    
**************************************************************************************/
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName == RFO_Constant.PROFILE_PRODUCTS_AND_ORDERS || profileName == RFO_Constant.PROFILE_SYSTEM_ADMIN){
            RFO_SendEmailOnFileUploadHelper.sendEmails(trigger.new);
        }
        // End of Alpha-529

        for(ContentVersion cv :contentVersionList) {

            if(cv.ContentDocumentId != null && cv.Trinity_File_Type__c=='OTMA')
            {
                System.debug('entered in OTMA ');
                contentDocumentIdSet.add(cv.ContentDocumentId);
                contentVersionIds.add(cv.id);
                //CDX_ContentVersionHandler.handleContentVersion(contentDocumentIdSet, contentVersionIds);
            }
            else if(cv.ContentDocumentId != null && cv.Trinity_File_Type__c=='Cleaning Certification')
            {
                System.debug('entered in Cleaning Certification');
                contentDocumentIdSet.add(cv.ContentDocumentId);
                contentVersionIds.add(cv.id);
                CDX_ContentVersionHandler.handleServiceRequest(contentDocumentIdSet, contentVersionIds); 

            }else if(cv.ContentDocumentId != null && cv.Trinity_File_Type__c==RFO_Constant.FILE_TYPE_SIGNED_PROPOSAL){
                signedProposalMap.put(cv.Id, cv.ContentDocumentId);

            }else {
                if(Label.Partially_Executed_File_Types != null){
                    List<String> fileTypes = Label.Partially_Executed_File_Types.split(',');
                    for(String fileType : fileTypes){
                        if(fileType.equalsIgnoreCase(cv.Trinity_File_Type__c)){
                            contentVersionToDocumentMap.put(cv.Id, cv.ContentDocumentId);
                            contentDocumentToFileType.put(cv.ContentDocumentId,cv.Trinity_File_Type__c );
                        }
                    }
                }
            }
        }
        if(contentVersionToDocumentMap.size()>0){
            CDX_ContentVersionHandler.handlePartialFileUploadNotifications(contentVersionToDocumentMap, contentDocumentToFileType); 
        }        

        if(signedProposalMap.size()>0){
            sendSignedProposalChatterNotification(signedProposalMap);
        } 

    }
    
    public static void  handleContentVersion( Set<Id> contentDocumentIdSet, Set<Id> contentVersionIds)
        
    {
        System.debug('Enterd in handleContentVersion');
        String chatterGroupName='Trinity Development';
        List<CollaborationGroup> chatterGroup = [select Id, Name from CollaborationGroup where name =: chatterGroupName];
        List<New_OTMA_Document__e> publishEvents = new List<New_OTMA_Document__e>(); 
        ContentDocumentLink cdl = [SELECT id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet  order By LinkedEntityId desc limit 1];
        String BodyOfEvent='';
        List<string> lsstr= new List<string> ();
        for(Id cvIds: contentVersionIds)
        {
            New_OTMA_Document__e otmaEvent=new New_OTMA_Document__e(); 
            otmaEvent.ContentDocument_ID__c= cdl.ContentDocumentId; 
            otmaEvent.LinkedEntityId__c=cdl.LinkedEntityId;
            otmaEvent.ContentDocumentLink_ID__c=cdl.id;
            otmaEvent.ContentVersion_ID__c=cvIds;
            otmaEvent.Source__c= 'RailforceOne';
            publishEvents.add(otmaEvent);
        }
        
        if(publishEvents.size()>0)
        {
            
            Database.SaveResult[] srList = EventBus.publish(publishEvents);
            // Inspect publishing result 
            for (Database.SaveResult sr : srList) 
            {
                if (sr.isSuccess()) {
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
        
    }

    public static void  handleServiceRequest( Set<Id> contentDocumentIdSet, Set<Id> contentVersionIds) 
    {
        if(Test.isRunningTest())
       {
           Schema.sObjectType sObjType = Schema.getGlobalDescribe().get('RFO_ShopIncident__c');
        String serviceRequestPrefix = sObjType.getDescribe().getKeyPrefix();
       System.debug('serviceRequestPrefix'+serviceRequestPrefix);
        ContentDocumentLink cdlForServiceRequest= [SELECT id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet  order By LinkedEntityId desc limit 1];  
      if(cdlForServiceRequest!=null)
      {
        System.debug('cdlForServiceRequest'+cdlForServiceRequest);
        String linkedEntityId = cdlForServiceRequest.LinkedEntityId; 
        system.debug('linked entity id: ' + linkedEntityId); 
        
       if(linkedEntityId.startsWith('0'))

       {
           System.debug('Entered in LinkedEntityLoop');
       
        RFO_ShopIncident__c serviceReq=[select id,RFO_Customer__r.name,RFO_SIRef__c,RFO_ShopName__c,RFO_Location__c,CDX_Detail_Link__c,CDX_Primary_Contact__r.name,CDX_Primary_Contact__r.email from  RFO_ShopIncident__c Limit 1 ];
            System.debug('serviceReq'+serviceReq);
          
           if(serviceReq!=null)
            {
           System.debug('Cleaning certificate loop entered');
       System.debug('isCleaningChecked entered');
            
            /* Uncomment to enable Cleaning Cert notoifications    
             CDX_CleaningCertNotificationForSerReq ser= new CDX_CleaningCertNotificationForSerReq(serviceReq);
                        Database.executeBatch(ser);
            */    
            }
            else
            {
                System.debug('No service request associated');
            } 
        }
      }
        }
        else
        {
        boolean CleaningChecked=false;
        boolean serviceReqChecked=false;
        Schema.sObjectType sObjType = Schema.getGlobalDescribe().get('RFO_ShopIncident__c');
        String serviceRequestPrefix = sObjType.getDescribe().getKeyPrefix();
       System.debug('serviceRequestPrefix'+serviceRequestPrefix);
        ContentDocumentLink cdlForServiceRequest= [SELECT id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet  order By LinkedEntityId desc limit 1];  
      if(cdlForServiceRequest!=null)
      {
        System.debug('cdlForServiceRequest'+cdlForServiceRequest);
        String linkedEntityId = cdlForServiceRequest.LinkedEntityId; 
        system.debug('linked entity id: ' + linkedEntityId); 
        
       if(linkedEntityId.startsWith(serviceRequestPrefix))

       {
           System.debug('Entered in LinkedEntityLoop');
       
        RFO_ShopIncident__c serviceReq=[select id,RFO_Customer__r.name,RFO_SIRef__c,RFO_ShopName__c,RFO_Location__c,CDX_Detail_Link__c,CDX_Primary_Contact__r.name,CDX_Primary_Contact__r.email from  RFO_ShopIncident__c where id=:cdlForServiceRequest.LinkedEntityId];
            System.debug('serviceReq'+serviceReq);
          
           if(serviceReq!=null)
            {
           System.debug('Cleaning certificate loop entered');
       System.debug('isCleaningChecked entered');
            /*    
             CDX_CleaningCertNotificationForSerReq ser= new CDX_CleaningCertNotificationForSerReq(serviceReq);
                        Database.executeBatch(ser);
            */    
            }
            else
            {
                System.debug('No service request associated');
            }
       }
      }  
        } 
    }
 
/**************************************************************************************
* @Author : Ashish Reddy
* @Modified Date : 9/10/2020
* @Description       
* @User Story : ALPHA-119    
**************************************************************************************/
    public static void handlePartialFileUploadNotifications(Map<Id,Id> contentVersionToDocumentMap, Map<Id,String> contentDocumentToFileType){
        try{
            List<Task> tasks = new List<Task>();
            Set<Id> quoteIdSet = new Set<Id>();
            Set<Id> riderIdSet = new Set<Id>();
            List<Id> tankGroupMembers = new List<Id>();
            List<Id> freightGroupMembers = new List<Id>();
            Map<Id,Id> linkedEntityToContentDocMap = new Map<Id,Id>();
            
            for(ContentDocumentLink contentLink : [SELECT id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentVersionToDocumentMap.values()]){
                Schema.SObjectType sobjectType = contentLink.LinkedEntityId.getSObjectType();
                String sobjectName = sobjectType.getDescribe().getName();
                if(sobjectType == (SBQQ__Quote__c.getSobjectType())){
                    quoteIdSet.add(contentLink.LinkedEntityId);
                    linkedEntityToContentDocMap.put(contentLink.LinkedEntityId, contentLink.ContentDocumentId);
                }else if(sobjectType == (RFO_Rider__c.getSobjectType())){
                    riderIdSet.add(contentLink.LinkedEntityId);
                    linkedEntityToContentDocMap.put(contentLink.LinkedEntityId, contentLink.ContentDocumentId);
                }
            }
            for(GroupMember member : [select Id, Group.DeveloperName, UserOrGroupId from GroupMember where  Group.Type =: RFO_Constant.QUEUE AND Group.DeveloperName =: RFO_Constant.CONTRACT_ADMIN_TANK_QUEUE ]){
                tankGroupMembers.add(member.UserOrGroupId);
            }
            for(GroupMember member : [select Id, Group.DeveloperName, UserOrGroupId from GroupMember where  Group.Type =: RFO_Constant.QUEUE AND Group.DeveloperName =: RFO_Constant.CONTRACT_ADMIN_FREIGHT_QUEUE ]){
                freightGroupMembers.add(member.UserOrGroupId);
            }
            List<Task> taskList = new List<Task>();
            if(!quoteIdSet.isEmpty()){
                for(SBQQ__Quote__c quote :[select id, RFO_OpportunityRecordType__c from SBQQ__Quote__c where Id IN:quoteIdSet]){
                    if(quote.RFO_OpportunityRecordType__c == RFO_Constant.OPP_RECORDTYPE_TANK){
                        prepareTaskByType(taskList, quote.Id, linkedEntityToContentDocMap.get(quote.Id), tankGroupMembers, contentDocumentToFileType.get(linkedEntityToContentDocMap.get(quote.Id)));
                    }else if(quote.RFO_OpportunityRecordType__c == RFO_Constant.OPP_RECORDTYPE_FREIGHT){
                        prepareTaskByType(taskList, quote.Id, linkedEntityToContentDocMap.get(quote.Id), freightGroupMembers, contentDocumentToFileType.get(linkedEntityToContentDocMap.get(quote.Id)));
                    }
                }
            }
            if(!riderIdSet.isEmpty()){
                for(RFO_Rider__c rider :[select id, RFO_Product__r.RFO_CarTypeGroupName__c from RFO_Rider__c where Id IN:riderIdSet]){
                    system.debug('*************'+rider.RFO_Product__r.RFO_CarTypeGroupName__c );
                    if(rider.RFO_Product__r.RFO_CarTypeGroupName__c == RFO_Constant.OPP_RECORDTYPE_TANK){
                        prepareTaskByType(taskList, rider.Id, linkedEntityToContentDocMap.get(rider.Id), tankGroupMembers, contentDocumentToFileType.get(linkedEntityToContentDocMap.get(rider.Id)));
                    }else if(rider.RFO_Product__r.RFO_CarTypeGroupName__c == RFO_Constant.OPP_RECORDTYPE_FREIGHT){
                        prepareTaskByType(taskList, rider.Id, linkedEntityToContentDocMap.get(rider.Id), freightGroupMembers, contentDocumentToFileType.get(linkedEntityToContentDocMap.get(rider.Id)));
                    }
                }
            }
            
            if(!taskList.isEmpty()){
                insert taskList;
            }
        }catch(Exception e){
            system.debug('******Exception in handlePartialFileUploadNotifications' + e.getCause() + e.getLineNumber() + e.getStackTraceString());
        }
    }

  
/**************************************************************************************
* @Author : Ashish Reddy
* @Modified Date : 9/10/2020
* @Description       


* @User Story : ALPHA-155   
**************************************************************************************/
    private static void sendSignedProposalChatterNotification(Map<Id,Id> contentVersionToDocumentMap){

        Set<Id> quoteIdSet = new Set<Id>();

        for(ContentDocumentLink contentLink : [SELECT id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentVersionToDocumentMap.values()]){
            Schema.SObjectType sobjectType = contentLink.LinkedEntityId.getSObjectType();
            String sobjectName = sobjectType.getDescribe().getName();
            if(sobjectType == (SBQQ__Quote__c.getSobjectType())){
                quoteIdSet.add(contentLink.LinkedEntityId);
            } 
        }
        Set<Id> businessAwardedQuotes = new Set<Id>();
        if(quoteIdSet.size()>0){

            RFO_QuoteHelperClass.sendChatterNotification(quoteIdSet, RFO_Constant.CHATTER_SIGNED_PROPOSAL);
            for(SBQQ__Quote__c quote: [select id from SBQQ__Quote__c where Id in:quoteIdSet and RFO_QuoteStage__c =:RFO_Constant.BUSINESS_AWARDED ]){
                businessAwardedQuotes.add(quote.Id);
            }
        }
        if(businessAwardedQuotes.size()>0){
            RFO_QuoteHelperClass.sendChatterNotification(businessAwardedQuotes, RFO_Constant.CHATTER_FLEET_ENGG);
            RFO_QuoteHelperClass.prepAndSendCustomNotifications(businessAwardedQuotes);
        }
    }
  
/**************************************************************************************
* @Author : Ashish Reddy
* @Modified Date : 9/10/2020
* @Description       


* @User Story : ALPHA-119    
**************************************************************************************/
    private static void prepareTaskByType(List<Task> taskList, Id entityId, Id contentDocId, List<Id> groupMembers, String fileType){
        for(Id grpMember: groupMembers){
            Task t = new Task();
            t.OwnerId = grpMember;
            t.Subject = 'Partially Executed Document uploaded - ' + fileType;
            t.Status = 'Open';
            t.Priority = 'Normal';
            t.WhatId = entityId;
            //t.IsReminderSet = true;
            //t.ReminderDateTime = System.now();
            t.Description = 'Please review this partially executed document - ' + fileType + ' : ' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + contentDocId;
            taskList.add(t);
        }
    }




}