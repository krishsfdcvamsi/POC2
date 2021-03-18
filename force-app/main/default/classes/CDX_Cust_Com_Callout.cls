public class CDX_Cust_Com_Callout {
    //POST CALLOUT
    @future(Callout=true)
    public static void CustComPost(String com)
    {
        //Variables that control run time
        boolean run = true;
        String Error = NULL;
        Integer runs = 0;
        boolean success = false;

        CDX_Cust_Com_Callout_Helper ComHelper = NULL;
        ComHelper = (CDX_Cust_Com_Callout_Helper) JSON.deserialize(com, CDX_Cust_Com_Callout_Helper.class);
        
      
        
        String query = '';
        String SobjectApiName = 'Customer_Commodity__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String strFields = '';
        for(String fieldName : fieldMap.keyset() )
        {
            if(strFields == NULL || strFields == '')
            {
                strFields = fieldName;
            }else{
                strFields = strFields + ' , ' + fieldName;
            }
        }
        
        query = 'SELECT ' + strFields + ', CDX_O_Ring__r.Name, CDX_Nitrogen_Pad_Type__r.Name,'+
            ' CDX_Manway_Gasket__r.Name, CDX_Interior_Touch_Up_Type__r.Name, CDX_Interior_Preparation__r.Name, '+
            'CDX_Flange_Gasket__r.Name, CDX_Bottom_Outlet_Valve_Cap_Gasket__r.Name, '+
            ' CDX_O_Ring__r.CDX_Value__c, CDX_Nitrogen_Pad_Type__r.CDX_Value__c,'+
            ' CDX_Manway_Gasket__r.CDX_Value__c, CDX_Interior_Touch_Up_Type__r.CDX_Value__c, CDX_Interior_Preparation__r.CDX_Value__c, '+
            'CDX_Flange_Gasket__r.CDX_Value__c, CDX_Bottom_Outlet_Valve_Cap_Gasket__r.CDX_Value__c, '+
            'CDX_Customer__r.RFO_TASId__c, CDX_ValidatedbyID__r.Lan_Id__c, CDX_Interior_Lining_Type__r.Name, CDX_Interior_Lining_Type__r.CDX_Value__c '+ 
            'FROM '+ SobjectApiName + ' WHERE Id = \''+ComHelper.CustComId+'\' LIMIT 1';
        List<Customer_Commodity__c> foundcoms = Database.query(query);
        Customer_Commodity__c custcom = foundcoms[0];

              //Assigning variables for Integration Log
              String requestBody = '';
              String responseBody = '';
              String URI = '';
              String methodType = '';
              String statusCode = '';

        while (run == True) {
            if (runs < 4)
            {
                //Sends HTTP Request
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(RFO_IntegrationLinks__c.getInstance('CustomerCommodity').RFO_APILink__c);
                request.setMethod('POST');
                request.setHeader('client_id', '5cd2281f6f8d456baaa5c552d79547c3');
                request.setHeader('client_secret', '9fc0007C0eDF4106825DF517a6fB7592');
                request.setHeader('x-correlation-id', '07fEcd485Ca64A48A63f4990F1a38BAB');
                request.setHeader('Content-Type', 'application/json');
                request.setTimeout(120000); 
                system.debug(request.getEndpoint());
                
                //Integer Fields
                String acc = '';
                if (custcom.CDX_Customer__r.RFO_TASId__c != NULL)
                    acc = '"accountId": "'+custcom.CDX_Customer__r.RFO_TASId__c+'",';
                
                string cd = string.valueOfGmt(custcom.CreatedDate).replace(' ', 'T')+'.000Z';
                system.debug(cd);
                
                string lmd = string.valueOfGmt(custcom.LastModifiedDate).replace(' ', 'T')+'+01:00';
                system.debug(lmd);
                
                //Create Arrays
                List<ContentDocumentLink> Links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: custcom.Id];
                String ConDocs = '';
                if (Links.size() > 0)
                {
                    ConDocs = '"contentDocumentLink": [';
                    
                    String arraybody = '';
                    for(ContentDocumentLink alink : Links)
                    {
                        if(arraybody == NULL || arraybody == '')
                        {
                            arraybody = '{"id": "'+alink.Id+'", "documentSource": "RailforceOne"}';
                        }else{
                            arraybody = arraybody + ', ' + '{"id": "'+alink.Id+'", "documentSource": "RailforceOne"}';
                        }
                    }
                    
                    ConDocs = ConDocs+arraybody+'],';
                }
                
                List<CDX_Commodity_Junction__c> junct = [SELECT Id, STCC__r.RFO_STCC__c FROM CDX_Commodity_Junction__c WHERE Customer_Commodity__c =: custcom.Id];
                String stcc = '';
                System.debug('STCC\'s FOUND: '+junct.size());
                if (junct.size() > 0)
                {
                    stcc = '"contentDocumentLink": [';
                    
                    String arraybody = '';
                    for(CDX_Commodity_Junction__c stick : junct)
                    {
                        if(arraybody == NULL || arraybody == '')
                        {
                            arraybody = '{"customerCommoditySTCCid": "'+stick.Id+'", "stcc": "'+stick.STCC__r.RFO_STCC__c+'"}';
                        }else{
                            arraybody = arraybody + ', ' + '{"customerCommoditySTCCid": "'+stick.Id+'", "stcc": "'+stick.STCC__r.RFO_STCC__c+'"}';
                        }
                    }
                    
                    stcc = stcc+arraybody+'],';
                }                   
                
                //Validation
                String Val = '';
                string vd = string.valueOfGmt(custcom.CDX_Validated_Date__c).replace(' ', 'T')+'.000Z';
                system.debug(vd);
                
                if(custcom.CDX_Validated__c == true)
                {
                    vd = string.valueOfGmt(custcom.CDX_Validated_Date__c).replace(' ', 'T')+'.000Z';
                    system.debug(vd);
                }
                
                
                String car = custcom.CDX_Car_Type__c.replace(' Car', '');
                car = car.replace(' ', '');
                
                String Bov = '"bovGasket": null,';
                String Flange = '"flangeGasket": null,';
                String IntLine = 'null';
                String IntPrep = '"interiorPrep": null,';
                String IntTouch = '"interiorTouchUpType": null,';
                String Manway = '"manwayGasket": null,';
                String Nitro = '"nitrogenPad": null,';
                String Oring = '"oring": null,';
                String OtherNotes = '"ccssNotes": null,';
                system.debug('othernotes: '+ OtherNotes);   
                if(custcom.CDX_Other_Requirements_Notes__c != NULL)
                {
                    OtherNotes = '"ccssNotes": ' + '"' +custcom.CDX_Other_Requirements_Notes__c.replace('\n', '\\r\\n')+'",';
                }
                system.debug('othernotes replaced: '+ OtherNotes);                  
                String Member = '';
                if(car == 'Tank')
                {
                    if(custcom.CDX_Manway_Gasket__c != NULL)
                    {
                        if (custcom.CDX_Manway_Gasket__r.CDX_Value__c.toLowerCase() != 'unknown')
                            Manway =  '"manwayGasket": "'+custcom.CDX_Manway_Gasket__r.Name.replace('"', '\\"')+'",';
                    }
                    
                    if(custcom.CDX_Bottom_Outlet_Valve_Cap_Gasket__c != NULL)
                    {
                        if(custcom.CDX_Bottom_Outlet_Valve_Cap_Gasket__r.CDX_Value__c.toLowerCase() != 'unknown')
                            Bov = '"bovGasket": "'+custcom.CDX_Bottom_Outlet_Valve_Cap_Gasket__r.Name.replace('"', '\\"')+'",';
                    }                    
                    
                    if(custcom.CDX_Flange_Gasket__c != NULL)
                    {
                        if(custcom.CDX_Flange_Gasket__r.CDX_Value__c.toLowerCase() != 'unknown')
                            Flange = '"flangeGasket": "'+custcom.CDX_Flange_Gasket__r.Name.replace('"', '\\"')+'",';
                    }
                    
                    if(custcom.CDX_O_Ring__c != Null)
                    {
                        if(custcom.CDX_O_Ring__r.CDX_Value__c.toLowerCase() != 'unknown')
                            Oring = '"oring": "'+custcom.CDX_O_Ring__r.Name.replace('"', '\\"')+'",';
                    }
                    
                    if(custcom.CDX_Nitrogen_Pad_Type__c != NULL)
                    {
                        if(custcom.CDX_Nitrogen_Pad__c == True && custcom.CDX_Nitrogen_Pad_Type__r.CDX_Value__c.toLowerCase() != 'unknown')
                            Nitro = '"nitrogenPad": "'+ custcom.CDX_Nitrogen_Pad_Type_Name__c.replace('"', '\\"')+'",';
                    }
                    
                    Member = '"memberOfRideTightProgram": '+custcom.CDX_Member_of_Fittings_Progam__c+',';
                }
                
                if(custcom.CDX_Interior_Lining_Type__c != NULL)
                {
                    if(custcom.CDX_Interior_Lining_Type__r.CDX_Value__c.toLowerCase() != 'unknown')
                        IntLine = '"'+custcom.CDX_Interior_Lining_Type__r.Name.replace('"', '\\"')+'"';
                }      
                
                if(custcom.CDX_Interior_Preparation__c != NULL)
                {
                    if(custcom.CDX_Interior_Preparation__r.CDX_Value__c.toLowerCase() != 'unknown')
                        IntPrep = '"interiorPrep": "'+custcom.CDX_Interior_Preparation_Name__c.replace('"', '\\"')+'",';
                }
                
             //   if(custcom.CDX_Interior_Touch_Up_Type__r != NULL && custcom.CDX_Interior_Touch_Up_Type__r.CDX_Value__c.toLowerCase() != 'unknown')
             //   {
             //       IntTouch = '"interiorTouchUpType": "'+custcom.CDX_Interior_Touch_Up_Type_Name__c.replace('"', '\\"')+'",';
             //   }
    
                // Set the body as a JSON object
                request.setBody('{"customerCommodityIdRF1": "'+custcom.Id+'",'+
                                //'"accountId": "'+custcom.CDX_Customer__r.RFO_TASId__c+'",'+
                                '"accountId": '+custcom.CDX_Customer__r.RFO_TASId__c+','+
                                '"customerCommodityName": "'+custcom.CDX_Customer_Commodity_Name__c+'",'+
                                //'"active": "'+custcom.CDX_Active__c+'",'+
                                '"active": '+custcom.CDX_Active__c+','+
                                '"createdDate": "'+cd+'",'+
                                '"userId": "'+/*'005S000000IVWi9IAH'*/custcom.CreatedById+'",'+ 
                                '"validated": '+custcom.CDX_Is_Validated__c+','+
                                '"carType": "'+car+'",'+ 
                                OtherNotes+        
                                //'"validatedBy": '+custcom.CDX_ValidatedbyID__r.Lan_Id__c+','+ 
                                '"validatedByRF1": "'+custcom.CDX_ValidatedbyID__c+'",'+ 
                                //'"validatedDate": '+custcom.CDX_Validated_Date__c+','+
                                '"validatedDate": "'+vd+'",'+
                                Nitro+ 
                                Oring+
                                Flange+
                                Bov+
                                Manway+
                                '"foodGradeService": '+custcom.CDX_Is_Car_in_Food_Grade_Service__c+','+
                                '"kosherService": '+custcom.CDX_Is_Car_in_Kosher_Service__c+','+ 
                                IntPrep+ 
                                '"interiorLiningApplicable": '+custcom.CDX_Interior_Lining__c+', '+
                                '"interiorLiningSpec": '+IntLine+','+ 
                                Member+
                                '"customerCommoditySTCC": []'+ 
                                '}');
             
                Integer mid = request.getBody().length()/4;System.debug(' ');
                
                System.debug('REQUEST BODY START');
                System.debug('FULL BODY');
                System.debug(request.getBody());
                System.debug('SEGMENTED');
                System.debug(request.getBody().substring(0,mid));
                System.debug(request.getBody().substring(mid,mid+mid));
                System.debug(request.getBody().substring(mid+mid, mid+mid+mid));
                System.debug(request.getBody().substring(mid+mid+mid,mid+mid+mid+mid));
                System.debug('REQUEST BODY END');
                System.debug(' ');
                
                HttpResponse response = http.send(request);
                requestBody = request.getBody();
                responseBody = response.getBody();
                methodType = request.getMethod();
                statusCode = String.valueOf(response.getStatusCode());
                URI = request.getEndpoint();
                
                // Parse the JSON response
                if (response.getStatusCode() != 201 && response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' +
                                 response.getStatusCode() + ' ' + response.getStatus());
                    System.debug('Reason: '+response.getBody());
                    Error = response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody();   
                    runs += 1;
                } else {
                    System.debug(response.getBody());
                    run = false;
                    runs = 5;
                    success = true;
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody().toLowerCase());
                    //    System.debug('Custcom.Name ->' + m.get('customerCommodityIdTAS'));
                    // System.debug('Custcom.Name Int->' + Integer.valueOf(m.get('customerCommodityIdTAS')));
                    // Integer custcomNameInt = Integer.valueOf(m.get('customerCommodityIdTAS'));
                    // custcom.Name__c = String.valueOf(custcomNameInt);
                    // System.debug('Custcom.Name ->' + custcom.Name__c);
                    custcom.Name__c = String.valueOf(m.get('customercommodityidtas'));
                    System.debug( custcom.Name__c);
                    update custcom;
                }
            }
            else
            {
                run = false;
            }
        }
        //Post to API Failure chatter group in the event of a failure
        if (success == false)
        {
            String BodyOfEvent = 'Customer Commodity POST was not sent: '+custcom.id+'\nReason: '+Error;
            FeedItem post = new FeedItem();
            post.ParentId = Label.CDX_ApiFailureGroup;
            post.Body=BodyOfEvent;
            //insert post;
            System.debug('post'+post);
        }

            // WRiting to integration log
             System.debug('Going to Integration Utility=====');  
             RFO_IntegrationUtility.createIntegrationLogRecord('Customer_Commodity__c', String.valueOf(custcom.Id), requestBody, URI, responseBody, statusCode, methodType, 'CDX_Cust_Com_Callout');
       
    }
    
    @future(Callout=true)
    public static void CustComPut(String com)
    {
        CDX_Cust_Com_Callout_Helper ComHelper = NULL;
        ComHelper = (CDX_Cust_Com_Callout_Helper) JSON.deserialize(com, CDX_Cust_Com_Callout_Helper.class);
        System.debug('Post Callout ID: '+ComHelper.CustComId);
        String query = '';
        String SobjectApiName = 'Customer_Commodity__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String strFields = '';
        
        for(String fieldName : fieldMap.keyset() )
        {
            if(strFields == NULL || strFields == '')
            {
                strFields = fieldName;
            }else{
                strFields = strFields + ' , ' + fieldName;
            }
        }
        
        query = 'SELECT ' + strFields + ', CDX_O_Ring__r.Name, CDX_Nitrogen_Pad_Type__r.Name,'+
            ' CDX_Manway_Gasket__r.Name, CDX_Interior_Touch_Up_Type__r.Name, CDX_Interior_Preparation__r.Name, '+
            'CDX_Flange_Gasket__r.Name, CDX_Bottom_Outlet_Valve_Cap_Gasket__r.Name, '+
            ' CDX_O_Ring__r.CDX_Value__c, CDX_Nitrogen_Pad_Type__r.CDX_Value__c,'+
            ' CDX_Manway_Gasket__r.CDX_Value__c, CDX_Interior_Touch_Up_Type__r.CDX_Value__c, CDX_Interior_Preparation__r.CDX_Value__c, '+
            'CDX_Flange_Gasket__r.CDX_Value__c, CDX_Bottom_Outlet_Valve_Cap_Gasket__r.CDX_Value__c, '+
            'CDX_Customer__r.RFO_TASId__c, CDX_ValidatedbyID__r.Lan_Id__c, CDX_Interior_Lining_Type__r.Name, CDX_Interior_Lining_Type__r.CDX_Value__c '+ 
            'FROM '+ SobjectApiName + ' WHERE Id = \''+ComHelper.CustComId+'\' LIMIT 1';
        List<Customer_Commodity__c> foundcoms = Database.query(query);
        Customer_Commodity__c custcom = foundcoms[0];
        boolean run = true;
        String Error = NULL;
        Integer runs = 0;
        boolean success = false;
        
        //Assigning variables for Integration Log
        String requestBody = '';
        String responseBody = '';
        String URI = '';
        String methodType = '';
        String statusCode = '';

        while (run == True) {
            if (runs < 4)
            {
                
                //Sends HTTP Request
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(RFO_IntegrationLinks__c.getInstance('CustomerCommodity').RFO_APILink__c+'/'+custcom.Name__c);
                request.setMethod('PUT');
                request.setHeader('client_id', '5cd2281f6f8d456baaa5c552d79547c3');
                request.setHeader('client_secret', '9fc0007C0eDF4106825DF517a6fB7592');
                request.setHeader('x-correlation-id', '07fEcd485Ca64A48A63f4990F1a38BAB');
                request.setHeader('Content-Type', 'application/json');
                request.setTimeout(120000); 
                system.debug(request.getEndpoint());
                
                //--------------
                //Integer Fields
                String acc = '';
                if (custcom.CDX_Customer__r.RFO_TASId__c != NULL)
                    acc = '"accountId": "'+custcom.CDX_Customer__r.RFO_TASId__c+'",';
                
                string cd = string.valueOfGmt(custcom.CreatedDate).replace(' ', 'T')+'.000Z';
                system.debug(cd);
                
                string lmd = string.valueOfGmt(custcom.LastModifiedDate).replace(' ', 'T')+'+01:00';
                system.debug(lmd);
                
                //-------------
                //Create Arrays
                List<ContentDocumentLink> Links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: custcom.Id];
                String ConDocs = '';
                if (Links.size() > 0)
                {
                    String arraybody = '';
                    for(ContentDocumentLink alink : Links)
                    {
                        if(arraybody == NULL || arraybody == '')
                        {
                            arraybody = '{"id": "'+alink.Id+'", "documentSource": "RailforceOne"}';
                        }else{
                            arraybody = arraybody + ', ' + '{"id": "'+alink.Id+'", "documentSource": "RailforceOne"}';
                        }
                    }
                    
                    ConDocs = ConDocs+arraybody;
                }
                System.debug(ConDocs);
                
                List<CDX_Commodity_Junction__c> junct = [SELECT Id, STCC__r.RFO_STCC__c, Name FROM CDX_Commodity_Junction__c WHERE Customer_Commodity__c =: custcom.Id];
                String stcc = '';
                System.debug('STCC\'s FOUND: '+junct.size());
                if (junct.size() > 0)
                {
                    String arraybody = '';
                    for(CDX_Commodity_Junction__c stick : junct)
                    {
                        if(arraybody == NULL || arraybody == '')
                        {
                            arraybody = '{"customerCommoditySTCCid": "'+stick.STCC__r.RFO_STCC__c+'", "stcc": "'+stick.STCC__r.RFO_STCC__c+'"}';
                        }else{
                            arraybody = arraybody + ', ' + '{"customerCommoditySTCCid": "'+stick.STCC__r.RFO_STCC__c+'", "stcc": "'+stick.STCC__r.RFO_STCC__c+'"}';
                        }
                    }
                    
                    stcc = stcc+arraybody;
                }           
                System.debug(stcc);
                
                //----------
                //Validation
                String Val = '';
                string vd = string.valueOfGmt(custcom.CDX_Validated_Date__c).replace(' ', 'T')+'.000Z';
                system.debug(vd);
                
                if(custcom.CDX_Validated__c == true)
                {
                    vd = string.valueOfGmt(custcom.CDX_Validated_Date__c).replace(' ', 'T')+'.000Z';
                    system.debug(vd);
                }
                
                
                String car = custcom.CDX_Car_Type__c.replace(' Car', '');
                car = car.replace(' ', '');
                
                String Bov = '"bovGasket": null,';
                String Flange = '"flangeGasket": null,';
                String IntLine = 'null';
                String IntPrep = '"interiorPrep": null,';
                String IntTouch = '"interiorTouchUpType": null,';
                String Manway = '"manwayGasket": null,';
                String Nitro = '"nitrogenPad": "null",';
                String Oring = '"oring": null,';
                String OtherNotes = '"ccssNotes": null,';
                system.debug('othernotes: '+ OtherNotes);   
                if(custcom.CDX_Other_Requirements_Notes__c != NULL)
                {
                    OtherNotes = '"ccssNotes": ' + '"' +custcom.CDX_Other_Requirements_Notes__c.replace('\n', '\\r\\n')+'",';
                }
                system.debug('othernotes replaced: '+ OtherNotes);                
                String Member = '';
                if(car == 'Tank')
                {
                    if(custcom.CDX_Manway_Gasket__c != NULL)
                    {
                        if (custcom.CDX_Manway_Gasket__r.CDX_Value__c.toLowerCase() != 'unknown')
                            Manway =  '"manwayGasket": "'+custcom.CDX_Manway_Gasket__r.Name.replace('"', '\\"')+'",';
                    }
                    
                    if(custcom.CDX_Bottom_Outlet_Valve_Cap_Gasket__c != NULL)
                    {
                        if(custcom.CDX_Bottom_Outlet_Valve_Cap_Gasket__r.CDX_Value__c.toLowerCase() != 'unknown')
                            Bov = '"bovGasket": "'+custcom.CDX_Bottom_Outlet_Valve_Cap_Gasket__r.Name.replace('"', '\\"')+'",';
                    }                    
                    
                    if(custcom.CDX_Flange_Gasket__c != NULL)
                    {
                        if(custcom.CDX_Flange_Gasket__r.CDX_Value__c.toLowerCase() != 'unknown')
                            Flange = '"flangeGasket": "'+custcom.CDX_Flange_Gasket__r.Name.replace('"', '\\"')+'",';
                    }
                    
                    if(custcom.CDX_O_Ring__c != Null)
                    {
                        if(custcom.CDX_O_Ring__r.CDX_Value__c.toLowerCase() != 'unknown')
                            Oring = '"oring": "'+custcom.CDX_O_Ring__r.Name.replace('"', '\\"')+'",';
                    }
                    
                    if(custcom.CDX_Nitrogen_Pad_Type__c != NULL)
                    {
                        if(custcom.CDX_Nitrogen_Pad__c == True && custcom.CDX_Nitrogen_Pad_Type__r.CDX_Value__c.toLowerCase() != 'unknown')
                            Nitro = '"nitrogenPad": "'+ custcom.CDX_Nitrogen_Pad_Type_Name__c.replace('"', '\\"')+'",';
                    }
                    Member = '"memberOfRideTightProgram": '+custcom.CDX_Member_of_Fittings_Progam__c+',';
                }
                
                if(custcom.CDX_Interior_Lining_Type__c != NULL)
                {
                    if(custcom.CDX_Interior_Lining_Type__r.CDX_Value__c.toLowerCase() != 'unknown')
                        IntLine = '"'+custcom.CDX_Interior_Lining_Type__r.Name.replace('"', '\\"')+'"';
                }      
                
                if(custcom.CDX_Interior_Preparation__c != NULL)
                {
                    if(custcom.CDX_Interior_Preparation__r.CDX_Value__c.toLowerCase() != 'unknown')
                        IntPrep = '"interiorPrep": "'+custcom.CDX_Interior_Preparation_Name__c.replace('"', '\\"')+'",';
                }
                
           //     if(custcom.CDX_Interior_Touch_Up_Type__r != NULL && custcom.CDX_Interior_Touch_Up_Type__r.CDX_Value__c.toLowerCase() != 'unknown')
           //     {
           //         IntTouch = '"interiorTouchUpType": "'+custcom.CDX_Interior_Touch_Up_Type_Name__c.replace('"', '\\"')+'",';
           //     }
                   
                // Set the body as a JSON object
                request.setBody('{"customerCommodityIdRF1": "'+custcom.Id+'",'+
                                //'"accountId": "'+custcom.CDX_Customer__r.RFO_TASId__c+'",'+
                                '"accountId": '+custcom.CDX_Customer__r.RFO_TASId__c+','+
                                '"customerCommodityName": "'+custcom.CDX_Customer_Commodity_Name__c+'",'+
                                //'"active": "'+custcom.CDX_Active__c+'",'+
                                '"active": '+custcom.CDX_Active__c+','+
                                '"createdDate": "'+cd+'",'+
                                '"userId": "'+custcom.CreatedById+'",'+ 
                                '"validated": '+custcom.CDX_Is_Validated__c+','+
                                '"carType": "'+car+'",'+
                                OtherNotes+        
                                //'"validatedBy": '+custcom.CDX_ValidatedbyID__r.Lan_Id__c+','+ 
                                '"validatedByRF1": "'+custcom.CDX_ValidatedbyID__c+'",'+ 
                                '"validatedDate": "'+vd+'",'+ 
                                Nitro+ 
                                Oring+
                                Flange+
                                Bov+
                                Manway+
                                '"foodGradeService": '+custcom.CDX_Is_Car_in_Food_Grade_Service__c+','+
                                '"kosherService": '+custcom.CDX_Is_Car_in_Kosher_Service__c+','+ 
                                IntPrep+ 
                                '"interiorLiningApplicable": '+custcom.CDX_Interior_Lining__c+', '+
                                '"interiorLiningSpec": '+IntLine+','+ 
                                Member+
                                '"customerCommoditySTCC": ['+stcc+'],'+ 
                                '"contentDocumentLink": ['+ConDocs+']'+
                                '}');        

                Integer mid = request.getBody().length()/4;System.debug(' ');
                
                System.debug('REQUEST BODY START');
                System.debug('FULL BODY');
                System.debug(request.getBody());
                System.debug('SEGMENTED');
                System.debug(request.getBody().substring(0,mid));
                System.debug(request.getBody().substring(mid,mid+mid));
                System.debug(request.getBody().substring(mid+mid, mid+mid+mid));
                System.debug(request.getBody().substring(mid+mid+mid,mid+mid+mid+mid));
                System.debug('REQUEST BODY END');
                System.debug(' ');
                
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
        
        //Post to API Failure chatter group in the event of a failure
        if (success == false)
        {
            String BodyOfEvent = 'Customer Commodity PUT was not sent: '+custcom.id+'\nReason: '+Error;
            FeedItem post = new FeedItem();
            post.ParentId = Label.CDX_ApiFailureGroup;
            post.Body=BodyOfEvent;
            insert post;
            System.debug('post'+post);
        }

        // WRiting to integration log
        System.debug('Going to Integration Utility=====');  
        RFO_IntegrationUtility.createIntegrationLogRecord('Customer_Commodity__c', String.valueOf(custcom.Id), requestBody, URI, responseBody, statusCode, methodType, 'CDX_Cust_Com_Callout');
    
    }
}