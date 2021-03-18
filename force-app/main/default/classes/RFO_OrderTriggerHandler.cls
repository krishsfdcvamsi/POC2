/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 7th Dec 2019
* @Description : 
*                
**/
public class RFO_OrderTriggerHandler implements ITriggerHandler{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean triggerDisabled = false;
    RFO_TriggerSetting__mdt caseTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='OrderTrigger' LIMIT 1];
    /*****
Checks to see if the trigger has been disabled either by custom setting or by running code
*****/
    public Boolean isDisabled()
    {
        if (caseTrigger.RFO_Active__c){
            return triggerDisabled;
        }else{
            return true;
        }
    }
    
    /*****
* Method Name: BeforeInsert
*****/
    public void beforeInsert(List<SObject> newItems) {
        try{
            RFO_OrderTriggerHelper.orderStageRequiredFields((List<Order>)newItems, null);
            RFO_OrderTriggerHelper.updateOrderFields((List<Order>)newItems);
            RFO_OrderTriggerHelper.addPriceBook((List<Order>) newItems); // Changed By ramesh - To make Order as Completed, adding a Product Order on Order.
            RFO_OrderTriggerHelper.sendOrderNotificationExitCheck((List<Order>)newItems,new Map<id,Order>(),true,false); //ALPHA-646, Lakshmi Malepati
            //RFO_OrderTriggerHelper.createEscalationTask((List<Order>)newItems,new Map<id,Order>(),true,false); //ALPHA-581, Lakshmi Malepati
            RFO_OrderTriggerHelper.isRequiredTaskAndAlertBefore((List<Order>)newItems,new Map<id,Order>(),true,false); //ALPHA-1748, Lakshmi Malepati
        } 
        catch(Exception e) {   
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),RFO_Constant.OPPORTUNITY_OBJECT,
                                                   RFO_Constant.TRIGER,'RFO_OrderTriggerHandler','beforeInsert');
        }
        
    }
    
    /**
* Method Name: beforeUpdate
**/
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        //Alpha - 521 Start - Haseeb
        // Get Order Existing Record Type Id
        map<id, order> oldOrderMap = (map<id, order>)oldItems;
        list<order> orderIds = new list<order>();
        list<order> orderStatusCompleted = new list<order>();
        string ExistingRTId = Schema.SObjectType.order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        if(newItems != null){
            for(order o : (List<Order>)newItems.values()){
                if(o.Status != oldOrderMap.get(o.id).Status && o.Status == RFO_Constant.Order_Status_Process && o.RecordTypeId == ExistingRTId){
                    orderIds.add(o);
                }
                if(o.Status != oldOrderMap.get(o.id).Status && o.Status == RFO_Constant.Order_Status_Complete && o.RecordTypeId == ExistingRTId){
                    orderStatusCompleted.add(o);
                }
                //Alpha - 520 Start - Ramesh
                if(oldOrderMap.get(o.id).Status == 'External ORM' && o.Status == 'Change Request in Progress' && o.RFO_OrderReviewMeetingDate__c != null){
                    o.Status = 'Order in Process';
                }
                //Alpha - 520 End - Ramesh
                // Vihari ALPHA - 530, Stop Car Marks Pending Alerts
                // New Car Order Record Type
                Id orderNewCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(RFO_Constant.ORDER_NEWCAR).getRecordTypeId();
                /*  Added by Vihari EPSI - 691 */
        		Id orderRetankingCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(RFO_Constant.ORDER_Retanking).getRecordTypeId();
        		/* End EPSI- 691 */
                if((o.RecordTypeId == orderNewCarRTId || o.RecordTypeId == orderRetankingCarRTId) && o.New_Car_Marks_Pending_Notification_Start__c == true
                   && o.Total_Asset_Count__c != oldOrderMap.get(o.Id).Total_Asset_Count__c && o.Total_Asset_Count__c>0){
                    o.New_Car_Marks_Pending_Notification_Stop__c = true;
                    o.New_Car_Marks_Pending_Notification_Start__c = false;
                } 
                /* End Vihari ALPHA-530 */
            }
            if(orderIds.size() > 0)
                validateOrderInProcess(newItems,orderIds);
            
            if(orderStatusCompleted.size() > 0)
                validateOrderComplete(newItems, orderStatusCompleted);
        }
        //Alpha - 521 End - Haseeb
        //
        //Alpha - 520 Start - Ramesh
         
        try{
            RFO_OrderTriggerHelper.orderStageRequiredFields((List<Order>)newItems.values(), oldItems);
            //RFO_OrderTriggerHelper.updateOrderFields((List<Order>)newItems.values());
            RFO_OrderTriggerHelper.sendOrderNotificationExitCheck((List<Order>)newItems.values(),(Map<Id, Order>)oldItems,false,true);//ALPHA-646, Lakshmi Malepati
           // RFO_OrderTriggerHelper.createEscalationTask((List<Order>)newItems.values(),(Map<Id, Order>)oldItems,false,true); //ALPHA-581, Lakshmi Malepati
           RFO_OrderTriggerHelper.isRequiredTaskAndAlertBefore((List<Order>)newItems.values(),(Map<Id, Order>)oldItems,false,true); //ALPHA-1748, Lakshmi Malepati
        } 
        catch(Exception e) {   
            RFO_Utility.createErrorLogRecordFuture(e.getMessage(),'Order',
                                                   RFO_Constant.TRIGER,'RFO_OrderTriggerHandler','beforeUpdate');
        } 

              
        
        if(newItems != null) RFO_OrderTriggerHelper.addPriceBook((List<Order>) newItems.values()); // Changed By ramesh Alpha-
    }
    
    /**
* Method Name: beforeDelete
**/
    public void beforeDelete(Map<Id, SObject> oldItems) {}
    
    /**
* Method Name: afterInsert
**/
    public void afterInsert(Map<Id, SObject> newItems) {
        newItems = newItems != null ? newItems : new Map<Id, SObject>();
        RFO_OrderTriggerHelper.sendOrderNotification((List<Order>)newItems.values(),new Map<id,Order>(),true,false); //ALPHA-646, Lakshmi Malepati
        RFO_OrderTriggerHelper.isRequiredTaskAndAlert((List<Order>)newItems.values(),new Map<id,Order>(),true,false); //ALPHA-1748, Lakshmi Malepati
    }
    
    /**
* Method Name: afterUpdate
**/
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        RFO_OrderTriggerHelper.insertOrderProduct(newItems);
        //Alpha-680 start
        RFO_OrderTriggerHelper.handleNewCarSampleCarAlerts( (Map<Id, Order>)newItems, (Map<Id, Order>)oldItems);
        //Alpha-680 stop
        RFO_OrderTriggerHelper.UMLERStatusTaskEscalation((Map<Id, Order>)newItems, (Map<Id, Order>)oldItems); //Haseeb, Alpha-678, 
        //Alpha-585 shipping Commence Notification/alert
        map<id, order> oldOrderMap = (map<id, order>)oldItems;
        RFO_OrderTriggerHelper.shippingCommenceDateNotifications(newItems,oldOrderMap);
        
        // Vihari ALPHA-530
        RFO_OrderTriggerHelper.carMarksPendingNotification((Map<Id, Order>)newItems, (Map<Id, Order>)oldItems);   
        /* End */
        RFO_OrderTriggerHelper.sendOrderNotification((List<Order>)newItems.values(),(Map<Id, Order>)oldItems,false,true);//ALPHA-646, Lakshmi Malepati
        RFO_OrderTriggerHelper.isRequiredTaskAndAlert((List<Order>)newItems.values(),(Map<Id, Order>)oldItems,false,true); //ALPHA-1748, Lakshmi Malepati
    }
    
    /**
* Method Name: afterDelete
**/
    public void afterDelete(Map<Id, SObject> oldItems) {}
    
    /**
* Method Name: afterUndelete
**/
    public void afterUndelete(Map<Id, SObject> oldItems) {}
    
    /**********************************************************************************************
* Haseeb, Alpha-521
* Purpose: Validates Order Status based on all child case status. 
**********************************************************************************************/
    public void validateOrderInProcess(Map<Id, SObject> newItems, list<Order> orderIds){
        list<case> OrderCR = [select id,status,RFO_OrderID__c from case where RFO_OrderID__c in: orderIds and status != 'Change Request Cancelled' and status != 'Closed'];
        set<string> errorOrderIds = new set<string>();
        for(case c : OrderCR){
            errorOrderIds.add(c.RFO_OrderID__c);
        }
        for(order o : (List<Order>)newItems.values()){
            if(errorOrderIds.contains(o.Id))
                o.addError('Error: All change requests must be Acknowledged/Cancelled before changing order status');
        }
    }
    
    public void validateOrderComplete(Map<Id, SObject> newItems, list<Order> orderStatusCompleted){
        list<case> OrderCR = [select id,status,RFO_OrderID__c from case where RFO_OrderID__c in: orderStatusCompleted and status !=: RFO_Constant.Case_Status_Acknowledge and status !=: RFO_Constant.Case_Status_Rejected];
        set<string> errorOrderIds = new set<string>();
        for(case c : OrderCR){
            errorOrderIds.add(c.RFO_OrderID__c);
        }
        for(order o : (List<Order>)newItems.values()){
            if(errorOrderIds.contains(o.Id))
                o.addError('Error: All change requests must be Approved/Rejected before changing order status');
        }
    }
    /************************************************************************************************
* End- Alpha-521, Haseeb
************************************************************************************************/
    
}