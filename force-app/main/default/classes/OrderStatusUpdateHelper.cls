/************************************************************************************************** 
 * Name: OrderStatusUpdateHelper
 * Created By: Haseeb
 * Created Date: September 2020
 * Jira: ALpha- 520, 521 & 523
 * Purpose: Update Order Status based on the Case and ChangeRequestLineItem Status.
 **************************************************************************************************/

public class OrderStatusUpdateHelper {
    
    //Updates the status on Case based on the Customer Approval of all Child Change Request Line Items
    public static void updateChangeRequestStatus(list<RFO_ChangeRequestLineItem__c> newCRLIList, map<id,RFO_ChangeRequestLineItem__c> oldMapCRLI){
        // Get Order Existing Record Type Id
        string ExistingRTId = Schema.SObjectType.order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        string NewCarRTId = Schema.SObjectType.order.getRecordTypeInfosByName().get('New Car').getRecordTypeId();// Ramesh, Alpha-520, Applicable to New Car RT as well, September 2020
        system.debug(' ~~~ Order Existing Record Type ID: '+ExistingRTId);
        list<string> CRLIList = new list<string>();
        list<case> updateCaseStatus = new list<case>();
        CRLIList = filterCRLI(newCRLIList, oldMapCRLI);        
                
        if(CRLIList.size()>0){
            system.debug('~~~ CRLIList :'+CRLIList);
            //Filter Change Request Line Item only for Existing New Car Order Record type
            list<RFO_ChangeRequestLineItem__c> CRLIs = [select id,RFO_CustomerApproval__c,RFO_ChangeRequestID__c,RFO_ChangeRequestID__r.RFO_OrderID__c,
                                                        RFO_ChangeRequestID__r.RFO_OrderID__r.RecordTypeId from RFO_ChangeRequestLineItem__c where RFO_ChangeRequestID__c in: CRLIList and 
                                                        (RFO_ChangeRequestID__r.RFO_OrderID__r.RecordTypeId =: ExistingRTId or RFO_ChangeRequestID__r.RFO_OrderID__r.RecordTypeId =:NewCarRTId)];
            if(CRLIs.size() > 0){
                map<string,set<string>> mapCaseCRLI = new map<string,set<string>>();
                mapCaseCRLI = getMapCRChildRecords(CRLIs);
                for(string caseid : mapCaseCRLI.keyset()){
                    if(mapCaseCRLI.get(caseid).contains('Approved') && !mapCaseCRLI.get(caseid).contains(null)){
                        //if(!mapCaseCRLI.get(caseid).contains(null)){
                        case c = new case();
                        c.Id = caseid;
                        c.Status = RFO_Constant.Case_Status_Acknowledge;//'Change Request Acknowledged';
                        updateCaseStatus.add(c);
                    }
                    else if(!mapCaseCRLI.get(caseid).contains('Approved') && !mapCaseCRLI.get(caseid).contains(null)){
                        case c = new case();
                        c.Id = caseid;
                        c.Status = RFO_Constant.Case_Status_Rejected;//'Change Request Rejected';
                        updateCaseStatus.add(c);
                    }
                }
            }
        }
        //Alpha - 520 Start - Ramesh
        if(updateCaseStatus.size()>0)
        	update updateCaseStatus;
        //Alpha - 520 End - Ramesh
    }
    
    //Filters Change Request Line Items for those of Customer approval has been updated
    public static list<string> filterCRLI(list<RFO_ChangeRequestLineItem__c> newCRLIList, map<id,RFO_ChangeRequestLineItem__c> oldMapCRLI){
        list<string> CRLIList = new list<string>();
        for(RFO_ChangeRequestLineItem__c crli : newCRLIList){
            if(oldMapCRLI != null){
                if(crli.RFO_CustomerApproval__c != oldMapCRLI.get(crli.Id).RFO_CustomerApproval__c){
                    CRLIList.add(crli.RFO_ChangeRequestID__c);
                }
            }
            else{
                if(crli.RFO_CustomerApproval__c != null){
                    CRLIList.add(crli.RFO_ChangeRequestID__c);
                }
            }
        }
        return CRLIList;
    }
    
    //Returns a map of case and child Change request line item records
    public static map<string,set<string>> getMapCRChildRecords(list<RFO_ChangeRequestLineItem__c> CRLIs){
        map<string,set<string>> mapCaseCRLI = new map<string,set<string>>();
        for(RFO_ChangeRequestLineItem__c crli : CRLIs){
            if(mapCaseCRLI.containsKey(crli.RFO_ChangeRequestID__c)){
                set<string> CRItemSet = mapCaseCRLI.get(crli.RFO_ChangeRequestID__c);
                CRItemSet.add(crli.RFO_CustomerApproval__c);
                mapCaseCRLI.put(crli.RFO_ChangeRequestID__c,CRItemSet);
            }
            else{
                set<string> newCRItemSet = new set<string>();
                newCRItemSet.add(crli.RFO_CustomerApproval__c);
                mapCaseCRLI.put(crli.RFO_ChangeRequestID__c,newCRItemSet);
            }
        }
        return mapCaseCRLI;
    }
    
    //Update status on Order based on all Case child records status
    Public static void updateOrderStatus(list<case> newCaseList, map<id,case> oldMapCase){
        system.debug('~~ Order Update Status Entered ~');
        // Get Order Existing Record Type Id
        string ExistingRTId = Schema.SObjectType.order.getRecordTypeInfosByName().get('Existing Car').getRecordTypeId();
        string NewCarRTId = Schema.SObjectType.order.getRecordTypeInfosByName().get('New Car').getRecordTypeId();
        list<string> caseList = new list<string>();
        list<order> orderToUpdate = new list<order>();
        
        for(case c : newCaseList){
            if(c.Status != oldMapCase.get(c.id).Status && (c.Status == RFO_Constant.Case_Status_Acknowledge || c.Status == RFO_Constant.Case_Status_Rejected|| c.Status ==  RFO_Constant.Case_Status_Closed || c.Status ==  RFO_Constant.Case_Status_Cancelled))
                caseList.add(c.RFO_OrderID__c);
        }
        if(caseList.size() > 0){
            list<case> CasesL = CaseService.getCasesByOrderId(caseList, ExistingRTId, NewCarRTId);
            //list<case> CasesL = [select id,status,RFO_OrderID__c,RFO_OrderID__r.RecordTypeID from case where RFO_OrderID__c in: caseList and (RFO_OrderID__r.RecordTypeID =:ExistingRTId or RFO_OrderID__r.RecordTypeID =:NewCarRTId)];
            map<string,set<string>> mapOrderCRStatus = new map<string,set<string>>();
            if(casesL.size()>0){
                mapOrderCRStatus = getMapCaseChildRecords(CasesL);
                
                for(string orderid : mapOrderCRStatus.keyset()){
                    if(mapOrderCRStatus.get(orderid).size()==1 && (mapOrderCRStatus.get(orderid).contains(RFO_Constant.Case_Status_Acknowledge) || mapOrderCRStatus.get(orderid).contains(RFO_Constant.Case_Status_Rejected))){
                        order o = new order();
                        o.id = orderid;
                        o.Status = RFO_Constant.Order_Status_Complete;//'Change Request Complete';
                        orderToUpdate.add(o);
                	}
                    else if(mapOrderCRStatus.get(orderid).size()==2 && mapOrderCRStatus.get(orderid).contains(RFO_Constant.Case_Status_Acknowledge) && mapOrderCRStatus.get(orderid).contains(RFO_Constant.Case_Status_Rejected)){
                        order o = new order();
                        o.id = orderid;
                        o.Status = RFO_Constant.Order_Status_Complete;//'Change Request Complete';
                        orderToUpdate.add(o);
                    }
                    else if(mapOrderCRStatus.get(orderid).size()==1 && (mapOrderCRStatus.get(orderid).contains(RFO_Constant.Case_Status_Closed) || mapOrderCRStatus.get(orderid).contains(RFO_Constant.Case_Status_Cancelled))){
                        order o = new order();
                        o.id = orderid;
                        o.Status = RFO_Constant.Order_Status_Process;//'Order in Process';
                        orderToUpdate.add(o);
                    }
                    else if(mapOrderCRStatus.get(orderid).size()==2 && mapOrderCRStatus.get(orderid).contains(RFO_Constant.Case_Status_Closed) && mapOrderCRStatus.get(orderid).contains(RFO_Constant.Case_Status_Cancelled)){
                        order o = new order();
                        o.id = orderid;
                        o.Status = RFO_Constant.Order_Status_Process;//'Order in Process';
                        orderToUpdate.add(o);
                    }
                    
                }
                
            }
        }
        //Alpha - 520 Start - Ramesh
        if(orderToUpdate.size() > 0){
            system.debug('~~ Order Update Status Entered ~ 141');
            update orderToUpdate;
        }
        //Alpha - 520 End - Ramesh
    }
    
    //Returns a map of Order and child Case records
    public static map<string,set<string>> getMapCaseChildRecords(list<case> CasesL){
        map<string,set<string>> mapOrderCRStatus = new map<string,set<string>>();
        for(Case c : CasesL){
            if(mapOrderCRStatus.containsKey(c.RFO_OrderID__c)){
                set<string> CRSet = mapOrderCRStatus.get(c.RFO_OrderID__c);
                CRSet.add(c.Status);
                mapOrderCRStatus.put(c.RFO_OrderID__c,CRSet);
            }
            else{
                set<string> newCRSet = new set<string>();
                newCRSet.add(c.Status);
                mapOrderCRStatus.put(c.RFO_OrderID__c,newCRSet);
            }
        }
        return mapOrderCRStatus;
    }
    
    //Alpha - 520 Start - Ramesh
    Public static void changeOrderStatus(list<case> newCaseList){
        List<Id> orderIds = new List<Id>();
        List<Order> orders = new List<Order>();
        for(case c : newCaseList){
            if(c.RFO_OrderID__c != null ) orderIds.add(c.RFO_OrderID__c);
        }
        
        for(Order obj : [SELECT id, status,Name from Order where ID in : orderIds and status = 'Order In Process']){
            obj.status  = 'Change Request In Progress';
            orders.add(obj);
        }
        
        if(orders.size() > 0){
            UPDATE orders;
        }
    }
    //Alpha - 520 End - Ramesh
}