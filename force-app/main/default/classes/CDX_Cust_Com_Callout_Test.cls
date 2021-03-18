@isTest(SeeAllData=true)
global class CDX_Cust_Com_Callout_Test implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('test', '5cd2281f6f8d456baaa5c552d79547c3');
        response.setHeader('test', '9fc0007C0eDF4106825DF517a6fB7592');
        response.setHeader('x-correlation-id', '07fEcd485Ca64A48A63f4990F1a38BAB');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"CustomerCommodityIdTAS": 69420}');
        response.setStatusCode(200);
        system.debug('response'+response);
        return response; 
    }
    
     @isTest static void TestCalloutData() {
        //Make Fake Customer Commodity
        Account acc = new Account();
        acc.Name = 'My Test Account';
        acc.RFO_AccountOwner__c = 'Me';
        acc.CDX_CopyCDMOnEmail__c = true;
        insert acc;
        
        Contact con1 = new contact();
        con1.AccountId = acc.Id;
        con1.FirstName = 'Test';
        con1.LastName = 'Contact 1234';
        con1.Email = 'abcD@test.com';
        con1.CDX_SR_Notification_Preference__c=true;
        insert con1;
        
        Asset testAsset = new Asset();
        testAsset.name = 'Test Asset';
        testAsset.AccountId = acc.id;
        testAsset.RFO_CarType__c = 'Testing car type';
        testAsset.RFO_CarMark__c = 'Testing car mark';
        insert testAsset;
        
        TAS_Picklist__c pick = new TAS_Picklist__c();
        pick.CDX_TAS_Picklist_ID__c = 'Test Id';
        pick.CDX_TAS_Picklist_Reference_Name__c = 'Test Picklist';
        pick.CDX_Value__c = 'Test Value';
        insert pick;
        
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Customer_Commodity__c' LIMIT 1];
        Customer_Commodity__c com = new Customer_Commodity__c();
        com.RecordTypeId = rt.Id;
        com.CDX_Customer__c = acc.id;
        com.CDX_Is_Car_in_Food_Grade_Service__c = true;
        com.CDX_Is_Car_in_Kosher_Service__c = true;       
        com.CDX_Customer_Commodity_Name__c = 'Test Customer Commodity';
        com.CDX_Active__c = true;
        com.CDX_Bottom_Outlet_Valve_Cap_Gasket__c = pick.id;
        com.CDX_Flange_Gasket__c = pick.id;
        com.CDX_Interior_Preparation__c = pick.id;
        com.CDX_Interior_Touch_Up_Type__c = pick.id;
        com.CDX_Interior_Lining_Type__c = pick.id;
        com.CDX_Manway_Gasket__c = pick.id;
        com.CDX_O_Ring__c = pick.id;
        com.CDX_Nitrogen_Pad_Type__c = pick.id;
        com.CDX_Validated_Date__c=System.today();
        com.Name__c='Test';
        insert com;
        com.CDX_Customer_Commodity_Name__c = 'Test Customer CommodityUpdated';
        update com;
        
        CDX_Commodity_Junction__c comJunc=new  CDX_Commodity_Junction__c();
        comJunc.Customer_Commodity__c=com.id;
        comJunc.STCC__c=null;
        insert comJunc;
        
        RFO_ShopIncident__c shopInc1=new  RFO_ShopIncident__c();
        shopInc1.name='Test Service Request1';
        shopInc1.RFO_Asset__c=testAsset.id;
        shopInc1.RFO_Customer__c=acc.id;
        shopInc1.RFO_SIRef__c='22344';
        shopInc1.RFO_ShopName__c='www';
        shopInc1.RFO_Location__c='Location';
        shopInc1.CDX_Primary_Contact__c=con1.id;
        // shopInc.CDX_Primary_Contact__r.email=con.Email;
        insert shopInc1;
        
        RecordType ContentRT = [select Id FROM RecordType WHERE Name='Commodity Document'];
        ContentVersion contentVersionInsert1 = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            Trinity_File_Type__c ='SDS',
            recordTypeId = ContentRT.Id,
            SharingPrivacy='N'
            
        );
        insert contentVersionInsert1;
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVersionInsert1.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        
        contentlink.ShareType= 'V';
        contentlink.LinkedEntityId = com.Id; 
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
    }
    
    @isTest static void testCallout() {
        //Make Fake Customer Commodity
        Account acc = new Account();
        acc.Name = 'My Test Account';
        acc.RFO_AccountOwner__c = 'Me';
        acc.CDX_CopyCDMOnEmail__c = true;
        insert acc;
        
        Contact con1 = new contact();
        con1.AccountId = acc.Id;
        con1.FirstName = 'Test';
        con1.LastName = 'Contact 1234';
        con1.Email = 'abcD@test.com';
        con1.CDX_SR_Notification_Preference__c=true;
        insert con1;
        
        Asset testAsset = new Asset();
        testAsset.name = 'Test Asset';
        testAsset.AccountId = acc.id;
        testAsset.RFO_CarType__c = 'Testing car type';
        testAsset.RFO_CarMark__c = 'Testing car mark';
        insert testAsset;
        
        TAS_Picklist__c pick = new TAS_Picklist__c();
        pick.CDX_TAS_Picklist_ID__c = 'Test Id';
        pick.CDX_TAS_Picklist_Reference_Name__c = 'Test Picklist';
        pick.CDX_Value__c = 'Test Value';
        insert pick;

        Customer_Commodity__c com = new Customer_Commodity__c();
        com.RecordTypeId = Schema.SObjectType.Customer_Commodity__c.getRecordTypeInfosByName().get('Tank Car').getRecordTypeId();
        com.CDX_Customer__c = acc.id;
        com.CDX_Is_Car_in_Food_Grade_Service__c = true;
        com.CDX_Is_Car_in_Kosher_Service__c = true;       
        com.CDX_Customer_Commodity_Name__c = 'Test Customer Commodity';
        com.CDX_Active__c = true;
        com.CDX_Bottom_Outlet_Valve_Cap_Gasket__c = pick.id;
        com.CDX_Flange_Gasket__c = pick.id;
        com.CDX_Interior_Preparation__c = pick.id;
        com.CDX_Interior_Touch_Up_Type__c = pick.id;
        com.CDX_Interior_Lining_Type__c = pick.id;
        com.CDX_Manway_Gasket__c = pick.id;
        com.CDX_O_Ring__c = pick.id;
        com.CDX_Nitrogen_Pad_Type__c = pick.id;
        com.CDX_Validated_Date__c=System.today();
        insert com;
        com.CDX_Customer_Commodity_Name__c = 'Test Customer CommodityUpdated';
        update com;
        
        CDX_Commodity_Junction__c comJunc=new  CDX_Commodity_Junction__c();
        comJunc.Customer_Commodity__c=com.id;
        comJunc.STCC__c=null;
        insert comJunc;
        
        RFO_ShopIncident__c shopInc1=new  RFO_ShopIncident__c();
        shopInc1.name='Test Service Request1';
        shopInc1.RFO_Asset__c=testAsset.id;
        shopInc1.RFO_Customer__c=acc.id;
        shopInc1.RFO_SIRef__c='22344';
        shopInc1.RFO_ShopName__c='www';
        shopInc1.RFO_Location__c='Location';
        shopInc1.CDX_Primary_Contact__c=con1.id;
        // shopInc.CDX_Primary_Contact__r.email=con.Email;
        insert shopInc1;
        
        RecordType ContentRT = [select Id FROM RecordType WHERE Name='Commodity Document'];
        ContentVersion contentVersionInsert1 = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            Trinity_File_Type__c ='SDS',
            recordTypeId = ContentRT.Id,
            SharingPrivacy='N'
            
        );
        insert contentVersionInsert1;
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVersionInsert1.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        
        contentlink.ShareType= 'V';
        contentlink.LinkedEntityId = com.Id; 
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        System.debug('Test Class ID: '+com.id);
        CDX_Cust_Com_Callout_Helper req = new CDX_Cust_Com_Callout_Helper(com.id);
        
        System.debug('req: '+req);
        String jsoninfo = JSON.serialize(req);
        System.debug('jsoninfo: '+jsoninfo);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CDX_Cust_Com_Callout_Test()); 
            // This causes a fake response to be sent
            // from the class that implements HttpCalloutMock. 
            System.debug('Customer Community Post Callout');
            CDX_Cust_Com_Callout.CustComPost(jsoninfo);
            System.debug(' ');
            System.debug(' ');
            System.debug('Customer Community Put Callout');
            CDX_Cust_Com_Callout.CustComPut(jsoninfo);
            Test.stopTest(); 
    }
    
    @isTest static void UpdateNoId()
    { 
        TestCalloutData();
        Customer_Commodity__c comod = [SELECT Id, Name__c FROM Customer_Commodity__c LIMIT 1];
        comod.Name__c = NULL;
        comod.CDX_Validated_Date__c = System.today();
        update comod;
        
        System.debug('Test Class ID: '+comod.id);
        CDX_Cust_Com_Callout_Helper req = new CDX_Cust_Com_Callout_Helper(comod.id);
        
        System.debug('req: '+req);
        String jsoninfo = JSON.serialize(req);
        System.debug('jsoninfo: '+jsoninfo);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CDX_Cust_Com_Callout_Test()); 
            System.debug('Customer Community Put Callout');
            CDX_Cust_Com_Callout.CustComPut(jsoninfo);
        Test.stopTest(); 
    }
}