trigger BulletinBoardTrigger on Bulletin_Board__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        BulletinBoardTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }    
}