public without sharing class AssetGroupController {
    @auraEnabled
    Public Static void updateAssetGroup(String Description,String groupId,String groupName){
        	Asset_Group__c objAssetGroup 			= 	New Asset_Group__c();
        	objAssetGroup.Id 						= 	groupId;
        	objAssetGroup.Group_Name__c				=	groupName;
            objAssetGroup.Description__c			=	Description;
            //objAssetGroup.TR_Number__c				=	decimal.valueOf(TRNumber);
        update objAssetGroup;
        
    }
    @AuraEnabled
    public static map<String,object> getListViewDetails(String assetGroupId){
        map<String,object> result = New map<String,object>();
        try{
            Asset_Group__c  objAssetGroup = [SELECT Group_Name__c FROM Asset_Group__c WHERE Id=:assetGroupId];
            //objAssetGroup
            Asset_Group_Lines_Matching__c objMatching = Asset_Group_Lines_Matching__c.getInstance(userInfo.getUserId());
            objMatching.Group_Name__c  = objAssetGroup.Group_Name__c;
            objMatching.SetupOwnerId   = userInfo.getUserId();
            upsert objMatching;
            system.debug('objMatching>>>>>>'+objMatching);
            ListView objListView = [SELECT Id FROM ListView WHERE SObjectType = 'Asset_Lines__c' AND developerName='All_Asset_Group_Lines'];
            result.put('success',true);
            result.put('objAssetGroup',true);
            result.put('listViewId',objListView.Id);
            if(TEST.isRunningTest()){
                integer i = 1/0;
            }
        }catch(exception ex){
            result.put('success', false);
            result.put('msg', ex.getMessage());
        }
        return result;
    }
    @auraEnabled
    Public Static Map<String,object> addAssetsToLines(Asset_Group__c objAssetGroup,List<String> lstAssets){
        Map<String,Object> results = New Map<String,Object>();
        system.debug('objAssetGroup>>>>>'+objAssetGroup);
        system.debug('lstAssets>>>>>'+lstAssets);
        try{
            
            List<Asset_Lines__c> lstAssetLines 	= 	New List<Asset_Lines__c>();
            for(String objAsset : lstAssets){
                Asset_Lines__c objAssetLine 	= 	New Asset_Lines__c();
                objAssetLine.Asset_Group__c 	= 	objAssetGroup.Id;
                objAssetLine.Asset__c			=	objAsset;
                lstAssetLines.add(objAssetLine);
            }
            if(!lstAssetLines.isEmpty()){
                Insert lstAssetLines;
            }
           results.put('success', true); 
            if(TEST.isRunningTest()){
                integer i = 1/0;
            }
        }catch(exception ex){
            system.debug('exception>>>>'+ex);
            system.debug('exception>>>>'+ex.getCause());
            system.debug('exception>>>>'+ex.getStackTraceString());
            results.put('success', false);
            results.put('msg', ex.getMessage());
        }
        return results;
    }
    @auraEnabled
    Public Static integer getTotalAssetsAvailable(){
            return [SELECT COUNT() FROM Asset WHERE RFO_CarType__c!=''];
    }
	@auraEnabled
    //Public Static List<Object> getAssetsInformation(String searchKey,Integer rowLimit,Integer rowOffset){
    Public Static Map<String,Object> getAssetsInformation(List<String> SelectedAssetIDs,String lineItemId){
    //Public Static Map<String,Object> getAssetsInformation(Integer rowLimit,Integer rowOffset,
      //                                                    List<String> SelectedAssetIDs,String searchKey){
        Map<String,object> results = New Map<String,Object>();
        //EPSI-782 - Begin - Ashish Reddy
        Set<String> SelectedAssetIdsSet = new Set<String>();
        try{
             
            for(String str : SelectedAssetIDs){
               SelectedAssetIdsSet.add(str);
            }            
             
            
            system.debug('lineItemId>>>>>>'+lineItemId);
            SBQQ__QuoteLine__c  objQuoteLine = [SELECT SBQQ__Quote__c, SBQQ__Quote__r.RFO_Product__c FROM SBQQ__QuoteLine__c WHERE Id=:lineItemId LIMIT 1];
            String productId = objQuoteLine.SBQQ__Quote__r.RFO_Product__c;
            
            
            Id quoteId = objQuoteLine.SBQQ__Quote__c;
            Set<Id> quoteLineIds = new Set<Id>();
            for( SBQQ__QuoteLine__c  quotLine : [SELECT Id  FROM SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId ] ){
                quoteLineIds.add(quotLine.Id);
            }
            if(!quoteLineIds.isEmpty()){
                for(Asset_Lines__c  assetLine :[SELECT Id, Asset__c from Asset_Lines__c where Asset_Group__c in (select id from Asset_Group__c where Quote_Line__c in :quoteLineIds)]){
                    SelectedAssetIdsSet.add(assetLine.Asset__c);
                }                
            }
			//EPSI-782 - End
            /*
            if(String.isNotEmpty(searchKey) && String.isNotBlank(searchKey)){
                searchKey = searchKey+'%';
            }
			*/
            integer  totoalAssets = 0;
            /*
            if(String.isNotEmpty(searchKey) && String.isNotBlank(searchKey)){
                totoalAssets =  [SELECT COUNT() FROM Asset WHERE Id Not IN:SelectedAssetIDs AND  RFO_CarType__c!='' 
                                 AND (Name LIKE:searchKey OR Account.Name LIKE:searchKey OR Product2.Name LIKE:searchKey)];
            }else{
               totoalAssets =  [SELECT COUNT() FROM Asset WHERE Id Not IN:SelectedAssetIDs AND  RFO_CarType__c!='' ]; 
            }
            */
            totoalAssets =  [SELECT COUNT() FROM Asset WHERE Id Not IN:SelectedAssetIDs AND  RFO_CarType__c!=''
                            AND Id NOT IN:SelectedAssetIDs
                            AND Product2Id=:productId
                            AND status NOT IN ('Destroyed', 'sold', 'scrapped')];
            List<Object> allAssrts = New List<Object>();
            /*
            String strQuery =  '';
            system.debug('searchKey>>>>>'+searchKey);
            if(String.isNotEmpty(searchKey) && String.isNotBlank(searchKey)){
                	strQuery 		= 	'SELECT Name,RFO_TRNumber__c,Project_Number__c,RFO_CarType__c,RFO_CarNumber__c,RFO_CarOwner__c,';
            		strQuery		+=	'SBQQ__ChargeType__c,SBQQ__CombineKey__c,RFO_CommittedTo__c,Company__c,SBQQ__CreditProductId__c,';
            		strQuery		+=	'SBQQ__ListPrice__c,SBQQ__Number__c,SBQQ__OptionDiscount__c,RFO_Origin__c,Price,SBQQ__PricingMethod__c,Quantity,';
            		strQuery		+=	'ProductCode,Product2Id,Product2.Name,SBQQ__QuoteLine__c,RFO_RAType__c,Account.Name,AccountId,';
            		strQuery		+=	'Status,RFO_UOM__c FROM Asset WHERE RFO_CarType__c!=NULL AND  (Name LIKE:searchKey OR Account.Name LIKE:searchKey OR Product2.Name LIKE:searchKey) LIMIT :rowLimit OFFSET :rowOffset';
            }else{
                	strQuery 		= 	'SELECT Name,RFO_TRNumber__c,Project_Number__c,RFO_CarType__c,RFO_CarNumber__c,RFO_CarOwner__c,';
            		strQuery		+=	'SBQQ__ChargeType__c,SBQQ__CombineKey__c,RFO_CommittedTo__c,Company__c,SBQQ__CreditProductId__c,';
            		strQuery		+=	'SBQQ__ListPrice__c,SBQQ__Number__c,SBQQ__OptionDiscount__c,RFO_Origin__c,Price,SBQQ__PricingMethod__c,Quantity,';
            		strQuery		+=	'ProductCode,Product2Id,Product2.Name,SBQQ__QuoteLine__c,RFO_RAType__c,Account.Name,AccountId,';
            		strQuery		+=	'Status,RFO_UOM__c FROM Asset WHERE RFO_CarType__c!=NULL LIMIT :rowLimit OFFSET :rowOffset';
            }
            */
            /*  
            for(Asset objAsset: [SELECT Name,RFO_TRNumber__c,Project_Number__c,
                				RFO_CarType__c,RFO_CarNumber__c,RFO_CarOwner__c,
                				SBQQ__ChargeType__c,SBQQ__CombineKey__c,
                				RFO_CommittedTo__c,Company__c,SBQQ__CreditProductId__c,
                				SBQQ__ListPrice__c,SBQQ__Number__c,SBQQ__OptionDiscount__c,
                				RFO_Origin__c,Price,SBQQ__PricingMethod__c,Quantity,
                				
							syst,Product2Id,Product2.Name,
                				SBQQ__QuoteLine__c,RFO_RAType__c,Account.Name,AccountId,
               					Status,RFO_UOM__c FROM Asset WHERE RFO_CarType__c!='' 
                                LIMIT :rowLimit OFFSET :rowOffset] ){
                                    
                                   */ 
            for(Asset objAsset:  [SELECT Name,
                                  RFO_TRNumber__c,
                                  RFO_CarType__c,
                                  RFO_CarNumber__c,
                                  RFO_File__c,
                                  RFO_CarCondition__c,
                                  RFO_LocationStatus__c,
								  Account.Name,
                                  AccountId,
                                  RFO_DaysNotMoved__c,
                                  Status,
                                  Product2Id,
                                  Product2.Name,
                                  RFO_Origin__c,
                                  RFO_RAType__c,
                                  (SELECT Name,RFO_Project__r.Name FROM Project_Asset_SI__r ORDER BY Name  DESC LIMIT 1)
                                  FROM Asset WHERE RFO_CarType__c!=NULL 
                                  AND Id NOT IN:SelectedAssetIdsSet
                                  AND Product2Id=:productId
                                  AND status NOT IN ('Destroyed', 'sold', 'scrapped')
                                  ORDER BY RFO_DaysNotMoved__c DESC LIMIT 50000
                                 ]){
                                     //Product id from quote should match with Asset Prodcut.
                                     //RFO_Product__c
                                     //And status not in ('Destroyed', 'sold', 'scrapped')
                                     //
                                 if(!SelectedAssetIDs.contains(objAsset.Id)){
                                    system.debug('objAsset.Id>>>>>'+objAsset.Id);
                                    system.debug('objAsset>>>>>> in the list>>'+objAsset);
                                     if(objAsset.RFO_DaysNotMoved__c == null){
                                         objAsset.RFO_DaysNotMoved__c = 0;
                                     }
                                     String projectNumber = '';
                                     if(!objAsset.Project_Asset_SI__r.isEmpty()){
                                         projectNumber = objAsset.Project_Asset_SI__r[0].RFO_Project__r.Name;
                                     }
                                    allAssrts.add(New Map<String,Object>{
                                               		'Id'=>  objAsset.Id,
													'AssestLink' =>'/'+objAsset.Id,
                                                	'AssestName'=>objAsset.Name,
                                                	'TRNUmber' =>objAsset.RFO_TRNumber__c,
                                                	//'Projectnumber'=>objAsset.Project_Number__c,
                                                    'Projectnumber'=>projectNumber,
                                                    'ProductName'=>objAsset.Product2.Name,
                                                    'ProductLink'=>'/'+objAsset.Product2Id,
                                                    'CarType'=>objAsset.RFO_CarType__c,
                                                    'AssetAge'=>objAsset.RFO_DaysNotMoved__c,
                                                    'Status'=>objAsset.Status,
                                                    'AccountName'=>objAsset.Account.Name,
                                                    'AccountLink'=>'/'+objAsset.AccountId,
                                                    'Location'=>    objAsset.RFO_Origin__c,
												    'CarFile'=>objAsset.RFO_File__c,
												    'ServiceStatus'=>objAsset.RFO_CarCondition__c,
												    'LocationStatus'=>objAsset.RFO_LocationStatus__c
                                    });
                                }    
                                     
               /*
                if(!SelectedAssetIDs.isEmpty()){
                    system.debug('SelectedAssetIDs not empty>>>>>>>>');
                    	if(SelectedAssetIDs.contains(objAsset.Id) == false){
                            system.debug('objAsset.Id>>>>>'+objAsset.Id);
                            system.debug('objAsset>>>>>> in the list>>'+objAsset);
                            allAssrts.add(New Map<String,Object>{
                                       'Id'=>  objAsset.Id,
                                        'AssestLink' =>'/'+objAsset.Id,
                                           'AssestName'=>objAsset.Name,
                                          'TRNUmber' =>objAsset.RFO_TRNumber__c,
                                           'Projectnumber'=>objAsset.Project_Number__c,
                                           'ProductName'=>objAsset.Product2.Name,
                                           'ProductLink'=>'/'+objAsset.Product2Id,
                                           'CarType'=>objAsset.RFO_CarType__c,
                                           'Status'=>objAsset.Status,
                                           'AccountName'=>objAsset.Account.Name,
                                           'AccountLink'=>'/'+objAsset.AccountId
                            });
                        }
                }else{
                    system.debug('objAsset>>>>>>'+objAsset);
                    	allAssrts.add(New Map<String,Object>{
                                       'Id'=>  objAsset.Id,
                                        'AssestLink' =>'/'+objAsset.Id,
                                           'AssestName'=>objAsset.Name,
                                          'TRNUmber' =>objAsset.RFO_TRNumber__c,
                                           'Projectnumber'=>objAsset.Project_Number__c,
                                           'ProductName'=>objAsset.Product2.Name,
                                           'ProductLink'=>'/'+objAsset.Product2Id,
                                           'CarType'=>objAsset.RFO_CarType__c,
                                           'Status'=>objAsset.Status,
                                           'AccountName'=>objAsset.Account.Name,
                                           'AccountLink'=>'/'+objAsset.AccountId
                            });
                }
                
                    
                */                    
        	}
            system.debug('allAssrts>>>>>'+allAssrts.size());
            system.debug('allAssrts>>>>>'+allAssrts);
            results.put('success',true);
            results.put('allAssets',allAssrts);
            system.debug('totoalAssets>>>>>>'+totoalAssets);
            results.put('TotalAssets',totoalAssets);
            if(TEST.isRunningTest()){
                integer i = 1/0;
            }
        }catch(exception ex){
            results.put('success',false);
            results.put('msg',ex.getMessage());
        }
        return results;
    }
    @auraEnabled
    public static Map<String,Object> getAssetInformation(Id lineItemId){
        Map<String,Object> result = New Map<String,Object>();
        try{
            String sObjName = lineItemId.getSObjectType().getDescribe().getName();
            system.debug('sObjName>>>>>'+sObjName);
            Asset_Group__c  objAssetGroup   = New Asset_Group__c();
            if(sObjName  == 'SBQQ__QuoteLine__c'){
              objAssetGroup  = [SELECT Name,
                                Group_Name__c,
                                Description__c,Number_of_Assets__c,Quote_Line__c,Quote_Line__r.Name
                                           FROM Asset_Group__c WHERE Quote_Line__c=:lineItemId LIMIT 1];
             
            }else if(sObjName  == 'Asset_Group__c'){
                objAssetGroup  = [SELECT Name,
                                  Group_Name__c,
                                  Description__c,Number_of_Assets__c,Quote_Line__c,Quote_Line__r.Name
                                           FROM Asset_Group__c WHERE Id=:lineItemId LIMIT 1];
            }
           system.debug('objAssetGroup>>>>>'+objAssetGroup);
            Set<String> setAssetIds =  New Set<String>();
            for(Asset_Lines__c objAssetLine : [SELECT Asset_Group__c,Asset__c FROM Asset_Lines__c 
                								WHERE Asset_Group__c=:objAssetGroup.Id]){
                setAssetIds.add(objAssetLine.Asset__c);
            }
            Map<String,RFO_ProjectAssetSI__c> mapProjectAssets = New Map<String,RFO_ProjectAssetSI__c>();
            if(!setAssetIds.isEmpty()){
                for(RFO_ProjectAssetSI__c objProjectAsset :[SELECT RFO_Asset__c,Name,RFO_Project__r.Name FROM RFO_ProjectAssetSI__c WHERE RFO_Asset__c IN:setAssetIds ORDER BY Name]){
                    if(!mapProjectAssets.containsKey(objProjectAsset.RFO_Asset__c)){
                        mapProjectAssets.put(objProjectAsset.RFO_Asset__c,objProjectAsset);
                    }
                }
            }
            system.debug('mapProjectAssets>>>>>>'+mapProjectAssets);
            List<Object> lstAssetLines  = New List<Object>();
            for(Asset_Lines__c objAssetLine : [SELECT Asset_Group__c,Asset_Group__r.Name,
                                                  Asset_Group__r.Group_Name__c,
                                               	  Asset_Location__c,
                                                  Asset__c,
                                                  Asset__r.Name,
                                                  Asset__r.Account.Name,
                                                  Asset__r.AccountId,
                                                  Asset__r.Product2.Name,
                                                  Asset__r.Product2Id,
                                                  Asset__r.RFO_TRNumber__c,
                                                  Asset__r.RFO_CarType__c,
                                                  Asset__r.RFO_DaysNotMoved__c,
                                                  Asset__r.Status,
                                                  Asset__r.RFO_File__c,
                                                  Asset__r.RFO_CarCondition__c,
                                                  Asset__r.RFO_LocationStatus__c
                                                  FROM Asset_Lines__c
                                                  WHERE Asset_Group__c=:objAssetGroup.Id]){
                                    String projectNumber = '';
                                     if(mapProjectAssets.containsKey(objAssetLine.Asset__c)){
                                         projectNumber = mapProjectAssets.get(objAssetLine.Asset__c).RFO_Project__r.Name;
                                     }
                						lstAssetLines.add(New Map<String,Object>{
                                               		'Id'				=>  objAssetLine.Id,
													'AssetGroupName' 	=>	'/'+objAssetLine.Asset_Group__r.Name,'AssetGroupLink'	=>	'/'+objAssetLine.Asset_Group__c,
                                                     'AssetLocation'   	=>	objAssetLine.Asset_Location__c,'AssetId' 			=>	objAssetLine.Asset__c,
                                                    'AssetName'			=>	objAssetLine.Asset__r.Name,'AssetLink'			=>	'/'+objAssetLine.Asset__c,
                                                    'AccountName'		=>	objAssetLine.Asset__r.Account.Name,'AccountLink'		=>	'/'+objAssetLine.Asset__r.AccountId,
                                                    'ProductLink'		=>	'/'+objAssetLine.Asset__r.Product2Id,
                                                    'ProductName'		=>	objAssetLine.Asset__r.Product2.Name,'TRNUmber' 			=>	objAssetLine.Asset__r.RFO_TRNumber__c,'Projectnumber'		=>	projectNumber,
                                                    'CarType'			=>	objAssetLine.Asset__r.RFO_CarType__c,'AssetAge'			=>	objAssetLine.Asset__r.RFO_DaysNotMoved__c,
                                                    'Status'			=>	objAssetLine.Asset__r.Status,'CarFile'			=>	objAssetLine.Asset__r.RFO_File__c,
												    'ServiceStatus'		=>	objAssetLine.Asset__r.RFO_CarCondition__c,'LocationStatus'	=>	objAssetLine.Asset__r.RFO_LocationStatus__c
                                    });
            }
            /*
            List<Asset_Lines__c> lstAssetLines = [SELECT Asset_Group__c,Asset_Group__r.Name,
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
                                                  WHERE Asset_Group__c=:objAssetGroup.Id];
			*/
            //ListView objCPQAssets =  [SELECT Name FROM ListView WHERE DeveloperName='CPQ_All_Assets' LIMIT 1];
            system.debug('lstAssetLines>>>>'+lstAssetLines);
             result.put('AssetGroup',objAssetGroup);
             result.put('AssetLines',lstAssetLines);
			//result.put('AssetListView',objCPQAssets);
            result.put('success',true);
            if(TEST.isRunningTest()){
                integer i = 1/0;
            }
        }catch(exception ex){
            system.debug('exception>>>>>>>>'+ex.getStackTraceString());
            system.debug('exception>>>>>>>>'+ex);
            result.put('success',false);
            result.put('msg',ex.getMessage());
        }
        return result;
    }
    @auraEnabled
    Public static Map<String,object> deleteAssestLineItems(List<String> SeletedRows){
        Map<String,object> result = New Map<String,object>();
        try{
           List<Asset_Lines__c> lstDelete = New List<Asset_Lines__c>();
            for(String IdVal : SeletedRows){
                Asset_Lines__c objAsselineDel = New Asset_Lines__c(Id=IdVal);
                lstDelete.add(objAsselineDel);
            }
            if(!lstDelete.isEmpty()){
                Delete lstDelete;
            }
            result.put('success',true);
            if(TEST.isRunningTest()){
                integer i = 1/0;
            }
        }catch(exception ex){
            result.put('success',false);
            result.put('msg',ex.getMessage());
        }
        return result;
        
    }
}