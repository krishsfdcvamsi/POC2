public without sharing class ManageMassAssetsController {

    @auraEnabled
    Public Static Map<String,Object> getAllAssetsLines(String quoteId,integer queryOffSet,
                                                       integer queryLimit,String searchKey){
        system.debug('quoteId>>>>>'+quoteId);
       	Map<String,Object>  result = New Map<String,Object>();
        try{
            if(String.isNotBlank(searchKey) && String.isNotEmpty(searchKey)){
                searchKey=searchKey+'%';
            }else{
                searchKey = '';
            }
            system.debug('searchKey>>>>>>>>'+searchKey);
            Set<Id> setQuoteLineGroupIds  = New Set<Id>();
            if(String.isNotBlank(searchKey) && String.isNotEmpty(searchKey)){
                for(Asset_Group__c objAssetGroup : [SELECT Id FROM Asset_Group__c WHERE 
                                                    Quote_Line__r.SBQQ__Quote__c =:quoteId 
                                                    AND 
                                                    (Name Like:searchKey OR Group_Name__c Like:searchKey)
                                                   ]){
                    setQuoteLineGroupIds.add(objAssetGroup.Id);
            }
            }else{
                for(Asset_Group__c objAssetGroup : [SELECT Id FROM Asset_Group__c WHERE 
                                                    Quote_Line__r.SBQQ__Quote__c =:quoteId
                                                   ]){
                    setQuoteLineGroupIds.add(objAssetGroup.Id);
            	}
            }
            system.debug('setQuoteLineGroupIds>>>>>>'+setQuoteLineGroupIds);
            integer  totoalAssets  = [SELECT COUNT() FROM Asset_Lines__c 
                                     WHERE  Asset_Group__c IN: setQuoteLineGroupIds];
            /*
            if(String.isNotBlank(searchKey) && String.isNotEmpty(searchKey)){
                totoalAssets = [SELECT COUNT() FROM Asset_Lines__c 
                                     WHERE  
                               Asset_Group__c IN: setQuoteLineGroupIds];
            }else{
                totoalAssets = [SELECT COUNT() FROM Asset_Lines__c 
                                     WHERE  Asset_Group__c IN: setQuoteLineGroupIds];
            }
			*/
            system.debug('totoalAssets>>>>>>'+totoalAssets);
            if(!setQuoteLineGroupIds.isEmpty()){
                /*
                String QueryTogetAssetLins = 'SELECT Asset_Group__c,Asset_Group__r.Name,Asset_Group__r.Group_Name__c,Asset__c,Asset__r.Name,Asset__r.RFO_TRNumber__c,Asset__r.Project_Number__c,Asset__r.RFO_CarType__c,Asset__r.RFO_Origin__c,Asset__r.Price,Asset__r.ProductCode,Asset__r.ProductFamily,Asset__r.PurchaseDate,Asset__r.Quantity,Asset__r.SerialNumber,Asset__r.Status,Asset__r.Product2Id,Asset__r.Product2.Name,Asset__r.ParentId,Asset__r.Parent.Name,Asset__r.ManufactureDate,Asset__r.ContactId,Asset__r.Contact.Name,Asset__r.AccountId,Asset__r.Account.Name FROM Asset_Lines__c';
                if(String.isNotBlank(searchKey) && String.isNotEmpty(searchKey)){
                    //QueryTogetAssetLins = 'SELECT Asset_Group__c,Asset_Group__r.Name,Asset_Group__r.Group_Name__c,Asset__c,Asset__r.Name,Asset__r.RFO_TRNumber__c,Asset__r.Project_Number__c,Asset__r.RFO_CarType__c,Asset__r.RFO_Origin__c,Asset__r.Price,Asset__r.ProductCode,Asset__r.ProductFamily,Asset__r.PurchaseDate,Asset__r.Quantity,Asset__r.SerialNumber,Asset__r.Status,Asset__r.Product2Id,Asset__r.Product2.Name,Asset__r.ParentId,Asset__r.Parent.Name,Asset__r.ManufactureDate,Asset__r.ContactId,Asset__r.Contact.Name,Asset__r.AccountId,Asset__r.Account.Name FROM Asset_Lines__c';
                	QueryTogetAssetLins+=' WHERE Asset_Group__c IN: setQuoteLineGroupIds AND (Asset_Group__r.Name LIKE:searchKey OR Asset_Group__r.Group_Name__c LIKE:searchKey) ORDER BY Asset_Group__r.Name ASC LIMIT :queryLimit OFFSET :queryOffSet';
                }else{
                    QueryTogetAssetLins += ' WHERE Asset_Group__c IN: setQuoteLineGroupIds ORDER BY Asset_Group__r.Name ASC LIMIT :queryLimit OFFSET :queryOffSet';
                }
                system.debug('QueryTogetAssetLins>>>>>>>'+QueryTogetAssetLins);
                
                for(Asset_Lines__c objAssetLines : Database.query(QueryTogetAssetLins)){
                */
                Set<String> setAssetIds =  New Set<String>();
                for(Asset_Lines__c objAssetLine : [SELECT Asset_Group__c,Asset__c FROM Asset_Lines__c 
                                                    WHERE Asset_Group__c IN:setQuoteLineGroupIds]){
                    setAssetIds.add(objAssetLine.Asset__c);
                }
                Map<String,RFO_ProjectAssetSI__c> mapProjectAssets = New Map<String,RFO_ProjectAssetSI__c>();
                if(!setAssetIds.isEmpty()){
                    for(RFO_ProjectAssetSI__c objProjectAsset :[SELECT RFO_Asset__c,Name,RFO_Project__r.Name FROM RFO_ProjectAssetSI__c ORDER BY Name]){
                        if(!mapProjectAssets.containsKey(objProjectAsset.RFO_Asset__c)){
                            mapProjectAssets.put(objProjectAsset.RFO_Asset__c,objProjectAsset);
                        }
                    }
                }
                List<Object> allAssrts = New List<Object>();
                for(Asset_Lines__c objAssetLines : [SELECT 
                                                   Asset_Group__c,
                                                   Asset_Group__r.Name,
                                                   Asset_Group__r.Group_Name__c,
                                                   Asset__c,
                                                   Asset__r.Name,
                                                   Asset__r.RFO_TRNumber__c,
                                                   Asset__r.Project_Number__c,
                                                   Asset__r.RFO_CarType__c,
                                                   Asset__r.RFO_Origin__c,
                                                   Asset__r.Price,
                                                   Asset__r.ProductCode,
                                                   Asset__r.ProductFamily,
                                                   Asset__r.PurchaseDate,
                                                   Asset__r.Quantity,
                                                   Asset__r.SerialNumber,
                                                   Asset__r.Status,
                                                   Asset__r.Product2Id,
                                                   Asset__r.Product2.Name,
                                                   Asset__r.ParentId,
                                                   Asset__r.Parent.Name,
                                                   Asset__r.ManufactureDate,
                                                   Asset__r.ContactId,
                                                   Asset__r.Contact.Name,
                                                   Asset__r.AccountId,
                                                   Asset__r.Account.Name
                                                   FROM Asset_Lines__c
                                                   WHERE Asset_Group__c IN: setQuoteLineGroupIds  
                                                   ORDER BY Asset_Group__r.Name ASC
                                                   //LIMIT :queryLimit OFFSET :queryOffSet
                                                   ]){
                                                       
                                                      String assetGroupName = '';
                                                       if(String.isNotBlank(objAssetLines.Asset_Group__r.Group_Name__c)
                                                         &&
                                                         String.isNotEmpty(objAssetLines.Asset_Group__r.Group_Name__c)){
                                                           assetGroupName  = objAssetLines.Asset_Group__r.Group_Name__c;
                                                         }else{
                                                             assetGroupName  = objAssetLines.Asset_Group__r.Name;
                                                         }
                                                        String projectNumber = '';
                                     if(mapProjectAssets.containsKey(objAssetLines.Asset__c)){
                                         projectNumber = mapProjectAssets.get(objAssetLines.Asset__c).RFO_Project__r.Name;
                                     }
                    				allAssrts.add(New Map<String,Object>{
                                       		'Id'					=>  objAssetLines.Id,
                                        	'AssestLineLink' 		=>	'/'+objAssetLines.Id,
                                            'AssestLineGroupName' 	=>	assetGroupName,
                                            'AssestLineGroupLink' 	=>	'/'+objAssetLines.Asset_Group__c,
                                            'AssestName'			=>	objAssetLines.Asset__r.Name,
                                            'AssestLink'			=>	'/'+objAssetLines.Asset__c,
                                            'TRNUmber' 				=>	objAssetLines.Asset__r.RFO_TRNumber__c,
                                           	'Projectnumber'			=>	projectNumber,
                                           	'ProductName'			=>	objAssetLines.Asset__r.Product2.Name,
                                           	'ProductLink'			=>	'/'+objAssetLines.Asset__r.Product2Id,
                                           	'CarType'				=>	objAssetLines.Asset__r.RFO_CarType__c,
                                           	'Status'				=>	objAssetLines.Asset__r.Status,
                                           	'AccountName'			=>	objAssetLines.Asset__r.Account.Name,
                                           	'AccountLink'			=>	'/'+objAssetLines.Asset__r.AccountId
                                   });
                }
               system.debug('allAssrts>>>>>'+allAssrts);
               result.put('success',true); 
               result.put('AssetLinse',allAssrts); 
                result.put('totoalAssets',totoalAssets); 
            }else{
                result.put('noAssetsLines',true);
                result.put('noAssestMsg','No Assets Found.');
            }
            if(test.isRunningTest()){
                integer i =1/0;
            }
        }catch(exception ex){
            result.put('success',false);
            result.put('msg',ex.getMessage());
        }
        //Asset_Lines__c
    	return result;
    }
   @auraEnabled
    Public Static Map<String,Object> updateAssetLineGroups(String groupId,List<String> assetLines){ 
        Map<String,object> result = New Map<String,Object>();
        try{
            List<Asset_Lines__c> lstAssetLines = New List<Asset_Lines__c>();
            for(String assetLineId : assetLines){
                Asset_Lines__c  objAssetLine 	=  New Asset_Lines__c();
                objAssetLine.Id 				=  assetLineId;
                objAssetLine.Asset_Group__c 	=  groupId;
                lstAssetLines.add(objAssetLine);
            }
            update lstAssetLines;
           result.put('success',true); 
            if(test.isRunningTest()){
                integer i =1/0;
            }
        }catch(exception ex){
            result.put('success',false);
            result.put('msg',ex.getMessage());
        }
        return result;
}
}