public class CDX_SI_Callout {
    
    //PUT CALLOUT
    @future(Callout=true)
    public static void SIPut(String sr)
    {              
        //Variables for controllering run number
        boolean run = true;
        String Error = NULL;
        Integer runs = 0;
        boolean success = false;
        
        //Converts JSON to service request Is
        CDX_SI_Callout_Helper SerReq = (CDX_SI_Callout_Helper) JSON.deserialize(sr, CDX_SI_Callout_Helper.class);
        
        //Queries service request and needed fields
        List<RFO_ShopIncident__c> IncidentList = [SELECT Id, RFO_ShopIncidentID__c, Name, RFO_RepairType__c, RFO_CarStatus__c, RFO_SIStatus__c, RFO_LastContents__c, CDX_Additional_Emails__c, CDX_Bypass_Validation__c,
                                                  CreatedByID, CDX_Primary_Contact__r.RFO_ContactId__c, CDX_Destination_Consignee__c,
                                                  CDX_Current_STCC__r.RFO_STCC__c, RFO_Asset__r.RFO_TASId__c, CDX_Customer_Comments__c,
                                                  CDX_Destination_Consignee__r.CDX_Address__c, CDX_Destination_Consignee__r.CDX_City__c, 
                                                  CDX_Destination_Consignee__r.CDX_Postal_Code__c, CDX_Destination_Consignee__r.Name, CDX_Destination_Consignee__r.CDX_State__c,
                                                  CDX_Care_of_Party__r.CDX_Location_Name__c, RFO_OutboundRoutingInformation__c, RFO_FreightResponsibility__c,
                                                  CDX_Customer_Broker__c, CDX_Freight_Forwarder__c, LastModifiedById, RFO_ShopType__c, CDX_Destination_Consignee__r.CDX_Location_Name__c,
                                                  RFO_ShopInstruction__c, CreatedDate, RFO_TASLastModifiedBy__c, RFO_OutboundDispAddress__c
                                                  FROM RFO_ShopIncident__c 
                                                  WHERE Id =: SerReq.request LIMIT 1];
        
        RFO_ShopIncident__c Incident = IncidentList[0];
        System.debug('===========>>>>>Incident'+ Incident );
        
        //Creates Document Array
        List<ContentDocumentLink> docs = [SELECT ID, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: Incident.Id];
        String links = ''; 
        for(ContentDocumentLink x : docs)
        {
            if(links == NULL || links == '')
            {
                links = '{"id": "'+x.Id+'", "documentSource": "RailforceOne"}';
            }else{
                links = links + ', ' + '{"id": "'+x.Id+'", "documentSource": "RailforceOne"}';
            }
        }
       //Assigning variables for Integration Log
        String requestBody = '';
        String responseBody = '';
        String URI = '';
        String methodType = '';
        String statusCode = '';
        
        while (run == True) {
            if (runs < 2)
            {
                
                //Sends HTTP Request
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(RFO_IntegrationLinks__c.getInstance('ServiceRequest').RFO_APILink__c+'/'+Incident.RFO_ShopIncidentID__c);
                request.setMethod('PUT');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('client_id', '5cd2281f6f8d456baaa5c552d79547c3');
                request.setHeader('client_secret', '9fc0007C0eDF4106825DF517a6fB7592');
                request.setHeader('x-correlation-id', '07fEcd485Ca64A48A63f4990F1a38BAB');
                request.setHeader('Content-Type', 'application/json');
                request.setTimeout(120000);
                
                System.debug('Data Recieved to Send: Sending to: '+request.getEndpoint());

                //Converts tome compatible format
                string ad = string.valueOfGmt(Incident.CreatedDate).replace(' ', 'T')+'+01:00';
                system.debug(ad);
                
                //Adds care of party if not null
                String Care = '';
                if (Incident.CDX_Care_of_Party__r.CDX_Location_Name__c != NULL)
                   // Care = '"outBoundCareOfPartyAddID": "'+Incident.CDX_Care_of_Party__r.CDX_Location_Name__c+'",';
                      Care = '"outBoundCareOfPartyAddID": '+Incident.CDX_Care_of_Party__r.CDX_Location_Name__c+',';
                //Adds last modified by if not null
                String LAST = '';
                LAST = '"lastUpdatedBy": "'+UserInfo.getUserId()+'",';
                
                //Adds asset if if not null
                String AstId = '';
                if (Incident.RFO_Asset__r.RFO_TASId__c != NULL)
                    AstId = '"assetID": '+Incident.RFO_Asset__r.RFO_TASId__c+',';
                
                //Builds outbound disposition address to send if not null
                String OutDisp = '';
                if(Incident.CDX_Destination_Consignee__r.CDX_Address__c != NULL)
                    OutDisp = OutDisp+Incident.CDX_Destination_Consignee__r.CDX_Address__c;
                if(Incident.CDX_Destination_Consignee__r.CDX_City__c != NULL)
                    OutDisp = OutDisp+Incident.CDX_Destination_Consignee__r.CDX_City__c;
                if(Incident.CDX_Destination_Consignee__r.CDX_State__c != NULL)
                    OutDisp = OutDisp+Incident.CDX_Destination_Consignee__r.CDX_State__c;
                if(Incident.CDX_Destination_Consignee__r.CDX_Postal_Code__c != NULL)
                    OutDisp = OutDisp+Incident.CDX_Destination_Consignee__r.CDX_Postal_Code__c;
                
                String ConId = '';
                if(Incident.CDX_Destination_Consignee__c != NULL)
                    //ConId = '"outBoundConsigneeAddID": "'+Incident.CDX_Destination_Consignee__r.CDX_Location_Name__c+'",';
                    ConId = '"outBoundConsigneeAddID": '+Incident.CDX_Destination_Consignee__r.CDX_Location_Name__c+',';
                 
                // Get stcc code only from RFO_LastContents__c
                Integer stccCodeInt;
                stccCodeInt = 0;
                if(Incident.RFO_LastContents__c != NULL) {
                    String lastContentsFull  = Incident.RFO_LastContents__c;
                    String[] lastContents = lastContentsFull.split(' ');
                    String stccCode = lastContents[0]; 
                    stccCodeInt = integer.valueof(stccCode);
                }
                
                // "stcc": "'+Incident.CDX_Current_STCC__r.RFO_STCC__c+'",
                // "lastContents": "'+stccCodeInt+'", 
                
                // Set the body as a JSON object
                request.setBody('{"repairType": "'+Incident.RFO_RepairType__c+
                                '", "carStatus": "'+Incident.RFO_CarStatus__c+
                                '", "createdBy": "'+Incident.CreatedByID+
                                '", "customerContactID": '+Incident.CDX_Primary_Contact__r.RFO_ContactId__c+
                                ', "origin": "'+'railforceone'+
                                '", "repairStatus": "'+Incident.RFO_SIStatus__c+
                                '", '+AstId+
                                ' "shopIncidentIdRf1": "'+Incident.Id+
                                '", "outboundDisp": "'+OutDisp+
                                '", '+Care+
                                ' "outboundDispRouting": "'+Incident.RFO_OutboundRoutingInformation__c+
                                '", "freightResp": "'+Incident.RFO_FreightResponsibility__c+
                                '", "customerBroker": '+Incident.CDX_Customer_Broker__c+
                                ', "freightForwarder": '+Incident.CDX_Freight_Forwarder__c+
                                ', '+LAST+ConId+
                                ' "createdDate": "'+ad+'",'+ 
                                '"documentID": [],'+
                                //'"shopIncidentID": "'+Incident.RFO_ShopIncidentID__c+'"'+
                                '"shopIncidentID": '+Incident.RFO_ShopIncidentID__c+
                                '}');
                
                //Prints JSON to logs
                Integer mid = request.getBody().length()/4;
                System.debug('REQUEST BODY START');
                System.debug(request.getBody().substring(0,mid));
                System.debug(request.getBody().substring(mid,mid+mid));
                System.debug(request.getBody().substring(mid+mid, mid+mid+mid));
                System.debug(request.getBody().substring(mid+mid+mid,mid+mid+mid+mid));
                System.debug('REQUEST BODY END');

               
                
                HttpResponse response = http.send(request);
                requestBody = request.getBody();
                responseBody = response.getBody();
                methodType = request.getMethod();
                statusCode = String.valueOf(response.getStatusCode());
                URI = request.getEndpoint();
                
                // Parse the JSON response
                if (response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' +
                                 response.getStatusCode() + ' ' + response.getStatus());
                    System.debug('Reason: '+response.getBody());
                    Error = response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody();   
                    runs += 1;
                } else {
                    System.debug('Recieved A 200: '+response.getStatusCode());
                    System.debug(response.getBody());
                    run = false;
                    runs = 5;
                    success = true;
                }
            }
            else
            {
                run = false;
            }
        }
        
        //If a succesful response is not recieved at 3 tries a post will be made in the api callout failure group
        if (success == false)
        {
            String BodyOfEvent = 'Service Request PUT Not Sent To Tas: \nID of the service request: '+Incident.id+'\nReason: '+Error;   
            FeedItem post = new FeedItem();
            post.ParentId = Label.CDX_ApiFailureGroup;
            post.Body=BodyOfEvent;
            insert post;
            System.debug('post'+post);
        }

        // WRiting to integration log
        System.debug('Going to Integration Utility=====');  
        RFO_IntegrationUtility.createIntegrationLogRecord('RFO_ShopIncident__c', String.valueOf(Incident.id), requestBody, URI, responseBody, statusCode, methodType, 'CDX_SI_Callout');

    }
    
      ////////////////
     //POST CALLOUT//
    ////////////////
    @future(Callout=true)
    public static void SIPost(String sr)
    {
        //Valiables that control run count
        boolean run = true;
        String Error = NULL;
        Integer runs = 0;
        boolean success = false;
        
        //Gets record type
        List<RecordType> rt = [SELECT Id, Name from RecordType where name = 'Submitted' AND SObjectType = 'RFO_ShopIncident__c'];
        system.debug('++++++++++debugpoint1'+ rt);
        
        //Converts JSON into service request Id
        CDX_SI_Callout_Helper SerReq = (CDX_SI_Callout_Helper) JSON.deserialize(sr, CDX_SI_Callout_Helper.class);
        
        //Queries service request
        List<RFO_ShopIncident__c> IncidentList = [SELECT Id, RFO_ShopIncidentID__c, Name, RFO_RepairType__c, RFO_CarStatus__c, RFO_SIStatus__c, RFO_LastContents__c, CDX_Additional_Emails__c, RFO_Customer__c,
                                                  CreatedByID, CDX_Primary_Contact__r.RFO_ContactId__c, CDX_Current_Customer_Commodity__r.CDX_Customer_Commodity_Name__c,
                                                  CDX_Current_STCC__r.RFO_STCC__c, RFO_Asset__r.RFO_TASId__c, CDX_Customer_Comments__c,RFO_Customer__r.Id, CreatedBy.ProfileId, 
                                                  CDX_Current_Customer_Commodity__r.Name, CDX_Current_Customer_Commodity__r.CDX_Customer__r.Name,
                                                  CDX_Current_Customer_Commodity__r.CDX_Car_Type__c, CDX_Current_Customer_Commodity__r.CDX_Bottom_Outlet_Valve_Cap_Gasket_Name__c, 
                                                  CDX_Current_Customer_Commodity__r.CDX_Flange_Gasket_Name__c, CDX_Current_Customer_Commodity__r.CDX_Interior_Lining_Type_Name__c,
                                                  CDX_Current_Customer_Commodity__r.CDX_Interior_Preparation_Name__c, CDX_Current_Customer_Commodity__r.CDX_Interior_Touch_Up_Type_Name__c,
                                                  CDX_Current_Customer_Commodity__r.CDX_Manway_Gasket_Name__c, CDX_Current_Customer_Commodity__r.CDX_Nitrogen_Pad_Type_Name__c,   
                                                  CDX_Current_Customer_Commodity__r.CDX_O_Ring_Name__c, CDX_Current_Customer_Commodity__r.CDX_Is_Car_in_Food_Grade_Service__c, 
                                                  CDX_Current_Customer_Commodity__r.CDX_Is_Car_in_Kosher_Service__c, RecordTypeId, CDX_Bypass_Validation__c,
                                                  RFO_ShopName__c, RFO_Customer__r.RFO_TASId__c, CDX_Current_Location__r.CDX_City__c,
                                                  CDX_Current_Location__r.CDX_Address__c, CDX_Current_Location__r.CDX_State__c, RFO_ShopType__c,
                                                  CDX_Current_Location__r.CDX_Location_Name__c, CDX_Current_Location__r.CDX_Postal_Code__c, CreatedDate
                                                  FROM RFO_ShopIncident__c 
                                                  WHERE Id =: SerReq.request LIMIT 1];
        RFO_ShopIncident__c Incident = IncidentList[0];
        system.debug('++++++++++debugpoint2'+ IncidentList);
                
        //Sets Record type
        Incident.RecordTypeId = rt[0].id;
        
        //Sets Comments
        Incident.CDX_Customer_Comments__c =  CDX_SI_Callout.AmmendComments(Incident);
        //Formats comments for submission  
                
        String comsub = Incident.CDX_Customer_Comments__c.replace('\\ n', '\n');
        comsub = comsub.replace('\n', '\\r\\n');
        comsub = comsub.replace('\n', '  ');
        comsub = comsub.replace('\r\n', '  ');
        comsub = comsub.replace('\r', '  ');
        comsub = comsub.replace('\t', '');
        comsub = comsub.replace('\\', '\\\\');
        comsub = comsub.replace('"', '\\"');
        System.debug('COMMENTS AFTER METHOD EXECUTION: '+comsub);
             
        //Creates Document Array
        List<ContentDocumentLink> docs = [SELECT ID, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: Incident.Id];
        String links = ''; 
        for(ContentDocumentLink x : docs)
        {
            if(links == NULL || links == '')
            {
                links = '{"id": "'+x.Id+'", "documentSource": "RailforceOne"}';
            }else{
                links = links + ', ' + '{"id": "'+x.Id+'", "documentSource": "RailforceOne"}';
            }
        }
        System.debug('Debugstatement3 '+run);
        String requestBody = '';
        String responseBody = '';
        String URI = '';
        String methodType = '';
        String statusCode = '';
		
        while (run == True) {
            if (runs < 2)
            {
                //Send HTTP Request
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(RFO_IntegrationLinks__c.getInstance('ServiceRequest').RFO_APILink__c);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('client_id', '5cd2281f6f8d456baaa5c552d79547c3');
                request.setHeader('client_secret', '9fc0007C0eDF4106825DF517a6fB7592');
                request.setHeader('x-correlation-id', '07fEcd485Ca64A48A63f4990F1a38BAB');
                request.setHeader('Content-Type', 'application/json');
                request.setTimeout(120000);
                
                System.debug('Data Recieved to Send: Sending to: '+request.getEndpoint());
                
                //Value Formatting
                string ad = string.valueOfGmt(Incident.CreatedDate).replace(' ', 'T')+'+01:00';
                system.debug(ad);
                
                String CC = '""';
                if (Incident.CDX_Additional_Emails__c != NULL)
                    CC = '"'+Incident.CDX_Additional_Emails__c+'"';
                
                String AstId = '';
                if (Incident.RFO_Asset__r.RFO_TASId__c != NULL)
                    AstId = '"assetID": '+Incident.RFO_Asset__r.RFO_TASId__c+',';
                
                //Builds inbound disposition address to send if not null
                String inDisp = '';
                if(Incident.CDX_Current_Location__r.CDX_Address__c != NULL)
                    inDisp = inDisp+Incident.CDX_Current_Location__r.CDX_Address__c;
                if(Incident.CDX_Current_Location__r.CDX_City__c != NULL)
                    inDisp = inDisp+Incident.CDX_Current_Location__r.CDX_City__c;
                if(Incident.CDX_Current_Location__r.CDX_State__c != NULL)
                    inDisp = inDisp+Incident.CDX_Current_Location__r.CDX_State__c;
                if(Incident.CDX_Current_Location__r.CDX_Postal_Code__c != NULL)
                    inDisp = inDisp+Incident.CDX_Current_Location__r.CDX_Postal_Code__c;
                
                // Get stcc code only from RFO_LastContents__c
               
                Integer stccCodeInt;
                stccCodeInt = 0;
                if(Incident.RFO_LastContents__c != NULL) {
                    String lastContentsFull  = Incident.RFO_LastContents__c;
                    String[] lastContents = lastContentsFull.split(' ');
                    String stccCode = lastContents[0]; 
                    stccCodeInt = integer.valueof(stccCode);
                }
                
                // Set the body as a JSON object
                request.setBody('{"repairType": "'+Incident.RFO_RepairType__c+
                                '", "carStatus": "'+Incident.RFO_CarStatus__c+
                                '", "createdBy": "'+Incident.CreatedByID+
                                '", "origin": "'+'railforceone'+
                                '", "lastContents": '+stccCodeInt+
                                ', "repairStatus": "'+Incident.RFO_SIStatus__c+
                                '", "commodityName": "'+Incident.CDX_Current_Customer_Commodity__r.CDX_Customer_Commodity_Name__c+
                                '", "stcc": "'+Incident.CDX_Current_STCC__r.RFO_STCC__c+
                                '", '+AstId+
                                ' "shopIncidentIdRf1": "'+Incident.Id+
                                '", "address": "'+Incident.CDX_Current_Location__r.CDX_Location_Name__c+
                                '", "customerID": '+Incident.RFO_Customer__r.RFO_TASId__c+
                                ', "customerContactID": '+Incident.CDX_Primary_Contact__r.RFO_ContactId__c+
                                ', "createdDate": "'+ad+'",'+
                                '"documentID": ['+links+'],'+
                                '"inboundRouting": "'+inDisp+'",'+
                                '"interNoteCustomer": "'+comsub+'",'+
                                '"shopType": "'+Incident.RFO_ShopType__c+'"'+
                                '}');
                
                //Prints JSON to logs
                System.debug('REQUEST BODY START');
                Integer mid = request.getBody().length()/6;
                System.debug(request.getBody().substring(0,mid));
                System.debug(request.getBody().substring(mid,mid+mid));
                System.debug(request.getBody().substring(mid+mid, mid+mid+mid));
                System.debug(request.getBody().substring(mid+mid+mid,mid+mid+mid+mid));
                System.debug(request.getBody().substring(mid+mid+mid+mid,mid+mid+mid+mid+mid));
                System.debug(request.getBody().substring(mid+mid+mid+mid+mid,mid+mid+mid+mid+mid+mid));
                System.debug('REQUEST BODY END');
                
                HttpResponse response = http.send(request);
                requestBody = request.getBody();
                responseBody = response.getBody();
                methodType = request.getMethod();
                statusCode = String.valueOf(response.getStatusCode());
                URI = request.getEndpoint();
                
                System.debug('RESPONSE RECIEVED: '+response.getStatusCode() + ' ' + response.getStatus());
                // Parse the JSON response
                if (response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' +
                                 response.getStatusCode() + ' ' + response.getStatus());
                    System.debug('Reason: '+response.getBody());
                    Error = response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody();   
                    runs += 1;
                } else {
                    System.debug(response.getBody());
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());   
                    Incident.RFO_ShopIncidentID__c = String.valueOf(m.get('shopIncidentID'));
                    Incident.Name = Incident.RFO_ShopIncidentID__c; 
                    system.debug(Incident.RFO_ShopIncidentID__c);
                    Incident.CDX_Bypass_Validation__c = True;
                    run = false;
                    runs = 5;
                    success = true;
                    update Incident;
                   
                   Incident.CDX_Bypass_Validation__c = false;
					update Incident;                    
                    
                }

            }
            else
            {
                run = false;
            }
        }
        
        //If a successful response is not recieved after 3 tries, a post is made in the api failure chatter group
        if (success == false)
        {
            String BodyOfEvent = 'Service Request POST Not Sent To Tas: \nID of the service request: '+Incident.id+'\nReason: '+Error;
            FeedItem post = new FeedItem();
            post.ParentId = Label.CDX_ApiFailureGroup;
            post.Body=BodyOfEvent;
            insert post;
            System.debug('post'+post);
        }

        // WRiting to integration log
        System.debug('Going to Integration Utility=====');  
        RFO_IntegrationUtility.createIntegrationLogRecord('RFO_ShopIncident__c', String.valueOf(Incident.id), requestBody, URI, responseBody, statusCode, methodType, 'CDX_SI_Callout');
    }
    
    public static String AmmendComments(RFO_ShopIncident__c Incident)
    {
        System.debug('IN AMEND COMMENTS');
        String Comments = '';
        Comments += Incident.CDX_Customer_Comments__c;

        System.debug('COMMENTS BEFORE DETAILS AMMENDED: '+Comments);
        //Sets Comments
        String coms = '\n \n' + 'Customer Commodity Details: ' + '\n' +
            'Name: ' + Incident.CDX_Current_Customer_Commodity__r.CDX_Customer_Commodity_Name__c + '\n' +
            'Number: '+ Incident.CDX_Current_Customer_Commodity__r.Name + '\n' +
            'Account: ' + Incident.CDX_Current_Customer_Commodity__r.CDX_Customer__r.Name + '\n' +
            'Car Type: '+ Incident.CDX_Current_Customer_Commodity__r.CDX_Car_Type__c + '\n' +
            'Bottom Outlet Valve: ' + Incident.CDX_Current_Customer_Commodity__r.CDX_Bottom_Outlet_Valve_Cap_Gasket_Name__c + '\n' +
            'Flange Gasket Name: '+ Incident.CDX_Current_Customer_Commodity__r.CDX_Flange_Gasket_Name__c + '\n' +
            'Interior Linig Type Nam: ' + Incident.CDX_Current_Customer_Commodity__r.CDX_Interior_Lining_Type_Name__c + '\n' +
            'Interior Preparation Name: '+ Incident.CDX_Current_Customer_Commodity__r.CDX_Interior_Preparation_Name__c + '\n' +
            'Interior Touch Up Type Name: ' + Incident.CDX_Current_Customer_Commodity__r.CDX_Interior_Touch_Up_Type_Name__c + '\n' +
            'Manway Gasket Name: '+ Incident.CDX_Current_Customer_Commodity__r.CDX_Manway_Gasket_Name__c + '\n' +
            'Nitrogen Pad Type Name: ' + Incident.CDX_Current_Customer_Commodity__r.CDX_Nitrogen_Pad_Type_Name__c + '\n' +
            'O Ring Name: '+ Incident.CDX_Current_Customer_Commodity__r.CDX_O_Ring_Name__c + '\n' +
            'Car Food Service Grade?: ' + Incident.CDX_Current_Customer_Commodity__r.CDX_Is_Car_in_Food_Grade_Service__c + '\n' +
            'Car Kosher Service?: '+ Incident.CDX_Current_Customer_Commodity__r.CDX_Is_Car_in_Kosher_Service__c;
        Comments = Comments+coms;
        System.debug('COMMENTS AFTER DETAILS AMMENDED: '+Comments);
        return Comments;
    }
}