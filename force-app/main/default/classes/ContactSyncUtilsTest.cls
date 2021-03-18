@isTest
global class ContactSyncUtilsTest implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"success": true}');
        response.setStatusCode(200);
        return response; 
    }
    
    @testSetup
    static void createTestData() {
        Account testAcc = new Account();
        testAcc.Name = 'testAccount';
        testAcc.RFO_AccountOwner__c = 'Me';
        testAcc.CDX_CopyCDMOnEmail__c = true;
        testAcc.RFO_TASID__c = '123456';
        insert testAcc;
        
        Contact cont = new Contact();
        cont.AccountId= testAcc.Id;
        cont.LastName = 'Testlast';
        cont.FirstName = 'Testlast1';
        cont.RFO_Status__c = 'Active';
        cont.Title = 'Mr';
        cont.RFO_NickName__c = 'Bob';
        cont.Phone = '999 999 9999'; 
        cont.OtherPhone = '888 888 8888'; 
        cont.Fax = '111 111 1111'; 
        cont.mobilePhone = '777 777 7777';
        cont.Email = 'test@test.com'; 
        cont.CDX_EInvoice__c = true;
        cont.CDX_InvoiceType__c = 'Rental;Repairs;Mileage;Modification';
        cont.CDX_FileFormat__c = 'Text (.txt);PDF (.pdf);AAR Format (.dat);MS Excel (.xls);New MS Excel (.xlsx)'; 
        cont.RFO_ContactRole__c = 'Sales - Executive';
        cont.Customer_Interests__c = 'Billing';
        insert cont;
    }
  
    static testmethod void testCreateContact() {
        Test.setMock(HttpCalloutMock.class, new MockCreateContactResponseGenerator()); 
        Contact con = [SELECT Id, firstName, lastName, Email, Account.RFO_TASID__c, RFO_NickName__c, RFO_ContactId__c, Title, 
                       Phone, OtherPhone, Fax, MobilePhone, CDX_EInvoice__c, CDX_InvoiceType__c, CDX_FileFormat__c, Customer_Interests__c, RFO_Status__c 
                       FROM Contact];
        
        String json = ContactSyncUtils.createJSON(con,'create'); 
        system.debug('json is : ' + json); 
        ContactSyncUtils.syncContact(con.Id, 'create'); 
    }
    
    static testmethod void testUpdateContactDiffRole() {
		Test.setMock(HttpCalloutMock.class, new MockCreateContactResponseGenerator()); 
        Contact con = [SELECT Id, firstName, lastName, Email, Account.RFO_TASID__c, RFO_NickName__c, RFO_ContactId__c, Title, Customer_Interests__c,
                       Phone, OtherPhone, Fax, MobilePhone, CDX_EInvoice__c, CDX_InvoiceType__c, CDX_FileFormat__c, RFO_ContactRole__c, RFO_Status__c
                       FROM Contact];
        system.debug('OG ROLE: '+con.RFO_ContactRole__c);
        con.RFO_ContactRole__c = 'Legal Contact;Field Services Contact';
        con.Customer_Interests__c = 'Disposition';
        con.RFO_Status__c = 'Active';
        con.CDX_EInvoice__c = false;
        con.RFO_ContactId__c = '123456';
        update con;
        
        Contact con2 = [SELECT Id, firstName, lastName, Email, Account.RFO_TASID__c, RFO_NickName__c, RFO_ContactId__c, Title, Customer_Interests__c,
                       Phone, OtherPhone, Fax, MobilePhone, CDX_EInvoice__c, CDX_InvoiceType__c, CDX_FileFormat__c, RFO_ContactRole__c, RFO_Status__c 
                       FROM Contact];
        system.debug('OG ROLE: '+con2.RFO_ContactRole__c);
        
        String json = ContactSyncUtils.createJSON(con,'create'); 
        system.debug('json is : ' + json); 
        ContactSyncUtils.syncContact(con.Id, 'Update'); 
    }
    
     static testmethod void testUpdateContactNoRole() {
		Test.setMock(HttpCalloutMock.class, new MockCreateContactResponseGenerator()); 
        Contact con = [SELECT Id, firstName, lastName, Email, Account.RFO_TASID__c, RFO_NickName__c, RFO_ContactId__c, Title, Customer_Interests__c,
                       Phone, OtherPhone, Fax, MobilePhone, CDX_EInvoice__c, CDX_InvoiceType__c, CDX_FileFormat__c, RFO_ContactRole__c, RFO_Status__c
                       FROM Contact];
        system.debug('OG ROLE: '+con.RFO_ContactRole__c);
        con.RFO_ContactRole__c = NULL;
        con.RFO_Status__c = 'Active';
        con.Customer_Interests__c = 'Disposition';
        con.CDX_EInvoice__c = false;
        con.RFO_ContactId__c = '123456';
        update con;
        
        Contact con2 = [SELECT Id, firstName, lastName, Email, Account.RFO_TASID__c, RFO_NickName__c, RFO_ContactId__c, Title, Customer_Interests__c,
                       Phone, OtherPhone, Fax, MobilePhone, CDX_EInvoice__c, CDX_InvoiceType__c, CDX_FileFormat__c, RFO_ContactRole__c, RFO_Status__c
                       FROM Contact];
        system.debug('OG ROLE: '+con2.RFO_ContactRole__c);
        
        String json = ContactSyncUtils.createJSON(con,'create'); 
        system.debug('json is : ' + json); 
        ContactSyncUtils.syncContact(con.Id, 'Update'); 
    }
    
    
    static testmethod void testPqCrushKeyStakeHolderDelete(){
        User userRec = createUser();
        User userRec1 = createUser1();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
		
        system.runAs(userRec){
		   account ac =new account();
		   ac.Name = 'BNSF';  // Account Name
		   ac.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
		   ac.Phone = '800-832-5452';          // Phone
		   ac.RFO_Region__c = 'Class 1 Railroads';   // Region
		   ac.RFO_AccountStatus__c = 'Active';
		   ac.OwnerId = userRec1.id;
		   database.insert(ac,false);
		   accList.add(ac);
		   
		   Contact cnt = new Contact(
			   FirstName = 'Tony',         // FirstName
			   LastName = 'Alen',            // LastName
			   RFO_Status__c = 'Active',                                               // Status
			   Email = 'Tony.Alen@trinity.net',                                  // Email
			   AccountId = accList[0].id,                                          // Account Name
			   Phone = '(806) 381-0261',                                               // Phone
			   RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
			   Fax = '(806) 371-7528'                                                 // Fax
		   );
		   database.insert(cnt,false);
            conList.add(cnt);
        }
        
        pqcrush__Account_Plan__c accPlan = new pqcrush__Account_Plan__c(
        	Name='Testing',
        	pqcrush__Account__c = accList[0].id,
        	pqcrush__Status__c = 'Open',
        	pqcrush__Goal__c = 'Save'    
        );
        database.insert(accPlan,false);
        
        pqcrush__Key_Stakeholder__c keystake = new pqcrush__Key_Stakeholder__c(
        	pqcrush__Account_Plan__c = accPlan.id,
            pqcrush__Contact__c = conList[0].id,
            pqcrush__Influence__c = 'Low Influence'
        );
       database.insert(keystake,false);
       
		Contact con = conList[0];
		con.RFO_Status__c = 'Inactive';
        
        system.runAs(userRec){
        database.update(con,false);
        }
		
			        
    }
    
    private static User createUser() {
    	Profile profileId = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
		Profile profileId1 = [Select Id, Name from Profile where Name =: 'Sales Customer' limit 1];
        UserRole roleId =[Select Id,Name from UserRole where Name =: 'Commercial-30' limit 1];
        UserRole salesReproleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
        User usr = new User();
	   usr.LastName = 'LIVESON';
       usr.FirstName='JASO';
       usr.Alias = 'jsiv';
       usr.Email = 'jaso.liveson@example.com';
       usr.Username = 'jaso.liveson@example.com';
       usr.ProfileId = profileId.id;
       usr.TimeZoneSidKey = 'GMT';
       usr.LanguageLocaleKey = 'en_US';
       usr.EmailEncodingKey = 'UTF-8';
       usr.LocaleSidKey = 'en_US';
       usr.UserRoleId = roleId.id;
	   database.insert(usr,false);
	   return usr;
    }    
        
    private static User createUser1() {
    	Profile profileId = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
		Profile profileId1 = [Select Id, Name from Profile where Name =: 'Sales Customer' limit 1];
        UserRole roleId =[Select Id,Name from UserRole where Name =: 'Commercial-30' limit 1];
        UserRole salesReproleId =[Select Id,Name from UserRole where Name =: 'Sales Customer-30' limit 1];
       User usr1 = new User();
	   usr1.LastName = 'Daniel';
       usr1.FirstName='Russ';
       usr1.Alias = 'Daru';
       usr1.Email = 'Daniel.Russ@example.com';
       usr1.Username = 'Daniel.Russ@example.com';
       usr1.ProfileId = profileId.id;
       usr1.TimeZoneSidKey = 'GMT';
       usr1.LanguageLocaleKey = 'en_US';
       usr1.EmailEncodingKey = 'UTF-8';
       usr1.LocaleSidKey = 'en_US';
       usr1.UserRoleId = salesReproleId.id;
	   //usr1.managerId = usr.id;
	   database.insert(usr1,false);
	   return usr1;
    }    
    
}