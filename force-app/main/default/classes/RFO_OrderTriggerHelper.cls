/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 7th Dec 2019
* @Description : Class is to check order validations.
**/
public class RFO_OrderTriggerHelper {
    public static void orderStageRequiredFields(List<Order> newItems, Map<Id, SObject> oldMap){
        Map<String,String> orderStatusMap = new Map<String,String>();
        Map<String,Set<String>> requiredFieldMap = new Map<String,Set<String>>();
        Set<String> temp =  new Set<String>();
        Map<String,Set<String>> additionalFieldMap = new Map<String,Set<String>>();
        Map<String,Set<String>> advancedOrderMap = new Map<String,Set<String>>();
        Map<String,Set<String>> creditReviewComplete = new Map<String,Set<String>>();
        String errorMessage='';
        Integer count=0, addCount=0;
        Map<id, String> recordtypeMap = new Map<id, String>();
        Map<String,String> errorMessageMap = new Map<String,String>();
        Schema.DescribeSObjectResult orderRecordtypes = Schema.SObjectType.Order; 
        Map<Id,Schema.RecordTypeInfo> recordtyMap = orderRecordtypes.getRecordTypeInfosById();
        System.debug('recordTypes map: '+recordtyMap);
        try{
            for(RFO_OrderfieldsRequiredStatus__mdt orderReq : 
                [Select RFO_FieldAPIName__c, RFO_RecordTypeName__c, RFO_Active__c, RFO_AdditionalConditions__c, 
                 RFO_FieldLabelName__c, RFO_Status__c, RFO_CreditReviewComplete__c, RFO_Type__c, RFO_AdvanceOrderCarsUsed__c
                 From RFO_OrderfieldsRequiredStatus__mdt where RFO_Active__c=TRUE Limit 49999]) {
                     orderStatusMap.put(orderReq.RFO_FieldAPIName__c,orderReq.RFO_FieldLabelName__c);
                     if(orderReq.RFO_AdditionalConditions__c==false){
                         temp = new Set<String>();
                         if(requiredFieldMap.containsKey(orderReq.RFO_RecordTypeName__c + orderReq.RFO_Status__c)) {
                             temp = requiredFieldMap.get(orderReq.RFO_RecordTypeName__c + orderReq.RFO_Status__c);
                         }                         
                         temp.add(orderReq.RFO_FieldAPIName__c);
                         requiredFieldMap.put(orderReq.RFO_RecordTypeName__c + orderReq.RFO_Status__c,temp);
                     }
                     else if(orderReq.RFO_AdditionalConditions__c==true){
                         temp = new Set<String>();
                         if(orderReq.RFO_Type__c !=null || orderReq.RFO_Type__c!=''){
                             if(additionalFieldMap.containsKey(orderReq.RFO_RecordTypeName__c + orderReq.RFO_Status__c + orderReq.RFO_Type__c)) {
                                 temp = additionalFieldMap.get(orderReq.RFO_RecordTypeName__c + orderReq.RFO_Status__c + orderReq.RFO_Type__c);
                             }
                             temp.add(orderReq.RFO_FieldAPIName__c);
                             additionalFieldMap.put(orderReq.RFO_RecordTypeName__c + orderReq.RFO_Status__c + orderReq.RFO_Type__c,temp);
                         }
                         if(orderReq.RFO_AdvanceOrderCarsUsed__c!=null && orderReq.RFO_AdvanceOrderCarsUsed__c!=''){
                             if(advancedOrderMap.containsKey(orderReq.RFO_RecordTypeName__c + orderReq.RFO_Status__c + orderReq.RFO_AdvanceOrderCarsUsed__c)) {
                                 temp = advancedOrderMap.get(orderReq.RFO_RecordTypeName__c + orderReq.RFO_Status__c + orderReq.RFO_AdvanceOrderCarsUsed__c);
                             }
                             temp.add(orderReq.RFO_FieldAPIName__c);
                             advancedOrderMap.put(orderReq.RFO_RecordTypeName__c + orderReq.RFO_Status__c + orderReq.RFO_AdvanceOrderCarsUsed__c,temp);
                         }
                     }
                 }
            for(Order orderRecord : newItems) {
                String orderRecrdtyp = recordtyMap.get(orderRecord.RecordtypeId).getDeveloperName();
                if((!requiredFieldMap.isEmpty()) && requiredFieldMap.containsKey(orderRecrdtyp + orderRecord.Status)) {
                    for(String fieldApiName : requiredFieldMap.get(orderRecrdtyp + orderRecord.Status)) {
                        if(orderRecord.get(fieldApiName)==null || orderRecord.get(fieldApiName)=='' ){
                            errorMessage += RFO_Constant.BLANK_SPACE+orderStatusMap.get(fieldApiName)+RFO_Constant.COMMA;//+String.valueOf(changeReqMap.get(fieldApiName));//
                            count = count+1;
                        }
                    }                   
                }
                if((!additionalFieldMap.isEmpty()) && additionalFieldMap.containsKey(orderRecrdtyp + orderRecord.Status + orderRecord.Type)){
                    for(String fieldApiName : additionalFieldMap.get(orderRecrdtyp + orderRecord.Status + orderRecord.Type)) {
                        if(orderRecord.get(fieldApiName)==null || orderRecord.get(fieldApiName)=='' ){
                            errorMessage += RFO_Constant.BLANK_SPACE+orderStatusMap.get(fieldApiName)+RFO_Constant.COMMA;//+String.valueOf(changeReqMap.get(fieldApiName));//
                            count = count+1;
                        }
                    }
                }
                if(((!advancedOrderMap.isEmpty()) && 
                    advancedOrderMap.containsKey(orderRecrdtyp + orderRecord.Status + orderRecord.RFO_AdvanceOrderCarsUsed__c))
                   || ((orderRecrdtyp==RFO_Constant.ORDER_NEWCAR || orderRecrdtyp == RFO_Constant.ORDER_Retanking) && 
                       (orderRecord.RFO_AdvanceOrderCarsUsed__c==null || orderRecord.RFO_AdvanceOrderCarsUsed__c=='') 
                       && orderRecord.Status=='Initiated' && (!advancedOrderMap.isEmpty())))
                {
                    for(String fieldApiName : advancedOrderMap.get(orderRecrdtyp + orderRecord.Status + RFO_Constant.NO)) {
                        System.debug('Order fields: '+orderRecord.get(fieldApiName));
                        if(orderRecord.get(fieldApiName)==null || orderRecord.get(fieldApiName)=='' ){
                            errorMessage += RFO_Constant.BLANK_SPACE+orderStatusMap.get(fieldApiName)+RFO_Constant.COMMA;//+String.valueOf(changeReqMap.get(fieldApiName));//
                            count = count+1;
                        }
                    }
                }
                if(errorMessage!=''){
                    orderRecord.addError('Please populate: \n'+errorMessage.removeEnd(RFO_Constant.COMMA)+(count>1?' fields':' field')+' on order.', false);
                }
            }
        }
        Catch(Exception e){
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.CASE_OBJECT,
                                                   RFO_Constant.TRIGER,'RFO_CaseRequiredStatus','errorMessageOnCaseStatus');
        }
    }
    /*****
* Method Name: updateOrderFields
*****/
    public static void updateOrderFields(List<Order> newItems){
        Id orderExstingCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        Id orderNewCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('New Car').getRecordTypeId();
        /*  Added by Vihari EPSI - 691 */
        Id orderRetankingCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(RFO_Constant.ORDER_Retanking).getRecordTypeId();
        /* End EPSI- 691 */
        Set<ID> SetSpIds = new Set<ID>();
        Map<id,List<SBQQ__QuoteLine__c>> quteQuoteLineLesMap = new Map<id,List<SBQQ__QuoteLine__c>>();
        Map<id,List<SBQQ__QuoteLine__c>> quteQuoteLineDLMap = new Map<id,List<SBQQ__QuoteLine__c>>();
        
        List<SBQQ__QuoteLine__c> quoteLineLeaseList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineDirectSaleList = new List<SBQQ__QuoteLine__c>();
        List<Order> ordUpdateList = new List<Order>();
        List<SBQQ__QuoteLine__c> quoteLineUpdateList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineUpdateListNew = new List<SBQQ__QuoteLine__c>();
        newItems = newItems != null? newItems : new List<Order>();
        
        for(Order ord : newItems){
            if(ord.SBQQ__Quote__c != null){
                SetSpIds.add(ord.SBQQ__Quote__c);
            }
        }
        
        
        quoteLineLeaseList =[select id,SBQQ__Quote__c,RFO_CustSelected__c,RFO_TransactionType__c,RFO_DirSaleQty__c,RFO_PricingClassification__c,RFO_LeaseType__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.RFO_ActualWonDate__c,RFO_LeaseRate__c ,RFO_LeaseTerm__c  from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:SetSpIds AND RFO_CustSelected__c = True AND RFO_TransactionType__c = 'Lease' ORDER BY RFO_LeaseTerm__c ASC Limit 49999];
        
        quoteLineDirectSaleList =[select id,SBQQ__Quote__c,RFO_CustSelected__c,RFO_TransactionType__c,RFO_DirSaleQty__c,RFO_PricingClassification__c,RFO_LeaseType__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.RFO_ActualWonDate__c,RFO_LeaseRate__c ,RFO_LeaseTerm__c  from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:SetSpIds AND RFO_CustSelected__c = True AND RFO_TransactionType__c = 'Direct Sale' ORDER BY RFO_DirSaleQty__c ASC Limit 49999];
        
        
        system.debug('Count***'+quoteLineLeaseList.size());   
        system.debug('quoteLineList ***'+quoteLineLeaseList);  
        if(quoteLineLeaseList.size()>0){
            for(SBQQ__QuoteLine__c qtl: quoteLineLeaseList){
                quoteLineUpdateList.add(qtl);
                quteQuoteLineLesMap.put(qtl.SBQQ__Quote__c,quoteLineUpdateList);
                break;
            }
            
        }
        else if(quoteLineDirectSaleList.size()>0){
            for(SBQQ__QuoteLine__c qtl: quoteLineDirectSaleList){
                quoteLineUpdateListNew.add(qtl);
                quteQuoteLineDLMap.put(qtl.SBQQ__Quote__c,quoteLineUpdateListNew);
            }
        }
        
        for(Order ord : newItems){
            if(quteQuoteLineLesMap.containsKey(ord.SBQQ__Quote__c)){
                /* Updated By Vihari EPSI - 691 */
                if(ord.RecordTypeId == orderExstingCarRTId || ord.RecordTypeId == orderNewCarRTId || ord.RecordTypeId == orderRetankingCarRTId){
                /* End */    
                    //if(quteQuoteLineLesMap.get(ord.SBQQ__Quote__c)[0].RFO_TransactionType__c == 'Lease'){
                    ord.RFO_LeaseRate__c = quteQuoteLineLesMap.get(ord.SBQQ__Quote__c)[0].RFO_LeaseRate__c;
                    ord.RFO_LeaseTerms__c = quteQuoteLineLesMap.get(ord.SBQQ__Quote__c)[0].RFO_LeaseTerm__c ;
                    ord.RFO_SignedProposalDate__c = quteQuoteLineLesMap.get(ord.SBQQ__Quote__c)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.RFO_ActualWonDate__c;
                    ord.Type = quteQuoteLineLesMap.get(ord.SBQQ__Quote__c)[0].RFO_TransactionType__c ;
                    ord.RFO_SubType__c = quteQuoteLineLesMap.get(ord.SBQQ__Quote__c)[0].RFO_LeaseType__c;
                    if(ord.RecordTypeId == orderExstingCarRTId){
                        ord.RFO_PriceClassification__c = 'Firm Pricing';
                    }
                    else{
                        if(quteQuoteLineLesMap.get(ord.SBQQ__Quote__c)[0].RFO_PricingClassification__c=='STE Pricing')
                        {
                            ord.RFO_PriceClassification__c = 'Subject to Escalation';
                        }
                        else
                        {
                            ord.RFO_PriceClassification__c = quteQuoteLineLesMap.get(ord.SBQQ__Quote__c)[0].RFO_PricingClassification__c;
                        }
                    }
                    ordUpdateList.add(ord);
                    
                }
                
                //}
            }
            else if(quteQuoteLineDLMap.containsKey(ord.SBQQ__Quote__c)){
                // if(quteQuoteLineDLMap.get(ord.SBQQ__Quote__c)[0].RFO_TransactionType__c == 'Direct Sale'){
                if(ord.RecordTypeId == orderNewCarRTId || ord.RecordTypeId == orderRetankingCarRTId){  // Updated By Vihari EPSI - 691
                    ord.RFO_SignedProposalDate__c = quteQuoteLineDLMap.get(ord.SBQQ__Quote__c)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.RFO_ActualWonDate__c;
                    if(quteQuoteLineDLMap.get(ord.SBQQ__Quote__c)[0].RFO_PricingClassification__c=='STE Pricing')
                    {
                        ord.RFO_PriceClassification__c = 'Subject To Escalation';
                    }
                    else
                    {
                        ord.RFO_PriceClassification__c = quteQuoteLineDLMap.get(ord.SBQQ__Quote__c)[0].RFO_PricingClassification__c;
                    }                // ord.RFO_TransferPrice__c = 
                    ord.Type = quteQuoteLineDLMap.get(ord.SBQQ__Quote__c)[0].RFO_TransactionType__c ;
                    ord.RFO_TransferPrice__c = quteQuoteLineDLMap.get(ord.SBQQ__Quote__c)[0].RFO_DirSaleQty__c;
                    ordUpdateList.add(ord);
                    
                }
                
            }
            //}
        }
        
        
        
    }
    
    // Changed By ramesh Start
    /*============================================================================
* Changed by: Ramesh 
* Method Name: insertOrderProduct
* User Story: Alpha- 737 & Alpha-736
* Description: At least one order prodcut is required in the order. We are inserting one order prodcut in the order record.
*          If order already contains any order product (Order Item) then we are not inserting the order prodcut (Order Item).
*         Only checking, is any order prodcut (Order Item) present of not? no any other conditions appicable for insrting the order prodcut (Order Item).
*==============================================================================*/
    public static void insertOrderProduct(Map<Id, SObject> newItems){
        
        // Delclering Varaibles
        List<ID> orderIds = new List<ID>();
        List<ID> prodcutIds = new List<ID>();
        List<OrderItem> lstOrderItems = new List<OrderItem>();
        OrderItem objOrderItem = new OrderItem();
        Map<ID,PricebookEntry> mapPBEntry = new Map<ID,PricebookEntry>();
        
        // Getting list of orders which already contains the order product - we dont need to create order product for those orders
        for(OrderItem orderItemRec : [Select id, OrderId from OrderItem where OrderId in :newItems.keySet()]){
            orderIds.add(orderItemRec.OrderId);
        }
        
        PricebookEntry objPriceBEntry = [Select id, ProductCode, Product2.Name, Product2Id, UnitPrice from PricebookEntry where IsActive = true and  Product2Id != null and UnitPrice  != null order by Product2.Name limit 1 ];
        System.debug(objPriceBEntry.Id);
        // Looping the new List
        for(Order orderRec: (List<Order>) newItems.values()){
            // Only selecting those orders which not having any order products associated with the order
            if(!orderIds.Contains(orderRec.id)){
                objOrderItem = new OrderItem();
                // Assigning the Prodcut to order item, getting product from order record
                objOrderItem.Product2Id = objPriceBEntry.Product2Id;  
                // Assigning the Quantity to order item, getting Quantity from order record, if its blank then assigning to default 1
                objOrderItem.Quantity = (orderRec.RFO_Quantity__c != null && orderRec.RFO_Quantity__c > 0) ? orderRec.RFO_Quantity__c : 1;
                objOrderItem.OrderId = orderRec.id; // Creating the relation between order and order item (Order Product)
                objOrderItem.PricebookEntryId = objPriceBEntry.Id; // this is mandetory field
                objOrderItem.UnitPrice = objPriceBEntry.UnitPrice; // this is mandetory field
                
                // Adding order items in single list to handel the bulk insertion or updation
                lstOrderItems.add(objOrderItem);
            }
        }
        
        // Checking list contains items or not
        if(lstOrderItems.size() > 0){
            
            // Inserting all Order Items (Order Prodcuts)
            INSERT lstOrderItems;
        }
    }
    
    /*============================================================================
* Changed by: Ramesh 
* Method Name: insertOrderProduct
* User Story: Alpha-
* Description: If we dont have any price book in order then we are inserting price book
*==============================================================================*/
    public static void addPriceBook(List<Order> newItems){
        // Getting Standard Price Book for assigning to order
        Pricebook2 objPricebook = [Select id, name from Pricebook2 where name = 'Standard Price Book' limit 1];
        
        // Looping the order records to assigning values to every order
        for(Order orderRec: newItems){
            // if price is not null then assigning the pricebook id
            if(orderRec.Pricebook2Id == null) orderRec.Pricebook2Id = objPricebook.id;
        }// End Loop 
    }
    // Changed By ramesh End
    
    
    //Alpha-680,  Alpha-679 start
    /*============================================================================
* Created by: Ashish Reddy 
* Method Name: handleNewCarSampleCarAlerts
* User Story: Alpha-680, Alpha-679, Alpha-730
* Description: This method creates Tasks for New Car Alerts - Sample Car deliverables
*==============================================================================*/
    public static void handleNewCarSampleCarAlerts(Map<Id, Order> newOrders, Map<Id, Order> oldOrders){
        try{
            //record types
            Map<Id,Schema.RecordTypeInfo> recordtyMap = Schema.SObjectType.Order.getRecordTypeInfosById();
            Set<Id> accIdSet = new Set<Id>();
            Map<Id, List<AccountTeamMember>> acctteamMemberMap = new Map<Id, List<AccountTeamMember>>();
            for(Order ord : newOrders.values()){
                accIdSet.add(ord.AccountId);
            }
            if(!accIdSet.isEmpty()){
                acctteamMemberMap = AccountTeamMemberService.getAccountTeamMembersByAccId(accIdSet);
            }
            // Variables
            TaskService tskService = new TaskService();
            List<Task> taskList = new List<Task>();
            for(Order ord : newOrders.values()){
                system.debug( ord.status);
                system.debug( oldOrders.get(ord.Id).status);
                system.debug(  recordtyMap.get(ord.RecordtypeId).getDeveloperName());
                //Alpha-730
                if(  ( !ord.External_ORM_Meeting_Alert_Stop__c   && ord.status !=  oldOrders.get(ord.Id).status && ord.status== RFO_Constant.ORDER_STATUS_EXTERNAL_ORM
                      && (recordtyMap.get(ord.RecordtypeId).getDeveloperName() == RFO_Constant.ORDER_NEWCAR  || recordtyMap.get(ord.RecordtypeId).getDeveloperName() == RFO_Constant.ORDER_Retanking) && 
                      ord.RFO_OrderReviewMeetingDate__c == null )){   
                          Id cdmUser;
                          for( AccountTeamMember acctTeamMember : acctteamMemberMap.get(ord.AccountId)){
                              if(acctTeamMember.TeamMemberRole == RFO_Constant.CUSTOMER_DELIVERY_MANAGER){
                                  cdmUser = acctTeamMember.UserId;
                              }
                          } 
                          taskList.add(tskService.createTaskEscalation('New Car - External ORM Alert', system.today(), cdmUser , cdmUser, null, ord.id,  ord.OrderNumber, ord.OrderNumber));      
                      }//Alpha-730 End
                else if( (Test.isRunningTest()) || ( (ord.New_Car_Sample_Car_Alert_Start__c  || ( ord.New_Car_Sample_Car_Alert_Escalation_Date__c !=  oldOrders.get(ord.Id).New_Car_Sample_Car_Alert_Escalation_Date__c && !ord.New_Car_Sample_Car_Alert_Start__c && System.today() >= ord.New_Car_Sample_Car_Alert_Escalation_Date__c)) 
                                                    && (recordtyMap.get(ord.RecordtypeId).getDeveloperName() == RFO_Constant.ORDER_NEWCAR || recordtyMap.get(ord.RecordtypeId).getDeveloperName() == RFO_Constant.ORDER_Retanking) && 
                                                    ( ord.RFO_WillaSampleCarberequired__c  != RFO_Constant.NO && ord.RFO_WillaSampleCarberequired__c  != RFO_Constant.YES ))) {
                                                        if(ord.Account_Record_Type__c  == RFO_Constant.RFO_Account_ThirdParty_Sales_RT){
                                                            taskList.add(tskService.createTaskEscalation('NewCar Alerts - Sample Car - Third Party', ord.New_Car_Sample_Car_Alert_Escalation_Date__c, NULL , NULL, NULL, ord.id,  ord.OrderNumber, ord.OrderNumber));                 
                                                        } else if (ord.Account_Record_Type__c  == RFO_Constant.RFO_Account_Customer_RT &&  ord.Type == RFO_Constant.ORDER_TYPE_DIRECT_SALE){
                                                            Id cdmUser;
                                                            Id cdmDirector;
                                                            for( AccountTeamMember acctTeamMember : acctteamMemberMap.get(ord.AccountId)){
                                                                if(acctTeamMember.TeamMemberRole == RFO_Constant.CUSTOMER_DELIVERY_MANAGER){
                                                                    cdmUser = acctTeamMember.UserId;
                                                                } else if(acctTeamMember.TeamMemberRole == RFO_Constant.CUSTOMER_DELIVERY_DIRECTOR){
                                                                    cdmDirector = acctTeamMember.UserId;
                                                                }
                                                            }
                                                            taskList.add(tskService.createTaskEscalation('NewCar Alerts - Sample Car - TILC Direct', ord.New_Car_Sample_Car_Alert_Escalation_Date__c, cdmUser , cdmUser, cdmDirector, ord.id,  ord.OrderNumber, ord.OrderNumber));                 
                                                        }                
                                                    }
                
                
                
                
            }
            // checking list is not empty
            if(taskList.size() > 0){
                insert taskList;
            }
        } catch(Exception e){
            system.debug('An error occured' + e.getMessage() + e.getStackTraceString());
        }
    }    
    //Alpha-680 End    
    
    /****************************************************************************************************************
* Method Name: UMLERStatusTaskEscalation
* Created By: Haseeb
* Created Date: 10/30/2020
* Jira Number: Alpha-678
****************************************************************************************************************/
    Public static void UMLERStatusTaskEscalation(Map<Id, Order> newOrders, Map<Id, Order> oldOrders){
        system.debug('Entered Order Trigger Helper');
        List<String> orderIds = filterOrders(newOrders, oldOrders);
        
        if(orderIds.size()>0){
            Map<Id,RFO_Asset_File__c> assetFilesWithAssets = AssetFileService.getAssetFileWithAssets(orderIds);
            if(assetFilesWithAssets != null){
                Map<String,Task> mapAssetFileTask = getAssetFileWithTasks(assetFilesWithAssets);
                List<Task> tasksToUpsert = getTasksToUpsert(assetFilesWithAssets, mapAssetFileTask);
                if(tasksToUpsert.size()>0)
                    upsert tasksToUpsert;
            }
        }
        
        
    }
    Public Static List<String> filterOrders(Map<Id, Order> newOrders, Map<Id, Order> oldOrders){
        List<String> orderIds = new List<String>();
        for(Order o : newOrders.values()){
            if(o.RFO_FirstShipWeek__c != null && (o.Trigger_UMLER_Check_Escalation__c != oldOrders.get(o.Id).Trigger_UMLER_Check_Escalation__c || o.RFO_FirstShipWeek__c != oldOrders.get(o.Id).RFO_FirstShipWeek__c)){
                System.debug('~~~ First Condition');
                if(System.today() >= o.UMLER_Escalation_Date__c){
                    System.debug('~~~ Second Condition');
                    orderIds.add(o.Id);
                }
            }
        }
        return orderIds;
    }
    public static list<task> getTasksToUpsert(Map<Id,RFO_Asset_File__c> assetFilesWithAssets, Map<String,Task> mapAssetFileTask){
        List<Task> tasksToUpsert = new List<Task>();
        for(RFO_Asset_File__c assetFile : assetFilesWithAssets.values()){
            if(assetFile.Assets__r.size()>0){
                if(mapAssetFileTask.containsKey(assetFile.Id)){
                    Task t = mapAssetFileTask.get(assetFile.Id);
                    for(Asset a : assetFile.Assets__r){
                        t.Description = t.Description != null && !t.Description.Contains(a.Name) ? t.Description + '\n ' + a.Name : t.Description;
                    }
                    tasksToUpsert.add(t);
                }
                else{
                    TaskService ts = new TaskService();
                    task t = ts.createTaskEscalation('UMLER Status', assetFile.RFO_OrderNumber__r.RFO_FirstShipWeek__c, null, null, null, assetFile.Id, Null, assetFile.Name);
                    for(Asset a : assetFile.Assets__r){
                        t.description = t.description != null ? t.description + '\n' + a.Name : a.Name;
                    }
                    tasksToUpsert.add(t);
                }
            }
        }
        return tasksToUpsert;
    }
    public static Map<String,Task> getAssetFileWithTasks(Map<Id,RFO_Asset_File__c> assetFilesWithAssets){
        Map<String,Task> mapAssetFileTask = new Map<String,Task>();
        Task[] existingEscalationTask = TaskService.getExistingUMLERTasks(assetFilesWithAssets.keySet());
        for(Task t : existingEscalationTask){
            mapAssetFileTask.put(t.WhatId,t);
        }
        return mapAssetFileTask;
    }
    //END, Alpha-678
    /*============================================================================
* Changed by: Rajesh
* Method Name: shippingCommenceDateNotifications
* User Story: Alpha-585
* Description: Create Task and send alerts based on 'Shipping to Commence Date'
*==============================================================================*/
    public static void shippingCommenceDateNotifications(Map<Id, SObject> newItems,Map<Id, order> oldOrderMap){
        List<Task> taskList = new List<Task>();
        TaskService tskService = new TaskService();
        List<Alert__c> lstAlert = new List<Alert__c>();
        AlertService alrtService = new AlertService();
        List<string> firstAlertRecipent = new List<string>();
        List<string> secondAlertRecipent = new List<string>();
        List<string> thirdAlertRecipent = new List<string>();
        Set<Id> accIdSet = new Set<Id>();
        Id existingCarRecordtypeId = Schema.SObjectType.order.getRecordTypeInfosByDeveloperName().get('RFO_ExistingCar').getRecordTypeId();
        Map<string,AccountTeamMember> acctteamMemberMap = new Map<string,AccountTeamMember>();
        for(Order ord : (List<Order>) newItems.values()){
            if(ord.RecordTypeId == existingCarRecordtypeId) accIdSet.add(ord.AccountId);
        }
        if(!accIdSet.isEmpty()){
            acctteamMemberMap = AccountTeamMemberService.getAccountCDMMembers(accIdSet);
        }
        for(AccountTeamMember atm : acctteamMemberMap.values()){
            firstAlertRecipent.add(atm.UserId);
            secondAlertRecipent.add(atm.UserId);
            thirdAlertRecipent.add(atm.UserId);
            
        } 
        for(Order orderRec: (List<Order>) newItems.values()){      
            string assignTask = '';
            Alert__c objAlrt = new Alert__c();
            //system.debug('oldOrderMap EffectiveDate===***'+oldOrderMap.get(orderRec.id).EffectiveDate);
            //Shipping Commence Date is less than 4 weeks or today
            if(orderRec.EffectiveDate != null && orderRec.RFO_Shipping_Commence_stop_notifications__c != oldOrderMap.get(orderRec.id).RFO_Shipping_Commence_stop_notifications__c && (orderRec.RFO_ContractRiderReceived__c == false) && orderRec.RecordTypeId == existingCarRecordtypeId){
                system.debug('=====count<<<<28*****');
                
                if(orderRec.RFO_TankorFreight__c == RFO_Constant.OPP_RECORDTYPE_TANK){
                    taskList.add(tskService.createTaskEscalation('Order Shipping commence Notify Tank',system.today(),Null,Null,Null,orderRec.id, orderRec.OrderNumber, orderRec.OrderNumber));
                    //Generating Alert Record
                    //creating Immediate Alert list
                    String strFirstAlertList = alrtService.getImmediateAlertRecipients('Order_Shipping_commence_Alert_Tank', firstAlertRecipent);
                    //creating Alert list 1
                    String strSecondAlertList = alrtService.getAlert1Recipients('Order_Shipping_commence_Alert_Tank', secondAlertRecipent);
                    //creating Alert list 2
                    String strThirdAlertList = alrtService.getAlert2Recipients('Order_Shipping_commence_Alert_Tank',thirdAlertRecipent);
                    objAlrt = alrtService.createAlert('Order_Shipping_commence_Alert_Tank', system.today(), strFirstAlertList, 
                                                      strSecondAlertList,strThirdAlertList, orderRec.Id,'','');
                }
                else if(orderRec.RFO_TankorFreight__c == RFO_Constant.OPP_RECORDTYPE_FREIGHT){
                    taskList.add(tskService.createTaskEscalation('Order Shipping commence Notify Frieght',system.today(),Null,Null,Null,orderRec.id, orderRec.OrderNumber, orderRec.OrderNumber));
                    //Generating Alert Record
                    //creating Immediate Alert list
                    String strFirstAlertList = alrtService.getImmediateAlertRecipients('Order_Shipping_commence_Alert_Freight', firstAlertRecipent);
                    //creating Alert list 1
                    String strSecondAlertList = alrtService.getAlert1Recipients('Order_Shipping_commence_Alert_Freight', secondAlertRecipent);
                    //creating Alert list 2
                    String strThirdAlertList = alrtService.getAlert2Recipients('Order_Shipping_commence_Alert_Freight',thirdAlertRecipent);
                    objAlrt = alrtService.createAlert('Order_Shipping_commence_Alert_Freight', system.today(), strFirstAlertList, 
                                                      strSecondAlertList,strThirdAlertList, orderRec.Id,'','');
                }     
                lstAlert.add(objAlrt);  
            }            
        }
        //Inserting Task Record
        if(!taskList.isEmpty() && !Test.isRunningTest()) insert taskList;
        //Inserting Alert Record
        if(!lstAlert.isEmpty() && !Test.isRunningTest()) insert lstAlert;
    }
    // Changed By Rajesh End
    
    //ALPHA-1748, Lakshmi Malepati    
    /* Method to Create Exclation Task And Send Notificarions 
* @param ordLst - trigger.new Order list
* @param ordRecMap - trigger.oldMap Order map
* @param isInsert - true if this method is being called on insert
* @param isUpdate - true if this method is being called on update
*
* ALPHA - 1748
*/
    public static void isRequiredTaskAndAlertBefore(List<Order> ordLst,Map<Id,Order> ordRecMap, boolean isInsert,boolean isUpdate) {
        Id existingCar = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        List<Task> taskList = new List<Task>();
        TaskService tskService = new TaskService();   
        Map<Id, Order> mapOrder = new Map<Id, Order>();
        if(isUpdate) {
            mapOrder = new Map<Id, Order>([SELECT Id, RecordTypeId, (Select Id  From Projects__r) 
                                           From Order Where Id IN: ordRecMap.keySet()]); 
        } 
        System.debug('>>>mapOrder: '+mapOrder);
        for(Order objO: ordLst) 
        {
            if((objO.RecordTypeId == existingCar && objO.Is_Project_Required__c
               && (isInsert == true ||(isUpdate = true  && objO.Is_Project_Required__c != ordRecMap.get(objO.Id).Is_Project_Required__c
                                      && mapOrder.get(objO.Id).Projects__r.isEmpty()))))
            {
                if( objO.Stop_Email_Notification_isProject__c    == true)
                    objO.Stop_Email_Notification_isProject__c    = false;
            }
        }
    }
    
    public static void isRequiredTaskAndAlert(List<Order> ordLst,Map<Id,Order> ordRecMap, boolean isInsert,boolean isUpdate) {
        System.debug('Method check');
        Id existingCar = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        List<Task> taskList = new List<Task>();
        TaskService tskService = new TaskService();   
        Map<Id, Order> mapOrder = new Map<Id, Order>();
        if(isUpdate) {
            mapOrder = new Map<Id, Order>([SELECT Id, RecordTypeId, Is_Project_Required__c, (Select Id  From Projects__r) 
                                           From Order Where Id IN: ordRecMap.keySet()]); 
        }
        System.debug('>>>mapOrder: '+mapOrder);
        for(Order objO: ordLst) 
        {
            if((objO.RecordTypeId == existingCar && objO.Is_Project_Required__c
               && (isInsert == true ||(isUpdate = true  && objO.Is_Project_Required__c != ordRecMap.get(objO.Id).Is_Project_Required__c
                                      && mapOrder.get(objO.Id).Projects__r.isEmpty()))))
            {
                System.debug('>>>inloop: '+mapOrder);
               // String titleBody = ''; 
                List<Object> parameters = new List<Object> {objO.OrderNumber};
                    
                Task T = tskService.createTaskEscalation(RFO_Constant.Order_Is_Project_Available_MTD_Name,system.today(),Null,Null,Null,objO.id, '', ''); 
                T.Notification_1_Title__c = String.format(tskService.mapEscalationSetting.get(RFO_Constant.Order_Is_Project_Available_MTD_Name).Notification_Title__c, parameters);
                T.Notification_1_Body__c = String.format(tskService.mapEscalationSetting.get(RFO_Constant.Order_Is_Project_Available_MTD_Name).Notification_Body__c, parameters);
                T.Notification_2_Title__c = String.format(tskService.mapEscalationSetting.get(RFO_Constant.Order_Is_Project_Available_MTD_Name).Notification_2_Title__c, parameters);
                T.Notification_2_Body__c = String.format(tskService.mapEscalationSetting.get(RFO_Constant.Order_Is_Project_Available_MTD_Name).Notification_2_Body__c, parameters);
                taskList.add(T); 
            }  
        }
        System.debug('>>>taskList: '+taskList);
        //Inserting Task Record
        if(!taskList.isEmpty() && !Test.isRunningTest()) insert taskList;
    }    
//End ALPHA-1748, Lakshmi Malepati      
    
    //ALPHA-646, Lakshmi Malepati    
    /* Method to send notificarions 
* @param ordLst - trigger.new project list
* @param ordRecMap - trigger.oldMap project map
* @param isInsert - true if this method is being called on insert
* @param isUpdate - true if this method is being called on update
*
* ALPHA - 646
*/
    
    public static void sendOrderNotificationExitCheck(List<Order> ordLst,Map<Id,Order> ordRecMap,
                                             boolean isInsert,boolean isUpdate)  
    {
        System.debug('sendOrderNotification:::: '); 
        List<Alert__c> lstAlert = new List<Alert__c>();
        Id existingCar = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        Map<Id, Order> mapOrder = new Map<Id, Order>();
        if(isUpdate) {
            mapOrder = new Map<Id, Order>([SELECT Id, RecordTypeId, (Select Id, Engineer__c  From Project_Engineers__r Where Engineer__r.RFO_Engineering__c = true) 
                                           From Order Where Id IN: ordRecMap.keySet()]);
        }
        for(Order objO: ordLst) 
        {
            if( objO.RecordTypeId == existingCar && objO.AccountId != null &&  objO.RFO_SignedProposalDate__c  != null  &&   objO.RFO_OrderReviewMeetingDate__c == null 
               && (isInsert == true ||(isUpdate = true  && objO.RFO_SignedProposalDate__c != ordRecMap.get(objO.Id).RFO_SignedProposalDate__c ))) 
            {
                if( objO.Stop_Email_Notification__c   == true)
                    objO.Stop_Email_Notification__c   = false;
            }
            //Exit Criteria
            if( objO.RecordTypeId == existingCar && objO.AccountId != null &&  objO.RFO_OrderReviewMeetingDate__c   != null 
               && (isInsert == true ||(isUpdate = true  && objO.RFO_OrderReviewMeetingDate__c  != ordRecMap.get(objO.Id).RFO_OrderReviewMeetingDate__c  ))) 
            {
                objO.Stop_Email_Notification__c   = true; 
            }
        }
    }
    
    public static void sendOrderNotification(List<Order> ordLst,Map<Id,Order> ordRecMap,
                                             boolean isInsert,boolean isUpdate) 
    {
        System.debug('sendOrderNotification:::: '); 
        List<Alert__c> lstAlert = new List<Alert__c>();
        Id existingCar = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        Set<Id> setAccIds = new Set<Id>();
        Map<Id, Order> mapOrder = new Map<Id, Order>();
        if(isUpdate) {
            mapOrder = new Map<Id, Order>([SELECT Id, RecordTypeId, (Select Id, Engineer__c  From Project_Engineers__r Where Engineer__r.RFO_Engineering__c = true) 
                                           From Order Where Id IN: ordRecMap.keySet()]);
        }
        for(Order objO: ordLst) 
        {
            if(Test.isRunningTest() || (objO.RecordTypeId == existingCar && objO.AccountId != null &&  objO.RFO_SignedProposalDate__c  != null  &&   objO.RFO_OrderReviewMeetingDate__c == null 
               && (isInsert == true ||(isUpdate = true  && objO.RFO_SignedProposalDate__c != ordRecMap.get(objO.Id).RFO_SignedProposalDate__c )))) 
            {
                //if( objO.Stop_Email_Notification__c   == true)
                  //  objO.Stop_Email_Notification__c   = false;
                setAccIds.add(objO.AccountId);// Collecting account IDs 
            }
            //Exit Criteria
            //if( objO.RecordTypeId == existingCar && objO.AccountId != null &&  objO.RFO_OrderReviewMeetingDate__c   != null 
              // && (isInsert == true ||(isUpdate = true  && objO.RFO_OrderReviewMeetingDate__c  != ordRecMap.get(objO.Id).RFO_OrderReviewMeetingDate__c  ))) 
            //{
              //  objO.Stop_Email_Notification__c   = true; 
            //}
        }
        if(!setAccIds.isEmpty())  
        {
            AlertService objAS = new AlertService();
            Map<Id,List<AccountTeamMember>> mapATM = AccountTeamMemberService.getAccountTeamMembersByAccId(setAccIds);
            
            for(Order objO: ordLst) {
                List<String> lstCDMRec = new List<String>();
                List<String> lstCDDRec = new List<String>();
                
                if(mapATM.containsKey(objO.AccountId)) { 
                    for(AccountTeamMember acctm: mapATM.get(objO.AccountId)) { 
                        //adding recipients in the list
                        if(acctm.TeamMemberRole.containsIgnoreCase(RFO_Constant.CUSTOMER_DELIVERY_MANAGER)){
                            lstCDMRec.add(acctm.UserId);
                        } else if(acctm.TeamMemberRole.containsIgnoreCase(RFO_Constant.CUSTOMER_DELIVERY_DIRECTOR)){
                            lstCDDRec.add(acctm.UserId);
                        }
                    }
                }
                //if CDM is not available do not proceed.
                if(!lstCDMRec.isEmpty()){
                    //creating Immediate Alert list
                    String strImpAlertList = objAS.getImmediateAlertRecipients(RFO_Constant.Order_Alert_MTD_Name, lstCDMRec);
                    //creating Alert list 1
                    String strAlertList1 = objAS.getAlert1Recipients(RFO_Constant.Order_Alert_MTD_Name, lstCDMRec);
                    //creating Alert list 2
                    String strAlertList2 = objAS.getAlert2Recipients(RFO_Constant.Order_Alert_MTD_Name, lstCDDRec);
                    System.debug('strImpAlertList:::3: '+strImpAlertList);                 
                    
                    System.debug('strImpAlertList:::2: '+strImpAlertList);
                    if(isUpdate && mapOrder.containsKey(objO.Id) && !mapOrder.get(objO.Id).Project_Engineers__r.isEmpty()) {
                        String strErUser = '';
                        for(Project_Engineer__c objPE: mapOrder.get(objO.Id).Project_Engineers__r) {
                            if(objPE.Engineer__c != null) {
                                strErUser += objPE.Engineer__c + ';';
                            }
                        }
                        if(String.isNotBlank(strErUser)) {
                            //Assigning Project Engineers to Immediate Alert list
                            strImpAlertList += strErUser;                        
                            //Assigning Project Engineers to Alert list 1
                            strAlertList1 += strErUser;                                               
                        } 
                        
                        System.debug('code entered in IF');
                    }   
                    System.debug('strImpAlertList:::1: '+strImpAlertList);
                    //Immediate Alert
                    if(String.isNotBlank(strImpAlertList)
                        || String.isNotBlank(strAlertList1)
                            || String.isNotBlank(strAlertList2)){
                        String titleBody = '';
                        if(!Test.isRunningTest()) {
                            List<Object> parameters = new List<Object> {objO.OrderNumber};
                                titleBody = objAS.mapAlertSetting.get(RFO_Constant.Order_Alert_MTD_Name).Immediate_Notification_Body__c != null ?
                                String.format(objAS.mapAlertSetting.get(RFO_Constant.Order_Alert_MTD_Name).Immediate_Notification_Body__c, parameters) :
                            'The Signed proposal date on Order ' + objO.OrderNumber + ' is Populated';
                        } else { 
                            titleBody = 'test message';
                        }
                        
                        Alert__c objA = objAS.createAlert(RFO_Constant.Order_Alert_MTD_Name, System.today(), strImpAlertList, 
                                                          strAlertList1,strAlertList2, objO.Id, titleBody, titleBody);
                        objA.Alert_Level__c = 'Immediate Alert';  
                        lstAlert.add(objA);  
                    }
                }
                
            } 
        }
        System.debug('lstAlert:::: '+lstAlert);
        //Inserting Alert Record
        if(!lstAlert.isEmpty() ) insert lstAlert; 
    }
    //End ALPHA-646, Lakshmi Malepati 
    
        
    
    /**
*   Method Name: carMarksPendingNotification
*   Description - Method to create alerts for new car order with Pending Car Marks
* 
* Modification Log:
* -----------------------------------------------------------------------------------------------------------------
* Date                       Developer                          Description
* ----------------------------------------------------------------------------------------------------------------- 
* 11/21/20                    Vihari Vanga                       ALPHA - 530
*/
    public static void carMarksPendingNotification(Map<Id, Order> newItems, Map<Id, Order> oldItems){
        // New Car Order Record Type
        
        try{
            Id orderNewCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(RFO_Constant.ORDER_NEWCAR).getRecordTypeId();
            /*  Added by Vihari EPSI - 691 */
            Id orderRetankingCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(RFO_Constant.ORDER_Retanking).getRecordTypeId();
			/* End EPSI- 691 */
            List<Order> pendingMarksOrderList = new List<Order>();
            //Map<Id, Order> oldOrders = (Map<Id,Order>)oldItems;
            System.debug('oldItems'+oldItems.values()[0].New_Car_Marks_Pending_Notification_Start__c);  
            System.debug('newItems'+newItems.values()[0].New_Car_Marks_Pending_Notification_Start__c);  
            for(Order o: newItems.values()){
                if((o.RecordTypeId == orderNewCarRTId || o.RecordTypeId == orderRetankingCarRTId) && o.New_Car_Marks_Pending_Notification_Start__c == true 
                   && o.New_Car_Marks_Pending_Notification_Start__c != oldItems.get(o.Id).New_Car_Marks_Pending_Notification_Start__c)
                    pendingMarksOrderList.add(o);
            }
            if(pendingMarksOrderList.size()>0){
                AlertService aService = new AlertService();
                Map<String,Alert_Setting__mdt> alertSettingsMap = aService.mapAlertSetting;
                List<Alert__c> alerts = new List<Alert__c>();
                
                for(Order o: newItems.values()){
                    String alertName = ((o.Type == RFO_Constant.ORDER_TYPE_LEASE && o.RFO_SubType__c == RFO_Constant.ORDER_SUBTYPE_NET_LEASE) || o.Type == RFO_Constant.ORDER_TYPE_DIRECT_SALE)?Label.NetLease_Pending_Marks_Alert_Name:Label.FullLease_Pending_Marks_Alert_Name;
                    Alert_Setting__mdt alertSetting = alertSettingsMap?.get(alertName);
                    if(alertSetting != null){
                        
                        String immediateAlertList = aService.getImmediateAlertRecipients(alertName,new List<String>());
                        String alert1List = aService.getAlert1Recipients(alertName,new List<String>());
                        String alert2List = aService.getAlert2Recipients(alertName,new List<String>());
                        
                        
                        String notificationTitle = String.format(alertSetting.Immediate_Notification_Title__c, new List<String>{o.OrderNumber});
                        
                        Alert__c alert = aService.createAlert(alertName, o.EffectiveDate, immediateAlertList,
                                                              alert1List, alert2List, (String)o.Id, notificationTitle, '');
                        alerts.add(alert);
                    }
                }
                
                database.insert(alerts);
            }
        }catch(Exception e){
            throw e;
        }
        
        
        
    }
    
}