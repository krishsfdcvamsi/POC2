@isTest
global class CDX_EstimateLineItemExtContTest implements HTTPCalloutMock
{
    public static String status;
    global HTTPResponse respond(HTTPRequest request) 
    {
        System.debug('status>>>'+status);
        System.debug('CDXstatus>>>'+CDX_EstimateLineItemExtCont.estimateItemListStatus);
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        if(CDX_EstimateLineItemExtCont.estimateItemListStatus=='CustomerWaiting')
        {
            response.setBody('{ "ExternalId": 1115025, "CDX_Estimate__c": "60607",  "CDX_Repair_Location__c": "C ",  "CDX_Quantity__c": 4.0,  "CDX_Job_Code_Applied__c": "7014",  "CDX_Condition_Code__c": "9 ",  "CDX_Qualifier_Code__c": null, "CDX_Why_Made__c": "09", "CDX_Labor_Charge__c": "544", "CDX_Materials_Miscellaneous_Charge__c": "0",  "CDX_Total_Amount__c": "544",  "CDX_Approved_Rejected_By__c": "Cary Tumlinson", "CDX_Version_Number__c": null,  "CDX_Job_Code_Reviewed__c": "7014",  "CDX_Qualifier__c": null, "CDX_Description__c": "R&R OUTLETS",  "CDX_Comments__c": "Test",  "CDX_Status__c": "CustomerWaiting"}');
        }
        else if(CDX_EstimateLineItemExtCont.estimateItemListStatus=='All')
        {
            response.setBody('{ "ExternalId": 1115025, "CDX_Estimate__c": "60607",  "CDX_Repair_Location__c": "C ",  "CDX_Quantity__c": 4.0,  "CDX_Job_Code_Applied__c": "7014",  "CDX_Condition_Code__c": "9 ",  "CDX_Qualifier_Code__c": null, "CDX_Why_Made__c": "09", "CDX_Labor_Charge__c": "544", "CDX_Materials_Miscellaneous_Charge__c": "0",  "CDX_Total_Amount__c": "544",  "CDX_Approved_Rejected_By__c": "Cary Tumlinson", "CDX_Version_Number__c": null,  "CDX_Job_Code_Reviewed__c": "7014",  "CDX_Qualifier__c": null, "CDX_Description__c": "R&R OUTLETS",  "CDX_Comments__c": "Test",  "CDX_Status__c": "Approved"}');
        }
        if(CDX_EstimateLineItemExtCont.estimateItemListStatus=='Rejected')
        {
            response.setBody('{ "ExternalId": 1115025, "CDX_Estimate__c": "60607",  "CDX_Repair_Location__c": "C ",  "CDX_Quantity__c": 4.0,  "CDX_Job_Code_Applied__c": "7014",  "CDX_Condition_Code__c": "9 ",  "CDX_Qualifier_Code__c": null, "CDX_Why_Made__c": "09", "CDX_Labor_Charge__c": "544", "CDX_Materials_Miscellaneous_Charge__c": "0",  "CDX_Total_Amount__c": "544",  "CDX_Approved_Rejected_By__c": "Cary Tumlinson", "CDX_Version_Number__c": null,  "CDX_Job_Code_Reviewed__c": "7014",  "CDX_Qualifier__c": null, "CDX_Description__c": "R&R OUTLETS",  "CDX_Comments__c": "Test",  "CDX_Status__c": "Rejected"}');
        }
        if(CDX_EstimateLineItemExtCont.estimateItemListStatus=='Approved')
        {
            response.setBody('{ "ExternalId": 1115025, "CDX_Estimate__c": "60607",  "CDX_Repair_Location__c": "C ",  "CDX_Quantity__c": 4.0,  "CDX_Job_Code_Applied__c": "7014",  "CDX_Condition_Code__c": "9 ",  "CDX_Qualifier_Code__c": null, "CDX_Why_Made__c": "09", "CDX_Labor_Charge__c": "544", "CDX_Materials_Miscellaneous_Charge__c": "0",  "CDX_Total_Amount__c": "544",  "CDX_Approved_Rejected_By__c": "Cary Tumlinson", "CDX_Version_Number__c": null,  "CDX_Job_Code_Reviewed__c": "7014",  "CDX_Qualifier__c": null, "CDX_Description__c": "R&R OUTLETS",  "CDX_Comments__c": "Test",  "CDX_Status__c": "Approved"}');    
        }
        
        response.setStatusCode(200);
        return response; 
    }
    
    @testSetup 
    static void EstimateSetup() 
    {
        Account acc=new Account();
        acc.Name='Acc name';
        insert acc;
        
        Contact con=new Contact();
        con.AccountId=acc.Id;
        con.FirstName = 'Test1';
        con.LastName = 'Contact 1234';
        insert con;
        
        Contract contract=new Contract();
        contract.AccountId=acc.Id;
        contract.Status='New';
        insert contract;
        
        Asset asset=new Asset();
        asset.Name='Asset Test';
        asset.AccountId=acc.Id;
        asset.ContactId=con.Id;
        insert asset;
        
        RFO_ShopIncident__c serRequest=new RFO_ShopIncident__c();
        serRequest.Name='Service Test';
        serRequest.RFO_Asset__c=asset.Id;
        serRequest.RFO_Customer__c=acc.id;
        insert serRequest;
    
        RFO_IntegrationLinks__c intCustomSettings= new  RFO_IntegrationLinks__c();
        intCustomSettings.RFO_APILink__c='https://dev-api.trinityrail.com:8431/tst/v1/customer/estimate/api/customers/estimates/123511/lineItems/43497';
        intCustomSettings.name='Estimates_Line_Item';
        insert intCustomSettings;
    }
    
    @isTest
    static void GetAllEstimates()
    {
        status='CustomerWaiting';
        CDX_EstimateLineItemExtCont.estimateItemListStatus='CustomerWaiting';
        Asset a = [SELECT Id, Name, AccountId, ContactId FROM Asset LIMIT 1];    
        RFO_ShopIncident__c sr = [SELECT Id, Name, RFO_Asset__c, RFO_Customer__c FROM RFO_ShopIncident__c LIMIT 1]; 
        
        CDX_Estimate__c estimate=new CDX_Estimate__c();
        estimate.Name='Test Estimate1';
        estimate.CDX_Service_Request__c=sr.Id;
        estimate.CDX_Asset__c=a.Id;
        estimate.Estimate_External_ID__c='60607';
        estimate.CDX_DetailsToReviewCount__c = 2;
        estimate.ReimbursableFrom__c = a.AccountId;
        insert estimate;        
        
        Test.setMock(HttpCalloutMock.class, new CDX_EstimateLineItemExtContTest()); 
        
        Test.startTest();
			CDX_EstimateLineItemExtCont.getAllEstimateLineItemInitial(estimate.id);
        Test.stopTest();
    }
    
    @isTest
    static void GetAllEstimatesApproved()
    {
        status='Approved';
        CDX_EstimateLineItemExtCont.estimateItemListStatus='Approved';
        Asset a = [SELECT Id, Name, AccountId, ContactId FROM Asset LIMIT 1];    
        RFO_ShopIncident__c sr = [SELECT Id, Name, RFO_Asset__c, RFO_Customer__c FROM RFO_ShopIncident__c LIMIT 1]; 
        
        CDX_Estimate__c estimate=new CDX_Estimate__c();
        estimate.Name='Test Estimate1';
        estimate.CDX_Service_Request__c=sr.Id;
        estimate.CDX_Asset__c=a.Id;
        estimate.Estimate_External_ID__c='60607';
        estimate.CDX_DetailsToReviewCount__c = 2;
        estimate.ReimbursableFrom__c = a.AccountId;
        insert estimate;        
        
        Test.setMock(HttpCalloutMock.class, new CDX_EstimateLineItemExtContTest()); 
        
        Test.startTest();
			CDX_EstimateLineItemExtCont.getAllEstimateLineItem(estimate.id, 'Approved');
        Test.stopTest();
    }
    
    @isTest
    static void ApproveEstimates()
    {
        status='CustomerWaiting';
        CDX_EstimateLineItemExtCont.estimateItemListStatus='CustomerWaiting';
        Asset a = [SELECT Id, Name, AccountId, ContactId FROM Asset LIMIT 1];    
        RFO_ShopIncident__c sr = [SELECT Id, Name, RFO_Asset__c, RFO_Customer__c FROM RFO_ShopIncident__c LIMIT 1]; 
        
        CDX_Estimate__c estimate=new CDX_Estimate__c();
        estimate.Name='Test Estimate1';
        estimate.CDX_Service_Request__c=sr.Id;
        estimate.CDX_Asset__c=a.Id;
        estimate.Estimate_External_ID__c='60607';
        estimate.CDX_DetailsToReviewCount__c = 2;
        estimate.ReimbursableFrom__c = a.AccountId;
        insert estimate;        
        
        Test.setMock(HttpCalloutMock.class, new CDX_EstimateLineItemExtContTest()); 
        
        List<CDX_Estimate_Line_Item__x> Ests = CDX_EstimateLineItemExtCont.getAllEstimateLineItem(estimate.id, 'CustomerWaiting');

        Test.startTest();
        	CDX_EstimateLineItemExtCont.approve(Ests, Ests,estimate.id);
        Test.stopTest();
        
    }
    
    @isTest
    static void ApproveAllEstimates()
    {
        status='CustomerWaiting';
        CDX_EstimateLineItemExtCont.estimateItemListStatus='CustomerWaiting';
        Asset a = [SELECT Id, Name, AccountId, ContactId FROM Asset LIMIT 1];    
        RFO_ShopIncident__c sr = [SELECT Id, Name, RFO_Asset__c, RFO_Customer__c FROM RFO_ShopIncident__c LIMIT 1]; 
        
        CDX_Estimate__c estimate=new CDX_Estimate__c();
        estimate.Name='Test Estimate1';
        estimate.CDX_Service_Request__c=sr.Id;
        estimate.CDX_Asset__c=a.Id;
        estimate.Estimate_External_ID__c='60607';
        estimate.CDX_DetailsToReviewCount__c = 2;
        estimate.ReimbursableFrom__c = a.AccountId;
        insert estimate;        
        
        Test.setMock(HttpCalloutMock.class, new CDX_EstimateLineItemExtContTest()); 
        
        List<CDX_Estimate_Line_Item__x> Ests = CDX_EstimateLineItemExtCont.getAllEstimateLineItem(estimate.id, 'CustomerWaiting');
        
        Test.startTest();
        	CDX_EstimateLineItemExtCont.approveAllList(estimate.Id);
        Test.stopTest();
    }
    
    @isTest
    static void RejestInitialEstimates()
    {
        status='CustomerWaiting';
        CDX_EstimateLineItemExtCont.estimateItemListStatus='CustomerWaiting';
        Asset a = [SELECT Id, Name, AccountId, ContactId FROM Asset LIMIT 1];    
        RFO_ShopIncident__c sr = [SELECT Id, Name, RFO_Asset__c, RFO_Customer__c FROM RFO_ShopIncident__c LIMIT 1]; 
        
        CDX_Estimate__c estimate=new CDX_Estimate__c();
        estimate.Name='Test Estimate1';
        estimate.CDX_Service_Request__c=sr.Id;
        estimate.CDX_Asset__c=a.Id;
        estimate.Estimate_External_ID__c='60607';
        estimate.CDX_DetailsToReviewCount__c = 2;
        estimate.ReimbursableFrom__c = a.AccountId;
        insert estimate;        
        
        Test.setMock(HttpCalloutMock.class, new CDX_EstimateLineItemExtContTest()); 
        
        List<CDX_Estimate_Line_Item__x> Ests = CDX_EstimateLineItemExtCont.getAllEstimateLineItem(estimate.id, 'CustomerWaiting');

        Test.startTest();
        	CDX_EstimateLineItemExtCont.rejectInitial(Ests, Ests,estimate.id);
        Test.stopTest();
    }
    
     @isTest
    static void RejectPendingOne()
    {
        status='CustomerWaiting';
        CDX_EstimateLineItemExtCont.estimateItemListStatus='CustomerWaiting';
        Asset a = [SELECT Id, Name, AccountId, ContactId FROM Asset LIMIT 1];    
        RFO_ShopIncident__c sr = [SELECT Id, Name, RFO_Asset__c, RFO_Customer__c FROM RFO_ShopIncident__c LIMIT 1]; 
        
        CDX_Estimate__c estimate=new CDX_Estimate__c();
        estimate.Name='Test Estimate1';
        estimate.CDX_Service_Request__c=sr.Id;
        estimate.CDX_Asset__c=a.Id;
        estimate.Estimate_External_ID__c='60607';
        estimate.CDX_DetailsToReviewCount__c = 2;
        estimate.ReimbursableFrom__c = a.AccountId;
        insert estimate;        
        
        Test.setMock(HttpCalloutMock.class, new CDX_EstimateLineItemExtContTest()); 
        
        List<CDX_Estimate_Line_Item__x> Ests = CDX_EstimateLineItemExtCont.getAllEstimateLineItem(estimate.id, 'CustomerWaiting');

        Test.startTest();
        	CDX_EstimateLineItemExtCont.lineItemWithComments = Ests;
        	for(CDX_Estimate_Line_Item__x est : CDX_EstimateLineItemExtCont.lineItemWithComments)
            {
                est.CDX_Comments__c = 'Testing';
                est.CDX_Estimate__c = estimate.Id;
            }
        System.debug(Ests);
        	CDX_EstimateLineItemExtCont.rejectPendingOne(Ests);
        Test.stopTest();
    }
}