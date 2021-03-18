/*
* Class  Name: RFO_CaseRequiredStatusTest
*/
@isTest(SeeAllData = false)
private class RFO_CaseRequiredStatusTest {
    /*
* Method Name: test
*/
    @testsetup static void test() {
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        system.assert(accList.size()>0);
        Database.insert(accList);
        accList[0].RFO_GlobalAccountId__c = RFO_Constant.GLOBALACCOUNTID;
        Database.update(accList[0]);
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = RFO_Utility_Test.createTankOpportunities(accList[0]);                    
        Database.insert(oppList);
        //Creating a QuoteTeam
        RFO_QuoteTeams__c quoteTeamRecord = RFO_Utility_Test.createQuoteTeam();
        database.insert(quoteTeamRecord);
        
        //Creating a CPQ Quote
        SBQQ__Quote__c  cpqQuoteList = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRecord);
        cpqQuoteList.RFO_ProposalRefreshStatus__c = RFO_CONSTANT.PROPOSAL_FRESH_STATUS;   // Proposal Refresh Status
        cpqQuoteList.RFO_ProposalRefreshRequired__c = RFO_CONSTANT.YES;                  // Proposal Refresh Required
        cpqQuoteList.RFO_DaysUntilProposalExpires__c = RFO_CONSTANT.THIRTY; 
        cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;
        database.insert(cpqQuoteList);
        
        //Commodity creation
        List<RFO_Commodity__c> commList = new List<RFO_Commodity__c>();
        commList = RFO_Utility_Test.createCommodity1();
        Database.insert(commList);
        
        Pricebook2 pbook = new Pricebook2(
            Name = 'Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Database.update(pbook);
        //Product Creation
        Product2 prodObj = new Product2();
        prodObj = RFO_Utility_Test.createProduct();
        prodObj.IsActive = true; // Changed by Ramesh 22/12/2020
        Database.insert(prodObj);
        
        // Order Creation
        List<Order> orderList = new List<Order>();
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList,accList[0],commList[0], prodObj );
        //System.debug('orderList'+orderList);
        orderList[0].RFO_Commencement__c = date.today();
        orderList[0].RFO_FirstShipWeek__c = date.today();
        orderList[0].EffectiveDate = date.today();
        orderList[0].Status = RFO_CONSTANT.DRAFT;
        Database.insert(orderList);
        
        // Asset File Creation
        List<RFO_Asset_File__c> assetfileList = new List<RFO_Asset_File__c>();
        assetfileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        Database.insert(assetfileList);
        
        // Change Request Creation
        List<Case> caseList = new List<Case>();
        caseList = RFO_Utility_Test.createNewCarCR(accList[0],orderList[0],assetfileList[0]);
        Id newCarChangeReqRecID = 
            Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_NewCarChangeRequest').getRecordTypeId();
        caseList[0].RecordTypeId = newCarChangeReqRecID;
        caseList[0].Status='Engineering Review';
        Database.insert(caseList);
        //System.debug('case'+caseList);      
        
        //Create a ChangeRequestLineItem record
        Id newCarChangeReqLinItmRecID = 
            Schema.SObjectType.RFO_ChangeRequestLineItem__c.getRecordTypeInfosByDeveloperName().get('RFO_NewCarChangeRequestLineItem').getRecordTypeId();
        List<RFO_ChangeRequestLineItem__c> crliList = new List<RFO_ChangeRequestLineItem__c>();
        crliList = RFO_Utility_Test.createNewCarCRLI(caseList[0]); 
         //crliList[0].RecordTypeId = newCarChangeReqLinItmRecID;
        Database.insert(crliList);
        
        
        system.assertEquals(caseList != null,true);
        
    }
    /**
* Description: Updateing Account Owner
* */
    
    private static testMethod void caseRequiredStatus(){
        system.runAs(createUser()) { 
            Id standardPBId = Test.getStandardPricebookId();
            Case caseRec = [select id,RFO_NewCarLineItemCount__c,Status from Case limit 1];
            RFO_ChangeRequestLineItem__c cRLI = [select id, name, Recordtype.Name from RFO_ChangeRequestLineItem__c
                                                 where RFO_ChangeRequestID__c =: caseRec.id limit 1];
            System.debug('Case field: '+caseRec.RFO_NewCarLineItemCount__c);
            System.debug('CRLI recordtype: '+cRLI.Recordtype.Name);
            caseRec.Status = 'Change Request Feedback Received'; 
            
            Map<Id,Case> caseMap = new Map<Id, case>([SELECT Id,RFO_NewCarLineItemCount__c,status FROM case LIMIT 49999]);
            //RFO_CaseRequiredStatus.errorMessageOnCaseStatus(caseMap);
            Test.startTest();
            try{
                Database.update(caseRec) ;
            }
            catch(Exception e)
            {
                String message = e.getMessage();
                system.assert(message.contains('The list of required fields missed on'), 'message=' + message);
            }
            System.debug('Case field: '+caseRec.RFO_NewCarLineItemCount__c);
            Test.stopTest();
            System.AssertEquals(caseRec.Status, 'Change Request Feedback Received');
        }
    }
    
    /**
*   createUser method
**/
    private static User createUser() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        userRecord.Lan_Id__c = 'MYDEVROLE';
        System.Assert(userRecord!=null );
        Database.insert(userRecord);
        return userRecord;
    }
}