/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 29 May 2019
* @Description : This Test Class covers Apex Trigger: RFO_QuoteTrigger, RFO_QuoteTeamTrigger and Apex Class: RFO_QuoteHelperClass, RFO_CreateQuoteShareRecord Code Coverage.
**/

@isTest(SeeAllData=false)
/*   Test Class Begins    */
Private Class RFO_QuoteTeamMemberHelperTest{ 
    /*Create Test Data */
    private static testmethod void createTestdata(){
        
        List<Quote_Team_Member__c> qtmList = new List<Quote_Team_Member__c>();
        Quote_Team_Member__c quotteammemEng = new Quote_Team_Member__c();
        Quote_Team_Member__c quotteammemPrcg = new Quote_Team_Member__c();
        Quote_Team_Member__c quotteammemPrdPlng = new Quote_Team_Member__c();
        Quote_Team_Member__c quotteammemPortflio = new Quote_Team_Member__c();
        Quote_Team_Member__c quotteammemSalesAdmin = new Quote_Team_Member__c();
         // Creating a Product
        Product2 prd = RFO_Utility_Test.createProduct();
        Database.insert(prd);  
        // Creating a Quote Team
        RFO_QuoteTeams__c quoteTeam = RFO_Utility_Test.createQuoteTeamUpdated();
        Database.insert(quoteTeam);
        // Creating an Account
        List<Account> prospectAccs = RFO_Utility_Test.createProspectAccounts();
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        prospectAccs[0].RFO_GlobalAccountID__c = RFO_Constant.ACCOUNT_GLOBALACCOUNTID;
        prospectAccs[0].RFO_OracleId__c = RFO_Constant.ACCOUNT_ORACLEID;
        prospectAccs[0].RFO_TASId__c = RFO_Constant.ACCOUNT_TASID;
        for(Account acc :prospectAccs ) {
            acc.recordTypeId = recordTypeId;
        }
        Database.insert(prospectAccs);
        // Creating an Opportunity
        List<Opportunity> tankOpportunities = RFO_Utility_Test.createTankOpportunities(prospectAccs[0]);
        Database.insert(tankOpportunities); 
        //Creating a Product
        Product2 productRec = new Product2();
        productRec = RFO_Utility_Test.createProduct();
        productRec.IsActive = True;
        Database.insert(productRec,false);
         // Creating a Quote       
         SBQQ__Quote__c qte =  RFO_Utility_Test.createCPQPrimaryQuotewithProduct(tankOpportunities[0],quoteTeam,productRec);
         Database.insert(qte);   
        
         // Creating a User record for CPQ
         User userQuoteTeam = new User();
         userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
         Database.insert(userQuoteTeam);
         // Creating a Quote Team member
                      quotteammemEng= RFO_Utility_Test.createQuoteTeamMember(qte,userQuoteTeam);
                      qtmList.add(quotteammemEng);
                      
                      quotteammemPrcg= RFO_Utility_Test.createQuoteTeamMember(qte,userQuoteTeam);
                      quotteammemPrcg.Role__c = 'Pricing';
                      qtmList.add(quotteammemPrcg);
                      
                      quotteammemPrdPlng = RFO_Utility_Test.createQuoteTeamMember(qte,userQuoteTeam);
                      quotteammemPrdPlng .Role__c = 'Production Planning';
                      qtmList.add(quotteammemPrdPlng );
                      
                      quotteammemPortflio = RFO_Utility_Test.createQuoteTeamMember(qte,userQuoteTeam);
                      quotteammemPortflio .Role__c = 'Portfolio Management';
                      qtmList.add(quotteammemPortflio );
                      
                      quotteammemSalesAdmin = RFO_Utility_Test.createQuoteTeamMember(qte,userQuoteTeam);
                      quotteammemSalesAdmin .Role__c ='Sales Admin';
                      qtmList.add(quotteammemSalesAdmin );
                      
                      Database.insert(qtmList);
                       
         User userQuoteTeam2 = new User();
         // Creating a User record for CPQ
         userQuoteTeam2 = RFO_Utility_Test.createUserRecordForCPQ();
         Database.insert(userQuoteTeam2);
         
         qtmList[0].User__c = userQuoteTeam2.id;
         Database.update(qtmList[0]);
         Map<Id,Quote_Team_Member__c> quotetTeamMemOldMap = new Map<Id,Quote_Team_Member__c>();
         quotetTeamMemOldMap.put(qtmList[0].id,qtmList[0]);
         RFO_QuoteTeamMemberHelper.addQuoteTeamMemToPublicGroup(qtmList,quotetTeamMemOldMap);
         
         Database.delete(qtmList[1]);
         
                      
           
         
      } 
    private static testmethod void createhandlrTestdata(){
    
    RFO_QuoteTeamMemberTriggerHandler obj= new RFO_QuoteTeamMemberTriggerHandler();
         Test.startTest();
             obj.afterInsert(null);
      obj.beforeInsert(null);
     obj.beforeUpdate(null,null);
                obj.afterDelete(null);
               obj.beforeDelete(null);
                obj.afterUnDelete(null);
    obj.afterUpdate(null,null);
       
        
        Test.stopTest();  
    } 
}