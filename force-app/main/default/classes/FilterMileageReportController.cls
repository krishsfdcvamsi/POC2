/************************************************************************************************************************************************** 
 * Class Name : Filter Mileage Data Report
 * Description : As a customer user I want to be able to view “Fleet Mileage Details” for all of my assets.
 * 				 so that I can use the report for analysis and review of mileages that were used during the course of a specific duration. 
 * Author : Sai Anudeep
 * Created On : 11/21/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/21/20                    Sai Anudeep                       BETA - 95 Added custom filters to pull the report.
      
 **************************************************************************************************************************************************/


public with sharing class FilterMileageReportController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(){
       return [SELECT Id,Name FROM Account];
      /*  return [SELECT Id,Name,Car_Mark__c,Car_Number__c, Earned_Date__c, Allowed_Date__c,Number__c, 
                Account__r.Name,Rider_Number__c,RailRoad__c FROM Fleet_Mileage_Data__c WHERE Account__c IN: accounts LIMIT 1000];*/
    }
    
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