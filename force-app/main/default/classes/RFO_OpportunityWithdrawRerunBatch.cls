global class RFO_OpportunityWithdrawRerunBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select Id, Name, LastModifieddate, stageName from Opportunity where stageName in (\'Closed-Withdrawn\',\'Closed-Lost\')  and RFO_PartialOpportunitystillActive__c =\'No\' and LastModifieddate = THIS_MONTH');
    }
    global void execute(Database.BatchableContext bc,  List<Opportunity> oplist){
        List<SBQQ__Quote__c> qtlist = [Select Id,Name,SBQQ__Opportunity2__c,RFO_QuoteStage__c,SBQQ__Opportunity2__r.StageName,SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c,SBQQ__Opportunity2__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :oplist AND RFO_QuoteStage__c!='Withdrawn'];
        system.debug('quotelist.size()='+qtlist.size());
        for(SBQQ__Quote__c quote : qtlist){
            system.debug('Quote Id:: '+ quote.Id  +'   OPP STAGE::'+ quote.SBQQ__Opportunity2__r.StageName  +' >>> Qte STage ::' +quote.RFO_QuoteStage__c);
        }
        List<SBQQ__Quote__c> terminatedlist = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> withdrwanlist = new List<SBQQ__Quote__c>();
        Map<id,String> quoteStatusMap = new Map<id,String>();
        ID optyRenewalRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY ).getRecordTypeId();
        ID optyTankRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Tank').getRecordTypeId();
        ID optyFreightRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Freight').getRecordTypeId(); 
        ID optyMangmntServRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId(); 
        if(qtlist.size()>0){
            System.debug('INside here');
            for(SBQQ__Quote__c qte :qtlist){
                if((qte.SBQQ__Opportunity2__r.StageName=='Closed-Withdrawn' || qte.SBQQ__Opportunity2__r.StageName=='Closed-Lost')){
                    system.debug('RFO_PartialOpportunitystillActive__c '+qte.SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c);
                    if(qte.SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c== 'No' && (qte.SBQQ__Opportunity2__r.RecordTypeId== optyTankRecordType || qte.SBQQ__Opportunity2__r.RecordTypeId==optyFreightRecordType)){
                        
                        qte.RFO_QuoteStage__c='Withdrawn';
                        withdrwanlist.add(qte);
                        
                    }
                    else if(qte.SBQQ__Opportunity2__r.RecordTypeId== optyMangmntServRtId ){
                        qte.RFO_QuoteStage__c='Withdrawn';
                        withdrwanlist.add(qte);
                    }
                }
                else if(qte.SBQQ__Opportunity2__r.RecordTypeId== optyRenewalRtId && qte.SBQQ__Opportunity2__r.StageName=='Closed-Termination'){
                    qte.RFO_QuoteStage__c='Withdrawn';
                    terminatedlist.add(qte);
                }
            }
            
        }
        system.debug('withdrwanlist.size()::'+withdrwanlist.size());
        if(withdrwanlist.size()>0){
            database.update(withdrwanlist);
            system.debug('withdrwan updated');
        }
        system.debug('terminatedlist.size()::'+terminatedlist.size());
        if(terminatedlist.size()>0){
            database.update(terminatedlist) ;
            system.debug('terminated updated');
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }
    
    
}