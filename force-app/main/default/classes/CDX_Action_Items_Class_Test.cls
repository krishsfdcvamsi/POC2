@isTest
public class CDX_Action_Items_Class_Test {
    
    @isTest //(seeAllData=true)
    static void CreateTestData()
    {
        UserRole urole = [SELECT Id FROM UserRole WHERE PortalType != 'CustomerPortal' LIMIT 1];
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Customer Operations'
        ].Id;
        adminUser.UserRoleId = urole.id;    //[SELECT Id FROM UserRole WHERE Name = 'Trinity Super User' LIMIT 1].Id;
        insert adminUser;
        
        System.runAs(adminUser) {
             
            Account testAcc = new Account();
            testAcc.Name = 'testAccount';
            testAcc.RFO_AccountOwner__c = 'Me';
            testAcc.CDX_CopyCDMOnEmail__c = true;
            testAcc.RFO_TASId__c = '8JDYKW2';
            insert testAcc;
			
			AccountTeamMember ateam2 =  RFO_Utility_Test.createAccountTeamMember(UserInfo.getUserId(),testAcc.id );
             ateam2.TeamMemberRole = 'Customer Delivery Manager';
			 insert ateam2;
            
            Contact createCon = new Contact();
            createCon.AccountId= testAcc.Id;
            createCon.LastName = 'Testlast';
            createCon.FirstName = 'Testlast1';
            insert createCon;
            
            profile p = [Select id, name from profile where name = 'CDX Customer'];
            
            //UserRole urole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
            /*
            User testUser = new User();
            //testUser.ContactId = createCon.id;
            testUser.Alias = 'arvv1234';
            testUser.Email='arvqq@testorg.com';
            testUser.EmailEncodingKey='UTF-8';
            testUser.LastName='Testing';
            testUser.LanguageLocaleKey='en_US';
            testUser.LocaleSidKey='en_US'; 
            testUser.ProfileId = p.Id;
            testUser.TimeZoneSidKey='America/Los_Angeles';
            testUser.UserName='arv12304@gmail.com';
            testUser.Lan_Id__c='arvqq-LAN';
            //testUser.UserRoleId = urole.Id;
            insert testUser;*/
            
            Contract testTract = new Contract();
            testTract.Name = 'Test Contract';
            testTract.AccountId = testAcc.id;
            testTract.StartDate = date.today() - 7;
            testTract.Status = 'New';
            insert testTract;
            
            RFO_Rider__c  rider = new RFO_Rider__c();
            rider.RFO_Contract__c = testTract.id;
            rider.RFO_Account__c = testAcc.id;
            //Ride.Name = 'Test Rider';
            rider.RFO_OriginalMaturityDate__c = date.today() - 7;
            rider.RFO_CurrentMaturityDate__c = date.today() + 7;
            rider.RFO_LeaseType__c = 'MANAGEMENT AGREEMENT';
            rider.RFO_RiderDate__c=System.today();
            rider.RFO_RiderRateType__c='Term';
            rider.RFO_AutoRenewalTermTermMonths__c=5;
            rider.RFO_NumberofPayments__c=5;
            rider.RFO_PaymentFrequency__c='Monthly';
            rider.RFO_RenewalDaysNotice__c=5;
            rider.RFO_StartMethod__c='Delivery Date';
            rider.RFO_Term__c=5;
            rider.RFO_TransactionType__c='Lease';
            rider.RFO_UnitofMeasure__c='    per car, per diem';
            rider.RFO_TotalOfCars__c=5;
            rider.RFO_AutoRenewalTermTermMonths__c = 12.21;
            rider.RFO_RiderDate__c = date.today();
            rider.RFO_StartMethod__c = 'Accepted Date';
            rider.RFO_UnitofMeasure__c = 'per car, per month';
            rider.RFO_RiderType__c = 'Net Lease';
            insert rider;
            
            RFO_Projects__c testProj = new RFO_Projects__c();
            testProj.Name = 'Test Project';
            testProj.RFO_Account__c = testAcc.Id;
            testProj.RFO_DemandDriverName__c = 'Compliance';
            testProj.RFO_TotalAssetCount__c = 23;
            testProj.RFO_ProjectId__c= '100';
            testProj.RFO_Status__c = 'Active';
            insert testProj;
            
            test.startTest();
            
            CDX_Schedule__c Sched = new CDX_Schedule__c();
            Sched.Name = 'Test Schedule';
            Sched.CDX_Published_Date__c = date.today() - 7;
            Sched.CDX_Project__c = testProj.id;
            insert Sched;
            
            CDX_Invoice__c Inv = new CDX_Invoice__c();
            Inv.Name = 'Test Invoice';
            Inv.CDX_Status__c = 'Unpaid';
            Inv.CDX_Account__c = testAcc.Id;
            Inv.CDX_Amount_Due__c = 123;
            Inv.CDX_Invoice_Type__c = 'Repairs';
            Inv.CDX_Invoice_Date__c = System.today();
            insert Inv;
            
            //RFO_Project__r.RFO_DemandDriverName__c
            //RFO_Asset__r.RFO_CarType__c
            //RFO_Asset__r.RFO_CarMark__c
            
                     
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        
        Contract con = [SELECT Id, Name FROM Contract LIMIT 1];
        
        RFO_Projects__c Proj = [SELECT Id, Name FROM RFO_Projects__c LIMIT 1];


            Asset testAsset = new Asset();
            testAsset.name = 'testAsset';
            testAsset.AccountId = acc.Id;
            testAsset.RFO_CarType__c = 'Testing car type';
            testAsset.RFO_CarMark__c = 'Testing car mark';
            insert testAsset;
            
            RFO_ShopIncident__c OTMA = new  RFO_ShopIncident__c();
            OTMA.name = 'Test OTMA Service Request';
            OTMA.RFO_Asset__c = testAsset.id;
            OTMA.RFO_Status__c = 'Active'; //Check for useage
            OTMA.RFO_ShopName__c = 'OTMA Testing Center';
            OTMA.CDX_Disposition_Assigned_Date__c = date.today() + 7;
            OTMA.RFO_SIStatus__c = 'OTMA Waiting';
            OTMA.RFO_Customer__c = acc.Id;
            insert OTMA;
            
            CDX_Estimate__c Est = new CDX_Estimate__c();
            Est.Name = 'Test-imate';
            Est.CDX_Status__c = 'Pending';
            Est.CDX_Asset__c = testAsset.id;
            //Est.CDX_Estimated_Amount__c = '123';
            Est.CDX_Date_Notified__c = date.today() - 7;
            Est.CDX_Service_Request__c = OTMA.id;
            Est.CDX_Estimate_Approved__c = date.today() - 7;
            Est.CDX_DetailsToReviewCount__c=1;
            Est.ReimbursableFrom__c = acc.id;
            insert Est;
			//Id newCarChangeReqRecID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RFO_NewCarChangeRequest').getRecordTypeId();
			Id GenReqRecTypID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General_Request').getRecordTypeId();
            Case TestCase = new Case();
			TestCase.RecordTypeId = GenReqRecTypID; // Change Request Record Type 
            TestCase.AccountId = acc.Id;
            TestCase.AssetId = testAsset.id;
            TestCase.Subject = 'TESTING THIS CASE TO SEE IF IT CAN BE PICKED UP BY THE QUERY IN THE TESTING ENVIRONMENT';
            TestCase.Status = 'Waiting on Customer';
            TestCase.Type = 'Invoicing';
            TestCase.ContactId = createCon.Id;
			//TestCase.RFO_OrderID__c = od.Id;
            insert TestCase;

            RFO_ShopIncident__c DispNoRe = new RFO_ShopIncident__c();
            DispNoRe.name = 'Test Disp Service Request no reassignment';
            DispNoRe.RFO_Asset__c = testAsset.id;
            DispNoRe.RFO_Status__c = 'Active'; //Check for useage
            DispNoRe.RFO_ShopName__c = 'Disp Testing Center';
            DispNoRe.CDX_Disposition_Assigned_Date__c = date.today() - 7;
            DispNoRe.RFO_RepairType__c = 'Assignment';
            DispNoRe.CDX_Servicing_Railroad__c = 'Test Road';
            //DispNoRe.CDX_Destination_Consignee__c = NULL;
            DispNoRe.CDX_Disposition_Requested_Date__c = date.today() + 7;
            DispNoRe.RFO_Customer__c = acc.Id;
            insert DispNoRe;
            
            RFO_ShopIncident__c DispRe = new RFO_ShopIncident__c();
            DispRe.name = 'Test Disp Service Request with reassignment';
            DispRe.RFO_Asset__c = testAsset.id;
            DispRe.RFO_Status__c = 'Active'; //Check for useage
            DispRe.RFO_ShopName__c = 'Disp Testing Center';
            DispRe.CDX_Disposition_Assigned_Date__c = date.today() - 7;
            DispRe.RFO_RepairType__c = 'Reassign';
            DispRe.CDX_Servicing_Railroad__c = 'Test Road';
            //DispRe.CDX_Destination_Consignee__c = NULL;
            DispRe.CDX_Disposition_Requested_Date__c = date.today() + 7;
            DispRe.RFO_Customer__c = acc.Id;
            insert DispRe;
            
            RFO_ShopIncident__c DispRe2 = new RFO_ShopIncident__c();
            DispRe2.name = 'Test Disp Service Request with reassignment';
            DispRe2.RFO_Asset__c = testAsset.id;
            DispRe2.RFO_Status__c = 'Active'; //Check for useage
            DispRe2.RFO_ShopName__c = 'Disp Testing Center';
            DispRe2.CDX_Disposition_Assigned_Date__c = date.today() - 8;
            DispRe2.RFO_RepairType__c = 'Cleaning';
            DispRe2.CDX_Servicing_Railroad__c = 'Test Road';
            //DispRe.CDX_Destination_Consignee__c = NULL;
            DispRe2.CDX_Disposition_Requested_Date__c = date.today() + 8;
            DispRe2.RFO_Customer__c = acc.Id;
            insert DispRe2;
            
            RFO_ShopIncident__c DispRe3 = new RFO_ShopIncident__c();
            DispRe3.name = 'Test Disp Service Request with reassignment';
            DispRe3.RFO_Asset__c = testAsset.id;
            DispRe3.RFO_Status__c = 'Active'; //Check for useage
            DispRe3.RFO_ShopName__c = 'Disp Testing Center';
            DispRe3.CDX_Disposition_Assigned_Date__c = date.today() - 6;
            DispRe3.RFO_RepairType__c = 'Cleaning';
            DispRe3.CDX_Servicing_Railroad__c = 'Test Road';
            //DispRe.CDX_Destination_Consignee__c = NULL;
            DispRe3.CDX_Disposition_Requested_Date__c = date.today() + 6;
            DispRe3.RFO_Customer__c = acc.Id;
            insert DispRe3;
            
            RFO_ShopIncident__c DispRe4 = new RFO_ShopIncident__c();
            DispRe4.name = 'Test Disp Service Request with reassignment';
            DispRe4.RFO_Asset__c = testAsset.id;
            DispRe4.RFO_Status__c = 'Active'; //Check for useage
            DispRe4.RFO_ShopName__c = 'Disp Testing Center';
            //DispRe4.CDX_Disposition_Assigned_Date__c = date.today() - 6;
            DispRe4.RFO_RepairType__c = 'Cleaning';
            DispRe4.CDX_Servicing_Railroad__c = 'Test Road';
            //DispRe.CDX_Destination_Consignee__c = NULL;
            //DispRe4.CDX_Disposition_Requested_Date__c = date.today() + 6;
            DispRe4.RFO_Customer__c = acc.Id;
            insert DispRe4;
            //Id GenReqRecTyp2ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General_Request').getRecordTypeId();
            Case TestCase2 = new Case();
            TestCase2.AccountId = acc.Id;
			TestCase2.RecordTypeId = GenReqRecTypID;
            //TestCase2.AssetId = testAsset.id;
            TestCase2.Subject = 'TESTING THIS CASE TO SEE IF IT CAN BE PICKED UP BY THE QUERY IN THE TESTING ENVIRONMENT';
            TestCase2.Status = 'Waiting on Customer';
            TestCase2.Type = 'Disposition';
            TestCase2.contactId = createCon.Id;
            insert TestCase2;
			 	Account acc1 = new Account();
			acc1.Name = 'My Test Account';
			acc1.RFO_AccountOwner__c = 'Me';
			acc1.CDX_CopyCDMOnEmail__c = true;
			insert acc1;
			 RFO_Projects__c proj1 =new RFO_Projects__c();
			proj1.RFO_Account__c = acc.id;
			proj1.Name = 'Test';
				insert proj1;
			
			RFO_ProjectAssetSI__c psia = new RFO_ProjectAssetSI__c();
			psia.RFO_Asset__c = testAsset.id;
			psia.RFO_Project__c = proj1.id;
			psia.Name = 'TestProjectSIAsset';
			insert psia;
            test.stopTest();
        }
    }
    
    static testmethod void TestActionItems(){
        CreateTestData();
                
         profile p = [Select id, name from profile where name = 'CDX Customer'];
        Contact con = [SELECT Id, Name FROM Contact];
        User testUser = new User();
            testUser.ContactId = con.id;
            testUser.Alias = 'arvv1234';
            testUser.Email='arvqq@testorg.com';
            testUser.EmailEncodingKey='UTF-8';
            testUser.LastName='Testing';
            testUser.LanguageLocaleKey='en_US';
            testUser.LocaleSidKey='en_US'; 
            testUser.ProfileId = p.Id;
            testUser.TimeZoneSidKey='America/Los_Angeles';
            testUser.UserName='arv12304@gmail.com';
            testUser.Lan_Id__c='arvqq-LAN';
            //testUser.UserRoleId = urole.Id;
            insert testUser;
        //test.startTest();
        System.runAs(testUser){
            list<RFO_Projects__c> rfo = [SELECT Id,Name,RFO_ProjectId__c FROM RFO_Projects__c];
                Test.setMock(HttpCalloutMock.class, new RFO_HttpCalloutProject_Test());

                    
                  CDX_Action_Items_Class.ActionItems Items = CDX_Action_Items_Class.GetActionItems();
                  
                  Integer Ests = Items.PendingEstimates.size();
                  Integer OTMA = Items.PendingOTMA.size();
                  Integer Disp = Items.OutboundDisposition.size();
                  Integer Sched = Items.AwaitingSchedules.size();
                  Integer Cases = Items.AwaitingCases.size();
                  Integer Invs = Items.InvoicesDue.size();
                  Integer Ride = Items.MaturingRiders.size();
				   CDX_Action_Items_Class.projectCls Items1 = new CDX_Action_Items_Class.projectCls();
                  
                  List<RFO_ShopIncident__c> OutDisp = [SELECT ID, Name, CDX_Asset_Name__c, RFO_Asset__r.RFO_CarType__c, RFO_Asset__r.RFO_CarMark__c, CDX_Service_Request_Link__c, RFO_Asset__c, RFO_Asset__r.Name, CDX_Servicing_Railroad__c, RFO_ShopName__c, CDX_Num_of_Days_Waiting_Disposition__c, RFO_RepairType__c
                                                       FROM RFO_ShopIncident__c];
                  
                  for(RFO_ShopIncident__c a : OutDisp)
                  {
                      system.debug('Disp Id: '+a.id+'   Link: '+a.CDX_Service_Request_Link__c);
                  }
                /*
                  System.debug('Ests>>>'+Ests);
                  system.assertEquals(1, Ests, 'Correct est size');
                  system.assertEquals(1, OTMA, 'Correct otma size');
                  
                  system.assertEquals(1, Sched, 'Correct sched size');
                  system.assertEquals(2, Cases, 'Correct case size');
                  system.assertEquals(1, Invs, 'Correct inv size');
                  system.assertEquals(1, Ride, 'Correct rider size');
                */
          
            
        }
          //test.stopTest();
    }
	static testmethod void TestActionItems1(){
        CreateTestData();
                
         profile p = [Select id, name from profile where name = 'Customer Operations'];
        Contact con = [SELECT Id, Name FROM Contact];
        User testUser = new User();
            //testUser.ContactId = con.id;
            testUser.Alias = 'arvv1234';
            testUser.Email='arvqq@testorg.com';
            testUser.EmailEncodingKey='UTF-8';
            testUser.LastName='Testing';
            testUser.LanguageLocaleKey='en_US';
            testUser.LocaleSidKey='en_US'; 
            testUser.ProfileId = p.Id;
            testUser.TimeZoneSidKey='America/Los_Angeles';
            testUser.UserName='arv123045@gmail.com';
            testUser.Lan_Id__c='arvqq-LAN';
            //testUser.UserRoleId = urole.Id;
            insert testUser;
        //test.startTest();
        System.runAs(testUser){
            list<RFO_Projects__c> rfo = [SELECT Id,Name,RFO_ProjectId__c FROM RFO_Projects__c];
                Test.setMock(HttpCalloutMock.class, new RFO_HttpCalloutProject_Test());

                    
                  CDX_Action_Items_Class.ActionItems Items = CDX_Action_Items_Class.GetActionItems();
                  
                  Integer Ests = Items.PendingEstimates.size();
                  Integer OTMA = Items.PendingOTMA.size();
                  Integer Disp = Items.OutboundDisposition.size();
                  Integer Sched = Items.AwaitingSchedules.size();
                  Integer Cases = Items.AwaitingCases.size();
                  Integer Invs = Items.InvoicesDue.size();
                  Integer Ride = Items.MaturingRiders.size();
				   CDX_Action_Items_Class.projectCls Items1 = new CDX_Action_Items_Class.projectCls();
                  
            
        }
          //test.stopTest();
    }
}