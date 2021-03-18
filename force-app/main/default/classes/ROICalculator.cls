global class ROICalculator {
    public class ROICalculatorException extends Exception{}
    private boolean doAssetUpdate =false, doPriceLineUpdate=true;
    public void ROICalculator(boolean updateAsset, boolean updateQuoteLine)
    {
        doAssetUpdate=updateAsset;
        doPriceLineUpdate = updateQuoteLine;
    }
    public void ROICalculator(){}
    class BettermentDTO
    {
        public decimal TotalValue{get;set;}
        public integer usefulLife {get;set;}
        public decimal ConsumedCost {get;set;}
        public decimal remainingValue {get;set;}
    }
    class AssetDTO
    {
        public string residualCurve {get;set;}
        public Decimal baseCost {get;set;}
        public string modelId {get;set;}
        public Decimal bettermentKey {get;set;}
        public date buildDate {get;set;}
        public integer leaseMonths {get;set;}
        public string accountingPeriodStart{get;set;}
        public string accountingPeriodEnd {get;set;}
        public date leaseStartDate {get;set;}
        public date leaseEndDate {get;set;}
        public string assetLineId {get;set;}
        public decimal monthlyAssumedMaintenance {get;set;}
        public decimal initialResidualValue {get;set;}
        public decimal futureResidualValue {get;set;}
        public decimal ageInMonthsAtStartofLease {get;set;}
        public decimal ageInMonthsAtEndofLease {get;set;}
        public string residualCurveKeyStart {get;set;}
        public string residualCurveKeyEnd {get;set;}
        public string leaseType {get;set;}
    }
    class pricingScenario
    {
        public date leaseStartDate {get;set;}
        public date leaseEndDate {get;set;}
        public decimal bettermentGap {get;set;}
        
        public Decimal totalAssumedMaintenance {get;set;}
        public Decimal totalInitialAssetCost {get;set;}
        public Decimal totalFinalAssetCost {get;set;}
        public sbqq__quoteline__c quoteLine {get;set;}
        
    }
    @future
    public static void runCalculateReturn_future(string quoteLineId,
                                                 decimal bettermentAmountGap,
                                                 decimal maintanceAmountGap,
                                                 decimal exposure)
    {
        ROICalculator.runCalculateReturn_nonBulkified(quoteLineId,bettermentAmountGap,maintanceAmountGap,exposure);
    }
    public static void runCalculateReturn_nonBulkified(string quoteLineId, 
                                                       decimal bettermentAmountGap,
                                                       decimal maintanceAmountGap,
                                                       decimal exposure)
    {
        
        list<sbqq__quoteline__c> qlines= [SELECT Id, sbqq__quote__c, Return__c ,RFO_LeaseQty__c, 
                                          RFO_LeaseTerm__c,RFO_LeaseRate__c,RFO_LeaseType__c, 
                                          Current_Residual_Value__c,Future_Residual_Value__c,Residual_Betterment_Value__c, 
                                          Maintenance_Total__c, Assumed_Maintenance_Total__c, Maintenance_Gap__c,
                                          Gap_Analysis_Investment__c,Exposure_cost__c,recordTypeId,  
                                          Betterment_Gap__c, sbqq__quote__r.Commercial_Quote__c   
                                          FROM SBQQ__QuoteLine__c WHERE Id=:quotelineId];
        sbqq__quoteline__c line = qlines[0];
        ROICalculator calcInstance = new ROICalculator();
        line.Betterment_Gap__c = bettermentAmountGap;
        line.Maintenance_Gap__c = maintanceAmountGap;
        line.Exposure_cost__c = exposure;
        //TODO verify betterment field/calc
        list<sbqq__quoteline__c> processedLines =calcInstance.calculatePriceLineTotals(qlines);
        
        calcInstance.CalculateReturn(processedLines[0]);     
    }
    
    public static void runCalculateReturn_Bulkified(list<sbqq__quoteline__c> linesToProcess)
    {
        for(sbqq__quoteline__c q : linesToProcess)
        {
            ROICalculator.runCalculateReturn_future(q.Id,0,0,0);
        }
    }
    private void CalculateReturn(SBQQ__QuoteLine__c pricingLine){
        
        decimal Current_Residual_Value = pricingLine.Current_Residual_Value__c;
        decimal Future_Residual_Value = pricingLine.Future_Residual_Value__c;
        decimal totalGapCost = pricingLine.Gap_Analysis_Investment__c;
        decimal bettermentAmountGap =pricingLine.Betterment_Gap__c==null? 0:pricingLine.Betterment_Gap__c;
        decimal maintanceAmountGap = pricingLine.Maintenance_Gap__c==null? 0:pricingLine.Maintenance_Gap__c;
        decimal Exposure = pricingLine.Exposure_cost__c;
        decimal residualBetterment = pricingLine.Residual_Betterment_Value__c;
        decimal assumedMaintenance = pricingLine.Assumed_Maintenance_Total__c;
        
        try{
            
            system.debug('pricingLine>>>>>>>>'+pricingLine);
            system.debug('Residual_Betterment_Value__c '+ pricingLine.Residual_Betterment_Value__c);
            date startdate 	= getLeaseCashFlowStartDate(getLeaseStartDate());
            
            date cashflowdate = startdate;
            system.debug('am: '+assumedMaintenance+ ' exposure ' +exposure+ ' maintanceAmountGap '+maintanceAmountGap);
            Decimal Maintenance_Total = assumedMaintenance + exposure + maintanceAmountGap;
            system.debug('Maintenance_Total>>>>>>'+Maintenance_Total);
            system.debug('expenseamountgap>>>>>>'+(totalGapCost-bettermentAmountGap-maintanceAmountGap));
            system.debug('bettermentAmountGap>>>>>>'+bettermentAmountGap);
            system.debug('maintanceAmountGap>>>>>>'+maintanceAmountGap);
            system.debug('totalGapCost>>>>>>'+totalGapCost);
            Decimal upfrontGapCost = totalGapCost-maintanceAmountGap;
            system.debug('upfrontGapCost>>>>>>'+upfrontGapCost);
            
            system.debug('startdate>>after close>>>>'+startdate);
            decimal rentalCashflow 		= 0;
            if(pricingLine.RFO_LeaseRate__c !=null && pricingLine.RFO_LeaseQty__c !=null){
                 rentalCashflow  = (pricingLine.RFO_LeaseRate__c * pricingLine.RFO_LeaseQty__c);
                if(Maintenance_Total> 0 )
                {
                    rentalCashflow=rentalCashflow- ((Maintenance_Total)/pricingLine.RFO_LeaseTerm__c);
                }
              
            }
            system.debug('rentalCashflow>>after close>>>>'+rentalCashflow);//expenseAmountGap
            Decimal initialCashoutlay 	= (Current_Residual_Value+upfrontGapCost)*-1;//Multipling with -1 to make it as negative value.
            system.debug('initialCashoutlay>>>>>'+initialCashoutlay);
            //excel IRR function logic
            XIRR xirr = new XIRR();
            xirr.addCashflow(startdate, initialCashoutlay);
            //rental income loop
            System.debug('pricingLine.RFO_LeaseTerm__c>>>>>>'+pricingLine.RFO_LeaseTerm__c);
            if(pricingLine.RFO_LeaseTerm__c !=null && pricingLine.RFO_LeaseTerm__c !=0){
                for (integer i = 1; i <= pricingLine.RFO_LeaseTerm__c; i++) {
                    
                    xirr.addCashflow(cashflowdate, rentalCashflow);
                    system.debug('cashflowdate>>>inloop>>>'+cashflowdate);
                    cashflowdate = cashflowdate.addMonths(1);
                   
                }
            }
            
            decimal FutureDerivedValueCashInflow 	= Future_Residual_Value+residualBetterment; //future residualvalue (total for all assets on quote) + betterment
            date finalCashInflowDate = getCarReturnCashInflowDate(cashflowdate);
            system.debug('finalCashInflowDate>>>>'+finalCashInflowDate);
            xirr.addCashflow(finalCashInflowDate, FutureDerivedValueCashInflow);//add cash inflow on last month of lease
            
            Decimal result 							= xirr.calculate();
            system.debug('result>>>>>>'+result);
            
            pricingLine.Return__c 					= (result*100).setScale(2);
            pricingLine.Maintenance_Total__c 		= Maintenance_Total;
            system.debug('pricingLine>>>>>'+pricingLine);
            system.debug('Residual_Betterment_Value__c '+ pricingLine.Residual_Betterment_Value__c);
            update pricingLine;
            
        }catch(exception ex){
            system.debug('exception: '+ex.getMessage());
            system.debug('exception: '+ex.getStackTraceString());
            throw new ROICalculatorException('Failed to run XIRR function. This is a bug, NOT a timeout.');
            
        }
        
    }
    
    private List<sbqq__quoteline__c> calculatePriceLineTotals(list<SBQQ__QuoteLine__c> pricingLines)
    {
        //Data mappings
        system.debug('calculatePriceLineTotals start');
        Map<Id,List<Id>> trnQuoteIdToRelatedAssetGroupIdMap;
        Map<Id, SBQQ__QuoteLine__c> priceLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        
        map<id, List<AssetDTO>> quoteLineToAssetListMap= new map<id, List<AssetDTO>>();
        Map<string,Assumed_Maintenance__c> modelIdtoMaintenance = new Map<string,Assumed_Maintenance__c>();
        Map<string, Residual_Curve__c> keyToResidualCurveMap = new Map<string, Residual_Curve__c>();
        
        set<string> distinctResidualCurveIds = new set<string>();
        //  Map<id,id> assetToAssetGroupId = new Map<id,id>();
        
        set<string> modelIds =  new Set<string>();
        set<Decimal> distinctAcctPeriods = new set<Decimal>();
        set<Decimal> distinctBettermentAssetKeys = new set<Decimal>();
        set<Decimal> distinctAgeInMonthsToLoad = new set<decimal>();
        Set<Id> assetGroupIds = new Set<Id>();
        List<sbqq__quoteline__c> cpqLines = getCPQQuoteLines(pricingLines);
        system.debug('getCPQQuoteLines finish. sending '+pricingLines.size() + ' lines');
        map<id, asset_group__c> allAssetGroupMap = getAssetGroupLinesForQuoteLines(pricingLines,cpqLines); 
        if(allAssetGroupMap==null || allAssetGroupMap.size()==0)
        {
            throw new ROICalculatorException('No asset groups found on related quote');
        }
        system.debug('getAssetGroupLinesForQuoteLines finish. found '+allAssetGroupMap.size() + ' asset groups');

        //AssetDTO per pricing quote line
        for(SBQQ__QuoteLine__c priceLine : pricingLines)
        {
            priceLineMap.put(priceLine.sbqq__quote__c, priceLine);
        }
        system.debug('asset DTO creation start');
        for(asset_group__c ag : allAssetGroupMap.values())
        {
            SBQQ__QuoteLine__c priceLine =pricingLines[0];//priceLineMap.get(ag.quote_line__r.sbqq__quote__c);
            for(asset_lines__c al : ag.asset_lines__r)
            {
                system.debug('asset DTO creation for ' + al.name);
                AssetDTO dto= new AssetDTO();
                
                string listTypeUpper = string.isnotempty(priceLine.RFO_LeaseType__c)?priceLine.RFO_LeaseType__c.toUpperCase() : 'unknown'.toUpperCase();//lease type is not required on UI, but needed for est. maintenance
                //lease type formatting based on data in Assumed_Maintenance__c object. It does not match the quote line picklist...
                dto.leaseType = listTypeUpper.equalsIgnoreCase('Full Service') ? listTypeUpper+' lease'.ToUpperCase() : listTypeUpper;
                dto.baseCost=al.asset__r.IRR_Base_Cost__c;
                dto.modelId=al.asset__r.product2.RFO_ModelId__c;
                dto.bettermentKey =al.asset__r.Betterment_Asset_Key__c;
                dto.buildDate = al.asset__r.RFO_DateBuilt__c;
                dto.leaseStartDate =getLeaseStartDate();
                dto.leaseMonths = integer.valueOf(priceLine.RFO_LeaseTerm__c);
                dto.leaseEndDate=getLeaseEndDate(dto.leaseStartDate,dto.leaseMonths);
                dto.accountingPeriodStart = getAccountingPeriod(dto.leaseStartDate);
                dto.accountingPeriodEnd = getAccountingPeriod(dto.leaseEndDate);
                dto.assetLineId = al.Id;
                if(string.isempty(al.asset__r.Residual_Curve_Id__c))
                {
                    throw new ROICalculatorException('Residual Curve value not found for '+al.asset__r.Name +'. Please update the data or remove the asset to calculate return.');
                }
                dto.residualCurve = al.asset__r.Residual_Curve_Id__c;
                dto.ageInMonthsAtStartofLease = dto.leaseStartDate.monthsBetween(dto.buildDate)*-1;
                dto.ageInMonthsAtEndofLease = dto.leaseEndDate.monthsBetween(dto.buildDate)*-1;
                dto.residualCurveKeyStart = dto.ageInMonthsAtStartofLease +''+ dto.residualCurve;
                dto.residualCurveKeyEnd = dto.ageInMonthsAtEndofLease +''+ dto.residualCurve;
                system.debug('zcreated asset dto :'+dto);
                if(quoteLineToAssetListMap.containsKey(priceLine.Id))
                {
                    //system.debug('found DTO mapping: '+priceLine.Id);
                    quoteLineToAssetListMap.get(priceLine.Id).add(dto);
                }
                else
                {
                    //system.debug('creating dto mapping: '+priceLine.Id);
                    List<assetDTO> adl = new List<assetdto>();
                    adl.add(dto);
                    quoteLineToAssetListMap.put(priceLine.Id, adl);
                }
                distinctAcctPeriods.add(decimal.valueOf(dto.accountingPeriodStart));
                distinctAcctPeriods.add(decimal.valueOf(dto.accountingPeriodEnd));
                distinctAgeInMonthsToLoad.add(dto.ageInMonthsAtStartofLease);
                distinctAgeInMonthsToLoad.add(dto.ageInMonthsAtEndofLease);
                distinctBettermentAssetKeys.add(dto.bettermentKey); 
                
                distinctResidualCurveIds.add(al.asset__r.Residual_Curve_Id__c);
                modelIds.add(dto.modelId);
                
            } 
        }
        if(quoteLineToAssetListMap.size()==0)
        {
            throw new ROICalculatorException('No assets found on quote');
        }
        //Residual_Curve__c
        system.debug('Model Ids: '+modelIds);
        system.debug('months: '+distinctAgeInMonthsToLoad + ' curves: '+distinctResidualCurveIds);
        for(Residual_Curve__c rc :[SELECT Id,Age_In_Months__c, Residual_Curve_ID__c, Residual_Percent__c
                                   FROM Residual_Curve__c
                                   Where Residual_Curve_ID__c in :distinctResidualCurveIds
                                   AND Age_In_Months__c in :distinctAgeInMonthsToLoad] )
        {
            string compositeRCKey = integer.valueOf(rc.Age_In_Months__c)+rc.Residual_Curve_ID__c;
            system.debug('keyToResidualCurveMap '  + compositeRCKey + ' '+ rc);
            keyToResidualCurveMap.put(compositeRCKey, rc);
        }
        system.debug('Found '+keyToResidualCurveMap.size()+ ' Residual curve records');
        //Residual_Betterment__c
        Map<string,Residual_Betterment__c> assetYomoToBettermentMap =  new  Map<string,Residual_Betterment__c>();
        system.debug('dbkey: '+distinctBettermentAssetKeys + ' acctPds: '+distinctAcctPeriods);
        for(Residual_Betterment__c rb : [SELECT Accounting_Period__c,Betterment_Asset_Key__c,Id,
                                         Original_Betterment_Value__c,Residual_Betterment_Value__c
                                         FROM Residual_Betterment__c
                                         WHERE Betterment_Asset_Key__c in :distinctBettermentAssetKeys
                                         AND Accounting_Period__c in :distinctAcctPeriods])
        {
            string compositeKey = getBettermentCurveKey(rb.Betterment_Asset_Key__c,string.valueOf(integer.valueOf(rb.Accounting_Period__c )));
            system.debug('storing yomo comp key: '+compositeKey + ' with ' + rb);
            assetYomoToBettermentMap.put(compositeKey, rb);
        }
        system.debug('Found '+assetYomoToBettermentMap.size()+ ' Betterment curve records');
        //Assumed_Maintenance__c
 		for (Assumed_Maintenance__c am : [SELECT Id,Lease_Type__c,Model_Id__c,Monthly_Maintenance_Amount__c
                                          FROM Assumed_Maintenance__c WHERE Model_Id__c in :modelIds and Monthly_Maintenance_Amount__c <> null])
        {
            string key =getAssumedMaintenanceKey(am.Lease_Type__c, am.Model_Id__c);
            modelIdtoMaintenance.put(key, am);
            system.debug('zzzam '+key + ' ' +am);      
        }
        system.debug('Found '+modelIdtoMaintenance.size()+ ' Assumed Maintenance records');
        //calculate value per asset
        list<pricingScenario> pricingScenarios =  new List<pricingScenario>();
		system.debug('pricingLines>>>>>>'+pricingLines);
        system.debug('quoteLineToAssetListMap>>>>>>'+quoteLineToAssetListMap);
        for(SBQQ__QuoteLine__c priceLine : pricingLines)
        {
            try
            {
                pricingScenario ps = new pricingScenario();
                ps.totalAssumedMaintenance =0;
                ps.totalInitialAssetCost=0;
                ps.totalFinalAssetCost=0;
                ps.quoteLine = priceLine;
                List<AssetDTO> quoteAssets;
                if(quoteLineToAssetListMap.containskey(priceLine.Id))
                {
                    quoteAssets = quoteLineToAssetListMap.get(priceLine.Id);
                }
                else
                {
                    throw new ROICalculatorException('An error occured calculating ROI. Please check Asset Groups to make sure they contain valid assets only');
                }
                system.debug('zzzpocessing prices for '+ quoteAssets.size());
                system.debug('quoteAssets>>>>>'+quoteAssets);
                system.debug('keyToResidualCurveMap>>>>>'+keyToResidualCurveMap);
                system.debug('assetYomoToBettermentMap>>>>>'+assetYomoToBettermentMap);
                for(AssetDTO dto : quoteAssets)
                {
                    system.debug(dto);
                    string bettermentKeyStart = getBettermentCurveKey(dto.bettermentKey, dto.accountingPeriodStart);
                    string bettermentKeyEnd =getBettermentCurveKey(dto.bettermentKey, dto.accountingPeriodEnd);
                    system.debug('dto.residualCurveKeyStart: '+dto.residualCurveKeyStart);
                    system.debug('dto.residualCurveKeyEnd '+ dto.residualCurveKeyEnd);
                    system.debug('getBettermentCurveKey ' +bettermentKeyStart);
                    system.debug('getBettermentCurveKey ' +bettermentKeyEnd);
                    decimal initialBettermentValue = 0, finalBettermentValue=0;
            
                    
                    if(!keyToResidualCurveMap.containsKey(dto.residualCurveKeyStart))
                    {
                        system.debug('keyToResidualCurveMap not found for ' +dto.residualCurveKeyStart);
                        throw new ROICalculatorException('Could not find residual curve entry for modelId: '+dto.modelId +',  acct period of: ' +dto.accountingPeriodStart +' residual curve id: '+ dto.residualCurve);
                    }
                    if(!keyToResidualCurveMap.containsKey(dto.residualCurveKeyEnd))
                    {
                        system.debug('keyToResidualCurveMap not found for ' +dto.residualCurveKeyEnd );
                        throw new ROICalculatorException('Could not find residual curve entry for modelId: '+dto.modelId +' and acct period of: '+dto.accountingPeriodEnd +' residual curve id: '+ dto.residualCurve);
                    }
                    if(assetYomoToBettermentMap.containsKey(getBettermentCurveKey(dto.bettermentKey, dto.accountingPeriodStart)))
                    {
                        initialBettermentValue = assetYomoToBettermentMap.get(getBettermentCurveKey(dto.bettermentKey, dto.accountingPeriodStart)).Residual_Betterment_Value__c;
                    }
                    if(assetYomoToBettermentMap.containsKey(getBettermentCurveKey(dto.bettermentKey, dto.accountingPeriodEnd)))
                    {
                        
                        finalBettermentValue = assetYomoToBettermentMap.get(getBettermentCurveKey(dto.bettermentKey, dto.accountingPeriodEnd)).Residual_Betterment_Value__c;
                        
                    }
                    system.debug('getting keys.. ');
                    decimal initialResidualCurve = keyToResidualCurveMap.get(dto.residualCurveKeyStart).Residual_Percent__c;
                    decimal finalResidualCurve = keyToResidualCurveMap.get(dto.residualCurveKeyEnd).Residual_Percent__c; 
                    
                    system.debug('found keys.. irc: ' + initialResidualCurve+' frc: ' +finalResidualCurve +' ibv: ' + initialBettermentValue+' fbv'+finalBettermentValue);
                    dto.initialResidualValue = (dto.baseCost * initialResidualCurve) + initialBettermentValue;
                    dto.futureResidualValue = (dto.baseCost * finalResidualCurve) + finalBettermentValue;
                    string amkey = getAssumedMaintenanceKey(dto.leaseType, dto.ModelId);
                    if(modelIdtoMaintenance.containskey(amkey))
                    {
                        dto.monthlyAssumedMaintenance =dto.leaseMonths * modelIdtoMaintenance.get(amkey).Monthly_Maintenance_Amount__c;
                        system.debug('setting am on asset ' +dto.monthlyAssumedMaintenance );
                    }
                    else
                    {
                        dto.monthlyAssumedMaintenance = 0;
                    }
                   
                    calcualteResidualBettermentandStoreOnPriceLine(cpqLines, ps.quoteLine);

                    ps.totalAssumedMaintenance +=  dto.monthlyAssumedMaintenance;
                    ps.totalInitialAssetCost += dto.initialResidualValue;
                    ps.totalFinalAssetCost += dto.futureResidualValue; 
                }
                
                pricingScenarios.add(ps);
                system.debug('zpricingScenario'+ps);
            }
            catch(ROICalculatorException roiEx)
            {
                system.debug(roiEX.getMessage());
                throw roiEX;//log and push exception through to UI
            }
            catch(Exception e)
            {
                system.debug('zpricingScenario Failed to create '+e.getMessage());
                system.debug(e.getStackTraceString());
                throw new ROICalculatorException('Failed to calculate IRR. Please check related data and try again.');
            }
            
        }
        system.debug('created pricing scenarios '+pricingScenarios.size());
        return convertPricingLineDTOToSObject(pricingScenarios);
    }
     private void calcualteResidualBettermentandStoreOnPriceLine(List<sbqq__quoteline__c> cpqLines, sbqq__quoteline__c priceLine)
    {
       decimal residualBettermentValue=0;
        for(sbqq__quoteline__c q : cpqLines)
        {
            if (q.TRN_QLine_Type_c__c =='Betterment' && q.sbqq__quote__r.Commercial_Quote__c == priceLine.SBQQ__Quote__c)
            {
                residualBettermentValue += calculateResidualBettermentValue(q.NetTotalAmount__c, q.UsefulLife__c,priceLine.RFO_LeaseTerm__c);
            }
        }
        system.debug('residualBettermentValue>>>>>>>>>'+residualBettermentValue);
        priceLine.Residual_Betterment_Value__c = residualBettermentValue;
    }
    private List<sbqq__quoteline__c> convertPricingLineDTOToSObject(list<pricingScenario> pricingScenarios) 
    {
        List<sbqq__quoteline__c> quoteLinesToUpdate = new List<sbqq__quoteline__c>(); 
        
        for(pricingScenario ps : pricingScenarios)
        {
            ps.quoteLine.Future_Residual_Value__c = ps.totalFinalAssetCost;
            ps.quoteLine.Current_Residual_Value__c = ps.totalInitialAssetCost;
            ps.quoteLine.Assumed_Maintenance_Total__c=ps.totalAssumedMaintenance;
            quoteLinesToUpdate.add(ps.quoteLine);
            
        }
        return quoteLinesToUpdate;
    }
  
    private date getLeaseEndDate(date startDate, decimal term)
    {
        system.debug('getAccountingPeriod start :'+startDate +' '+term);
        date endDate = startDate;
        if(term>0)
        {
            endDate = startdate.addMonths(integer.valueof(math.rint(term)));
        }
        return endDate;     
    }
    private string getAccountingPeriod(date dateVal)
    {
        string returnVal = dateVal.year()+''+dateVal.month()+''+dateVal.day();
        system.debug('getAccountingPeriod end: '+returnVal);
        return returnVal;
    }
    private string getBettermentCurveKey(decimal assetKey, string accountingPeriod)
    {
        return string.valueOf(integer.valueOf(assetKey))+accountingPeriod;
    }
    private string getAssumedMaintenanceKey(string leaseType, string modelId)
    {
        return leaseType+modelId;
    }
    private string getrecordtypeId(string recordTyepName)
    {
        return Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get(recordTyepName).getRecordTypeId();
    }
    private date getLeaseStartDate()
    {
        date dateField = date.today();
        dateField = dateField.addMonths(1);
        Integer numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
        Date lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
        return lastDayOfMonth;
        
    }
    private date getLeaseCashFlowStartDate(date leaseDate)
    {
      return leaseDate.toStartOfMonth();
        
    }
    private date getCarReturnCashInflowDate(date dateField)
    {
        datefield = datefield.addMonths(-1);
        Integer numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
        Date lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
        return lastDayOfMonth;
    }
    public decimal calculateResidualBettermentValue(decimal gapBetterment, decimal bettermentLife, decimal leaseTerm)
    {
       if(bettermentLife > leaseTerm)
       {
           return gapBetterment * ((bettermentLife-leaseTerm) / bettermentLife);
       }
       else return 0;//if life is less than or equal to term, betterment has no residual value
    }
    private Map<id, asset_group__c> getAssetGroupLinesForQuoteLines(List<sbqq__quoteline__c> pricingLines, List<sbqq__quoteline__c> cpqLines)
    {
        //Map<Id,List<Id>> trnQuoteIdToRelatedAssetGroupIdMap = new Map<Id,List<Id>>();
        set<Id> quoteLinesToPullAssetgroups = new set<Id>();
        set<Id> quoteLinesToPullCPQLines = new set<Id>();
        
        for(SBQQ__QuoteLine__c q : pricingLines)
        {
            //for renewals, pull asset groups by standard quote
            if(q.recordTypeId==getrecordtypeId('Renewals'))
            {
                quoteLinesToPullAssetgroups.add(q.id);
            }
          
            system.debug('getAssetGroupLinesForQuoteLines. Found '+cpqLines.size() + ' cpq lines');
            for(SBQQ__QuoteLine__c cpq : cpqLines)
            {
                quoteLinesToPullAssetgroups.add(cpq.id);
            }
            system.debug('getAssetGroupLinesForQuoteLines. Found '+quoteLinesToPullCPQLines.size() + ' total lines');
        }
        //Asset_Group__c
        return new Map<id, asset_group__c>([SELECT id, name,quote_line__c,quote_line__r.sbqq__quote__c, 
                                            (SELECT id, name,asset__c, asset__r.name, asset__r.Residual_Curve_Id__c,
                                             asset__r.IRR_Base_Cost__c, asset__r.Betterment_Asset_Key__c,asset__r.RFO_DateBuilt__c,
                                             asset__r.product2.RFO_ModelId__c from asset_lines__r) 
                                            FROM Asset_Group__c WHERE quote_line__c in :quoteLinesToPullAssetgroups]);
    }
  
     private list<SBQQ__QuoteLine__c> getCPQQuoteLines(List<sbqq__quoteline__c> pricingLines)
    {
        set<id> trnQuoteIds = new set<id>();
        for(SBQQ__QuoteLine__c q : pricingLines)
        {
            if(q.recordTypeId!=getrecordtypeId('Renewals'))
            {
                trnQuoteIds.add(q.sbqq__quote__c);
            }      
        }
        return [SELECT id, Asset_Group__c, sbqq__quote__c,TRN_QLine_Type_c__c,usefullife__c,
                NetTotalAmount__c, sbqq__quote__r.Commercial_Quote__c 
                FROM SBQQ__QuoteLine__c 
                WHERE sbqq__quote__r.Commercial_Quote__c in :trnQuoteIds ];
    }
   
    
}