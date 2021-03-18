/***************************
* @author :Krishna V--*/
public class CDX_CommunityUtilityExt {
    
    public static Set<String> GetWeekIds()
    {
        System.debug('GETTING WEEK IDS');
        Set<String> weekIds  = new Set<String>();
        Date weekstartdate=Date.today().addDays(-7);
        System.debug('weekstartdate>>>'+weekstartdate);
        List<TrinityWeek__mdt> mdtList = [SELECT Label, WeekID__c, WeekStartDate__c, WeekEndDate__c, BusinessDays__c from TrinityWeek__mdt where WeekStartDate__c >= :weekstartdate ];
        System.debug('mdtList>>>'+mdtList);
        for(TrinityWeek__mdt mdt:mdtList ){
            weekIds.add(mdt.WeekID__c);  
        }
        System.debug('weekIds in Utility'+weekIds);
        return weekIds;
    }
    
    public static String PrepareEmailBodyforSubscribedContacts(List<CDX_ScheduleDetail__x> lstScheduleDetail)
    {
        
        String label=System.Label.CDX_ScheduleExtDetailLink;
        //label=label.replace('PROJECTIDName','a0KS000000EVI0tMAH'+'/'+'Valero Change Of Service - CRD to ASPH');
        String test='www.google.com';
        System.debug('label'+label);
        List<String> scheduleIds= new List<String>();
        List<ID> scheduleForProjectIds= new List<ID>();
        
        for(CDX_ScheduleDetail__x objSchdeuleDetail:lstScheduleDetail)  
        {
            scheduleIds.add(objSchdeuleDetail.CDX_Schedule__c);  
        }
      
        System.debug('scheduleIds>>>'+ scheduleIds);
        List<CDX_Schedule__c> scheduleList=[select id,CDX_Project__c, Schedule_External_ID__c from CDX_Schedule__c where Schedule_External_ID__c in:scheduleIds];
        System.debug('scheduleList>>'+scheduleList);
        for(CDX_Schedule__c objSchdeuleDetail:scheduleList)  
        {
            scheduleForProjectIds.add(objSchdeuleDetail.CDX_Project__c); 
        }
        System.debug(' scheduleForProjectIds>>'+ scheduleForProjectIds);
        
        List<RFO_Projects__c> projList=[select id,name from RFO_Projects__c where id in: scheduleForProjectIds];
        System.debug('projList>>'+ projList);
        
        //Creates Map that maps schedule details to projects
        Map<String,RFO_Projects__c> projmap = new Map<String,RFO_Projects__c>();  
        for(CDX_ScheduleDetail__x deets : lstScheduleDetail)  
        {
            for(CDX_Schedule__c scheds:scheduleList)  
            {
                if(scheds.Schedule_External_ID__c == deets.CDX_Schedule__c)
                {
                    for(RFO_Projects__c projs : projList)
                    {
                        if(scheds.CDX_Project__c == projs.Id)
                        {
                        	projmap.put(deets.CDX_Schedule__c,projs);  
                        }
                    } 
                }
            }
        }
        
        String  emailBody;
        
        Date weeksd=Date.today().addDays(-7);
        List<TrinityWeek__mdt> mdtList = [SELECT Label, WeekID__c, WeekStartDate__c, WeekEndDate__c, BusinessDays__c from TrinityWeek__mdt where WeekStartDate__c >= :weeksd ];
        
        Integer iCounter=0;
        String templateFirst;
        
        if(lstScheduleDetail.size()>0){
            for(CDX_ScheduleDetail__x objSchdeuleDetail:lstScheduleDetail)  
            {
                
                integer afterDecimal;
                if(objSchdeuleDetail.CDX_Projected_Customer_Release__c!=null){
                    String eE_remaining = objSchdeuleDetail.CDX_Projected_Customer_Release__c;
                    afterDecimal = Integer.valueOf(eE_remaining);
                }    
                Datetime dT ;
                for(TrinityWeek__mdt mtd:mdtList){
                    if(objSchdeuleDetail.CDX_Week__c == mtd.WeekID__c){
                        dT = mtd.WeekStartDate__c;
                    }
                }
                String weekStartDate;
                if(dT!=null){
                    weekStartDate = dT.format('yyyy-MM-dd');
                    
                    label=label.replace('PROJECTIDName',projmap.get(objSchdeuleDetail.CDX_Schedule__c).id+'/'+projmap.get(objSchdeuleDetail.CDX_Schedule__c).name);
                }
                if(iCounter==0)
                {
                    templateFirst='<!DOCTYPE html><html><head><style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style><title>Page Title</title></head><body><p>Hello,</p>You have cars that are scheduled to be released the week of '+ weekStartDate +'<br><br><table style="width:100%">';
                    templateFirst+='<tr><th>Schedule</th>';
                    templateFirst+='<th>Shop Name</th> ';
                    templateFirst+=' <th>Inbound Location</th>';
                    templateFirst+=' <th>Projected Release</th>';
                    templateFirst+='</tr>';
                    templateFirst+='<tr></tr>';
                }
                iCounter++;
                //label=label.replace('PROJECTIDName',projList[iCounter].id+'/'+projList[iCounter].name);
                System.debug('label in Counter>>>>'+label);
                templateFirst+='<tr><td><center><a href='+'\''+label+'\''+'>'+objSchdeuleDetail.ExternalId+'</a>'+'</center></td><td><center>' +objSchdeuleDetail.CDX_Schedule__r.CDX_Shop_Name__c + '</center></td><td><center>' + objSchdeuleDetail.CDX_Schedule__r.CDX_Shop_Location__c+ '</center></td><td><center>' + afterDecimal +'</center></td></tr>';
                
            }    
            templateFirst+='</table>';     
        }    
        
        
        String templateThird='<br>';
        templateThird+='You are receiving this email notification because your notification preferences have been setup in the TrinityRail service portal. Please login or contact your CDM to update your preferences.<br><br>';
        
        templateThird+='TrinityRail<br>';
        templateThird+='2525 N Stemmons Fwy, Dallas, TX 75207<br>';
        templateThird+='800-227-8844<br>';
        templateThird+='support.trinityrail.com<br>';
        templateThird+='© 2019 TrinityRail<br>';
        
        // templateThird+=Label.CDX_Footer;
        
        templateThird+='</body></html>';
        
        emailBody=templateFirst+templateThird; 
        System.debug(' emailBody in CommunityUtility'+ emailBody);
        return emailBody;
    }
    
    public static List<Messaging.SingleEmailMessage> SendEmailforAllSubscribedContacts(Id accountId, String emailBody)
    {
        List<Messaging.SingleEmailMessage> emails;
        List<Contact> lstContacts = [Select Name, Email, CDX_Project_Notification_Preference__c from Contact where CDX_Project_Notification_Preference__c = true and Id in (Select ContactId from AccountContactRelation where AccountId = :accountId)];
        System.debug('lstContacts>>>'+lstContacts);
        if(lstContacts.size()>0)
        {
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: 'noreply@trin.net'];
            System.debug('owea>>>'+owea);
            emails=new List<Messaging.SingleEmailMessage>();
            for(Contact objContact:lstContacts)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(objContact.id);
                mail.setSaveAsActivity(false);
                mail.setSubject('Cars to be Released');
                if ( owea.size() > 0 ) { mail.setOrgWideEmailAddressId(owea.get(0).Id);} 
                mail.setHtmlBody(emailBody);
                emails.add(mail);
            }
            //return emails;
        }
        System.debug('emails in utility>>'+emails);
        return emails;
    } 
}