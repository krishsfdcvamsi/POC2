public class ContactHandler {

    
    public static Boolean isupdateRoleOnAccRec = false;
    public static Boolean isInsertCon = false;
    
    public static void updateRoleOnAccConReln(Map<Id,Contact> conMap){
        if(!isupdateRoleOnAccRec){
        isupdateRoleOnAccRec = true;    
        List<AccountContactRelation> acrtoUpdate = new List<AccountContactRelation>();
        
            //contact to acr map
            if(conMap!=null && conMap.size()>0){
                for(AccountContactRelation acr : [Select id,Roles,isDirect,ContactId from AccountContactRelation where isDirect= true and ContactId IN :conMap.keySet()]){
                    if(conMap.get(acr.ContactId).RFO_Status__c == 'Active'){
                        acr.Roles = conMap.get(acr.ContactId).RFO_ContactRole__c;
                        acrtoUpdate.add(acr);
                    }
                }
                
                if(acrtoUpdate.size()>0){
                    AccountContactRelationHandler.isupdateRoleOnConRecr = true;
                    update acrtoUpdate;
                    
                }
            }
        }
    }
}