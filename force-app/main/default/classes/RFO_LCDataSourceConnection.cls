/**
* This class is used to create external objects and fields for them. Also to make http API request to Trinity server to get response.
* @author      Accenture
* @version     1.0
* @since       26/03/2018
*/
global class RFO_LCDataSourceConnection extends DataSource.Connection {
    
    public static  string CDX_Estimate;
    public static final String AssetExternal='RFO_AssetExternal';  
    public static final String GVPExternal='RFO_GVP';
    public static final String InvoiceExternal='RFO_InvoiceExternal';
    public static final String TestHistoryExternal='RFO_TestHistoryExternal';
    public static final String InvoiceAgeingExternal='RFO_InvoiceAgeingExternal';
    public static final String InvoiceType='RFO_InvoiceType';
    public static final String TestHistoryOneYearDue='RFO_TestHistoryOneYearDue';
    public static final String TestHistoryFiveYearDue='RFO_TestHistoryFiveYearDue';
    //public static final String MechanicalData='CDX_MechanicalDataExternal';
    public static final String ScheduleExternal='CDX_ScheduleExternal';
    public static final String ScheduleDetail='CDX_ScheduleDetail';
    public static final String Estimates_Line_Item='CDX_Estimates_Line_ItemExternal'; 
    public static final String EstimateLineItemExternal='CDX_Estimate_Line_Item'; 
    
    public static final String ExternalId='ExternalId';
    
    public static final String FilterColumn='(Filter:[columnName'; 
    public static final String subfilters='subfilters';
    public static final String columnValueSub1='columnValue=';
    public static final String cama=',';  
    
    public static final String AssetID='RFO_AssetID';
    public static final String AccountID='RFO_AccountID';
    public static final String InvoiceID='RFO_InvoiceID';
    public static final String TestResultID='TestResultID';
    public static final String Invoice_AgingID='RFO_Invoice_AgingID';
    public static final String TASId='RFO_TASId';
    
    public static final String InvoiceUniqueId='RFO_InvoiceUniqueId';
    public static final String DatePassed='RFO_DatePassed';
    public static final String NextTestDate='RFO_NextTestDate';
    public static final String CurrentCommodityStartDate='RFO_CurrentCommodityStartDate';
    public static final String PreviousCommodityStartDate='RFO_PreviousCommodityStartDate';
    public static final String DateBuilt='RFO_DateBuilt';
    public static final String ShipDate='RFO_ShipDate';
    public static final String InvoiceDate='RFO_InvoiceDate';
    public static final String InvoiceDueDate='RFO_InvoiceDueDate';    
    
    private DataSource.ConnectionParams connectionInfo;
    
    global RFO_LCDataSourceConnection(DataSource.ConnectionParams connectionInfo){
        this.connectionInfo = connectionInfo;
        System.debug('CDX_Estimate>>>In LLC'+CDX_Estimate);
    }
    
    override global DataSource.TableResult query(DataSource.QueryContext context) {
        system.debug('Context' + context);
        system.debug('Context' + context.tableSelection);
        DataSource.Filter filter = context.tableSelection.filter;
        system.debug('filter>>>' + filter);
        string strSubNumer='';
        String str = filter != null ?String.valueOf(filter) : null;
        String FilterColumName;
       // system.debug('filter.columnName>>>' + filter.columnName);
       
        if(filter != null){
            FilterColumName=filter.columnName != null ? filter.columnName : filter.subfilters[0].columnName; 
        }
        
        if(str!=NULL){
            string strSub =str.substringBetween(FilterColumn,subfilters);
            if(strSub!=Null){
                strSubNumer =strSub.substringBetween(columnValueSub1,cama);        
            }
            strSubNumer = String.valueOf(filter.columnName != null ? filter.columnValue :  filter.subfilters[0].columnValue);
            
        }
        system.debug('strSubNumer>>>' + strSubNumer);
        if(filter != null && filter.columnValue!=NUll){
            strSubNumer =(string) filter.columnValue; 
        }
        
        List<Map<String, Object>> rows ;
        String url;
        
        system.debug('Context' + context);
        system.debug('strSubNumber: ' + strSubNumer);
        system.debug('FilterColumnName: ' + FilterColumName);
                
        if (context.tableSelection.tableSelected.equals(GVPExternal)) {       
            rows =DataSource.QueryUtils.process(context, getData(GVPExternal,strSubNumer,FilterColumName));
        }
        else if (context.tableSelection.tableSelected.equals(AssetExternal)) {
            rows = DataSource.QueryUtils.process(context, getData(AssetExternal,strSubNumer,FilterColumName));
        }
        else if (context.tableSelection.tableSelected.equals(InvoiceExternal)) {
            rows = DataSource.QueryUtils.process(context, getData(InvoiceExternal,strSubNumer,FilterColumName));
        }
        else if (context.tableSelection.tableSelected.equals(TestHistoryExternal)) {
            rows = DataSource.QueryUtils.process(context, getData(TestHistoryExternal,strSubNumer,FilterColumName));
        }
        else if (context.tableSelection.tableSelected.equals(InvoiceAgeingExternal)) {
            rows = DataSource.QueryUtils.process(context, getData(InvoiceAgeingExternal,strSubNumer,FilterColumName));
        }
        else if (context.tableSelection.tableSelected.equals(InvoiceType)) {
            rows = DataSource.QueryUtils.process(context, getData(InvoiceType,strSubNumer,FilterColumName));
        }
        else if (context.tableSelection.tableSelected.equals(TestHistoryOneYearDue)) {
            rows = DataSource.QueryUtils.process(context, getData(TestHistoryOneYearDue,'',''));
        }
        else if (context.tableSelection.tableSelected.equals(TestHistoryFiveYearDue)) {
            rows = DataSource.QueryUtils.process(context, getData(TestHistoryFiveYearDue,'',''));
        }
        /*else if (context.tableSelection.tableSelected.equals(MechanicalData)) {
            System.debug('In mecha datasource query call');
            rows = DataSource.QueryUtils.process(context, getData(MechanicalData,strSubNumer,FilterColumName));
        }*/
        else if (context.tableSelection.tableSelected.equals(ScheduleDetail)) {
            rows = DataSource.QueryUtils.process(context, getData(ScheduleDetail,strSubNumer,FilterColumName)); 
        }
        else if (context.tableSelection.tableSelected.equals(EstimateLineItemExternal)) { 
            rows = getData(Estimates_Line_Item, strSubNumer, FilterColumName);  
            system.debug('results from getData: ' + rows); 
        } 
        
        /**
        * Filters, sorts, and applies limit and offset clauses.
        **/
        // DataSource.TableResult result = DataSource.TableResult.get(true, null, context.tableSelection.tableSelected, rows);
        System.debug(rows);
        System.debug(context);
        DataSource.TableResult result = DataSource.TableResult.get(context, rows);
        system.debug('result: ' + result); 
        return result; 
        
    } // end of query method
    
        override global List<DataSource.Table> sync() {
        List<DataSource.Table> tables = new List<DataSource.Table>(); 
        
        /**
        * GVP
        */
        List<DataSource.Column> columnsGVP;
        columnsGVP = new List<DataSource.Column>();       
        columnsGVP.add(DataSource.Column.text('RFO_AssetID','Asset ID', 255));
        columnsGVP.add(DataSource.Column.text('RFO_Carrier','Carrier', 255));
        columnsGVP.add(DataSource.Column.text('RFO_Destination','Destination', 255));
        columnsGVP.add(DataSource.Column.text('RFO_EventStation','Event Station', 255));
        columnsGVP.add(DataSource.Column.text('RFO_LE','L/E', 255));
        columnsGVP.add(DataSource.Column.text('RFO_Origin','Origin', 255));
        columnsGVP.add(DataSource.Column.text('RFO_STCCDescription','STCC description', 255));
        columnsGVP.add(DataSource.Column.text('RFO_Status','Status', 255));
        columnsGVP.add(DataSource.Column.text('RFO_StatusDate','Status Date', 255));
        columnsGVP.add(DataSource.Column.text('RFO_STCC','STCC', 255));
        columnsGVP.add(DataSource.Column.text('RFO_TrainID','Train ID', 255));
        columnsGVP.add(DataSource.Column.text('RFO_StageID','Stage ID', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Location_City__c','Location City', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Location_State__c','Location State', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Sighting_Year__c','Sighting Year', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Sighting_Month__c','Sighting Month', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Sighting_Day__c','Sighting Day', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Destination_City__c','Destination City', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Destination_State__c','Destination State', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Origin_City__c','Origin City', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Origin_State__c','Origin State', 255));
        columnsGVP.add(DataSource.Column.text('CDX_ETA_Destination_Date__c','ETA Destination Date', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Date_Shipped__c','Date Shipped', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Account__c','Customer', 255));
        columnsGVP.add(DataSource.Column.text('CDX_Bill_of_Lading__c','Bill of Lading', 255));
        columnsGVP.add(DataSource.Column.text('ExternalId', 255));       
        columnsGVP.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('RFO_GVP','GVP','GVP','GVP External Obj','ExternalId',columnsGVP));
        
        /**
        * AssetGVP
        */
        List<DataSource.Column> columnsAsset;
        columnsAsset = new List<DataSource.Column>();
        columnsAsset.add(DataSource.Column.text('RFO_TASId','Asset Name', 255));        
        columnsAsset.add(DataSource.Column.text('ExternalId', 255));        
        columnsAsset.add(DataSource.Column.text('AccountId','Assigned To', 255));
        columnsAsset.add(DataSource.Column.text('CreatedById','Created By', 255));
        columnsAsset.add(DataSource.Column.text('CreatedDate','Created Date', 255));
        columnsAsset.add(DataSource.Column.text('Id','Asset ID', 255));
        columnsAsset.add(DataSource.Column.text('LastModifiedById','LastModified By', 255));
        columnsAsset.add(DataSource.Column.text('LastModifiedDate','LastModified Date', 255)); 
        columnsAsset.add(DataSource.Column.text('Name','Equipment', 255));
        columnsAsset.add(DataSource.Column.text('Price','Original Cost', 255));
        columnsAsset.add(DataSource.Column.text('Product2Id','Product', 255));
        columnsAsset.add(DataSource.Column.text('PurchaseDate','Invoice Date', 255));
        columnsAsset.add(DataSource.Column.text('RFO_CarCondition','Car Condition', 255));
        columnsAsset.add(DataSource.Column.text('Quantity','Quantity', 255));
        columnsAsset.add(DataSource.Column.text('RFO_ActualCapacity','Actual Capacity', 255));              
        columnsAsset.add(DataSource.Column.text('Assigned_To','Assigned To', 255));
        columnsAsset.add(DataSource.Column.text('RFO_CarMark','Car Mark', 255));
        columnsAsset.add(DataSource.Column.text('RFO_CarNumber','Car Number', 255));
        columnsAsset.add(DataSource.Column.text('RFO_CarOwner','Car Owner', 255));
        columnsAsset.add(DataSource.Column.text('RFO_CarSubStatus','SubStatus', 255));
        columnsAsset.add(DataSource.Column.text('RFO_CarType','Car Type', 255));
        columnsAsset.add(DataSource.Column.text('RFO_Committed_To','Committed To', 255));
        columnsAsset.add(DataSource.Column.text('RFO_CurrentCommodity','Current  Commodity', 255));
        columnsAsset.add(DataSource.Column.text('RFO_CurrentCommodityStartDate','Current Commodity Start Date', 255));
        columnsAsset.add(DataSource.Column.text('RFO_DateBuilt','Date Built', 255));
        columnsAsset.add(DataSource.Column.text('RFO_DesignatedCapacity','Designated Capacity', 255));
        columnsAsset.add(DataSource.Column.text('RFO_DOTClass','DOT Class', 255));        
        columnsAsset.add(DataSource.Column.text('RFO_File','File Number', 255));
        columnsAsset.add(DataSource.Column.text('RFO_GRL','GRL', 255));
        columnsAsset.add(DataSource.Column.text('RFO_LightWeight','Light Weight', 255));
        columnsAsset.add(DataSource.Column.text('RFO_LocationStatus','Location Status', 255));
        columnsAsset.add(DataSource.Column.text('RFO_Manufacturer','Manufacturers', 255));
        columnsAsset.add(DataSource.Column.text('RFO_MfgPlant','Plant NUM', 255));              
        columnsAsset.add(DataSource.Column.text('RFO_ModelDescription','Model ID', 255));
        columnsAsset.add(DataSource.Column.text('RFO_Previous_Commodity','Previous Commodity', 255));
        columnsAsset.add(DataSource.Column.text('RFO_PreviousCommodityStartDate','Previous Commodity Start Date', 255));
        columnsAsset.add(DataSource.Column.text('RFO_RANumber','RA Number', 255));
        columnsAsset.add(DataSource.Column.text('RFO_RAType','RA Type', 255));
        columnsAsset.add(DataSource.Column.text('RFO_ShipDate','Ship Date', 255));
        columnsAsset.add(DataSource.Column.text('RFO_StencilSpec','Stencil Spec', 255));
        columnsAsset.add(DataSource.Column.text('RFO_TRNumber','TRN Number', 255));
        columnsAsset.add(DataSource.Column.text('RFO_TRType','TRN Type', 255));
        columnsAsset.add(DataSource.Column.text('SerialNumber','Serial Numbers', 255));
        columnsAsset.add(DataSource.Column.text('Status','Status', 255));
        columnsAsset.add(DataSource.Column.text('UsageEndDate','Usage End Date', 255)); 
        columnsAsset.add(DataSource.Column.text('RFO_EventStation','Last Seen Location', 255)); 
        columnsAsset.add(DataSource.Column.text('RFO_StatusDate','Last Seen Date', 255)); 
        columnsAsset.add(DataSource.Column.text('RFO_Origin','Origin', 255));
        columnsAsset.add(DataSource.Column.text('RFO_LE','Loaded or Empty', 255));
        columnsAsset.add(DataSource.Column.text('RFO_Destination','Destination', 255));
        columnsAsset.add(DataSource.Column.text('RFO_PortfolioStatus','Portfolio Status', 255));
        columnsAsset.add(DataSource.Column.text('RFO_LinktoEngineeringSpec','Link to Engineering Spec', 255));
        columnsAsset.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('RFO_AssetExternal','Asset Detail','Asset Detail','AssetExternal External Obj','ExternalId',columnsAsset));
        
        /**
        * Invoices
        */
        List<DataSource.Column> columnsInvoice;
        columnsInvoice = new List<DataSource.Column>();      
        columnsInvoice.add(DataSource.Column.text('RFO_Account','Account',255));
        columnsInvoice.add(DataSource.Column.text('CreatedById','Created By', 255));
        columnsInvoice.add(DataSource.Column.text('CreatedDate','Created Date', 255));
        columnsInvoice.add(DataSource.Column.text('LastModifiedById','Last Modified By', 255));
        columnsInvoice.add(DataSource.Column.text('LastModifiedDate','Last Modified Date', 255));
        columnsInvoice.add(DataSource.Column.text('Name','Invoice Number', 255));        
        columnsInvoice.add(DataSource.Column.text('RFO_AmountDue','Amount Due', 255));
        columnsInvoice.add(DataSource.Column.text('RFO_Document','Document', 255));
        columnsInvoice.add(DataSource.Column.text('RFO_InvoiceAmount','Invoice Amount', 255));
        columnsInvoice.add(DataSource.Column.text('RFO_InvoiceDate','Invoice Date', 255));
        columnsInvoice.add(DataSource.Column.text('RFO_InvoiceDueDate','Invoice Due Date', 255));
        columnsInvoice.add(DataSource.Column.text('RFO_InvoiceID','Invoice ID', 255));
        columnsInvoice.add(DataSource.Column.text('RFO_Status','Status', 255));  
        columnsInvoice.add(DataSource.Column.text('RFO_LinktoInvoice','Link to Invoice',255));
        columnsInvoice.add(DataSource.Column.text('ExternalId',255));
        columnsInvoice.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('RFO_InvoiceExternal','Invoice','Invoice','InvoiceExternal External Obj','ExternalId',columnsInvoice));
        
        /**
        * Invoice Aging
        */
        List<DataSource.Column> columnsInvoiceAging;
        columnsInvoiceAging = new List<DataSource.Column>();
        columnsInvoiceAging.add(DataSource.Column.text('RFO_Account','Account ID',255));
        columnsInvoiceAging.add(DataSource.Column.text('ExternalId',255));
        columnsInvoiceAging.add(DataSource.Column.url('DisplayUrl'));
        columnsInvoiceAging.add(DataSource.Column.text('RFO_X1_30','1-30 days', 255));        
        columnsInvoiceAging.add(DataSource.Column.text('RFO_X31_60','31-60 days', 255));
        columnsInvoiceAging.add(DataSource.Column.text('RFO_X61_90','61-90 days', 255));
        columnsInvoiceAging.add(DataSource.Column.text('RFO_X91_180','91-180 days', 255)); 
        columnsInvoiceAging.add(DataSource.Column.text('RFO_X181','181+ days', 255));       
        tables.add(DataSource.Table.get('RFO_InvoiceAgeingExternal','Invoice Aging','Invoice Aging','InvoiceAgingExternal Obj','ExternalId',columnsInvoiceAging));
        
        /**
        * Invoice Type
        */
        List<DataSource.Column> columnsInvoiceType;
        columnsInvoiceType = new List<DataSource.Column>();      
        columnsInvoiceType.add(DataSource.Column.text('RFO_AccountId','Account',255));
        columnsInvoiceType.add(DataSource.Column.text('RFO_InvoiceAmount','Invoice Amount', 255));
        columnsInvoiceType.add(DataSource.Column.text('RFO_InvoiceRevenueType','Invoice Revenue Type', 255));
        columnsInvoiceType.add(DataSource.Column.text('ExternalId',255));
        columnsInvoiceType.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('RFO_InvoiceType','Invoice Type','Invoice Type','InvoiceType External Obj','ExternalId',columnsInvoiceType)); 
        
        /**
        * Test History
        */
        /*List<DataSource.Column> columnsTestHistory;
        columnsTestHistory = new List<DataSource.Column>();
        columnsTestHistory.add(DataSource.Column.text('RFO_Asset','Asset Name',255));
        columnsTestHistory.add(DataSource.Column.text('ExternalId',255));        
        columnsTestHistory.add(DataSource.Column.text('LastModifiedDate','Last Modified Date',255));        
        columnsTestHistory.add(DataSource.Column.text('RFO_DatePassed','Date Passed', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_DocumentCreatedBy','Document Created', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_DocumentDesc','Document Desc', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_DocumentName','Document Name', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_NextTestDate','Next Test Date', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_ShopIncident','ShopIncident', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_ShopLocation','Shop Location', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_ShopName','Company', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_TestDesc','Test Desc', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_TestID','Test ID', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_TestName','Test or Function', 255));
        columnsTestHistory.add(DataSource.Column.text('RFO_TestType','Test Type', 255));
         columnsTestHistory.add(DataSource.Column.text('CDX_CarMark','Car Mark', 255));
         columnsTestHistory.add(DataSource.Column.text('CDX_CarNumber','Car Number', 255));
         columnsTestHistory.add(DataSource.Column.text('CDX_AssetName','Asset Name', 255));       
        columnsTestHistory.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('RFO_TestHistoryExternal','Test History','Test History','TestHistoryExternal External Obj','ExternalId',columnsTestHistory));
        */
        /**
        * Test History One
        */
        List<DataSource.Column> columnsTestHistoryOneYearDue;
        columnsTestHistoryOneYearDue = new List<DataSource.Column>();
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_Asset','Asset Name',255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('ExternalId',255));        
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('LastModifiedDate','Last Modified Date',255));        
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_DatePassed','Date Passed', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_DocumentCreatedBy','Document Created', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_DocumentDesc','Document Desc', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_DocumentName','Document Name', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_NextTestDate','Next Test Date', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_ShopIncident','ShopIncident', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_ShopLocation','Shop Location', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_ShopName','Company', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_TestDesc','Test Desc', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_TestID','Test ID', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_TestName','Test or Function', 255));
        columnsTestHistoryOneYearDue.add(DataSource.Column.text('RFO_TestType','Test Type', 255));        
        columnsTestHistoryOneYearDue.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('RFO_TestHistoryOneYearDue','TestHistoryOneYearDue','TestHistoryOneYearDue','TestHistoryOneYearDue External Obj','ExternalId',columnsTestHistoryOneYearDue));
        
        /**
        * Test History Five
        */
        List<DataSource.Column> columnsTestHistoryFiveYearDue;
        columnsTestHistoryFiveYearDue = new List<DataSource.Column>();
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_Asset','Asset Name',255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('ExternalId',255));        
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('LastModifiedDate','Last Modified Date',255));        
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_DatePassed','Date Passed', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_DocumentCreatedBy','Document Created', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_DocumentDesc','Document Desc', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_DocumentName','Document Name', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_NextTestDate','Next Test Date', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_ShopIncident','ShopIncident', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_ShopLocation','Shop Location', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_ShopName','Company', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_TestDesc','Test Desc', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_TestID','Test ID', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_TestName','Test or Function', 255));
        columnsTestHistoryFiveYearDue.add(DataSource.Column.text('RFO_TestType','Test Type', 255));        
        columnsTestHistoryFiveYearDue.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('RFO_TestHistoryFiveYearDue','TestHistoryFiveYearDue','TestHistoryFiveYearDue','TestHistoryFiveYearDue External Obj','ExternalId',columnsTestHistoryFiveYearDue));
        
        /**
        * Schedule Detail
        */
        /**
        List<DataSource.Column> columnsScheduleDetail;
        columnsScheduleDetail = new List<DataSource.Column>();      
        columnsScheduleDetail.add(DataSource.Column.text('Cars_Arrived_at_Shop','Actual Cars Arrived',255));
        columnsScheduleDetail.add(DataSource.Column.text('Actual_Cars_Complete','Actual Cars Completed',255));
        columnsScheduleDetail.add(DataSource.Column.text('Cars_En_Route_Triggered_by_SI_creation','Actual Customer Release',255));
        columnsScheduleDetail.add(DataSource.Column.text('Average_Turn_Time_Accepted_by_Shop','Average Turn Time (Accepted by Shop)',255));
        columnsScheduleDetail.add(DataSource.Column.text('Projected_Arrival_to_Shop','Projected Arrival',255));
        columnsScheduleDetail.add(DataSource.Column.text('Projected_Schedule_Cars_Complete','Projected Cars Complete',255));
        columnsScheduleDetail.add(DataSource.Column.text('Customer_Release','Projected Customer Release',255));
        columnsScheduleDetail.add(DataSource.Column.text('CDX_Schedule','Schedule',255));
        columnsScheduleDetail.add(DataSource.Column.text('CDX_WeekStartDate','Week Start Date',255));
        columnsScheduleDetail.add(DataSource.Column.text('Week','Week',255));
        columnsScheduleDetail.add(DataSource.Column.text('ExternalId',255));
        columnsScheduleDetail.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('CDX_ScheduleExternal','Schedule Detail','Schedule Detail','CDX_ScheduleExternal','ExternalId',columnsScheduleDetail));
        */
        
        /**
        * Schedule Detail
        */
        List<DataSource.Column> columnsScheduleDetail;
        columnsScheduleDetail = new List<DataSource.Column>();      
        columnsScheduleDetail.add(DataSource.Column.text('CDX_Week','Week',255));
        columnsScheduleDetail.add(DataSource.Column.text('CDX_Week_Start_Date','Week Start Date',255));
        columnsScheduleDetail.add(DataSource.Column.text('CDX_Projected_Customer_Release','Projected Release',255));
        columnsScheduleDetail.add(DataSource.Column.text('CDX_Actual_Customer_Release','Actual Customer Release',255));
        columnsScheduleDetail.add(DataSource.Column.text('CDX_Projected_Arrival','Projected Arrival',255));  
        columnsScheduleDetail.add(DataSource.Column.text('CDX_Actual_Cars_Arrived','Actual Cars Arrived',255));
        columnsScheduleDetail.add(DataSource.Column.text('CDX_Projected_Cars_Complete','Projected Cars Complete',255));
        columnsScheduleDetail.add(DataSource.Column.text('CDX_Actual_Cars_Completed','Actual Cars Completed',255));
        columnsScheduleDetail.add(DataSource.Column.indirectLookup('CDX_Schedule','CDX_Schedule__c', 'Schedule_External_ID__c'));
        columnsScheduleDetail.add(DataSource.Column.text('ExternalId',255));
        columnsScheduleDetail.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('CDX_ScheduleDetail','Schedule Detail','Schedule Details','Schedule Details','ExternalId', columnsScheduleDetail));
        
        /**
        * MechanicalDataExternal
        */
        /*List<DataSource.Column> columnsMechanicalData;
        columnsMechanicalData = new List<DataSource.Column>();      
        columnsMechanicalData.add(DataSource.Column.text('CDX_AccountId','AccountId',255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_A_End_Coupler','A End Coupler', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Air_Connector_Type','Air Connector Type', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Asset','Asset', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_B_End_Coupler','B End Coupler', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Bottom_Gate_Manufacturer','Bottom Gate Manufacturer', 255));        
        columnsMechanicalData.add(DataSource.Column.text('CDX_Bottom_Gate_Model','Bottom Gate Model', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Bottom_Gate_Type','Bottom Gate Type', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Bottom_Outlet_Valve_Cap_Gasket','Bottom Outlet Valve Cap Gasket', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_BOV_Current_per_Mechanical_Data','BOV/Current per Mechanical Data in TAS.', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_BOV_Handle_Type','BOV Handle Type', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Build_Date','Build Date', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Capacity','Capacity', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Coil_Material','Coil Material', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Coil_Type','Coil Type', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_DOT_Construction_Class','DOT Construction Class', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_DOT_Stencil_Class','DOT Stencil Class', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Eduction_Pipe','Eduction Pipe', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Eduction_Valve','Eduction Valve', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Extreme_Height','Extreme Height', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Extreme_Width','Extreme Width', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_File_Number','File Number', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Flange_Gasket','Flange Gasket', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Gauging_Device','Gauging Device', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Gross_Rail_Limit','Gross Rail Limit', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Hatch_Cover_Composition','Hatch Cover Composition', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Hatch_Cover_Manufacturer','Hatch Cover Manufacturer', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Hatch_Cover_Model','Hatch Cover Model', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Hatch_Opening_Number_Of_Hatches','Hatch Opening(Number of Hatches)', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Hatch_Opening_Type','Hatch Opening(Type)', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Insulation_Material','Insulation Material', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Length_Over_Coupler_Pulling','Length Over Coupler Pulling Face(Extreme', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Length_Over_Striker','Length Over Striker', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Light_Weight','Light Weight', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Lining_By','Lining By', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Lining_Date','Lining Date', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Lining_Material','Lining Material', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Lining_Type','Lining Type', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Load_Limit','Load Limit', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Manufacturer','Manufacturer', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Manway_Gasket','Manway Gasket', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Manway_Size','Manway Size', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Nitrogen_Pad','Nitrogen Pad', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Number_of_Bottom_Gates','Number of Bottom Gates', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Number_of_Coil_Lines','Number of Coil Lines', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Number_of_Compartments','Number of Compartments', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_O_Ring','O-Ring', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Paint_By','Paint By', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Paint_Color','Paint Color', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Paint_Date','Paint Date', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Paint_Material','Paint Material', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Rupture_Disc','Rupture Disc', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Safety_Valve_Composition','Safety Valve Composition', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Safety_Valve_QTY','Safety Valve QTY', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Safety_Vent','Safety Vent', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Sample_Valve','Sample Valve', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Thermowell','Thermowell', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Truck_Capacity','Truck Capacity', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Unit_of_Measure','Unit of Measure', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_VRV','VRV', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_AssetName','Asset Name', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_CarMark','Car Mark', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_CarNumber','Car Number', 255));
        columnsMechanicalData.add(DataSource.Column.text('CDX_Account','Account', 255));        
        columnsMechanicalData.add(DataSource.Column.text('ExternalId',255));
        columnsMechanicalData.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('CDX_MechanicalDataExternal','Mechanical Data','Mechanical Data','MechanicalDataExternal Object','ExternalID',columnsMechanicalData));
        */
        /**
        * Estimates Line Item
        */
        List<DataSource.Column> columnsEstimatesLineItem;
        columnsEstimatesLineItem = new List<DataSource.Column>(); 
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Approved_Rejected_By','Approved/Rejected By',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Comments','Comments',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Condition_Code','Condition Code',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Description','Description',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Job_Category_Code','Job Category Code',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Job_Category_Description','Job Category Description',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Job_Code_Applied','Job Code Applied',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Job_Code_Reviewed','Job Code Reviewed',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Labor_Charge','Labor Charge',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Materials_Miscellaneous_Charge','Materials/Miscellaneous Charge',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Qualifier','Qualifier',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Qualifier_Code','Qualifier Code',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Quantity','Quantity (Qty)',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_RepEstimateCustVerDetID','RepEstimateCustVerDetID',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_RepEstimateCustVerHdrID','RepEstimateCustVerHdrID',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Status','Status',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Total_Amount','Total Amount',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Version_History','Version History',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Version_Number','Version Number',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Why_Made','Why Made',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Repair_Location','Repair Location (LOC)',255)); 
        columnsEstimatesLineItem.add(DataSource.Column.text('CDX_Estimate','Estimate',255));
        columnsEstimatesLineItem.add(DataSource.Column.text('ExternalId',255));
        columnsEstimatesLineItem.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('CDX_Estimates_Line_ItemExternal','Estimates Line Item','Estimates Line Item','CDX_Estimates_Line_ItemExternal','ExternalId',columnsEstimatesLineItem));
        
        /**
        * Estimate Line Item
        */
        List<DataSource.Column> columnsEstimateLineItem = new List<DataSource.Column>(); 
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Approved_Rejected_By','Approved/Rejected By',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Comments','Comments',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Condition_Code','Condition Code',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Description','Description',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Job_Category_Code','Job Category Code',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Job_Category_Description','Job Category Description',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Job_Code_Applied','Job Code Applied',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Job_Code_Reviewed','Job Code Reviewed',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Labor_Charge','Labor Charge',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Materials_Miscellaneous_Charge','Materials/Miscellaneous Charge',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Qualifier','Qualifier',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Qualifier_Code','Qualifier Code',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Quantity','Quantity (Qty)',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_RepEstimateCustVerDetID','RepEstimateCustVerDetID',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_RepEstimateCustVerHdrID','RepEstimateCustVerHdrID',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Status','Status',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Total_Amount','Total Amount',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Version_History','Version History',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Version_Number','Version Number',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Why_Made','Why Made',255));
        columnsEstimateLineItem.add(DataSource.Column.text('CDX_Repair_Location','Repair Location (LOC)',255)); 
        // columnsEstimateLineItem.add(DataSource.Column.text('CDX_Estimate','Estimate',255));
        //columnsEstimateLineItem.add(DataSource.Column.indirectLookup('CDX_Estimate', 'CDX_Estimate__c', 'CDX_RepEstimateHdrID_ReimbursableFrom__c'));
        columnsEstimateLineItem.add(DataSource.Column.indirectLookup('CDX_RepEstimateHdrID_ReimbursableFrom', 'CDX_Estimate__c', 'CDX_RepEstimateHdrID_ReimbursableFrom__c'));
        columnsEstimateLineItem.add(DataSource.Column.text('ExternalId',255));
        columnsEstimateLineItem.add(DataSource.Column.url('DisplayUrl'));
        tables.add(DataSource.Table.get('CDX_Estimate_Line_Item','Estimate Line Item','Estimate Line Items','Estimate Line Item External Object', 'ExternalId', columnsEstimateLineItem));
        
        return tables;
    } // end of sync method
    
    /**
    * Called to do a full text search and get results from
    * the external system for SOSL queries and Salesforce
    * global searches.
    *
    * The SearchContext argument represents the query to run
    * against a table in the external system.
    *
    * Returns results for each table that the SearchContext
    * requested to be searched.
    **/
    override global List<DataSource.TableResult> search(DataSource.SearchContext context) {
        List<DataSource.TableResult> results = new List<DataSource.TableResult>();
        
        for (Integer i =0;i< context.tableSelections.size();i++) {
            String entity = context.tableSelections[i].tableSelected;
            
            // Search usernames
            String url = '';
            
            results.add(DataSource.TableResult.get(true, null, entity, getData(GVPExternal,'','')));
        }
        return results;
    } // end of search method
    
    /**
    * Helper method to parse the data.
    * The url argument is the URL of the external system.
    * Returns a list of rows from the external system.
    **/
    public List<Map<String, Object>> getData(String url,string strSubNumer,string FilterColumName) {
        String response = getResponse(url,strSubNumer,FilterColumName);
        // system.debug('response: ' + response); 
        
        // Standardize response string
        if (!response.contains('"Response":')) {
            if (response.substring(0,1).equals('{')) {
                response = '[' + response  + ']';
            }
            response = '{"Response": ' + response + '}';
        }
        
        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        
        Map<String, Object> responseBodyMap = (Map<String, Object>)
            JSON.deserializeUntyped(response);
        // system.debug('responseBodyMap: ' + responseBodyMap);
        
        /**
        * Check errors
        **/
        Map<String, Object> error =
            (Map<String, Object>)responseBodyMap.get('error');
        if (error!=null) {
            List<Object> errorsList = (List<Object>)error.get('errors');
            Map<String, Object> errors = (Map<String, Object>)errorsList[0];
            String errorMessage = (String)errors.get('message');
            throw new 
                DataSource.OAuthTokenExpiredException(errorMessage);
        }
        //System.debug('responseBodyMap :'+responseBodyMap);
        List<Object> fileItems = (List<Object>)responseBodyMap.get('Response'); 
       // system.debug('fileItems: ' + fileItems); 
        if (fileItems != null) {
            for (Integer i=0; i < fileItems.size(); i++) {
                Map<String, Object> item = (Map<String, Object>)fileItems[i]; 
                system.debug('item: ' + item); 
                rows.add(createRow(item)); 
            }
        } else {
            rows.add(createRow(responseBodyMap));
        }
       
        //system.debug('first row external Id: ' + rows[0].get(ExternalId)); 
        //system.debug('Estimate Id: ' + rows[0].get('CDX_Estimate__c')); 
        
        
        return rows;
    } // end of getData() method
    
    /**
    * Helper method to populate the External ID and Display
    * Display URL values.
    **/
    public Map<String, Object> createRow(Map<String, Object> item){
        Map<String, Object> row = new Map<String, Object>();
        
        for ( String key : item.keySet() ) {
            if (key ==AssetID) { //GVP External ID
                row.put(ExternalId, item.get(key));
                
            } else if (key==InvoiceID) { // Invoice External ID
                row.put(ExternalId, item.get(key));
            }            
            else if (key==TestResultID) { // Test History
                row.put(ExternalId, item.get(key));
            }
            else if (key==Invoice_AgingID) { // Invoice Ageing External ID
                row.put(ExternalId, item.get(key));
            }
            else if (key==TASId) { // Asset External ID
                row.put(ExternalId, item.get(key));
            }
            else if (key==InvoiceUniqueId) { // Invoice Type External ID
                row.put(ExternalId, item.get(key));
            }
            else if (key=='projectCustShopScheduleDetailID') { // Schedule Detail External ID
                row.put(ExternalId, item.get(key));
            }
            else if (key=='assetId') { // Mechanica Data External ID
                system.debug('Exteneral Id being set');
                row.put(ExternalId, item.get(key));
            }
            else if (key=='ExternalId') { // Estimate Line Item External ID
                system.debug('Estimate Exteneral Id: '+item.get(key));
                row.put(ExternalId, item.get(key));
            }
            
            if (key=='assetId') { // Mechanica Data External ID
                system.debug('CDX_Asset__c foreign key being set');
                row.put('CDX_Asset', item.get(key)); 
            }

            
            Object value = item.get(key); 
            
            if (key.endsWith('__c')) 
                key = key.substring(0, key.length() - 3);
            
            row.put(key, value);
            if (key==DatePassed||key==NextTestDate||Key==CurrentCommodityStartDate||Key==PreviousCommodityStartDate||Key==DateBuilt||Key==ShipDate||Key==InvoiceDate||Key==InvoiceDueDate) {
                string S1=(String)item.get(key);
                if(S1!=NULL && S1.Length()>=3){          
                    S1 = S1.subString(0,10);                       
                    row.put(key, S1);
                }           
            }            
        }
        return row;
    } // end of createRow method
    
    /**
    * Helper method to make the HTTP GET call.
    */
    public String getResponse(String url,string strSubNumer,string FilterColumName) {
        String response1;
        string TASID=strSubNumer;
        string Colum=FilterColumName;
        String Endurl;
        
        system.debug('getResponse: URL is ' + strSubNumer); 
        
        if(url==GVPExternal){
            string  LinkGVP=RFO_IntegrationLinks__c.getInstance('GVP').RFO_APILink__c;
            Endurl=LinkGVP+TASID;  
            system.debug('Endurl for GVP is' + Endurl);                 
        }
        else if(url==AssetExternal){
            string  LinkAsset=RFO_IntegrationLinks__c.getInstance('Asset').RFO_APILink__c;
            Endurl=LinkAsset+TASID; 
        }
        else if(url==InvoiceExternal){
            string  LinkInvoice;
            if(Colum==ExternalId){
                LinkInvoice=RFO_IntegrationLinks__c.getInstance('InvoiceDetail').RFO_APILink__c; 
            }
            else{
                LinkInvoice=RFO_IntegrationLinks__c.getInstance('Invoice').RFO_APILink__c; 
            }           
            Endurl=LinkInvoice+TASID; 
        }
        else if(url==TestHistoryExternal){ 
            System.debug('COLUMN IS SET TO: '+Colum);
            string  LinkTestHistory;
            if(Colum==ExternalId){
                LinkTestHistory=RFO_IntegrationLinks__c.getInstance('TestHistoryDetail').RFO_APILink__c+TASID;
            }
            else{
                If (Colum==AccountID){
                LinkTestHistory=RFO_IntegrationLinks__c.getInstance('TestHistoryAccount').RFO_APILink__c+TASID+'&NumberofMonths=12';
                }
                else
                {
                    LinkTestHistory=RFO_IntegrationLinks__c.getInstance('TestHistory').RFO_APILink__c+TASID;
                }
            }
            Endurl=LinkTestHistory; 
        }
        else if(url==InvoiceAgeingExternal){ 
            string  LinkInvoiceAgeing;
            if(Colum==ExternalId){
                LinkInvoiceAgeing=RFO_IntegrationLinks__c.getInstance('InvoiceAgeingDetail').RFO_APILink__c;
            }
            else{
                LinkInvoiceAgeing=RFO_IntegrationLinks__c.getInstance('InvoiceAgeing').RFO_APILink__c;
            }
            Endurl=LinkInvoiceAgeing+TASID;  
        }
        else if(url==InvoiceType){ 
            string  LinkInvoiceType;
            LinkInvoiceType=RFO_IntegrationLinks__c.getInstance('InvoiceType').RFO_APILink__c;  
            Endurl=LinkInvoiceType+TASID;          
        }
        else if(url==TestHistoryOneYearDue){           
            Endurl=RFO_IntegrationLinks__c.getInstance('TestHistoryOneYearDue').RFO_APILink__c;                   
        }
        else if(url==TestHistoryFiveYearDue){             
            Endurl=RFO_IntegrationLinks__c.getInstance('TestHistoryFiveYearDue').RFO_APILink__c;   
        }
        /*else if(url==MechanicalData){
            string  LinkMechData=RFO_IntegrationLinks__c.getInstance('MechanicalData').RFO_APILink__c;
            Endurl=LinkMechData+TASID;
            system.debug('Endurl for Mechanical Data is' + Endurl); 
        }*/
        else if(url==ScheduleDetail){
            Endurl = RFO_IntegrationLinks__c.getInstance('ScheduleDetail').RFO_APILink__c;
            //Endurl=String.format(Endurl, new List<Object> { TASID } ); 
            Endurl= Endurl.replace('%7B0%7D', TASID);
            Endurl= Endurl.replace('{0}', TASID);
            system.debug('Endurl for schedule Details is' + Endurl); 
        }
        else if(url == 'CDX_Estimates_Line_ItemExternal'){
          string  LinkEstimateLineItem;
            system.debug('Colum>>>>' + Colum); 
            if(Colum==ExternalId){
                LinkEstimateLineItem=RFO_IntegrationLinks__c.getInstance('Estimates_Line_Item_Detail').RFO_APILink__c;
                system.debug('LinkEstimateLineItem>>>>' + LinkEstimateLineItem); 
                Endurl=LinkEstimateLineItem+TASID+'/details'; 
            }
            else{
                LinkEstimateLineItem=RFO_IntegrationLinks__c.getInstance('Estimates_Line_Item').RFO_APILink__c;
                system.debug('LinkEstimateLineItem111>>>>' + LinkEstimateLineItem);


                CDX_Estimate__c cdxEstimate = [SELECT Id,ReimbursableFrom__r.RFO_TASId__c, Estimate_External_ID__c  FROM CDX_Estimate__c 
                                               WHERE CDX_RepEstimateHdrID_ReimbursableFrom__c =: TASID LIMIT 1];
                //strSubNumer
                String rfoTasId = '';
                System.debug(cdxEstimate.ReimbursableFrom__r.RFO_TASId__c);
                if(cdxEstimate.ReimbursableFrom__r.RFO_TASId__c == null){
                    rfoTasId = strSubNumer.split('_')[1];
                }
                else{
                    rfoTasId = cdxEstimate.ReimbursableFrom__r.RFO_TASId__c;
                }
                Endurl=LinkEstimateLineItem+cdxEstimate.Estimate_External_ID__c+'/reimbursableFrom/'+rfoTasId; 
				TASID=cdxEstimate.Estimate_External_ID__c;
                System.debug('TAS Id :'+cdxEstimate.ReimbursableFrom__r);
                System.debug('TAS Id : '+cdxEstimate.ReimbursableFrom__r.RFO_TASId__c);

            }
            
            system.debug('Endurl>>>>' + Endurl);
        }  
        /* else if(url == 'CDX_Estimates_Line_ItemExternal'){
            Endurl=RFO_IntegrationLinks__c.getInstance('Estimates_Line_Item').RFO_APILink__c;  
            Endurl = Endurl + TASID; 
            system.debug('Endurl for Estimate Line items is' + Endurl); 
        } */
      
        system.debug('Endurl: ' + Endurl); 
        
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(Endurl);
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        
        // if (url == Estimates_Line_Item) {
            req.setHeader('client_id', '72d7b41af5cc4466af121e9baecb876a');
            req.setHeader('client_secret', 'a6bFA94D4f224739aEbAFF808C66ec23'); 
            req.setHeader('x-correlation-id', '07fEcd485Ca64A48A63f4990F1a38BAB');
        // }
        
        req.setTimeout(100000);
        Http httpObj = new Http();
        System.HttpResponse res = httpObj.send(req);
        response1= res.getBody ();   
        system.debug('&&&&&&&RESS='+response1);  
        return response1;    
    } // end of getResponse method 
}