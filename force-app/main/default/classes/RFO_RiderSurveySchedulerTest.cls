@isTest
private class RFO_RiderSurveySchedulerTest {
    
    
	static testmethod void testRiderSurveyScheduler(){
        
        Id recordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        List<RFO_Rider__c> riderList = new List<RFO_Rider__c>();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = : RFO_Constant.SALES_PROFILE LIMIT 1];
        Account accRec=RFO_TestDataFactory.createAccount('Test Account 451', recordTypeIdCustomer, true);
        List<Contact> contRec = RFO_Utility_Test.createContact(accRec);
        for(Contact c: contRec){
            c.RFO_ContactRole__c = c.RFO_ContactRole__c + ';'+'Survey Contact';
        }
        Database.insert(contRec);
        Contract contr= RFO_TestDataFactory.createContract('TEST - Contract', accRec.Id, true);
        User usr =RFO_TestDataFactory.createUser(profileId.id, null, 'jason.liveston@example.com', true);
       
        
        
        for(Integer i=0;i<3;i++){
            RFO_Rider__c rider = new RFO_Rider__c();
            rider.RFO_Account__c = accRec.Id;
            rider.RFO_Contract__c = contr.Id;
            rider.RFO_RiderType__c = 'Net Lease';
            rider.RFO_CarModels__c ='TESLA';
            rider.RFO_TotalOfCars__c = 10;
            rider.Rider_Name_Ends_Zero__c ='YES';
            rider.RFO_RiderNumberSuffix__c = '0';
            
            //rider.RFO_NumberofPayments__c = 5;
            rider.RFO_RiderDate__c = System.today() + 5;
            rider.RFO_RiderRateType__c ='Term';
            rider.RFO_Term__c = 10;
            rider.RFO_AutoRenewalTermTermMonths__c = 5;
            rider.RFO_RenewalDaysNotice__c = 10;
            //rider.RFO_TransactionType__c = 'Maintenance Service';
            //rider.RFO_PaymentFrequency__c ='Monthly';
            rider.RFO_StartMethod__c = 'Fixed Date';
            rider.RFO_IncreaseEffectiveUpon__c = 'Completion of Modification';
            rider.RFO_UnitofMeasure__c ='per car, per mile';
      		rider.RFO_AvgBeginCharge__c = System.today()-10;
            
            
            riderList.add(rider);
        }
        riderList[2].RFO_RiderNumberSuffix__c=null;      
         Database.insert(riderList); 
       
        RFO_Rider__c rid = [Select Id, contactId__c from RFO_Rider__c where Id = : riderList.get(0).Id Limit 1];
      
        
        for(RFO_Rider__c r :riderList){
            r.RFO_AvgBeginCharge__c = System.today();
        }
         Database.update(riderList);
        
        Test.startTest();
        
        List<Contact> conList = [Select Id, RFO_ContactRole__c from Contact];
        for(Contact con : conList){
            con.RFO_ContactRole__c = 'Survey Contact';
        }
        update conList;
        
        RFO_RiderSurveyScheduler sh1 = new RFO_RiderSurveyScheduler();
        String sch = '0 0 5 * * ?'; 
        system.schedule('Send new car order survey', sch, sh1); 
        Test.stopTest();
    }
}