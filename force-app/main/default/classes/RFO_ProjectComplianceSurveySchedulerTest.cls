@isTest
private class RFO_ProjectComplianceSurveySchedulerTest {
	static testmethod void testComplianceProjectScheduler(){
        Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
         
        Account ac = new Account();
        ac.Name = 'Test Account 11111';
        ac.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
		ac.Phone = '800-832-5452';          // Phone
		ac.RFO_Region__c = 'Class 1 Railroads';   // Region
		ac.RFO_AccountStatus__c = 'Active';
		//ac.OwnerId = usr1.id;
		insert ac;
		
        
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
        
        for(RFO_Projects__c project : projectList){
            project.Last_Car_Ship_Date__c = system.today() -15;
        }
        
        update projectList;
        
        Test.startTest();
        List<Contact> conList = [Select Id, RFO_ContactRole__c from Contact];
        for(Contact con : conList){
            con.RFO_ContactRole__c = 'Compliance Project Survey Contact';
        }
        update conList;
        
        RFO_ProjectComplianceSurveyScheduler sh1 = new RFO_ProjectComplianceSurveyScheduler();
		String sch = '0 0 2 * * ?'; 
		system.schedule('Send Compliance project survey', sch, sh1); 
        Test.stopTest();
    }
    
}