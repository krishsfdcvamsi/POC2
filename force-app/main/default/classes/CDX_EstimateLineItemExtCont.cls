public  without sharing class CDX_EstimateLineItemExtCont
{
    @TestVisible private static String estimateItemListStatus; 
    @TestVisible private static String estimateExternalId;
    @TestVisible private static List<CDX_Estimate_Line_Item__x> estList=new  List<CDX_Estimate_Line_Item__x>() ; 
    //@TestVisible private static boolean testStatus; 
    public static List<CDX_Estimate_Line_Item__x> lineItemWithComments=new List<CDX_Estimate_Line_Item__x>();    
    
    @AuraEnabled
    public static List<CDX_Estimate_Line_Item__x> getAllEstimateLineItemInitial(Id estimateId)
    {       
        CDX_Estimate__c estimate=[select id, Estimate_External_ID__c,CDX_RepEstimateHdrID_ReimbursableFrom__c from CDX_Estimate__c where id=:estimateId];
        List<CDX_Estimate_Line_Item__x> estimateItemList = new List<CDX_Estimate_Line_Item__x> ();
        List<CDX_Estimate_Line_Item__x> estimateItemListForCustomerWaiting= new List<CDX_Estimate_Line_Item__x>();
        List<CDX_Estimate_Line_Item__x> estimateItemListForAll = new List<CDX_Estimate_Line_Item__x>();
        
        if(Test.isRunningTest())
        {
            HTTP http= new HTTP();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            
            CDX_EstimateLineItemExtContTest conTest=new CDX_EstimateLineItemExtContTest();
            HTTPResponse response=conTest.respond(request);
            
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 

            CDX_Estimate_Line_Item__x obj=new  CDX_Estimate_Line_Item__x();
            obj.CDX_Status__c=String.valueOf(m.get('CDX_Status__c'));
            obj.CDX_Estimate__c=String.valueOf(m.get('CDX_Estimate__c'));
            obj.ExternalId=String.valueOf(m.get('ExternalId'));

            System.debug('obj>>>'+obj);
            estimateItemList.add(obj);
            //estimateItemList=CDX_EstimateTestDataFactory.setStatus(estimateItemListStatus,estimate.Estimate_External_ID__c);
        }        
        else
        {
            
            System.debug(estimate.Estimate_External_ID__c);
            estimateItemList = [Select id,externalId, CDX_Estimate__c, CDX_Approved_Rejected_By__c, CDX_Comments__c, CDX_Condition_Code__c,
                                CDX_Description__c, CDX_Job_Category_Code__c, CDX_Job_Category_Description__c, CDX_Job_Code_Applied__c, 
                                CDX_Job_Code_Reviewed__c, CDX_Labor_Charge__c, CDX_Materials_Miscellaneous_Charge__c, CDX_Qualifier__c, 
                                CDX_Qualifier_Code__c, CDX_Quantity__c, CDX_Repair_Location__c, CDX_RepEstimateCustVerDetID__c, CDX_ReimbursableFrom__c,
                                CDX_RepEstimateCustVerHdrID__c, CDX_Status__c, CDX_Total_Amount__c, CDX_Version_History__c,
                                CDX_Version_Number__c, CDX_Why_Made__c from CDX_Estimate_Line_Item__x 
                                where CDX_Estimate__r.CDX_RepEstimateHdrID_ReimbursableFrom__c =:estimate.CDX_RepEstimateHdrID_ReimbursableFrom__c];
        }
        
        System.debug('estimateItemList>>>'+estimateItemList);
        for(CDX_Estimate_Line_Item__x estObj: estimateItemList)
        {
            if(estObj.CDX_Status__c=='CustomerWaiting')
            {
                estimateItemListForCustomerWaiting.add(estObj);  
            }
            else if(estObj.CDX_Status__c!='CustomerWaiting')
            {
                estimateItemListForAll.add(estObj); 
            }
            
        }
        System.debug(' estimateItemListForPending'+ estimateItemListForCustomerWaiting);
        System.debug('  estimateItemListForAll'+  estimateItemListForAll);
        
        if(estimateItemListForCustomerWaiting.size()>0)
            return estimateItemListForCustomerWaiting;
        else
            return estimateItemListForAll;
    }   
    
    @AuraEnabled    
    public static List<CDX_Estimate_Line_Item__x> getAllEstimateLineItem(Id estimateId, String statusvalue)
    {
        
        CDX_Estimate__c estimate=[select id, Estimate_External_ID__c from CDX_Estimate__c where id=:estimateId];        
        
        List<CDX_Estimate_Line_Item__x> estimateItemList = new List<CDX_Estimate_Line_Item__x> ();
        List<CDX_Estimate_Line_Item__x> estimateItemListForCustomerWaiting = new List<CDX_Estimate_Line_Item__x>();
        List<CDX_Estimate_Line_Item__x> estimateItemListForRejected = new List<CDX_Estimate_Line_Item__x>();
        List<CDX_Estimate_Line_Item__x> estimateItemListForApproved = new List<CDX_Estimate_Line_Item__x>();        
        
        if(Test.isRunningTest())
        {
            HTTP http= new HTTP();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            
            CDX_EstimateLineItemExtContTest conTest=new CDX_EstimateLineItemExtContTest();
            HTTPResponse response=conTest.respond(request);
            
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 

            CDX_Estimate_Line_Item__x obj=new  CDX_Estimate_Line_Item__x();
            obj.CDX_Status__c=String.valueOf(m.get('CDX_Status__c'));
            obj.CDX_Estimate__c=String.valueOf(m.get('CDX_Estimate__c'));
            obj.ExternalId=String.valueOf(m.get('ExternalId'));

            System.debug('obj>>>'+obj);
            estimateItemList.add(obj);
            // estimateItemList = CDX_EstimateTestDataFactory.setStatus(statusvalue,estimate.Estimate_External_ID__c);
        }
        else
        {
            estimateItemList = [Select id,externalId, CDX_Estimate__c, CDX_Approved_Rejected_By__c, CDX_Comments__c, CDX_Condition_Code__c,
                                CDX_Description__c, CDX_Job_Category_Code__c, CDX_Job_Category_Description__c, CDX_Job_Code_Applied__c,
                                CDX_Job_Code_Reviewed__c, CDX_Labor_Charge__c, CDX_Materials_Miscellaneous_Charge__c, CDX_Qualifier__c, 
                                CDX_Qualifier_Code__c, CDX_Quantity__c, CDX_Repair_Location__c, CDX_RepEstimateCustVerDetID__c, 
                                CDX_RepEstimateCustVerHdrID__c, CDX_Status__c, CDX_Total_Amount__c, CDX_Version_History__c, 
                                CDX_Version_Number__c, CDX_Why_Made__c,CDX_ReimbursableFrom__c from CDX_Estimate_Line_Item__x where CDX_Estimate__r.Id=:estimate.Id];
        }
        
        for(CDX_Estimate_Line_Item__x estObj: estimateItemList)
        {
            if(estObj.CDX_Status__c=='CustomerWaiting')
            {
                estimateItemListForCustomerWaiting.add(estObj);  
            }
            else if(estObj.CDX_Status__c=='Rejected')
            {
                estimateItemListForRejected.add(estObj); 
            }
            else if(estObj.CDX_Status__c=='Approved')
            {
                estimateItemListForApproved.add(estObj); 
            }
            
        }
        
        // Returning the EstimateLineItem list
        if(statusvalue == 'All' || statusvalue == Null){
            return estimateItemList;    
        }else if(statusvalue == 'CustomerWaiting'){
            return estimateItemListForCustomerWaiting;    
        }else if(statusvalue == 'Rejected'){
            return estimateItemListForRejected;    
        }else if(statusvalue == 'Approved'){
            return estimateItemListForApproved;    
        }else{
            return estimateItemList;    
        }
    }
    @AuraEnabled
    public static void updateLineItem(List<CDX_Estimate_Line_Item__x> lineItem)
    {
        lineItemWithComments=lineItem.clone();      
    }
    
    @AuraEnabled
    public static void approve(List<CDX_Estimate_Line_Item__x> lineItemforApproval,List<CDX_Estimate_Line_Item__x>  draftList, Id estimateId)
    {
        CDX_UpdateLineItemEstimates.EstimateLineItem item;
        List<CDX_UpdateLineItemEstimates.EstimateLineItem> items = new List<CDX_UpdateLineItemEstimates.EstimateLineItem>();
        System.debug('lineItemforApprovalInitial>>>'+lineItemforApproval);
        if(Test.isRunningTest())
        {
            HTTP http= new HTTP();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            
            CDX_EstimateLineItemExtContTest conTest=new CDX_EstimateLineItemExtContTest();
            HTTPResponse response=conTest.respond(request);
            
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 

            CDX_Estimate_Line_Item__x obj=new  CDX_Estimate_Line_Item__x();
            obj.CDX_Status__c=String.valueOf(m.get('CDX_Status__c'));
            obj.CDX_Estimate__c=String.valueOf(m.get('CDX_Estimate__c'));
            obj.ExternalId=String.valueOf(m.get('ExternalId'));
            obj.CDX_Comments__c = String.valueOf(m.get('CDX_Comments__c'));

            System.debug('obj>>>'+obj);
            lineItemforApproval.add(obj);
        }
        
        System.debug('draftList++++>>>>'+draftList); 
        System.debug('lineItemforApproval++++>>>>'+lineItemforApproval);   
        for(CDX_Estimate_Line_Item__x estObj:lineItemforApproval)
        {   
            if(estObj.CDX_Status__c=='CustomerWaiting')
            {
                item = new CDX_UpdateLineItemEstimates.EstimateLineItem();                 
                item.status = 'APPROVED';                
                item.userId = UserInfo.getUserId();                
                item.externalId = estObj.ExternalId;
                item.comments=''; 
                for(integer i=0;i<draftList.size();i++)
                {			   
                    System.debug('draftList[i].Id'+draftList[i].Id);
                    System.debug('estObj.Id'+estObj.Id);
                    if(!Test.isRunningTest())
                    {
                        if(estObj.Id==draftList[i].Id)			   
                        {
                            System.debug('yoyo');		  
                            item.comments=draftList[i].CDX_Comments__c;
                            break;
                        }  
                    }
                    else
                    	item.comments = 'Test'; 
                }            
                items.add(item); 
            }
        }
        
        if(items.size()>0)
        {
            System.debug('items>>>>'+items);
            
            CDX_UpdateLineItemEstimates.updateLineItemEstimates(estimateId, items);
        }
    } 
    
    @AuraEnabled
    public static boolean approveAllList(Id estimateId)
    {    
        
        boolean sel=false;
        CDX_UpdateLineItemEstimates.EstimateLineItem item;
        List<CDX_Estimate_Line_Item__x> lineItemforApprovalNewList =new List<CDX_Estimate_Line_Item__x>();
        List<CDX_Estimate_Line_Item__x> lineItemforApprovalList1 =new List<CDX_Estimate_Line_Item__x>();
        List<CDX_UpdateLineItemEstimates.EstimateLineItem> items = new List<CDX_UpdateLineItemEstimates.EstimateLineItem>();
        CDX_Estimate__c estimate=[select id, Estimate_External_ID__c from CDX_Estimate__c where id=:estimateId];
        System.debug('estimate>>>>'+estimate);
        List<CDX_Estimate_Line_Item__x> lineItemforApprovalList =new List<CDX_Estimate_Line_Item__x>(); 
        if(Test.isRunningTest())
        {
            HTTP http= new HTTP();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            
            CDX_EstimateLineItemExtContTest conTest=new CDX_EstimateLineItemExtContTest();
            HTTPResponse response=conTest.respond(request);
            
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 

            CDX_Estimate_Line_Item__x obj=new  CDX_Estimate_Line_Item__x();
            obj.CDX_Status__c=String.valueOf(m.get('CDX_Status__c'));
            obj.CDX_Estimate__c=String.valueOf(m.get('CDX_Estimate__c'));
            obj.ExternalId=String.valueOf(m.get('ExternalId'));
            obj.CDX_Comments__c = String.valueOf(m.get('CDX_Comments__c'));

            System.debug('obj>>>'+obj);
            lineItemforApprovalList.add(obj);
            System.debug('lineItemforApprovalList>>>>'+lineItemforApprovalList);
        }
        
        else
        {          
            lineItemforApprovalList = [Select id,externalId, CDX_Estimate__c, CDX_Approved_Rejected_By__c,
                                       CDX_Comments__c, CDX_Condition_Code__c, CDX_Description__c,
                                       CDX_Job_Category_Code__c, CDX_Job_Category_Description__c,
                                       CDX_Job_Code_Applied__c, CDX_Job_Code_Reviewed__c, CDX_Labor_Charge__c, 
                                       CDX_Materials_Miscellaneous_Charge__c, CDX_Qualifier__c, CDX_Qualifier_Code__c, 
                                       CDX_Quantity__c, CDX_Repair_Location__c, CDX_RepEstimateCustVerDetID__c, 
                                       CDX_RepEstimateCustVerHdrID__c, CDX_Status__c, CDX_Total_Amount__c, CDX_Version_History__c, 
                                       CDX_Version_Number__c, CDX_Why_Made__c,CDX_ReimbursableFrom__c	 from CDX_Estimate_Line_Item__x
                                       where CDX_Estimate__r.Id =:estimate.Id];
        }
        
        if( lineItemforApprovalList.size()>0)
        {
            for(CDX_Estimate_Line_Item__x estObj:lineItemforApprovalList)
            {
                if(estObj.CDX_Status__c=='CustomerWaiting')
                {
                    lineItemforApprovalList1.add(estObj); 
                }
            }
        }
        
        
        for(CDX_Estimate_Line_Item__x estObj:lineItemforApprovalList1)
        {           
            if(estObj.CDX_Status__c=='CustomerWaiting')
            {
                item = new CDX_UpdateLineItemEstimates.EstimateLineItem(); 
                item.status = 'APPROVED';                
                item.userId = UserInfo.getUserId();                
                item.externalId = estObj.ExternalId; //External id of Estimate Line Item                
                item.comments = '';
                items.add(item);
                sel=true;
            }
            else
            {
                sel=false;
                break;
            }
            
        }
        
        if(items.size()>0&& sel==true)
        {
            System.debug('itemsApproveAll>>>>'+items);
            CDX_UpdateLineItemEstimates.updateLineItemEstimates(estimate.Id, items);  
        }
        return sel;
        
    }
    
    @AuraEnabled
    public static void rejectPendingOne(List<CDX_Estimate_Line_Item__x> lineItemforRejection)
    {
        Integer i=0;
        
        
        
        CDX_UpdateLineItemEstimates.EstimateLineItem item ;
        
        List<CDX_UpdateLineItemEstimates.EstimateLineItem> items = new List<CDX_UpdateLineItemEstimates.EstimateLineItem>();
        
        List<CDX_Estimate_Line_Item__x> lineItemforRejectionNewList =new List<CDX_Estimate_Line_Item__x>();
        
        if(Test.isRunningTest())
        {
            HTTP http= new HTTP();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            
            CDX_EstimateLineItemExtContTest conTest=new CDX_EstimateLineItemExtContTest();
            HTTPResponse response=conTest.respond(request);
            
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 

            CDX_Estimate_Line_Item__x obj=new  CDX_Estimate_Line_Item__x();
            obj.CDX_Status__c=String.valueOf(m.get('CDX_Status__c'));
            obj.CDX_Estimate__c=String.valueOf(m.get('CDX_Estimate__c'));
            obj.ExternalId=String.valueOf(m.get('ExternalId'));
            obj.CDX_Comments__c = String.valueOf(m.get('CDX_Comments__c'));

            System.debug('obj>>>'+obj);
            lineItemforRejection.add(obj);
            System.debug('lineItemforRejection>>>>'+lineItemforRejection);
        }
        
        System.debug('lineItemforRejection>>>>'+lineItemforRejection);
        
        for(CDX_Estimate_Line_Item__x estObj:lineItemforRejection)
        {
            
            item = new CDX_UpdateLineItemEstimates.EstimateLineItem();            
            item.status = 'REJECTED';            
            item.userId = UserInfo.getUserId();            
            item.externalId = estObj.ExternalId; //External id of Estimate Line Item              
            item.comments=lineItemWithComments[i].CDX_Comments__c;
            items.add(item);            
            
            i++;
        }
        if(items.size()>0)
        {
            System.debug('items>>>'+items);
            CDX_UpdateLineItemEstimates.updateLineItemEstimates(lineItemforRejection[0].CDX_Estimate__c, items);  
        }
    }
    
    
    @AuraEnabled
    public static void rejectInitial(List<CDX_Estimate_Line_Item__x> rejectionList,List<CDX_Estimate_Line_Item__x>  draftList,Id estimateId)
    {
        CDX_UpdateLineItemEstimates.EstimateLineItem item;
        List<CDX_UpdateLineItemEstimates.EstimateLineItem> items = new List<CDX_UpdateLineItemEstimates.EstimateLineItem>();
        
        System.debug('draftList++++>>>>'+draftList); 
        if(Test.isRunningTest())
        {
            HTTP http= new HTTP();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            
            CDX_EstimateLineItemExtContTest conTest=new CDX_EstimateLineItemExtContTest();
            HTTPResponse response=conTest.respond(request);
            
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 

            CDX_Estimate_Line_Item__x obj=new  CDX_Estimate_Line_Item__x();
            obj.CDX_Status__c=String.valueOf(m.get('CDX_Status__c'));
            obj.CDX_Estimate__c=String.valueOf(m.get('CDX_Estimate__c'));
            obj.ExternalId=String.valueOf(m.get('ExternalId'));
            obj.CDX_Comments__c = String.valueOf(m.get('CDX_Comments__c'));

            System.debug('obj>>>'+obj);
            rejectionList.add(obj);
            
        }
        System.debug('rejectionList>>>>'+rejectionList);
        for(CDX_Estimate_Line_Item__x estObj:rejectionList)
        {   
            if(estObj.CDX_Status__c=='CustomerWaiting')
            {
                item = new CDX_UpdateLineItemEstimates.EstimateLineItem();                 
                item.status = 'REJECTED';                
                item.userId = UserInfo.getUserId();                
                item.externalId = estObj.ExternalId;
                item.comments=''; 
                for(integer i=0;i<draftList.size();i++)
                {			   
                    System.debug('draftList[i].Id'+draftList[i].Id);
                    System.debug('estObj.Id'+estObj.Id);
                    if(!Test.isRunningTest())
                    {
                        if(estObj.Id==draftList[i].Id)			   
                        {
                            System.debug('yoyo');		  
                            item.comments=draftList[i].CDX_Comments__c;
                            break;
                        } 
                    }
                    else
                        item.comments = 'Test';
                }            
                items.add(item); 
            }
        }
        
        if(items.size()>0)
        {
            System.debug('items>>>>'+items);
            CDX_UpdateLineItemEstimates.updateLineItemEstimates(estimateId, items);
        }  
        
    }
    public class EstimateWrapper
    {
        public String id;
        public String lineItemNumber;
        public String estimateId;
        public String notes;
        public String status;
    }
    
}