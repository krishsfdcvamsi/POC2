trigger CDX_ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert)	
{	
	if(Trigger.isInsert && Trigger.isBefore)	
	{	
		//Document Visablitiy	
		final String USER_PREFIX = '005'; 	
		String ccsLabel = Label.CCS_Label;	
		system.debug('ccsLabel'+ccsLabel);	
		String SIlbl = Label.CDX_SI_prefix;	
		system.debug('SIlbl:'+SIlbl);	
        String acclbl = Label.CDX_Account_Label;
        system.debug('acclbl:'+acclbl);
        
			
		Set<String> profilesToCheck 	
			= new Set<String>{ 'CDX Customer', 'CDX Customer - Super User' }; 	
					
				system.debug('executing contentdocumentlink trigger');         	
			
		List<ContentDocumentLink> itemsToProcess = new List<ContentDocumentLink>();	
		Set<String> ownerIds = new Set<String>();     	
		for (ContentDocumentLink cdl : Trigger.new)	
		{	
			if (!String.valueOf(cdl.LinkedEntityId).startsWith(USER_PREFIX))	
			{	
				itemsToProcess.add(cdl);	
			} 	
				
			/*Below code is to avoid duplicate documents to be uploaded on SI and Commodity objects	
			 * Developer: Sumana Kumbum 	
			 * Date: 10/02/2020 */	
            if ((String.valueOf(cdl.LinkedEntityId).startsWith(SIlbl))||(String.valueOf(cdl.LinkedEntityId).startsWith(ccsLabel))||(String.valueOf(cdl.LinkedEntityId).startsWith(acclbl)))
			{	
				List<ContentDocumentLink> contentDocLinks = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: cdl.LinkedEntityId];	
				List<Id> contentDocIds = new List<Id>();	
				for (ContentDocumentLink cd : contentDocLinks)	
				{	
				   contentDocIds.add(cd.ContentDocumentId);	
				}	
				List<ContentDocument> contentDocs = [SELECT FileExtension,FileType,Id,Title FROM ContentDocument WHERE Id =: contentDocIds];	
				ContentDocument contentDocNew = [SELECT FileExtension,FileType,Id,Title FROM ContentDocument WHERE Id = :cdl.ContentDocumentId];	
				for (ContentDocument contentDoc : contentDocs)	
				{	
                    if (contentDoc.Title == contentDocNew.Title && contentDoc.FileExtension == contentDocNew.FileExtension) 
					{	
                        cdl.adderror('You are uploading a file with an existing file name and extension. Please change the file name or extension to load the document');
					}	
				}	
			} 	
		}	
		System.debug('itemsToProcess'+ itemsToProcess);	
		User userInformation = [select Id, Profile.Name from User where Id =: UserInfo.getUserId()]; 	
			
		String profileName = userInformation.Profile.Name;	
			
		system.debug('profilename is ' + profileName);	
			
		if (profilesToCheck.contains(profileName))	
		{	
			for (ContentDocumentLink cdl : itemsToProcess)	
			{	
				system.debug('setting visibility to All users'); 	
				cdl.Visibility = 'AllUsers';        	
				//cdl.ShareType = 'C'; 	
			}    	
		}	
			
		for (ContentDocumentLink cdl : itemsToProcess)	
		{	
			if (String.valueOf(cdl.LinkedEntityId).startsWith(ccsLabel))	
			{	
			system.debug('setting visibility to All users'); 	
				cdl.Visibility = 'AllUsers';        	
			 //   cdl.ShareType = 'C';  	
			}	
		}	
	}	
		
	if(Trigger.isInsert && Trigger.isAfter)	
	{	
		ContentDocumentLinkHandler.LaunchEvent(Trigger.new);	
		ContentDocumentLinkHandler.updateAssetFile(Trigger.new);//Alpha-741, Haseeb, Purpose: Updates BOM File Uploaded field on asset file when BOM Document is uploaded.
	}	
	
}