public class ShareInvoiceFilesBatch implements Database.Batchable<sObject>{
    
    private static final String INVOICE_FILES_GROUP = 'InvoiceFiles';
    private static final String SHARE_TYPE = 'C';
    
    public List<GroupMember> invoiceGrpMembers = new List<GroupMember>();
    
    public Iterable<sObject> start(Database.BatchableContext BC){
      //  return [SELECT Id,Title,Owner.Name FROM ContentDocument];
      return Database.getQueryLocator([SELECT Id,Title,Owner.Name FROM ContentDocument]);  
    }
     
    public void execute(Database.BatchableContext BC, List<ContentDocument> scope){
        
        Map<Id,Id> invoiceIds = new Map<Id,Id>();
        Set<Id> invoiceUserIds = new Set<Id>();
        List<GroupMember> invoiceGrpMembers = [SELECT Id,UserOrGroupId FROM GroupMember WHERE Group.Name =: INVOICE_FILES_GROUP];
        for(GroupMember gm : invoiceGrpMembers){
            invoiceUserIds.add(gm.UserOrGroupId);
        }
        
        List<ContentDocumentLink> invoiceCdls = new List<ContentDocumentLink>();
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocument cd : scope){
            contentDocumentIds.add(cd.Id);
            System.debug(cd.Title);
            System.debug(cd.Id);
            System.debug(cd.Owner.Name);
        }
        Set<String> contentDocUserIds = new Set<String>();
        for(ContentDocumentLink cdl : [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN: contentDocumentIds]){
            if(String.valueOf(cdl.LinkedEntityId.getSobjectType()) == 'CDX_Invoice__c'){
                invoiceIds.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
            if(String.valueOf(cdl.LinkedEntityId.getSobjectType()) == 'User'){
                contentDocUserIds.add(String.valueOf(cdl.ContentDocumentId)+String.valueOf(cdl.LinkedEntityId));
            }
        }
        
        for(Id contentDocumentId : invoiceIds.keySet()){
            
            for(GroupMember gm : invoiceGrpMembers){
                if(!contentDocUserIds.contains(String.valueOf(contentDocumentId)+String.valueOf(gm.UserOrGroupId)))
                invoiceCdls.add(new ContentDocumentLink(LinkedEntityId=gm.UserOrGroupId,ShareType = SHARE_TYPE,ContentDocumentId=contentDocumentId));
            }
        }
        
        if(!invoiceCdls.isEmpty()){
            ContentDocumentLinkHandler.isInvoiceFileShared = true;
            Database.insert(invoiceCdls,true);   
        }
    }
    
    public void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }
}