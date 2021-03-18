/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 20th June 2019
* @Description : Implements the Database.Batchable<sObject> base class to execute batch class.
*                The class is to create Renewal/Management Opportunity from Rider.
**/
global class RFO_CreateRenewalManagementOpty_Batch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Date todayPlus120Days = Date.Today().addDays(120);
        String query = 'SELECT id, RFO_TotalActiveCars__c, RFO_CurrentMaturityDate__c, RFO_AutoRenewal__c, RFO_Commodity__c, RFO_Status__c, RFO_TotalOfCars__c, RFO_RiderType__c, RFO_ProductType__c, RFO_Account__c, RFO_OriginalMaturityDate__c FROM RFO_Rider__c WHERE (RFO_OriginalMaturityDate__c <=:todayPlus120Days AND RFO_OriginalMaturityDate__c >= TODAY) ORDER BY RFO_OriginalMaturityDate__c DESC LIMIT 49999';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<RFO_Rider__c> scope)
    {
        ID optyRenewalRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY).getRecordTypeId(); 
        ID optyMangmntServRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId();
        List<Opportunity> temp;
        Map<Id,List<Opportunity>> oppRenewalMap = new Map<Id,List<Opportunity>>();
        Map<Id,List<Opportunity>> oppMgmtMap = new Map<Id,List<Opportunity>>();
        List <Opportunity> oppList = [select id, RFO_RiderID__c, RecordTypeId from opportunity where RFO_RiderID__c in :scope and (recordtypeId =:optyRenewalRtId or recordtypeId =:optyMangmntServRtId) LIMIT 49999];
        //System.debug('oppList data: '+oppList.size());
        for(Opportunity opp : [select id, RFO_RiderID__c, RecordTypeId from opportunity where RFO_RiderID__c in :scope and (recordtypeId =:optyRenewalRtId or recordtypeId =:optyMangmntServRtId) LIMIT 49999]){
            temp = new List<Opportunity>();
            
            if(opp.RecordTypeId==optyRenewalRtId){
                if(oppRenewalMap.containsKey(opp.RFO_RiderID__c)){
                    temp = oppRenewalMap.get(opp.RFO_RiderID__c);
                }
                else{
                    temp.add(opp);
                }
                oppRenewalMap.put(opp.RFO_RiderID__c,temp);
            }
            else{
                if(oppMgmtMap.containsKey(opp.RFO_RiderID__c)){
                    temp = oppMgmtMap.get(opp.RFO_RiderID__c);
                }
                else{
                    temp.add(opp);
                }
                oppMgmtMap.put(opp.RFO_RiderID__c,temp);
            }
            
        }
        system.debug('############################## Mgmt ='+ oppMgmtMap.size());
        system.debug('############################## Renwl ='+ oppRenewalMap.size());
        Integer mgmtOppCount = 0;
        Integer renwlOppCount = 0;
        for(RFO_Rider__c rider: scope){
            //System.debug('Rider record: '+scope);
            if(rider.RFO_Status__c != RFO_Constant.RIDER_FULLY_TERMINATED  && rider.RFO_Status__c != RFO_Constant.DO_NOT_RENEW  && 
               rider.RFO_Status__c != RFO_Constant.RIDER_CANCELLED  && rider.RFO_AutoRenewal__c != RFO_Constant.YES  && rider.RFO_OriginalMaturityDate__c!=null){
                   if(rider.RFO_RiderType__c!=null && (rider.RFO_RiderType__c.equals( RFO_Constant.MANAGEMENT_AGREEMENT  ) || rider.RFO_RiderType__c.equals( RFO_Constant.MAINTENANCE_AGREEMENT) )){
                       if(!oppMgmtMap.containsKey(rider.Id)){ 
                           RFO_OpportunityHelper.createManagementServicesOpp(rider, RFO_Constant.BATCH);
                           system.debug('CREATED for Mgmt '+rider.Id+' maturity dt:'+rider.RFO_OriginalMaturityDate__c);
                           mgmtOppCount = mgmtOppCount + 1;
                       }
                   }
                   else{
                       if(!oppRenewalMap.containsKey(rider.Id)){
                           RFO_OpportunityHelper.createRenewalOpportunity(rider, RFO_Constant.BATCH);
                           system.debug('CREATED for Renewal '+rider.Id+' maturity dt:'+rider.RFO_OriginalMaturityDate__c);
                           renwlOppCount = renwlOppCount + 1;
                       }
                   }
                   
               }
        }//for loop
        system.debug('@@@@#### Total number of Renewal Oppty created '+renwlOppCount);
        system.debug('@@@@#### Total number of Mgrmt Oppty created '+mgmtOppCount);
        
    } //end of Execute method
    
    global void finish(Database.BatchableContext BC) {
    }
} //end of batch class