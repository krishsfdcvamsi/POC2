@isTest
private class RFO_LCDataSourceConnection_Test{
    
    static testMethod void testDataSourceConn() {
        RFO_ExternalDataSourceProvider ex= new RFO_ExternalDataSourceProvider();
        List<DataSource.AuthenticationCapability> au= ex.getAuthenticationCapabilities();
        ex.getCapabilities();
        DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
        
        ex.getConnection(connectionParams);
        RFO_LCDataSourceConnection da= new RFO_LCDataSourceConnection(connectionParams);
        da.sync();
        DataSource.QueryContext context = new DataSource.QueryContext();
        
        
    }
    
    @isTest
    static void testQuery() {
        
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = 'RFO_AssetID';
        filter.columnValue ='280725';
        filter.subfilters = null;
        filter.tableName = 'RFO_GVP';
        
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'RFO_GVP';
        tableSelection.filter = filter;
        
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.TableSelection = tableSelection;
        DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
        RFO_IntegrationLinks__c cc= new RFO_IntegrationLinks__c();
        cc.Name='GVP';
        cc.RFO_APILink__c='http://example.com/example/test';
        insert cc;       
        
        RFO_HttpConnectionMock mock = new RFO_HttpConnectionMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        RFO_LCDataSourceConnection connection = new RFO_LCDataSourceConnection(connectionParams);
        connection.getData('RFO_GVP','1636' ,'TASID');  
        
        
        Test.stopTest();
       // system.assertEquals(result.tableName,'RFO_GVP');
        //  RFO_GVP__x GG= NEW RFO_GVP__x();
        // GG= [SELECT Id, ExternalId, DisplayUrl, RFO_Carrier__c, RFO_AssetID__c, RFO_EventStation__c FROM RFO_GVP__x WHERE RFO_AssetID__c='450462'];
        
        
        
    }
    @isTest
    static void testQueryInvoice() {
        
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = 'ExtelId';
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'RFO_InvoiceExternal';
        tableSelection.filter = filter;
        
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.TableSelection = tableSelection;
        DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
        RFO_IntegrationLinks__c cc= new RFO_IntegrationLinks__c();
        cc.Name='Invoice';
        cc.RFO_APILink__c='http://example.com/example/test';
        insert cc;       
        
        RFO_HttpConnectionMock mock = new RFO_HttpConnectionMock();
        Test.setMock(HttpCalloutMock.class, mock);        
        Test.startTest();
        RFO_LCDataSourceConnection connection = new RFO_LCDataSourceConnection(connectionParams);
       // DataSource.TableResult result = connection.query(context);  
       connection.getData('RFO_InvoiceExternal','1636' ,'TASID');  
        Test.stopTest(); 
    }
    
    
    
    
     @isTest
    static void testQueryAsset() {
        
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = 'ExtelId';
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'RFO_AssetExternal';
        tableSelection.filter = filter;
        
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.TableSelection = tableSelection;
        DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
        RFO_IntegrationLinks__c cc= new RFO_IntegrationLinks__c();
        cc.Name='Asset';
        cc.RFO_APILink__c='http://example.com/example/test';
        insert cc;       
        
        RFO_HttpConnectionMock mock = new RFO_HttpConnectionMock();
        Test.setMock(HttpCalloutMock.class, mock);        
        Test.startTest();
        RFO_LCDataSourceConnection connection = new RFO_LCDataSourceConnection(connectionParams);
        // DataSource.TableResult result = connection.query(context);  
        connection.getData('RFO_AssetExternal','1636' ,'TASID');  
        Test.stopTest(); 
    }
     /* @isTest
    static void testQueryTestHistory() {
        
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = 'ExtelId';
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'RFO_TestHistoryExternal';
        tableSelection.filter = filter;
        
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.TableSelection = tableSelection;
        DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
        RFO_IntegrationLinks__c cc= new RFO_IntegrationLinks__c();
        cc.Name='TestHistory';
        cc.RFO_APILink__c='http://example.com/example/test';
        insert cc;       
        RFO_HttpConnectionMock mock = new RFO_HttpConnectionMock();
        Test.setMock(HttpCalloutMock.class, mock);        
        Test.startTest();
        RFO_LCDataSourceConnection connection = new RFO_LCDataSourceConnection(connectionParams);
       // DataSource.TableResult result = connection.query(context);  
       connection.getData('RFO_TestHistoryExternal','1636' ,'TASID');  
        Test.stopTest(); 
    }*/
     @isTest
    static void testQueryInvoiceType() {
        
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = 'ExtelId';
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'RFO_InvoiceType';
        tableSelection.filter = filter;
        
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.TableSelection = tableSelection;
        DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
        RFO_IntegrationLinks__c cc= new RFO_IntegrationLinks__c();
        cc.Name='InvoiceType';
        cc.RFO_APILink__c='http://example.com/example/test';
        insert cc;       
        RFO_HttpConnectionMock mock = new RFO_HttpConnectionMock();
        Test.setMock(HttpCalloutMock.class, mock);        
        Test.startTest();
        RFO_LCDataSourceConnection connection = new RFO_LCDataSourceConnection(connectionParams);
       // DataSource.TableResult result = connection.query(context);  
       connection.getData('RFO_InvoiceType','1636' ,'TASID');  
        Test.stopTest(); 
    }
    
     @isTest
    static void testQueryScheduleDetail() {
        
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = 'ExtelId';
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'CDX_ScheduleExternal';
        tableSelection.filter = filter;
        
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.TableSelection = tableSelection;
        DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
        RFO_IntegrationLinks__c Schdetl= new RFO_IntegrationLinks__c();
        Schdetl.Name='ScheduleDetail';
        Schdetl.RFO_APILink__c='http://example.com/example/test';
        insert Schdetl;       
        
        RFO_HttpConnectionMock mock = new RFO_HttpConnectionMock();
        Test.setMock(HttpCalloutMock.class, mock);        
        Test.startTest();
        RFO_LCDataSourceConnection connection = new RFO_LCDataSourceConnection(connectionParams);
        //DataSource.TableResult result = connection.query(context);  
        connection.getData('CDX_ScheduleDetail','1636' ,'TASID');  
        Test.stopTest(); 
    }
    
    /* @isTest
    static void testQueryMechanicalData() {
        
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = 'ExtelId';
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'CDX_MechanicalDataExternal';
        tableSelection.filter = filter;
        
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.TableSelection = tableSelection;
        DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
        RFO_IntegrationLinks__c machdata= new RFO_IntegrationLinks__c();
        machdata.Name='MechanicalData';
        machdata.RFO_APILink__c='http://example.com/example/test';
        insert machdata;       
        
        RFO_HttpConnectionMock mock = new RFO_HttpConnectionMock();
        Test.setMock(HttpCalloutMock.class, mock);        
        Test.startTest();
        RFO_LCDataSourceConnection connection = new RFO_LCDataSourceConnection(connectionParams);
        //DataSource.TableResult result = connection.query(context);  
        connection.getData('CDX_MechanicalDataExternal','1636' ,'TASID');  
        Test.stopTest(); 
    }*/
    
     @isTest
    static void testQueryEstimates_Line_Item() {
        
        Account acc = new Account(Name = 'test acc');
        insert acc;
        Asset ast = new Asset(Name = 'test ast',AccountId=acc.Id);
        insert ast;
        RFO_ShopIncident__c sr = new RFO_ShopIncident__c(RFO_Asset__c=ast.Id, RFO_Customer__c=acc.Id);
        insert sr;
        CDX_Estimate__c est = new CDX_Estimate__c(CDX_Service_Request__c=sr.Id,Estimate_External_ID__c='1636_112', ReimbursableFrom__c=acc.Id,CDX_RepEstimateHdrID_ReimbursableFrom__c='1636_112');
        insert est;
        
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = 'ExtelId';
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'CDX_Estimates_Line_ItemExternal';
        tableSelection.filter = filter;
        
        DataSource.QueryContext context = new DataSource.QueryContext();
        context.TableSelection = tableSelection;
        DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
        RFO_IntegrationLinks__c Estimates= new RFO_IntegrationLinks__c();
        Estimates.Name='Estimates_Line_Item';
        Estimates.RFO_APILink__c='http://example.com/example/test';
        insert Estimates;       
        
        RFO_HttpConnectionMock mock = new RFO_HttpConnectionMock();
        Test.setMock(HttpCalloutMock.class, mock);        
        Test.startTest();
        RFO_LCDataSourceConnection connection = new RFO_LCDataSourceConnection(connectionParams);
        //DataSource.TableResult result = connection.query(context);  
        connection.getData('CDX_Estimates_Line_ItemExternal','1636_112' ,'TASID');  
        Test.stopTest(); 
    }
    
    
  static testMethod void myTest() {     
                RFO_AssetExternal__x mockedAsset1 = new RFO_AssetExternal__x(
                  Price__c='600459',
                  Name__c='abcLtd',
                  RFO_LocationStatus__c='test1',
                  Status__c='YES'
                );
             Account TestAcc = new Account(
                  Name='Test Acc'                  
                );
             insert TestAcc; 
             Asset moAsset = new Asset(
                  RFO_TASId__c='600459',
                  Name='xyzLtd',
                 AccountId=TestAcc.Id
                );
             insert moAsset;

             
RFO_ExternalObjectFilterController.mockedAssetlist.add(mockedAsset1);
                     List<RFO_AssetExternal__x> AssetExt = new List<RFO_AssetExternal__x>();
             AssetExt=RFO_ExternalObjectFilterController.getAssetExternal(moAsset.Id);
             System.assert(AssetExt != null);
            RFO_ExternalObjectFilterController.getInvoiceLink('000000000000000') ;

         }
}