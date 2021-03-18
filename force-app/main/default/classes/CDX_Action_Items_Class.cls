global class CDX_Action_Items_Class {
    
    @AuraEnabled(cacheable=true)
    public static ActionItems GetActionItems() {
        //Methods With Sharing
        MethodsWithSharing OtherMeths = new MethodsWithSharing();
        
        //Methods Without Sharing
        MethodsWithoutSharing DispMeth = new MethodsWithoutSharing();
        
        //Set Action Items
        ActionItems Results = new ActionItems();
        Results.PendingEstimates = OtherMeths.GetPendingEstimates();
        Results.PendingOTMA = OtherMeths.GetPendingOTMA();
        Results.OutboundDisposition = DispMeth.GetOutboundDisposition();
        Results.AwaitingSchedules = OtherMeths.GetAwaitingSchedules();
        Results.AwaitingCases = OtherMeths.GetAwaitingCases();
        Results.InvoicesDue = OtherMeths.GetInvoicesDue();
        Results.MaturingRiders = OtherMeths.GetMaturingRiders();
        Results.permCheck = FeatureManagement.checkPermission('CDX_SchedulesAccess');   //Added by MA BETA-190
        if(Results.permCheck || Test.isRunningTest()) {
            Results.ObjectData = getProjectList();    //Added by MA BETA-190
        }
        
        return Results; 
    }
    
    public class ActionItems {
        @AuraEnabled
        public List<CDX_Estimate__c> PendingEstimates;
        @AuraEnabled
        public List<RFO_ShopIncident__c> PendingOTMA;
        @AuraEnabled
        public List<DispData> OutboundDisposition;
        @AuraEnabled
        public List<RFO_Projects__c> AwaitingSchedules;
        @AuraEnabled
        public List<Case> AwaitingCases;
        @AuraEnabled
        public List<CDX_Invoice__c> InvoicesDue;
        @AuraEnabled
        public List<RFO_Rider__c> MaturingRiders;
        @AuraEnabled
        public MainWrapper ObjectData;   //Added by MA BETA-190
        @AuraEnabled
        public boolean permCheck;   //Added by MA BETA-190
    }
    
    global class DispData implements Comparable{
        @AuraEnabled
        public String AssetName;
        @AuraEnabled
        public String ShopName;
        @AuraEnabled
        public String ServicingRailroad;
        @AuraEnabled
        public String DaysWaiting;
        @AuraEnabled
        public String LinkURL;
        
        
        // Compare opportunities based on the opportunity amount.
        global Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
          
            
            DispData Compare = (DispData)compareTo;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if(DaysWaiting == NULL && Compare.DaysWaiting != NULL)
            {
                returnValue = -1;
            }
            //System.debug('Comparing: '+DaysWaiting+'  and  '+Compare.DaysWaiting);
            if (integer.valueof(DaysWaiting) > integer.valueof(Compare.DaysWaiting)) {
                // Set return value to a positive value
                returnValue = -1;
            } else if (integer.valueof(DaysWaiting) < integer.valueof(Compare.DaysWaiting)) {
                // Set return value to a negative value.
                returnValue = 1;
            }
            return returnValue;      
        }
    }
    
    
    //With Sharing Methods
    public with sharing class MethodsWithSharing{
        //Gets Pending Esimates
        @AuraEnabled(cacheable=true)
        public List<CDX_Estimate__c> GetPendingEstimates()
        {
            List<CDX_Estimate__c> PendEst = [SELECT ID, Name, CDX_Status__c, CDX_Estimated_Amount__c, CDX_Asset__r.Name, CDX_Asset__c, CDX_Days_Waiting__c, CDX_Date_Notified__c
                                             FROM CDX_Estimate__c
                                             WHERE CDX_DetailsToReviewCount__c > 0
                                             ORDER BY CDX_Days_Waiting__c DESC
                                             LIMIT 1000];
            system.debug('******Pending Estimates'+ PendEst );
            return PendEst;
        }
        
        //Gets Pending OTMA
        @AuraEnabled(cacheable=true)
        public List<RFO_ShopIncident__c> GetPendingOTMA()
        {
            List<RFO_ShopIncident__c> PendOTMA = [SELECT ID, RFO_Asset__c, RFO_Asset__r.Name, RFO_Status__c, RFO_ShopName__c, Name, CDX_Num_of_Days_Waiting_OTMA__c 
                                                  FROM RFO_ShopIncident__c
                                                  WHERE CDX_Num_of_Days_Waiting_OTMA__c != 'Not Waiting'
                                                  ORDER BY CDX_Num_of_Days_Waiting_OTMA__c DESC
                                                  LIMIT 1000];            
            return PendOTMA;
        }       
        
        //Gets Schedules Waiting
        @AuraEnabled(cacheable=true)
        public List<RFO_Projects__c> GetAwaitingSchedules()
        {      
            List<RFO_Projects__c> WaitProj = [SELECT ID, Name, RFO_DemandDriverName__c, RFO_TotalAssetCount__c, CDX_Schedule_Last_Published_Date__c
                                              FROM RFO_Projects__c
                                              WHERE RFO_DemandDriverName__c != 'Reassignment'  AND CDX_Count_of_Pending_Schedules__c > 0
                                              ORDER BY CDX_Schedule_Last_Published_Date__c DESC
                                              LIMIT 1000];
            
            return WaitProj;
        }
        
        //Gets Cases Waiting
        @AuraEnabled(cacheable=true)
        public List<Case> GetAwaitingCases()
        { 
            List<Case> WaitCase = [SELECT ID, CaseNumber, Subject, Type, Case_Age__c, Status
                                   FROM Case
                                   WHERE Status = 'Waiting on Customer'
                                   ORDER BY Case_Age__c DESC 
                                   LIMIT 1000];
            
            return WaitCase;
        }
        
        //Gets Invoices Due
        @AuraEnabled(cacheable=true)
        public List<CDX_Invoice__c> GetInvoicesDue()
        {
            List<CDX_Invoice__c> InvoicesDue = [SELECT ID, Name, CDX_Amount_Due__c, CDX_Invoice_Type__c, CDX_Invoice_Date__c, CDX_Status__c
                                                FROM CDX_Invoice__c
                                                WHERE CDX_Status__c = 'Due' OR CDX_Status__c = 'Unpaid'
                                                ORDER BY CDX_Invoice_Date__c DESC
                                                LIMIT 1000];
            
            return InvoicesDue;
         
        }
        
        //Gets Maturing Riders
        @AuraEnabled(cacheable=true)
        public List<RFO_Rider__c> GetMaturingRiders()
        {
            List<RFO_Rider__c> LetsRide = [SELECT ID, Name, RFO_Account__c, RFO_Account__r.OwnerId, RFO_Account__r.RFO_AccountOwner__c, RFO_OriginalMaturityDate__c, RFO_CurrentMaturityDate__c, CDX_Rider_Link__c, CDX_Rider_Sales_Rep__c  
                                           FROM RFO_Rider__c
                                           WHERE (RFO_OriginalMaturityDate__c >= LAST_N_DAYS:120 AND RFO_OriginalMaturityDate__c <= TODAY) OR (RFO_OriginalMaturityDate__c > TODAY AND RFO_CurrentMaturityDate__c >= LAST_N_DAYS:120 AND RFO_CurrentMaturityDate__c <= TODAY)
                                           ORDER BY RFO_OriginalMaturityDate__c DESC
                                           LIMIT 1000];
            
            //Set Hyperlink
            for(RFO_Rider__c FoundRider : LetsRide)
            {
                FoundRider.CDX_Rider_Sales_Rep__c = FoundRider.RFO_Account__r.RFO_AccountOwner__c; 

                FoundRider.CDX_Rider_Link__c = '/s/profile/'+FoundRider.RFO_Account__r.OwnerId;
            }
            
            return LetsRide;
        }
    }
    
    
    //Without Sharing Methods
    public without sharing  class MethodsWithoutSharing{
        @AuraEnabled(cacheable=true)
        public List<DispData> GetOutboundDisposition()
        {
            //Data Return List 
            List<DispData> DispReturn = new List<DispData>();
            
            //Get User Contact
            Id uid = System.UserInfo.getUserId();
            User founduser = [SELECT Id, Name, ContactId FROM User WHERE Id =: uid LIMIT 1];
            System.debug('USER ID: '+uid);
            System.debug('FOUND CONTACT ID: '+founduser.Id);
            
            //Query Account IDs Based On Conact
            List<AccountContactRelation> AccConList = [SELECT Id, AccountId, ContactId, IsActive FROM AccountContactRelation WHERE ContactId =: founduser.ContactId];
            Set<Id> AccIdList = new Set<Id>(); 
            for (AccountContactRelation rel : AccConList)
            {
                Id AccId = rel.AccountId;
                AccIdList.add(AccId);
            }
            System.debug('FOUND RELATIONS: '+AccConList.size());
            System.debug('SET ID SIZE: '+AccIdList.size()); 
            
            //Query TRType from Asset
            Set<String> Trtypes = new Set<String>();
            Trtypes.add('Termination');
            Trtypes.add('Reassignment');
            Trtypes.add('Pre-Assignment');
            
            //Query Service Request that arent for reassigmnet
            List<RFO_ShopIncident__c> OutDisp = [SELECT ID, Name, RFO_Customer__r.Id ,CDX_Asset_Name__c, RFO_Asset__r.RFO_CarType__c, 
                                                 RFO_Asset__r.RFO_CarMark__c, RFO_Asset__r.RFO_TRType__c ,CDX_Service_Request_Link__c, RFO_Asset__c, RFO_Asset__r.Name, 
                                                 CDX_Servicing_Railroad__c, RFO_ShopName__c,RFO_SIStatus__c, CDX_Num_of_Days_Waiting_Disposition__c, RFO_RepairType__c
                                                 FROM RFO_ShopIncident__c
                                                 WHERE CDX_Num_of_Days_Waiting_Disposition__c != 'Not Waiting' 
                                                 AND RFO_Customer__r.Id in :AccIdList
                                                 AND RFO_RepairType__c != 'Assignment'
                                                 AND RFO_SIStatus__c != 'Closed'
                                                 AND RFO_Asset__r.RFO_TRType__c not in :Trtypes
                                                 ORDER BY CDX_Num_of_Days_Waiting_Disposition__c DESC
                                                 LIMIT 1000];
            
            System.debug('SERVICE REQUEST FOUND: '+OutDisp.size());
            Set<Id> SRIDList = new Set<Id>(); 
            for (RFO_ShopIncident__c Disp : OutDisp)
            {
                Id SRID = Disp.Id;
                SRIDList.add(SRID);
                DispData data = new DispData();
                data.AssetName = Disp.RFO_Asset__r.Name;
                data.ShopName = Disp.RFO_ShopName__c;
                data.ServicingRailroad = Disp.CDX_Servicing_Railroad__c;
                data.DaysWaiting = Disp.CDX_Num_of_Days_Waiting_Disposition__c;
                data.LinkURL = '/s/service-request/'+Disp.Id+'/'+Disp.Name+System.Label.DispositionsTab;
                DispReturn.add(data);
            }
            
            
            List<Case> dispcases = [SELECT Id, CDX_Project_Asset__r.Id 
                                    FROM Case 
                                    WHERE Type = 'Disposition'];
            
            Set<Id> CaseId = new Set<Id>(); 
            for (Case pacase : dispcases)
            {
                Id CID = pacase.CDX_Project_Asset__r.Id;
                CaseId.add(CID);
            }
            
            List<RFO_ProjectAssetSI__c> PASIList = [SELECT ID, Name, RFO_Asset__c, RFO_Project__c, RFO_Project__r.RFO_DemandDriverName__c, CDX_Num_of_Days_Waiting_Disposition__c, 
                                                    RFO_ShopIncidentID__c, RFO_Asset__r.RFO_CarType__c, RFO_Asset__r.RFO_CarMark__c,
                                                    RFO_ShopIncidentID__r.RFO_ShopName__c, RFO_ShopIncidentID__r.CDX_Servicing_Railroad__c, RFO_ShopIncidentID__r.RFO_SIStatus__c 
                                                    FROM RFO_ProjectAssetSI__c 
                                                    WHERE RFO_Project__r.RFO_Account__r.Id in :AccIdList
                                                    AND RFO_Project__r.RFO_DemandDriverName__c != 'Reassignment'
                                                    AND RFO_Project__r.RFO_DemandDriverName__c != 'Quote'
                                                    AND CDX_Num_of_Days_Waiting_Disposition__c != 'Not Waiting'
                                                    AND RFO_ShopIncidentID__r.RFO_SIStatus__c  != 'Closed'
                                                    AND Id NOT IN: CaseId
                                                    LIMIT 1000];
            
            for(RFO_ProjectAssetSI__c PASI : PASIList)
            { 
                DispData data = new DispData();
                //data.AssetName = PASI.RFO_Asset__r.RFO_CarType__c+' '+PASI.RFO_Asset__r.RFO_CarMark__c;
                data.AssetName = PASI.Name;
                data.ShopName = PASI.RFO_ShopIncidentID__r.RFO_ShopName__c;
                data.ServicingRailroad = PASI.RFO_ShopIncidentID__r.CDX_Servicing_Railroad__c;
                data.DaysWaiting = PASI.CDX_Num_of_Days_Waiting_Disposition__c;
                data.LinkURL = '/s/project-asset/'+PASI.ID+'/'+System.Label.ProjectAssetDispositionTab;
                DispReturn.add(data);
            }
            
            DispReturn.sort();
            return DispReturn;
        }  
    } 
    
    //Added by MA BETA-190
    static final string ProjectIdAPI = 'ProjectIdAPI';
    static map<Id,Account> accountMap;
    static map<Integer,RFO_Projects__c> projectSOMap;
    static list<weekCls> weekNames;
    static Integer currentWeekNo;
    public class projectDetails {
        @AuraEnabled public Integer projectId;
        @AuraEnabled public Integer CDX_Week;
        //@AuraEnabled public Integer actualCarsReleasedByCustomer;
        //@AuraEnabled public Integer actualCarsShippedByShop;
        //@AuraEnabled public Integer actualCompletedCarsByShop;
        //@AuraEnabled public Integer arrivedCarsToShop;
        @AuraEnabled public Integer customerReleasedCars;
        //@AuraEnabled public Integer projectedArrivalCars;
        //@AuraEnabled public Integer projectedOutCarsByShop;
        
    }
    
    public class projectCls {
        @AuraEnabled public RFO_Projects__c projectSO;
        @AuraEnabled public string Name;
        @AuraEnabled public Integer week0;
        @AuraEnabled public Integer week1;
        @AuraEnabled public Integer week2;
        @AuraEnabled public Integer week3;
        @AuraEnabled public Integer week4;
        @AuraEnabled public Integer weekNth;
        
        public projectCls() {
            week0 = 0;
            week1 = 0;
            week2 = 0;
            week3 = 0;
            week4 = 0;
            weekNth = 0;
        }
         
    }
    public class MainWrapper {
        @AuraEnabled public list<projectCls> projectList;
        @AuraEnabled public list<weekCls> weekList;
        public MainWrapper() {
            projectList = new list<projectCls>();
            weekList = new list<weekCls>();
        }
    }
    
    public class weekCls {
        @AuraEnabled public string weekNo;
        @AuraEnabled public string weekName;
        
    }
    
    //Getting the end point from the Integartion link custom setting
    public static string getEndpoint(string endPointvar) {
        if(RFO_IntegrationLinks__c.getAll().containsKey(endPointvar)) {
            RFO_IntegrationLinks__c apiLink = RFO_IntegrationLinks__c.getValues(endPointvar);
            return apiLink.RFO_APILink__c;
        }
        else {
            return '';
        }
    }
    //Retuns the Project records for the given Account
    public static map<Integer,RFO_Projects__c> getprojectDetails(set<Id> accIds) {
        map<Integer,RFO_Projects__c> projectsMap = new map<Integer, RFO_Projects__c>();
        for(RFO_Projects__c rfo : [SELECT Id,Name,RFO_ProjectId__c 
                                    FROM RFO_Projects__c 
                                    WHERE RFO_Account__c IN : accIds
                                    AND RFO_DemandDriverName__c != 'Reassignment'
                                    AND RFO_Status__c = 'Active']) {
            
            //In order to get the salesforce project Id, using map and storing project external id as key
            projectsMap.put(Integer.valueOf(rfo.RFO_ProjectId__c),rfo);
        }
        return projectsMap;
    }
    //Prepares HTTP request
    public static httpRequest getRequest(string endpoint) {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);
        req.setHeader('x-correlation-id', System.Label.Project_Id_API); //storing the correlation in the custom label
        
        system.debug('end point = '+endpoint);
        req.setEndpoint(endpoint);
        return req;
    }
    //This method is used to get the current week number from custom metadata
    public static Integer getCurrentWeekNo() {
        Integer cWeekNo = 0;
        Date todayDate = system.today();
        weekNames = new list<weekCls>();
        Integer i=0;
        for( TrinityWeek__mdt mdt : [SELECT  WeekID__c, WeekShortName__c  
                                        FROM TrinityWeek__mdt 
                                        WHERE WeekEndDate__c >= : todayDate 
                                        ORDER BY WeekID__c ASC]) {
                                            
            if(cWeekNo == 0) {
                if(!Test.isRunningTest())                      
                    cWeekNo = Integer.valueOf(mdt.WeekID__c);
                else
                    cWeekNo = 100;
            }
            if(i<=5) {
                weekCls w = new weekCls();
                w.weekNo = mdt.WeekShortName__c;
                if(i==0) {
                    w.weekName = 'Current Week';
                }
                else if(i == 5) {
                    w.weekName = 'All Remaining Weeks';
                    w.weekNo = 'All Remaining <br/> Weeks';
                }
                else {
                    w.weekName = 'Current + '+ i;
                }
                weekNames.add(w);
            }
            i++;
        }
        system.debug('weekNames = '+weekNames);
        return cWeekNo;
    }
    //This method process the JSON repsonse and gives the wrapper data
    public static list<projectCls> getProjectData(string bodyStr) {
        map<Integer,projectCls> projectMap = new map<Integer,projectCls>();
        //if the authentication is success, parsing the JSON to list
        list<projectDetails> projectList = (list<projectDetails>)JSON.deserialize(bodyStr, list<projectDetails>.class);
        
        for(projectDetails pd : projectList) {
            projectCls projectVar;
            if(pd.CDX_Week >= currentWeekNo && pd.customerReleasedCars != null && pd.customerReleasedCars > 0) {
                if(projectMap.containsKey(pd.projectId)) {
                    projectVar = projectMap.get(pd.projectId);
                }
                else {
                    if(projectSOMap.containsKey(pd.projectId)) {
                        projectVar = new projectCls();
                        projectVar.projectSO = projectSOMap.get(pd.projectId);   
                        projectVar.Name = projectVar.projectSO.Name.replaceAll('/','').replaceAll('#','');
                        projectMap.put(pd.projectId,projectVar);
                        projectSOMap.remove(pd.projectId);
                    }               
                }
                if(projectVar != null) {
                    if(currentWeekNo == pd.CDX_Week) {
                        projectVar.week0 = pd.customerReleasedCars;
                    }
                    else if((currentWeekNo +1) == pd.CDX_Week) {
                        projectVar.week1 = pd.customerReleasedCars;
                    }
                    else if((currentWeekNo +2) == pd.CDX_Week) {
                        projectVar.week2 = pd.customerReleasedCars;
                    }
                    else if((currentWeekNo +3) == pd.CDX_Week) {
                        projectVar.week3 = pd.customerReleasedCars;
                    }
                    else if((currentWeekNo +4) == pd.CDX_Week) {
                        projectVar.week4 = pd.customerReleasedCars;
                    }
                    else {
                        projectVar.weekNth += pd.customerReleasedCars;
                    }
                }
            }
        }
        return projectMap.values();
    }
    
    public static MainWrapper getProjectList() {
        MainWrapper projectWrap = new MainWrapper();
        try {
            //Getting the logged in user 
            accountMap = new Map<Id,Account>();
            User userSO = [Select Id, contactId,Profile.Name from User where id =: userInfo.getUserId()];
            if(userSO.Profile.Name == 'Customer Operations') {
                for(Account accSO : [SELECT Id,RFO_TASId__c FROM Account 
                                        WHERE Id IN (SELECT AccountId from AccountTeamMember 
                                                        WHERE TeamMemberRole = 'Customer Delivery Manager' 
                                                        AND UserId  =: UserInfo.getUserId())
                                                        AND RFO_TASId__c != null]) {
                    accountMap.put(accSO.Id,accSO);
                }
            }
            else {
                for(Account accSO : [SELECT Id,RFO_TASId__c FROM Account 
                                        WHERE Id IN (SELECT AccountId from AccountContactRelation 
                                                        WHERE ContactId =: userSO.contactId)  
                                                        AND RFO_TASId__c != null]) {
                    accountMap.put(accSO.Id,accSO);
                }
            }
            currentWeekNo = getCurrentWeekNo();
            projectWrap.weekList = weekNames;
            String accountStr='';
            projectSOMap = getprojectDetails(accountMap.keySet());
            Integer i = 0;
            string endpoint = '';
            for(Id accountId : accountMap.keySet()) {
                accountStr += 'accountIds='+accountMap.get(accountId).RFO_TASId__c+'&';
                i++;
                if(math.mod(i, 5) == 0) {
                    accountStr = accountStr.substring(0, accountStr.length() - 1);
                    endpoint = getEndPoint(ProjectIdAPI)+accountStr;
                    HttpRequest req = getRequest(endpoint);            
                    Http http = new Http();
                    HTTPResponse response = http.send(req);
                    system.debug('respone = '+response.getBody());
                    if(response.getStatusCode() == 200) {
                        projectWrap.projectList.addAll(getProjectData(response.getBody()));
                        
                    }
                    accountStr = '';
                }
            }
            if(accountStr != '') {
                accountStr = accountStr.substring(0, accountStr.length() - 1);
                endpoint = getEndPoint(ProjectIdAPI)+accountStr;
                HttpRequest req = getRequest(endpoint);            
                Http http = new Http();
                HTTPResponse response = http.send(req);
                system.debug('respone = '+response.getBody());
                if(response.getStatusCode() == 200) {
                    projectWrap.projectList.addAll(getProjectData(response.getBody()));
                }
            }
        }
        catch(exception e) {
            system.debug('Exception = '+e.getMessage()+' at line no: '+e.getLinenumber());
        }
        return projectWrap;
    }
    //end by MA BETA-190
}