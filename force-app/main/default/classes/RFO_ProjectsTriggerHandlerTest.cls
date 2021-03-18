@isTest
public class RFO_ProjectsTriggerHandlerTest {
    public static testMethod void updateContactIdTest(){
        //Start, Lakshmi
        User userRecord = RFO_Utility_Test.createUserRecord();
        insert userRecord;
        
        system.runAs(userRecord) { 
            Account objAcc = new Account(); 
            objAcc.Name= 'Test';    
            insert objAcc;
            
            AccountTeamMember ateam = RFO_Utility_Test.createAccountTeamMember(userRecord.id,objAcc.id);
            DataBase.insert(ateam);
            
            
            
            
            System.assert(objAcc != null);  
            System.assert(objAcc.Name == 'Test');   
            RFO_Projects__c objProject = new RFO_Projects__c(); 
            objProject.RFO_Account__c = objAcc.Id;  
            objProject.RFO_Workstation__c = 'Engineering';  
            objProject.Stop_Email_Notification__c = True;   
            insert objProject;  
            objProject.RFO_Workstation__c = 'Customer Delivery';    
            update objProject;  
            
            RFO_Projects__c objProject1 = new RFO_Projects__c();    
            objProject1.RFO_Account__c = objAcc.Id; 
            objProject1.RFO_Workstation__c = 'Customer Delivery';   
            objProject1.Stop_Email_Notification__c = True;  
            insert objProject1; 
            update objProject1; 
            delete objProject1; 
            System.assert(objProject.RFO_Workstation__c != null);   
            RFO_Projects__c objProject2 = new RFO_Projects__c();    
            objProject2.RFO_Account__c = objAcc.Id; 
            objProject2.RFO_Workstation__c = 'Engineering'; 
            objProject2.Stop_Email_Notification__c = True;  
            objProject2.RFO_ProjectId__c = '123678';    
            insert objProject2;     
            objProject2.RFO_Workstation__c = 'Capacity Planning';   
            update objProject2; 
            objProject2.RFO_Workstation__c = 'Planning';    
            update objProject2; 
            System.assert(objProject2.RFO_Workstation__c != null);
            //End, Lakshmi
            
            Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
            Test.startTest();
            Account ac = new Account();
            ac.Name = 'Test Account 11111';
            ac.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
            ac.Phone = '800-832-5452';          // Phone
            ac.RFO_Region__c = 'Class 1 Railroads';   // Region
            ac.RFO_AccountStatus__c = 'Active';
            //ac.OwnerId = usr1.id;
            insert ac;
            //Start, Lakshmi
            Account ac1 = new Account();    
            ac1.Name = 'Test Account 2';    
            ac1.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type   
            ac1.Phone = '800-832-5452';          // Phone   
            ac1.RFO_Region__c = 'Class 1 Railroads';   // Region    
            ac1.RFO_AccountStatus__c = 'Active';    
            //ac.OwnerId = usr1.id; 
            insert ac1;
            //End, Lakshmi
            
            Contact cnt = new Contact(
                FirstName = 'Tony', // FirstName
                LastName = 'Alen',  // LastName
                RFO_Status__c = 'Active', // Status
                Email = 'Tony.Alen@trinity.net', // Email
                AccountId = ac.id, // Account Name
                Phone = '(806) 381-0261', // Phone
                RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
                Fax = '(806) 371-7528' // Fax
            );
            insert cnt;
            
            
            Contact c1 = new Contact();
            c1.FirstName = 'Alagiri1';
            c1.LastName = 'Muthiah1';
            c1.RFO_Status__c = 'Active';
            c1.AccountId = ac.id;  
            c1.Email = 'alagiri.muthiah@trin.net';
            c1.RFO_ContactRole__c = 'Compliance Project Survey Contact';
            insert c1;  
            
            //Start, Lakshmi
            Contact c2 = new Contact(); 
            c2.FirstName = 'Alagiri';   
            c2.LastName = 'Muthiah';    
            c2.RFO_Status__c = 'Active';    
            c2.AccountId = ac.id;   
            c2.Email = 'alagiri.muthiah@trin.net';  
            c2.RFO_ContactRole__c = 'Survey Contact';   
            insert c2;      
            
            Pricebook2 objP = new Pricebook2(); 
            objP.IsActive = true;   
            objp.Name = 'Standard Price Book';  
            insert objP;    
            
            Product2 objP2 = new Product2();    
            objP2.Name = 'test';    
            insert objP2;   
            
            PricebookEntry objPBE = new PricebookEntry();   
            objPBE.Pricebook2Id = objP.Id;  
            objPBE.UnitPrice = 10;  
            objPBE.Product2Id = objP2.Id;   
            objPBE.IsActive = true; 
            objPBE.Pricebook2Id=Test.getStandardPricebookId();  
            insert objPBE;  
            
            // insert new PriceBookEntry(Product2Id=objP2.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0); 
            List<Order> orderList = new List<Order>();  
            Id existingCar = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId(); 
            Order ord = new Order();    
            ord.AccountId = objAcc.Id;  
            ord.Status = 'Active';  
            ord.RecordTypeId = existingCar; 
            ord.Pricebook2Id = Test.getStandardPricebookId();   
            ord.RFO_RANumber__c = '123456'; 
            ord.RFO_OrderReviewMeetingDate__c = date.today();   
            ord.EffectiveDate = Date.today();   
            
            
            Order ord1 = new Order();   
            ord1.AccountId = objAcc.Id; 
            ord1.Status = 'Active'; 
            ord1.Pricebook2Id = Test.getStandardPricebookId();  
            ord1.EffectiveDate = Date.today();  
            
            orderList.add(ord); 
            orderList.add(ord1);    
            
            insert orderList;   
            
            RFO_Projects__c objProject3 = new RFO_Projects__c();    
            objProject3.RFO_Account__c = objAcc.Id; 
            objProject3.RFO_Workstation__c = 'Customer Delivery';   
            objProject3.Stop_Email_Notification__c = True;  
            objProject3.RFO_ProjectId__c = '1234';  
            objProject3.Order__c = ord.Id;  
            insert objProject3;
            
            
            
            //End, Lakshmi
            
            List<RFO_Projects__c> projectList = new List<RFO_Projects__c>();
            for(Integer i=0;i<2;i++){
                RFO_Projects__c proj = new RFO_Projects__c();
                proj.RFO_Account__c = ac.Id;
                proj.RFO_Status__c = 'Active';
                proj.RFO_DemandDriverName__c = 'Compliance';
                proj.Name = 'Test Project';
                projectList.add(proj);
            }
            
            insert projectList;
            /*
for(RFO_Projects__c project : projectList){
project.Last_Car_Ship_Date__c = system.today() -11;
}

update projectList;*/
            
            Test.stopTest(); 
            
            
        }
        
        
    }
    /* Name: alertEngineersTest
* Created By: Ramesh
* Created Date: November 2020
* Jira: ALpha- 587 & 588
*/
    public static testMethod void alertEngineersTest(){
        // Product Insert
        Product2 prod2 = RFO_Utility_Test.createProduct();
        prod2.IsActive=true;
        insert prod2;
        
        
        // Account insert
        List<Account> accList = RFO_Utility_Test.createProspectAccounts();
        insert accList;
        
        // Contact Insert
        List<Contact> contList = RFO_Utility_Test.createContact(accList[0]);
        insert contList;
        
        // AccountTeamMember Insert
        
        AccountTeamMember ateam2 = new  AccountTeamMember();
        ateam2 = RFO_Utility_Test.createAccountTeamMemberCDM(UserInfo.getUserId(),accList[0].Id);
        
        DataBase.insert(ateam2);
        
        
        // Opportunities insert
        List<Opportunity> oppList = RFO_Utility_Test.createTankOpportunities1(accList[0], contList[0]);
        insert oppList;
        
        // QuoteTeams insert
        RFO_QuoteTeams__c quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
        Database.insert(quoteTeamRec);  
        
        // Quote Insert
        SBQQ__Quote__c quote = RFO_Utility_Test.createQuote(oppList[0]);
        quote.RFO_QuoteTeam__c = quoteTeamRec.Id;
        insert quote;
        
        // Commodity Insert
        List<RFO_Commodity__c> commList = RFO_Utility_Test.createCommodity();
        insert commList;
        
        // Insert Order
        List<Order> orders = RFO_Utility_Test.createNewCarOrders(quote, accList[0], commList[0], prod2);
        insert orders;
        Order orderrec = [SELECT id FROM Order LIMIT 1];
        
        // Insert Project
        RFO_Projects__c proj = new RFO_Projects__c();
        proj.RFO_Account__c = accList[0].Id;
        proj.RFO_Status__c = 'Active';
        proj.Order__c = orderrec.Id;
        proj.Name = 'Test Project';
        proj.RFO_Workstation__c = 'Customer Service';        
        insert proj;
        
        
        // Insert Project_Engineer__c
       // Project_Engineer__c projEng = new Project_Engineer__c();
       // projEng.Engineer__c = UserInfo.getUserId();
       // projEng.Order__c = orderrec.Id;
       // insert projEng;
        
        // Update Project
        List<RFO_Projects__c> lstRP = new List<RFO_Projects__c>();
        Map<Id ,RFO_Projects__c> mapRF = new   Map<Id ,RFO_Projects__c>();
        RFO_Projects__c projupdate = new RFO_Projects__c();
        projupdate = [select id, RFO_Workstation__c,Name, Start_Project_Workflow_Alert__c ,Last_Car_Ship_Date__c,RFO_DemandDriverName__c from RFO_Projects__c limit 1];
        projupdate.RFO_Workstation__c = 'Engineering';
        projupdate.RFO_Account__c = accList[0].Id;
        projupdate.Start_Project_Workflow_Alert__c = false;
        
        update projupdate;
        
        // Update Project
        projupdate = new RFO_Projects__c();
        projupdate = [select id,Name, RFO_Workstation__c, SOW_Proposal_Status__c,RFO_Account__c,Last_Car_Ship_Date__c,RFO_DemandDriverName__c, Start_Project_Workflow_Alert__c  from RFO_Projects__c limit 1];
        projupdate.SOW_Proposal_Status__c = 'Submitted';
        projupdate.Start_Project_Workflow_Alert__c = true;
        update projupdate;
        
        
    }
    
       /* Name: alertEngineersTest2
* Created By: Lakshmi
* Created Date: November 2020
*
*/
    
    public static testMethod void alertEngineersTest2(){
        //Start, Lakshmi
        User userRecord = RFO_Utility_Test.createUserRecord();
        userRecord.RFO_Engineering__c = true;
        userRecord.IsActive = true;
        insert userRecord;
        system.runAs(userRecord) { 
                
            // Product Insert
            Product2 prod2 = RFO_Utility_Test.createProduct();
            prod2.IsActive=true;
            insert prod2;
            
            
            // Account insert
            List<Account> accList = RFO_Utility_Test.createProspectAccounts();
            insert accList;
            
            // Contact Insert
            List<Contact> contList = RFO_Utility_Test.createContact(accList[0]);
            insert contList;
            
            // AccountTeamMember Insert
            
            
            
            
            AccountTeamMember team = new AccountTeamMember();
            team.AccountID = accList[0].Id;
            team.UserId = userRecord.Id;
            team.TeamMemberRole ='Customer Delivery Director';
            insert team;
            
            
            
            // Opportunities insert
            List<Opportunity> oppList = RFO_Utility_Test.createTankOpportunities1(accList[0], contList[0]);
            insert oppList;
            
            // QuoteTeams insert
            RFO_QuoteTeams__c quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
            Database.insert(quoteTeamRec);  
            
            // Quote Insert
            SBQQ__Quote__c quote = RFO_Utility_Test.createQuote(oppList[0]);
            quote.RFO_QuoteTeam__c = quoteTeamRec.Id;
            insert quote;
            
            // Commodity Insert
            List<RFO_Commodity__c> commList = RFO_Utility_Test.createCommodity();
            insert commList;
            
            // Insert Order
            List<Order> orders = RFO_Utility_Test.createNewCarOrders(quote, accList[0], commList[0], prod2);
            insert orders;
            Order orderrec = [SELECT id FROM Order LIMIT 1];
            
            // Insert Project
            RFO_Projects__c proj = new RFO_Projects__c();
            proj.RFO_Account__c = accList[0].Id;
            proj.RFO_Status__c = 'Active';
            proj.Order__c = orderrec.Id;
            proj.Name = 'Test Project';
            proj.RFO_Workstation__c = 'Customer Service';        
            insert proj;
            
            
            // Insert Project_Engineer__c
            Project_Engineer__c projEng = new Project_Engineer__c();
            projEng.Engineer__c = UserInfo.getUserId();
            projEng.Order__c = orderrec.Id;
            Insert projEng;
            
            // Update Project
            List<RFO_Projects__c> lstRP = new List<RFO_Projects__c>();
            Map<Id ,RFO_Projects__c> mapRF = new   Map<Id ,RFO_Projects__c>();
            RFO_Projects__c projupdate = new RFO_Projects__c();
            projupdate = [select id, RFO_Workstation__c,Name, Start_Project_Workflow_Alert__c ,Last_Car_Ship_Date__c,RFO_DemandDriverName__c from RFO_Projects__c limit 1];
            projupdate.RFO_Workstation__c = 'Engineering';
            projupdate.RFO_Account__c = accList[0].Id;
            projupdate.Start_Project_Workflow_Alert__c = false;
            
            update projupdate;
            
            // Update Project
            projupdate = new RFO_Projects__c();
            projupdate = [select id,Name, RFO_Workstation__c, SOW_Proposal_Status__c,RFO_Account__c,Last_Car_Ship_Date__c,RFO_DemandDriverName__c, Start_Project_Workflow_Alert__c  from RFO_Projects__c limit 1];
            projupdate.SOW_Proposal_Status__c = 'Submitted';
            projupdate.Start_Project_Workflow_Alert__c = true;
            update projupdate;
        }
        
        
    }
    /************************
     * Created By: Haseeb
     * Created Date: Nov 23 2020
     * Jira: Alpha-583
     ************************/
    static testMethod void sendSOWBellNotification(){
        // Product Insert
        Product2 prod2 = RFO_Utility_Test.createProduct();
        prod2.IsActive=true;
        insert prod2;
        
        
        // Account insert
        List<Account> accList = RFO_Utility_Test.createProspectAccounts();
        insert accList;
        
        // Contact Insert
        List<Contact> contList = RFO_Utility_Test.createContact(accList[0]);
        insert contList;
        
               
        
        // Opportunities insert
        List<Opportunity> oppList = RFO_Utility_Test.createTankOpportunities1(accList[0], contList[0]);
        insert oppList;
        
        // QuoteTeams insert
        RFO_QuoteTeams__c quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
        Database.insert(quoteTeamRec);  
        
        // Quote Insert
        SBQQ__Quote__c quote = RFO_Utility_Test.createQuote(oppList[0]);
        quote.RFO_QuoteTeam__c = quoteTeamRec.Id;
        insert quote;
        
        // Commodity Insert
        List<RFO_Commodity__c> commList = RFO_Utility_Test.createCommodity();
        insert commList;
        
        // Insert Order
        List<Order> orders = RFO_Utility_Test.createNewCarOrders(quote, accList[0], commList[0], prod2);
        insert orders;
        Order orderrec = [SELECT id FROM Order LIMIT 1];
        
        // Insert Project
        RFO_Projects__c proj = new RFO_Projects__c();
        proj.RFO_Account__c = accList[0].Id;
        proj.RFO_Status__c = 'Active';
        proj.Order__c = orderrec.Id;
        proj.Name = 'Test Project';
        proj.SOW_Proposal_Status__c = 'Submitted';
        test.startTest();
        insert proj;
        test.stopTest();
        
    }
    
    
    
}