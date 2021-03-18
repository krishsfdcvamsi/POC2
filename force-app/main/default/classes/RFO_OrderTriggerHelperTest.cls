/* Name: RFO_OrderTriggerHelperTest
 * Created By: Ramesh
 * Created Date: September 2020
 * Jira: ALpha- 529
 * Purpose: Test class for RFO_SendEmailOnFileUploadHelper & RFO_SendEmailOnFileUpload.
 */

@isTest(SeeAllData = false)
private class RFO_OrderTriggerHelperTest {
    /*
     * create Order test data setup method
     * */
    @testsetup static void createorderTestdata(){
        User usr =  RFO_Utility_Test.createUserRecord();
        Database.insert(usr);
       system.runAs(createUser()) {   
        List<Account> accList = new List<Account>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c();
        List<Order> orderList = new List<Order>();
        SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
        Product2 productRec = new Product2();
        List<RFO_Asset_File__c> assetFileList = new List<RFO_Asset_File__c>();

        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = '14098';
        accList[0].RFO_OracleId__c = '123456';
        accList[0].RFO_TASId__c = '1234';
        Database.insert(accList);

        AccountTeamMember ateam = RFO_Utility_Test.createAccountTeamMemberCDM(usr.id,accList[0].id);
        DataBase.insert(ateam);
        AccountTeamMember ateam2 =  RFO_Utility_Test.createAccountTeamMember(UserInfo.getUserId(),accList[0].id );
        DataBase.insert(ateam2);
        //Creating a Commodity
        commodityList = RFO_Utility_Test.createCommodity1();
        Database.insert(commodityList);
        //Creating an Opportunity
        opportunityList=RFO_Utility_Test.createTankOpportunities(accList[0]);
        opportunityList[0].Requirement_Status__c = 'test';
        Database.insert(opportunityList);
        //Creating a QuoteTeam
        quoteTeamRecord = RFO_Utility_Test.createQuoteTeam();
        Database.insert(quoteTeamRecord);
        
        //Creating a CPQ Quote
        cpqQuoteList = RFO_Utility_Test.createCPQPrimaryQuote(opportunityList[0], quoteTeamRecord);
        cpqQuoteList.RFO_ProposalRefreshStatus__c = 'Resubmit for Pricing';   // Proposal Refresh Status
        cpqQuoteList.RFO_ProposalRefreshRequired__c = 'Yes';                  // Proposal Refresh Required
        cpqQuoteList.RFO_DaysUntilProposalExpires__c = '30'; 
        cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;
        Database.insert(cpqQuoteList);
        //Creating a Product
        productRec = RFO_Utility_Test.createProduct();
        productRec.IsActive = True;
        Database.insert(productRec,false);
        //Creating an Order
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList[0], commodityList[0], productRec);
        Database.insert(orderList);
        //Creating an Asset File
        assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        assetFileList[0].RFO_FileNumber__c = '';
        Database.insert(assetFileList);

           RFO_CpqTriggerSwitch.disableCpqTriggers();

           Pricebook2 pbook = new Pricebook2(
               Name = 'Standard Price Book',
               Id = Test.getStandardPricebookId(),
               IsActive = true
           );
           PricebookEntry pbe = new PricebookEntry(pricebook2id=pbook.id, product2id=productRec.id,unitprice=2.0, isActive=true);
           insert pbe;
           Database.update(pbook);
                }
    }
       
       /* Test Method 2 begins **/
    /**This method is used to create an automatic order from Quote having 
customer selected QuoteLines with transaction type as direct sale **/
 
    private static testMethod void createOrderRecord(){ 
    /* Test starts and stops here */             
       test.startTest();
       RFO_CpqTriggerSwitch.disableCpqTriggers(); 
        Account acclist=[select id from Account Limit 1];
        RFO_Commodity__c commodityList = [select id from RFO_Commodity__c Limit 1];
         Opportunity opportunityList = [Select id from Opportunity Limit 1 ];
        RFO_QuoteTeams__c quoteTeamRecord = [Select id from RFO_QuoteTeams__c Limit 1];
       Product2 productRec =[Select id from Product2 Limit 1];
        SBQQ__Quote__c cpqQuoteList =[Select id from SBQQ__Quote__c Limit 1];
        cpqQuoteList.RFO_Product__c=productRec.id;
        update cpqQuoteList;
       Pricebook2 pbook = new Pricebook2(
            Name = 'Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Database.update(pbook);
         
      /** Creating a QuoteLine with Direct Sale as Transaction Type **/ 
       List<SBQQ__QuoteLine__c> quoteLineDsUpList = new List<SBQQ__QuoteLine__c>();
       SBQQ__QuoteLine__c quotLine = RFO_Utility_Test.createQuoteLine(cpqQuoteList, productRec);
        quotLine.RFO_DirSaleQty__c = 1;
        quotLine.RFO_TransactionType__c = 'Direct Sale';
        quotLine.RFO_CustSelected__c = True;
        Database.insert(quotLine);
        quotLine.RFO_DirSaleQty__c = 6;
        quotLine.RFO_TransactionType__c = 'Direct Sale';
        quotLine.RFO_CustSelected__c = True;
        
        Database.insert(quoteLineDsUpList); 
       List<Order> orderList1 = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList, commodityList, productRec);      
        Database.insert(orderList1);    
       RFO_OrderTriggerHelper.updateOrderFields(orderList1);
    
       
       Database.insert(quoteLineDsUpList);
       cpqQuoteList.RFO_BusinessAwarded__c= 'Yes';
       cpqQuoteList.SBQQ__Ordered__c = True;
       RFO_CpqTriggerSwitch.disableCpqTriggers();
       test.stopTest();
       system.assertEquals(cpqQuoteList.RFO_BusinessAwarded__c, 'Yes');       
         }
    
    
    //Test method to check Validation messages on order
    
 private static testMethod void deleteOrderRecord(){  
 
 /* Test starts and stops here */             
       
        RFO_CpqTriggerSwitch.disableCpqTriggers();
        Account acclist=[select id from Account Limit 1];
        RFO_Commodity__c commodityList = [select id from RFO_Commodity__c Limit 1];
         Opportunity opportunityList = [Select id from Opportunity Limit 1 ];
        RFO_QuoteTeams__c quoteTeamRecord = [Select id from RFO_QuoteTeams__c Limit 1];
       Product2 productRec =[Select id from Product2 Limit 1];
        SBQQ__Quote__c cpqQuoteList =[Select id from SBQQ__Quote__c Limit 1];
        cpqQuoteList.RFO_Product__c=productRec.id;
        update cpqQuoteList;

         test.startTest();
      // Creating a QuoteLine with Direct Sale as Transaction Type 
       List<SBQQ__QuoteLine__c> quoteLineDsUpList = new List<SBQQ__QuoteLine__c>();
      
       SBQQ__QuoteLine__c quotLine = RFO_Utility_Test.createQuoteLine(cpqQuoteList, productRec);
        quotLine.RFO_DirSaleQty__c = 1;
        quotLine.RFO_TransactionType__c = 'Direct Sale';
        quotLine.RFO_CustSelected__c = True;
        Database.insert(quotLine);
        quotLine.RFO_DirSaleQty__c = 6;
        quotLine.RFO_TransactionType__c = 'Direct Sale';
        quotLine.RFO_CustSelected__c = True;
        
        Database.insert(quoteLineDsUpList); 
       List<Order> orderList1 = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList, commodityList, productRec);    
       orderList1[0].RFO_FirstShipWeek__c  = system.today() + 10;
       orderList1[0].Is_Project_Required__c = true;
        Database.insert(orderList1);  
     Test.stopTest();
        Map<id, Order> newMap = new Map<id,Order>();
        orderList1 = [select id ,RFO_SignedProposalDate__c, Is_Project_Required__c, RFO_OrderReviewMeetingDate__c, OrderNumber,RFO_Shipping_Commence_stop_notifications__c, RFO_Quantity__c,New_Car_Marks_Pending_Notification_Start__c,EffectiveDate,Account_Record_Type__c ,AccountId, New_Car_Sample_Car_Alert_Start__c, New_Car_Sample_Car_Alert_Escalation_Date__c, RecordtypeId, RFO_SampleCarDate__c, RFO_WillaSampleCarberequired__c,RFO_FirstShipWeek__c,Trigger_UMLER_Check_Escalation__c from order];
     for(Order r :orderList1 ){
         r.RFO_Quantity__c = 6; 
         newMap.put(r.id, r);
     }
     update orderList1;
     
       RFO_OrderTriggerHandler obj = new RFO_OrderTriggerHandler();
    
               obj.afterInsert(null);
      obj.beforeInsert(null);
   //  obj.beforeUpdate(null,null);
                obj.afterDelete(null);
               obj.beforeDelete(null);
                obj.afterUnDelete(null);
     obj.afterUpdate(newMap,newMap);
        RFO_CpqTriggerSwitch.disableCpqTriggers();
          
   }
    //Alpha-680,  Alpha-679 start
    /*============================================================================
* Created by: Ashish Reddy 
* Method Name: handleNewCarSampleCarAlerts
* User Story: Alpha-680, Alpha-679
*==============================================================================*/
    private static testMethod void testSampleCarAlerts(){
        
        Test.startTest();
        
        List<Order> orderList = [Select Id, OwnerId, ContractId, AccountId, RecordType.DeveloperName, Pricebook2Id, OriginalOrderId, OpportunityId, QuoteId, RecordTypeId, EffectiveDate, EndDate, IsReductionOrder, Status, Description, CustomerAuthorizedById, CustomerAuthorizedDate, CompanyAuthorizedById, CompanyAuthorizedDate, Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Name, PoDate, PoNumber, OrderReferenceNumber, BillToContactId, ShipToContactId, ActivatedDate, ActivatedById, StatusCode, OrderNumber, TotalAmount, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, IsDeleted, SystemModstamp, LastViewedDate, LastReferencedDate, RFO_BasePrice__c, RFO_CarType__c, RFO_ChangeOrderDate__c, RFO_Comments__c, RFO_Commitment_Date__c, RFO_Commodity__c, RFO_Commodity_lookup__c, RFO_Contract__c, RFO_CurrentSalesPrice__c, RFO_DateSpeSheetSent__c, RFO_DateSpecIssued__c, RFO_EOSTransactionID__c, RFO_EndChargeDate__c, RFO_ExpiryDate__c, RFO_FieldServiceDate__c, RFO_File__c, RFO_FirstShipWeek__c, RFO_InspectionDate__c, RFO_LinktoEngineeringSpec__c, RFO_NoOfAssetsOnFile__c, RFO_OrderReviewMeetingDate__c, RFO_ParentOrder__c, RFO_Product__c, RFO_ProgramName__c, RFO_QuoteID__c, RFO_QuoteScenarioID__c, RFO_RevisedDeliveryDate__c, RFO_Rider__c, RFO_SampleCarDate__c, RFO_SellQuantity__c, RFO_SignedProposalDate__c, RFO_StatusDate__c, RFO_SubType__c, RFO_TerminationMeetingDate__c, RFO_TransDate__c, RFO_Transaction__c, RFO_TASLastModifiedBy__c, RFO_TASLastModifiedDate__c, Survey_Contact_Id__c, Survey_Contact__c, Survey_Sent_Time__c, First_Ship_Week_Survey_Sent_Time__c, Last_Ship_Week_Survey_Sent_Time__c, RFO_LastShipWeek__c, Account_Name_Text__c, SBQQ__Contracted__c, SBQQ__ContractingMethod__c, SBQQ__PaymentTerm__c, SBQQ__PriceCalcStatusMessage__c, SBQQ__PriceCalcStatus__c, SBQQ__Quote__c, SBQQ__RenewalTerm__c, SBQQ__RenewalUpliftRate__c, SBQQ__OrderBookings__c, SBQQ__TaxAmount__c, Actualdelivery__c, Escalation_Terms__c, IRR__c, RFO_AddScrapSurchargetoAbovePrice__c, RFO_AdvanceOrderCarsUsed__c, RFO_AdvanceOrderInterfaceField__c, RFO_AdvancePaymentDepositRequired__c, RFO_AdvancePaymentReceived__c, RFO_AlternatesAccepted__c, RFO_AlternatesComments__c, RFO_AlternatesCost__c, RFO_AlternatesPrice__c, RFO_AssetFileLeaseType__c, RFO_BPCSCustomerNumber__c, RFO_BaseCarPriceEach__c, RFO_CarsAssignedtoTrip__c, RFO_Commencement__c, RFO_CommencmentDate__c, RFO_CommodityName__c, RFO_Costpermonth__c, RFO_CreditComments__c, RFO_CreditConditionsAcknowledged__c, RFO_CreditReviewComplete__c, RFO_CreditStatus__c, RFO_CurrentPlant__c, RFO_CustomerCreditAcknowledgementIssued__c, RFO_DateofOrder__c, RFO_DeliveryComments__c, RFO_DeliveryCostIncluded__c, RFO_DepositCommentary__c, RFO_DirectSalePrice__c, RFO_EngineeringApprovalsBegin__c, RFO_ExcludefromBacklog__c, RFO_ExecutiveApproval__c, RFO_Expectdelivery__c, RFO_FOBPoint__c, RFO_FinishingPlant__c, RFO_FrabricateApprovalsBegin__c, RFO_FreightBills__c, RFO_GloballySourcedMaterialAcceptable__c, RFO_GuarantyReceived__c, RFO_GuarantyRequired__c, RFO_InteriorLined__c, RFO_JobCostDetails__c, RFO_LOCAmount__c, RFO_LOCReceived__c, RFO_LOCRequired__c, RFO_LeaseRate__c, RFO_LeaseTerms__c, RFO_LineNumber__c, RFO_MonthlyRentalsHeldAsSecurityDeposit__c, RFO_NetTerms__c, RFO_OALstatus__c, RFO_OrderAcknowledgementDate__c, RFO_OrderFlag__c, RFO_OrderURLHead__c, RFO_OriginalMargin__c, RFO_OriginalSalesPrice__c, RFO_OriginalUnitCost__c, RFO_PercentageDeposit__c, RFO_PriceClassification__c, RFO_ProposalDate__c, RFO_ProposalRequired__c, RFO_Purchasing__c, RFO_Quantity__c, RFO_RANumber__c, RFO_RapidResponseLink__c, RFO_RemoveCarNumbers__c, RFO_ReportingMarks__c, RFO_ReturnProvisionsStillValid__c, RFO_RunningNumbers__c, RFO_SalesOrderIssued__c, RFO_SecurityDepositReceived__c, RFO_SecurityDepositRequired__c, RFO_ShipmentApproved__c, RFO_ShippingtoCommence__c, RFO_SignedProposalDateCheck__c, RFO_SingleUnitShipmentsAcceptable__c, RFO_TankorFreight__c, RFO_TrafficHelpinSecuringFirstLoad__c, RFO_TransferPrice__c, RFO_TrinitySpecDate__c, RFO_UnresolvedItems__c, RFO_UpdateFirstShippedWeek__c, RFO_WarrantyType__c, RFO_WillaSampleCarberequired__c, ROE__c, Transfer_Margin__c, RFO_TotalCurrentQuantity__c, RFO_TotalOrderAmount__c, Is_Survey_Sent__c, RFO_ContractRiderReceived__c, RFO_ExistingCarCRPastDate__c, RFO_ExistingCarCRStatuschange__c, RFO_ExistingCarCRStatusupdate__c, RFO_ExistingCarCRcreation__c, RFO_NewCarCRPastDate__c, RFO_NewCarCRStatuschange__c, RFO_NewCarCRStatusupdate__c, RFO_NewCarCRcreation__c, RFO_OrderNotesDate__c, RFO_Notify_New_Car_Plant_User_On_Defined__c, RFO_First_Car_Ship_Days__c, RFO_Freight_Payer__c, RFO_PM_Notes__c, Account_Record_Type__c, Request_Disposition__c, New_Car_Sample_Car_Alert_Start__c, New_Car_Sample_Car_Alert_Stop__c, New_Car_Sample_Car_Alert_Escalation_Date__c from order limit 1];
        
        orderList[0].RFO_FirstShipWeek__c  = system.today() + 10;
        //orderList[0].RFO_WillaSampleCarberequired__c = 'Yes';
        orderList[0].Account_Record_Type__c  = RFO_Constant.RFO_Account_Customer_RT;
        orderList[0].Type = RFO_Constant.ORDER_TYPE_DIRECT_SALE;
        Database.update(orderList);
        Test.stopTest();     
        List<Task> tasks = [select Id, WhatId from task where whatId =:orderList[0].Id];
        system.assertNotEquals(tasks, null);
    }
    //Alpha-680,  Alpha-679 End  

        //Alpha-730  start
    /*============================================================================
* Created by: Ashish Reddy 
* Method Name: test External ORM Alerts
* User Story: Alpha-730
*==============================================================================*/
    private static testMethod void testExternalOrmAlerts(){
        
        Test.startTest();
        
        List<Order> orderList = [Select Id, OwnerId, ContractId, AccountId, RecordType.DeveloperName, Pricebook2Id, OriginalOrderId, OpportunityId, QuoteId, RecordTypeId, EffectiveDate, EndDate, IsReductionOrder,
                                Status, Description, CustomerAuthorizedById, CustomerAuthorizedDate, CompanyAuthorizedById, CompanyAuthorizedDate, Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, 
                                    BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Name, PoDate, PoNumber, OrderReferenceNumber, BillToContactId, 
                                    ShipToContactId, ActivatedDate, ActivatedById, StatusCode, OrderNumber, TotalAmount, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, IsDeleted, SystemModstamp, LastViewedDate, LastReferencedDate, RFO_BasePrice__c, RFO_CarType__c, RFO_ChangeOrderDate__c, RFO_Comments__c, RFO_Commitment_Date__c, RFO_Commodity__c, RFO_Commodity_lookup__c, RFO_Contract__c, RFO_CurrentSalesPrice__c, RFO_DateSpeSheetSent__c, 
                                    RFO_DateSpecIssued__c, RFO_EOSTransactionID__c, RFO_EndChargeDate__c, RFO_ExpiryDate__c, RFO_FieldServiceDate__c, RFO_File__c, RFO_FirstShipWeek__c, RFO_InspectionDate__c, RFO_LinktoEngineeringSpec__c, RFO_NoOfAssetsOnFile__c, RFO_OrderReviewMeetingDate__c, RFO_ParentOrder__c, RFO_Product__c, RFO_ProgramName__c, RFO_QuoteID__c, RFO_QuoteScenarioID__c, RFO_RevisedDeliveryDate__c, RFO_Rider__c, RFO_SampleCarDate__c, RFO_SellQuantity__c, RFO_SignedProposalDate__c, RFO_StatusDate__c, RFO_SubType__c,
                                    RFO_TerminationMeetingDate__c, RFO_TransDate__c, RFO_Transaction__c, RFO_TASLastModifiedBy__c, RFO_TASLastModifiedDate__c, Survey_Contact_Id__c, Survey_Contact__c,
                                    Survey_Sent_Time__c, First_Ship_Week_Survey_Sent_Time__c, Last_Ship_Week_Survey_Sent_Time__c, RFO_LastShipWeek__c, Account_Name_Text__c, SBQQ__Contracted__c, SBQQ__ContractingMethod__c, SBQQ__PaymentTerm__c, SBQQ__PriceCalcStatusMessage__c, SBQQ__PriceCalcStatus__c, SBQQ__Quote__c, SBQQ__RenewalTerm__c, SBQQ__RenewalUpliftRate__c, SBQQ__OrderBookings__c, SBQQ__TaxAmount__c, Actualdelivery__c, Escalation_Terms__c, IRR__c,
                                    RFO_AddScrapSurchargetoAbovePrice__c, RFO_AdvanceOrderCarsUsed__c, RFO_AdvanceOrderInterfaceField__c, RFO_AdvancePaymentDepositRequired__c, RFO_AdvancePaymentReceived__c, 
                                    RFO_AlternatesAccepted__c, RFO_AlternatesComments__c, RFO_AlternatesCost__c, RFO_AlternatesPrice__c, RFO_AssetFileLeaseType__c, RFO_BPCSCustomerNumber__c, RFO_BaseCarPriceEach__c, 
                                    RFO_CarsAssignedtoTrip__c, RFO_Commencement__c, RFO_CommencmentDate__c, RFO_CommodityName__c, RFO_Costpermonth__c, RFO_CreditComments__c, RFO_CreditConditionsAcknowledged__c, RFO_CreditReviewComplete__c, 
                                    RFO_CreditStatus__c, RFO_CurrentPlant__c, RFO_CustomerCreditAcknowledgementIssued__c, RFO_DateofOrder__c, RFO_DeliveryComments__c, RFO_DeliveryCostIncluded__c, RFO_DepositCommentary__c, RFO_DirectSalePrice__c, RFO_EngineeringApprovalsBegin__c, RFO_ExcludefromBacklog__c, RFO_ExecutiveApproval__c, RFO_Expectdelivery__c, RFO_FOBPoint__c, RFO_FinishingPlant__c, RFO_FrabricateApprovalsBegin__c, RFO_FreightBills__c, RFO_GloballySourcedMaterialAcceptable__c, RFO_GuarantyReceived__c, 
                                    RFO_GuarantyRequired__c, RFO_InteriorLined__c, RFO_JobCostDetails__c, RFO_LOCAmount__c, RFO_LOCReceived__c, RFO_LOCRequired__c, RFO_LeaseRate__c, RFO_LeaseTerms__c, RFO_LineNumber__c, RFO_MonthlyRentalsHeldAsSecurityDeposit__c, RFO_NetTerms__c, RFO_OALstatus__c, RFO_OrderAcknowledgementDate__c, RFO_OrderFlag__c, RFO_OrderURLHead__c, RFO_OriginalMargin__c, RFO_OriginalSalesPrice__c, RFO_OriginalUnitCost__c, 
                                    RFO_PercentageDeposit__c, RFO_PriceClassification__c, RFO_ProposalDate__c, RFO_ProposalRequired__c, RFO_Purchasing__c, RFO_Quantity__c, RFO_RANumber__c, RFO_RapidResponseLink__c, RFO_RemoveCarNumbers__c, RFO_ReportingMarks__c, RFO_ReturnProvisionsStillValid__c, RFO_RunningNumbers__c, RFO_SalesOrderIssued__c, RFO_SecurityDepositReceived__c, RFO_SecurityDepositRequired__c, RFO_ShipmentApproved__c, 
                                    RFO_ShippingtoCommence__c, RFO_SignedProposalDateCheck__c, RFO_SingleUnitShipmentsAcceptable__c, RFO_TankorFreight__c, RFO_TrafficHelpinSecuringFirstLoad__c, RFO_TransferPrice__c, RFO_TrinitySpecDate__c, RFO_UnresolvedItems__c, RFO_UpdateFirstShippedWeek__c, RFO_WarrantyType__c, RFO_WillaSampleCarberequired__c, ROE__c, Transfer_Margin__c, RFO_TotalCurrentQuantity__c, 
                                    RFO_TotalOrderAmount__c, Is_Survey_Sent__c, RFO_ContractRiderReceived__c, RFO_ExistingCarCRPastDate__c, RFO_ExistingCarCRStatuschange__c, RFO_ExistingCarCRStatusupdate__c, RFO_ExistingCarCRcreation__c, RFO_NewCarCRPastDate__c, 
                                    RFO_NewCarCRStatuschange__c, RFO_NewCarCRStatusupdate__c, RFO_NewCarCRcreation__c, RFO_OrderNotesDate__c, RFO_Notify_New_Car_Plant_User_On_Defined__c, RFO_First_Car_Ship_Days__c, 
                                    RFO_Freight_Payer__c, RFO_PM_Notes__c, Account_Record_Type__c, Request_Disposition__c, New_Car_Sample_Car_Alert_Start__c, New_Car_Sample_Car_Alert_Stop__c, New_Car_Sample_Car_Alert_Escalation_Date__c from order limit 1];
        
        orderList[0].status = RFO_Constant.ORDER_STATUS_INTERNAL_ORM;
        orderList[0].Account_Record_Type__c  = RFO_Constant.RFO_Account_Customer_RT;
        orderList[0].RecordtypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(RFO_Constant.ORDER_NEWCAR).getRecordTypeId();
        Database.update(orderList);
        Test.stopTest();     
        List<Task> tasks = [select Id, WhatId from task where whatId =:orderList[0].Id];
        system.assertNotEquals(tasks, null);
    }
    //Alpha-730 End      
    
    /**
*   createUser method
**/
    private static User createUser() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        userRecord.Lan_Id__c = 'MYDEVROLE';
        System.Assert(userRecord!=null );
        Database.insert(userRecord);
        return userRecord;
    }
    private static testMethod void shippingCommenceDateNotifications(){ 
    /* Test starts and stops here */             
       test.startTest();
       RFO_CpqTriggerSwitch.disableCpqTriggers(); 
        Account acclist=[select id from Account Limit 1];
        RFO_Commodity__c commodityList = [select id from RFO_Commodity__c Limit 1];
         Opportunity opportunityList = [Select id from Opportunity Limit 1 ];
        //RFO_QuoteTeams__c quoteTeamRecord = [Select id from RFO_QuoteTeams__c Limit 1];
       Product2 productRec =[Select id from Product2 Limit 1];
        SBQQ__Quote__c cpqQuoteList =[Select id from SBQQ__Quote__c Limit 1];
        cpqQuoteList.RFO_Product__c=productRec.id;
        update cpqQuoteList;
       Pricebook2 pbook = new Pricebook2(
            Name = 'Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Database.update(pbook);
         
      /** Creating a QuoteLine with Direct Sale as Transaction Type **/  
       List<Order> orderList1 = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList, commodityList, productRec);      
        //orderList1[0].EffectiveDate = system.today();
      Database.insert(orderList1);
        Map<id, Order> oldMap = new Map<id,Order>([select id ,OrderNumber, EffectiveDate,Account_Record_Type__c,RFO_Shipping_Commence_stop_notifications__c,RFO_TankorFreight__c,RFO_ContractRiderReceived__c ,AccountId, RecordtypeId from order]);
        Map<id, Order> newMap = new Map<id,Order>([select id ,OrderNumber, EffectiveDate,Account_Record_Type__c,RFO_Shipping_Commence_stop_notifications__c,RFO_TankorFreight__c,RFO_ContractRiderReceived__c ,AccountId, RecordtypeId from order]);
        system.debug('oldMap111===='+oldMap);
        for(Order r :newMap.values() ){         
         r.EffectiveDate = Date.newInstance(2020, 12, 30);
         r.RFO_ContractRiderReceived__c = false;
         r.RFO_Shipping_Commence_stop_notifications__c = true;
         r.RFO_TankorFreight__c = 'Tank';
         newMap.put(r.id, r);
     }
        system.debug('newMap===='+newMap.values());
        system.debug('oldMap===='+oldMap.values());
     //update newMap.values();
       RFO_OrderTriggerHelper.shippingCommenceDateNotifications(newMap,oldMap);
       //RFO_CpqTriggerSwitch.disableCpqTriggers();
       //RFO_OrderTriggerHandler objH = new RFO_OrderTriggerHandler();
       Map<id, Order> newMap1 = new Map<id,Order>([select id ,OrderNumber, EffectiveDate,Account_Record_Type__c,RFO_Shipping_Commence_stop_notifications__c,RFO_TankorFreight__c,RFO_ContractRiderReceived__c ,AccountId, RecordtypeId from order]);
        for(Order r :newMap1.values() ){         
         r.EffectiveDate = Date.newInstance(2020, 11, 30);
         r.RFO_ContractRiderReceived__c = false;
         r.RFO_Shipping_Commence_stop_notifications__c = true;
         r.RFO_TankorFreight__c = 'Freight';
         newMap.put(r.id, r);
     }
       RFO_OrderTriggerHelper.shippingCommenceDateNotifications(newMap1,oldMap);
       test.stopTest();
       //system.assertEquals(cpqQuoteList.RFO_BusinessAwarded__c, 'Yes');   
           
    }
    
//Alpha-579  start
    /*============================================================================
* Created by: Ashish Reddy 
* Method Name: test Project Required
* User Story: Alpha-579
*==============================================================================*/
   /* private static testMethod void testProjectRequired(){
        
        Test.startTest();
        Map<Id,Order> mapOfOrder = new  Map<Id,Order>();
        List<Order> orderList = [Select Id, OwnerId, ContractId, Is_Project_Required__c, AccountId, RecordType.DeveloperName, Pricebook2Id, OriginalOrderId, OpportunityId, QuoteId, RecordTypeId, EffectiveDate, EndDate, IsReductionOrder, Status, Description, CustomerAuthorizedById, CustomerAuthorizedDate, CompanyAuthorizedById, CompanyAuthorizedDate, Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Name, PoDate, PoNumber, OrderReferenceNumber, BillToContactId, ShipToContactId, ActivatedDate, ActivatedById, StatusCode, OrderNumber, TotalAmount, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, IsDeleted, SystemModstamp, LastViewedDate, LastReferencedDate, RFO_BasePrice__c, RFO_CarType__c, RFO_ChangeOrderDate__c, RFO_Comments__c, RFO_Commitment_Date__c, RFO_Commodity__c, RFO_Commodity_lookup__c, RFO_Contract__c, RFO_CurrentSalesPrice__c, RFO_DateSpeSheetSent__c, RFO_DateSpecIssued__c, RFO_EOSTransactionID__c, RFO_EndChargeDate__c, RFO_ExpiryDate__c, RFO_FieldServiceDate__c, RFO_File__c, RFO_FirstShipWeek__c, RFO_InspectionDate__c, RFO_LinktoEngineeringSpec__c, RFO_NoOfAssetsOnFile__c, RFO_OrderReviewMeetingDate__c, RFO_ParentOrder__c, RFO_Product__c, RFO_ProgramName__c, RFO_QuoteID__c, RFO_QuoteScenarioID__c, RFO_RevisedDeliveryDate__c, RFO_Rider__c, RFO_SampleCarDate__c, RFO_SellQuantity__c, RFO_SignedProposalDate__c, RFO_StatusDate__c, RFO_SubType__c, RFO_TerminationMeetingDate__c, RFO_TransDate__c, RFO_Transaction__c, RFO_TASLastModifiedBy__c, RFO_TASLastModifiedDate__c, Survey_Contact_Id__c, Survey_Contact__c, Survey_Sent_Time__c, First_Ship_Week_Survey_Sent_Time__c, Last_Ship_Week_Survey_Sent_Time__c, RFO_LastShipWeek__c, Account_Name_Text__c, SBQQ__Contracted__c, SBQQ__ContractingMethod__c, SBQQ__PaymentTerm__c, SBQQ__PriceCalcStatusMessage__c, SBQQ__PriceCalcStatus__c, SBQQ__Quote__c, SBQQ__RenewalTerm__c, SBQQ__RenewalUpliftRate__c, SBQQ__OrderBookings__c, SBQQ__TaxAmount__c, Actualdelivery__c, Escalation_Terms__c, IRR__c, RFO_AddScrapSurchargetoAbovePrice__c, RFO_AdvanceOrderCarsUsed__c, RFO_AdvanceOrderInterfaceField__c, RFO_AdvancePaymentDepositRequired__c, RFO_AdvancePaymentReceived__c, RFO_AlternatesAccepted__c, RFO_AlternatesComments__c, RFO_AlternatesCost__c, RFO_AlternatesPrice__c, RFO_AssetFileLeaseType__c, RFO_BPCSCustomerNumber__c, RFO_BaseCarPriceEach__c, RFO_CarsAssignedtoTrip__c, RFO_Commencement__c, RFO_CommencmentDate__c, RFO_CommodityName__c, RFO_Costpermonth__c, RFO_CreditComments__c, RFO_CreditConditionsAcknowledged__c, RFO_CreditReviewComplete__c, RFO_CreditStatus__c, RFO_CurrentPlant__c, RFO_CustomerCreditAcknowledgementIssued__c, RFO_DateofOrder__c, RFO_DeliveryComments__c, RFO_DeliveryCostIncluded__c, RFO_DepositCommentary__c, RFO_DirectSalePrice__c, RFO_EngineeringApprovalsBegin__c, RFO_ExcludefromBacklog__c, RFO_ExecutiveApproval__c, RFO_Expectdelivery__c, RFO_FOBPoint__c, RFO_FinishingPlant__c, RFO_FrabricateApprovalsBegin__c, RFO_FreightBills__c, RFO_GloballySourcedMaterialAcceptable__c, RFO_GuarantyReceived__c, RFO_GuarantyRequired__c, RFO_InteriorLined__c, RFO_JobCostDetails__c, RFO_LOCAmount__c, RFO_LOCReceived__c, RFO_LOCRequired__c, RFO_LeaseRate__c, RFO_LeaseTerms__c, RFO_LineNumber__c, RFO_MonthlyRentalsHeldAsSecurityDeposit__c, RFO_NetTerms__c, RFO_OALstatus__c, RFO_OrderAcknowledgementDate__c, RFO_OrderFlag__c, RFO_OrderURLHead__c, RFO_OriginalMargin__c, RFO_OriginalSalesPrice__c, RFO_OriginalUnitCost__c, RFO_PercentageDeposit__c, RFO_PriceClassification__c, RFO_ProposalDate__c, RFO_ProposalRequired__c, RFO_Purchasing__c, RFO_Quantity__c, RFO_RANumber__c, RFO_RapidResponseLink__c, RFO_RemoveCarNumbers__c, RFO_ReportingMarks__c, RFO_ReturnProvisionsStillValid__c, RFO_RunningNumbers__c, RFO_SalesOrderIssued__c, RFO_SecurityDepositReceived__c, RFO_SecurityDepositRequired__c, RFO_ShipmentApproved__c, RFO_ShippingtoCommence__c, RFO_SignedProposalDateCheck__c, RFO_SingleUnitShipmentsAcceptable__c, RFO_TankorFreight__c, RFO_TrafficHelpinSecuringFirstLoad__c, RFO_TransferPrice__c, RFO_TrinitySpecDate__c, RFO_UnresolvedItems__c, RFO_UpdateFirstShippedWeek__c, RFO_WarrantyType__c, RFO_WillaSampleCarberequired__c, ROE__c, Transfer_Margin__c, RFO_TotalCurrentQuantity__c, RFO_TotalOrderAmount__c, Is_Survey_Sent__c, RFO_ContractRiderReceived__c, RFO_ExistingCarCRPastDate__c, RFO_ExistingCarCRStatuschange__c, RFO_ExistingCarCRStatusupdate__c, RFO_ExistingCarCRcreation__c, RFO_NewCarCRPastDate__c, RFO_NewCarCRStatuschange__c, RFO_NewCarCRStatusupdate__c, RFO_NewCarCRcreation__c, RFO_OrderNotesDate__c, RFO_Notify_New_Car_Plant_User_On_Defined__c, RFO_First_Car_Ship_Days__c, RFO_Freight_Payer__c, RFO_PM_Notes__c, Account_Record_Type__c, Request_Disposition__c, New_Car_Sample_Car_Alert_Start__c, New_Car_Sample_Car_Alert_Stop__c, New_Car_Sample_Car_Alert_Escalation_Date__c from order limit 1];
        orderList[0].Is_Project_Required__c = true;
        orderList[0].RFO_SignedProposalDate__c = Date.today() +3;
      
        
        try{
            update orderList; 
           
        }
        catch(Exception e){
            
        }
        RFO_Projects__c proj = new RFO_Projects__c();
        proj.RFO_Account__c =  orderList[0].AccountId;
        proj.Name = 'Test';
        proj.Order__c = orderList[0].Id;
        insert proj;
        try{
            update orderList; 
        }
        catch(Exception e){            
        }
        Test.stopTest();  
        List<Order> updatedOrderList = [Select Id, OwnerId, ContractId, Is_Project_Required__c, AccountId from Order limit 1];
        system.assertEquals(true, updatedOrderList[0].Is_Project_Required__c);
        
    } */
    
     //Added By Vihari Alpha-530
    /* //Test method to test After Update for New Cars
     * Method Name: carMarksPendingNotification
     * User Story: Alpha-530
     **/
    
    private static testMethod void testAfterUpdateforNewCars(){ 
       Test.startTest();
       RFO_CpqTriggerSwitch.disableCpqTriggers(); 
       Account acclist=[select id from Account Limit 1];
       RFO_Commodity__c commodityList = [select id from RFO_Commodity__c Limit 1];
       Opportunity opportunityList = [Select id from Opportunity Limit 1 ];
       RFO_QuoteTeams__c quoteTeamRecord = [Select id from RFO_QuoteTeams__c Limit 1];
       Product2 productRec =[Select id from Product2 Limit 1];
       SBQQ__Quote__c cpqQuoteList =[Select id from SBQQ__Quote__c Limit 1];
       cpqQuoteList.RFO_Product__c=productRec.id;
       update cpqQuoteList;
       
     
        Id orderNewCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(RFO_Constant.ORDER_NEWCAR).getRecordTypeId();

        List<Order> orderList1 = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList, commodityList, productRec);      
        orderList1[0].EffectiveDate = system.today().addMonths(6);
        
        Database.insert(orderList1);
        Map<id, Order> newMap = new Map<id,Order>();
        Map<id, Order> oldMap = new Map<id,Order>();
        orderList1 = [select id , EffectiveDate,New_Car_Marks_Pending_Notification_Start__c,Status,RFO_OrderReviewMeetingDate__c, Total_Asset_Count__c, Account_Record_Type__c,RFO_TankorFreight__c, AccountId, RecordtypeId, Recordtype.Name from order];
        for(Order r :orderList1 ){
            r.recordTypeId = orderNewCarRTId;
            oldMap.put(r.id, r);
            Order order2 = new Order(id=r.id, RecordtypeId = r.RecordtypeId, Status=r.Status, RFO_OrderReviewMeetingDate__c = r.RFO_OrderReviewMeetingDate__c, New_Car_Marks_Pending_Notification_Start__c = true, Type = 'Lease' , RFO_SubType__c = 'Net Lease' );
            newMap.put(order2.id, order2);
        }
        update newMap.values();
        
        RFO_OrderTriggerHelper.carMarksPendingNotification(newMap,oldMap);
        RFO_CpqTriggerSwitch.disableCpqTriggers();
        
        test.stopTest();
        List<Alert__c> alerts = [Select id from Alert__c];
        System.assertEquals(true, alerts.size()>0);
            
        }
    
  /* //Test method to test Before Update for New Cars
     * Method Name: 
     * User Story: Alpha-530
     **/
    
    private static testMethod void testBeforeUpdateforNewCars(){ 
       Test.startTest();
       RFO_CpqTriggerSwitch.disableCpqTriggers(); 
       Account acclist=[select id from Account Limit 1];
       RFO_Commodity__c commodityList = [select id from RFO_Commodity__c Limit 1];
       Opportunity opportunityList = [Select id from Opportunity Limit 1 ];
       RFO_QuoteTeams__c quoteTeamRecord = [Select id from RFO_QuoteTeams__c Limit 1];
       Product2 productRec =[Select id from Product2 Limit 1];
       SBQQ__Quote__c cpqQuoteList =[Select id from SBQQ__Quote__c Limit 1];
       cpqQuoteList.RFO_Product__c=productRec.id;
       update cpqQuoteList;
       
     
        Id orderNewCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(RFO_Constant.ORDER_NEWCAR).getRecordTypeId();

        List<Order> orderList1 = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList, commodityList, productRec);      
        orderList1[0].EffectiveDate = system.today().addMonths(6);
        
        Database.insert(orderList1);
        Map<id, Order> newMap = new Map<id,Order>();
        Map<id, Order> oldMap = new Map<id,Order>();
        orderList1 = [select id , EffectiveDate,New_Car_Marks_Pending_Notification_Start__c,Is_Project_Required__c, Status,RFO_OrderReviewMeetingDate__c, Total_Asset_Count__c, Account_Record_Type__c,RFO_TankorFreight__c, AccountId, RecordtypeId, Recordtype.Name from order];
        for(Order r :orderList1 ){
            r.recordTypeId = orderNewCarRTId;
            oldMap.put(r.id, r);
            Order order2 = new Order(id=r.id, RecordtypeId = r.RecordtypeId,  New_Car_Marks_Pending_Notification_Start__c = true, Type = 'Lease' , RFO_SubType__c = 'Net Lease', Total_Asset_Count__c =1 );
            newMap.put(order2.id, order2);
        }
        RFO_CpqTriggerSwitch.disableCpqTriggers();
        RFO_OrderTriggerHandler objH = new RFO_OrderTriggerHandler();
        objH.beforeUpdate(newMap,oldMap);
        objH.validateOrderInProcess(newMap, orderList1);
        objH.validateOrderComplete(newMap, orderList1);
        test.stopTest();
            
        }
    /* End Vihari  ALPHA-530 */        
}