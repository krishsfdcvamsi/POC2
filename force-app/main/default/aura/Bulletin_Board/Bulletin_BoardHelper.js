({
    doInit : function(component,event) {
        var action = component.get("c.getBulletinPoints");
        //action.setParams();
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            var announcements = [];
            var enhancements = [];
            resp.forEach(function(item) {
                if(item.URL_Link__c && !item.URL_Link__c.includes('http')){
                    item.URL_Link__c = 'http://' + item.URL_Link__c;
                    //item.URL_Link__c =  item.URL_Link__c;
                }
                else{
                    item.URL_Link__c = item.URL_Link__c.includes('http') ? item.URL_Link__c : '';
                    //item.URL_Link__c = 'https://' + item.URL_Link__c;
                }
                if(item.RecordType.Name == 'CD Announcement'){
                    announcements.push(item);
                }
                else{
                    enhancements.push(item);
                }
            });
            component.set('v.announcements', announcements);      
            component.set('v.enhancements', enhancements);
        });
        $A.enqueueAction(action);
    }
    
})