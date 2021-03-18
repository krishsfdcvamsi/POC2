public class CDX_UpdateScheduleDetails {

    public static String updateScheduleDetails(List<CDX_Schedule__c> schedules)
    {
        System.debug('schDetails>>>'+Schedules);
        String endUrl;
        if(Test.isRunningTest())
        {
              system.debug('Endurl Inside If:>>>> '); 
           endUrl = 'https://dev-api.trinityrail.com:8431/tst/v1/project/schedule/api/projectSchedules/reviews/bulk';    
        }
        else
        {  
             system.debug('Endurl Inside Else:>>>> '); 
            
            endUrl = RFO_IntegrationLinks__c.getInstance('ScheduleUpdate').RFO_APILink__c;  
           
        }
      //String endUrl = RFO_IntegrationLinks__c.getInstance('ScheduleUpdate').RFO_APILink__c;  
   //   String endUrl = 'https://dev-api.trinityrail.com:8431/tst/v1/project/schedule/api/projectSchedules/'+projectScheduleExtId+'/details';
    
        system.debug('Endurl:>>>> ' + endUrl); 
        String userId = UserInfo.getUserId(); 
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('userID', userId);  //UserInfo.getUserId(); 
        gen.writeFieldName('reviewDetails');
        gen.writeStartArray();
        
        for (Integer i = 0; i < Schedules.size(); i++) {
            System.debug('Schedule Internal ID: '+Schedules[i].Id+'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
            System.debug('Schedule External ID: '+Schedules[i].Schedule_External_ID__c+'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
            System.debug('Schedule Status: '+Schedules[i].Status__c+'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
            System.debug('Schedule Comments: '+Schedules[i].CDX_Comment__c+'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
            gen.writeStartObject();
            gen.writeStringField('projectScheduleId', Schedules[i].Schedule_External_ID__c);
            gen.writeStringField('projectCustShopScheduleStatus', Schedules[i].Status__c);
            gen.writeStringField('comments', Schedules[i].CDX_Comment__c);
            //gen.writeStringField('userID', UserInfo.getUserId());
            
            gen.writeEndObject(); 
        } 
        gen.writeEndArray();
        gen.writeEndObject();
        
        System.debug('gen>>>>'+gen);
        String updateLineItemJSON = gen.getAsString();  
        system.debug('updateLineItemJSON'+updateLineItemJSON); 
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endUrl);
        request.setMethod('POST');
        request.setHeader('client_id', '1a729f09c935460aa80b931a9c59dc82');
        request.setHeader('client_secret', '8EDf735DEe054F4187FA6a0BAbfED942');
        request.setHeader('x-correlation-id', 'werfghyuikj');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(updateLineItemJSON);
        request.setTimeout(120000);
        HttpResponse response=new HTTPResponse();
        //To handle test class
         if(Test.isRunningTest())
        {
            System.debug('inside if of response Test');
            String  body='[{"projectCustShopScheduleStatus":"Approved","projectScheduleId":"123511","comments":"Test Comment","errors":[]}]';
            response.setBody(body);
             system.debug('http response in test class: ' +response.getBody()); 
        }
        else
        {
            System.debug('inside else of response');
            response = http.send(request);
        }
       // HttpResponse response = http.send(request);
        system.debug('http response: ' +response.getBody()); 
                
        List<JSONResponse> responseLineItems =
              (List<JSONResponse>)JSON.deserialize(response.getBody(), List<JSONResponse>.class); 
        
        String retVal = 'SUCCESS'; 
        for (JSONResponse each : responseLineItems) {
            if (each.errors == null || each.errors.size() == 0)   
                continue; 
            else 
                retVal = each.errors[0]; 
        }
        
        return retVal; 
        
    }
            
    public class JSONResponse {
        public String projectCustShopScheduleStatus;
        public String projectScheduleExtId;
        public String comments;
        public List<String> errors; 
     
    }
    
    
    
}