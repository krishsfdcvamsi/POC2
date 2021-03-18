/* Class Name : EmailService
 * Description : Test Class for EmailService
 * Created By : Vihari Vanga
 * Created On : 10/22/20
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/22/20                    Vihari Vanga                       ALPHA - 738
 * 11/29/20                    Vihari Vanga                       ALPHA - 1693
 */
@isTest
public class EmailServiceTest {
@testSetup 
    static void setup() {
        List<Account> accList = new List<Account>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c();
        List<Order> orderList = new List<Order>();
        SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
        Product2 productRec = new Product2();
        List<RFO_Asset_File__c> assetFileList = new List<RFO_Asset_File__c>();
        
        
        //Creating an Account
        List<RecordType> rList= [Select id From RecordType Where sObjectType = 'Account'and RecordType.Name = 'Customer' Limit 1];
        Account act =new account();
        act.Name = '37 Building Products';  // Account Name
        act.recordTypeid = rlist[0].id;           // Account Record Type
        act.Phone = '800-832-5451';          // Phone
        act.RFO_Region__c = 'Class 1 Railroads';   // Region
        act.RFO_AccountStatus__c = 'Active';
        accList.add(act);
        
        Account ac1 =new account();
        ac1.Name = 'testghy1';  // Account Name
        ac1.recordTypeid = rlist[0].id;           // Account Record Type
        ac1.Phone = '800-832-5453';          // Phone
        ac1.RFO_Region__c = 'Class 1 Railroads';   // Region
        ac1.RFO_AccountStatus__c = 'Active';
        accList.add(ac1);
       
        Database.insert(accList);

        //Creating a Commodity
        commodityList = RFO_Utility_Test.createCommodity1();
        Database.insert(commodityList);
        //Creating an Opportunity
        opportunityList=RFO_Utility_Test.createTankOpportunities(accList[0]);
        opportunityList[0].RFO_ProductType__c=null;
        opportunityList[0].Requirement_Status__c= 'Test';// Added By Vihari 2/17/21
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
        productRec.IsActive = true;// Updated by Vihari
        Database.insert(productRec,false);
        //Creating an Order
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList[0], commodityList[0], productRec);
        orderList[0].RFO_File__c = '1234';
        Database.insert(orderList);
        //Creating an Asset File
        assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        assetFileList[0].RFO_FileNumber__c = '';
        Database.insert(assetFileList);
    }
    
    private static testMethod void testSendEmailNotification(){ 
        EmailTemplate validEmailTemplate = new EmailTemplate();
		validEmailTemplate.isActive = true;
		validEmailTemplate.Name = 'testName';
		validEmailTemplate.DeveloperName = 'testing_template';
		validEmailTemplate.TemplateType = 'text';
		validEmailTemplate.FolderId = UserInfo.getUserId();
        insert validEmailTemplate;
        /* Test starts here */             
        test.startTest();
        
        User u = RFO_Utility_Test.createUserRecord();
        Database.insert(u);
        
        List<Order> orders = [SELECT Id FROM Order];
        
        EmailService.Input inps = new EmailService.Input();
        inps.userIds = new List<String>{u.id};
        inps.relatedTo = orders[0].id;
        inps.templateName = 'testing_template';
        inps.senderEmail = 'noreply@trin.net';
            
        EmailService.sendEmailNotification(new List<EmailService.Input>{inps});
      	 /* Added By Vihari ALPHA-693 */
        List<User> uList = UserService.getUsers(new List<String>{u.id});
        System.assertEquals(true, uList.size()>0);
        /* End ALPHA - 693 */
        test.stopTest();
        /* Test stops here */
    }
    
    
}