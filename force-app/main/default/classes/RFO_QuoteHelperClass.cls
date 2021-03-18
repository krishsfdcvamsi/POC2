/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 
* @Description :This class is a helper class to Trigger'RFO_QuoteTrigger's'  US: 
**/
public  with sharing class RFO_QuoteHelperClass{
    
    public static Boolean triggerDisabled = false;
    public String prdTrigName = 'QuoteTrigger';
    RFO_TriggerSetting__mdt pbeTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt 
                                          where MasterLabel =:prdTrigName Limit 1];
    
    public static Boolean isRecurrsiveonUpdate = false; 
    public static String error = null;
    
    public static void updateContactName(List<SBQQ__Quote__c> quoteLst){
        
        Set<id> idsAcc = new Set<id>();
        //SBQQ__Quote__c quoteUpdate;        
        
        try{    
            List<SBQQ__Quote__c>  quoteNewList =new List<SBQQ__Quote__c>();
            if(quoteLst.size()>0){
                quoteNewList = [Select Id,SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.AccountId FROM SBQQ__Quote__c WHERE Id IN: quoteLst Limit 49999];
            }
            
            if(quoteNewList.size()>0){ 
                for(SBQQ__Quote__c qq : quoteNewList){
                    idsAcc.add(qq.SBQQ__Opportunity2__r.AccountId);
                }
            }
            
            
            if(idsAcc.size()>0){            
                
                Map<Id,contact> mapContact = new Map<Id,contact>();            
                
                for(Contact cc : [SELECT Id,Name,Title,AccountId FROM Contact WHERE RFO_ContactRole__c includes ('Sales - Primary Contact') AND AccountId IN: idsAcc  Order by CreatedDate Asc Limit 49999]){
                    mapContact.put(cc.AccountId,cc);
                }
                
                List<SBQQ__Quote__c>  quoteList = new List<SBQQ__Quote__c>();
                for(SBQQ__Quote__c qq : quoteNewList){
                    //quoteUpdate = new SBQQ__Quote__c();
                    if(mapContact.containsKey(qq.SBQQ__Opportunity2__r.AccountId)){
                        //quoteUpdate.Id = qq.Id;
                        //quoteUpdate.RFO_ContactName__c = mapContact.get(qq.SBQQ__Opportunity2__r.AccountId).Name ;
                        //quoteUpdate.RFO_ContactTitle__c = mapContact.get(qq.SBQQ__Opportunity2__r.AccountId).Title ;                 
                        quoteList.add(new SBQQ__Quote__c(Id = qq.Id,RFO_ContactName__c = mapContact.get(qq.SBQQ__Opportunity2__r.AccountId).Name,
                                                         RFO_ContactTitle__c = mapContact.get(qq.SBQQ__Opportunity2__r.AccountId).Title));
                    }             
                }
                
                if(quoteList.size()>0){
                    update quoteList;
                }
                
            }
            
        }catch(Exception e) {
            error = e.getMessage();            
            System.debug('The following exception has occurred: ' + error);            
        }   
    }
    
    /**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 
* @Description :This method is used to update Primary on quote when Opportunity has only 1 quote. 
**/ 
    public static void updatePrimaryQuote(List<SBQQ__Quote__c> quoteList){
        
        Set<ID> OppIDSet = new Set<ID>();
        //SBQQ__Quote__c qrec;
        try{        
            List<SBQQ__Quote__c> quotelist1 = new List<SBQQ__Quote__c>();
            for(SBQQ__Quote__c quoteRec: quoteList){
                OppIDSet.add(quoteRec.SBQQ__Opportunity2__c);
            }
            // AggregateResult[] groupedResults  = [SELECT SBQQ__Opportunity2__c, Count(Id) Total FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN: OppIDSet  GROUP BY SBQQ__Opportunity2__c];
            Map<ID,Integer> oppmap=new Map<Id,Integer>();
            
            for (AggregateResult ar : [SELECT SBQQ__Opportunity2__c, Count(Id) Total FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN: OppIDSet  GROUP BY SBQQ__Opportunity2__c Limit 49999])  {
                Integer count= (Integer)ar.get('Total');
                Id oppid = (ID)ar.get('SBQQ__Opportunity2__c');
                
                oppmap.put(oppid,count);
            } 
            for(SBQQ__Quote__c quoteRecs: quoteList){
                if(oppmap.containsKey(quoteRecs.SBQQ__Opportunity2__c)){
                    if(oppmap.get(quoteRecs.SBQQ__Opportunity2__c)==1){
                        //qrec = new SBQQ__Quote__c();
                        //qrec.SBQQ__Primary__c=true;
                        //qrec.id=quoteRecs.id;
                        quotelist1.add(new SBQQ__Quote__c(SBQQ__Primary__c=true,id=quoteRecs.id));
                        system.debug('***QuoteREc****'+quoteRecs.id);
                    }
                }
            }
            if(quotelist1.size() >0)
            {
                system.debug('***quotelist1****'+quotelist1);
                update quotelist1;
            }
        }catch(Exception e) {            
            error = e.getMessage();            
            System.debug('The following exception has occurred: ' + error);           
        }           
    }
    
    /**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 
* @Description :This method adds quote team members from Quote Team assigned to Quote
**/ 
    public static void updateQuoteTeamMembers(List<SBQQ__Quote__c> quoteList, Map<Id,SBQQ__Quote__c> quoteOldMap){
        System.debug('Inside updateQuoteTeamMembers:' + quoteList);
        //Set of Team IDs
        Set<Id> teamSet = new Set<Id>();
        Map<ID, Quote_Team_Member__c> qtmMap = new Map<ID, Quote_Team_Member__c>();
        
        //Map of TeamId, teamMemberlist
        Map<Id, List<RFO_TeamMembers__c>> teamMembersMap = new Map<Id, List<RFO_TeamMembers__c>>();
        
        for(SBQQ__Quote__c quote : quoteList){
            if(quote.RFO_QuoteTeam__c != null) teamSet.add(quote.RFO_QuoteTeam__c);
        }
        System.debug('teamSet : ' + teamSet);
        
        //Get Team Members
        for(RFO_TeamMembers__c teamMember : [Select Id, Role__c, Team__c, User__c
                                             from RFO_TeamMembers__c
                                             where Team__c in : teamSet Limit 49999])
        {
            if(teamMembersMap.containsKey(teamMember.Team__c))
            {
                //append
                teamMembersMap.get(teamMember.Team__c).add(teamMember);
            }else{
                //add new
                List<RFO_TeamMembers__c> teamMemberList = new List<RFO_TeamMembers__c>();
                teamMemberList.add(teamMember);
                teamMembersMap.put(teamMember.Team__c, teamMemberList);
            }
        }
        System.debug('teamMembersMap : ' + teamMembersMap);
        
        Savepoint sp = Database.setSavepoint(); // setting savepoint
        List<Quote_Team_Member__c> newQuoteTeamMemerList = new List<Quote_Team_Member__c>();
        Quote_Team_Member__c quoteTeamMemer;
        
        try{
            //Get list of members from team assigned to each Quote and delete
            deleteQuoteTeamMembers(quoteList);
            //loop thru quote
            if(!teamMembersMap.isEmpty()){
            for(SBQQ__Quote__c quote : quoteList){
                if(!(quote.RFO_QuoteTeam__c != null && teamMembersMap.containsKey(quote.RFO_QuoteTeam__c))) continue;
                
                for(RFO_TeamMembers__c teamMember : teamMembersMap.get(quote.RFO_QuoteTeam__c)){
                    //assign Quote team members
                    quoteTeamMemer = new Quote_Team_Member__c();
                    quoteTeamMemer.Quote__c = quote.Id;
                    quoteTeamMemer.Role__c = teamMember.Role__c;
                    quoteTeamMemer.User__c = teamMember.User__c;
                    newQuoteTeamMemerList.add(quoteTeamMemer);
                }
            }
        
            //insert Quote Team members
            System.debug('insert Quote Team members : ' + newQuoteTeamMemerList);
            if(newQuoteTeamMemerList != null && !newQuoteTeamMemerList.isEmpty()){
                Database.insert(newQuoteTeamMemerList,false);
                    System.debug('Created Quote Team members : ' + newQuoteTeamMemerList);
            }
            }
           
        }catch(Exception e){ // handling exception
            System.debug('RFO_QuoteTeamMemberTriggerHandler Exception getCause : '+e.getCause());
            System.debug('RFO_QuoteTeamMemberTriggerHandler Exception getLineNumber : '+e.getLineNumber());
            System.debug('RFO_QuoteTeamMemberTriggerHandler Exception getMessage : '+e.getMessage());
            System.debug('RFO_QuoteTeamMemberTriggerHandler Exception getStackTraceString : '+e.getStackTraceString());
            Database.rollback( sp ); // roll back the DML transaction when error occured
            throw e;
        }
    }
    
    public static void deleteQuoteTeamMembers(List<SBQQ__Quote__c> quoteList) {
        System.debug('Inside deleteQuoteTeamMembers : ' + quoteList);
        List<Quote_Team_Member__c> quoteMemberList = [select Id 
                                                      from Quote_Team_Member__c 
                                                      where Quote__c in :quoteList Limit 49999];
        //Delete Existing Quote Member records
        System.debug('Delete Existing Quote Member records : ' + quoteMemberList);
        if(quoteMemberList != null && !quoteMemberList.isEmpty()){
            Database.delete(quoteMemberList);          
        }
    }
    
    
    /**
*   Method Name: quoteOppStageRequiredFields
*   Description: This method is to throw custom validation message when required fields for status are missing on opportunity
* */
    public static void quoteOppStageRequiredFields(List<SBQQ__Quote__c> quoteList, Map<Id, SObject> oldItems){
        Set<Id> opptyIds = new Set<Id>();
        Map<Id,Opportunity> quoteOppMap = new Map<Id,Opportunity>();
        Map<String,String> quoteFieldsMap = new Map<String,String>();
        Map<String,Set<String>> requiredFieldMap = new Map<String,Set<String>>();
        Set<String> temp =  new Set<String>();
        Map<String,Set<String>> additionalFieldMap = new Map<String,Set<String>>();
        String errorMessage='';
        Integer count=0;
       Map<id, String> partialLostFieldMap = new Map<id, String>();
        Schema.DescribeSObjectResult oppRecordtypes = Schema.SObjectType.Opportunity; 
        Map<Id,Schema.RecordTypeInfo> recordtyMap = oppRecordtypes.getRecordTypeInfosById();
        System.debug('recordTypes map: '+recordtyMap);
        try{
            for(RFO_QuoteOpportunityfieldsRequiredStatus__mdt oppReq : 
                [Select RFO_FieldAPIName__c, RFO_RecordTypeName__c, RFO_Active__c,  
                 RFO_FieldLabelName__c, RFO_Stage__c,RFO_PartialLost__c 
                 From RFO_QuoteOpportunityfieldsRequiredStatus__mdt where RFO_Active__c=TRUE Limit 49999]) {
                     quoteFieldsMap.put(oppReq.RFO_FieldAPIName__c,oppReq.RFO_FieldLabelName__c);
                     if(oppReq.RFO_PartialLost__c == true){
                         temp = new Set<String>();
                         if(additionalFieldMap.containsKey(oppReq.RFO_RecordTypeName__c + oppReq.RFO_Stage__c + 'Yes')) {
                             temp = additionalFieldMap.get(oppReq.RFO_RecordTypeName__c + oppReq.RFO_Stage__c + 'Yes');
                         }                         
                         temp.add(oppReq.RFO_FieldAPIName__c);
                         additionalFieldMap.put(oppReq.RFO_RecordTypeName__c + oppReq.RFO_Stage__c + 'Yes',temp);
                         
                     }
                     else{
                         temp = new Set<String>();
                         if(requiredFieldMap.containsKey(oppReq.RFO_RecordTypeName__c + oppReq.RFO_Stage__c)) {
                             temp = requiredFieldMap.get(oppReq.RFO_RecordTypeName__c + oppReq.RFO_Stage__c);
                         }                         
                         temp.add(oppReq.RFO_FieldAPIName__c);
                         requiredFieldMap.put(oppReq.RFO_RecordTypeName__c + oppReq.RFO_Stage__c,temp);
                     }
                 }  
            if(quoteList.size()>0){
                for(SBQQ__Quote__c quoteOppty: quoteList){
                    opptyIds.add(quoteOppty.SBQQ__Opportunity2__c);
                }
            }
            DescribeSObjectResult describeResult = Opportunity.getSObjectType().getDescribe();  
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );  
            String query =    ' SELECT Recordtype.developername,' +       String.join( fieldNames, ',' ) +    ' FROM ' +          describeResult.getName()  ;   
            
            
            if(opptyIds.size()>0){
                List<Opportunity> oppList = Database.query(query+' where Id IN:opptyIds ');
                for(Opportunity oppty: oppList){
                    quoteOppMap.put(oppty.Id,oppty);
                    partialLostFieldMap.put(oppty.Id, oppty.RFO_PartialLost__c);
                }
            }
            for(SBQQ__Quote__c quoteRec: quoteList){
                if(quoteRec.RFO_QuoteStage__c=='Business Awarded' && quoteRec.RFO_QuoteStage__c!=oldItems.get(quoteRec.Id).get('RFO_QuoteStage__c') && quoteRec.SBQQ__Primary__c==true){
                    if((!requiredFieldMap.isEmpty()) && requiredFieldMap.containsKey(quoteOppMap.get(quoteRec.SBQQ__Opportunity2__c).RecordType.Developername+quoteRec.RFO_QuoteStage__c)) {
                        for(String fieldApiName : requiredFieldMap.get(quoteOppMap.get(quoteRec.SBQQ__Opportunity2__c).RecordType.Developername+quoteRec.RFO_QuoteStage__c)) {
                            if(quoteOppMap.get(quoteRec.SBQQ__Opportunity2__c).get(fieldApiName)==null || quoteOppMap.get(quoteRec.SBQQ__Opportunity2__c).get(fieldApiName)=='' ){
                                errorMessage += RFO_Constant.BLANK_SPACE+quoteFieldsMap.get(fieldApiName)+RFO_Constant.COMMA;//+String.valueOf(changeReqMap.get(fieldApiName));//
                                count = count+1;
                            }
                        }
                    }
                    if((!additionalFieldMap.isEmpty()) && additionalFieldMap.containsKey(quoteOppMap.get(quoteRec.SBQQ__Opportunity2__c).RecordType.Developername+quoteRec.RFO_QuoteStage__c + quoteOppMap.get(quoteRec.SBQQ__Opportunity2__c).RFO_PartialLost__c))
                        for(String fieldApiName : additionalFieldMap.get(quoteOppMap.get(quoteRec.SBQQ__Opportunity2__c).RecordType.Developername+quoteRec.RFO_QuoteStage__c + quoteOppMap.get(quoteRec.SBQQ__Opportunity2__c).RFO_PartialLost__c)) {
                            if(quoteOppMap.get(quoteRec.SBQQ__Opportunity2__c).get(fieldApiName)==null || quoteOppMap.get(quoteRec.SBQQ__Opportunity2__c).get(fieldApiName)=='' ){
                                errorMessage += RFO_Constant.BLANK_SPACE+quoteFieldsMap.get(fieldApiName)+RFO_Constant.COMMA;     //+String.valueOf(changeReqMap.get(fieldApiName));//
                                count = count+1;
                            }
                        }            
                    if(errorMessage!=''){
                        quoteRec.addError('Please populate: \n'+errorMessage.removeEnd(RFO_Constant.COMMA)+(count>1?' fields':' field')+' on related Opportunity', false);
                    }
                }
            }
        }
        catch(Exception e) { 
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.QUOTE_OBJECT,
                                                   RFO_Constant.TRIGER,'RFO_QuoteHelperClass','quoteOppStageRequiredFields');  
        }
        
    }
    public static void quoteStageUpdateToBA(List<SBQQ__Quote__c> newItems){
           //List<SBQQ__Quote__c> qtList = new List<SBQQ__Quote__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> opptySet = new Set<Id>();
       for (SBQQ__Quote__c quteItem : newItems){
            opptySet.add(quteItem.SBQQ__Opportunity2__c);
        }
        system.debug('opptySet 111***'+opptySet);
        List<SBQQ__Quote__c> qtList = [Select Id,RFO_QuoteStage__c,SBQQ__Primary__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c,SBQQ__Opportunity2__r.StageName from SBQQ__Quote__c where SBQQ__Opportunity2__c IN:opptySet Limit 49999];
        for(SBQQ__Quote__c qtItem: qtList){
            if(qtItem.RFO_QuoteStage__c=='Business Awarded' && qtItem.SBQQ__Primary__c ==True){
                qtItem.SBQQ__Opportunity2__r.StageName='Closed-Won';
                oppList.add(qtItem.SBQQ__Opportunity2__r);
            }
        }   
        update oppList;
    }
    public static void updateQuoteStatus(List<SBQQ__Quote__c> quoteList){
     List<SBQQ__Quote__c> newQuoteList = new List<SBQQ__Quote__c>();
    Set<ID> OppIDSet = new Set<ID>();
        for(SBQQ__Quote__c quoteRec: quoteList){
            if(quoteRec.RFO_QuoteStage__c=='Business Awarded'){
                OppIDSet.add(quoteRec.SBQQ__Opportunity2__c);
                system.debug('****OPPid***'+OppIDSet);
            }
            
        }
        
      List <SBQQ__Quote__c> qtBAList = [Select Id,Name,SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c,SBQQ__Opportunity2__c,RFO_QuoteStage__c,SBQQ__Opportunity2__r.StageName FROM SBQQ__Quote__c WHERE 
                                                  SBQQ__Opportunity2__c IN:OppIDSet AND SBQQ__Opportunity2__r.RFO_PartialOpportunitystillActive__c ='No' AND SBQQ__Opportunity2__r.StageName='Closed-Won'  LIMIT 49999];
      for(SBQQ__Quote__c qtrec :qtBAList){
        if(qtrec.RFO_QuoteStage__c!='Business Awarded'){
             qtrec.RFO_QuoteStage__c='Withdrawn';
             newQuoteList.add(qtrec);
        }
     }
      if(newQuoteList.size()>0){
        update newQuoteList ;
          system.debug('****newQuoteList***'+newQuoteList);
        }
}

    public static void updateOpportunityType(map<string,set<Id>> optyIdsWrtQuoteRecordType) {
        list<opportunity> optyList = new list<opportunity>();
        if(optyIdsWrtQuoteRecordType.containsKey('New')) {
            optyList.addAll(getOpportunities(optyIdsWrtQuoteRecordType.get('New'),'New'));
        }
        else if(optyIdsWrtQuoteRecordType.containsKey('Existing')) {
            optyList.addAll(getOpportunities(optyIdsWrtQuoteRecordType.get('Existing'),'Existing'));
        }
        if(!optyList.isEmpty()) {
            update optyList;
        }
    }
    
    private static list<opportunity> getOpportunities(set<Id> optyIds,string type) {
        list<opportunity> optyList = new list<opportunity>();
        for(Id optyId : optyIds) {
            opportunity optySO = new opportunity();
            optySO.id = optyId;
            optySO.RFO_LostDtl_NewExisting__c = type;
            optyList.add(optySO);
        }
        return optyList;
        
    }
    

    public static void updateOpportunityTypeInUpdate(set<Id> optyIds) {
        list<opportunity> optyList = new list<opportunity>();
        system.debug('@---optyIds = '+optyIds);
        for(opportunity opty : [SELECT id,RFO_LostDtl_NewExisting__c,RFO_PreferredNewExisting__c,
                                (SELECT Id,recordType.Name FROM SBQQ__Quotes2__r WHERE SBQQ__Primary__c=true)
                                FROM opportunity WHERE id IN : optyIds]) {
            system.debug('@---opty = '+opty);
            if(opty.SBQQ__Quotes2__r != null && opty.SBQQ__Quotes2__r.size() > 0 ) {
                if(opty.SBQQ__Quotes2__r[0].recordType.Name.equals('New') || opty.SBQQ__Quotes2__r[0].recordType.Name.equals('Existing')) {
                    opty.RFO_LostDtl_NewExisting__c = opty.SBQQ__Quotes2__r[0].recordType.Name;
                }
            }
            else {
                opty.RFO_LostDtl_NewExisting__c = opty.RFO_PreferredNewExisting__c;
            }
            optyList.add(opty);
        }
        if(!optyList.isEmpty()) {
            update optyList;
        }
    }

/**************************************************************************************
* @Author : Ashish Reddy
* @Modified Date : 9/17/2020
* @Description       
* @User Story : ALPHA-155   
**************************************************************************************/    
    public static void sendSignedProposalNotification(Map<Id, SBQQ__Quote__c> quoteMap){

        Map<id,Id> contentDocToLinkedEntityMap  = ContentDocumentLinkService.getContentDocumentIdsByLinkedEntityId(quoteMap.keyset());
        if(!contentDocToLinkedEntityMap.isEmpty()){
            Set<Id> quoteIdSet = new Set<Id>();
            Map<Id,ContentVersion> contentVersionMap = ContentVersionService.getContentVersionIdByFileType(contentDocToLinkedEntityMap.keySet(), 'Signed Proposal');
            if(contentVersionMap != null && !contentVersionMap.isEmpty()){
                for(ContentVersion cv: contentVersionMap.values()){
                    quoteIdSet.add(contentDocToLinkedEntityMap.get(cv.contentDocumentId));
                }
                if(!quoteIdSet.isEmpty()){
                    sendChatterNotification(quoteIdSet, RFO_Constant.CHATTER_FLEET_ENGG);
                    prepAndSendCustomNotifications(quoteIdSet);
                }
            }
        }
    }

/**************************************************************************************
* @Author : Ashish Reddy
* @Modified Date : 9/17/2020
* @Description       
* @User Story : ALPHA-155   
**************************************************************************************/
public static void sendChatterNotification(Set<Id> quoteIdSet, String chatterGroupName ){
    CollaborationGroup cGroup;
    List<FeedItem> feedItemList = New List<FeedItem>();
    try {
        String cGroupName = Test.isRunningTest()?'Fleet Engineer Test Group':chatterGroupName;
        cGroup = [SELECT Id,Name From CollaborationGroup WHERE name =: cGroupName];
    }
    catch(exception e) {
        cGroup = null;
    }
    if(cGroup != null) {
        for(Id quoteId : quoteIdSet) {
            FeedItem post = new FeedItem();
            post.ParentId = cGroup.Id;
            post.Body = 'Signed Proposal is now available';
            post.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/'+ quoteId;
            feedItemList.add(post);
        }
        if(feedItemList.size() > 0) {         
            insert feedItemList;                
        }
    }
}

/**************************************************************************************
* @Author : Ashish Reddy
* @Modified Date : 9/17/2020
* @Description       
* @User Story : ALPHA-155   
**************************************************************************************/
public static void  prepAndSendCustomNotifications(Set<Id> quoteIdSet){
    set<String> userIds= new set<String>();
    for(User usr: [SELECT Id from user where Profile.Name = 'Fleet Engineering' and IsActive = true ]){
        userIds.add(usr.Id);
    }
    if(!userIds.isEmpty()) {
        for(Id quoteId : quoteIdSet) {                
            Map<String, Object> params = new Map<String, Object>();
            params.put('RecepientIdsList', userIds);
            params.put('NotificationType', 'Fleet_Engineering_Notification');
            params.put('NotificationBody', 'Signed Proposal is now available : ' + URL.getSalesforceBaseUrl().toExternalForm() + '/'+ quoteId);
            params.put('NotificationTitle', 'Signed Proposal is now available');
            params.put('targetId', quoteId);
            Flow.Interview.Send_Custom_Notifications sendCustomNotif = new Flow.Interview.Send_Custom_Notifications( params);
            sendCustomNotif.start();                                                
        }
    }
}



}