trigger CDX_Customer_Commodity_Link_Trigger on CDX_Commodity_Junction__c (after insert) {
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter)
    {
        //Commodity Callout Code
        for(CDX_Commodity_Junction__c com : Trigger.new)
        {
            //Create Helper Class Object
            CDX_Cust_Com_Callout_Helper req = new CDX_Cust_Com_Callout_Helper(com.Customer_Commodity__c);
            
            if (Trigger.isInsert){
                if (!test.isrunningtest())
                {
                    //Call Callout Class
                    CDX_Cust_Com_Callout.CustComPut(JSON.serialize(req));//Commented for Execute Anon Testing
                }
            }
        }
    }
}