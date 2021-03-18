/* Name: RFO_SendEmailOnFileUploadHelper
 * Created By: Ramesh
 * Created Date: November 2020
 * Jira: ALpha- 529
 * Purpose: As an Engineer user, need system generated alerts sent to all teams that needs notifications regarding the spec sheet uploads into Order Object.
 */

public class RFO_SendEmailOnFileUploadHelper {
    
    /* Method Name: sendEmails
     * Created By: Ramesh
     * Created Date: November 2020
     * Jira: ALpha- 529
     * Purpose: As an Engineer user, need system generated alerts sent to all teams that needs notifications regarding the spec sheet uploads into Order Object.
     */
    public static void sendEmails(List<ContentVersion> newList){
        // declaring Variables
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> orderIdNewCarSet = new Set<Id>();
        Set<Id> AssetIdSet = new Set<Id>();
        Set<String> sendEmails = new Set<String>();
        List<String> lstSendEmails = new List<String>();
        list<user> userIds = new list<user>();
        string[] stringuserIds = new list<string>();
        String orderType = '';
        String emailSubject = RFO_Constant.Email_Subject;	
        String emailBody = RFO_Constant.Email_Content;	
        String Hyperlinks = '';
        string cvTitle ;
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        AlertService alertServ = new AlertService();
        String relatedTo;
        string assemblyPlant ;
        Id assetRT = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(RFO_Constant.AssetFile_RecordType).getRecordTypeId();
        
        // Looping the new list of Content Version
        for(ContentVersion cv: newList){
            // Checking Content Document Id is not null and File type is Spec Sheet
             if(cv.ContentDocumentId != null 
                && cv.RecordTypeId == assetRT
                && cv.Trinity_File_Type__c == RFO_constant.File_Type
               )
            {
                // Adding values in the sets
                contentDocumentIdSet.add(cv.ContentDocumentId);
                AssetIdSet.add(cv.FirstPublishLocationId);
                Hyperlinks = Hyperlinks +  baseUrl +'/' + cv.ContentDocumentId ;
                cvTitle = cv.Title;
            }
        } // End for Loop
        
        // Query on the Asset Files object to get Plant details
        for(RFO_Asset_File__c assetRec : [SELECT id, name, RFO_OrderNumber__c, RFO_CurrentPlant__r.RFO_AssemblyPlantDistributionList__c,
                                         // RFO_CurrentPlant__r.RFO_AssemblyPlantCommercialDistList__c,RFO_CurrentPlant__r.RFO_AssemblyPlantThirdPartyDistList__c,
                                          RFO_CurrentPlant__r.RFO_FinishingPlantDistributionList__c, RFO_OrderNumber__r.AccountId, 
                                          RFO_OrderNumber__r.Status, RFO_OrderNumber__r.RecordType.DeveloperName , RFO_OrderNumber__r.Id, RFO_OrderNumber__r.Type 
                                          FROM RFO_Asset_File__c where Id in : AssetIdSet and RFO_OrderNumber__r.Status != 'Order Cancelled' and RFO_OrderNumber__r.Status != 'Delivery Complete'
                                          ]){
                                              // Changed by Ramesh Start
                                              orderType = assetRec.RFO_OrderNumber__r.Type;
                                              if(((orderType == RFO_constant.ORDER_TYPE_DIRECT_SALE || orderType == RFO_constant.Prototype || 
                                                   orderType == RFO_constant.LEASE || orderType == RFO_constant.Advanced_Order
                                                 )
                                                  && (assetRec.RFO_OrderNumber__r.RecordType.DeveloperName == RFO_constant.ORDER_NEWCAR
                                                      || assetRec.RFO_OrderNumber__r.RecordType.DeveloperName == RFO_constant.ORDER_Retanking)) || Test.isRunningTest()){
                                                  // Adding account Ids in the set
                                                  accountIdSet.add(assetRec.RFO_OrderNumber__r.AccountId); 
                                                  
                                                      if(assetRec.RFO_OrderNumber__r.Status !=  RFO_constant.INITIATED){
                                                          // Adding record ids in the set
                                                          orderIdNewCarSet.add(assetRec.RFO_OrderNumber__r.Id); 
                                                          
                                                          // Adding email ids in the list
                                                          if(assetRec.RFO_CurrentPlant__r.RFO_AssemblyPlantDistributionList__c != null) sendEmails.add(assetRec.RFO_CurrentPlant__r.RFO_AssemblyPlantDistributionList__c); 
                                                       // if(assetRec.RFO_CurrentPlant__r.RFO_AssemblyPlantCommercialDistList__c != null) sendEmails.add(assetRec.RFO_CurrentPlant__r.RFO_AssemblyPlantCommercialDistList__c);
                                                       // if(assetRec.RFO_CurrentPlant__r.RFO_AssemblyPlantThirdPartyDistList__c != null) sendEmails.add(assetRec.RFO_CurrentPlant__r.RFO_AssemblyPlantThirdPartyDistList__c);
                                                          if(assetRec.RFO_CurrentPlant__r.RFO_FinishingPlantDistributionList__c != null) sendEmails.add(assetRec.RFO_CurrentPlant__r.RFO_FinishingPlantDistributionList__c);
                                                          // Upending asset names in subject line and email body
                                                      }
                                                  // Changed by Ramesh End
                                                  emailSubject = emailSubject + assetRec.name + ', '; 
                                                  relatedTo = assetRec.id;
                                                  emailBody = emailBody + ' <a href="'+ baseUrl +'/' + assetRec.id + '">'+ assetRec.name +'</a>'  + ', ';
                                              }
        }
        
        // Removing last comma from the email subject and and email body
        emailSubject = emailSubject.removeEnd(', ');
        emailBody = emailBody.removeEnd(', ');
        
        // Query on Account Members to get All CDMs
        for(AccountTeamMember accTeamMemb :[Select id, AccountId, User.Name, User.Email 
                                            FROM AccountTeamMember where AccountId in : accountIdSet
                                            AND TeamMemberRole = 'Customer Delivery Manager']){
            
                                                // Adding email ids in the list
                                                sendEmails.add(accTeamMemb.User.Email);
        }
        
        // Query on Project Engineer to get All Project Engineer's Email Ids
        for(Project_Engineer__c projectEngineerRec :[Select id, Engineer__r.Name, Engineer__r.Email 
                                            FROM Project_Engineer__c where Order__c in : orderIdNewCarSet]){
            
                                                // Adding email ids in the list
                                                sendEmails.add(projectEngineerRec.Engineer__r.Email);
        }
        
        // Adding Hyperlinks in Email Body
        emailBody = emailBody + Hyperlinks;
        RFO_Asset_File__c assetFile = new RFO_Asset_File__c();
        if(relatedTo != null){
            assetFile.id = relatedTo;
            assetFile.Spec_Sheet_URL__c = Hyperlinks;
            assetFile.Spec_Sheet_Name__c = cvTitle;
            update assetFile;
        }
        
        // Checking send emails should not be blank
        // Adding set values in List
        lstSendEmails.addAll(sendEmails);
        // Calling method to send emails
        // sendEmails(lstSendEmails, emailSubject, emailBody);
        // String emailIds = string.join(lstSendEmails,';');
        
        userIds = [select id from user where email in:lstSendEmails];
        for(user u: userIds){
            stringuserIds.add(u.id);
        }

        // Changed by Ramesh Start
        for(user u: [select id from user where id in (select userorgroupid from groupmember where group.name = 'Production Planning')]){
            if(!stringuserIds.contains(u.Id)) stringuserIds.add(u.id);
        }
        for(user u: [select id from user where id in (select userorgroupid from groupmember where group.name = 'Estimating Users')]){
            if(!stringuserIds.contains(u.Id)) stringuserIds.add(u.id);
        }
        
        if(stringuserIds.size() > 0 && relatedTo != null){
            // Changed by Ramesh End
            Alert__c objAlert = alertServ.createAlert('New_Car_Engg_Spec_Sheet', null, string.join(stringuserIds,';')+';', null, null, relatedTo, emailSubject, emailBody);
            objAlert.Completed__c = true;
            if(objAlert != null){
                insert objAlert;
            }
        }
    }
    
}