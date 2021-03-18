public class AccountContactRelationHandler {
    public static Boolean isupdateRoleOnConRecr = false;
    public static void updateContact(Map<Id,AccountContactRelation> acrMap){
        if(!isupdateRoleOnConRecr){
            isupdateRoleOnConRecr = true;
            Set<Id> conIds = new Set<Id>();
            Map<Id,Contact> activeConMap = new Map<Id,Contact>();
            List<Contact> contactstoUpdate = new List<Contact>();
            
            if(acrMap!=null&&acrMap.size()>0){    
                for(AccountContactRelation acr : acrMap.values()){
                    if(acr.isDirect)
                    {
                       conIds.add(acr.ContactId);
                    }
                }
                if(conIds.size()>0){
                    for(Contact con : [Select id,RFO_Status__c,RFO_ContactRole__c from Contact where id IN :conIds]){
                        if(con.RFO_Status__c == 'Active'){
                            activeConMap.put(con.id,con);
                        }
                    }
                }
                if(activeConMap!=null&&activeConMap.size()>0){
                     for(AccountContactRelation acr : acrMap.values()){
                         if(acr.isDirect){
                            Contact con = activeConMap.get(acr.ContactId);
                            con.RFO_ContactRole__c = acr.Roles;
                            contactstoUpdate.add(con);
                         }
                    }   
                }
                
                if(contactstoUpdate.size()>0){
                    ContactHandler.isupdateRoleOnAccRec = true;
                    update contactstoUpdate;
                    

                }
            }
        }
   }
}