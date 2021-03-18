trigger IdeaTrigger on Idea__c (after insert, after update) {

    if(trigger.isAfter){
        if(Trigger.isInsert){
            IdeaTriggerHandler.shareIdeaRecord(Trigger.New);
        }
        if(Trigger.isUpdate){
            List<Idea__c> userUpdatedIdeaList = new List<Idea__c>();
            for(Idea__c i :Trigger.new){
                if((i.Project_Leader__c != Trigger.oldMap.get(i.id).Project_Leader__c)||
                   (i.Commercial_Member__c != Trigger.oldMap.get(i.id).Commercial_Member__c)||
                   (i.Technology_Member__c != Trigger.oldMap.get(i.id).Technology_Member__c)||
                   (i.Marketing_Member__c != Trigger.oldMap.get(i.id).Marketing_Member__c)||
                   (i.Engineering_Member__c != Trigger.oldMap.get(i.id).Engineering_Member__c)||
                   (i.Legal_Member__c != Trigger.oldMap.get(i.id).Legal_Member__c)||
                   (i.Product_Member__c != Trigger.oldMap.get(i.id).Product_Member__c)||
                   (i.Project_Engineer__c != Trigger.oldMap.get(i.id).Project_Engineer__c)
                  ){
                      userUpdatedIdeaList.add(i);
                   }
                }
            if(!userUpdatedIdeaList.isEmpty()){
                IdeaTriggerHandler.updateIdeaShare(userUpdatedIdeaList,Trigger.oldMap);
            	IdeaTriggerHandler.shareIdeaRecord(userUpdatedIdeaList);
            }
            
        }
       
        
    }
    
}