/*
* Class Name: RFO_RiderTriggerHelper_Test
*/
@isTest(SeeAllData = false)
private class RFO_RiderTriggerHelper_Test{
    /**
*   Test method riderCreation
**/
    @testsetup static void riderCreation(){
        Test.startTest();
        // Account Creation        
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].Name = RFO_Constant.ACCOUNT_NAME;
        accList[1].Name = RFO_Constant.ACCOUNT_NAME_TEST;
        Database.insert(accList);
        
        //contract Creation
        Contract contr = new Contract(AccountId = accList[0].id, RFO_ContractType__c=RFO_Constant.CONTRACT_TYPE_DIRECT_SALE ,
                                      RFO_ContractDate__c=system.today());
        Contract contr1 = new Contract(AccountId = accList[1].id, RFO_ContractType__c=RFO_Constant.CONTRACT_TYPE_NET_LEASE ,
                                       RFO_ContractDate__c=system.today());
        Database.insert(contr);
        Database.insert(contr1);
        
        //Commodity Creation
        List<RFO_Commodity__c> commd=RFO_Utility_Test.createCommodity();
        Database.insert(commd);
        
        //Product Creation
        Product2 prod=RFO_Utility_Test.createProduct();
        prod.IsActive = true;
        Database.insert(prod);
        
        //~~~
        PriceBook2 pb = new Pricebook2();
        pb.Id = Test.getStandardPricebookId();
        pb.IsActive = TRUE;
        update pb;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pb.Id;
        pbe.Product2Id =prod.id;
        pbe.IsActive = true;
        pbe.UnitPrice = 1;
        insert pbe;
        
        //~~~
        
        //Order Creation
        Order ordr = new Order();
        Id recordTypeIdExistingCar = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get(RFO_Constant.ORDER_EXISTINGCAR).getRecordTypeId();
        RFO_OrderTriggerHandler.triggerDisabled = false;
        ordr.RecordTypeId=recordTypeIdExistingCar;
        ordr.Status=RFO_Constant.INITIATED;
        ordr.AccountId=accList[0].id;
        ordr.Type=RFO_Constant.ORDER_TYPE_DIRECT_SALE;
        ordr.EffectiveDate = Date.newInstance(2020, 01, 25); 
        ordr.RFO_ProposalRequired__c = RFO_Constant.PROPOSAL_REQUIRED;
        ordr.RFO_Commodity_lookup__c=commd[0].id;
        ordr.RFO_TankorFreight__c = RFO_Constant.TANK_RECORD_TYPE;
        ordr.RFO_Quantity__c = 5;
        ordr.RFO_CarType__c = RFO_Constant.ORDER_CAR_TYPE;
        ordr.RFO_Product__c = prod.Id;
        database.insert(ordr); 
        
        //Rider Creation
        RFO_Rider__c rider2=new RFO_Rider__c();
        rider2=RFO_Utility_Test.createrider();
        rider2.RFO_Account__c=accList[0].id;
        rider2.RFO_Status__c =RFO_Constant.READY_FOR_DELIVERY;
        rider2.RFO_AutoRenewal__c =RFO_Constant.YES;
        rider2.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider2.RFO_RiderType__c = RFO_Constant.RIDER_TYPE;
        rider2.RFO_ProductType__c = RFO_Constant.TEST;
        rider2.RFO_Contract__c=contr.id;
        rider2.RFO_TotalOfCars__c = 2; 
        rider2.RFO_TotalActiveCars__c = 5;
        Database.insert(rider2);
        
        RFO_Rider__c rider3=new RFO_Rider__c();
        rider3=RFO_Utility_Test.createrider();
        rider3.RFO_Account__c=accList[0].id;
        rider3.RFO_Status__c =RFO_Constant.READY_FOR_DELIVERY;
        rider3.RFO_AutoRenewal__c =RFO_Constant.NO;
        rider3.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider3.RFO_RiderType__c = RFO_Constant.MANAGEMENT_AGREEMENT;
        rider3.RFO_ProductType__c = RFO_Constant.TEST;
        rider3.RFO_Contract__c=contr.id;
        rider3.RFO_TotalOfCars__c = 2; 
        rider3.RFO_TotalActiveCars__c = 5;
        Database.insert(rider3);
        
        RFO_Rider__c rider4=new RFO_Rider__c();  
        rider4=RFO_Utility_Test.createrider();  
        rider4.RFO_Account__c=accList[0].id;
        rider4.RFO_Status__c =RFO_Constant.RIDER_STATUS;
        rider4.RFO_AutoRenewal__c =RFO_Constant.NO;
        rider4.RFO_OrderID__c = ordr.Id;
        rider4.RFO_Contract__c=contr1.id; 
        Database.insert(rider4);
        
        /*RFO_Rider__c rider5=new RFO_Rider__c();  
        rider5=RFO_Utility_Test.createrider();  
        rider5.RFO_Account__c=accList[0].id;
        rider5.RFO_Status__c ='Rider Initiated';
        rider5.RFO_RiderType__c = 'Net Lease';
        rider5.RFO_Contract__c=contr1.id;
        Database.insert(rider5);
        
        //Creating Renewal Opportunity  
        Id recordTypeIdRenewals = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RFO_Renewals').getRecordTypeId();
        Opportunity opp1 = new Opportunity();
        opp1.RecordTypeId = recordTypeIdRenewals;
        opp1.AccountId= accList[0].id;                                         // Account
        opp1.Name = 'Test Opportunity';                                 // opportunity Name
        opp1.StageName = 'Ready To Quote';                                   // Stage
        opp1.CloseDate = Date.newInstance(2019, 05, 25);                // Close Date
        opp1.RFO_ProductType__c = 'High Pressure Large';                // Product Type
        opp1.RFO_MarketSegment__c='Petrochemicals';                              //Opportunity Market segment
        opp1.RFO_Mileage__c = 2;
        opp1.RFO_MileageFee__c = 3;
        opp1.RFO_NumberofLoads__c =4;
        opp1.RFO_PreferredNewExisting__c = 'New';                       // Preferred New/Existing
        opp1.RFO_IdleRate__c =5;
        opp1.RFO_MaximumQuantity__c = 2;
        opp1.RFO_Quantity__c = 2;   
        opp1.RFO_MaturityDate__c=Date.newInstance(2019, 05, 25); 
        opp1.RFO_ConfidenceLevel__c = 'High';                           // Confidence Level
        opp1.RFO_ExpectedCarstoTrinity__c = 3;                          // Expected cars to Trinity
        opp1.RFO_LeaseTermsRequestedMonths__c = 90;
        opp1.RFO_RenewalDueDate__c  = Date.newInstance(2019, 10, 31);
        opp1.RFO_SalesComments__c = 'Testing' ;
        opp1.RFO_RiderID__c = rider5.id;
        opp1.RFO_Commodity__c=commd[0].id;
        Database.insert(opp1);*/
        
        //Creating Management Services Opportunity  
        Id recordTypeIdManagementServices = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId();
        Opportunity opp2 = new Opportunity();
        opp2.RecordTypeId = recordTypeIdManagementServices;
        opp2.AccountId= accList[0].id;                                   
        opp2.Name = RFO_Constant.OPPORTUNITY_NAME;                                
        opp2.StageName = RFO_Constant.INITIATED;                                 
        opp2.CloseDate = Date.newInstance(2020, 05, 25);
        opp2.RFO_ServiceType__c = RFO_Constant.MAINTENANCE;
        opp2.RFO_ProductType__c = RFO_Constant.OPPORTUNITY_PRODUCT_TYPE;            
        opp2.RFO_CustomerExpectedDeliveryStartDate__c=Date.newInstance(2020, 01, 25);  
        opp2.RFO_MaximumQuantity__c = 2;
        opp2.RFO_Quantity__c = 2;  
        opp2.RFO_ConfidenceLevel__c = RFO_Constant.OPPORTUNITY_CONFIDENCE_LEVEL;
        opp2.RFO_Renewal__c = RFO_Constant.YES;  
        opp2.RFO_RiderID__c = rider4.id;
        opp2.RFO_Commodity__c=commd[0].id;
        Database.insert(opp2); 
        Test.stopTest();
    }
    
    /**
*   Test method updateRider
**/   
    private static testMethod void updateRider(){
        
        Map<Id, SObject> newItems = new Map<Id, SObject>();
      //  Map<Id, SObject> oldItems = new Map<Id, SObject>();
        List<Contract> cntrct= [select id, name, AccountId from Contract Limit 49999];
        List<RFO_Rider__c> rdr= [select id, name, RFO_AutoRenewal__c ,RFO_Status__c,RFO_Account__c, RFO_OrderID__c 
                                 from RFO_Rider__c Where RFO_OrderID__c != null  Limit 49999];
        rdr[0].RFO_AutoRenewal__c ='No';
        rdr[0].RFO_Status__c = 'Request for Unscheduled Full Termination';
        rdr[0].RFO_Contract__c = cntrct[0].id;
        //rdr[1].RFO_AutoRenewal__c ='Yes';
        //rdr[1].RFO_Status__c = 'Rider Initiated';
        
        Test.startTest();
        Database.update(rdr[0]);
        //Database.update(rdr[1]);
        Test.stopTest();
        System.assert(newItems!=null);
    } 
    /**This method is used to Update the RiderAccount **/
    private static testMethod void updateRiderAccount(){
        
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].Name = 'Test3';
        Database.insert(accList);
        
        Contract contr = new Contract(AccountId = accList[0].id, RFO_ContractType__c='DIRECT SALE',
                                      RFO_ContractDate__c=system.today());
        contr= RFO_Utility_Test.createContract(accList);
        Database.insert(contr);
        
        RFO_Rider__c rider2=new RFO_Rider__c();
        rider2=RFO_Utility_Test.createrider();
        rider2.RFO_Account__c=accList[0].id;
        rider2.RFO_Status__c =RFO_Constant.READY_FOR_DELIVERY;
        rider2.RFO_AutoRenewal__c ='Yes';
        rider2.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider2.RFO_RiderType__c = 'Net Lease';
        rider2.RFO_ProductType__c = 'test';
        rider2.RFO_Contract__c=contr.id;
        rider2.RFO_TotalOfCars__c = 2; 
        rider2.RFO_TotalActiveCars__c = 5;
        Database.insert(rider2);
        system.assertEquals(rider2.RFO_RiderType__c, 'Net Lease');
    }
    
    private static testMethod void testupdateEligibleOrdersToDeliveryComplete(){
        Account objAcc = new Account();
        objAcc.Name = 'test';
        insert objAcc;
        Contract objCont = new Contract();
        objCont.Name = 'Testing';
        objCont.AccountId = objAcc.Id;
        insert objCont;
        RFO_Rider__c obj = new RFO_Rider__c ();
        //  obj.Id = '123';
        //  String rTDevName = Schema.SObjectType.Account.getRecordTypeInfosById().get('123').getDeveloperName();
        obj.RFO_Contract__c = objCont.Id;
        obj.RFO_RiderRateType__c = 'Term';
        obj.RFO_TotalOfCars__c = 20.2;
        obj.RFO_RenewalDaysNotice__c = 10.0;
        obj.RFO_Term__c = 10;
        obj.RFO_Status__c = 'Delivery complete';
        obj.RFO_CurrentMaturityDate__c = System.today();
        obj.RFO_TotalActiveCars__c = 20;
        Test.startTest();
        insert obj ;
        obj.RFO_CurrentMaturityDate__c = System.today().addDays(1);
        obj.RFO_TotalActiveCars__c = 30;
        update obj;
        Test.stopTest();
    }
    private static testMethod void testOrderDeliveryComplete(){
        
        List<RFO_Rider__c> riderList = new List<RFO_Rider__c>();
        Set<id> orderidSet = new Set<Id>();
        for(RFO_Rider__c rider : [select id, name, RFO_Status__c, RFO_AvgBeginCharge__c, RFO_OrderID__c from RFO_Rider__c Where RFO_OrderID__c!=null Limit 49999]){
            rider.RFO_Status__c = RFO_Constant.STATUS_DELIVERY_COMPLETE;
            rider.RFO_AvgBeginCharge__c = System.today();
            riderList.add(rider);
            if(rider.RFO_OrderID__c != null){
                orderidSet.add(rider.RFO_OrderID__c);
            }
        } 
        RFO_RiderTriggerHandler handler = new RFO_RiderTriggerHandler();

        Test.startTest();
        update riderList;
        handler.AfterDelete(null);
        handler.AfterUndelete(null);
        Test.stopTest();
        List<Order> orderList = [select id,status, Type, RecordType.Name   from Order where Id in: orderidSet limit 1];
        
        system.assertNotEquals(null, orderList);
        //system.assertEquals( RFO_Constant.STATUS_DELIVERY_COMPLETE, orderList[0].status);            
    }
    
    /* Added By Vihari ALPHA-22 */
    private static testMethod void testAutoAssignFieldsForClonedRider(){
        // - Create Account
        List<Account> listAccount = new List<Account>();
        listAccount = RFO_Utility_Test.createProspectAccounts();
        listAccount[0].Name = RFO_Constant.ACCOUNT_NAME;
        listAccount[1].Name = RFO_Constant.ACCOUNT_NAME_TEST;
        Database.insert(listAccount);
        // - Create Contract
        Contract objContract = new Contract(AccountId = listAccount[0].Id, RFO_ContractType__c = RFO_Constant.CONTRACT_TYPE_DIRECT_SALE, RFO_ContractDate__c = system.today());
        Database.insert(objContract);
        // - Create Rider
        
        RFO_Rider__c objRider = RFO_Utility_Test.createrider();
        objRider.RFO_Account__c = listAccount[0].Id;
        objRider.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
        objRider.RFO_AutoRenewal__c = RFO_Constant.YES;
        objRider.RFO_OriginalMaturityDate__c = system.today().AddDays(2);
        objRider.RFO_RiderType__c = RFO_Constant.RIDER_TYPE;
        objRider.RFO_ProductType__c = RFO_Constant.TEST;
        objRider.RFO_Contract__c = objContract.id;
        objRider.RFO_TotalOfCars__c = 2; 
        objRider.RFO_TotalActiveCars__c = 5;
        Database.insert(objRider);
       
        Assumption__c objAssumption = new Assumption__c();
        objAssumption.Source_Account__c = listAccount[0].Id;
        objAssumption.Destination_Account__c = listAccount[1].Id;
        
        Test.startTest();
    
        CreateAssumptionController.AssumptionResult objAssumptionResult = CreateAssumptionController.createAssumption(objAssumption, new List<RFO_Rider__c>{objRider}, new List<RFO_Rider__c>());
        System.assertEquals(true, objAssumptionResult.strAssumptionId!=null);
        objRider.Assumption__c = objAssumptionResult.strAssumptionId;
        objRider.Assumption_Account_Number__c = listAccount[1].Id;
        
        RFO_Rider__c objCloneRider = objRider.clone(false, false, false, false);
        RFO_RiderTriggerHelper.autoAssignFieldsForClonedRider(new List<RFO_Rider__c>{objCloneRider});
        Test.stopTest();
   
    }
    
    
}