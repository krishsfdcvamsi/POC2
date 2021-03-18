public class IdeaTriggerHandler {
    
    public static void shareIdeaRecord(List<Idea__c> newList){
        Set<Id> userId = new Set<Id>();
        List<Group> grpList = [Select Id,Name from Group where Name = 'Idea_Product_Record_Share ' OR Name ='Idea_Service_Record_Share'];
            for(GroupMember grp: [Select Id,UserOrGroupId ,GroupId from GroupMember where GroupId IN :grpList]){
                userId.add(grp.UserorGroupId);
            }
        
        List<Idea__Share> ideaShares = new List<Idea__Share>();
        List<Idea__Share> ideaRecord = [SELECT Id, userorgroupid FROM Idea__Share];
        if(!newList.isEmpty()){
            for(Idea__c i : newList){
            
                if(i.Project_Leader__c !=null && i.OwnerId != i.Project_Leader__c){ 
                    if(!userId.contains(i.Project_Leader__c)){
                        Idea__Share ideaRecord1 = new Idea__Share();
                        ideaRecord1.ParentId = i.id;
                        ideaRecord1.UserOrGroupId = i.Project_Leader__c;
                        ideaRecord1.AccessLevel ='edit';
                        ideaRecord1.RowCause ='Manual';
                        ideaShares.add(ideaRecord1);
                    }
                }
                
                if(i.Commercial_Member__c!= null && i.OwnerId != i.Commercial_Member__c){
                    if(!userId.contains(i.Commercial_Member__c)){
                        Idea__Share ideaRecord2 = new Idea__Share();
                        ideaRecord2.ParentId = i.id;
                        ideaRecord2.UserOrGroupId = i.Commercial_Member__c;
                        ideaRecord2.AccessLevel ='edit';
                        ideaRecord2.RowCause ='Manual';
                        ideaShares.add(ideaRecord2);
                    }
                }
                
                if(i.Technology_Member__c!= null && i.OwnerId != i.Technology_Member__c){
                    if(!userId.contains(i.Technology_Member__c)){
                        Idea__Share ideaRecord3 = new Idea__Share();
                        ideaRecord3.ParentId = i.id;
                        ideaRecord3.UserOrGroupId = i.Technology_Member__c;
                        ideaRecord3.AccessLevel ='edit';
                        ideaRecord3.RowCause ='Manual';
                        ideaShares.add(ideaRecord3);
                    }
                }
                
                if(i.Marketing_Member__c!=null && i.OwnerId != i.Marketing_Member__c){
                    if(!userId.contains(i.Marketing_Member__c)){
                        Idea__Share ideaRecord4 = new Idea__Share();
                        ideaRecord4.ParentId = i.id;
                        ideaRecord4.UserOrGroupId = i.Marketing_Member__c;
                        ideaRecord4.AccessLevel ='edit';
                        ideaRecord4.RowCause ='Manual';
                        ideaShares.add(ideaRecord4);
                    }
                }
                
                if(i.Engineering_Member__c!=null && i.OwnerId != i.Engineering_Member__c){
                    if(!userId.contains(i.Engineering_Member__c)){
                        Idea__Share ideaRecord5 = new Idea__Share();
                        ideaRecord5.ParentId = i.id;
                        ideaRecord5.UserOrGroupId = i.Engineering_Member__c;
                        ideaRecord5.AccessLevel ='edit';
                        ideaRecord5.RowCause ='Manual';
                        ideaShares.add(ideaRecord5);
					}
                }
                
                if(i.Legal_Member__c!=null && i.OwnerId != i.Legal_Member__c){
                    if(!userId.contains(i.Legal_Member__c)){
                        Idea__Share ideaRecord6 = new Idea__Share();
                        ideaRecord6.ParentId = i.id;
                        ideaRecord6.UserOrGroupId = i.Legal_Member__c;
                        ideaRecord6.AccessLevel ='edit';
                        ideaRecord6.RowCause ='Manual';
                        ideaShares.add(ideaRecord6);
                    }
                }
                
                if(i.Product_Member__c!=null && i.OwnerId != i.Product_Member__c){
                    if(!userId.contains(i.Product_Member__c)){
                        Idea__Share ideaRecord7 = new Idea__Share();
                        ideaRecord7.ParentId = i.id;
                        ideaRecord7.UserOrGroupId = i.Product_Member__c;
                        ideaRecord7.AccessLevel ='edit';
                        ideaRecord7.RowCause ='Manual';
                        ideaShares.add(ideaRecord7);
                    }
                }
                    
                if(i.Project_Engineer__c!=null && i.OwnerId != i.Project_Engineer__c){
                    if(!userId.contains(i.Project_Engineer__c)){
                        Idea__Share ideaRecord8 = new Idea__Share();
                        ideaRecord8.ParentId = i.id;
                        ideaRecord8.UserOrGroupId = i.Project_Engineer__c;
                        ideaRecord8.AccessLevel ='edit';
                        ideaRecord8.RowCause ='Manual';
                        ideaShares.add(ideaRecord8);
                    }
                }    
            } 
        }
        if(!ideaShares.isEmpty()){
            insert ideaShares;
        }    
    }
    
    public static void updateIdeaShare(List<Idea__c> newList,Map<Id,Idea__c> oldMap){
        List<Idea__Share> delIdeaShareList = new List<Idea__Share>();
        if(!newList.isEmpty()){
            delIdeaShareList = [Select Id,Parentid from Idea__Share where parentid IN :newList and RowCause = 'Manual'];
        }
        System.debug(delIdeaShareList);
        if(!delIdeaShareList.isEmpty()){
            delete delIdeaShareList;
        }
    }
    
}