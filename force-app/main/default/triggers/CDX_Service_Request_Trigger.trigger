//Trigger Name: CDX_Service_Request_Trigger
//Description: This trigger is to create records on Service Request Object and update Outbound Disposition info on SR records
trigger CDX_Service_Request_Trigger on RFO_ShopIncident__c (after insert, after update,before update, before insert, before delete) {
    
    
                
    //Updates CDM
    Id uid = System.UserInfo.getUserId();
    User myuser = [SELECT Id, Name, ProfileId FROM User WHERE Id =: uid LIMIT 1];
    system.debug('PROFILE ID: '+ myuser.ProfileId);
    List<Profile> prof = [SELECT Id, Name FROM Profile WHERE Id =: myuser.ProfileId];
    static final string CDM = 'Customer Delivery Manager';
    static final string CDD = 'Customer Delivery Director';
   
    // draft record type  
    Id draftRecTypeId = Schema.SObjectType.RFO_ShopIncident__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
    system.debug(draftRecTypeId);
    
    if(Trigger.isInsert && Trigger.isBefore)
    {   
        Map<string,AccountTeamMember> rfoCustomerMap = new Map<string,AccountTeamMember>();
        Map<string,string> cddMap = new Map<string,string>();
        Set<String> rfoCustomerSet = new Set<String>(); 
        for(RFO_ShopIncident__c Incident : Trigger.new)
        {
            if(!System.isBatch())
            {
                //Sets CDM
                if(myuser.Name != 'Integration User' && (prof.size() > 0) && (prof[0].Name == 'CDX Customer' || prof[0].Name == 'CDX Customer - Super User' || prof[0].Name == 'System Administrator'))
                {
                    rfoCustomerSet.add(Incident.RFO_Customer__c);
                }
                else
                {
                    System.debug('CORRECT USER PROFILE NOT FOUND ON USER');
                } 
            }
        }

        List<AccountTeamMember> mem = [SELECT AccountId,Id,UserId,TeamMemberRole 
                                                   FROM AccountTeamMember 
                                                   WHERE AccountId IN: rfoCustomerSet 
                                                   AND (TeamMemberRole =: CDM 
                                                   OR TeamMemberRole =: CDD)];
        for(AccountTeamMember a:mem){
            if(a.TeamMemberRole == CDM) {
                rfoCustomerMap.put(a.AccountId,a); 
            }
            else if(a.TeamMemberRole == CDD) {
                cddMap.put(a.AccountId,a.UserId); 
            }
        }
        for(RFO_ShopIncident__c Incident : Trigger.new) {
            if(!System.isBatch()) {
                if(rfoCustomerMap !=null && rfoCustomerMap.containsKey(Incident.RFO_Customer__c) && rfoCustomerMap.get(Incident.RFO_Customer__c).UserId !=null){
                    Incident.CDX_Customer_Delivery_Manager__c = rfoCustomerMap.get(Incident.RFO_Customer__c).UserId;
                    
                }
                else {
                    System.debug('NO CDM FOUND ON ACCOUNT');
                }
                if(cddMap.containsKey(Incident.RFO_Customer__c)) {
                    Incident.Customer_Delivery_Director__c = cddMap.get(Incident.RFO_Customer__c);
                }
            }
        }   
            
    } // end of before insert 
    
    //SI Callout Code
    
    //Sends Callout on Creates
    if (Trigger.isInsert && Trigger.isAfter)
    {
        for(RFO_ShopIncident__c request : Trigger.new)
        {  
            CDX_SI_Callout_Helper req = new CDX_SI_Callout_Helper(request.id);
            
            if (request.RFO_SIStatus__c == 'Cust. Submitted')
            { 
                if (!System.isBatch())
                {
                    
                    if(!test.isrunningtest() && myuser.Name != 'Integration User')
                    {
                        System.debug('is insert');
                        CDX_SI_Callout.SIPost(JSON.serialize(req));
                        
                    }
                }
            }
        }
    } // end of after insert
    
    //Sends Callout on Update
    if (Trigger.isUpdate && Trigger.isAfter)
    {
        
        for(RFO_ShopIncident__c request : Trigger.new)
        {  
            CDX_SI_Callout_Helper req = new CDX_SI_Callout_Helper(request.id);
            
            //regradless of the status, it should make a call to TAS if disposition requested date is populated and outbound disposition is updated
           // if (request.RFO_SIStatus__c == 'Cust. Submitted' || request.RFO_SIStatus__c == 'Active')
          // { 
                RFO_ShopIncident__c oldsr = Trigger.oldMap.get(request.ID);
                system.debug('++++++++++++++id'+oldsr);
                
                if(oldsr.RFO_ShopIncidentID__c != NULL)
                {
                    System.debug('is update');
                    
                    if (request.CDX_Destination_Consignee__c != oldsr.CDX_Destination_Consignee__c ||
                        request.CDX_Care_of_Party__c != oldsr.CDX_Care_of_Party__c ||
                        request.RFO_OutboundRoutingInformation__c != oldsr.RFO_OutboundRoutingInformation__c ||
                        request.RFO_FreightResponsibility__c != oldsr.RFO_FreightResponsibility__c ||
                        request.CDX_Customer_Broker__c != oldsr.CDX_Customer_Broker__c ||
                        request.CDX_Freight_Forwarder__c != oldsr.CDX_Freight_Forwarder__c ||
                        request.RFO_ShopInstruction__c != oldsr.RFO_ShopInstruction__c) 
                    {
                        
                        System.debug('Outbound Disposition Fields Changed');
                        //if (!System.isBatch() && request.CDX_Bypass_Validation__c == true)
                        if(!System.isBatch())
                        {
                            
                            if(!test.isrunningtest() && myuser.Name != 'Integration User')
                            {
                                CDX_SI_Callout.SIPut(JSON.serialize(req));
                            }
                        }
                    }
                 system.debug('++++++++++before if');
                }
                  
               else if (request.RFO_ShopIncidentID__c == NULL)
                {
                    
                       system.debug('++++++++++after else if');
                     //regarddless of bypassvalidation value, it should make a call to TAS to create if request.RFO_ShopIncidentID__c == NULL
                    //if (!System.isBatch()&& request.CDX_Bypass_Validation__c == true)
                    if (!System.isBatch())
                    {
                        system.debug('++++++++++Bypassvalidation'+ request.CDX_Bypass_Validation__c );
                        
                        if(!test.isrunningtest() && myuser.Name != 'Integration User')
                        {
                            System.debug('Posting From Update: RFO Id Still Null');
                            CDX_SI_Callout.SIPost(JSON.serialize(req)); 
                        }
                    }
                } // end of else if
           // }
        }
    } // end of after update 

    // Only draft record type is allowed to delete  
    if (Trigger.isDelete && Trigger.isBefore){
        system.debug('++++delete trigger');
        for(RFO_ShopIncident__c sr : trigger.old){
           if(myuser.Name != 'Integration User' && (prof.size() > 0) && prof[0].Name != 'System Administrator' || Test.isRunningTest() ){
               system.debug('++++username'+ prof[0].Name);
                if(sr.RFO_ShopIncidentID__c != NULL){
                    system.debug('+++draftrecord'+sr.RecordTypeId );
                    sr.adderror('You do not have permission to delete this record.');
              } 
           }
        }
    }
    
    if(trigger.isUpdate && trigger.isBefore) {
        set<Id> accountIds = new set<Id>();
        for(RFO_ShopIncident__c sr : trigger.new){
           if(sr.Customer_Delivery_Director__c == null) {
               accountIds.add(sr.RFO_Customer__c);
           }
        }
        if(!accountIds.isEmpty()) {
            Map<string,string> cddMap = new Map<string,string>();
            for(AccountTeamMember atm : [SELECT AccountId,Id,UserId 
                                               FROM AccountTeamMember 
                                               WHERE AccountId IN : accountIds 
                                               AND TeamMemberRole =: CDD]) {
                                                   
                cddMap.put(atm.accountId, atm.UserId);
            }
            for(RFO_ShopIncident__c sr : trigger.new){
                system.debug('sr.RFO_Customer__c = '+sr.RFO_Customer__c);
                if(sr.Customer_Delivery_Director__c == null && cddMap.containsKey(sr.RFO_Customer__c)) {
                   sr.Customer_Delivery_Director__c = cddMap.get(sr.RFO_Customer__c);
                }
            }
        }
    }
    
}