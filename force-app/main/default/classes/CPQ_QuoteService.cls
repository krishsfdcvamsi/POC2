global class CPQ_QuoteService {
    public string cpqRecordTypeName {
      get {
         return 'CPQ';//TODO: put in setting
      }
      private set {
         
      }
   } 
   
    Public void createCPQQuoteRecords(Map<Id, SBQQ__Quote__c> parentCommercialQuotesMap)
    {

        SBQQ.TriggerControl.disable();

        system.debug('entering createCPQQuoteRecords records');
        system.debug('parentCommercialQuotesMap: '+parentCommercialQuotesMap.size());
       
        Set<string> validRecordTypesForCPQ= new Set<string>{'Existing'};//TODO: put in setting
        string commercialQuoteStatus = 'In Progress';
        List<SBQQ__Quote__c> CPQQuotes = new List<SBQQ__Quote__c>();
        Id cpqRecordTypeId = CPQ_QuoteService.getQuoteRecordTypeIdByRecordTypeName(cpqRecordTypeName);
        
        for(SBQQ__Quote__c commercialQuote :  parentCommercialQuotesMap.values())
        {
            system.debug('mapping '+ commercialQuote.id);
            string commQtRecordType =CPQ_QuoteService.getRecrodTypeNameById(commercialQuote.RecordTypeId);
            if(validRecordTypesForCPQ.contains(commQtRecordType)
               && string.isEmpty(commercialQuote.Commercial_Quote__c) 
               && commercialQuoteStatus.equalsIgnoreCase(commercialQuote.RFO_QuoteStage__c)
               && commercialQuote.CPQ_Quote__c == null)
            {
                SBQQ__Quote__c CPQ_QUOTE = new SBQQ__Quote__c(RecordTypeId=cpqRecordTypeId,
                                                              Commercial_Quote__c= commercialQuote.id,
                                                              RFO_QuoteTeam__c=commercialQuote.RFO_QuoteTeam__c,
                                                              SBQQ__Account__c= commercialQuote.SBQQ__Account__c,
                                                              RFO_Product__c = commercialQuote.RFO_Product__c,







                                                              SBQQ__LineItemsGrouped__c = true);
                                                          //    SBQQ__Opportunity2__c= commercialQuote.SBQQ__Opportunity2__c);







                CPQQuotes.add(CPQ_QUOTE);
            }
            
        } 
        if(CPQQuotes.size()>0)
        {
             system.debug('iserting '+cpqquotes.size()+ ' new quotes');
            insert CPQQuotes;
        system.debug('inserted new quotes');
            createQuoteGroup(CPQQuotes);




            submitForApproval(CPQQuotes);




            Map<Id, SBQQ__Quote__c> updateParents = new Map<Id, SBQQ__Quote__c>([select id, CPQ_Quote__c 
                                                                                 from SBQQ__Quote__c 
                                                                                 where Id in :parentCommercialQuotesMap.keyset()]);
        system.debug('parents found: '+updateParents.size());
            for(SBQQ__Quote__c q : CPQQuotes)
            {
                if(updateParents.containskey(q.Commercial_Quote__c))
                {
                    system.debug('found parent quote');
                   system.debug('mapping '+ q.id +' to: '+updateParents.get(q.Commercial_Quote__c).id);
                   updateParents.get(q.Commercial_Quote__c).CPQ_Quote__c = q.id; 
                }
                
            }
            update updateParents.values(); //run from before trigger, no need to update parent
        }
        else
        {
            system.debug('did not create any cpq quotes. This is triggered by a new CPQ quote being created.');
        }


        SBQQ.TriggerControl.enable();

    }
    
    public static Id getQuoteRecordTypeIdByRecordTypeName(string recordTyepName)
    {
        return Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(recordTyepName).getRecordTypeId();
    }
    
    public static string getRecrodTypeNameById(Id recordTypeId)
    {
        return Schema.getGlobalDescribe().get('SBQQ__Quote__c').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    }    
    
    public void createQuoteGroup(list<SBQQ__Quote__c> cpqQuotesList){
        list<SBQQ__QuoteLineGroup__c> qouteLineGroup = new list<SBQQ__QuoteLineGroup__c>();
        string cpqRecordTypeName ='CPQ';
        system.debug('cpqQuotesList' + cpqQuotesList);
        for(SBQQ__Quote__c cpqQuote : cpqQuotesList){
            string cpqQtRecordType =CPQ_QuoteService.getRecrodTypeNameById(cpqQuote.RecordTypeId);
           	if(cpqQtRecordType.equalsIgnoreCase(cpqRecordTypeName)){
                qouteLineGroup.add( new SBQQ__QuoteLineGroup__c(Name = 'As Configured',SBQQ__Account__c = cpqQuote.SBQQ__Account__c,
                                                                SBQQ__Quote__c = cpqQuote.id,SBQQ__Number__c = 2) );
            	system.debug('cpqQuote.id' + cpqQuote.id);
                qouteLineGroup.add( new SBQQ__QuoteLineGroup__c(Name = 'Need Configuration',SBQQ__Account__c = cpqQuote.SBQQ__Account__c,
                                                                SBQQ__Quote__c = cpqQuote.id,SBQQ__Number__c = 1) );
            }
       }
        system.debug('qouteLineGroup'+qouteLineGroup);
        if(qouteLineGroup.size()>0){
        	insert qouteLineGroup;   
        }
    }







    public static void submitForApproval(list<SBQQ__Quote__c> cpqQuotesList){        
        for(SBQQ__Quote__c cpqQuote : cpqQuotesList){    
        	Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            system.debug('cpqQuote.id---'+cpqQuote.id);
        	req.setObjectId(cpqQuote.id);
            req.setskipentrycriteria(false);
            req.setSubmitterId('0056f00000AR8KsAAL'); //(userinfo.getUserId());   //
            req.setProcessDefinitionNameOrId('CPQ_SLAProcess');
            system.debug('Before submitting the AP');
            try{
       		 Approval.ProcessResult result = Approval.process(req);
			} catch(DmlException e) {
    		System.debug('The following exception has occurred: ' + e.getMessage());
			}    
            system.debug('After submitting the AP');
        }
    }     







}