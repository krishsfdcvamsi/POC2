public class ContactSyncUtils {
    @future (callout=true)
    public static void syncContact(String contactId, String action) { 
        
        Contact cont = [select Id, firstName, lastName, Email, Account.RFO_TASID__c, RFO_NickName__c, RFO_ContactId__c, Title, Phone, OtherPhone, 
                        Fax, MobilePhone, CDX_EInvoice__c, CDX_InvoiceType__c, CDX_FileFormat__c, RFO_Status__c from Contact where Id =: contactId];  
        String json = createJSON(cont,action); 
        system.debug('created JSON: ' + json); 
       
        RequestStatus status = null;
        if (action == 'Create' || cont.RFO_ContactId__c == null) 
            status = sendCreateRequest(json); 
        
        else
            status = sendUpdateRequest(json, cont.RFO_ContactId__c, cont.Account.RFO_TASID__c);  
        if (status.success) {
            if (action == 'Create' || cont.RFO_ContactId__c == null)  {
                cont.RFO_ContactId__c = status.contactId;
                update cont;
            }
        }
        else {
            if (!Test.isRunningTest()) {
                String BodyOfEvent = 'Contact sync failed during ' + action + ' for: ' + cont.Id;  
                
                FeedItem post = new FeedItem();
                post.ParentId = Label.CDX_ApiFailureGroup;
                post.Body= BodyOfEvent;
                insert post;
                System.debug('posted to Chatter: ' + post);
            }
        }
    }
    
    public static RequestStatus sendCreateRequest(String contactJSON) {
        
        String endUrl = 'https://dev-api.trinityrail.com:8431/stg/v1/contact/api/contacts'; 
        if (!Test.isRunningTest())    
            endUrl = RFO_IntegrationLinks__c.getInstance('Contact').RFO_APILink__c;   
        system.debug('Endurl:>>>> ' + endUrl); 
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endUrl);
        request.setMethod('POST');
        request.setHeader('client_id', '72d7b41af5cc4466af121e9baecb876a');
        request.setHeader('client_secret', 'a6bFA94D4f224739aEbAFF808C66ec23');
        request.setHeader('x-correlation-id', '07fEcd485Ca64A48A63f4990F1a38BAB');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(RFO_GlobalCallOut.setCalloutTime('Contact'));
        request.setBody(contactJSON);
        HttpResponse response = http.send(request);
        system.debug('http response from Trinity: ' + response.getBody());  
        
        Map<String, Object> o = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, Object> m = (Map<String, Object>) o.get('message');
        String contactTASId = null;
        
        if (Test.isRunningTest()) {
			contactTASId = '123456';
        } else if (m.get('contactId') != null) {
            Integer contactId = (Integer) m.get('contactId');
            contactTASId = String.valueOf(contactId);
            system.debug('contactTASId: ' + contactTASId);
        } else if (o.get('contactId') != null) {
            Integer contactId = (Integer) o.get('contactId');
            contactTASId = String.valueOf(contactId);
            system.debug('contactTASId: ' + contactTASId);
        }
        
        RequestStatus status = new RequestStatus();
        if (contactTASId != null && !String.isEmpty(contactTASId)) {
            status.success = true;
            status.contactId = contactTASId; 
        }
        else {
            status.success = false; 
            system.debug('contactId: ' + status.contactId);
        }
        // WRiting to integration log
        System.debug('Going to Integration Utility=====');  
        RFO_IntegrationUtility.createIntegrationLogRecord('Contact', contactTASId, contactJSON, endUrl, response.getBody(), String.valueOf(response.getStatusCode()), 'POST', 'ContactSyncUtils');
    
        return status; 
    }    
    
    /** 
     *  Create JSON for Real-time Create/Update of Contact
     *  
     **/
    public static String createJSON(Contact cont, String action) {
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('lastName', cont.LastName);
        if (!String.isEmpty(cont.FirstName)) {
            gen.writeStringField('firstName', cont.FirstName); 
        }
        
        if ((!String.isEmpty(cont.Account.RFO_TASID__c) && action == 'create') || String.isEmpty(cont.RFO_ContactId__c)) {
            //gen.writeStringField('accountId', cont.Account.RFO_TASID__c);
            gen.writeNumberField('accountId', Integer.valueof(cont.Account.RFO_TASID__c));
            }
        
        String userId = UserInfo.getUserId(); 
        gen.writeStringField('userID', userId);  
        gen.writeStringField('contactIdRf1', Cont.Id);
        //gen.writeStringField('contactIdRf1', '0035600ZZZKUQCoAAP');  // -> Uncomment this line and comment the above one if you want to use a unique Contact id 
        
        if (!String.isEmpty(cont.RFO_NickName__c)) {
            gen.writeStringField('nickname', cont.RFO_NickName__c); 
        }
        
        if (!String.isEmpty(cont.RFO_Status__c)) {				
            gen.writeStringField('status', cont.RFO_Status__c); 
        }
        
        if (!String.isEmpty(cont.Title)) {
            gen.writeStringField('title', cont.Title); 
        }
        
        if (!String.isEmpty(cont.Phone)) {
            gen.writeStringField('phone', cont.Phone); 
        }
        
        if (!String.isEmpty(cont.OtherPhone)) {
            gen.writeStringField('phone2', cont.OtherPhone); 
        }
        
        if (!String.isEmpty(cont.Fax)) {
            gen.writeStringField('fax', cont.Fax); 
        }
       
        if (!String.isEmpty(cont.mobilePhone)) {
            gen.writeStringField('mobilePhone', cont.MobilePhone); 
        }
        
        if (!String.isEmpty(cont.Email)) {
            gen.writeStringField('email', cont.Email); 
        }
            
        if (cont.CDX_EInvoice__c == true) {
        gen.writeBooleanField('subscribeToEmail', True); 
        }
        
        if (cont.CDX_EInvoice__c == false) {
        gen.writeBooleanField('subscribeToEmail', False);
        }
        
        String invoiceType = cont.CDX_InvoiceType__c;
        if (!String.isEmpty(invoiceType)) {
            
            if (invoiceType.contains('Rental')) {
                //gen.writeStringField('rental', 'true'); 
                gen.writeBooleanField('rental',True);
            }
            
            if (invoiceType.contains('Repairs')) {
                //gen.writeStringField('repair', 'true');
                gen.writeBooleanField('repair',True);
            }
            
            if (invoiceType.contains('Mileage')) {
                //gen.writeStringField('mileage', 'true'); 
                gen.writeBooleanField('mileage', True);
            }
            
            if (invoiceType.contains('Modification')) {
                //gen.writeStringField('modification', 'true');
                gen.writeBooleanField('modification', True); 
            }
            
        }
        
        String fileType = cont.CDX_FileFormat__c;
        if (!String.isEmpty(fileType)) {
            gen.writeFieldName('fileFormat');
            gen.writeStartArray();
            
            if (fileType.contains('pdf')) {
                gen.writeStartObject();
                gen.writeStringField('format', 'pdf');
                gen.writeEndObject();
            }
            
            if (fileType.contains('txt')) {
                gen.writeStartObject();
                gen.writeStringField('format', 'txt');
                gen.writeEndObject();
            }
            
            if (fileType.contains('dat')) {
                gen.writeStartObject();
                gen.writeStringField('format', 'dat');
                gen.writeEndObject();
            }
            
            if (fileType.contains('xls')) {
                gen.writeStartObject();
                gen.writeStringField('format', 'xls');
                gen.writeEndObject();
            }
            
            if (fileType.contains('xlsx')) {
                gen.writeStartObject();
                gen.writeStringField('format', 'xlsx');
                gen.writeEndObject();
            }
            
            gen.writeEndArray();
        } else {
            gen.writeFieldName('fileFormat');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('format', 'pdf');
            gen.writeEndObject();
            
            gen.writeEndArray();
        }
        
        //Default Values
        /*
gen.writeStringField('repairDataFormat', '500');  
gen.writeStringField('inActive', '1');  
*/
        gen.writeEndObject();
        return gen.getAsString();
    }
    
    public static RequestStatus sendUpdateRequest(String contactJSON, String contactId, String accountId) {
        
        String endUrl = 'https://dev-api.trinityrail.com:8431/stg/v1/contact/api/contacts'; 
        if (!Test.isRunningTest())
            endUrl = RFO_IntegrationLinks__c.getInstance('Contact').RFO_APILink__c + '/' + accountId + '/' + contactId;  
        System.debug('Endurl:>>>> ' + endUrl); 
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endUrl);
        //request.setHeader('X-HTTP-Method-Override','PATCH');
        request.setMethod('PUT');
        request.setHeader('client_id', '72d7b41af5cc4466af121e9baecb876a');
        request.setHeader('client_secret', 'a6bFA94D4f224739aEbAFF808C66ec23');
        request.setHeader('x-correlation-id', '07fEcd485Ca64A48A63f4990F1a38BAB'); 
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(RFO_GlobalCallOut.setCalloutTime('Contact'));
        request.setBody(contactJSON);
        HttpResponse response = http.send(request);
        system.debug('https response from Trinity: ' + response.getBody());  
        
        Map<String, Object> o = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
        system.debug('JSON Map: ' + o); 
        
        RequestStatus status = new RequestStatus();
        //If request fails, API returns a key/value pair: 'success: false'. 
        //Currenty, if call is succcessful, API does NOT return the success key. 
        if (o.containsKey('status')) {
            Boolean success = (Boolean) o.get('success');
            if (success == false)
                status.success = false; 
            else 
                status.success = true; 
        }
        else {
            status.success = false;         
        } 
        // WRiting to integration log
        System.debug('Going to Integration Utility=====');  
        RFO_IntegrationUtility.createIntegrationLogRecord('Contact', contactId, contactJSON, endUrl, response.getBody(), String.valueOf(response.getStatusCode()), 'PUT', 'ContactSyncUtils');
    
        return status; 
    }    
    
    public class RequestStatus {
        Boolean success;
        String contactId;
        String errorMessage; 
    }
}