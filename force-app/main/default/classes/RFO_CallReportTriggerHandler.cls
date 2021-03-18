public class RFO_CallReportTriggerHandler {
    public static void updateAccountRelatedEmail(List<Call_Report__c> callReportList){
        Id RecordTypeIdFieldServices = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Field_Services').getRecordTypeId();
        Set<String> AccountTeamRoles = new Set<String>{'Sales Manager'};
        Set<Id> accountIds = new Set<Id>();
        for(Call_Report__c report : callReportList){
        	accountIds.add(report.Account__c);
        }
        List<AccountTeamMember> accTeamList = [Select AccountId,TeamMemberRole,UserId,user.email FROM AccountTeamMember WHERE AccountId In :accountIds AND TeamMemberRole ='Sales Manager' ];
        List<Account> accountList = [Select Id, Name, owner.email, (Select  ContactId, Contact.FirstName,  Contact.LastName,  Contact.Email,  Contact.Name,  Contact.RFO_ContactRole__c  From AccountContactRelations) from Account acc where Id = :accountIds];        
        String invalidContactErrMsg1 = label.RFO_CallReport_Contact_Invalid1;
        String invalidContactErrMsg2 = label.RFO_CallReport_Contact_Invalid2;
        String invalidContactErrMsg3 = label.RFO_CallReport_Contact_Invalid3;
        for(Call_Report__c report : callReportList){
            Id RecordTypeIdManufacturing = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('Manufacturing_Operations').getRecordTypeId();
            if(report.RecordTypeId != RecordTypeIdManufacturing){
                Integer contactExists = 0;
                Integer secondarycontactExists = 0;
                Integer tertiarycontactExists = 0;
                for(Account acc : accountList){
                    if(report.Account__c==acc.Id){
                        for(AccountContactRelation acr: acc.AccountContactRelations){
                            if(acr.ContactId==report.Contact__c){
                                contactExists = 2;
                            }
                            if(report.RFO_SecondaryContact__c==null){
                                secondarycontactExists=1;
                            }else{
                                if(acr.ContactId==report.RFO_SecondaryContact__c)
                                    secondarycontactExists = 2;
                            }
                            if(report.RFO_TertiaryContact__c==null){
                                tertiarycontactExists=1;
                            }
                            else{
                                if(acr.ContactId==report.RFO_TertiaryContact__c)
                                    tertiarycontactExists = 2;
                            }                        
                        }
                    }
                }//for
                system.debug('NOW THE tertiarycontactExists is '+ tertiarycontactExists);
                String finalErrorMsg = label.RFO_CallReport_Contact_Invalid;
                Integer errCount = 0;
                if(contactExists==0){
                    finalErrorMsg = finalErrorMsg + ' ' +invalidContactErrMsg1;
                    errCount = errCount + 1;
                }
                if(secondarycontactExists==0){
                    errCount = errCount + 1;
                    if(contactExists==0)
                        finalErrorMsg = finalErrorMsg +' , ' + invalidContactErrMsg2;
                    else
                        finalErrorMsg = finalErrorMsg +' ' + invalidContactErrMsg2;
                }
                if(tertiarycontactExists==0){
                    errCount = errCount + 1;
                    if(contactExists==0 || secondarycontactExists ==0)
                        finalErrorMsg = finalErrorMsg +' , ' + invalidContactErrMsg3;
                    else
                        finalErrorMsg = finalErrorMsg +' ' + invalidContactErrMsg3;
                }
                system.debug('The error count is '+errCount );
                if(errCount > 0){
                    report.addError(finalErrorMsg,false);
                }
            }
            if(report.RecordTypeId == RecordTypeIdFieldServices ){//fieldservice starts
                if(accTeamList!=null && accTeamList.size()>0){
                    for(AccountTeamMember accTeam : accTeamList)
                    {
                        if(report.Account__c==accTeam.AccountId){
                            report.Account_Sales_Manager_Email__c = accTeam.user.email;
                			System.debug('report.Account_Sales_Manager_Email__c ::'+accTeam.user.email);
                        }
                    }
                }
                if(accountList!=null && accountList.size()>0){
                    for(Account ac : accountList){
                        if(report.Account__c==ac.Id){
                            report.Account_Owner_Email__c = ac.owner.email;
                			System.debug('report.Account_Owner_Email__c ::'+ac.owner.email);
            			}
        			}
    			}//if
			}//field services
 		}//main for loop
	}//method
    Public static void ValidateCallReportStatus(List<Call_Report__c> NewCRList){
        set<string> CRaccountIds = new set<string>();
        for(Call_Report__c cr : NewCRList){
            if(cr.RFO_Status__c == 'Completed')
				CRaccountIds.add(cr.Account__c);
		}
        if(CRaccountIds.size() > 0){
        RFO_coveragePlan__c[] CPList = [select id,RFO_AccountName__c from RFO_coveragePlan__c where RFO_CoveragePlanApprovalStatus__c ='Sent For Approval' 
                                        and RFO_AccountName__c in: CRaccountIds];
        set<string> CPAccountIds = new set<string>();
        for(RFO_coveragePlan__c cp: CPList){
            CPAccountIds.add(cp.RFO_AccountName__c);
        }
        for(Call_Report__c c: NewCRList){
            if(CPAccountIds.Contains(c.Account__c))
                c.addError('You cannot save the record as " Completed " because it is pending SVP approval');
        }
        
    }
    }
    
    //ALPHA-69 : Changes by MA
    Public static void previousCallDate(List<Call_Report__c> NewCRList,map<id,Call_Report__c> crOldMap){ 
        for(Call_Report__c cr : NewCRList) {
            if(crOldMap != null 
                && (cr.Call_Date__c != crOldMap.get(cr.Id).Call_Date__c || 
                (crOldMap.get(cr.Id).RFO_Status__c == 'Completed' && cr.RFO_Status__c == 'Draft'))) {
                    cr.Previous_Call_Date__c = crOldMap.get(cr.Id).Call_Date__c;
        }
        
    }
    }
    //End of changes by MA
}