/*************************************************************
@Name: UpdateAssetsDeliveredBatch
@Author: MA
@CreateDate: Nov 29, 2020
@JIRA : BETA-194
@Description: updates Asset delivered to the existing order
**************************************************************/
global class UpdateAssetsDeliveredBatch implements Database.Batchable<sObject> {
    
    static final string EXISTING_ORDER = 'RFO_ExistingCar';
    static final string NEW_ORDER = 'RFO_NewCar';
    static final string ASSIGNED = 'Assigned';
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
            string query = 'SELECT Id,of_Assets_Delivered__c,recordType.developerName,'
                                +'(SELECT Id,Status,RFO_BeginChargeDate__c FROM Assets1__r '
                                +'WHERE RFO_BeginChargeDate__c >= TODAY) '
                                +'FROM Order '
                                +'WHERE recordType.developerName =: EXISTING_ORDER';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc,  List<Order> orderList){ 
        list<Order> ordersList = new list<Order>();
        for(Order orderSO : orderList) {
            Integer count = 0;
            if(orderSO.Assets1__r != null) {
                for(Asset assetSO : orderSO.Assets1__r) {
                    if(assetSO.RFO_BeginChargeDate__c >= System.today()) {
                        count++;
                    }
                }
                orderSO.of_Assets_Delivered__c = count;
                ordersList.add(orderSO);
            }
        }
        if(!ordersList.isEmpty()) {
            Database.update(ordersList, false);
        }
    }
    
    global void finish(Database.BatchableContext bc){

    }     
}