@isTest
public class CDX_ContentDocumentLinkTriggerTest
{
    static testmethod void ContentDocumentLinkTriggerTest()
    {
        Account acc=new Account();
        acc.Name='testAccount';
        insert acc;
        System.debug('account'+acc);
        Asset testAsset=new Asset();
        testAsset.name='testAsset';
        testAsset.AccountId=acc.id;
        insert  testAsset;
        System.debug('asset'+testAsset);
        RFO_ShopIncident__c shopInc=new  RFO_ShopIncident__c();
        shopInc.name='Test Service Request';
        shopInc.RFO_Asset__c=testAsset.id;
        shopInc.RFO_Customer__c=acc.id;
        insert shopInc;
        System.debug('service request'+shopInc);
        Customer_Commodity__c ccSpec = new Customer_Commodity__c();
        ccSpec.CDX_Customer__c = acc.id;
        insert ccSpec;
        CollaborationGroup cg = new CollaborationGroup(Name = 'Trinity Development', CollaborationType = 'Public');
        insert cg;
        RecordType ContentRT = [select Id FROM RecordType WHERE Name='Other' LIMIT 1];
        System.debug(' RecordType'+ContentRT);
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            Trinity_File_Type__c = 'OTMA',
            recordTypeId = ContentRT.Id,
            SharingPrivacy='N'
            //ContentDocumentId='06956000000eUFQAA2'
        );
        insert contentVersionInsert;
        
        ContentVersion v = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id];
        List<ContentDocumentLink> itemsToProcess = new List<ContentDocumentLink>();
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = shopInc.id;
        contentlink.contentdocumentid = v.ContentDocumentId;
        contentlink.ShareType = 'V';
        contentlink.Visibility = 'AllUsers'; 
        
        
        /*
        if (!String.valueOf(contentlink.LinkedEntityId).startsWith('005'))
        {
            itemsToProcess.add(contentlink);
        }
		*/
        itemsToProcess.add(contentlink);
        
        ContentVersion contentVersionInsert2 = new ContentVersion(
            Title = 'Test2',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            Trinity_File_Type__c = 'Cleaning Certification',
            recordTypeId = ContentRT.Id,
            SharingPrivacy='N'
            //ContentDocumentId='06956000000eUFQAA2'
        );
        
        insert contentVersionInsert2;
        
        ContentVersion v2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert2.Id];
        ContentDocumentLink contentlink2 = new ContentDocumentLink();
        contentlink2.LinkedEntityId = shopInc.id;
        contentlink2.contentdocumentid = v2.ContentDocumentId; 
        contentlink2.ShareType = 'V';
        contentlink2.Visibility = 'AllUsers'; 
        
        ContentDocumentLink contentlink3 = new ContentDocumentLink();
        contentlink3.LinkedEntityId = ccSpec.id;
        contentlink3.contentdocumentid = v.ContentDocumentId;
        contentlink3.ShareType = 'V';
        contentlink3.Visibility = 'AllUsers'; 
        
        /*
        if (!String.valueOf(contentlink2.LinkedEntityId).startsWith('005'))
        {
            itemsToProcess.add(contentlink2);
        }
        */
        itemsToProcess.add(contentlink2);
        system.debug('content document link: ' + contentlink2.id); 
        system.debug('linked entity id: ' + contentlink2.LinkedEntityId); 
        
        itemsToProcess.add(contentlink3);
        system.debug('content document link: ' + contentlink3.id); 
        system.debug('linked entity id: ' + contentlink3.LinkedEntityId); 
        
        Test.startTest();
        insert itemsToProcess;
    
        Test.stopTest();
    }


    //Start - Alpha-23, Haseeb, Test method for ValidateCdlRT Method, Created Date: September 2020
    static testMethod void testValidateCdlRT(){
        Product2 p = new product2();
        p.Name = 'Test';
        p.HasBaseCarSpec__c = true;
        p.IsActive = true;
        insert p;
        
        ContentVersion CV = new ContentVersion();
        CV.Title = 'Test';
        CV.VersionData = Blob.valueOf('Test Content');
        CV.PathOnClient = 'test.txt';
        CV.Trinity_File_Type__c = 'Other';
        insert CV;
        string CDId = [select contentDocumentid from contentversion where id =: cv.Id].contentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = CDId;
        cdl.LinkedEntityId = p.Id;
        try{
            insert cdl;
        }
        catch(exception e){
            system.debug('~ Exception Message :'+e.getMessage());
            system.assertEquals(e.getMessage().contains('Please upload files only for Base Car Product of Type Base Car Spec'), true);
        }
    }
    //End - Alpha-23
	//Start, Alpha - 741, Haseeb, tests to validate if the uploaded BOM Document check box is set to true when a Document of type BOM document is uploaded to asset file sobject
    static testMethod void testUpdateAssetBOMFile(){
        //Create Account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        account acc1 =new account();
        acc1.Name = 'BNSF';  // Account Name
        acc1.RecordTypeId = recordTypeIdAccount;           // Account Record Type
        acc1.Phone = '800-832-5452';         
        insert acc1;
        
        //Create Commodity
        RFO_Commodity__c commodity = new RFO_Commodity__c();
        commodity.Name = 'TESTCOMMODITY';
        commodity.RFO_Active__c = True;
        insert commodity;
        
        //Create Product
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.IsActive = True;
        insert p;
        Pricebook2 pbook = new Pricebook2(
            Name = 'Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        PricebookEntry pbe = new PricebookEntry(pricebook2id=pbook.id, product2id=p.id,unitprice=2.0, isActive=true);
        insert pbe;
        Database.update(pbook);        
        //Create Order
        order o = new order();
        o.RecordTypeId = Schema.SObjectType.order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        o.AccountId = acc1.id;
        o.Type = 'Lease';
        o.Status = 'Initiated';
        o.RFO_ProposalRequired__c = 'Yes';
        o.RFO_SignedProposalDate__c = system.today();
        o.RFO_TankorFreight__c = 'Tank';
        o.EffectiveDate = system.today();
        o.RFO_JobCostDetails__c = 'Test';
        o.RFO_CarType__c = '200# CI ';
        o.RFO_LeaseRate__c = 1;
        o.RFO_LeaseTerms__c = 1;
        o.RFO_Commodity_lookup__c = commodity.Id;
        o.RFO_Product__c = p.Id;
        o.RFO_Quantity__c = 1;
        o.RFO_SubType__c = 'Full Service';
        o.RFO_OrderReviewMeetingDate__c = system.today();
        insert o;
        
        RFO_Asset_File__c af = new RFO_Asset_File__c();
        af.RFO_OrderNumber__c = o.Id;
        af.Name = 'Test 1';
        af.RFO_ProductDivision__c = 'Tank';
        af.RFO_Quantity__c = 1;
        af.RFO_RiderLeaseType__c = 'Full Service';
        insert af;
        
        ContentVersion CV = new ContentVersion();
        CV.Title = 'Test';
        CV.VersionData = Blob.valueOf('Test Content');
        CV.PathOnClient = 'test.txt';
        CV.RecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName().get('Asset File').getRecordTypeId();
        CV.Trinity_File_Type__c = 'BOM Document';
        insert CV;
        
        string CDId = [select contentDocumentid from contentversion where id =: cv.Id].contentDocumentId;
        
        Test.startTest();
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = CDId;
        cdl.LinkedEntityId = af.Id;
        insert cdl;
        RFO_Asset_File__c assetFile = [select id,BOM_File_Uploaded__c from RFO_Asset_File__c where id =: af.Id];
        system.assertEquals(True, assetFile.BOM_File_Uploaded__c);
        Test.stopTest();
        
        
    }
    //End, Alpha- 741, Haseeb


}