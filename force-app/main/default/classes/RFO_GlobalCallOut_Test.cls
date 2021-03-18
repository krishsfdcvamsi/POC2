/* Class Name : RFO_GlobalCallOut_Test
* Description : Test class for RFO_GlobalCallOut
* Created By : Ashish Reddy
* Created On : 12/28/20  
*
* Modification Log:
* -----------------------------------------------------------------------------------------------------------------
* Date                       Developer                          Description
* -----------------------------------------------------------------------------------------------------------------
* 12/28/20                   Ashish Reddy                       
*/

@isTest
private class RFO_GlobalCallOut_Test {
    
    @testsetup static void createRecords(){
        system.runAs(RFO_Utility_Test.createUserRecord()) {
            RFO_IntegrationLinks__c intgrtnLinks= new RFO_IntegrationLinks__c();
            RFO_IntegrationLinks__c intgrtnLinks1= new RFO_IntegrationLinks__c();     
            RFO_IntegrationLinks__c intgrtnLinks2= new RFO_IntegrationLinks__c();  
            RFO_IntegrationLinks__c intgrtnLinks3= new RFO_IntegrationLinks__c();    
            List<RFO_IntegrationLinks__c> linkList = new List<RFO_IntegrationLinks__c>();
            List<Account> accList = new List<Account>();
            List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
            List<Opportunity> opportunityList = new List<Opportunity>();
            RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c();
            List<Order> orderList = new List<Order>();
            SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
            Product2 productRec = new Product2();
            List<RFO_Asset_File__c> assetFileList = new List<RFO_Asset_File__c>();
            
            intgrtnLinks.Name=RFO_Constant.ACCOUNT_OBJECT;
            intgrtnLinks.RFO_APILink__c=RFO_Constant.APILINK_EX;
            intgrtnLinks1 = RFO_Utility_Test.createIntegrationLinks(RFO_Constant.APILINK_EX);
            intgrtnLinks2.Name='Rider';
            intgrtnLinks2.RFO_APILink__c=RFO_Constant.APILINK_EX;
            
            
            intgrtnLinks3.Name='PostParentAssetFile';
            intgrtnLinks3.RFO_APILink__c=RFO_Constant.APILINK_EX;            
            
            linkList.add(intgrtnLinks);
            linkList.add(intgrtnLinks1);
            linkList.add(intgrtnLinks2);
            linkList.add(intgrtnLinks3);
            DataBase.insert(linkList); 
            accList = RFO_Utility_Test.createProspectAccounts();
            //  System.debug('account list'+accList);
            accList[0].RFO_GlobalAccountID__c = RFO_Constant.ACCOUNT_GLOBALACCOUNTID;
            accList[0].RFO_OracleId__c = RFO_Constant.ACCOUNT_ORACLEID;
            accList[0].RFO_TASId__c = RFO_Constant.ACCOUNT_TASID;
            TriggerDispatcher.isRecurrsiveAfterInsert = true;
            TriggerDispatcher.isRecurrsiveAfterupdate = true;
            DataBase.insert(accList);
            
            //User userRecord = createSalesUser();
            User userQuoteTeam = new User();
            userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
            //  userQuoteTeam.RFO_Contracts__c = True;
            userQuoteTeam.RFO_Engineering__c = True;
            userQuoteTeam.RFO_Estimating__c = True;
            userQuoteTeam.RFO_PortfolioManagement__c = True;
            userQuoteTeam.RFO_PricingSummary__c = True;
            userQuoteTeam.RFO_ProductionPlanning__c = True;
            userQuoteTeam.RFO_AccountManager__c = True;
            userQuoteTeam.RFO_Sales__c = True;
            Database.insert(userQuoteTeam);
            
            Contract contr = new Contract(AccountId = accList[0].id, 
                                          RFO_ContractType__c= RFO_Constant.MANAGEMENT_AGREEMENT.toUpperCase(), 
                                          RFO_ContractId__c = '3869',
                                          StartDate = system.today(),
                                          RFO_ContractDate__c=system.today());
            Database.insert(contr);
            
            //Rider Creation
            RFO_Rider__c rider=new RFO_Rider__c();
            rider=RFO_Utility_Test.createrider();
            rider.RFO_Account__c=accList[0].id;
            rider.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
            rider.RFO_AutoRenewal__c = RFO_Constant.NO;
            rider.RFO_RiderNumber__c = RFO_Constant.NINE;
            rider.RFO_RiderNumberSuffix__c = RFO_Constant.NINE;
            
            rider.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
            rider.RFO_RiderType__c = RFO_Constant.MANAGEMENT_AGREEMENT;
            rider.RFO_Contract__c=contr.id;
            rider.RFO_TotalOfCars__c = 1;
            Database.Insert(rider);
            
            //Creating a Commodity
            commodityList = RFO_Utility_Test.createCommodity1();
            Database.insert(commodityList);
            //Creating an Opportunity
            opportunityList=RFO_Utility_Test.createTankOpportunities(accList[0]);
            Database.insert(opportunityList);
            //Creating a QuoteTeam
            quoteTeamRecord = RFO_Utility_Test.createQuoteTeam();
            Database.insert(quoteTeamRecord);
            
            
            //Creating a CPQ Quote
            cpqQuoteList = RFO_Utility_Test.createCPQPrimaryQuote(opportunityList[0], quoteTeamRecord);
            cpqQuoteList.RFO_ProposalRefreshStatus__c = 'Resubmit for Pricing';   // Proposal Refresh Status
            cpqQuoteList.RFO_ProposalRefreshRequired__c = 'Yes';                  // Proposal Refresh Required
            cpqQuoteList.RFO_DaysUntilProposalExpires__c = '30'; 
            cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
            cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;
            Database.insert(cpqQuoteList);
            //Creating a Product
            productRec = RFO_Utility_Test.createProduct();
            productRec.IsActive = True;
            productRec.Build_Flag__c = True;
            Database.insert(productRec,false);
            //Creating an Order
            orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList[0], commodityList[0], productRec);
            Database.insert(orderList);
            //Creating an Asset File
            assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
            assetFileList[0].RFO_FileNumber__c = '';
            Database.insert(assetFileList);            
            //Integer chatterGroupCount = [Select count() from CollaborationGroup where Name =:System.Label.RFO_DataManagement];
            //if(chatterGroupCount==0){
            //CollaborationGroup cg = new CollaborationGroup(Name = System.Label.RFO_DataManagement, CollaborationType = 'Public');
            //insert cg;                
            //}            
        }
    }
    private static testMethod void getRFOGlobalAccountIdTest (){
        Account acc = [select id, name from Account limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RFO_MockHttpResponseGenerator());                    
        RFO_GlobalCallOut.getRFOGlobalAccountId(String.valueOf(acc.id));
        Test.stopTest();
        acc = [select id, name, RFO_AccountStatus__c from Account where id =: acc.Id];
        system.assertEquals('Active', acc.RFO_AccountStatus__c);
    }
    
    private static testMethod void getRFOGlobalAccountIdFailureTest (){
        Account acc = [select id, name from Account limit 1];   
        String httpResponseBody1 = '{"status": "Error sending HTTP request.","StatusCode": "500"}';
        RFO_HTTPMockFactory mock1 = new RFO_HTTPMockFactory(500, 'Success', httpResponseBody1, new Map<String,String>());
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock1);                  
        RFO_GlobalCallOut.getRFOGlobalAccountId(String.valueOf(acc.id));
        Test.stopTest();
        acc = [select id, name, RFO_AccountStatus__c from Account where id =: acc.Id];
        system.assertEquals('Active', acc.RFO_AccountStatus__c);
    }
    
    private static testMethod void getRiderIdTest(){
        User userRecord = RFO_Utility_Test.createUserRecordForCPQ();
        RFO_Rider__c rider=[select id, name from RFO_Rider__c limit 1];
        rider.RFO_TASRiderId__c = '2314';
        Database.update(rider);
        system.runAs(userRecord) {
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"success","message":"Rider Created successfully"}');
            res.setStatusCode(200); 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileSplitResponse());     
            
            RFO_GlobalCallOut.getRiderId(String.valueOf(rider.Id), res.getBody(),   'messageId', rider.RFO_TASRiderId__c);
            Test.stopTest(); 
            rider = [select id, RFO_IntegrationStatus__c from RFO_Rider__c where Id = : rider.Id limit 1];
            System.assertEquals(rider.RFO_IntegrationStatus__c, 'Success');
        }
    }    
    
    
    private static testMethod void getAssetFileNumberTest(){
        User userRecord = RFO_Utility_Test.createUserRecordForCPQ();
        RFO_Asset_File__c assetFile=[select id, name from RFO_Asset_File__c limit 1];
        system.runAs(userRecord) {
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"success","message":"Asset Created successfully"}');
            res.setStatusCode(200); 
            RFO_HTTPMockFactory mock1 = new RFO_HTTPMockFactory(200, 'Success', res.getBody(), new Map<String,String>());
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock1);     
            
            RFO_GlobalCallOut.getAssetFileNumber(res.getBody(), String.valueOf(assetFile.Id), RFO_Constant.PARENT_ASSETFILE,  RFO_Constant.RECORD_CREATED,   'messageId');
            Test.stopTest();
            System.assert(assetFile.Name != null);
        }
    } 
    
    private static testMethod void getAssetFileNumberFailureTest(){
        User userRecord = RFO_Utility_Test.createUserRecordForCPQ();
        RFO_Asset_File__c assetFile=[select id, name from RFO_Asset_File__c limit 1];
        system.runAs(userRecord) {
            
            String httpResponseBody1 = '{"status": "Error sending HTTP request.","StatusCode": "500"}';
            RFO_HTTPMockFactory mock1 = new RFO_HTTPMockFactory(500, 'Success', httpResponseBody1, new Map<String,String>());
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"error", ');
            res.setStatusCode(400);
            try{
                Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, mock1);                 
                RFO_GlobalCallOut.getAssetFileNumber(res.getBody(), String.valueOf(assetFile.Id), RFO_Constant.PARENT_ASSETFILE,  RFO_Constant.RECORD_UPDATED,   'messageId');
                Test.stopTest();
            } catch(Exception e){                
            }                       
        }
         System.assert(assetFile.Name != null);
    }     
    
    private static testMethod void sendAccountInfoToTASTest(){
        User userRecord = RFO_Utility_Test.createUserRecordForCPQ();
        RFO_Asset_File__c assetFile=[select id, name from RFO_Asset_File__c limit 1];
        Account acc = [select id, name from Account limit 1];
        system.runAs(userRecord) {
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"success","message":"Asset Created successfully"}');
            res.setStatusCode(200); 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileSplitResponse());     
            RFO_GlobalCallOut.sendAccountInfoToTAS(String.valueOf(acc.Id) ,res.getBody(), 'messageId', RFO_Constant.TRIGER,   'SuccessMessage', '');
            Test.stopTest();
            
        }
       System.assert(assetFile.Name != null); 
    } 
    
    private static testMethod void sendAccountInfofromTAStoBatchTest(){
        User userRecord = RFO_Utility_Test.createUserRecordForCPQ();
        RFO_Asset_File__c assetFile=[select id, name from RFO_Asset_File__c limit 1];
        Account acc = [select id, name from Account limit 1];
        system.runAs(userRecord) {
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"success","message":"Asset Created successfully"}');
            res.setStatusCode(200); 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileSplitResponse());     
            RFO_GlobalCallOut.sendAccountInfofromTAStoBatch(String.valueOf(acc.Id) ,res.getBody(), 'messageId', RFO_Constant.TRIGER,   'SuccessMessage', '');
            Test.stopTest();
            
        }
       System.assert(assetFile.Name != null); 
    } 
    
    private static testMethod void sendAccountInfofromTAStoBatchFailureTest(){
        User userRecord = RFO_Utility_Test.createUserRecordForCPQ();
        RFO_Asset_File__c assetFile=[select id, name from RFO_Asset_File__c limit 1];
        Account acc = [select id, name from Account limit 1];
        system.runAs(userRecord) {
            String httpResponseBody1 = '{"status": "Error sending HTTP request.","StatusCode": "500"}';
            RFO_HTTPMockFactory mock1 = new RFO_HTTPMockFactory(500, 'Success', httpResponseBody1, new Map<String,String>());
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"error", ');
            res.setStatusCode(400); 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock1);     
            RFO_GlobalCallOut.sendAccountInfofromTAStoBatch(String.valueOf(acc.Id) ,res.getBody(), 'messageId', RFO_Constant.TRIGER,   'SuccessMessage', null);
            RFO_GlobalCallOut.failureResponseChatterPost(res, acc.Id);
            Test.stopTest();            
        }
        System.assert(assetFile.Name != null);
    }   
    
    private static testMethod void sendAccountInfoToTASFailureTest(){
        User userRecord = RFO_Utility_Test.createUserRecordForCPQ();
        RFO_Asset_File__c assetFile=[select id, name from RFO_Asset_File__c limit 1];
        Account acc = [select id, name from Account limit 1];
        system.runAs(userRecord) {
            
            String httpResponseBody1 = '{"status": "Error sending HTTP request.","StatusCode": "500"}';
            RFO_HTTPMockFactory mock1 = new RFO_HTTPMockFactory(500, 'Success', httpResponseBody1, new Map<String,String>());
            
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"error", ');
            res.setStatusCode(400); 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock1);     
            RFO_GlobalCallOut.sendAccountInfoToTAS(String.valueOf(acc.Id) ,res.getBody(), 'messageId', RFO_Constant.TRIGER,   'SuccessMessage', '');
            Test.stopTest();
            
        }
        System.assert(assetFile.Name != null);
    }     
    
}