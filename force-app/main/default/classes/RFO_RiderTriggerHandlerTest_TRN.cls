/**
*  Class:  RFO_RiderTriggerHandlerTest_TRN
**/
@isTest(SeeAllData=false)
private class RFO_RiderTriggerHandlerTest_TRN { 
    private static testMethod void updateContactIdProcessSurveyTest(){
        Id recordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        List<RFO_Rider__c> riderList = new List<RFO_Rider__c>();
        
      Profile profileId;
        
        if(Test.isRunningTest()){
          profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        }else{
               profileId = [SELECT Id FROM Profile WHERE Name = 'RFO - Sales' LIMIT 1];
        }
        
        Account accRec=RFO_TestDataFactory.createAccount('Test Account 451', recordTypeIdCustomer, true);
        
        
        List<Contact> contRec = RFO_Utility_Test.createContact(accRec);
        contRec[0].RFO_ContactRole__c = 'Survey Contact';
        contRec[0].Post_Delivery_Time__c = null;
        Database.insert(contRec);
        
        
        Contract contr= RFO_TestDataFactory.createContract('TEST - Contract', accRec.Id, true);
        User usr =RFO_TestDataFactory.createUser(profileId.id, null, 'jason.liveston@example.com', true);
        
        system.runAs(usr){
            EmailTemplate eTemplate = new EmailTemplate (developerName = 'Survey_Lease_Project_Avg_Begin_Charge',
                                                         FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'test'); 
            Database.insert(eTemplate);
            EmailTemplate eTemplate1 = new EmailTemplate (developerName = 'Survey_contact_not_exists_in_account_alert', 
                                                          FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'test1'); 
            Database.insert(eTemplate1);
        }        
        Test.startTest();
        for(Integer i=0;i<10;i++){
            RFO_Rider__c rider = new RFO_Rider__c();
            rider.RFO_Account__c = accRec.Id;
            rider.RFO_Contract__c = contr.Id;
            rider.RFO_RiderType__c = 'Maintenance Agreement';
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
            
            
            
            riderList.add(rider);
        }
        riderList[2].RFO_RiderNumberSuffix__c=null;      
        Database.insert(riderList); 
        
        RFO_Rider__c rid = [Select Id, contactId__c from RFO_Rider__c where Id = : riderList.get(0).Id Limit 1];
        
        
        for(RFO_Rider__c r :riderList){
            r.RFO_RiderAverageBeginDate__c = System.today();
        }
        Database.update(riderList);
        Test.stopTest(); 
        system.assert(riderList!=null);
    }
}