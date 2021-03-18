@istest
public class ROICalculatorTest {
    private static Id qlrecordType_TRNTank= Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('RFO_Tank').getRecordTypeId();
    private static Id qlRecordType_CPQ  = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('CPQ_Config').getRecordTypeId();
    @testsetup static void createOptyTestdata()
    {
        
        SBQQ.TriggerControl.disable();
        account acct = CPQUTILITYTEST.createProspectAccounts()[0];
        User u = CPQUTILITYTEST.createUserRecordForCPQ();
        insert u;
        system.debug('createdUserId '+ u.Id);
        acct.RFO_AccountOwner__c  = u.name;
        acct.OwnerId = u.id;
        insert acct;
        account a1=  [select id, RFO_AccountOwner__c,owner.id from account];
        
        List<Contact> contactList = new List<Contact>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        contactList = CPQUTILITYTEST.createContact1(acct);
        Database.insert(contactList);
        commodityList = CPQUTILITYTEST.createCommodity1();
        Database.insert(commodityList);
        Product2 objProduct = CPQUTILITYTEST.createProduct();
        objProduct.RFO_ModelId__c ='1234';
        
        insert objProduct;
        List<RFO_Commodity__c> lstCommi =  CPQUTILITYTEST.createCommodity1();
        insert lstCommi;
        Asset  objAsset = New Asset();
        objAsset.Name = 'TestAsset';
        objAsset.Product2Id  = objProduct.Id;
        objAsset.AccountId = acct.Id;
        objAsset.CDX_Last_Shopped_Commodity__c = commodityList[0].Id;
        objAsset.RFO_DateBuilt__c= date.valueOf('2020-01-01');
        objAsset.IRR_Base_Cost__c = 100000.0;
        objAsset.Betterment_Asset_Key__c =500.0;
        objAsset.Residual_Curve_Id__c='3515';
        insert objAsset;
        //depreciation detailsLs
        List<Residual_Curve__c> rcs = new List<Residual_Curve__c>();
        List<Residual_Betterment__c> rbs = new List<Residual_Betterment__c>();
        DateTime accountingDate = date.valueOf('2020-12-31');
        for(integer g=1;g<60;g++)
        {
            decimal d = decimal.valueOf(g);
            Residual_Curve__c rc = new Residual_Curve__c();
            rc.Residual_Curve_ID__c = objAsset.Residual_Curve_Id__c;
            rc.Residual_Percent__c = (1-(d/100));
            rc.Age_In_Months__c = g+10;
            system.debug('creating rc record '+rc);
            rcs.add(rc);
            
            Residual_Betterment__c rb= new Residual_Betterment__c();
            
            rb.Betterment_Asset_Key__c =  objAsset.Betterment_Asset_Key__c;
            rb.Accounting_Period__c =decimal.valueOf(accountingDate.year()+''+accountingDate.format('MM')+''+accountingDate.day());
            
            rb.Original_Betterment_Value__c = 5945.66;
            rb.Residual_Betterment_Value__c = rb.Original_Betterment_Value__c * rc.Residual_Percent__c;
            system.debug('creating rb record '+rb);
            rbs.add(rb);
            accountingDate = accountingDate.addMonths(1);
        }
        
        insert rcs;
        insert rbs;
        
        List<Assumed_Maintenance__c> ams = new List<Assumed_Maintenance__c>();
        
        Assumed_Maintenance__c am = new Assumed_Maintenance__c();
        
        am.Model_Id__c =  objProduct.RFO_ModelId__c;
        am.Lease_Type__c ='FULL SERVICE LEASE';
        am.Monthly_Maintenance_Amount__c=90.0;
        ams.add(am);
        
        Assumed_Maintenance__c am1 = new Assumed_Maintenance__c();
        
        am1.Model_Id__c =  objProduct.RFO_ModelId__c;
        am1.Lease_Type__c ='NET LEASE';
        am1.Monthly_Maintenance_Amount__c=00.0;
        ams.add(am1);
        
        insert ams;   
        
        //rest
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = CPQUTILITYTEST.createTankOpportunities1(acct, contactList[0]);
        
        Database.insert(oppList);
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = CPQUTILITYTEST.createQuoteTeam();
        Database.insert(quoteTeamRec);
        test.startTest();
        SBQQ__Quote__c cpqQuote, existingQuote;
        
        //test.startTest();
        existingQuote = CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objProduct, 'Existing');
        existingquote.RFO_Quantity__c = 100;
        existingQuote.SBQQ__Account__c=acct.id;
        insert existingQuote;
        
        cpqQuote =CPQUTILITYTEST.createCPQPrimaryQuotewithProductCPQ(oppList[0], quoteTeamRec,objProduct, 'CPQ');
        cpqQuote.Commercial_Quote__c = existingQuote.Id;
        cpqQuote.SBQQ__Account__c = acct.id;
        insert cpqQuote;
        test.stopTest();
        system.assertEquals(cpqQuote.Commercial_Quote__c, existingQuote.Id);
        //cpq line
        List<SBQQ__QuoteLine__c> qli = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c cpqLine =  CPQUTILITYTEST.createQuoteLine(cpqQuote,objProduct);
        cpqLine.RecordTypeId =qlRecordType_CPQ;
        qli.add(cpqLine);
        
        
        SBQQ__QuoteLine__c priceLine =  CPQUTILITYTEST.createQuoteLine(existingQuote,objProduct);
        //qlrecordType_TRNTank
        priceLine.RecordTypeId =qlrecordType_TRNTank;
        priceLine.RFO_LeaseTerm__c = 24;
        priceLine.RFO_LeaseType__c ='Full Service';
        priceLine.RFO_LeaseRate__c = 500;
        qli.add(priceLine);
        insert qli;
        
        
        
        List<Asset_Group__c> ags = new list<Asset_Group__c>();
        for(integer i =0;i<5;i++)
        {
            Asset_Group__c ag = New Asset_Group__c();
            ag.Quote_Line__c = cpqLine.Id;
            ags.add(ag);
        }
        insert ags;
        List<Asset_Lines__c> als = new list<Asset_Lines__c>();
        for(Asset_Group__c a : ags)
        {
            for(integer b = 0; b<100; b++)
            {
                Asset_Lines__c al =  New Asset_Lines__c();
                al.Asset__c = objAsset.Id;
                al.Asset_Group__c = a.Id;
                als.add(al);
            }
            
        }
        insert als;
        
    }
    
    private testmethod static void runROICalc_NoGapItems_Success()
    {
        
        SBQQ.TriggerControl.disable();
        sbqq__quoteline__c priceLine_beforeCalc = [SELECT Id, sbqq__quote__c, Return__c ,RFO_LeaseQty__c,
                                                   RFO_LeaseTerm__c,RFO_LeaseRate__c,RFO_LeaseType__c, 
                                                   Current_Residual_Value__c,Future_Residual_Value__c,
                                                   Maintenance_Total__c, Assumed_Maintenance_Total__c, Maintenance_Gap__c,
                                                   Gap_Analysis_Investment__c,Exposure_cost__c, 
                                                   Betterment_Gap__c  
                                                   FROM SBQQ__QuoteLine__c WHERE recordtypeId=:qlrecordType_TRNTank];
        
        
        
        system.assert(priceLine_beforeCalc.Return__c==0);
        system.assert(priceLine_beforeCalc.Current_Residual_Value__c==0);
        system.assert(priceLine_beforeCalc.Future_Residual_Value__c==0);
        system.debug('zxzz'+priceLine_beforeCalc.Assumed_Maintenance_Total__c);
        system.assert(priceLine_beforeCalc.Assumed_Maintenance_Total__c==null);
        
        
        
        Id quotelineId = priceLine_beforeCalc.Id;
        
        List<sobject> o = [select id, Asset_Group__c, sbqq__quote__c,sbqq__quote__r.Commercial_Quote__c 
                           from SBQQ__QuoteLine__c 
                           where sbqq__quote__r.Commercial_Quote__c =:priceLine_beforeCalc.sbqq__quote__c];
        system.assertEquals(1, o.size());
        system.debug('existing quote id '+ priceLine_beforeCalc.sbqq__quote__c);
        Test.startTest();
        ROICalculator.runCalculateReturn_future(quoteLineId, 0,0,0);
        Test.stopTest();
        
        sbqq__quoteline__c priceLineAfterCalc = [SELECT Id, sbqq__quote__c, Return__c ,RFO_LeaseQty__c,
                                                 RFO_LeaseTerm__c,RFO_LeaseRate__c,RFO_LeaseType__c, 
                                                 Current_Residual_Value__c,Future_Residual_Value__c,
                                                 Maintenance_Total__c, Assumed_Maintenance_Total__c, Maintenance_Gap__c,
                                                 Gap_Analysis_Investment__c,Exposure_cost__c, 
                                                 Betterment_Gap__c  
                                                 FROM SBQQ__QuoteLine__c WHERE Id=:quotelineId];
        
        
        system.assertEquals(priceLine_beforeCalc.RFO_LeaseRate__c, priceLineAfterCalc.RFO_LeaseRate__c);
        system.assert(priceLineAfterCalc.Current_Residual_Value__c>0);
        system.assert(priceLineAfterCalc.Future_Residual_Value__c>0);
        system.assert(priceLineAfterCalc.Assumed_Maintenance_Total__c>0);
        system.assert(priceLineAfterCalc.Return__c<>0);
       // system.assert(priceLineAfterCalc.Assumed_Maintenance_Total__c ==3240000);//90 per month times 5 cars times 72 months
        
        
    }
    private testmethod static void runROICalc_WithGapValues_Success()
    {
        
        SBQQ.TriggerControl.disable();
        sbqq__quoteline__c priceLine_beforeCalc = [SELECT Id, sbqq__quote__c, Return__c ,RFO_LeaseQty__c,
                                                   RFO_LeaseTerm__c,RFO_LeaseRate__c,RFO_LeaseType__c, 
                                                   Current_Residual_Value__c,Future_Residual_Value__c,
                                                   Maintenance_Total__c, Assumed_Maintenance_Total__c, Maintenance_Gap__c,
                                                   Gap_Analysis_Investment__c,Exposure_cost__c, 
                                                   Betterment_Gap__c  
                                                   FROM SBQQ__QuoteLine__c WHERE recordtypeId=:qlrecordType_TRNTank];
        
        
        system.debug('in test: ' + priceLine_beforeCalc.Assumed_Maintenance_Total__c);
        system.assert(priceLine_beforeCalc.Return__c==0);
        system.assert(priceLine_beforeCalc.Current_Residual_Value__c==0);
        system.assert(priceLine_beforeCalc.Future_Residual_Value__c==0);
        system.assert(priceLine_beforeCalc.Assumed_Maintenance_Total__c==null);
        
        Id quotelineId = priceLine_beforeCalc.Id;
        
        List<sobject> o = [select id, Asset_Group__c, sbqq__quote__c,sbqq__quote__r.Commercial_Quote__c 
                           from SBQQ__QuoteLine__c 
                           where sbqq__quote__r.Commercial_Quote__c =:priceLine_beforeCalc.sbqq__quote__c];
        system.assertEquals(1, o.size());
        system.debug('existing quote id '+ priceLine_beforeCalc.sbqq__quote__c);
        Test.startTest();
        ROICalculator.runCalculateReturn_nonBulkified(quoteLineId, 200000,300000,400000);
        Test.stopTest();
        
        sbqq__quoteline__c priceLineAfterCalc = [SELECT Id, sbqq__quote__c, Return__c ,RFO_LeaseQty__c,
                                                 RFO_LeaseTerm__c,RFO_LeaseRate__c,RFO_LeaseType__c, 
                                                 Current_Residual_Value__c,Future_Residual_Value__c,
                                                 Maintenance_Total__c, Assumed_Maintenance_Total__c, Maintenance_Gap__c,
                                                 Gap_Analysis_Investment__c,Exposure_cost__c, 
                                                 Betterment_Gap__c  
                                                 FROM SBQQ__QuoteLine__c WHERE Id=:quotelineId];
        
        
        system.assertEquals(priceLine_beforeCalc.RFO_LeaseRate__c, priceLineAfterCalc.RFO_LeaseRate__c);
        system.assert(priceLineAfterCalc.Current_Residual_Value__c>0);
        system.assert(priceLineAfterCalc.Future_Residual_Value__c>0);
        system.assert(priceLineAfterCalc.Assumed_Maintenance_Total__c>0);
        system.assert(priceLineAfterCalc.Return__c<>0);
      //  system.assert(priceLineAfterCalc.Assumed_Maintenance_Total__c ==3240000);
      //  system.assert(priceLineAfterCalc.Maintenance_Total__c ==3940000);//Assumed_Maintenance_Total__c+3000maint from gap + 4000exposure    
        
    }
}