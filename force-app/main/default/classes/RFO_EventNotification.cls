/*
Author Name   : I. Martinez
Created Date  : July 27, 2019 
Description   : Wrapper class used by the RFO_ContractSync lightning component to sync the Contract record with TAS

History
*
* 27JUL2019 | I Martinez | US:38.03.09 | Initial version used to sync Contract records with TAS
*/
public inherited sharing class RFO_EventNotification {
    private List<Notification__e> notifications = new List<Notification__e>();
    private List<Id> recipientIds;
    private String notificationmessage;
    private String notificationType;
    private String notificationTitle;
    private String notificationEvent;
    private String notificationRecipientId;
    private String notificationRecordId;

    /* Constructor */
    public RFO_EventNotification() {

    }

    /* RFO_EventNotification */
    public RFO_EventNotification message(String message) {
        //force:showToast.message
        this.notificationmessage = message;
        return this;
    }

    /* RFO_EventNotification: notificationType setter */
    public RFO_EventNotification type(String type) {
        //force:showToast.type: The toast type, which can be 'error', 'warning', 'success', or 'info'. The default is 'other'.
        this.notificationType = type;
        return this;
    }

    /* RFO_EventNotification: notificationTitle setter */
    public RFO_EventNotification title(String title) {
        //force:showToast.title
        this.notificationTitle = title;
        return this;
    }

    /* RFO_EventNotification: notificationRecipientId setter */
    public RFO_EventNotification sendToCurrentUser() {
        this.notificationRecipientId = UserInfo.getUserId();
        return this;
    }

    /* RFO_EventNotification: notificationEvent setter */
    public RFO_EventNotification event(String event) {
        this.notificationEvent = event;
        return this;
    }

    // public RFO_EventNotification recipientId(String recipientId) {
    //     this.notificationRecipientId = recipientId;
    //     return this;
    // }

    /* RFO_EventNotification: notificationRecordId setter */
    public RFO_EventNotification recordId(String recordId) {
        this.notificationRecordId = recordId;
        return this;
    }

    /* RFO_EventNotification: Adds notification to the list to be inserted */
    public RFO_EventNotification addNotification() {
        this.notifications.add(new Notification__e(RFO_Message__c = this.notificationmessage
                                                    , RFO_Type__c = this.notificationType
                                                   , RFO_Title__c = this.notificationTitle
                                                   , RFO_Event__c = this.notificationEvent 
                                                   , RFO_RecipientId__c = this.notificationRecipientId
                                                   , RFO_RecordId__c = this.notificationRecordId));
        return this;
    }

    /* RFO_EventNotification: Publishes notifications */
    public RFO_EventNotification publishNotificationEvent(){
        if (this.notifications.size()>0) {
            List<Database.SaveResult> results = EventBus.publish(this.notifications);
            // Inspect publishing results
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    for (Database.Error error : result.getErrors()) {
                        System.debug('Error returned: ' + error.getStatusCode() +' - '+ error.getMessage());
                    }
                }
            }
            this.notifications.clear();
        }
        return this;
    }
}