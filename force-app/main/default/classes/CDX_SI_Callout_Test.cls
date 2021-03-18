@isTest
global class CDX_SI_Callout_Test implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"shopIncidentID": 691230}');
        response.setStatusCode(200);
        return response; 
    }
    
     @isTest static void testCallout() {
        //Make Fake Service Request
        
         Account acc = new Account();
        acc.Name = 'The Wayne Foundation';
        acc.RFO_AccountOwner__c = 'Me';
        insert acc;
 
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test123';
        adminUser.Alias = 'Test123';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com.test';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Customer Operations'
        ].Id;
        //adminUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Trinity Super User' LIMIT 1].Id;
        insert adminUser;

        AccountTeamMember act = new AccountTeamMember ();
        act.TeamMemberRole ='Customer Delivery Manager';
        act.UserID = adminUser.Id; 
        act.AccountId = acc.Id;
        insert act;
        
        Asset testAsset = new Asset();
        testAsset.name = 'Kyptonite';
        testAsset.AccountId = acc.id;
        testAsset.RFO_CarType__c = 'Bat mobile';
        testAsset.RFO_CarMark__c = 'Bat';
        testAsset.RFO_TASId__c = '98056';
        insert testAsset;
        
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Customer_Commodity__c' LIMIT 1];
        Customer_Commodity__c com = new Customer_Commodity__c();
        com.RecordTypeId = rt.Id;
        com.CDX_Customer__c = acc.id;
        com.CDX_Is_Car_in_Food_Grade_Service__c = true;
        com.CDX_Is_Car_in_Kosher_Service__c = true;   
        com.CDX_Validated_Date__c = date.today();
        insert com;
         
        RFO_Commodity__c stick = new RFO_Commodity__c();
        insert stick;
         
        Contact con = new Contact();
        con.FirstName = 'Wayne';
        con.LastName = 'Bruce';
        con.Account_Record_Type__c ='RFO_Customer'; 
        //insert con;
         
        CDX_Service_Address_Location__c loc = new CDX_Service_Address_Location__c();
        loc.CDX_Active__c = true;
        loc.CDX_City__c = 'Gotham City';
        loc.CDX_Address__c = '123 Wayne Street';
        loc.CDX_Postal_Code__c = '12345';
        loc.CDX_State__c = 'NJ';
        loc.CDX_Location_Name__c = '10026918';
        insert loc;
         
        CDX_Service_Address_Location__c loc2 = new CDX_Service_Address_Location__c();
        loc2.CDX_Active__c = true;
        loc2.CDX_City__c = 'Space';
        loc2.CDX_Address__c = 'Space';
        loc2.CDX_Postal_Code__c = '1';
        loc2.CDX_State__c = 'Sp';
        loc2.CDX_Location_Name__c = 'Spave';
        insert loc2;

        //Insert
        RFO_ShopIncident__c sr = new  RFO_ShopIncident__c();
        sr.name = 'Insert';
        sr.RFO_Asset__c = testAsset.id;
        sr.RFO_Status__c = 'Active'; //Check for useage
        sr.RFO_ShopName__c = 'Insert';
        sr.CDX_Disposition_Assigned_Date__c = date.today() + 7;
        sr.RFO_SIStatus__c = 'OTMA Waiting';
        sr.RFO_AbatementPercent__c = 0.6;
        sr.RFO_ArrivalDate__c = date.today() + 7;
        sr.RFO_CarStatus__c = 'Loaded';
        sr.CDX_Additional_Emails__c = 'I@am.batman';
        sr.RFO_CreatedBy__c = 'Man Bat';
        sr.CreatedDate = date.today();
        sr.RFO_FreightResponsibility__c = 'Wayne Manor'; 
        sr.RFO_OutboundDispAddress__c = 'Wayne Manor'; 
        sr.RFO_RepairType__c = 'Storage';
        sr.CDX_Primary_Contact__c = con.id;
        sr.CDX_Current_STCC__c = stick.Id;
        sr.RFO_SIStatus__c = 'Cust. Submitted';
        sr.CDX_Current_Customer_Commodity__c = com.id;
		sr.CDX_Current_Location__c = loc.id;
        sr.RFO_Customer__c = acc.Id;
        sr.CDX_Destination_Consignee__c = loc.id;
        sr.CDX_Care_of_Party__c = loc.id;
        sr.RFO_TASLastModifiedBy__c = 'Dick Grayson';
        insert sr;
         
        //Update no SI ID
        RFO_ShopIncident__c sr2 = new  RFO_ShopIncident__c();
        sr2.name = 'Update No Id';
        sr2.RFO_Asset__c = testAsset.id;
        sr2.RFO_Status__c = 'Active'; //Check for useage
        sr2.RFO_ShopName__c = 'Update No Id';
        sr2.CDX_Disposition_Assigned_Date__c = date.today() + 7;
        sr2.RFO_SIStatus__c = 'OTMA Waiting';
        sr2.RFO_AbatementPercent__c = 0.6;
        sr2.RFO_ArrivalDate__c = date.today() + 7;
        sr2.RFO_CarStatus__c = 'Loaded';
        sr2.CDX_Additional_Emails__c = 'I@am.batman';
        sr2.RFO_CreatedBy__c = 'Man Bat';
        sr2.CreatedDate = date.today();
        sr2.RFO_FreightResponsibility__c = 'Wayne Manor'; 
        sr2.RFO_OutboundDispAddress__c = 'Wayne Manor'; 
        sr2.RFO_RepairType__c = 'Storage';
        sr2.CDX_Primary_Contact__c = con.id;
        sr2.CDX_Current_STCC__c = stick.Id;
        sr2.RFO_SIStatus__c = 'Cust. Submitted';
        sr2.CDX_Current_Customer_Commodity__c = com.id;
		sr2.CDX_Current_Location__c = loc.id;
        sr2.RFO_Customer__c = acc.Id;
        sr2.CDX_Destination_Consignee__c = loc.id;
        sr2.CDX_Care_of_Party__c = loc.id;
        sr2.RFO_TASLastModifiedBy__c = 'Jason Todd';
        sr2.CDX_Bypass_Validation__c = true;
        insert sr2;   
         
        //Update SI ID
        RFO_ShopIncident__c sr3 = new  RFO_ShopIncident__c();
        sr3.name = 'Update Id';
        sr3.RFO_Asset__c = testAsset.id;
        sr3.RFO_Status__c = 'Active'; //Check for useage
        sr3.RFO_ShopName__c = 'Update Id';
        sr3.CDX_Disposition_Assigned_Date__c = date.today() + 7;
        sr3.RFO_SIStatus__c = 'OTMA Waiting';
        sr3.RFO_AbatementPercent__c = 0.6;
        sr3.RFO_ArrivalDate__c = date.today() + 7;
        sr3.RFO_CarStatus__c = 'Loaded';
        sr3.CDX_Additional_Emails__c = 'I@am.batman';
        sr3.RFO_CreatedBy__c = 'Man Bat';
        sr3.CreatedDate = date.today();
        sr3.RFO_FreightResponsibility__c = 'Wayne Manor'; 
        sr3.RFO_OutboundDispAddress__c = 'Wayne Manor'; 
        sr3.RFO_RepairType__c = 'Storage';
        sr3.CDX_Primary_Contact__c = con.id;
        sr3.CDX_Current_STCC__c = stick.Id;
        sr3.RFO_SIStatus__c = 'Cust. Submitted';
        sr3.CDX_Current_Customer_Commodity__c = com.id;
		sr3.CDX_Current_Location__c = loc.id;
        sr3.RFO_Customer__c = acc.Id;
        sr3.CDX_Destination_Consignee__c = loc.id;
        sr3.CDX_Care_of_Party__c = loc.id;
        sr3.RFO_TASLastModifiedBy__c = 'Tim Drake';
        sr3.RFO_ShopIncidentID__c = '332196';
        insert sr3;
        
        RFO_ShopIncident__c sr4 = new  RFO_ShopIncident__c();
        sr4.name = 'draft Id';
        sr4.recordtypeId =  Schema.SObjectType.RFO_ShopIncident__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        sr4.RFO_Asset__c = testAsset.id;
        sr4.RFO_Status__c = 'Active'; //Check for useage
        sr4.RFO_ShopName__c = 'Update Id';
        sr4.CDX_Disposition_Assigned_Date__c = date.today() + 7;
        sr4.RFO_SIStatus__c = 'OTMA Waiting';
        sr4.RFO_AbatementPercent__c = 0.6;
        sr4.RFO_ArrivalDate__c = date.today() + 7;
        sr4.RFO_CarStatus__c = 'Loaded';
        sr4.CDX_Additional_Emails__c = 'I@am.batman';
        sr4.RFO_CreatedBy__c = 'Man Bat';
        sr4.CreatedDate = date.today();
        sr4.RFO_FreightResponsibility__c = 'Wayne Manor'; 
        sr4.RFO_OutboundDispAddress__c = 'Wayne Manor'; 
        sr4.RFO_RepairType__c = 'Storage';
        sr4.CDX_Primary_Contact__c = con.id;
        sr4.CDX_Current_STCC__c = stick.Id;
        sr4.RFO_SIStatus__c = 'Cust. Submitted';
        sr4.CDX_Current_Customer_Commodity__c = com.id;
		sr4.CDX_Current_Location__c = loc.id;
        sr4.RFO_Customer__c = acc.Id;
        sr4.CDX_Destination_Consignee__c = loc.id;
        sr4.CDX_Care_of_Party__c = loc.id;
        sr4.RFO_TASLastModifiedBy__c = 'Tim Drake';
        sr4.RFO_ShopIncidentID__c = '332188';
        insert sr4; 
         
        
         
        RFO_ShopIncident__c sr5 = new  RFO_ShopIncident__c();
        sr5.name = 'draft2 Id';
        sr5.recordtypeId =  Schema.SObjectType.RFO_ShopIncident__c.getRecordTypeInfosByName().get('Submitted').getRecordTypeId();
        sr5.RFO_Asset__c = testAsset.id;
        sr5.RFO_Status__c = 'Active'; //Check for useage
        sr5.RFO_ShopName__c = 'Update Id';
        sr5.CDX_Disposition_Assigned_Date__c = date.today() + 7;
        sr5.RFO_SIStatus__c = 'OTMA Waiting';
        sr5.RFO_AbatementPercent__c = 0.6;
        sr5.RFO_ArrivalDate__c = date.today() + 7;
        sr5.RFO_CarStatus__c = 'Loaded';
        sr5.CDX_Additional_Emails__c = 'I@am.batman';
        sr5.RFO_CreatedBy__c = 'Man Bat';
        sr5.CreatedDate = date.today();
        sr5.RFO_FreightResponsibility__c = 'Wayne Manor'; 
        sr5.RFO_OutboundDispAddress__c = 'Wayne Manor'; 
        sr5.RFO_RepairType__c = 'Storage';
        sr5.CDX_Primary_Contact__c = con.id;
        sr5.CDX_Current_STCC__c = stick.Id;
        sr5.RFO_SIStatus__c = 'Cust. Submitted';
        sr5.CDX_Current_Customer_Commodity__c = com.id;
		sr5.CDX_Current_Location__c = loc.id;
        sr5.RFO_Customer__c = acc.Id;
        sr5.CDX_Destination_Consignee__c = loc.id;
        sr5.CDX_Care_of_Party__c = loc.id;
        sr5.RFO_TASLastModifiedBy__c = 'Tim Drake';
        sr5.RFO_ShopIncidentID__c = '332199';
        insert sr5;  
         
        Id cvrt = [SELECT ID, NAME FROM RecordType WHERE sobjecttype = 'ContentVersion' and Name = 'Commodity Document' LIMIT 1].Id;
         
        ContentVersion c = new ContentVersion();
        c.Title = 'Test cv 1';
	    c.PathOnClient = 'cv1.jpg';
	    c.VersionData = Blob.valueOf('Test Content');
	    c.IsMajorVersion = true;
        c.RecordTypeId = cvrt;
        c.Trinity_File_Type__c = 'SDS';
        insert c;
         
        ContentVersion d = new ContentVersion();
        d.Title = 'Test cv 2';
	    d.PathOnClient = 'cv1.jpg';
	    d.VersionData = Blob.valueOf('Test Content');
	    d.IsMajorVersion = true;
        d.RecordTypeId = cvrt;
        d.Trinity_File_Type__c = 'SDS';
        insert d;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                
        ContentDocumentLink a = new ContentDocumentLink();
        a.LinkedEntityId = sr.Id;
        a.shareType = 'V';
        a.ContentDocumentId = documents[0].Id;
        insert a;
         
        ContentDocumentLink b = new ContentDocumentLink();
        b.LinkedEntityId = sr.Id;
        b.shareType = 'V';
        b.ContentDocumentId = documents[1].Id;
        insert b;
         
        RFO_IntegrationLinks__c ServiceRequest = new RFO_IntegrationLinks__c();
        ServiceRequest.RFO_APILink__c='bat.man';
        ServiceRequest.Name = 'ServiceRequest';
        insert ServiceRequest;
         
        RFO_IntegrationLinks__c CustomerCommodity = new RFO_IntegrationLinks__c();
        CustomerCommodity.RFO_APILink__c='bat.man';
        CustomerCommodity.Name = 'CustomerCommodity';
        insert 	CustomerCommodity;
         
    }
    
    @isTest
    static void testPostInsert(){
        testCallout();
        Test.startTest();
        RFO_ShopIncident__c sr = [SELECT Id, Name, RFO_ShopIncidentID__c FROM RFO_ShopIncident__c WHERE RFO_ShopName__c = 'Insert' LIMIT 1];
        RFO_ShopIncident__c sr2 = [SELECT Id, Name, RFO_ShopIncidentID__c FROM RFO_ShopIncident__c WHERE name = 'Draft Id' limit 1];
        
        CDX_SI_Callout_Helper req = new CDX_SI_Callout_Helper(sr.Id);
        String jsoninfo = JSON.serialize(req);
        
        
        	Test.setMock(HttpCalloutMock.class, new CDX_SI_Callout_Test()); 
        	System.debug('Post Callout');
        	CDX_SI_Callout.SIPost(jsoninfo);
            //delete sr2;
              
        try{
          RFO_ShopIncident__c sr3 = [SELECT Id, Name, RFO_ShopIncidentID__c FROM RFO_ShopIncident__c WHERE name = 'Draft2 Id' limit 1];  
          delete sr3;
        }catch(Exception error)
        {
        //system.Assert(error.getMessage().contains('Service Request other than draft cannot be deleted'));
        }
       
        Test.stopTest();  

        
        
       
       
    }
    
    @isTest
    static void testPostUpdate(){
        testCallout();
        Test.startTest();
        RFO_ShopIncident__c sr = [SELECT Id, Name, RFO_ShopIncidentID__c FROM RFO_ShopIncident__c WHERE RFO_ShopName__c = 'Update No Id' LIMIT 1];
        CDX_SI_Callout_Helper req = new CDX_SI_Callout_Helper(sr.Id);
        String jsoninfo = JSON.serialize(req);
        

        
            CDX_Service_Address_Location__c loc2 = [SELECT Id FROM CDX_Service_Address_Location__c WHERE CDX_Location_Name__c = 'Spave'];
            sr.CDX_Destination_Consignee__c = loc2.id;
            sr.CDX_Care_of_Party__c = loc2.id;
            sr.RFO_TASLastModifiedBy__c = 'Jason Todd';
        	sr.CDX_Bypass_Validation__c = true;
        	sr.RFO_LastContents__c = '1234';
            update sr;  
            
            Test.setMock(HttpCalloutMock.class, new CDX_SI_Callout_Test()); 
            System.debug('Post Callout');
            CDX_SI_Callout.SIPost(jsoninfo);
        Test.stopTest();  

        
    }
    @isTest
    static void testPUT(){
        testCallout();
        Test.startTest();
        
        RFO_ShopIncident__c sr = [SELECT Id, Name, RFO_ShopIncidentID__c FROM RFO_ShopIncident__c WHERE RFO_ShopName__c = 'Update Id' LIMIT 1];
        
        CDX_SI_Callout_Helper req = new CDX_SI_Callout_Helper(sr.Id);
        String jsoninfo = JSON.serialize(req);

        
            Test.setMock(HttpCalloutMock.class, new CDX_SI_Callout_Test()); 
            System.debug('Put Callout');
            CDX_SI_Callout.SIPut(jsoninfo);
        
            CDX_Service_Address_Location__c loc2 = [SELECT Id FROM CDX_Service_Address_Location__c WHERE CDX_Location_Name__c = 'Spave'];
            sr.RFO_ShopIncidentID__c = '691231';
            sr.CDX_Destination_Consignee__c = loc2.id;
            sr.CDX_Care_of_Party__c = loc2.id;
            sr.RFO_TASLastModifiedBy__c = 'Jason Todd';
            sr.RFO_OutboundRoutingInformation__c = 'TX-TN-T';
            sr.CDX_Bypass_Validation__c = true;
        	sr.RFO_LastContents__c = '1234';
        
            update sr;  
            
        Test.stopTest();
    }
}