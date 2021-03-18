/* Batch class to calculate business hour on closed cases*/
global class RFO_CaseCalculateBusinessHourBatch implements 
	Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
	
        
     global Database.QueryLocator start(Database.BatchableContext bc){
        // collect the batches of records or objects to be passed to execute        
        return Database.getQueryLocator(            
            'SELECT Id, CreatedDate, ClosedDate, CaseNumber, Subject, Status,Task_Associated__c, FCR_Case__c,Case_Age_In_Business_Days__c, Case_Age_Business_Hour__c from CASE WHERE status=\'Closed\' and Task_Associated__c = null and Contact.RFO_Status__c=\'Active\' and closeddate=LAST_N_DAYS:30');
    }
        
    global void execute(Database.BatchableContext bc,  List<Case> records){
        // process each batch of records
        try{
            if(records.size()>0){
                BusinessHours bh = [SELECT Id, Name FROM BusinessHours WHERE IsDefault=true];
        		system.debug('BH '+bh.Id + ' and name ::'+bh.Name);
                system.debug('status '+records[0].status + ' and ClosedDate ::'+records[0].ClosedDate);
        		Task[] tasks = [select Id, WhatId from Task where WhatId in :records];
                system.debug('status '+records[0].status + ' and ClosedDate ::'+records[0].ClosedDate);
                for(Case c : records){
                    system.debug('status '+c.status + ' and ClosedDate ::'+c.ClosedDate);
                    if(c.status=='Closed' && c.ClosedDate!=null){
                		c.Task_Associated__c = 0;
                		boolean taskAssociatedFlag = false;
                		for (Task t : tasks) {
                    		if(t.WhatId == c.id){
                        		c.Task_Associated__c = 1;
                        		taskAssociatedFlag = true;
                    		}
        				}
                		c.FCR_Case__c=0;
                
                		Decimal CaseAgeBusinessHours = BusinessHours.diff(bh.Id, c.CreatedDate, c.ClosedDate)/3600000.0;
                		Double CaseAgeBusinessHoursRounded = CaseAgeBusinessHours.setScale(2,System.RoundingMode.HALF_UP);
                		c.Case_Age_Business_Hour__c = CaseAgeBusinessHoursRounded;
                		//System.debug('Business Hours ::'+CaseAgeBusinessHoursRounded);
                
                		if(CaseAgeBusinessHoursRounded <= 8.00 && !taskAssociatedFlag){
                    		c.FCR_Case__c=1;
                		}
                		Decimal caseAgeBusinessDays = CaseAgeBusinessHours/8; 
                		//System.debug('Business Days Before Rounded ::'+caseAgeBusinessDays);
                		Double caseAgeBusinessDaysRounded = caseAgeBusinessDays.setScale(2,System.RoundingMode.HALF_UP);
                		System.debug('Business Days ::'+caseAgeBusinessDaysRounded);
                
                		c.Case_Age_In_Business_Days__c = caseAgeBusinessDaysRounded;    
                
            		}
                }
                Database.update(records,true);
            }
        }
        catch(Exception e) { 
            system.debug(e); 
        }  
    }
        
    global void finish(Database.BatchableContext bc){
        
    }        
        
}