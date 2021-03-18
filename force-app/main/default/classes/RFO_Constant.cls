/***
* Class Name: RFO_Constant
***/
public class RFO_Constant {
    /* Roles and Profiles */
    public static final String PROFILE_RFO_SALES = 'Sales Customer';
    public static final String PROFILE_RFO_PORTFOLIO_CONTRACT_PRICING = 'RFO - Portfolio Contract & Pricing';
    public static final String SALES_PROFILE = 'Sales Customer';
    public static final String PROFILE_SYSTEM_ADMIN = 'System Administrator';
    public static final String ROLE_COMMERCIAL_SOUTHWEST40 = 'RFO_Commercial_South_West_40';
    public static final String ROLE_COMMERCIAL_EAST20 = 'Commercial - East-20';
    public static final String ROLE_COMMERCIAL_EAST40 = 'Commercial - East-40';
    public static final String ROLE_CONTRACT_ADMINISTRATION60 = 'RFO_Contract_Administration_60';
    public static final String ROLE_BUSDEV_MGT_SERV_40 = 'RFO_Business_Development_Mgt_Services_40';
    public static final String ROLE_PROD_PLAN_60 = 'Production_Planning_60';
    public static final String PROFILE_PRODUCTS_AND_ORDERS = 'Products and Orders';
    
    /* REST call related */
    public static final String  APPLICATION_JSON= 'application/json';
    public static final String CONTRACT_URL = 'https://dev-api.trinityrail.com:8431/tst/v1/contract/api/contract';
    public static final String APILINK_EX = 'http://example.com/example/test';
    public static final String RECORD_CREATED = 'Created';
    public static final String RECORD_UPDATED = 'Updated';
    public static final String GET_METHOD = 'GET';
    public static final String POST_METHOD = 'POST';
    public static final String PUT_METHOD = 'PUT';
    /*Other constants*/
    public static final Integer ZERO = 0;
    public static final String COMMA = ',';
    public static final String BLANK_SPACE = ' ';
    public static final string TILDE_SYMBOL = '~';
    public static final String ACCOUNT_OBJECT = 'Account';
    public static final String CONTRACT_OBJECT = 'Contract';
    public static final String CASE_OBJECT = 'Case';
    public static final String ORDERASSET = 'OrderAsset';
    public static final String OPPORTUNITY_OBJECT = 'Opportunity';
    public static final String ASSETFILE_OBJECT = 'Asset File';
    public static final String PARENT_ASSETFILE = 'Plain';
    public static final String FILESPLIT_ASSETFILE = 'File Split';
    public static final String ASSETFILE_FILESPLIT = 'AssetFile_FileSplit';
    public static final String GLOBALACCOUNTID = '67656';
    public static final String CASESTATUS = 'Engineering Review';
    public static final String OPP_RECORDTYPE_TANK = 'Tank';
    public static final String OPP_RECORDTYPE_FREIGHT = 'Freight';
    public static final String OPP_RECORDTYPE_RENEWALS = 'Renewals';
    public static final String OPP_RECORDTYPE_MANAGE_SERVICES = 'Management Services';
    public static final String MANAGEMENT_AGREEMENT = 'Management Agreement';
    public static final String MAINTENANCE_AGREEMENT = 'Maintenance Agreement';
    public static final String RFO_MANAGEMENT_SERVICES = 'RFO_ManagementServices';
    public static final String MANAGEMENT_SERVICE = 'Management Service';
    public static final String OPP_TRANS_TYPE_FULL_SERVICE_LEASE  = 'Full Service Lease';
    public static final String OPP_TRANS_TYPE_NET_LEASE  = 'Net Lease';
    public static final String OPP_TRANS_TYPE_DIRECT_SALE = 'Direct Sale';
    public static final String OPP_TRANS_TYPE_NOT_PROVIDED_BY_CUSTOMER  = 'Not Provided by Customer';
    public static final String OPP_PREFERRED_NEW_EXISTING_NEW  = 'New';  
    public static final String OPP_PREFERRED_NEW_EXISTING_EXISTING = 'Existing';
    public static final String OPP_PREFERRED_NEW_EXISTING_NO_PREFERENCE = 'No Preference';
    public static final String  LEASING= 'LEASING';
    public static final String  LEASE= 'Lease';
    public static final String  POST_PARENT_ASSET_FILE= 'PostParentAssetFile';
    public static final String  PUT_FILESPLIT_ASSET_FILE= 'PutFileSplitAssetFile';
    public static final String  FILENUMBER= 'fileNumber';
    public static final String ACCOUNT_TEAM_MEMBER = 'AccountTeamMember';
    public static final String LABEL_URI_CONTRACT = 'Contract';
    public static final String CUSTOMER_DELIVERY_MANAGER = 'Customer Delivery Manager';
    public static final String CUSTOMER_DELIVERY_DIRECTOR = 'Customer Delivery Director';
    public static final String MESSAGE = 'message';
    public static final String RIDER = 'Rider';
    public static final String BATCH = 'Batch';
    public static final String TRIGER = 'Trigger';
    public static final String RENEWAL_OPPORTUNITY = 'RFO_Renewals';
    public static final String CUSTOMER_DELIVERY_QUEUE = 'Customer_Delivery';
    public static final String CONTRACT_ADMIN_FREIGHT_QUEUE = 'Contract_Admin_Freight';
    public static final String CONTRACT_ADMIN_TANK_QUEUE = 'Contract_Admin_Tank';
    public static final String RFO_CASE = 'RFO_Case';
    public static final String RFO_CLOSED_CASE = 'RFO_Closed_Case';
    public static final String RFO_CASE1 = 'RFO_Case1';
    public static final String RFO_CLOSED_CASE1 = 'RFO_Closed_Case1';
    public static final String RFO_CASE_NewCar = 'RFO_NewCarChangeRequest';
    public static final String RFO_CASE_Existing_Car = 'RFO_ExistingCarChangeRequest';
    public static final String RFO_CASE_Amortization = 'RFO_AmortizationRevisionChangeRequest';
    public static final String RFO_Account_ThirdParty_Prospect_RT = 'Third Party Prospect';
    public static final String RFO_Account_Prospect_RT = 'Prospect';
    public static final String RFO_Account_ThirdParty_Sales_RT = 'Third Party Sales';
    public static final String RFO_Account_Customer_RT = 'Customer';
    public static final String QUEUE = 'Queue'; 	
    public static final String FULLY_TERMINATED = 'Fully Terminated';
    public static final String DO_NOT_RENEW = 'Do Not Renew';
    public static final String RIDER_CANCELLED = 'Rider Cancelled';
    public static final String RIDER_FULLY_TERMINATED  = 'Rider Fully Terminated';
    public static final String YES = 'Yes';
    public static final String MAINTENANCE_SERVICE = 'Maintenance Service';
    public static final String INITIATED = 'Initiated';
    public static final String TRINITY_LEASE_EXPIRATIONS = 'Trinity Lease Expirations';
    public static final String NULL_STRING = 'NULL';
    public static final String MEDIUM = 'Medium';
    public static final String ASSET_TRACKING = 'Asset Tracking';
    public static final String OPTY_TEST_NAME = 'Opty Test Name';
    public static final String PASS_THROUGH_MANAGEMENT = 'Pass Through Management';
    public static final String MAINTENANCE = 'Maintenance';
    public static final String MANAGEMENT = 'Management';
    //public static final String RENEWAL_RIDER_CREATED = 'Renewal Rider Created';
    public static final String RENEWAL_RIDER_INITIATED = 'Renewal Rider Initiated';
    public static final String ACCOUNT_MOODYS_RATING = 'Account Moodys Rating Change:';
    public static final String ACCOUNT_SANDP_RATING = 'Account S&PRating Change:';
    public static final String ACCOUNT_OWNER_CHANGE = 'Account Owner Change:';
    public static final String ACCOUNT_TEAM_MEMBER_MESSAGE = 'Account Team Member:';
    public static final String R_CREATE = 'Create';
    public static final String R_UPDATE = 'Update';
    public static final String PER_DIEM = 'Per Diem';
    public static final String FULL_SERVICE = 'Full Service';
    public static final String OPTY_STAGE_NAME = 'Hold - Auto Renewal';
    public static final String NO = 'No';
    public static final String RFO_OM_CONTRACT_PS = 'RFO_OM_Contracts';
    public static final String CONTRACTID = 'contractId';
    public static final String SYNC_SUCCEEDED = 'Sync Succeeded';
    public static final String SYNC_FAILED = 'Sync Failed';
    public static final String PAYLOAD_PARAM_KEY_RESTMETHOD = 'restMethod';
    public static final String CONTRACT_STAUS_NEW = 'New';
    public static final String CONTRACT_TYPE_DIRECT_SALE = 'DIRECT SALE';
    public static final String CONTRACT_TYPE_NET_LEASE = 'NET LEASE';
    public static final String PS_RFO_OM_PROD_PLANNING = 'RFO_OM_Prod_Planning';
    public static final String PS_RFO_OM_MGMT_SRVCS = 'RFO_OM_Management_Services';
    public static final String ADDITIONAL_LEASE_RATE_FACTOR_ERROR = 'Additional Lease Rate Factor, expecting decimal value';
    public static final String INTGRN_RSPNS_STATUS_SUCCESS = 'success';
    public static final String INTGRN_RSPNS_STATUS_FAILURE = 'failure';
    public static final String INTGRN_RSPNS_STATUS_KEY = 'status';
    public static final String INTGRN_RSPNS_MSG_KEY = 'message';
    public static final String NOTIFICATION_TYPE_INFO = 'info';
    public static final String NOTIFICATION_TYPE_ERROR = 'error';
    public static final String NOTIFICATION_TYPE_SUCCESS = 'success';
    public static final String NOTIFICATION_TAS_SUCCESS = 'Send to TAS request succeeded!';
    public static final String NOTIFICATION_TAS_FAILURE = 'Send to TAS request failed!';
    public static final String NO_CONTRACT = 'No Contract';
    public static final String CUSTOMER_ACCOUNT = 'FREYM_TST';
    public static final String LAN_ID = 'HARRISB2_TST';
    public static final String SLS_USER_ID = 'testSlsUser@trin.net';
    public static final String PROPOSAL_FRESH_STATUS = 'Resubmit for Pricing';
    public static final String CONTRACT_USER_ID = 'testContractUser@trin.net';
    public static final String COMPLETION_OF_MODIFICATION = 'Completion of Modification';
    public static final String TEST = 'test';
    public static final String READY_FOR_DELIVERY = 'Ready for Delivery';
    public static final String TEST_OPPORTUNITY = 'Test Opportunity1';
    public static final String TEST_MGT_SERV_USERID = 'testMgmtSrvcsUser@trin.net';
    public static final String TEST_PROD_PLAN_USERID = 'testProdPlanningUser@trin.net';
    public static final String TEST_DAVISM_LANID = 'DAVISM_TST';
    public static final String TEST_FLACKK_LANID = 'FLACKK_TST';
    public static final String NINE = '9';
    public static final String ACCOUNT_INTEGRATION_LINK = 
        'https://dev-api.trinityrail.com:8431/tst/v1/account/api/account';
    public static final String THIRTY = '30';
    public static final String DRAFT = 'Draft';
    public static final String SALES_MANAGER = 'Sales Manager';
    public static final String TANK = 'RFO_Tank';
    public static final String ORDER_NEWCAR = 'RFO_NewCar';
    public static final String ORDER_EXISTINGCAR = 'RFO_ExistingCar';
    public static final String ORDER_Retanking = 'Retanking';// Added by Vihari EPSI-691
    public static final String FREIGHT = 'RFO_Freight';
    public static final String ORDER_OBJECT = 'Order';
    public static final String QUOTE_OBJECT = 'Quote';
    public static final String ACCOUNT_TASID ='1234';
    public static final String ACCOUNT_GLOBALACCOUNTID = '14098';
    public static final String ACCOUNT_ORACLEID = '123456';
    public static final String PRICEBOOK_NAME = 'Standard Price Book';
    public static final String ACCOUNT_NAME = 'Test1';
    public static final String ACCOUNT_NAME_TEST = 'Test';
    public static final String PROPOSAL_REQUIRED = 'Yes';
    public static final String TANK_RECORD_TYPE = 'Tank';
    public static final String ORDER_CAR_TYPE = '200# CI';
    public static final String ORDER_TYPE_DIRECT_SALE = 'Direct Sale';
    public static final String RIDER_TYPE = 'Net Lease';
    public static final String RIDER_STATUS = 'Rider Initiated';
    public static final String OPPORTUNITY_NAME = 'Test Opportunity1';
    public static final String OPPORTUNITY_PRODUCT_TYPE = 'High Pressure Large';
    public static final String OPPORTUNITY_CONFIDENCE_LEVEL = 'High';
    public static final String SUCCESS='Success';







	// File Type
    public static final String FILE_TYPE_SIGNED_PROPOSAL='Signed Proposal';
    //chatter Group
    public static final String CHATTER_FLEET_ENGG= 'Fleet Engineering';
    public static final String CHATTER_SIGNED_PROPOSAL= 'Signed Proposal Notifications';
    //Quote Status
    public static final string BUSINESS_AWARDED= 'Business Awarded';





    // Asset Disposition
    public static final string ASSET_DISPOSITION_COMPLETE= 'Disposition Information - Complete';






      //Haseeb, Alpha-521, Date: Sep 21 2020, Case and order status for OrderStatusUpdateHelper
    public static final String Case_Status_Acknowledge = 'Change Request Acknowledged';
    public static final String Case_Status_Rejected = 'Change Request Rejected';
    public static final String Case_Status_Engineering_Review = 'Engineering Review';      // Added by Vihari Alpha-677
    public static final String Case_Status_Closed = 'Closed';
    public static final String Case_Status_Cancelled = 'Change Request Cancelled';
    public static final String Order_Status_Complete = 'Change Request Complete';
    public static final String Order_Status_Process = 'Order in Process';
    //End, Alpha-521
    
    //Added By Vihari EPSI-429
    public static final String Order_Status_Materials_Planning = 'Materials/Planning';

    // Added by Ramesh EPSI-460
        public static final String Case_Change_Analysis_Approved = 'Change Analysis Approved';
        public static final String Case_Change_Analysis_Rejected = 'Change Analysis Rejected';



    //Ashish Reddy    ALPHA - 166
    public static final String STATUS_DELIVERY_COMPLETE = 'Delivery complete';
    public static final String ORDER_STATUS_INTERNAL_ORM = 'Internal ORM';
    public static final String ORDER_STATUS_EXTERNAL_ORM = 'External ORM';

	//Vihari ALPHA-771
	public static final String ESCALATION_SERVICE_ACCOUNT_NAME = 'Email Service Account';
	public static final String ESCALATION_SERVICE_CONTACT_EMAIL = 'serviceaccountdummy@test.com';



    /* Added by Vihari ALPHA - 932 */
    // Opportunity Stagenames
    public static final String Opportunity_Stage_Initiated = 'Initiated';
    public static final String Opportunity_Stage_Ready_to_Quote	 = 'Ready to Quote';
    public static final String Opportunity_Stage_Closed_Won = 'Closed-Won';
    public static final String Opportunity_Stage_Closed_Withdrawn = 'Closed-Withdrawn';
    public static final String Opportunity_Stage_Closed_Lost = 'Closed-Lost';
    public static final String Opportunity_Stage_Prospecting = 'Prospecting';
    public static final String Opportunity_Stage_Closed_Termination = 'Closed-Termination';
    public static final String Opportunity_Stage_Closed_Renewed = 'Closed-Renewed';
    public static final String Opportunity_Stage_Needs_Analysis = 'Needs Analysis';
    
    //Ramesh Guguloth ALPHA - 676
    public static final String Material_Cost_Review = 'Material Cost Review';
    public static final String Operations_Review = 'Operations Review';
   
    //Ramesh Guguloth    ALPHA - 529
    public static final String Email_Content = 'New Engineering Specification uploaded to RF1 for';
    public static final String Email_Subject = 'New Engineering Specification Uploaded:';
    public static final String Prototype = 'Prototype';
    public static final String Advanced_Order = 'Advanced Order';
    public static final String AssetFile_RecordType = 'Asset_File';
    public static final String File_Type = 'Car Specification';
    
    //AccountTeamMember Role
    public static final String Account_Member_Role_CDM = 'Customer Delivery Manager';
    
    //Task Status
    public static final String Task_Status_Open = 'Open';
    
    //Task Priority
    public static final String Task_Priority_Normal = 'Normal';
    
    /* Added by Lakshmi ALPHA - 645 */
    public static final String Customer_Delivery = 'Customer Service';
    public static final String Customer_Status_Engineering = 'Engineering';
    public static final String Project_Alert_MTD_Name = 'Project_Alert';
    
    /* Added by Lakshmi ALPHA - 646 */    
    public static final String Order_Alert_MTD_Name = 'Order_Alert';
    public static final String Order_Queue_Name = 'Order_Review_Meeting';
    
	/* Added by Lakshmi ALPHA - 582 */
	public static final String Project_Capacity_Planning = 'Capacity Planning';
    public static final String Project_Planning = 'Planning';
    public static final String Project_Escalation_MTD_Name = 'Project_Alert_Esc';
    public static final String Project_Escalation_Task_Subject = 'Project is interfaced to RF1';
    
    /* Added by Lakshmi ALPHA - 1748 */
    public static final String Order_Is_Project_Available_MTD_Name = 'Order_Is_Project_Available'; 
    
    /* Added by Lakshmi ALPHA - 581 */
    public static final String Order_Escalation_MTD_Name = 'Order_Alert_Esc';
    
    // Vihari ALPHA - 22
    public static final String Assumption_Status_Initiated = 'Initiated';
    public static final String Assumption_Status_InProcess = 'In-Process';
    
    //Ramesh Guguloth    ALPHA - 587 / 588
    public static final String Customer_Service = 'Customer Service';
    public static final String Engineering = 'Engineering';
    public static final String Submitted = 'Submitted';
    
     // Vihari ALPHA-530
     public static final String ORDER_TYPE_LEASE = 'Lease';
     public static final String ORDER_SUBTYPE_NET_LEASE = 'Net Lease';
}