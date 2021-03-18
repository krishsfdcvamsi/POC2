/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 05th July 2019
* @Description : This class is to update Rider Renewal Opportunity
*                
**/
public class RFO_RiderTriggerHelper {
    /**
*   Method Name: updateRenewalOpportunity
*   Creates Renewal opportunity record for Rider object.
**/
    public static void updateRenewalOpportunity(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id, Opportunity> renewalOppMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> MangmntServOppMap = new Map<Id, Opportunity>();
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        List<Opportunity> createRenewalOptyList = new List<Opportunity>();
        
        Id renewalOppRecordtype = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY).getRecordTypeId();
        ID optyMangmntServRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId();
        Date todayPlus120day = system.today().addDays(120);
        
        for(Opportunity opp : [select Id, Name, RFO_RiderID__c, StageName, RFO_MileageFee__c,  
                               RFO_Mileage__c, RFO_PreferredNewExisting__c, RFO_ConfidenceLevel__c, RFO_MarketSegment__c,
                               Type, AccountId, RFO_ProductType__c, RFO_ExpectedCarstoTrinity__c, TotalOpportunityQuantity,
                               CloseDate, RecordTypeId, RFO_IsOpportunityConverted__c
                               from Opportunity where RFO_RiderID__r.Id in :newItems.keySet() and (RecordtypeId =:renewalOppRecordtype or  RecordtypeId =:optyMangmntServRtId)]) 
        {
            if(opp.RecordtypeId == renewalOppRecordtype){
                renewalOppMap.put(opp.RFO_RiderId__c,opp);
            }
            if(opp.RecordtypeId == optyMangmntServRtId){
                MangmntServOppMap.put(opp.RFO_RiderId__c,opp);
            }
        }
        
        for(sObject riderRec: newItems.values()){
            System.debug('new items');
            if(!renewalOppMap.isEmpty()) {
                if(riderRec.get('RFO_AutoRenewal__c') == RFO_Constant.YES && oldItems.get(riderRec.Id).get('RFO_AutoRenewal__c') == RFO_Constant.NO && renewalOppMap.containsKey(riderRec.id)){
                    Opportunity opp = renewalOppMap.get(riderRec.Id);
                    opp.StageName = 'Hold - Auto Renewal';
                    updateOpportunityList.add(opp);
                }
            }
            if(!MangmntServOppMap.isEmpty()) {
                if(riderRec.get('RFO_AutoRenewal__c') == RFO_Constant.YES && oldItems.get(riderRec.Id).get('RFO_AutoRenewal__c') == RFO_Constant.NO && MangmntServOppMap.containsKey(riderRec.id)){
                    Opportunity opp = MangmntServOppMap.get(riderRec.Id);
                    opp.StageName = RFO_Constant.OPTY_STAGE_NAME;
                    updateOpportunityList.add(opp);
                }
            }
            if(riderRec.get('RFO_AutoRenewal__c') == RFO_Constant.NO && oldItems.get(riderRec.Id).get('RFO_AutoRenewal__c') == RFO_Constant.YES && (Date)riderRec.get('RFO_OriginalMaturityDate__c') <= todayPlus120day && (Date)riderRec.get('RFO_OriginalMaturityDate__c') >= System.today() ){
                if(renewalOppMap.isEmpty() && 
                  riderRec.get('RFO_RiderType__c')!=null && 
                   (!(riderRec.get('RFO_RiderType__c').equals( RFO_Constant.MANAGEMENT_AGREEMENT  ) || 
                    riderRec.get('RFO_RiderType__c').equals( RFO_Constant.MAINTENANCE_AGREEMENT) ))
                  ){
                    System.debug('entered loop');
                    RFO_OpportunityHelper.createRenewalOpportunity((RFO_Rider__c)riderRec, RFO_Constant.TRIGER);
                }
                if(MangmntServOppMap.isEmpty() && riderRec.get('RFO_RiderType__c')!=null && 
                  (riderRec.get('RFO_RiderType__c').equals( RFO_Constant.MANAGEMENT_AGREEMENT  ) || 
                    riderRec.get('RFO_RiderType__c').equals( RFO_Constant.MAINTENANCE_AGREEMENT) )
                  ){
                    RFO_OpportunityHelper.createManagementServicesOpp((RFO_Rider__c)riderRec, RFO_Constant.TRIGER);
                }
            }
        }
        if(updateOpportunityList.size()>0){
            update updateOpportunityList;
        }
    }
/*
 * D-1772, requested to make Account field on Rider as read only on pagelayout,
 * and to update the Account field with the Account from the Contract related to the Rider.
 * */     
    public static void updateAccountName(List<SObject> newList, Map<Id, SObject> oldMap, String Status){
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id, Contract> contractMap;
        for(RFO_Rider__c rider : (List<RFO_Rider__c>)newList){
            if(Status == RFO_Constant.RECORD_UPDATED && 
               ((rider.RFO_Contract__c != ((RFO_Rider__c)oldMap.get(rider.Id)).RFO_Contract__c)
              || rider.RFO_Account__c==null))
            {
            	contractIdSet.add(rider.RFO_Contract__c);
            }
            else if(Status == RFO_Constant.RECORD_CREATED){
                contractIdSet.add(rider.RFO_Contract__c);
            }
        }
        if(!contractIdSet.isEmpty()){
            contractMap = new Map<Id, Contract>([Select Id, AccountId from Contract where Id in :contractIdSet]);
            if(!contractMap.isEmpty()){
                for(RFO_Rider__c rider : (List<RFO_Rider__c>)newList){
                    rider.RFO_Account__c = contractMap.get(rider.RFO_Contract__c).AccountId;
                }
            }
        }
    }



	 public static void updateOrderstatus(Map<id,List<RFO_Rider__c>> newItemsMap){

        
    Id orderExstingCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
     List<RFO_Rider__c> riderUpdateList = new List<RFO_Rider__c>();
    List<Order> ordUpdateList = new List<Order>();
    Map<id,List<Order>> ordUpdateMap = new Map<id,List<Order>>();
    List<RFO_Rider__c> riderList = new List<RFO_Rider__c>();
    List<String> statusList= new List<String>();
    Map<id,List<String>> orderStatusFileMap = new Map<id,List<String>>();
    
    riderUpdateList =[select id,RFO_OrderID__c,RFO_Status__c,RFO_OrderID__r.RecordTypeID,RFO_OrderID__r.Status from RFO_Rider__c where RFO_OrderID__c IN:newItemsMap.KeySet() AND RFO_OrderID__r.RecordTypeID =:orderExstingCarRTId  Limit 49999];
   
    for(RFO_Rider__c rider: riderUpdateList){
                            statusList.add(rider.RFO_Status__c);
                           orderStatusFileMap.put(rider.RFO_OrderID__c,statusList);
            }
       if(orderStatusFileMap != null){
        for(RFO_Rider__c rider: riderUpdateList){
       if(!(orderStatusFileMap.get(rider.RFO_OrderID__c).contains('Rider Initiated') || orderStatusFileMap.get(rider.RFO_OrderID__c).contains('Contract Documents Sent to Customer') || orderStatusFileMap.get(rider.RFO_OrderID__c).contains('Signed Contract Documents Received') ||
		orderStatusFileMap.get(rider.RFO_OrderID__c).contains('Ready for Delivery') ||
		orderStatusFileMap.get(rider.RFO_OrderID__c).contains('Rider Cancelled'))){
        rider.RFO_OrderID__r.Status = 'Order Complete';
               if(!ordUpdateMap.containsKey(rider.RFO_OrderID__c)){
                   ordUpdateList.add(rider.RFO_OrderID__r);
                   ordUpdateMap.put(rider.RFO_OrderID__c,ordUpdateList);
                  }            
             }
          }
        }
 if(ordUpdateList.size()>0){
  Database.update(ordUpdateList);
     system.debug('*** ordUpdateList Updated***'+ordUpdateList);
  }          
 }


      

    // Changed by Ramesh Start for ALpha-36
    /**
    *	Method Name: associateOpportunity
    *	Description: This method for Assign Opportunity
    * */
    
    public static void associateOpportunity(List<RFO_Rider__c> newList){ 
        
        // Declering the variables
        List<Id> lstIds = new List<Id>();
        Map<Id,Id> mapIds = new Map<Id,Id>();
        list<string> originalCloneIds = new list<string>();

       
        // Looping the new list
        for(RFO_Rider__c r : newList){
            
            // checking the order id is null or not
            if(r.isClone() && r.RFO_OrderID__c == null){
                originalCloneIds.add(r.getCloneSourceId());
            }
            if(!r.isClone() && r.RFO_OrderID__c != null) { 
                lstIds.add(r.RFO_OrderID__c);
            }
        }
        if(originalCloneIds.size() > 0){
            
          	// Query on the Rider object to get the opportunity__c value. (This filed is not present in page, at the time of cloning this value will be null so need to get this value by quering on the rider)
            map<id,RFO_Rider__c> oldRiders = new map<id,RFO_Rider__c>([select id, Opportunity__c from RFO_Rider__c where id in: originalCloneIds]);

            
            // Looping the new list once again to assigning the values in opportunity__c and Opportunity_Cloned__c
            for(RFO_Rider__c r : newList){
                if(oldRiders.containsKey(r.getCloneSourceId()))
                    r.Opportunity__c = oldRiders.get(r.getCloneSourceId()).Opportunity__c; // Assigning the opportunity id 
                    r.Opportunity_Cloned__c = oldRiders.get(r.getCloneSourceId()).Opportunity__c; // Assigning the opportunity id 
                }
        }
		
        // In case order is present in the opportunity id we are getting the opportunity ID from the oerder object
        if(lstIds.size() > 0){
            
            // Query on order for getting opportunityID
            for( Order  objOrder : [Select id, name, OpportunityId from Order where id in : lstIds]){
                
                // Putting values of order id and opportunity id to handle the bulk insert
                mapIds.put(objOrder.id, objOrder.OpportunityId);
            }
        }
        

        // Looping the new list once again to assigning the values in opportunity__c and Opportunity_Cloned__c

        for(RFO_Rider__c rider : newList){
            
            // Checking the order id not null and it should contain in the map
            if(rider.RFO_OrderID__c != null && mapIds.containsKey(rider.RFO_OrderID__c)) { 
                if(rider.Opportunity__c == null && mapIds.get(rider.RFO_OrderID__c) != null)
                    rider.Opportunity__c = mapIds.get(rider.RFO_OrderID__c); // Assigning the opportunity id 
                	rider.Opportunity_Cloned__c = mapIds.get(rider.RFO_OrderID__c); // Assigning the opportunity id 
            }
        }

    }
// Changed by Ramesh End for Alpha-36

    
    
 /*
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * ----------------------------------------------------------------------------------------------------------------- 
 * 10/01/20                    Ashish Reddy                      ALPHA - 166
 */
    public static void updateEligibleOrdersToDeliveryComplete( Map<Id, Id> orderToRiderMap){
        
        Map<id, Order> deliveryCompleteOrders = new Map<id, Order>();
        Map<Id,List<RFO_Rider__c>> ridersByOrderIdMap =  RiderService.getAllRidersByOrderId(orderToRiderMap.keySet());
        
        if(ridersByOrderIdMap != null && !ridersByOrderIdMap.isEmpty()){            
            Map<Id, Order> ordersMap = OrderService.getOrdersByOrderIds(ridersByOrderIdMap.keySet());
            if(ordersMap != null && !ordersMap.isEmpty()){
                for(Order ord : ordersMap.values()){
                    if(ord.Status != RFO_Constant.STATUS_DELIVERY_COMPLETE){
                        Boolean allRidersDeliveryComplete = true;
                        for(RFO_Rider__c rider : ridersByOrderIdMap.get(ord.Id)){

                            if((((ord.RecordType.DeveloperName == RFO_Constant.ORDER_NEWCAR || ord.RecordType.DeveloperName == RFO_Constant.ORDER_Retanking) && rider.RFO_Status__c != RFO_Constant.STATUS_DELIVERY_COMPLETE)
                                || (ord.RecordType.DeveloperName == RFO_Constant.ORDER_EXISTINGCAR)) && rider.RFO_AvgBeginCharge__c == null 
                               && (ord.Type == RFO_Constant.LEASE || ord.Type == RFO_Constant.ORDER_TYPE_DIRECT_SALE)){
                                allRidersDeliveryComplete = false;     
                                break;                           
                            }
                        }
                        if(allRidersDeliveryComplete){
                            ord.Status = RFO_Constant.STATUS_DELIVERY_COMPLETE;
                            deliveryCompleteOrders.put(ord.Id, ord);
                        }
                    }
                }
            }
        }
        if(deliveryCompleteOrders.size()>0){
            Database.update(deliveryCompleteOrders.values()); 
        }
    }
    
   /**
    *   Method Name: autoAssignFieldsForClonedRider
    *   Auto Assign Field for Assumption Cloned Rider
    * 
 	* Modification Log:
 	* -----------------------------------------------------------------------------------------------------------------
	 * Date                       Developer                          Description
	 * ----------------------------------------------------------------------------------------------------------------- 
 	* 11/18/20                    Vihari Vanga                       ALPHA - 22
    * 02/26/21                    Ashish Reddy                      EPSI-811  
 	*/
    public static void autoAssignFieldsForClonedRider(List<RFO_Rider__c> newList){
          
        for (RFO_Rider__c objRider:newList) {
            //Epsi-811- start
            objRider.RFO_CurrentMaturityDate__c= null;
            objRider.RFO_OriginalMaturityDate__c = null;
            //Epsi-811- End
            if(objRider.Assumption__c != null && objRider.Assumption_Account_Number__c != null){
                objRider.Destination_Assumption__c = objRider.Assumption__c;
                objRider.Source_Rider__c = objRider.getCloneSourceId();
                objRider.RFO_Account__c=objRider.Assumption_Account_Number__c;
                objRider.Assumption__c = null;
                objRider.Assumption_Account_Number__c = null;
                objRider.RFO_RiderId__c = null;
                objRider.Assumed_of_Cars__c = null;
            }

        }
    }
}