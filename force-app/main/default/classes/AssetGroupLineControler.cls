public without sharing class AssetGroupLineControler {
    @auraEnabled
    public static Asset_Lines__c getAssetGroupLineInfo(String recordId){
        
        return [SELECT Asset__c,Asset__r.Name,Asset_Group__c,Asset_Group__r.Name,Asset_Match__c,
               	AttributeID_1__c,	
                AttributeID_10__c,AttributeID_11__c,AttributeID_12__c,AttributeID_13__c,	
                AttributeID_14__c,AttributeID_15__c,AttributeID_16__c,AttributeID_17__c,AttributeID_18__c,	
                AttributeID_19__c,AttributeID_2__c,AttributeID_20__c,AttributeID_21__c,AttributeID_22__c,AttributeID_23__c,	
                AttributeID_24__c,AttributeID_25__c,AttributeID_3__c,AttributeID_4__c,AttributeID_5__c,	
                AttributeID_6__c,AttributeID_7__c,AttributeID_8__c,AttributeID_9__c,
                Attr_Match_1__c,Attr_Match_10__c,
                Attr_Match_11__c,Attr_Match_12__c,Attr_Match_13__c,Attr_Match_14__c,Attr_Match_15__c,
                Attr_Match_16__c,Attr_Match_17__c,
                Attr_Match_18__c,Attr_Match_19__c,Attr_Match_2__c,Attr_Match_20__c,Attr_Match_21__c,Attr_Match_22__c,
                Attr_Match_23__c,Attr_Match_24__c,Attr_Match_25__c,Attr_Match_3__c,Attr_Match_4__c,
                Attr_Match_5__c,Attr_Match_6__c,Attr_Match_7__c,Attr_Match_8__c,Attr_Match_9__c,
                //ExternalAssetId__c,
                Qn_1__c,Qn_10__c,Qn_11__c,
                Qn_12__c,Qn_13__c,Qn_14__c,Qn_15__c,Qn_16__c,Qn_17__c,Qn_18__c,Qn_19__c,Qn_2__c,
                Qn_20__c,Qn_21__c,Qn_22__c,Qn_23__c,Qn_24__c,Qn_25__c,Qn_3__c,Qn_4__c,Qn_5__c,Qn_6__c,
                Qn_7__c, Qn_8__c,Qn_9__c,Qn_Desc_1__c,Qn_Desc_10__c,Qn_Desc_11__c,Qn_Desc_12__c,Qn_Desc_13__c,
                Qn_Desc_14__c,Qn_Desc_15__c,Qn_Desc_16__c,Qn_Desc_17__c,Qn_Desc_18__c,Qn_Desc_19__c,
                Qn_Desc_2__c,Qn_Desc_20__c,Qn_Desc_21__c,Qn_Desc_22__c,Qn_Desc_23__c,Qn_Desc_24__c,
                Qn_Desc_25__c,Qn_Desc_3__c,Qn_Desc_4__c,Qn_Desc_5__c,Qn_Desc_6__c,Qn_Desc_7__c,
                Qn_Desc_8__c,Qn_Desc_9__c,Qn_Match_1__c,Qn_Match_10__c,Qn_Match_11__c,Qn_Match_12__c,
                Qn_Match_13__c,Qn_Match_14__c,Qn_Match_15__c,Qn_Match_16__c,Qn_Match_17__c,Qn_Match_18__c,
                Qn_Match_19__c,Qn_Match_2__c,Qn_Match_20__c,Qn_Match_21__c,Qn_Match_22__c,
                Qn_Match_23__c,Qn_Match_24__c,Qn_Match_25__c,Qn_Match_3__c,Qn_Match_4__c,
                Qn_Match_5__c,Qn_Match_6__c,Qn_Match_7__c,Qn_Match_8__c,Qn_Match_9__c FROM Asset_Lines__c WHERE Id=:recordId];
        
    }
}