public without sharing class RFO_LeadTriggerHandler {
    
    public static final string LEAD_NOTIFY = 'Inside_Sales_Team_Notification_Lead';
    public static final string INSIDE_SALES = 'Inside_Sales_30';
    public static final string SALES_TEAM = 'Inside Sales Team';
    
    public static void postToChatter(set<id> leadIds) { 
        CollaborationGroup cGroup;
        List<FeedItem> FeedItemList = New List<FeedItem>();
        try {
            cGroup = [SELECT Id,Name From CollaborationGroup WHERE name =: SALES_TEAM];
        }
        catch(exception e) {
            cGroup = null;
        }
        if(cGroup != null) {
            for(Id leadid : leadIds) {
                FeedItem post = new FeedItem();
                post.ParentId = cGroup.Id;
                post.Body = 'A new sales team lead is created.';
                post.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/'+ leadId;
                FeedItemList.add(post);
            }
            if(FeedItemList.size() > 0) {         
                insert FeedItemList;                
            }
        }
    }
    
    @future (callout=true)
    public static void customNotification(set<id> leadIds) { 
    
        map<string,list<NotificationClass>> listDataMap = new map<string,list<NotificationClass>>();        
        map<id,user> userMap = new map<id,user>([SELECT Id from user where userRole.developername =: INSIDE_SALES]);
        CustomNotificationType cType;
        try {
            cType = [Select Id from CustomNotificationType where developername =: LEAD_NOTIFY];
        }
        catch(exception e) {
            cType = null;
        }
        if(cType != null && !userMap.isEmpty()) {
            
            list<NotificationClass> inputs = new list<NotificationClass>();
            set<id> userIds = new set<id>(userMap.keySet());
            if(userIds.contains(userInfo.getUserId()))
                userIds.remove(userInfo.getUserId());
            for(Lead leadSO : [SELECT Id,lastName,Company FROM Lead WHERE Id IN : leadIds]) {
                
                NotificationClass inputSO = new NotificationClass();
                inputSO.customNotifTypeId = cType.Id;
                inputSO.recipientIds = userIds;
                inputSO.body = 'A new sales team lead is created.';
                inputSO.title = leadSO.LastName+', '+leadSO.Company;
                inputSO.targetId = leadSO.Id;
                inputs.add(inputSO);
            }
            listDataMap.put('inputs',inputs);
            string endPointStr = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v49.0/actions/standard/customNotificationAction';
            string bodyStr = JSON.serialize(listDataMap, true);
            system.debug('@@JSOn = '+JSON.serialize(listDataMap, true));
            HttpRequest request = new HttpRequest();
            Http httpAPI = new Http();
            HttpResponse response = new HttpResponse();
            request.setEndpoint(endPointStr);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + userInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setBody(bodyStr);
            if(!Test.isRunningTest())
                response = httpAPI.send(request);
        }
        
        
    }
    
    public class NotificationClass {
        public id customNotifTypeId;
        public set<Id> recipientIds;
        public string  title;
        public string body;
        public id targetId;
    }
}