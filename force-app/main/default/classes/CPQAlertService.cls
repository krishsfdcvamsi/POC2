public class CPQAlertService {
    
    public static void processCommittedAssetsAlerts(list<asset_lines__c> lines){
        system.debug('lines>>>>>>>>'+lines);
        //preprocessing into groups
        Map<id, list<asset_lines__c>> quoteIdtoAssetLinesMap = new Map<id, list<asset_lines__c>>();
        for(asset_lines__c line :  lines){
            //only process if the committed to account is different than quote account, meaning asset went to a different customer
            //cant do this in soql due to governor limits on where clause
            
            if(line.asset_Group__r.quote_line__r.SBQQ__Quote__r.sbqq__account__r.name <> line.asset__r.RFO_CommittedTo__c){
                if(quoteIdtoAssetLinesMap.containsKey(line.asset_Group__r.quote_line__r.SBQQ__Quote__r.commercial_quote__c)){
                  list<asset_lines__c> al = quoteIdtoAssetLinesMap.get(line.asset_Group__r.quote_line__r.SBQQ__Quote__r.commercial_quote__c);
                  al.add(line);
                }else{
                     list<asset_lines__c> al = new  list<asset_lines__c>();
                     al.add(line);
                     quoteIdtoAssetLinesMap.put(line.asset_Group__r.quote_line__r.SBQQ__Quote__r.commercial_quote__c, al);
				}
            }
        }
        system.debug('quoteIdtoAssetLinesMap>>>>>>'+quoteIdtoAssetLinesMap);
        if(!quoteIdtoAssetLinesMap.isEmpty()){
            CPQAlertService.proccessAlertsandTasks(quoteIdtoAssetLinesMap);
        }
      }
    
    
        public Static void proccessAlertsandTasks(Map<id, list<asset_lines__c>> quoteIdtoAssetLinesMap){
            
            if(!quoteIdtoAssetLinesMap.isEmpty()){
                Set<Id> quoteIds = quoteIdtoAssetLinesMap.keySet();
                Set<String> setFinalsQuoteIdsAlerts = New Set<String>(); 
                Set<String> setFinalsQuoteIdsTasks = New Set<String>(); 
                if(!quoteIds.isEmpty()){
                    Set<String> setAlerts = New Set<String>();
                    for(Alert__c objAlert :[SELECT Related_To__c FROM Alert__c WHERE Related_To__c IN:quoteIds]){
                        if(String.isNotBlank(objAlert.Related_To__c) && String.isNotEmpty(objAlert.Related_To__c)){
                            setAlerts.add(objAlert.Related_To__c);
                        }
                    }
                    system.debug('setAlerts>>>>>>'+setAlerts);
                    for(Id QuoteId : quoteIds){
                        if(!setAlerts.Contains(QuoteId)){
                            setFinalsQuoteIdsAlerts.add(QuoteId);
                        }
                    }
                    
                    system.debug('setFinalsQuoteIdsAlerts>>>>>'+setFinalsQuoteIdsAlerts);
                   //Using to create Alert related to Quote if alert is not available.
                    if(!setFinalsQuoteIdsAlerts.isEmpty()){
                        AlertService objAlertService = New AlertService();     
                        system.debug('objAlertService>>>>>'+objAlertService.mapAlertSetting);
                        List<Alert__c> lstAlerts = New List<Alert__c>();
                        String notificationMergeTitle 	= objAlertService.mapAlertSetting.get('CPQ_Committed_Alert').Immediate_Notification_Title__c;
                        String notificationMergeBody 	= objAlertService.mapAlertSetting.get('CPQ_Committed_Alert').Immediate_Notification_Body__c;
                        for(SBQQ__Quote__c objQuote:[SELECT OwnerId,Commercial_Quote__r.Name,Commercial_Quote__c 
                                                     FROM SBQQ__Quote__c WHERE Id IN:setFinalsQuoteIdsAlerts]){
                            String alertBody = '';
                            system.debug('size>>>>>>'+quoteIdtoAssetLinesMap.get(objQuote.Id));
                            Map<String,String> mapCommitedAssets = New Map<String,String>();
                            if(quoteIdtoAssetLinesMap.containsKey(objQuote.Id)){
                                for(asset_lines__c objAssetLine:quoteIdtoAssetLinesMap.get(objQuote.Id)){
                                    mapCommitedAssets.put(objAssetLine.asset__c,objAssetLine.asset__r.Name);
                                }
                                for(String assetName : mapCommitedAssets.values()){
                                    if(String.isNotBlank(alertBody)){
                                        alertBody+= ';'+assetName;
                                    }else{
                                        alertBody+= assetName;
                                    }
                                }
                            }
                            Integer totalAssets = quoteIdtoAssetLinesMap.get(objQuote.Id).size();
                            //String template = '{0} was last updated {1}';
							List<Object> parameters = new List<Object> {totalAssets,objQuote.Commercial_Quote__r.Name};
							String notificationMergeTitleFormated = String.format(notificationMergeTitle, parameters);
							System.debug ('Newly formatted string is:' + notificationMergeTitleFormated);
                            String formatted = String.format(notificationMergeTitleFormated, parameters);
                            
                            Alert__c objAlert = objAlertService.createAlert('CPQ_Committed_Alert',
                                                                      null,
                                                                     objQuote.OwnerId,
                                                                     '',
                                                                     '',
                                                                     objQuote.Commercial_Quote__c,
                                                                     notificationMergeTitleFormated,
                                                                     notificationMergeBody);
                            objAlert.Details__c			=	alertBody;
                            objAlert.Alert_1__c			= true;
                            objAlert.Alert_2__c			= true;
                        //    objAlert.Completed__c		= true;
                            lstAlerts.add(objAlert);
                        }
                        system.debug('lstAlerts>>>>>>>'+lstAlerts);
                        if(!lstAlerts.isEmpty()){
                            Insert lstAlerts;
                            system.debug('lstAlerts>>After insert>>>>>'+lstAlerts);
                        }
                        List<Task> lstTasks = New List<Task>();
                        TaskService objTaskService = New TaskService();
                        	String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task').getRecordTypeId();
                            for(Alert__c objAlert:lstAlerts){
                                String[] OwnerIdVal  = objAlert.Immediate_Alert_List__c.split(';');
                                system.debug('OwnerIdVal>>>>>'+OwnerIdVal);
                                system.debug('user Id>>>>>'+OwnerIdVal[0]);
                            	Task objTask = objTaskService.createTaskEscalation('CPQ Committed Task',
                                                                                   Null,
                                                                                   OwnerIdVal[0],
                                                                                   '',
                                                                                   '',
                                                                                   objAlert.Id,
                                                                                   '',
                                                                                   ''
                                													);
                                objTask.RecordTypeId = taskRecordTypeId;
                                lstTasks.add(objTask);
                            }
                        system.debug('lstTasksAfter before >>>>>>>'+lstTasks);
                        if(!lstTasks.isEmpty()){
                            insert lstTasks;
                        }
                        system.debug('lstTasksAfter insert >>>>>>>'+lstTasks);
                    }
                }
            }
        }
        
        
   

}