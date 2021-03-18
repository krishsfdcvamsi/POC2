/***************************************
 * Created By: Madhava Allamm
 * Created Date: September 2020
 * Jira: Alpha-552
 * 
 **************************************/

public class ORM_NotesController {

    @AuraEnabled
    public static OrmWrapper getORMData(string recordId, string type) {
        OrmWrapper ormVar = new OrmWrapper();
        ORM__c ormSO;
        list<Order> orderSO = [SELECT Id,RFO_CommodityName__c,Type,RFO_Quantity__c,RFO_Product__r.Name,
                                RecordType.Name,RFO_RANumber__c,AccountId,RFO_OrderReviewMeetingDate__c,RFO_Internal_Order_Review_Meeting_Date__c
                                FROM Order WHERE Id =: recordId];
        list<AccountTeamMember> accountTMSO = [Select Id,TeamMemberRole,UserId from AccountTeamMember where AccountId =: orderSO[0].AccountId and 
                                               TeamMemberRole = 'Customer Delivery Manager'];                    
        list<RFO_Asset_File__c> assetList = [SELECT Id,Name FROM RFO_Asset_File__c where RFO_OrderNumber__c =: recordId];
        system.debug('@--'+assetList);
        if(orderSO != null && orderSO.size() > 0) {
            
            ormSO = getORM(recordId, type);
            
            if(ormSO != null) {
                ormVar.orm = ormSO;
                ormVar.actionItemList = getActionItems(ormSO.Id);
                ormVar.ORMTasks = getORMTasks(ormSO.Id);
                ormVar.selectedAssetFileNumber = orderSO[0].RecordType.Name == 'Existing Car'? orderSO[0].RFO_RANumber__c : ormSO.File_Number_Txt__c;
                ormVar.selectedServiceType = ormSO.Service_Type__c;
                set<string> serviceTypes = new set<string>();
                serviceTypes.add(ormSO.Service_Type__c);
                serviceTypes.add('Storage');
                serviceTypes.add('Service to Service');
                serviceTypes.add('Shop');
                ormVar.serviceType = serviceTypes;
            }
            else {
                system.debug('@--- '+type);
                ormSO = new ORM__c();
                ormSO.Commodity_Txt__c = orderSO[0].RFO_CommodityName__c;
                ormSO.Car_Type_Txt__c = orderSO[0].RFO_Product__r.Name;
                ormSO.Order_Type__c = orderSO[0].Type;
                ormSO.Quantity__c = orderSO[0].RFO_Quantity__c;
                ormSO.Date__c = System.today();
                ormSO.Order__c = orderSO[0].Id;
                ormSO.Type__c = type == 'External ORM' ? 'ORM Meeting Notes' : 'Internal ORM';
                ormSO.Order_Record_Type__c = orderSO[0].RecordType.Name;
                ormSO.File_Number_Txt__c = assetList.size() > 0 ? assetList[0].Name : null;
                ormSO.Revised_By__c = accountTMSO.size()>0 ? accountTMSO[0].userId : null;
                ormSO.Revised_Date__c = orderSO[0].RecordType.Name == 'Existing Car'? orderSO[0].RFO_OrderReviewMeetingDate__c: orderSO[0].RFO_Internal_Order_Review_Meeting_Date__c;
                ormVar.orm = ormSO;
                ormVar.actionItemList = new list<Action_Item__c>();
                ormVar.ORMTasks = new list<Task>();
                set<string> serviceTypes = new set<string>();
                
                serviceTypes.add('Storage');
                serviceTypes.add('Service to Service');
                serviceTypes.add('Shop');
                ormVar.serviceType = serviceTypes;
            }
            if(orderSO[0].RecordType.Name == 'Existing Car'){
                ormVar.selectedAssetFileNumber = orderSO[0].RFO_RANumber__c;
                set<string> fileList = new set<string>();
                fileList.add(orderSO[0].RFO_RANumber__c);
                ormVar.fileList = fileList;
            }
            
            if(assetList != null && assetList.size() > 0) {
                set<string> fileList = new set<string>();
                fileList.add(ormSO.File_Number_Txt__c);
                for(RFO_Asset_File__c assetSO : assetList) {
                    if(assetSO.Name != null) {
                        fileList.add(assetSO.Name);
                    }
                }
                ormVar.fileList = fileList;
            }
        }
        return ormVar;
    }
    
    public static ORM__c getORM(String recordId, String type) {
        try {
            return [SELECT Id,Are_there_quantity_limitations__c,Are_you_a_member_of_Chemtrec__c,Car_Type_Txt__c,
                    Change_order_required__c,Changes_from_quote__c,Commencing_Date__c,Commodity_Txt__c,Communication_Cadence__c,
                    Customer__c,Customer_Comments__c,Date__c,Date_Minutes_Issued__c,Description__c,Do_you_have_specific_customs_broker__c,
                    Engineering_Approved_By__c,Engineering_Approved_By__r.Name,Engineering_Approved_Date__c,File_Number_Txt__c,Is_a_sample_car_required__c,
                    Lining_form_completed__c,Location_Address__c,Order__c,Order_Record_Type__c,Order_Type__c,Payor_of_freight__c,
                    Portfolio_Management__c,Portfolio_Management__r.Name,Portfolio_Management_Date__c,Prepared_By__c,Prepared_By_User__c,Prepared_Date__c,Quantity__c,
                    Prepared_By_User__r.Name,Revised_By__c,Revised_By__r.Name,Revised_Date__c,Routing__c,Shop__c,Shop_Comments__c,Trinity_Rail_Users__c,Type__c,
                    Who_will_be_completing_the_OT_57_app__c,Will_Chemtrec_decals_or_similar_beneeded__c,World_Petroleum_Corp_Contacts__c,
                    Do_you_need_any_commodity_or_lessee_sten__c,Comments__c, Contacts_Name__c, User_Names__c,Additional_Attendees__c,Service_Type__c
                    FROM ORM__c WHERE Order__c =: recordId ];//AND Type__c =: type == 'External ORM' ? 'ORM Meeting Notes' : 'Internal ORM'];
        }
        catch(exception e) {
            return null;
        }
    }
    
    public static list<Action_Item__c> getActionItems(string ormId) {
        return [SELECT Id,Name,Change_Analysis__c,Description__c,Due_Date__c,ORM_Note__c,Responsible_Party__c,Responsible_Party__r.Name,Status__c 
                FROM Action_Item__c WHERE ORM_Note__c =: ormId];
    }
    
    public static list<task> getORMTasks(string ormId) {
        return [Select id,status,ownerId,owner.Name,description,activityDate,type,whatId,Subject,change_analysis__c from task where whatId =: ormId];
    }
    
    @AuraEnabled
    public static void updateORM(string ormJSON, boolean enableEmail) {
        system.debug('@---ormJSON = '+ormJSON);
        list<Action_Item__c> actionItemList = new list<Action_Item__c>();
        list<Task> taskList = new list<Task>();
        OrmWrapper oramData = (OrmWrapper)JSON.deserialize(ormJSON, OrmWrapper.class);
        
        ORM__c ormSO = oramData.orm;
        list<Contact> contactNames = [Select Name from contact where id in:ormSO.World_Petroleum_Corp_Contacts__c.split(',')];
        String[] contactNamesList = new list<string>();
        list<User> userNames = [Select Name from user where id in:ormSO.Trinity_Rail_Users__c.split(',')];
        String[] userNamesList = new list<string>();
        for(Contact c : contactNames){
            contactNamesList.add(c.Name);
        }
        for(User u: userNames){
            userNamesList.add(u.Name);
        }
        ormSO.Contacts_Name__c = string.join(contactNamesList,', ');
        ormSO.User_Names__c = string.join(userNamesList,', ');
        upsert ormSO;
        list<Action_Item__c> actionItemListDelete = new list<Action_Item__c>();
        list<task> tasksToDelete = new list<task>();
        map<id,Action_Item__c> actionItemsMapNew = new map<id,Action_Item__c>();
        map<id,Action_Item__c> actionItemsMapExisting = new map<id,Action_Item__c>(getActionItems(ormSO.Id));
        map<id,task> mapNewTask = new map<id,task>();
        map<id,task> mapTaskExisting = new map<id,task>(getORMTasks(ormSO.Id));
        string taskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task').getRecordTypeId();
        
        if(oramData.actionItemList != null && oramData.actionItemList.size()>0) {
            for(Action_Item__c actionSO : oramData.actionItemList) {
                actionItemsMapNew.put(actionSO.Id,actionSO);
                System.debug('~~~ Responsible Party: '+actionSO.Responsible_Party__c);
                if(actionSO.ORM_Note__c == null) 
                    actionSO.ORM_Note__c = ormSO.Id;
                actionSO.Status__c = actionSO.Status__c;
                actionItemList.add(actionSO);
            }
            if(!actionItemList.isEmpty()) {
                upsert actionItemList;
            }
        }
        
        if(oramData.ORMTasks != null && oramData.ORMTasks.size()>0){
            for(task t : oramData.ORMTasks){
                mapNewTask.put(t.Id, t);
                if(t.OwnerId != null && t.Subject != '' ){
                    t.WhatId = ormSO.Id;
                    t.Type = 'Other';
                    t.status = t.Status == null || t.Status == '' ? 'Not Started' : t.Status;
                    t.RecordTypeId = taskRecordType;
                    taskList.add(t);
                }
            }
            if(taskList.size()>0)
            	upsert taskList;
        }
        for(Action_Item__c ai : actionItemsMapExisting.values()){
            if(!actionItemsMapNew.containsKey(ai.Id))
                actionItemListDelete.add(ai);
        }
        for(task t : mapTaskExisting.values()){
            if(!mapNewTask.containsKey(t.Id))
                tasksToDelete.add(t);
        }
        if(tasksToDelete.size()>0)
            delete tasksToDelete;
        if(actionItemListDelete.size()>0)
            delete actionItemListDelete;
        if(enableEmail) {
            sendEmail(oramData);
        }
        
    }
    
    public static Task createTask(Action_Item__c actionSO) {
        Task taskSO = new Task();
        taskSO.ActivityDate = actionSO.Due_Date__c;
        taskSO.Subject = 'ORM Action';
        taskSO.Type = 'Task';
        taskSO.WhatId = actionSO.ORM_Note__c;
        taskSO.OwnerId = actionSO.Responsible_Party__c;
        taskSO.Status = 'Not Started';
        taskSO.Description = actionSO.Description__c;
        return taskSO;
        
        
    }
    
    @AuraEnabled
    public static void sendEmail(ormWrapper ormVar) {

        set<string> userIds = new set<string>();
        userIds.add(ormVar.orm.Revised_By__c);
        userIds.add(ormVar.orm.Prepared_By__c);
        userIds.add(ormVar.orm.Prepared_By_User__c);
        userIds.add(ormVar.orm.Engineering_Approved_By__c);
        userIds.add(ormVar.orm.Portfolio_Management__c);

        for(Action_Item__c  ai : ormVar.actionItemList) {
            userIds.add(ai.Responsible_Party__c);
        }
        for(task  ai : ormVar.ORMTasks) {
            userIds.add(ai.OwnerId);
        }

        map<string,string> userMap = new map<string,string>();
        list<string> e =  new list<string>();
        for(user usr : [SELECT Id,name,email FROM User WHERE Id IN : userIds]) {
            userMap.put(usr.Id,usr.Name);
            e.add(usr.email);
        }
        

        string mSubject = 'ORM Notes';
        string mbody = '';
        mbody = '<html><head><style>'
                +'th {background-color: #dddddd;border: 1px solid #dddddd}'
                +'</style></head>'
                +'<body style="width:80%;border: 1px solid #dddddd; padding:10px;"><table style="font-family: arial, sans-serif;border-collapse: collapse;width: 100%;">'
                    +'<tr>'
                        +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'
                            +'Date : '+ormVar.orm.Date__c
                        +'</td>'
                        +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'
                            +'Revised By : '+(userMap.containsKey(ormVar.orm.Revised_By__c) ? userMap.get(ormVar.orm.Revised_By__c) : '')+
                        +'</td>'
                        +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'
                            +'Revised Date : '+ormVar.orm.Revised_Date__c
                        +'</td>'
                    +'</tr>'

                    +'<tr>'
                        +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'
                            +'File Number : '+ormVar.orm.File_Number_Txt__c
                        +'</td>'
                        +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'
                            +'Commodity : '+ormVar.orm.Commodity_Txt__c
                        +'</td>'
                        +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'
                            +'Type : '+ormVar.orm.Type__c
                        +'</td>'
                    +'</tr>'

                    +'<tr>'
                        +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'
                            +'Order Type : '+ormVar.orm.Order_Type__c
                        +'</td>'
                        +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'
                            +'Quantity : '+ormVar.orm.Quantity__c
                        +'</td>'
                        +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'
                            +'Car Type : '+ormVar.orm.Car_Type_Txt__c
                        +'</td>'
                    +'</tr>'
            
            		+'<tr>'
           				 +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'
                            +'Service Type : '+ormVar.orm.Service_Type__c
            			 +'</td>'
            		 +'</tr>'
                +'</table>'
                +'<br/><div style="background-color: #dddddd;padding: 5px;">Customer Action Items</div><br/>'
                +'<table style="border-collapse: collapse;width: 100%;">'
                    +'<tr>'
                        +'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Description of The Change / Follow Up</th>'
                        //+'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Change Analysis</th>'
                        +'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Responsible Party</th>'
                        +'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Due Date</th>'
                        +'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Status</th>'
                    +'</tr>';
        string tableStr='';    
            for(Action_Item__c  ai : ormVar.actionItemList) {
                mbody += '<tr>'
                            +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+ai.Description__c+'</td>'
                            //+'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+ai.Change_Analysis__c+'</td>'
                            +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+(userMap.containsKey(ai.Responsible_Party__c) ? userMap.get(ai.Responsible_Party__c) : '')+'</td>'
                            +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+ai.Due_Date__c+'</td>'
                            +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+ai.Status__c+'</td>'
                        +'</tr>';
            }
        //~~~~~~~~
        mbody += +'</table><br/><div style="background-color: #dddddd;padding: 5px;">Trinity Action Items</div><br/>'
                +'<table style="border-collapse: collapse;width: 100%;">'
                    +'<tr>'
                        +'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Description/Comments</th>'
            			+'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Change Analysis</th>'
                        +'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Subject</th>'
                        +'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Assigned To</th>'
                        +'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Due Date</th>'
                        +'<th style="border: 1px solid #dddddd;text-align: left;padding: 4px;">Status</th>'
                    +'</tr>';
        string tableStr1='';    
            for(task  ai : ormVar.ORMTasks) {
                mbody += '<tr>'
                            +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+ai.Description+'</td>'
                    		+'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+ai.Change_Analysis__c+'</td>'
                            +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+ai.Subject+'</td>'
                            +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+(userMap.containsKey(ai.OwnerId) ? userMap.get(ai.OwnerId) : '')+'</td>'
                            +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+ai.ActivityDate+'</td>'
                            +'<td style="border: 1px solid #dddddd;text-align: left;padding: 4px;">'+ai.Status+'</td>'
                        +'</tr>';
            }

        //~~~~~

        mbody +=    +'</table>'
                    +'<br/><br/>'
                    +'<table style="width:70% !important">'
                        +'<tr style="height: 5px; !important">'
                            +'<td >Date Minute Issued : </td>'
                            +'<td >';
                            if(ormVar.orm.Date_Minutes_Issued__c != null) {
                                mbody += ormVar.orm.Date_Minutes_Issued__c+'</td>';
                            }
                            else {
                                mbody += '</td>';
                            }
                            
        mbody +=        '</tr>'
                        +'<tr >'
                            +'<td >Changes from quote? : </td>'
                            +'<td >'+ormVar.orm.Changes_from_quote__c+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >Change order required? : </td>'
                            +'<td >'+ormVar.orm.Change_order_required__c+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >Commencing Date : </td>'
                            +'<td >';
                            if(ormVar.orm.Commencing_Date__c != null) {
                                mbody += ormVar.orm.Commencing_Date__c+'</td>';
                            }
                            else {
                                mbody += '</td>';
                            }
         mbody +=       '</tr>'
                        +'<tr >'
                            +'<td >Customer : </td>'
                            +'<td >'+ormVar.orm.Customer__c+'</td>'
                            +'<td >Comments : </td>'
                            +'<td >'+(ormVar.orm.Customer_Comments__c != null ? ormVar.orm.Customer_Comments__c : '')+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >Shop : </td>'
                            +'<td >'+ormVar.orm.Shop__c+'</td>'
                            +'<td >Comments : </td>'
                            +'<td >'+(ormVar.orm.Shop_Comments__c !=null ? ormVar.orm.Shop_Comments__c : '')+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >Prepared By : </td>'
                            +'<td >'+(userMap.containsKey(ormVar.orm.Prepared_By_User__c) ? userMap.get(ormVar.orm.Prepared_By_User__c) : '')+'</td>'
                            +'<td >Date : </td>'
                            +'<td >';
                            if(ormVar.orm.Prepared_Date__c != null) {
                                mbody += ormVar.orm.Prepared_Date__c +'</td>';
                            }
                            else {
                                mbody += '</td>';
                            }
        mbody +=        '</tr>'
                        +'<tr >'
                            +'<td >Engineering Approved By : </td>'
                            +'<td >'+(userMap.containsKey(ormVar.orm.Engineering_Approved_By__c) ? userMap.get(ormVar.orm.Engineering_Approved_By__c) : '')+'</td>'
                            +'<td >Date : </td>'
                            +'<td >';
                            if(ormVar.orm.Engineering_Approved_Date__c != null) {
                                mbody += ormVar.orm.Engineering_Approved_Date__c+'</td>';
                            }
                            else {
                                mbody += '</td>';
                            }
        mbody +=        '</tr>'
                        +'<tr >'
                            +'<td >Portfolio Management : </td>'
                            +'<td >'+(userMap.containsKey(ormVar.orm.Portfolio_Management__c) ? userMap.get(ormVar.orm.Portfolio_Management__c) : '')+'</td>'
                            +'<td >Date : </td>'
                            +'<td >';
                            if(ormVar.orm.Portfolio_Management_Date__c != null) {
                                mbody += ormVar.orm.Portfolio_Management_Date__c +'</td>';
                            }
                            else {
                                mbody += '</td>';
                            }
        //~~~~
        mbody += +'</tr><tr><td>Comments: </td>'
            	 +'<td>'+ormVar.orm.Comments__c+'</td>';
        //~~~
                            
        mbody +=    '</tr>'
                    +'</table>'
                    +'<br/><div style="background-color: #dddddd;padding: 5px;">Additional Questions to be included in the meeting template</div><br/>'
                    +'<table style="width:70% !important">'
                        +'<tr style="height: 5px; !important">'
                            +'<td >1. Do you need any commodity or lessee stencils on the cars? : </td>'
                            +'<td >'+(ormVar.orm.Do_you_need_any_commodity_or_lessee_sten__c != null ? ormVar.orm.Do_you_need_any_commodity_or_lessee_sten__c : '')+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >2. Will Chemtrec decals (or similar) be needed? : </td>'
                            +'<td >'+(ormVar.orm.Will_Chemtrec_decals_or_similar_beneeded__c != null ? ormVar.orm.Will_Chemtrec_decals_or_similar_beneeded__c : '')+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >3. What are the disposition instructions : </td>'
                            
                        +'</tr>'
                        +'<tr >'
                            +'<td >- Location Address : </td>'
                            +'<td >'+(ormVar.orm.Location_Address__c != null ? ormVar.orm.Location_Address__c : '')+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >- Routing : </td>'
                            +'<td >'+(ormVar.orm.Routing__c != null ? ormVar.orm.Routing__c : '')+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >- Payor of freight : </td>'
                            +'<td >'+(ormVar.orm.Payor_of_freight__c != null ? ormVar.orm.Payor_of_freight__c : '')+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >4. Are there quantity limitations : </td>'
                            +'<td >'+(ormVar.orm.Are_there_quantity_limitations__c != null ? ormVar.orm.Are_there_quantity_limitations__c : '')+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >5. Is a sample car required? : </td>'
                            +'<td >'+(ormVar.orm.Is_a_sample_car_required__c != null ? ormVar.orm.Is_a_sample_car_required__c : false)+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >6. Lining form completed? : </td>'
                            +'<td >'+(ormVar.orm.Lining_form_completed__c != null ? ormVar.orm.Lining_form_completed__c : false)+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >7. Communication Cadence? : </td>'
                            +'<td >'+(ormVar.orm.Communication_Cadence__c != null ? ormVar.orm.Communication_Cadence__c : '')+'</td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >8. Who will be completing the OT-57 application? : </td>'
                            +'<td >'+(ormVar.orm.Who_will_be_completing_the_OT_57_app__c != null ? ormVar.orm.Who_will_be_completing_the_OT_57_app__c : '')+'</td>'
                        +'</tr>'
                    +'</table>'
                    +'<br/><div style="background-color: #dddddd;padding: 5px;">Other questions for international or direct sale customers</div><br/>'
                    +'<table style="width:70% !important">'
                        +'<tr style="height: 5px; !important">'
                            +'<td ><b>For international customers only : </b></td>'
                        +'</tr>'
                        +'<tr >'
                            +'<td >Do you have specific customs broker? : </td>'
                            +'<td >'+(ormVar.orm.Do_you_have_specific_customs_broker__c != null ? ormVar.orm.Do_you_have_specific_customs_broker__c : '')+'</td>'
                            
                        +'</tr>'
                        +'<tr >'
                            +'<td >Are you a member of Chemtrec? If yes, will international or domestic be necessary? : </td>'
                            +'<td >'+(ormVar.orm.Are_you_a_member_of_Chemtrec__c != null ? ormVar.orm.Are_you_a_member_of_Chemtrec__c : '')+'</td>'
                            
                        +'</tr>'
                        +'<tr >'
                            +'<td>'
                                +'<b>For Direct Sale customers only :</b> <br/>'
                                +'We will provide UMLER template three months prior to first car shipment<br/>'
                                +'As a reminder, a funding source and invoicing instructions must be identified no less than 30 days prior to first car scheduled shipment.'
                            +'</td>'
                        +'</tr>'
                    +'</table>'
                    +'</body></html>';

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        if(e.size()>0) sendTo.addAll(e);

        if(ormVar.orm.Trinity_Rail_Users__c != null && ormVar.orm.Trinity_Rail_Users__c != '' && ormVar.orm.Trinity_Rail_Users__c != '[]') {
            set<string> usIds = new set<string>();
            usIds.addAll(ormVar.orm.Trinity_Rail_Users__c.split(','));
            for(User usr : [SELECT Id,email FROM User WHERE Id IN : usIds AND email != null]) {
                sendTo.add(usr.email);
            }
            
        }
        if(ormVar.orm.World_Petroleum_Corp_Contacts__c != null && ormVar.orm.World_Petroleum_Corp_Contacts__c != '' && ormVar.orm.World_Petroleum_Corp_Contacts__c != '[]') {
            set<string> conIds = new set<string>();
            conIds.addAll(ormVar.orm.World_Petroleum_Corp_Contacts__c.split(','));
            for(Contact con : [SELECT Id,email FROM Contact WHERE Id IN : conIds AND email != null]) {
                sendTo.add(con.email);
            }
        }
        mail.setToAddresses(sendTo);
        system.debug('~~~ Send To: '+sendTo);
        mail.setReplyTo('noreply@gmail.com'); 
        mail.setSenderDisplayName(UserInfo.getUserName());
        mail.setSubject(mSubject);
        mail.setHtmlBody(mbody);
        mails.add(mail);
        if(sendTo.size()>0 && !Test.isRunningTest())
        	Messaging.sendEmail(mails);
    }
    
    public class OrmWrapper {
        
        @AuraEnabled public ORM__c orm{get;set;}
        @AuraEnabled public list<Action_Item__c> actionItemList{get;set;}
        @AuraEnabled public set<string> fileList{get;set;}
        @AuraEnabled public list<Task> ORMTasks{get;set;}
        @AuraEnabled public string selectedAssetFileNumber{get;set;}
        @AuraEnabled public string selectedServiceType{get;set;}
        @AuraEnabled public set<string> serviceType{get;set;}
        public OrmWrapper() {}
        
    }
    @AuraEnabled
    public static string getOrderId(string recordId) {
        ORM__c[] orderId = [Select id,Order__r.Id from ORM__c where id =:recordId];
        if(orderId.size()>0)
        	return orderId[0].Order__r.Id;
        else
            return 'Order';
    }
}