/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 10th Oct 2018
* @Description :This is test class for RFO_DataSetup_Factory.
**/

@isTest(SeeAllData = false)
public class RFO_TestDataSetup_Factory{
	public static Profile profileId = [SELECT Id FROM Profile WHERE Name =: RFO_Constant.SALES_PROFILE LIMIT 1];
	/**********************************************Account Data*********************************************/
   public static account customerAccount(){
       Id recordTypeIdCustomer = 
           Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
	   account acc1 =new account();
	   acc1.Name = 'BNSF';  // Account Name
       acc1.RecordTypeId = recordTypeIdCustomer;           // Account Record Type
       acc1.Phone = '800-832-5452';          // Phone
       acc1.RFO_Region__c = 'Class 1 Railroads';   // Region
       acc1.RFO_AccountStatus__c = 'Active';
	   try{
            database.insert(acc1,false);
            
        }catch(exception e){
        System.Assert(acc1.id==null);
       }
	   System.assertEquals('BNSF', acc1.name);
    return acc1;
   }
    /*
     * Creation of Competitor Account
     **/
   public static account competitorAccount(){
       Id recordTypeIdCompetitor = 
           Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Competitor').getRecordTypeId();
	   account compAc =new account();
	   compAc.Name = 'ALL Capital Rail';  // Account Name
       compAc.RecordTypeId = recordTypeIdCompetitor;           // Account Record Type
       compAc.Phone = '800-832-5452';          // Phone
       compAc.RFO_Region__c = 'Class 1 Railroads';   // Region
       compAc.RFO_AccountStatus__c = 'Active';
	   try{
            database.insert(compAc,false);
            
        }catch(exception e){
        System.Assert(compAc.id==null);
       }
	   System.assertEquals('BNSF', compAc.name);
    return compAc;
   }
    /*
     * Creation of investor Service Account
     **/
   public static account investorServiceAccount(){
       Id recordTypeIdIS = 
           Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Investor_Services').getRecordTypeId();
	   account invesAc =new account();
	   invesAc.Name = '37 Building Products';  // Account Name
       invesAc.RecordTypeId = recordTypeIdIS;           // Account Record Type
       invesAc.Phone = '800-832-5452';          // Phone
       invesAc.RFO_Region__c = 'Class 1 Railroads';   // Region
       invesAc.RFO_AccountStatus__c = 'Active';
	   try{
            database.insert(invesAc,false);
            
        }catch(exception e){
        System.Assert(invesAc.id==null);
       }
	   System.assertEquals('BNSF', invesAc.name);
    return invesAc;
   }
    /*
     * Creation of Prospect Account
     **/
   public static account prospectAccount(){
       Id recordTypeIdProspect = 
           Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Prospect').getRecordTypeId();
	   account prospAc =new account();
	   prospAc.Name = 'BNSFT';  // Account Name
       prospAc.RecordTypeId = recordTypeIdProspect;           // Account Record Type
       prospAc.Phone = '800-832-5252';          // Phone
       prospAc.RFO_Region__c = 'Class 1 Railroads';   // Region
       prospAc.RFO_AccountStatus__c = 'Active';        // Account Status
	   try{
            database.insert(prospAc,false);
            
        }catch(exception e){
        System.Assert(prospAc.id==null);
       }
	   System.assertEquals('BNSFT', prospAc.name);
    return prospAc;
   }
    /*
     * Creation of Third Party Prospect Account
     **/
   public static account thirdPartyProspectAccount(){
       Id recordTypeId3PP = 
           Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_ThirdPartyProspect').getRecordTypeId();
	   account tpProsAc =new account();
	   tpProsAc.Name = 'Leasing Co';  // Account Name
       tpProsAc.RecordTypeId = recordTypeId3PP;           // Account Record Type
       tpProsAc.Phone = '800-832-5452';          // Phone
       tpProsAc.RFO_Region__c = 'Class 1 Railroads';   // Region
       tpProsAc.RFO_AccountStatus__c = 'Active';
	   try{
            database.insert(tpProsAc,false);
            
        }catch(exception e){
        System.Assert(tpProsAc.id==null);
       }
	   System.assertEquals('BNSF', tpProsAc.name);
    return tpProsAc;
   }
    /*
     * Creation of Third Party Sales Account
     **/
   public static account thirdPartySalesAccount(){
       Id recordTypeId3PS = 
           Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_ThirdPartySales').getRecordTypeId();
	   account tpSalesAc =new account();
	   tpSalesAc.Name = 'Railforce Leasing Co';  // Account Name
       tpSalesAc.RecordTypeId = recordTypeId3PS;           // Account Record Type
       tpSalesAc.Phone = '800-832-5452';          // Phone
       tpSalesAc.RFO_Region__c = 'Class 1 Railroads';   // Region
       tpSalesAc.RFO_AccountStatus__c = 'Active';
	   try{
            database.insert(tpSalesAc,false);
            
        }catch(exception e){
        System.Assert(tpSalesAc.id==null);
       }
	   System.assertEquals('BNSF', tpSalesAc.name);
    return tpSalesAc;
   }
   
   /**********************************************User*********************************************/
   public static user userRecord1(){
       User usr = new User();
	   usr.LastName = 'LIVESTON';
       usr.FirstName='JASON';
       usr.Alias = 'jliv';
       usr.Email = 'jason.liveston@example.com';
       usr.Username = 'jason.liveston@example.com';
       usr.ProfileId = profileId.id;
       usr.TimeZoneSidKey = 'GMT';
       usr.LanguageLocaleKey = 'en_US';
       usr.EmailEncodingKey = 'UTF-8';
       usr.LocaleSidKey = 'en_US';
	   try{
            database.insert(usr,false);
            
        }catch(exception e){
        System.Assert(usr.id==null);
       }
	   System.assertEquals('jliv', usr.Alias);
    return usr;
   }
    /*
     * Creation of User record
     **/
   public static user userRecord2(){
       User usr = new User();
	   usr.LastName = 'LIVESON';
       usr.FirstName='JASO';
       usr.Alias = 'jsiv';
       usr.Email = 'jaso.liveson@example.com';
       usr.Username = 'jaso.liveson@example.com';
       usr.ProfileId = profileId.id;
       usr.TimeZoneSidKey = 'GMT';
       usr.LanguageLocaleKey = 'en_US';
       usr.EmailEncodingKey = 'UTF-8';
       usr.LocaleSidKey = 'en_US';
	   try{
            database.insert(usr,false);
            
        }catch(exception e){
        System.Assert(usr.id==null);
       }
	   System.assertEquals('jsiv', usr.Alias);
    return usr;
   }
   
   /**********************************************Account Team Member*********************************************/
   public static AccountTeamMember accTeam1(id accountID, id userId){
       AccountTeamMember accttm = new AccountTeamMember(AccountId = accountID,
                                                        UserId = userId,
                                                        TeamMemberRole = 'Customer Delivery Manager',
                                                        AccountAccessLevel = 'Read',
                                                        OpportunityAccessLevel = 'Read',
                                                        CaseAccessLevel = 'Read',
                                                        ContactAccessLevel = 'Read'
                                                        );
	   try{
            database.insert(accttm,false);
            
        }catch(exception e){
        System.Assert(accttm.id==null);
       }
	   System.assertEquals('Customer Delivery Manager', accttm.TeamMemberRole);
    return accttm;
   }
    /*
     * Creation of Account Team Member
     **/
   public static AccountTeamMember accTeam2(id accountID, id userId){
       AccountTeamMember accttm = new AccountTeamMember(AccountId = accountID,
                                                        UserId = userId,
                                                        TeamMemberRole = 'Customer Delivery Director',
                                                        AccountAccessLevel = 'Read',
                                                        OpportunityAccessLevel = 'Read',
                                                        CaseAccessLevel = 'Read',
                                                        ContactAccessLevel = 'Read'
                                                        );
	   try{
            database.insert(accttm,false);
            
        }catch(exception e){
        System.Assert(accttm.id==null);
       }
	   System.assertEquals('Customer Delivery Director', accttm.TeamMemberRole);
    return accttm;
   }
    /*
     * Creation of Account Team Member
     **/
   public static AccountTeamMember accTeam3(id accountID, id userId){
       AccountTeamMember accttm = new AccountTeamMember(AccountId = accountID,
                                                        UserId = userId,
                                                        TeamMemberRole = 'Sales Manager',
                                                        AccountAccessLevel = 'Read',
                                                        OpportunityAccessLevel = 'Read',
                                                        CaseAccessLevel = 'Read',
                                                        ContactAccessLevel = 'Read'
                                                        );
	   try{
            database.insert(accttm,false);
            
        }catch(exception e){
        System.Assert(accttm.id==null);
       }
	   System.assertEquals('Sales Manager', accttm.TeamMemberRole);
    return accttm;
   } 
   
   /**********************************************Contact*********************************************/
   public static Contact contactRecord1(Id accountID){
       Contact cnt = new Contact(
           FirstName = 'Tony',         // FirstName
           LastName = 'Alen',            // LastName
           RFO_Status__c = 'Active',                                               // Status
           Email = 'Tony.Alen@trinity.net',                                  // Email
           AccountId = accountID,                                          // Account Name
           Phone = '(806) 381-0261',                                               // Phone
           RFO_ContactRole__c = 'Rail Operations – 3rd Party Management Contact',  // Contact Role
           Fax = '(806) 371-7528'                                                 // Fax
       );
	   try{
            database.insert(cnt,false);
            
        }catch(exception e){
        System.Assert(cnt.id==null);
       }
	   System.assertEquals(accountID, cnt.AccountId);
    return cnt;
   }
   
   /**********************************************Case*********************************************/
   public static Case caseRecord1(id contactID){
       Case caseRec = new Case(
           RFO_CaseNature__c = 'Request',           // Case Nature
           ContactId = contactID,             // Contact Name
           Type = 'Estimating',                       // Type
           Priority = 'Medium',                       // Priority
           RFO_SubType__c = 'Information Request',    // Sub-Type
           Status = 'In Progress',                    // Status
           Origin = 'Phone'                                                 // Fax
       );
	   try{
            database.insert(caseRec,false);
            
        }catch(exception e){
        System.Assert(caseRec.id==null);
       }
	   System.assertEquals(contactID, caseRec.ContactId);
    return caseRec;
   }
   
   /**********************************************Call Report*********************************************/
   public static Call_Report__c commSalesCR(id accountID, id contactID){
		Id recordTypeIdCS = 
            Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
       Call_Report__c callRep = new Call_Report__c(
			Account__c = accountID,          // Account
			RecordTypeId = recordTypeIdCS,                // Record Type
			Contact__c = contactID,            // Contact
			RFO_Status__c = 'Completed',               // Status
			RFO_Purpose__c = 'test',                   // Purpose
			Call_Date__c = system.today(),  // Call Date
			RFO_TotalFleetCount__c = 7,              // Total Fleet Count
			RFO_Hashtags__c = '#FaceToFace',       // Hashtags
			Result__c = 'test\n'                      // Result
		);
	   try{
            database.insert(callRep,false);
            
        }catch(exception e){
        System.Assert(callRep.id==null);
       }
	   System.assertEquals('Completed', callRep.RFO_Status__c);
    return callRep;
   }
    /*
     * Creation of Call Report
**/
   public static Call_Report__c fieldServiceCR(id accountID, id contactID){
		Id recordTypeIdFS = 
            Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Field_Services').getRecordTypeId();
       Call_Report__c callRep1 = new Call_Report__c(
			Account__c = accountID,          // Account
			RecordTypeId = recordTypeIdFS,                // Record Type
			Contact__c = contactID,            // Contact
			RFO_Status__c = 'Completed',               // Status
			RFO_Purpose__c = 'test',                   // Purpose
			//Call_Date__c = Date.valueOf('10-4-2018'),  // Call Date
			RFO_TotalFleetCount__c = 7,              // Total Fleet Count
			RFO_Hashtags__c = '#CapitalMarkets',       // Hashtags
			Result__c = 'test\n'                      // Result
		);
	   try{
            database.insert(callRep1,false);
            
        }catch(exception e){
        System.Assert(callRep1.id==null);
       }
	   System.assertEquals('Completed', callRep1.RFO_Status__c);
    return callRep1;
   }
    /*
     * Creation of Call Report
     **/
   public static Call_Report__c investorServiceCR(id accountID, id contactID){
		Id recordTypeIdIS = 
            Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Investor_Services').getRecordTypeId();
       Call_Report__c callRep2 = new Call_Report__c(
			Account__c = accountID,          // Account
			RecordTypeId = recordTypeIdIS,                // Record Type
			Contact__c = contactID,            // Contact
			RFO_Status__c = 'Completed',               // Status
			RFO_Purpose__c = 'test',                   // Purpose
			//Call_Date__c = Date.valueOf('10-4-2018'),  // Call Date
			RFO_TotalFleetCount__c = 7,              // Total Fleet Count
			RFO_Hashtags__c = '#CapitalMarkets',       // Hashtags
			Result__c = 'test\n'                      // Result
		);
	   try{
            database.insert(callRep2,false);
            
        }catch(exception e){
        System.Assert(callRep2.id==null);
       }
	   System.assertEquals('Completed', callRep2.RFO_Status__c);
    return callRep2;
   }
    /*
     * Creation of Call Report
     **/
   public static Call_Report__c thirdPartySalesCR(id accountID, id contactID){
		Id recordTypeId3PS = 
            Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Third_Party_Sales').getRecordTypeId();
       Call_Report__c callRep3 = new Call_Report__c(
			Account__c = accountID,          // Account
			RecordTypeId = recordTypeId3PS,                // Record Type
			Contact__c = contactID,            // Contact
			RFO_Status__c = 'Completed',               // Status
			RFO_Purpose__c = 'test',                   // Purpose
			//Call_Date__c = Date.valueOf('10-04-2018'),  // Call Date
			RFO_TotalFleetCount__c = 7,              // Total Fleet Count
			RFO_Hashtags__c = '#CapitalMarkets',       // Hashtags
			Result__c = 'test\n'                      // Result
		);
	   try{
            database.insert(callRep3,false);
            
        }catch(exception e){
        System.Assert(callRep3.id==null);
       }
	   System.assertEquals('Completed', callRep3.RFO_Status__c);
    return callRep3;
   }
   
   /**********************************************Coverage Plan*********************************************/
   public static RFO_CoveragePlan__c activeCPRecord(Account accountID){
       Id activeRecordTypeId = 
           Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get('RFO_Active').getRecordTypeId();
		RFO_CoveragePlan__c covPlan = new RFO_CoveragePlan__c(
			RFO_CoverageRecommendation__c = 'Minimal',               
			RFO_ReasonForCoverageChange__c = 'Other', 
			RFO_AccountName__c = accountID.id,               
			RFO_CoveragePlan__c = 'Minimal', 
            RFO_RecordStatus__c=true,
            RecordTypeId = activeRecordTypeId,
            RFO_ActualContactDate__c = system.today(),
            //RFO_CoveragePlanApprovalStatus__c = 'Approved',
			RFO_PlanningStatus__c = 'Need to Schedule',  
			RFO_SalesLastFacetoFaceDate__c = system.today(),
            RFO_SalesLastContactDate__c = system.today(),
			RFO_Notes__c = 'CP Test'                
		);
	   try{
            database.insert(covPlan,false);
            
        }catch(exception e){
        System.Assert(covPlan.id==null);
       }
	   System.assertEquals('Minimal', covPlan.RFO_CoveragePlan__c);
    return covPlan;
   }
    /*
     * Creation of Coverage Plan
     **/
   public static RFO_CoveragePlan__c inActiveCPRecord(Account accountID){
       Id inActiveRecordTypeId = 
           Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get('RFO_Inactive').getRecordTypeId();
		RFO_CoveragePlan__c covPlan1 = new RFO_CoveragePlan__c(
			RFO_CoverageRecommendation__c = 'Minimal',               
			RFO_ReasonForCoverageChange__c = 'Other', 
			RFO_AccountName__c = accountID.id,               
			RFO_CoveragePlan__c = 'Minimal', 
            RFO_RecordStatus__c=false,
            RecordTypeId = inActiveRecordTypeId,
            //RFO_CoveragePlanApprovalStatus__c = 'Approved',
			RFO_PlanningStatus__c = 'Need to Schedule',  
			//RFO_SalesLastFacetoFaceDate__c = Date.valueOf('10-4-2018'),              
			RFO_Notes__c = 'CP Test'                
		);
	   try{
            database.insert(covPlan1,false);
            
        }catch(exception e){
        System.Assert(covPlan1.id==null);
       }
	   System.assertEquals('Minimal', covPlan1.RFO_CoveragePlan__c);
    return covPlan1;
   }
   
   /**********************************************Task*********************************************/
   public static Task cpTaskRecord(id contactID, id cpID){
		Task taskRec = new Task(
			Subject = 'Call',               
			Description = 'test', 
			WhoId = contactID,               
			WhatId = cpID ,
            Tasksubtype='Call'
		);
	   try{
            database.insert(taskRec,false);
            
        }catch(exception e){
            System.Assert(taskRec.id==null);
       }
	   System.assertEquals('Call', taskRec.Subject);
    return taskRec;
   }
}