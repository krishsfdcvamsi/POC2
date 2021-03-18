trigger RFO_AssetFileTrigger on RFO_Asset_File__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.Run(new RFO_AssetFileTriggerHandler());
}