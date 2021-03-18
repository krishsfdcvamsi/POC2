public class BulletinBoardTriggerHandler {
    
    public static void handleAfterUpdate(Map<Id,Bulletin_Board__c> oldBulletinRecs, Map<Id,Bulletin_Board__c> newBulletinRecs){
        List<Id> approvedIds = new List<Id>();
        for(Bulletin_Board__c bb: newBulletinRecs.values()){
            if((oldBulletinRecs.get(bb.Id).Status__c != bb.Status__c) && 
             (bb.Status__c == 'Approved' || bb.Status__c == 'Rejected')){
                  approvedIds.add(bb.Id);
            }
        }
        Map<Id, Bulletin_Board__c> approvedMap = new Map<Id,Bulletin_Board__c>([SELECT Id FROM Bulletin_Board__c WHERE ID IN: approvedIds]);
        for(Bulletin_Board__c bb : approvedMap.values()){
            bb.Approved_Rejected_Date__c = System.today();
        }
        List<ProcessInstance> piLst = [SELECT Id,LastActorId,TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN :approvedIds];
        for(ProcessInstance pi: piLst){
            approvedMap.get(pi.TargetObjectId).Approved_Rejected_By__c = pi.LastActorId;
        }
        update approvedMap.values();
    } 
}