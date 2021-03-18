trigger CDX_UserTrigger on User (before insert, before update, before
    delete, after insert, after update, after delete,  after undelete) {
        
        if (Trigger.isAfter && Trigger.isInsert) {
            CDX_UserHandler.CheckUserAccount(Trigger.New);
            CDX_UserHandler.publishNewUserRecord(Trigger.New);
        } 
        else if (Trigger.isAfter && Trigger.isUpdate) {
            CDX_UserHandler.publishUpdatedUserRecord(Trigger.New);
            CDX_UserHandler.updateAccounts(Trigger.New,Trigger.oldMap);
        }        

}