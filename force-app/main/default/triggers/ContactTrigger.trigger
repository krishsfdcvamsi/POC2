trigger ContactTrigger on Contact (before insert, before update, before
    delete, after insert, after update, after delete,  after undelete) {
        if(Trigger.isBefore && Trigger.isInsert){
            set<string> accountIds = new set<string>();
            for(contact c: trigger.new){
                accountIds.add(c.AccountId);
            }
            map<id,Account> mapAccount = new map<id,Account>([select id,recordType.name from account where
                                                             id in: accountIds]);
            for(contact c : trigger.new){
                c.Account_Record_Type__c = mapAccount.get(c.AccountId).recordType.name;
            }
          ContactHandler.isInsertCon = true;   
        }
        
        if (Trigger.isAfter && Trigger.isInsert) {
            for (Contact c: Trigger.New){
                if(!Test.isRunningTest() && !system.isFuture() && !System.isBatch()){
                	ContactSyncUtils.syncContact(c.Id, 'Create'); 
                }
            }
            ContactHandler.updateRoleOnAccConReln(Trigger.newMap);
        }
        
        if(Trigger.isBefore && Trigger.isUpdate){
            set<string> AccIds = new set<string>();
            for(contact c: trigger.new){
                AccIds.add(c.AccountId);
            }
            map<id,Account> mapAcc = new map<id,Account>([select id,recordType.name from account where
                                                             id in: AccIds]);
            for (Contact c: Trigger.New){
                //update Account Record Type in Contact
                 c.Account_Record_Type__c = mapAcc.get(c.AccountId).recordType.name;
                Contact oldCon = Trigger.oldMap.get(c.ID);
                //if customer interest field has been updated
                if(c.Customer_Interests__c != oldCon.Customer_Interests__c){
                    if(c.RFO_ContactRole__c != NULL && !c.RFO_ContactRole__c.contains('Railcar Servicing') )
                        c.RFO_ContactRole__c += ';Railcar Servicing';//append this value to the already selected picklist values
                    if(c.RFO_ContactRole__c == NULL )
                        c.RFO_ContactRole__c = 'Railcar Servicing';//add this value to the picklist
                }
            }
        }
        
        if (Trigger.isAfter && Trigger.isUpdate) {
            // ContactHandler.CheckContactUser(Trigger.New);
            Set<Id> cIdSet = new Set<Id>();
            for (Contact c: Trigger.New){       
                if(!Test.isRunningTest() && !system.isFuture() && !System.isBatch()){
                	ContactSyncUtils.syncContact(c.Id, 'Update');
            	}
                if(c.RFO_Status__c=='Inactive'){
                	cIdSet.add(c.Id);
                }
            }
            if(!cIdSet.isEmpty()){
            	List<pqcrush__Key_Stakeholder__c> kshList = [Select Id, pqcrush__Contact__c from pqcrush__Key_Stakeholder__c where pqcrush__Contact__c IN:cIdSet limit 4999];
                if(kshList.size()>0){
                    delete kshList;
                }
            }
          ContactHandler.updateRoleOnAccConReln(Trigger.newMap);  
        }
    
}