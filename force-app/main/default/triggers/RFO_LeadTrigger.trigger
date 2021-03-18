trigger RFO_LeadTrigger on Lead (after insert) {

    if(trigger.isInsert && trigger.isAfter) {
        set<Id> leadList = new set<Id>();
        for(Lead leadSO : trigger.new) {
            if(leadSO.LeadSource != null && leadSO.LeadSource == 'Sales Team') {
                leadList.add(leadSO.Id);
            }
        }
        if(!leadList.isEmpty()) {
            RFO_LeadTriggerHandler.customNotification(leadList);
            RFO_LeadTriggerHandler.postToChatter(leadList);
        }
    }

}