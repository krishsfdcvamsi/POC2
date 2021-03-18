public class RF1_AccountsNoSurveyContactCtrl {
    
	@AuraEnabled
    public static AccountPagerWrapper fetchAccount(Decimal pageNumber ,Integer recordToDisplay, String surveyType) {
        Integer pageSize = recordToDisplay;
      	Integer offset = ((Integer)pageNumber - 1) * pageSize;
    	// create a instance of wrapper class.
    	AccountPagerWrapper obj =  new AccountPagerWrapper();
    	// set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
        obj.pageSize = pageSize;
        obj.page = (Integer) pageNumber;
        //String surveyType = 'Survey Contact';
        
        List<Id> accountIds = new List<Id>();
        List<Account> acctNoSurveyContactList = new List<Account>();
        Set<String> AccountTeamRoles = new Set<String>{label.Customer_Delivery_Manager, label.Customer_Delivery_Director, label.Sales_Manager};
            
        List<AggregateResult> ContactsWithoutType = [Select ACCOUNTID from contact where RFO_ContactRole__c EXCLUDES (:surveyType) group by AccountId LIMIT 50000];
        List<Id> accountIdsWithoutContact = new List<Id>();
        for(AggregateResult obj1 : ContactsWithoutType){
            accountIdsWithoutContact.add((Id)obj1.get('ACCOUNTID'));
        }
        obj.total = [Select count() from Account where RFO_AccountStatus__c='Active' and Type='Customer' AND Id IN:accountIdsWithoutContact];
        //obj.total = ContactsWithoutType.size();
        
        
        List<Account> acctList = [Select Id, Name, RFO_AccountOwner__c, type, (Select Id, RFO_ContactRole__c From Contacts) from Account where RFO_AccountStatus__c='Active' and Type='Customer'  order by Name LIMIT :recordToDisplay OFFSET :offset];
        
        for(Account acc :acctList ){
            accountIds.add(acc.Id);
        }
        
		List<AccountTeamMember> accountTeams = [Select AccountId,TeamMemberRole,UserId,user.email, user.Name FROM AccountTeamMember WHERE AccountId IN:accountIds AND TeamMemberRole IN:AccountTeamRoles];
        for(Account a : acctList){
            Integer surveyCnt = 0;
            for(Contact objCon: a.Contacts){
                system.debug('Outside If Contact Role :: '+objCon.RFO_ContactRole__c);
                if(objCon.RFO_ContactRole__c!=null && objCon.RFO_ContactRole__c.contains(surveyType)){
                    system.debug('Contact Role :: '+objCon.RFO_ContactRole__c);
                    surveyCnt++;
                }
            }
            
            if(surveyCnt==0){
                for(AccountTeamMember atm: accountTeams){
                    if(a.Id == atm.AccountId && atm.TeamMemberRole=='Customer Delivery Manager'){
                        A.RFO_DBA__c = atm.user.Name;
                    }
                    if(a.Id == atm.AccountId && atm.TeamMemberRole=='Customer Delivery Director'){
                       A.RFO_TASLastModifiedBy__c = atm.user.Name;
                    }
                    if(a.Id == atm.AccountId && atm.TeamMemberRole=='Sales Manager'){
                       A.RFO_PrimaryMarketSegment__c = atm.user.Name;
                    }
                    
                }
                acctNoSurveyContactList.add(a);
            }
                
        }
        obj.accounts = acctNoSurveyContactList;
        
        return obj;
    }
    
     // create a wrapper class with @AuraEnabled Properties    
 	public class AccountPagerWrapper {
    	@AuraEnabled public Integer pageSize {get;set;}
    	@AuraEnabled public Integer page {get;set;}
    	@AuraEnabled public Integer total {get;set;}
    	@AuraEnabled public List<Account> accounts {get;set;}
   }
}