/* Name: RFO_SendEmailOnFileUploadTest
 * Created By: Ramesh
 * Created Date: September 2020
 * Jira: ALpha- 529
 * Purpose: To test for RFO_SendEmailOnFileUpload 
 */

@isTest
public class RFO_SendEmailOnFileUploadTest {
    @testSetup
    static void dataSetUp(){        
        List<Account> accList = new List<Account>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c();
        List<Order> orderList = new List<Order>();
        SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
        Product2 productRec = new Product2();
        List<RFO_Asset_File__c> assetFileList = new List<RFO_Asset_File__c>();
        
        //Creating an Account
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = RFO_Constant.ACCOUNT_GLOBALACCOUNTID;
        accList[0].RFO_OracleId__c = RFO_Constant.ACCOUNT_ORACLEID;
        accList[0].RFO_TASId__c = RFO_Constant.ACCOUNT_TASID;
        for(Account acc :accList ) {
            acc.recordTypeId = recordTypeId;
        }
        DataBase.insert(accList);
        
        //Creating a Commodity
        commodityList = RFO_Utility_Test.createCommodity1();
        Database.insert(commodityList);
        
        //Creating an Opportunity
        opportunityList=RFO_Utility_Test.createTankOpportunities(accList[0]);
        for(Opportunity opp:opportunityList){
            Opp.StageName = 'Initiated';
            Opp.Requirement_Status__c = '';
        }
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
        Database.insert(productRec,false);
        
        //Creating an Order
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList[0], commodityList[0], productRec);
        Database.insert(orderList);
        
        //Creating an Asset File
        assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        assetFileList[0].RFO_FileNumber__c = '';
        Database.insert(assetFileList);
    }
    
    static testMethod void testRFO_SendEmailOnFileUploadHelper(){
        RFO_Asset_File__c Asset = [select id from RFO_Asset_File__c];
        Id assetRT = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(RFO_Constant.AssetFile_RecordType).getRecordTypeId();
        
        test.startTest();
        try{
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test.pdf';
            cv.Trinity_File_Type__c ='Other';
            cv.PathOnClient = 'test';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            cv.FirstPublishLocationId = Asset.id;
            cv.RecordTypeId = assetRT;
        	cv.Trinity_File_Type__c = RFO_constant.File_Type;
            insert cv;
        }
        catch(exception e){
            system.assertEquals(e.getMessage().contains('Error: All change requests must be Acknowledged / Cancelled before changing order status.'), false);
        }
        test.stopTest();
    }
}