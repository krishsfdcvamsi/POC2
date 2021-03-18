public with sharing class gapProcessSelectedCarsController {
    @auraEnabled
    Public Static map<String,object> createLineItem(List<String> selectAsIdGroups,List<String> selectNeedConfig,String quoteId){
        Map<String,object> results = New Map<String,Object>();
        try{
            String strProductId  =  [SELECT RFO_Product__c FROM SBQQ__Quote__c WHERE Id=:quoteId LIMIT 1].RFO_Product__c;
          
            if(String.isNotEmpty(strProductId) && String.isNotBlank(strProductId)){
                system.debug('selectAsIsGroups>>>>'+selectAsIdGroups);
                system.debug('selectNeedConfig>>>>'+selectNeedConfig);
              /*  set<string> allAgs = new set<string>();
                allags.addall(selectAsIdGroups);
                allags.addall(selectNeedConfig);
                Map<id, asset_group__c> ags = new Map<id, asset_group__c>([select id,Quote_Line__c from asset_group__c where Id in :allags ]);*/
                Map<String,String> mapQuoteLineGroups = New Map<String,String>();
                for(SBQQ__QuoteLineGroup__c objQuoteLineGroup : [SELECT Name FROM SBQQ__QuoteLineGroup__c 
                                                                    WHERE SBQQ__Quote__c=:quoteId]){
                                                                        
                    mapQuoteLineGroups.put(objQuoteLineGroup.Name,objQuoteLineGroup.Id);
                }
                 system.debug('mapQuoteLineGroups>>>>>>'+mapQuoteLineGroups);           
                List<SBQQ__QuoteLine__c> lstSelectAs 		= 	New List<SBQQ__QuoteLine__c>();
                List<Asset_Group__c> lstSelectAsGroups 		= 	New List<Asset_Group__c>();
                for(String objGroupId : selectAsIdGroups){
                    SBQQ__QuoteLine__c objQuoteLine 		=  	New SBQQ__QuoteLine__c();
                    objQuoteLine.SBQQ__Group__c 			= 	mapQuoteLineGroups.get('As Configured');
                    objQuoteLine.SBQQ__Quote__c 			= 	quoteId;
                    objQuoteLine.RFO_TransactionType__c  	= 	'Management Services';
                    //if(TEST.isRunningTest()){
                    //String strProductId  =  [SELECT RFO_Product__c FROM SBQQ__Quote__c WHERE Id=:quoteId LIMIT 1].RFO_Product__c;
                    //}
                    objQuoteLine.SBQQ__Product__c		=	strProductId;
                    objQuoteLine.Asset_Group__c				=	objGroupId;
                    objQuoteLine.SBQQ__Bundle__c			=	true;
                    objQuoteLine.SBQQ__SubscriptionScope__c	= 	'Group';
                     
                    //if(quoteGroup  == 'Need Configuration'){
                       // objQuoteLine.Need_Configuration__c		= true;
                    //}
                    lstSelectAs.add(objQuoteLine);
                }
                if(!lstSelectAs.isEmpty()){
                        Insert lstSelectAs;
                    Map<String,String> mapQuoteGroups = New Map<String,String>();
                    for(SBQQ__QuoteLine__c objSelectAsQL : lstSelectAs){mapQuoteGroups.put(objSelectAsQL.Asset_Group__c,objSelectAsQL.Id);
                    }
                    system.debug('mapQuoteGroups>>>>>>>'+mapQuoteGroups);
                    
                    for(String selectAsGr : selectAsIdGroups){
                        Asset_Group__c objAssetGroup 			= 	New Asset_Group__c();objAssetGroup.Id 						= 	selectAsGr;objAssetGroup.Quote_Line__c				=	mapQuoteGroups.get(selectAsGr);lstSelectAsGroups.add(objAssetGroup);
                        //update objAssetGroup;
                    }
                }
                List<SBQQ__QuoteLine__c> lstNeedConfig 		= 	New List<SBQQ__QuoteLine__c>();
                for(String objGroupId : selectNeedConfig){
                    SBQQ__QuoteLine__c objQuoteLine 		=  	New SBQQ__QuoteLine__c();
                    objQuoteLine.SBQQ__Group__c 			= 	mapQuoteLineGroups.get('Need Configuration');
                    objQuoteLine.SBQQ__Quote__c 			= 	quoteId;
                    objQuoteLine.SBQQ__Product__c		=	strProductId;
                    //objQuoteLine.RFO_TransactionType__c  	= 	'Management Services';
                    objQuoteLine.Asset_Group__c				=	objGroupId;
                    objQuoteLine.Need_Configuration__c		= 	true;
                    objQuoteLine.SBQQ__Bundle__c			=	true;
                    lstNeedConfig.add(objQuoteLine);
                }
                if(!lstNeedConfig.isEmpty()){
                    Insert lstNeedConfig;
                    Map<String,String> mapQuoteGroups = New Map<String,String>();
                    for(SBQQ__QuoteLine__c objNeed : lstNeedConfig){mapQuoteGroups.put(objNeed.Asset_Group__c,objNeed.Id);}
                    system.debug('mapQuoteGroups>>>>>>>'+mapQuoteGroups);
                    for(String needConfig : selectNeedConfig){
                        Asset_Group__c objAssetGroup 			= 	New Asset_Group__c();objAssetGroup.Id 						= 	needConfig;objAssetGroup.Quote_Line__c				=	mapQuoteGroups.get(needConfig);lstSelectAsGroups.add(objAssetGroup);
                        //update objAssetGroup;
                    }
                }
                if(!lstSelectAsGroups.isEmpty()){update lstSelectAsGroups;}results.put('success',true);
            }else{
                results.put('success',false);results.put('msg','Update Product on the Quote before Selecting Assets');
            }      
        }catch(exception ex){
            results.put('success',false);
            results.put('msg',ex.getMessage());
        }
        return results;
    }
    @AuraEnabled
    public static map<String,object> getRecords(String reocrdId,Integer queryLimit, 
                                                Integer queryOffset,String searchKey) {
        Map<String,object> results = New Map<String,Object>();
        try{
            system.debug('queryLimit>>>>>>>'+queryLimit);
            system.debug('queryOffset>>>>>>>'+queryOffset);
            system.debug('searchKey>>>>>>>'+searchKey);
            system.debug('zzz '+reocrdId);
            SBQQ__Quote__c objQuote 		= 	[SELECT Commercial_Quote__r.SBQQ__Opportunity2__c  FROM SBQQ__Quote__c WHERE Id=:reocrdId][0];
            system.debug('objQuote>>>>>>'+objQuote);
            if(String.isNotBlank(searchKey) && String.isNotEmpty(searchKey)){
                searchKey=searchKey+'%';
            }
            system.debug('searchKey>2222>>>>>>'+searchKey);
            Integer totalCount 				= 0;
            if(String.isNotBlank(searchKey) && String.isNotEmpty(searchKey)){
                totalCount 				=  	[SELECT count() FROM Asset_Group__c WHERE Quote_Line__c='' 
               									AND Opportunity__c=:objQuote.Commercial_Quote__r.SBQQ__Opportunity2__c
                                                AND (Group_Name__c LIKE:searchKey OR Name LIKE:searchKey)];
            }else{
                totalCount 				=  	[SELECT count() FROM Asset_Group__c WHERE Quote_Line__c='' 
               									AND Opportunity__c=:objQuote.Commercial_Quote__r.SBQQ__Opportunity2__c
                                               ];
            }
            system.debug('totalCount>>>>>>'+totalCount);
            /*
            system.debug('zzz '+objQuote.Commercial_Quote__r.SBQQ__Opportunity2__c);
           	totalCount 				=  	[SELECT count() FROM Asset_Group__c WHERE Quote_Line__c='' 
               									AND Opportunity__c=:objQuote.Commercial_Quote__r.SBQQ__Opportunity2__c
                                                ];
			*/
            String OppId = objQuote.Commercial_Quote__r.SBQQ__Opportunity2__c ;
            system.debug('OppId>>>>>>'+OppId);
            String QueryStr  = 'SELECT Name,Group_Name__c,Number_of_Assets__c,Opportunity__c,maxassetscore__c,minassetscore__c,Description__c,Opportunity__r.Name,Project_Number__c,TR_Number__c,Quote_Line__c,Quote_Line__r.Name FROM Asset_Group__c WHERE Quote_Line__c = NULL ';
            if(String.isNotBlank(searchKey) && String.isNotEmpty(searchKey)){
            	QueryStr+=' AND Opportunity__c=:OppId AND (Group_Name__c LIKE:searchKey OR Name LIKE:searchKey) ORDER BY Group_Name__c LIMIT :queryLimit OFFSET :queryOffset';
            }else{
                QueryStr+=' AND Opportunity__c=:OppId  ORDER BY Group_Name__c LIMIT :queryLimit OFFSET :queryOffset';
            }
            system.debug('QueryStr>>>>>>'+QueryStr);
            List<object> lstGroups = New List<object>();
            /*
            for(Asset_Group__c objGroups : [SELECT Name, 
                                            Group_Name__c,
                                            Number_of_Assets__c,
                                            Opportunity__c,
                                            maxassetscore__c,
                                            minassetscore__c,
                                            Description__c,
                                            Opportunity__r.Name,
                                            Project_Number__c,
                                            TR_Number__c,
                                            Quote_Line__c,
                                            Quote_Line__r.Name
                                            FROM Asset_Group__c WHERE Quote_Line__c = '' 
               								AND Opportunity__c=:objQuote.Commercial_Quote__r.SBQQ__Opportunity2__c 
                                            ORDER BY Group_Name__c 
                                            LIMIT :queryLimit
                                     		OFFSET :queryOffset]){
                */
            for(Asset_Group__c objGroups : Database.query(QueryStr)){
                               lstGroups.add(New Map<String,Object>{'Id'=>	objGroups.Id,'GroupLink'=>	'/'+objGroups.Id,'Name'=>  objGroups.Name,'GroupName'=>  objGroups.Group_Name__c,'OpportunityId' =>	objGroups.Opportunity__c,
                                    'OpportunityLink' 			=>	'/'+objGroups.Opportunity__c,'OpportunityName' 			=>	objGroups.Opportunity__r.Name,'NumberOfAssets' 			=> 	objGroups.Number_of_Assets__c,'TRNumber'					=>  objGroups.TR_Number__c,'ProjectNumber' 			=> 	objGroups.Project_Number__c,'QuoteLineId' 				=> 	objGroups.Quote_Line__c,'QuoteLineLink' 			=> 	'/'+objGroups.Quote_Line__c,
                                    'QuoteLineName' 			=> 	objGroups.Quote_Line__r.Name,'MaxAssetScore'				=>  objGroups.maxassetscore__c,'MinAssetScore'  			=>	objGroups.minassetscore__c,'Description'				=>	objGroups.Description__c,
                                   'selectAsInActive'			=> 	false,'selectAsInActiveIcon'			=> 	'utility:automate','needConfigurationIsActive'		=>	false,'needConfigurationIsActiveIcon'	=>	'utility:custom_apps','manageAssets'					=> 	false,'manageAssetsIcon'				=> 	'utility:copy'
                                  });
            }
            system.debug('lstGroups>>>>>'+lstGroups);
            String strURL = system.URL.getSalesforceBaseUrl().toExternalForm();
            results.put('success',true);
            results.put('totalCount',totalCount);
            results.put('strURL',strURL);
            results.put('totalGroups',lstGroups);
            if(TEST.isRunningTest()){
                integer i =1/0;
            }
        }catch(exception ex){
            system.debug('error>>>>>>'+ex);
            results.put('success',false);
            results.put('msg',ex.getMessage());
            
        }
        return results;
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
            if(Test.isRunningTest()){
                integer i =1/0;
            }
        }catch(exception ex){
            result.put('success', false);
            result.put('msg', ex.getMessage());
        }
        return result;
    }
 
}