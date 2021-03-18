public without sharing class CPQ_QuoteLineService {
    Public Static boolean runOnlyOnceisBeforeUpdate = true;
    Public Static boolean runOnlyOnceisAfterUpdate = true;
    Public Static void updateBeforeGroups(List<SBQQ__QuoteLine__c> linesToUpdate){
        for(SBQQ__QuoteLine__c objQLI : linesToUpdate){
            if(trigger.isInsert && objQLI.SBQQ__ProductOption__c == null ){
                objQLI .ParentLine__c = true;
                objQLI .SBQQ__Bundle__c = true;
                
            }
            if(String.isNotBlank(objQLI.Custom_Group_Id__c) && String.isNotEmpty(objQLI.Custom_Group_Id__c) 
               && objQLI.Custom_Group_Id__c!='Delete'
              ){
                if(objQLI.SBQQ__Group__c != objQLI.Custom_Group_Id__c){
                     objQLI.SBQQ__Group__c = objQLI.Custom_Group_Id__c;
                }
            }
        }
    }
	Public void createAssetGroup(List<SBQQ__QuoteLine__c> linesToProcess){
        set<id> qliIds = new set<id>();
        map<id,SBQQ__QuoteLine__c> qliMap;// = new map<id,SBQQ__QuoteLine__c>();
        list<Asset_Group__c> assetGroups = new list<Asset_Group__c>();
        for(SBQQ__QuoteLine__c objQLI : linesToProcess){
			assetGroups.add(new Asset_Group__c(Quote_Line__c = objQLI.id ) );
            qliIds.add(objQLI.id);
        }
        if(assetGroups.size() > 0){
            Database.insert(assetGroups);
            qliMap = new Map<id,SBQQ__QuoteLine__c>([select id,Asset_Group__c from SBQQ__QuoteLine__c where Id in :qliIds]);//requery qli to update
            for(Asset_Group__c a :assetGroups)
            {
              qliMap.get(a.Quote_Line__c).Asset_Group__c=a.id;
            }
            update qliMap.values();
            
        }
    }
   
    Public void updateQuantity(List<SBQQ__QuoteLine__c> linesToUpdate){
        set<id> lineIdSet = new set<id>();
        for(SBQQ__QuoteLine__c lines :linesToUpdate){
            if(lines.id != null)
            	lineIdSet.add(lines.id);
        }
        if(lineIdSet.size() >0){
        	Map<id,Double> assetGroups  = new Map<id,Double>();
            for(Asset_Group__c astGrp : [Select Quote_Line__c,Number_of_Assets__c from Asset_Group__c where Quote_Line__c in :lineIdSet]){
            	assetGroups.put(astGrp.Quote_Line__c,astGrp.Number_of_Assets__c);   
            }
         
    	for(SBQQ__QuoteLine__c objQLI : linesToUpdate){
            if(assetGroups.containsKey(objQLI.id)){
        		objQLI.SBQQ__Quantity__c = assetGroups.get(objQLI.id);
            }
    	}
       }
    }
    public void createAssetGroupFromRider(Map<Id, SBQQ__QuoteLine__c> renewalQL)
    {
   		system.debug('renewalQL>>>>>>>>'+renewalQL);
        Map<id, id> riderIdtoOppId= new Map<id,id>();
        Map<id, SBQQ__QuoteLine__c> oppToQLI = new Map<id, SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c priceLine : [select id, SBQQ__Quote__r.SBQQ__Opportunity2__c,
                                                                                 SBQQ__Quote__r.SBQQ__Opportunity2__r.rfo_riderid__c  
                                                                                 from SBQQ__QuoteLine__c 
                                                                                 where id =: renewalQL.keyset()])
        {
            riderIdtoOppId.put(priceline.SBQQ__Quote__r.SBQQ__Opportunity2__r.rfo_riderid__c, priceline.SBQQ__Quote__r.SBQQ__Opportunity2__c);
            oppToQLI.put(priceline.SBQQ__Quote__r.SBQQ__Opportunity2__c, priceLine);
        }

     
        //load rider group assets        
        Map<id, list<rfo_ridergroupasset__c>> riderToRiderAssetListMap = new Map<id, list<rfo_ridergroupasset__c>>();
        for(rfo_ridergroupasset__c riderAsset : [select id, name, rfo_asset__c, rfo_riderGroup__c, 
                                                 rfo_riderGroup__r.rfo_rider__r.name 
                                                 from rfo_ridergroupasset__c
                                                 where rfo_riderGroup__r.rfo_rider__c =:riderIdtoOppId.keyset() 
                                                 AND rfo_asset__c<>null and RFO_Active__c=true])
        {
            system.debug('processing rider asset: ' + riderAsset);
            if(riderToRiderAssetListMap.containsKey(riderAsset.rfo_riderGroup__r.rfo_rider__c)){
                system.debug('found existing rider asset list');
                list<rfo_ridergroupasset__c> ral = riderToRiderAssetListMap.get(riderAsset.rfo_riderGroup__r.rfo_rider__c);
                ral.add(riderAsset);
            }else{
                system.debug('creating new rider asset list');
                list<rfo_ridergroupasset__c> ral = new list<rfo_ridergroupasset__c>();
                ral.add(riderAsset);
                riderToRiderAssetListMap.put(riderAsset.rfo_riderGroup__r.rfo_rider__c, ral);
            }
        }
        //create asset group for each quote line with asset lines matching rider group assets on opportunity
        List<Asset_Group__c> ag_Valid = new List<Asset_Group__c>();
        List<Asset_Group__c> ag_Exception = new List<Asset_Group__c>();
        Map<id, list<asset_lines__c>> agl =  new Map<id, list<asset_lines__c>>();
        system.debug('processing '+ riderToRiderAssetListMap.size()+ ' riders');
        for(Id riderId : riderToRiderAssetListMap.keyset()){
            Asset_Group__c a 		= new Asset_Group__c();
            Id oppId = riderIdtoOppId.get(riderId);
            SBQQ__QuoteLine__c qli 	= oppToQLI.get(oppId);
            try{
                 list<rfo_ridergroupasset__c> rgas = riderToRiderAssetListMap.get(riderId);
                 if(rgas.size()>0){
                     system.debug('processing '+ rgas.size()+ ' rider assets');
                     a.Group_Name__c = rgas[0].rfo_riderGroup__r.rfo_rider__r.name;//same rider name for all riders on one opp
                     a.Opportunity__c =oppId;
                     a.Quote_Line__c = qli.Id;
                     a.Description__c = 'Auto generated for renewal from Rider ' +  a.Group_Name__c;
                     ag_Valid.add(a);
                     //create asset group lines
                    for(rfo_ridergroupasset__c rga: rgas){
                        Asset_Lines__c al = new Asset_Lines__c(asset__c = rga.rfo_Asset__c, name = rga.name );
                        if(agl.containsKey(qli.Id)){
                            list<Asset_Lines__c> als = agl.get(qli.Id);
                            als.add(al);
                        }else{
                            list<Asset_Lines__c> als = new List<Asset_Lines__c>();
                            als.add(al);
                            agl.put(qli.Id, als);
                        }
                        system.debug('processed '+ agl.size()+ ' asset group lines');
                    }
                    
                 }
                 else throw new NoDataFoundException();//if we dont have any rider assets go to exception 
            }
            catch (Exception e)
            {
                  //if we have issues creating an asset group, create a blank one with no data
                system.debug(e.getMessage());
                system.debug('error creating asset lines for '+qli.Id);
                a.Group_Name__c ='Auto generated for renwal from Rider';
                a.Description__c='We could not automatically move Rider Group assets to this Asset Group. Either the data is missing or an error has occured. Please add assets manually or contact a System admin for help.';
                a.Opportunity__c =oppId;
                a.Quote_Line__c = qli.Id;
                ag_Exception.add(a);

            }
            
            if(ag_Exception.size()>0){
                system.debug('inserting errored ags ' + ag_Exception.size());
                insert ag_Exception;
            }
            if(ag_Valid.size()>0){
                list<asset_lines__c> linesToInsert = new List<asset_lines__c>();
                system.debug('inserting valid ags ' + ag_Valid.size());
                insert ag_Valid;
                for(Asset_Group__c ag : ag_Valid){
                    list<Asset_Lines__c> als = agl.get(ag.quote_line__c);
                    for(asset_lines__c a1 : als){
                        a1.asset_group__c = ag.id;
                        linesToInsert.add(a1);
                    }
                }
                system.debug('linesToInsert>>>>>>>>>'+linesToInsert);
                insert linesToInsert;
            }
           
        }
    }

}