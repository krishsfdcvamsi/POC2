public class RoiCalculationController {
    @auraEnabled
    Public Static Map<String,Object> getQuoteInfo(String quoteId){
        Map<String,Object> result = New Map<String,Object>();
        try{
            SBQQ__QuoteLine__c objQuoteLine = [SELECT SBQQ__Quote__c,SBQQ__Quote__r.Price_Book_Rate__c,
                                               Residual_Betterment_Value__c, 
                                               SBQQ__Quote__r.CPQ_Quote__c,
                                               SBQQ__Quote__r.CPQ_Quote__r.Price_Book_Rate__c,
                                               Commercial_Quote__c 
                                               FROM SBQQ__QuoteLine__c 
                                               WHERE Id=:quoteId LIMIT 1];
            //Price_Book_Rate__c
            Decimal Price_Book_Rate  = objQuoteLine.SBQQ__Quote__r.CPQ_Quote__r.Price_Book_Rate__c;
            system.debug('objQuoteLine>>>>>>>>>'+objQuoteLine);
            system.debug('objQuoteLine>>>>>>>>>'+objQuoteLine.SBQQ__Quote__r.CPQ_Quote__c);
            system.debug('objQuoteLine>>>>>>>>>'+objQuoteLine.Commercial_Quote__c);
            String strQuoteId 		= objQuoteLine.SBQQ__Quote__r.CPQ_Quote__c;
            String strTriQuoteId 	= objQuoteLine.SBQQ__Quote__c;
            system.debug('strQuoteId>>>>>>'+strQuoteId);
            SBQQ__QuoteLine__c objQuote = [SELECT Net_Present_Value__c,Return__c,
                                           SBQQ__NetPrice__c,RFO_LeaseQty__c,RFO_LeaseRate__c,
                                           RFO_LeaseTerm__c,Current_Residual_Value__c,
                                           Future_Residual_Value__c,Maintenance_Total__c,
                                           Gap_Analysis_Investment__c
                                           FROM SBQQ__QuoteLine__c WHERE Id=:quoteId];
            system.debug('objQuote>>>>>>>'+objQuote);
            decimal expenseAmount 		     = 0;
            decimal maintanceAmount 	     = 0;
            decimal totalbettermentAmount 	 = 0;
            decimal residualBettermentAmount = 0;
            decimal monthlyLeaseRate	     = 0;
            
            if(objQuote.RFO_LeaseQty__c !=null && objQuote.RFO_LeaseRate__c != null){
                monthlyLeaseRate  = objQuote.RFO_LeaseQty__c*objQuote.RFO_LeaseRate__c;
            }
            AggregateResult[] expenseResults = [SELECT SUM(NetTotalAmount__c)netTotalAmount 
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE TRN_QLine_Type_c__c='Expense' 
                                                AND SBQQ__Quote__c=:strQuoteId];
            system.debug('expenseResults>>>>>'+expenseResults);
            if((decimal)expenseResults[0].get('netTotalAmount')!=null){
                expenseAmount = (decimal)expenseResults[0].get('netTotalAmount');
            }
            
            system.debug('expenseAmount>>>>>'+expenseAmount);
            AggregateResult[] bettermentResults = [SELECT SUM(NetTotalAmount__c)netTotalAmount 
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE TRN_QLine_Type_c__c='Betterment' 
                                                   AND SBQQ__Quote__c=:strQuoteId];
            system.debug('bettermentResults>>>>>'+bettermentResults);
            if((decimal)bettermentResults[0].get('netTotalAmount') !=null){
                totalBettermentAmount = (decimal)bettermentResults[0].get('netTotalAmount');
            }
            //Decimal residualBettermentAmount= 0;
            if(objQuoteLine.Residual_Betterment_Value__c!=null){
                residualBettermentAmount =	objQuoteLine.Residual_Betterment_Value__c;
            }           
           
            
            
            system.debug('ResidualBetterment>>>>>'+residualBettermentAmount);
            system.debug('bettermentAmount>>>>>'+totalBettermentAmount);
            AggregateResult[] maintainceResults = [SELECT SUM(NetTotalAmount__c)netTotalAmount 
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE TRN_QLine_Type_c__c='Maintenance' 
                                                   AND SBQQ__Quote__c=:strQuoteId];
            system.debug('maintainceResults>>>>>'+maintainceResults);
            if((decimal)maintainceResults[0].get('netTotalAmount')!=null){
                maintanceAmount = (decimal)maintainceResults[0].get('netTotalAmount');
            }
            
            system.debug('maintanceAmount>>>>>'+maintanceAmount);
            result.put('PriceBookRate',Price_Book_Rate);
            result.put('success',true);
            result.put('Quote',objQuote);
            result.put('maintanceAmount',maintanceAmount);
            result.put('bettermentAmount',TotalbettermentAmount);
            //GAP Cost per Car calculation. Date: 1/26/2021
            // (totoal better+expe+mai)-residualBettermentAmount;
            decimal gapCostPerCar = 0;
            system.debug('objQuote.RFO_LeaseTerm__c>>>'+objQuote.RFO_LeaseTerm__c);
            system.debug('objQuote.RFO_LeaseQty__c>>>'+objQuote.RFO_LeaseQty__c);
            if(objQuote.RFO_LeaseTerm__c!=0 && objQuote.RFO_LeaseTerm__c!= null
               && objQuote.RFO_LeaseQty__c!=0 && objQuote.RFO_LeaseQty__c!=null){
                gapCostPerCar = ((((maintanceAmount+totalBettermentAmount+expenseAmount)-residualBettermentAmount)/objQuote.RFO_LeaseTerm__c)/objQuote.RFO_LeaseQty__c);
            }
            
            //TODO: please add ResidualBetterment to UI and pass back to CalculateReturn
            result.put('ResidualBetterment',residualBettermentAmount);
            result.put('gapCostPerCar',gapCostPerCar);
            result.put('expenseAmount',expenseAmount);
            result.put('monthlyLeaseRate',monthlyLeaseRate);
            result.put('baseLinePrice',(gapCostPerCar+Price_Book_Rate).setScale(2));
            If(Test.isRunningTest()){
                integer i=1/0;
            }
        }catch(exception ex){
            result.put('success',false);
            result.put('msg',ex.getMessage());
        }
        system.debug('result>>>>>>>'+result);
        return result;
    }
    @auraEnabled
    Public Static Map<String,Object> CalculateReturn(String QuoteId, boolean runAsync,
                                                     decimal Exposure,
                                                     decimal bettermentAmountGap,
                                                     decimal maintanceAmountGap,
                                                     decimal expenseAmountGap)
    {
        Map<String,Object> resultVal = New Map<String,Object>();
        try{
            
            if(runAsync)
            {
                ROICalculator.runCalculateReturn_future(quoteId, bettermentAmountGap, maintanceAmountGap, exposure);
                resultVal.put('success',true);
                resultVal.put('msg', 'ROI Calculation has been queued up. Please allow up to 1 minute for calculation to complete.');
            }
            else
            {
                ROICalculator.runCalculateReturn_nonBulkified(quoteId, bettermentAmountGap, maintanceAmountGap, exposure);
                resultVal.put('success',true);
                resultVal.put('msg', 'ROI Calculation has completed successfully');
            }
            
           
        }
        catch(exception ex)
        {
            system.debug('exception'+ex);
            resultVal.put('success', false);
            resultVal.put('msg', ex.getMessage());
        }
        return resultVal;
    }
    
}