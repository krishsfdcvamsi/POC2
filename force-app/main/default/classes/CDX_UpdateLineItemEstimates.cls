public class CDX_UpdateLineItemEstimates {
    
    public static String extEstimateId;
    public static String reimbursableFromId;
    
    public static String updateLineItemEstimates(String estimateId, EstimateLineItem [] lineItems)
    {
        CDX_Estimate__c est;
        if(extEstimateId != estimateId){
            extEstimateId = estimateId;
            
             est = [SELECT Id, Name, CDX_DetailsToReviewCount__c, CDX_Estimate_Approved__c, 
                                   CDX_Estimate_Approved_By__c, CDX_Status__c, Estimate_External_ID__c FROM CDX_Estimate__c
                                  WHERE Id =: estimateId LIMIT 1];

        }
        System.debug('lineItems>>>'+lineItems);
        System.debug('estimateId>>>'+estimateId);
        String endUrl = RFO_IntegrationLinks__c.getInstance('Estimates_Line_Item').RFO_APILink__c;  
        system.debug('Endurl:>>>> ' + endUrl); 
        endUrl = endUrl + est.Estimate_External_ID__c;//+'/'+'reimbursableFrom/'+reimbursableFromId;
        system.debug('Endurl: ' + endUrl); 
        //https://dev-api.trinityrail.com:8431/tst/v1/customer/estimate/api/customers/estimates/123511/lineItems/43497      
        String userId = UserInfo.getUserId(); 
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('railforceId', userId);  //UserInfo.getUserId(); 
        gen.writeFieldName('estimateDetails');
        gen.writeStartArray();
        
        for (Integer i = 0; i < lineItems.size(); i++) {
            
            gen.writeStartObject();
            gen.writeStringField('notes', lineItems[i].comments);
            gen.writeStringField('status', lineItems[i].status);
            //gen.writeStringField('userId', lineItems[i].userId);
            //gen.writeStringField('lineItemId', lineItems[i].externalId);
            gen.writeNumberField('lineItemId', Integer.valueof(lineItems[i].externalId));
            gen.writeEndObject(); 
        } 
        gen.writeEndArray();
        gen.writeEndObject();
        
        System.debug('gen>>>>'+gen);
        String updateLineItemJSON = gen.getAsString();  
        system.debug(updateLineItemJSON); 
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endUrl);
        request.setMethod('PUT');
        request.setHeader('client_id', '72d7b41af5cc4466af121e9baecb876a');
        request.setHeader('client_secret', 'a6bFA94D4f224739aEbAFF808C66ec23');
        request.setHeader('x-correlation-id', '07fEcd485Ca64A48A63f4990F1a38BAB');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(updateLineItemJSON);
        request.setTimeout(120000);
        HttpResponse response=new HTTPResponse();
        //Modified By Aniket Bajaj//
        if(Test.isRunningTest())
        {
            System.debug('inside if of response Test');
            String  body='[{"status":201,"estimateId":"60607","lineItemNumber":"1115025","errors":[]}]';
            response.setBody(body);
        }
        else
        {
            System.debug('inside else of response');
            response = http.send(request);
        }
        system.debug('http response: ' + response.getBody()); 
        
        List<JSONResponse> responseLineItems =(List<JSONResponse>)JSON.deserialize(response.getBody(),List<JSONResponse>.class); 
        System.debug('responseLineItems>>>'+responseLineItems);
        
        String retVal = 'SUCCESS'; 
        for (JSONResponse each : responseLineItems) {
            if (each.errors == null || each.errors.size() == 0)   
                continue; 
            else 
                retVal = each.errors[0]; 
        }
        
        if (retVal == 'SUCCESS')
        {
            System.debug('EST ID: '+estimateId);
           
 
            System.debug('PRE COUNT: '+est.CDX_DetailsToReviewCount__c);
            est.CDX_DetailsToReviewCount__c -= lineItems.size();
       		System.debug('POST COUNT: '+est.CDX_DetailsToReviewCount__c);
            
            if(est.CDX_DetailsToReviewCount__c <= 0)
            {
                est.CDX_Estimate_Approved__c = Date.today();
                est.CDX_Estimate_Approved_By__c = UserInfo.getName();
                est.CDX_Status__c = 'Approved'; 
            }
            
            update est;
        }
        
        return retVal; 
        
    }
    
    public class EstimateLineItem {
        public String externalId; 
        public String status;
        public String userId; 
        public String comments; 
    }
    
    public class JSONResponse {
        public String status;
        public String estimateId;
        public String lineItemNumber;
        public List<String> errors; 
    }
    
    
    
}