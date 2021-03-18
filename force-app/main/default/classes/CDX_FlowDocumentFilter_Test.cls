@isTest
public class CDX_FlowDocumentFilter_Test {
	
    static testmethod void testFlowDocument() 
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RFO_AccountOwner__c = 'Me';
        acc.CDX_CopyCDMOnEmail__c = true;
        insert acc;
        
        Customer_Commodity__c custcom = new Customer_Commodity__c();
        custcom.CDX_Customer__c = acc.Id;
        custcom.Name__c = 'Test Customer Commodity';
        insert custcom;

        ContentVersion c = new ContentVersion();
        c.Title = 'Test cv 1';
	    c.PathOnClient = 'cv1.jpg';
	    c.VersionData = Blob.valueOf('Test Content');
	    c.IsMajorVersion = true;
        c.Trinity_File_Type__c = 'SDS';
        insert c;
        
        ContentVersion d = new ContentVersion();
        d.Title = 'Test cv 1';
	    d.PathOnClient = 'cv1.jpg';
	    d.VersionData = Blob.valueOf('Test Content');
	    d.IsMajorVersion = true;
        d.Trinity_File_Type__c = 'SDS';
        insert d;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                
        ContentDocumentLink a = new ContentDocumentLink();
        a.LinkedEntityId = acc.Id;
        a.shareType = 'V';
        a.ContentDocumentId = documents[0].Id;
        insert a;
        
        ContentDocumentLink b = new ContentDocumentLink();
        b.LinkedEntityId = custcom.Id;
        b.shareType = 'V';
        b.ContentDocumentId = documents[1].Id;
        insert b;
        
		List<ContentDocumentLink> CDL = new List<ContentDocumentLink>();
        CDL.add(b);
        CDL.add(a);
        
        List<List<ContentDocumentLink>> CDLL =  new List<List<ContentDocumentLink>>();
        CDLL.add(CDL);
        
        List<List<ContentVersion>> CVL = new  List<List<ContentVersion>>();
        
        Test.startTest();
        	CVL = CDX_FlowDocumentFilter.FilterDocuments(CDLL);
        Test.stopTest();
        
        system.assertEquals(CVL.size(), 1);
        system.assertEquals(CVL[0].size(), 2);
        
        Boolean AccLoc = false;
        Boolean CustComLoc = false;
        for (ContentVersion cv : CVL[0])
        {
            if(cv.CDX_File_Location__c == 'Account')
                AccLoc = True;
            if(cv.CDX_File_Location__c == 'Customer Commodity')
                CustComLoc = True;
        }
        
        system.assertEquals(AccLoc, True);
        system.assertEquals(CustComLoc, True);
        
    }
}