trigger AccountContactRelnTrigger on AccountContactRelation (after insert, after update) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        if(!ContactHandler.isInsertCon)
         AccountContactRelationHandler.updateContact(Trigger.newMap);
    }
}