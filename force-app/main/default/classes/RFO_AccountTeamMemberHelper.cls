/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 24 June 2019
* @Description : This class is to Send ATeam info to TAS
*                
**/
public class RFO_AccountTeamMemberHelper {
    /**
* Method to send Account info to TAS
**/
    public static void sendAccountInfoToTAS(Account accountRec, String userLanId, String MoodysRating, String SPRating){
        //AccountTeamMember ATeamRec = [Select id, AccountId, Account.RFO_TASId__c, Account.Owner.Lan_Id__c, Account.RFO_SaleRepStartDate__c, UserId, User.Lan_Id__c, TeamMemberRole from AccountTeamMember where id = : ATeamId];
        Map<Id, Integer> requestsLogDetails;
        String SuccessMessage='';
        RequestBody reqbody = new RequestBody();
        if(accountRec.RFO_TASId__c!=null){
            reqbody.accountId = Integer.valueOf(accountRec.RFO_TASId__c);
        }
        if(accountRec.lastModifiedBy.Lan_Id__c!=null){
        	reqbody.lastModifiedBy = accountRec.lastModifiedBy.Lan_Id__c;
        } 
        else {
            reqbody.lastModifiedBy = accountRec.Owner.Lan_Id__c!=null?accountRec.Owner.Lan_Id__c:'';
        }
        if(MoodysRating!=null){
            reqbody.moodyRating = MoodysRating;
            SuccessMessage += RFO_Constant.ACCOUNT_MOODYS_RATING;
        }
        if(SPRating!=null){
            reqbody.sAndpRating = SPRating;
            SuccessMessage += RFO_Constant.ACCOUNT_SANDP_RATING;
        }
        salesRepresentative salesRep = new salesRepresentative();
        if(userLanId!=null){
            SuccessMessage = RFO_Constant.ACCOUNT_OWNER_CHANGE;
            salesRep.lanId = userLanId;
            salesRep.startDate = (accountRec.RFO_SalesRepStartDate__c).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');//.format('MM/dd/yyyy\'T\' HH:mm:ss','America/New_York'));
            reqbody.salesRepresentative = salesRep;
        }
        String jsonBody = json.serialize(reqbody, true);
        
        Map<Id, Object> messageIdRequest = new Map<Id, Object>();
        messageIdRequest.put(accountRec.Id, reqbody);
        requestsLogDetails = RFO_IntegrationUtility.createLogDetail(  messageIdRequest
                                                                    , RFO_Constant.ACCOUNT_OBJECT
                                                                    , RFO_Constant.R_UPDATE
                                                                    , '.'
                                                                    , RFO_Constant.PUT_METHOD
                                                                    , 'RFO_AccountTeamMemberHelper');
        
        if(reqbody.accountId!=null && reqbody.lastModifiedBy!=null && (userLanId!=null || MoodysRating!=null || SPRating!=null)){
            RFO_SendToTASFutureClass.sendAccountInfoToTASfuture(accountRec.id, jsonBody, String.valueOf(requestsLogDetails.get(accountRec.id)), RFO_Constant.TRIGER, SuccessMessage, '');
        }
        else {
            String Message;
            Message = 'Cannot send Account Info to TAS: Account TASID, LastModifiedBy LanId and Account Owner LanId(if Account owner changed) are required fields.';
            FeedItem post = new FeedItem();
            post.ParentId = accountRec.Id;
            post.Body = Message+'\n'+System.label.RFO_URL_head+accountRec.Id;
            insert post;
        }
    }
    /**
* Method to send Accountteam info to TAS
**/
    public static Map<AccountTeamMember, String> sendAccountTeamInfoToTAS(AccountTeamMember ATeamRec, String Status){
        RequestBody reqbody = new RequestBody();
        Map<Id, Integer> requestsLogDetails;
        String SuccessMessage = RFO_Constant.ACCOUNT_TEAM_MEMBER_MESSAGE;
        Map<AccountTeamMember, String> aTeamNewMap = new Map<AccountTeamMember, String>();
        if(ATeamRec.Account.RFO_TASId__c!=null){
            reqbody.accountId = Integer.valueOf(ATeamRec.Account.RFO_TASId__c);
        }
        if(ATeamRec.Account.lastModifiedBy.Lan_Id__c!=null){
            reqbody.lastModifiedBy = ATeamRec.Account.lastModifiedBy.Lan_Id__c;
        }
        else{
        	reqbody.lastModifiedBy = (ATeamRec.Account.Owner.Lan_Id__c!=null)?ATeamRec.Account.Owner.Lan_Id__c:'';
        }
        if(ATeamRec.TeamMemberRole == RFO_Constant.CUSTOMER_DELIVERY_DIRECTOR){
            reqbody.seniorCustomerServiceManagerId = ATeamRec.User.Lan_Id__c;
        }
        else if(ATeamRec.TeamMemberRole == RFO_Constant.CUSTOMER_DELIVERY_MANAGER){
            reqbody.customerServiceContactId = ATeamRec.User.Lan_Id__c;
        }
        String jsonBody = json.serialize(reqbody,true);
        DateTime dt = System.now();
        Map<Id, Object> messageIdRequest = new Map<Id, Object>();
        messageIdRequest.put(ATeamRec.Id, reqbody);
        
        if(reqbody.accountId!=null && reqbody.lastModifiedBy!=null){
            if(Status==RFO_Constant.BATCH){
            	aTeamNewMap = RFO_GlobalCallOut.sendAccountInfofromTAStoBatch(ATeamRec.AccountId, JsonBody,String.valueOf(dt.getTime()), Status, SuccessMessage, ATeamRec.Id);   
            }
            else if(Status==RFO_Constant.TRIGER){
                RFO_SendToTASFutureClass.sendAccountInfoToTASfuture(ATeamRec.AccountId, JsonBody,String.valueOf(dt.getTime()), Status, SuccessMessage, ATeamRec.Id);
            }
        }
        else{
            FeedItem post = new FeedItem();
            post.ParentId = ATeamRec.AccountId;
            String Message = 'Cannot send AccountTeam Info to TAS, Account TASID and LastModifiedBy LanID(If missed-then Account Owner LanID) are required Fields.';
            post.Body = Message+'\n'+System.label.RFO_URL_head+ATeamRec.AccountId;
            insert post;
        }
        return aTeamNewMap;
    }
    public static void sendAccountTeamToTAS(Set<Id> accountIds) {
        Map<Id, Integer> requestsLogDetails;
        String SuccessMessage='';
        Set<String> tempString = new Set<String>();
        RequestBody reqbody = new RequestBody();
        List<Account> accountWithAteamList = [select id, RFO_TASId__c, lastModifiedBy.Lan_Id__c, OwnerId, Owner.Lan_Id__c, RFO_SalesRepStartDate__c, 
                                              RFO_MoodysRating__c, RFO_SPRating__c, name, 
                                              (Select Id, UserId, User.Lan_Id__c, TeamMemberRole 
                                               from Account.AccountTeamMembers where TeamMemberRole = 'Customer Delivery Director' 
                                               or TeamMemberRole = 'Customer Delivery Manager'
                                               Order by Lastmodifieddate desc) 
                                              from Account where id in :accountIds];
        System.debug('Account with ATeam List'+accountWithAteamList);
        if(!accountWithAteamList.isEmpty()){
            for(Account accountRec: accountWithAteamList){
                SuccessMessage = 'Account Team Info Response:';
                if(accountRec.RFO_TASId__c!=null){
                    reqbody.accountId = Integer.valueOf(accountRec.RFO_TASId__c);
                }
                reqbody.lastModifiedBy = accountRec.Owner.Lan_Id__c;
                if(accountRec.RFO_MoodysRating__c!=null){
                    reqbody.moodyRating = accountRec.RFO_MoodysRating__c;
                }
                if(accountRec.RFO_SPRating__c!=null){
                    reqbody.sAndpRating = accountRec.RFO_SPRating__c;
                }
                salesRepresentative salesRep = new salesRepresentative();
                if(accountRec.OwnerId!=null){
                    salesRep.lanId = accountRec.Owner.Lan_Id__c;
                    salesRep.startDate = (accountRec.RFO_SalesRepStartDate__c).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');//.format('MM/dd/yyyy\'T\' HH:mm:ss','America/New_York'));
                    reqbody.salesRepresentative = salesRep;
                }
                if(!accountRec.AccountTeamMembers.isEmpty()){
                    for(AccountTeamMember aTeamRec : accountRec.AccountTeamMembers){
                        System.debug('Updated Account Related AccountTeamMembers:'+aTeamRec);
                        
                        if(aTeamRec.TeamMemberRole == RFO_Constant.CUSTOMER_DELIVERY_DIRECTOR && (!tempString.contains(RFO_Constant.CUSTOMER_DELIVERY_DIRECTOR))){
                            reqbody.seniorCustomerServiceManagerId = aTeamRec.User.Lan_Id__c;
                            tempString.add(RFO_Constant.CUSTOMER_DELIVERY_DIRECTOR);
                        }
                        else if(aTeamRec.TeamMemberRole == RFO_Constant.CUSTOMER_DELIVERY_MANAGER && (!tempString.contains(RFO_Constant.CUSTOMER_DELIVERY_MANAGER))){
                            reqbody.customerServiceContactId = aTeamRec.User.Lan_Id__c;
                            tempString.add(RFO_Constant.CUSTOMER_DELIVERY_MANAGER);
                        }
                        System.debug('temp String:'+tempString);
                    }
                }
                System.debug('Request Payload'+reqbody);
                String jsonBody = json.serialize(reqbody, true);
                
                Map<Id, Object> messageIdRequest = new Map<Id, Object>();
                Id accId = accountRec.Id;
                messageIdRequest.put(accId, reqbody);
                requestsLogDetails = RFO_IntegrationUtility.createLogDetail(  messageIdRequest
                                                                            , RFO_Constant.ACCOUNT_OBJECT
                                                                            , RFO_Constant.R_UPDATE
                                                                            , '.'
                                                                            , RFO_Constant.PUT_METHOD
                                                                            , 'RFO_AccountTeamMemberHelper');
                DateTime dt = System.now();
                if(reqbody.accountId!=null && reqbody.lastModifiedBy!=null){
                    RFO_SendToTASFutureClass.sendAccountInfoToTASfuture(accountRec.id, jsonBody, String.valueOf(requestsLogDetails.get(accountRec.id)), RFO_Constant.TRIGER, SuccessMessage, '');
                }
                else{
                    FeedItem post = new FeedItem();
                    post.ParentId = accountRec.Id;
                    String Message = 'Cannot send AccountTeam Info to TAS, Account TASID and LastModifiedBy LanID are required Fields.';
                    post.Body = Message+'\n'+System.label.RFO_URL_head+accountRec.Id;
                    insert post;
                }
            }
        }
    }    
    /**
* Wrapper Class
**/
    public class RequestBody{
        
        public integer accountId;
        public string seniorCustomerServiceManagerId;
        public string customerServiceContactId;
        public string moodyRating;
        public string sAndpRating;
        public String lastModifiedBy;
        public RFO_AccountTeamMemberHelper.salesRepresentative salesRepresentative;        
    }
    /**
* Wrapper Class
**/
    public class salesRepresentative{
        public string lanId;
        public String startDate;
    }
    
    /*
     * This method is used to throw a validation message on Account Team when a user is trying to create a record with same role
     * */
    public static void aTeamRestriction(List<AccountTeamMember> newItems, Map<Id, SObject> oldMap){
        Set<Id> accountSet = new Set<Id>();
        Set<Id> accountNewSet = new Set<Id>();
        Map<Id, List<String>> aTeamMap = new Map<Id, List<String>>();
        Map<Id, String> aTeamNewMap = new Map<Id, String>();
        List<String> tempString = new List<String>();
        Map<Id,List<AccountTeamMember>> aTeamNewMap1 = new Map<Id, List<AccountTeamMember>>();
        for(AccountTeamMember accountTeam : newItems){
            if((oldMap!=null && accountTeam.TeamMemberRole!=oldMap.get(accountTeam.Id).get('TeamMemberRole')) || Trigger.isInsert){
                accountSet.add(accountTeam.AccountId);
                if(!tempString.isEmpty() && tempString.contains(accountTeam.TeamMemberRole)){
                	accountTeam.addError(accountTeam.TeamMemberRole+' is already assigned to a Team Member. please choose other role or delete the existing Team Member');
            	}
            	tempString.add(accountTeam.TeamMemberRole);
            }
            else if(Trigger.isUpdate){
                accountNewSet.add(accountTeam.AccountId);
            }
        }
        if((!accountSet.isEmpty()) && accountSet.size()>0){
            List<AccountTeamMember> aTeamList = [Select id, TeamMemberRole, AccountId, UserId from AccountTeamMember where AccountId in :accountSet limit 49999];
            if(aTeamList.size()>=1){
                for(AccountTeamMember aTeam : aTeamList){
                    if(aTeamMap.containsKey(aTeam.AccountId)){
                        List<String> temp = aTeamMap.get(aTeam.AccountId);
                        temp.add(aTeam.TeamMemberRole);
                        aTeamMap.put(aTeam.AccountId, temp);
                    }
                    else{
                        aTeamMap.put(aTeam.AccountId, new List<String>{aTeam.TeamMemberRole});
                    }
                }                
            }
            if(!aTeamMap.isEmpty()){
                for(AccountTeamMember accountTeam : newItems){
                    if(aTeamMap.containsKey(accountTeam.AccountId)){
                        for(String teamMemberRole: aTeamMap.get(accountTeam.AccountId)){
                            if(accountTeam.TeamMemberRole == teamMemberRole ){
                                   accountTeam.addError(teamMemberRole+' is already assigned to a Team Member. please choose other role or delete the existing Team Member');
                               }
                        }
                    }
                }
            }
        }
        
        if(!accountNewSet.isEmpty()){
            List<AccountTeamMember> aTeamList = [Select id, TeamMemberRole, AccountId, UserId from AccountTeamMember where AccountId in :accountNewSet limit 49999];
            if(aTeamList.size()>1){
                for(AccountTeamMember aTeam : aTeamList){
                    if(aTeamNewMap1.containsKey(aTeam.AccountId)){
                        List<AccountTeamMember> temp = aTeamNewMap1.get(aTeam.AccountId);
                        temp.add(aTeam);
                        aTeamNewMap1.put(aTeam.AccountId, temp);
                    }
                    else{
                        aTeamNewMap1.put(aTeam.AccountId, new List<AccountTeamMember>{aTeam});
                    }
                }                
            }
            for(AccountTeamMember aTeam : newItems){
                if(aTeamNewMap1.containsKey(aTeam.AccountId)){
                    for(AccountTeamMember aTeamRec : aTeamNewMap1.get(aTeam.AccountId)){
                        if(aTeamRec.TeamMemberRole==aTeam.TeamMemberRole && aTeam.Id !=aTeamRec.Id){
                            aTeam.addError(aTeam.teamMemberRole+' is already assigned to a Team Member. please choose other role or delete the existing Team Member');
                        }
                    }
                }
            }
        }
    }
    
    // Alpha: 165 Start 
    /*
     * @Author      : Ramesh Guguloth
     * @Created Date: 6/11/2020
     * @Description : This method is used to Update CDM Value on Account
     * */
    public static void updateCDMUser(List<AccountTeamMember> newItems, map<id,AccountTeamMember> oldItems){
        List<Account> lstAcc = new List<Account>();
        Account acc = new Account();
        
        // Looping Account team member
        for(AccountTeamMember aTeam : newItems){
            // intializing account
            acc = new Account();
            // Checking criteria... if role is CDM
            if(aTeam.TeamMemberRole == RFO_Constant.Account_Member_Role_CDM){
                if(acc.id != aTeam.AccountId){
                    // Assiging Values to Account Record
                    acc.id= aTeam.AccountId;
                    acc.Customer_Delivery_Manager__c = aTeam.UserId;
                    
                    // Adding account to list for mass update
                    lstAcc.add(acc);
                }
            }
            else if(oldItems.get(aTeam.Id).TeamMemberRole != aTeam.TeamMemberRole ){
                acc.id = aTeam.AccountId;
                acc.Customer_Delivery_Manager__c = null;
                // Adding account to list for mass update
                lstAcc.add(acc);
            }
        }
        
        // Checking list is not null
        if(lstAcc.size() > 0){
            // Updating the Account list
            update lstAcc;
        }
    }
     public static void afterInsertUpdateCDMUser(List<AccountTeamMember> newItems){
        List<Account> lstAcc = new List<Account>();
        Account acc = new Account();
        
        // Looping Account team member
        for(AccountTeamMember aTeam : newItems){
            // intializing account
            acc = new Account();
            // Checking criteria... if role is CDM
            if(aTeam.TeamMemberRole == RFO_Constant.Account_Member_Role_CDM){
                // Assiging Values to Account Record
                acc.id= aTeam.AccountId;
                acc.Customer_Delivery_Manager__c = aTeam.UserId;
                
                // Adding account to list for mass update
                lstAcc.add(acc);
            }
        }
        
        // Checking list is not null
        if(lstAcc.size() > 0){
            // Updating the Account list
            update lstAcc;
        }

     }
    public static void afterDeleteUpdateCDMUser(List<AccountTeamMember> oldItems){
        List<Account> lstAcc = new List<Account>();
        Account acc = new Account();
        
        // Looping Account team member
        for(AccountTeamMember aTeam : oldItems){
            // intializing account
            acc = new Account();
            // Checking criteria... if role is CDM
            if(aTeam.TeamMemberRole == RFO_Constant.Account_Member_Role_CDM){
                // Assiging Values to Account Record
                acc.id= aTeam.AccountId;
                acc.Customer_Delivery_Manager__c = null;
                
                // Adding account to list for mass update
                lstAcc.add(acc);
            }
        }
        
        // Checking list is not null
        if(lstAcc.size() > 0){
            // Updating the Account list
            update lstAcc;
        }
        // Alpha: 165 End 
    }
}