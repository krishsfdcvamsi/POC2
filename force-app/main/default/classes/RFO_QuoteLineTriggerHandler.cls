public class RFO_QuoteLineTriggerHandler implements ITriggerHandler{
    public static Boolean triggerDisabled = false;
    RFO_TriggerSetting__mdt quoteLineTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='RFO_QuoteLineTrigger' LIMIT 1];
    public Boolean isDisabled()
    {
        if (quoteLineTrigger.RFO_Active__c){
            return triggerDisabled;
        }else{
            return true;
        }
        
    }
    public void beforeInsert(List<SObject> newItems) {
        Id CPQQuote_RecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
        Id Existing_RecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_Existing').getRecordTypeId();
        Id CPQ_Config_RecTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('CPQ_Config').getRecordTypeId(); 
        set<id> quoteIds = new set<id>();
        for(SBQQ__QuoteLine__c ln : (List<SBQQ__QuoteLine__c>)newItems){
            quoteIds.add(ln.SBQQ__Quote__c);	
        }
        // CPQ_QuoteLineService svc = new CPQ_QuoteLineService();
        //svc.updateQuantity((List<SBQQ__QuoteLine__c>)newItems);
        //CPQ_QuoteLineService.updateBeforeGroups((List<SBQQ__QuoteLine__c>)newItems);
        map<id,SBQQ__Quote__c> quoteMap = new map<id,SBQQ__Quote__c>([select id,RecordTypeId,Commercial_Quote__r.Estimated_Lease_Duration__c from SBQQ__Quote__c where id in :quoteIds]);
        list<SBQQ__QuoteLine__c> cpqNewLines = new List<SBQQ__QuoteLine__c>();
        list<SBQQ__QuoteLine__c> existingNewLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c line : (List<SBQQ__QuoteLine__c>)newItems){
            line.Estimated_Lease_Duration__c = quoteMap.get(line.SBQQ__Quote__c).Commercial_Quote__r.Estimated_Lease_Duration__c;
            if(quoteMap.get(line.SBQQ__Quote__c).RecordTypeId == CPQQuote_RecTypeId){
                line.RecordTypeId = CPQ_Config_RecTypeId;
                cpqNewLines.add(line);
            }else{
                if(quoteMap.get(line.SBQQ__Quote__c).RecordTypeId == Existing_RecTypeId){
                    existingNewLines.add(line);   
                }
            }    
        }
        if(cpqNewLines.size()> 0){ 
            CPQ_QuoteLineService svc = new CPQ_QuoteLineService();
            //  svc.updateQuantity(cpqNewLines);
            CPQ_QuoteLineService.updateBeforeGroups(cpqNewLines);
        }
        // if(existingNewLines.size()> 0){
        //	CPQ_QuoteLineService.calculateReturn(existingNewLines,false);
        //}
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Id CPQQuote_RecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
        Id Existing_RecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_Existing').getRecordTypeId();
        Id Renewal_RecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_Renewal').getRecordTypeId();
        set<id> quoteIds = new set<id>();
        for(SBQQ__QuoteLine__c ln : (List<SBQQ__QuoteLine__c>)newItems.values()){
            quoteIds.add(ln.SBQQ__Quote__c);	
        }
        map<id,SBQQ__Quote__c> quoteMap = new map<id,SBQQ__Quote__c>([select id,RecordTypeId,Commercial_Quote__r.Estimated_Lease_Duration__c from SBQQ__Quote__c where id in :quoteIds]);
        list<SBQQ__QuoteLine__c> cpqNewLines = new List<SBQQ__QuoteLine__c>();
        list<SBQQ__QuoteLine__c> existingNewLines = new List<SBQQ__QuoteLine__c>();
        list<SBQQ__QuoteLine__c> renewalsToUpdate = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c line : (List<SBQQ__QuoteLine__c>)newItems.values() ){
            line.Estimated_Lease_Duration__c = quoteMap.get(line.SBQQ__Quote__c).Commercial_Quote__r.Estimated_Lease_Duration__c;
            if(quoteMap.get(line.SBQQ__Quote__c).RecordTypeId == CPQQuote_RecTypeId)
            {
                cpqNewLines.add(line);
            }
            else if(quoteMap.get(line.SBQQ__Quote__c).RecordTypeId == Existing_RecTypeId)
            {
                existingNewLines.add(line);   
            }
            else if(quoteMap.get(line.SBQQ__Quote__c).RecordTypeId == Renewal_RecTypeId)
            {
                SBQQ__QuoteLine__c oldLine = (SBQQ__QuoteLine__c)oldItems.get(line.Id);
                if(line.RFO_LeaseRate__c != oldLine.RFO_LeaseRate__c || line.RFO_LeaseQty__c !=oldLine.RFO_LeaseQty__c || line.RFO_LeaseTerm__c != oldline.RFO_LeaseTerm__c)
                { //if any of the key determinants of IRR change, recalculate IRR
                    renewalsToUpdate.add(line);
                }
                
            }
            
        }
        
        if(cpqNewLines.size()> 0){
            CPQ_QuoteLineService svc = new CPQ_QuoteLineService();
            //  svc.updateQuantity(cpqNewLines);
            CPQ_QuoteLineService.updateBeforeGroups(cpqNewLines);
        }
         if(renewalsToUpdate.size()> 0){
        	ROICalculator.runCalculateReturn_Bulkified(renewalsToUpdate);
         }
        
    }
    
    public void beforeDelete(Map<Id, SObject> oldItems) {}
    
    public void afterInsert(Map<Id, SObject> newItems) {
        system.debug('newItems>>>>>>>>>>>>>'+newItems);
        
        Set<id> qrecordTypes = new Set<Id>();
        Id CPQQuote_RecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
        Id renewalRecType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_Renewal').getRecordTypeId();
        qrecordTypes.add(CPQQuote_RecTypeId);
        qrecordTypes.add(renewalRecType); 
        system.debug('qrecordTypes>>>>>>>'+qrecordTypes);
        set<id> quoteIds = new set<id>();
        for(SBQQ__QuoteLine__c ln : (List<SBQQ__QuoteLine__c>)newItems.values()){
            system.debug('ln>>>>>>'+ln);
            quoteIds.add(ln.SBQQ__Quote__c);	
        }
        system.debug('quoteIds in after insert'+quoteIds);
        Set<id> cpqQuotes = new set<id>();
        Set<id> renewals = new set<id>();
        for (sbqq__quote__c q : [SELECT id,name, recordtypeid 
                                 FROM SBQQ__Quote__c 
                                 WHERE RecordTypeId IN:qrecordTypes 
                                 AND id in :quoteIds]){
                                     
                                     if(q.recordtypeid==CPQQuote_RecTypeId)
                                     {
                                         cpqQuotes.add(q.id);
                                     }
                                     else if(q.recordtypeid==renewalRecType)
                                     {
                                         renewals.add(q.id);
                                     }
                                 }
        
        system.debug('list of quotes'+cpqQuotes);
        system.debug('list of renewals'+renewals);
        list<SBQQ__QuoteLine__c> cpqLinesToProcess = new List<SBQQ__QuoteLine__c>();
        map<id, SBQQ__QuoteLine__c> renewalLinesToProcess = new  map<id, SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c line : (List<SBQQ__QuoteLine__c>)newItems.values()){
            
            if(renewals.contains(line.SBQQ__Quote__c))
            {
                renewalLinesToProcess.put(line.id, line);
            }
            
            if(cpqQuotes.contains(line.SBQQ__Quote__c) && line.SBQQ__ProductOption__c == null &&  line.Asset_Group__c == null)
            {
                cpqLinesToProcess.add(line);
            }    
        }
        CPQ_QuoteLineService svc = new CPQ_QuoteLineService();
        if(cpqLinesToProcess.size() > 0){
            
            RFO_QuoteLineTriggerHandler.triggerDisabled=true;//disable rerunning this trigger again
            svc.createAssetGroup(cpqLinesToProcess);
        }
        system.debug('renewalLinesToProcess>>>>>>>>'+renewalLinesToProcess);
        if(renewalLinesToProcess.size()>0)
        {
            try
            {
                RFO_QuoteLineTriggerHandler.triggerDisabled=true;//disable rerunning this trigger again
                svc.createAssetGroupFromRider(renewalLinesToProcess);
                ROICalculator.runCalculateReturn_Bulkified(renewalLinesToProcess.values());
            }
            catch (ROICalculator.ROICalculatorException roiex)
            {
                system.debug('ROI Calculation Exception caught: '+roiex.getMessage());
                system.debug(roiex.getStackTraceString());
                //do not fail insert if its specifically IRR
            }
            catch(exception e)
            {
                system.debug('failed to calculate IRR or generate asset groups from rider');
                system.debug(e.getMessage());
                system.debug(e.getStackTraceString());
                throw e;  //fail insert
            }
            
        }
    }
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void afterDelete(Map<Id, SObject> oldItems) {}
    
    public void afterUndelete(Map<Id, SObject> oldItems) {}
}