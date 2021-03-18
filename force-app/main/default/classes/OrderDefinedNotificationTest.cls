/* Class Name : OrderDefinedNotificationHandler
 * Description : Test Class for OrderDefinedNotificationHandler
 * Created By : Vihari Vanga
 * Created On : 9/22/20
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 9/22/20                    Vihari Vanga                       ALPHA - 738
 */
@isTest
public class OrderDefinedNotificationTest {
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
        /* Test starts here */             
        test.startTest();
       
        List<Order> orderList1 = [SELECT Id, Name, OrderNumber, AccountId, Account.RecordType.Name, Account_Name_Text__c, RFO_LineNumber__c, RFO_SellQuantity__c,RFO_CarType__c,RFO_CommodityName__c,RFO_File__c,RFO_Notify_New_Car_Plant_User_On_Defined__c, RFO_Product__r.Name, RFO_Quantity__c, Type FROM Order];
        System.assertEquals(1,orderList1.size());                    
        OrderDefinedNotificationHandler.Input inps = new OrderDefinedNotificationHandler.Input();
        inps.orderId = orderList1[0].id;
        inps.recipientIds = new List<String>{'vihari.vanga@trin.net'};
            
        OrderDefinedNotificationHandler.sendEmailNotification(new List< OrderDefinedNotificationHandler.Input>{inps});
        
      
        test.stopTest();
        /* Test starts here */
    }
    
    private static testMethod void testSendEmailNotificationFailed(){ 
        /* Test starts here */             
        test.startTest();
       
        List<Order> orderList1 = [SELECT Id, Name, OrderNumber, AccountId, Account.RecordType.Name, Account_Name_Text__c, RFO_LineNumber__c, RFO_SellQuantity__c,RFO_CarType__c,RFO_CommodityName__c,RFO_File__c,RFO_Notify_New_Car_Plant_User_On_Defined__c, RFO_Product__r.Name, RFO_Quantity__c, Type FROM Order];
        System.assertEquals(1,orderList1.size());                    
        OrderDefinedNotificationHandler.Input inps = new OrderDefinedNotificationHandler.Input();
        inps.orderId = orderList1[0].id;
        inps.recipientIds = null;
        
        try{
           OrderDefinedNotificationHandler.sendEmailNotification(new List< OrderDefinedNotificationHandler.Input>{inps}); 
        }catch(Exception e)   {
            System.assertEquals(true, e.getMessage()!=null);
        }
        
        
      
        test.stopTest();
        /* Test starts here */
    }
   
}