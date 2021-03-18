trigger CDX_Customer_Commodity_Trigger on Customer_Commodity__c (after insert, after update) {
    
    //Commodity Callout Code
    if(Trigger.isInsert && Trigger.isAfter)
    {
        for(Customer_Commodity__c com : Trigger.new)
        {
            //Create Helper Class Object   
            CDX_Cust_Com_Callout_Helper req = new CDX_Cust_Com_Callout_Helper(com.id);
            
            if (!test.isrunningtest())
            {
                //Call Callout Class
                CDX_Cust_Com_Callout.CustComPost(JSON.serialize(req));//Commented for Execute Anon Testing
            }
        }
    }
    
    //Commodity Callout Code
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        //Commodity Callout Code
        for(Customer_Commodity__c com : Trigger.new)
        {
            //Create Helper Class Object   
            CDX_Cust_Com_Callout_Helper req = new CDX_Cust_Com_Callout_Helper(com.id);
            
            Customer_Commodity__c oldcom = Trigger.oldMap.get(com.ID);
            
            if(oldcom.Name__c != NULL)
            {
                if (!test.isrunningtest())
                {   
                    //Call Callout Class
                    CDX_Cust_Com_Callout.CustComPut(JSON.serialize(req));
                } 
            }
            else
            {
                if(com.Name__c == NULL)
                {
                    if (!test.isrunningtest())
                    {   
                        //Call Callout Class
                        CDX_Cust_Com_Callout.CustComPost(JSON.serialize(req));
                    } 
                }
            }
            
        }
    }
}