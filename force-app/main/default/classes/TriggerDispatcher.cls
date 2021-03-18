public class TriggerDispatcher 
{
    /*
        Call this method from your trigger, passing in an instance of a trigger handler which implements ITriggerHandler.
        This method will fire the appropriate methods on the handler depending on the trigger context.
    */
	public static Boolean isRecurrsiveBeforeInsert = false;
    public static Boolean isRecurrsiveAfterInsert = false;
    public static Boolean isRecurrsiveBeforeUpdate = false;
    public static Boolean isRecurrsiveAfterUpdate = false;
    public static Boolean isRecurrsiveBeforeDelete = false;
    public static Boolean isRecurrsiveAfterUnDelete = false;
    public static Boolean isRecurrsiveAfterDelete = false;
    public static void Run(ITriggerHandler handler)
    {
        // Check to see if the trigger has been disabled. If it has, return
        if (handler.IsDisabled())
            return;
             
        // Detect the current trigger context and fire the relevant methods on the trigger handler:
 
        // Before trigger logic
        if (Trigger.IsBefore)
        {
            if (Trigger.IsInsert && isRecurrsiveBeforeInsert==false){
                handler.BeforeInsert(trigger.new);
                isRecurrsiveBeforeInsert = true;
            }
            if (Trigger.IsUpdate && isRecurrsiveBeforeUpdate==false){
                handler.BeforeUpdate(trigger.newMap, trigger.oldMap);
                isRecurrsiveBeforeUpdate = true;
            }
            if (Trigger.IsDelete && isRecurrsiveBeforeDelete==false){
                handler.BeforeDelete(trigger.oldMap);
                isRecurrsiveBeforeDelete = true;
        	}
        }
         
        // After trigger logic
        if (Trigger.IsAfter)
        {
            if (Trigger.IsInsert && isRecurrsiveAfterInsert==false){
                handler.AfterInsert(Trigger.newMap);
                isRecurrsiveAfterInsert = true;
            }
            if (Trigger.IsUpdate && isRecurrsiveAfterUpdate==false){
                handler.AfterUpdate(trigger.newMap, trigger.oldMap);
                isRecurrsiveAfterUpdate = true;
            }
            if (trigger.IsDelete && isRecurrsiveAfterDelete==false){
                handler.AfterDelete(trigger.oldMap);
                isRecurrsiveAfterDelete = true;
            }
            if (trigger.isUndelete && isRecurrsiveAfterUnDelete==false){
                handler.AfterUndelete(trigger.oldMap);
                isRecurrsiveAfterUnDelete = true;
            }
        }
    }
}