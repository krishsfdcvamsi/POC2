/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 9th Dec 2019
* @Description : 
*                
**/

public class RFO_QuoteTriggerHandler implements ITriggerHandler{
 // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean triggerDisabled = false;
    RFO_TriggerSetting__mdt quoteTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='QuoteTrigger' LIMIT 1];
    /*****
Checks to see if the trigger has been disabled either by custom setting or by running code
*****/
    public Boolean isDisabled()
    {
        if (quoteTrigger.RFO_Active__c){
            return triggerDisabled;
        }else{
            return true;
        }
    }
    
     
    /*****
* Method Name: BeforeInsert
*****/
    public void beforeInsert(List<SObject> newItems) {
        for(SBQQ__Quote__c qq:(List<SBQQ__Quote__c>)newItems){
            if(qq.isClone()){
            	qq.RFO_Cloned_From_Origin_Quote_Id__c = qq.getCloneSourceId();
                
            }          
        }
    }
    
  /**
* Method Name: beforeUpdate
**/
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try{
           RFO_QuoteHelperClass.quoteOppStageRequiredFields((List<SBQQ__Quote__c>)newItems.values(), oldItems);
        }
        catch(Exception e) {   
                    RFO_Utility.createErrorLogRecordFuture(e.getMessage(),'Quote',
                                                           RFO_Constant.TRIGER,'RFO_QuoteTriggerHandler','beforeUpdate');
        }
    }
    
     /**
* Method Name: beforeDelete
**/
    public void beforeDelete(Map<Id, SObject> oldItems) {}
    
    /**
* Method Name: afterInsert
**/
    public void afterInsert(Map<Id, SObject> newItems) {
        
        try{
            List<SBQQ__Quote__c> quoteUpdateTeamMember = new List<SBQQ__Quote__c>();
            map<string,set<id>> optyIdsWrtQuoteRecordTypes = new map<string,set<id>>();
           
        for(SBQQ__Quote__c qq:(List<SBQQ__Quote__c>)newItems.values()){
            // Added for Quote Team
            if(qq.RFO_QuoteTeam__c  != null){
                quoteUpdateTeamMember.add(qq);
            }
            if(qq.SBQQ__Primary__c) {
                string recordTypeName = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosById().get(qq.recordtypeid).getname();
                if(optyIdsWrtQuoteRecordTypes.containsKey(recordTypeName)) {
                    optyIdsWrtQuoteRecordTypes.get(recordTypeName).add(qq.SBQQ__Opportunity2__c);
                }
                else {
                    optyIdsWrtQuoteRecordTypes.put(recordTypeName, new set<id>{qq.SBQQ__Opportunity2__c});
                }
            }
             
        }
        if(!quoteUpdateTeamMember.isEmpty()){       
            RFO_QuoteHelperClass.updateQuoteTeamMembers(quoteUpdateTeamMember,null);
        } 
        if(optyIdsWrtQuoteRecordTypes.size() > 0) {
            RFO_QuoteHelperClass.updateOpportunityType(optyIdsWrtQuoteRecordTypes);
        }
        

            RFO_QuoteHelperClass.updateContactName((List<SBQQ__Quote__c>)newItems.values());    
            RFO_QuoteHelperClass.updatePrimaryQuote((List<SBQQ__Quote__c>)newItems.values());
            
            RFO_QuoteHelperClass.quoteStageUpdateToBA((List<SBQQ__Quote__c>)newItems.values());
        }
        catch(Exception e) {   
                    System.debug('exception: '+e);
                    RFO_Utility.createErrorLogRecordFuture(e.getMessage(),'Quote',
                                                           RFO_Constant.TRIGER,'RFO_QuoteTriggerHandler','afterInsert');
        }
    }
    
    /**
* Method Name: afterUpdate
**/
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try{
        
        List<SBQQ__Quote__c> quoteUpdateTeamMember = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteUpdateQTeamMember = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteUpdateStageTeamMember = new List<SBQQ__Quote__c>();
        Map<id,SBQQ__Quote__c> quoteBusinessAwardedStage  = new Map<id,SBQQ__Quote__c>();
        Map<id,SBQQ__Quote__c> quoteNewQuoteTeam = (Map<id,SBQQ__Quote__c>)newItems;
        Map<id,SBQQ__Quote__c> quoteOldQuoteTeam = (Map<id,SBQQ__Quote__c>)oldItems;
        List<Quote_Team_Member__c> newQuoteTeamMemerList;
        Map<id,Quote_Team_Member__c> oldQuoteTeamMemerMap; 
        set<id> optyIds = new set<id>();
        


                
            Set<Id> oldQuoteTeamIds = new Set<Id>();
            Set<Id> newQuoteTeamIds = new Set<Id>();



            system.debug('@---after update');



            for(SBQQ__Quote__c qq: quoteNewQuoteTeam.values()){
                newQuoteTeamIds.add(qq.RFO_QuoteTeam__c);
                if(qq.RFO_QuoteTeam__c != quoteOldQuoteTeam.get(qq.id).RFO_QuoteTeam__c){ 
                  quoteUpdateTeamMember.add(qq);
                } 
                if(qq.RFO_QuoteStage__c != quoteOldQuoteTeam.get(qq.id).RFO_QuoteStage__c){
                    quoteUpdateStageTeamMember.add(qq);
                }



                if(qq.RFO_QuoteStage__c != quoteOldQuoteTeam.get(qq.id).RFO_QuoteStage__c && qq.RFO_QuoteStage__c == RFO_Constant.BUSINESS_AWARDED){
                    quoteBusinessAwardedStage.put(qq.Id, qq);
                }
            }
            
            if(!quoteBusinessAwardedStage.isEmpty()){
                RFO_QuoteHelperClass.sendSignedProposalNotification(quoteBusinessAwardedStage);



            }
            
            if(!quoteOldQuoteTeam.isEmpty()){
                for(SBQQ__Quote__c qq: quoteOldQuoteTeam.values()){
                    oldQuoteTeamIds.add(qq.RFO_QuoteTeam__c);
                }
            }
            
            if(newQuoteTeamIds.size()>0){
                  newQuoteTeamMemerList = [select id,Role__c,User__c,Quote__c,Quote__r.RFO_QuoteTeam__c from Quote_Team_Member__c where Quote__r.RFO_QuoteTeam__c IN:newQuoteTeamIds Limit 49999];
            }
            if(oldQuoteTeamIds.size()>0){
                oldQuoteTeamMemerMap = new Map<id,Quote_Team_Member__c>([select id,Role__c,User__c,Quote__c,Quote__r.RFO_QuoteTeam__c from Quote_Team_Member__c where Quote__r.RFO_QuoteTeam__c IN:oldQuoteTeamIds Limit 49999]);
            }
            system.debug('@@@@ newQuoteTeamMemerList'+newQuoteTeamMemerList);
            system.debug('%%%% oldQuoteTeamMemerMap'+oldQuoteTeamMemerMap);
            if(quoteUpdateTeamMember.isEmpty() && !newQuoteTeamMemerList.isEmpty()){
            for(Quote_Team_Member__c qTM: newQuoteTeamMemerList){
                if(qtm.User__c != oldQuoteTeamMemerMap.get(qTM.id).User__c || qtm.Role__c != oldQuoteTeamMemerMap.get(qTM.id).Role__c){
                    system.debug('&&&&&qtm.User__c '+qtm.User__c+ '&&&&&qtm.Role__c'+ qtm.Role__c );
                    quoteUpdateQTeamMember.add(qTM.Quote__r);
                }
            }
            }
            system.debug('$$$ quoteUpdateTeamMember'+quoteUpdateTeamMember);
         
          if(!quoteUpdateTeamMember.isEmpty()){    
           RFO_QuoteHelperClass.updateQuoteTeamMembers(quoteUpdateTeamMember,null);
         }
         /* else if(!quoteUpdateQTeamMember.isEmpty()){    
           RFO_QuoteHelperClass.updateQuoteTeamMembers(quoteUpdateTeamMember,quoteOldQuoteTeam);
         } */
            
             if(!quoteUpdateStageTeamMember.isEmpty()){
            RFO_QuoteHelperClass.quoteStageUpdateToBA(quoteUpdateStageTeamMember);  
            }
            RFO_QuoteHelperClass.updateQuoteStatus((List<SBQQ__Quote__c>)newItems.values());



                      

            //Capturing timestamp on Rider Object when Quote Stage changed to 'HPR Fully Executed'
            //Developer : Sumana Kumbum    
            system.debug('Updating Rider.quotestagetime in Quote =TriggerHandler..');
            Map<id,SBQQ__Quote__c> newQuoteItems = (Map<id,SBQQ__Quote__c>)newItems;
            Map<id,SBQQ__Quote__c> oldQuoteItems = (Map<id,SBQQ__Quote__c>)oldItems;
            system.debug('---->' + newQuoteItems.size());
            system.debug('*****>' + oldQuoteItems.size());
           
            for(SBQQ__Quote__c newQuoteItem: newQuoteItems.values()){
                if(newQuoteItem.RFO_QuoteStage__c != oldQuoteItems.get(newQuoteItem.id).RFO_QuoteStage__c && ((newQuoteItem.RFO_QuoteStage__c == 'HPR Fully Executed')||(newQuoteItem.RFO_QuoteStage__c == 'Signed HPR Received')||(newQuoteItem.RFO_QuoteStage__c == 'PM Reviewed'))){ 
                    system.debug('Updating Rider Quote Stage time for quite id..' + newQuoteItem.id);
                    List<RFO_Rider__c> riders = [SELECT Id,Quote_Id__c,Quote_Stage_Time__c,Quote_Stage__c FROM RFO_Rider__c WHERE Quote_Id__c = :newQuoteItem.id];
                    system.debug('*****>' + riders.size());
                    for(RFO_Rider__c rider : riders) {
                        datetime current = system.now();
                        rider.Quote_Stage_Time__c = current;
                        system.debug('Updating Rider Quote Stage time for Rider..' + rider.Id);
                        system.debug('Updating Rider Quote Stage time..' + current);
                        update rider;
                    }
                } 

            }
          

          

            if(!optyIds.isEmpty()) {
                RFO_QuoteHelperClass.updateOpportunityTypeInUpdate(optyIds);

            }



        }
        catch(Exception e) {   
                    RFO_Utility.createErrorLogRecordFuture(e.getMessage(),'Quote',
                                                           RFO_Constant.TRIGER,'RFO_QuoteTriggerHandler','afterInsert');
        }
        




        





        //CPQ Logic (arivkin)
       try{
             List<CPQSettings__mdt> iterationControl= [SELECT MasterLabel, QualifiedApiName, Value__c, Active__c from  CPQSettings__mdt 
                                                       WHERE QualifiedApiName ='RFO_QuoteTriggerHandler_AfterUpdate_Exec' 
                                                       AND Active__c=true Limit 1];
           
             if(iterationControl<>null && iterationControl.size()>0)
             {
                   CPQ_QuoteService svc = new CPQ_QuoteService();
                svc.createCPQQuoteRecords((Map<id,SBQQ__Quote__c >)newItems);
             }
           
        }
        catch(exception e)
        {
           system.debug(e.getMessage());
        }  






    }
    
    /**
* Method Name: afterDelete
**/
    public void afterDelete(Map<Id, SObject> oldItems) {
        
    }
    
    /**
* Method Name: afterUndelete
**/
    public void afterUndelete(Map<Id, SObject> oldItems) {}
}