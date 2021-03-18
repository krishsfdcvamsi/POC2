public class OrderTriggerHandler {
    
	public static void updateContactId(List<Order> orderList){
    /*    
    	System.debug('INSIDE updateContactId');
        List<Id> accountIds = new List<Id>();
        
		        
        for(Order order: orderList){
        	if(order.AccountId!=null ){
                accountIds.add(order.AccountId);
        	}
    	}
        if(accountIds.size()>0){
            List<Account> accounts = [Select Id, (Select Id,FirstName, LastName, RFO_ContactRole__c From Contacts) from Account where Id IN : accountIds];
            for(Order order: orderList){
				for(Account objAcc : accounts){
                    if(objAcc.Id == order.AccountId){
                        system.debug('Contact List ::'+objAcc.Contacts.size());
            			for(Contact objCon: objAcc.Contacts){
                    		system.debug('objCon.RFO_ContactRole__c =='+objCon.RFO_ContactRole__c);
                			if(objCon.RFO_ContactRole__c!=null && objCon.RFO_ContactRole__c.contains('Survey Contact')){
                    			system.debug('Inside contact exists');
                        		order.Survey_Contact__c = objCon.Id;
                        		order.Survey_Contact_Id__c = objCon.Id; 
                    			System.debug('Inside contact exists '+order.Survey_Contact__c);
                      		}
                		}
                    }	   
        		}            	
            }
        }
*/
    } 
}