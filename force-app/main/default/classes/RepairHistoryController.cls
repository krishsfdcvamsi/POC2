/************************************************************************************************************************************************** 
 * Class Name : Repair Histor Controller
 * Description : As a customer user I want to be able to see a list of “Repair History” report on the customer digital portal.
 * 				So that I can use that data to perform some analysis on my repair expenditures. 
 * Author : Sai Anudeep
 * Created On : 11/24/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/24/20                    Sai Anudeep                       BETA - 96 Added custom filters to pull the report.
      
 **************************************************************************************************************************************************/

public  class RepairHistoryController {
    
   
    
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(){
        return [SELECT Id,Name FROM Account];
    }
    
    /*@AuraEnabled(cacheable=true)
    public static List<RFO_Rider__c> getRiderNumbersByAccount(Id accountId){
        return [SELECT RFO_RiderNumber__c FROM RFO_Rider__c Where RFO_Account__c=: accountId AND RFO_RiderNumber__c != null]; */
	
    @AuraEnabled(cacheable=true)
    public static List<String> getRiderNumbers(Id accountId, String searchText){
        List<String> riderNumbers = new List<String>();
        //List<RFO_Rider__c> riders = new List<RFO_Rider__c>();
        
        String query = 'SELECT Id,Name,Rider_Number_new__c FROM RFO_Rider__c WHERE RFO_RiderNumber__c!= null '+
            			'AND RFO_RiderNumberSuffix__c != null AND RFO_Status__c !=\'Rider Cancelled\'';
        
        List<Account> accounts = new List<Account>();
        System.debug(accountId+' '+searchText);
        if(accountId != null){
            query += ' AND RFO_Account__c =: accountId';
            if(searchText != null){
                query += ' AND Rider_Number_new__c LIKE \'%'+searchText+'%\'';
            }
            query += ' LIMIT 5';
        }
        else{
            accounts = [SELECT Id,Name FROM Account];
            query += ' AND RFO_Account__c IN: accounts';
            if(searchText != null){
                query += ' AND Rider_Number_new__c LIKE \'%'+searchText+'%\'';
            }
            query += ' LIMIT 5';
           /* riders = [SELECT Id,Name,Rider_Number_new__c FROM RFO_Rider__c WHERE
                      RFO_Account__c IN: accounts AND RFO_RiderNumber__c!= null 
                      AND RFO_RiderNumberSuffix__c != null AND 
                      Rider_Number_new__c LIKE : '%'+searchText+'%' LIMIT 5];*/
            
        }
       System.debug(query);
        List<sObject> riders = Database.query(query);
        System.debug(riders);
        for(sObject rider : riders){
            if(!riderNumbers.contains(String.valueOf(rider.get('Rider_Number_new__c'))))
            riderNumbers.add(String.valueOf(rider.get('Rider_Number_new__c')));
        }
        return riderNumbers;
    }
    
    }