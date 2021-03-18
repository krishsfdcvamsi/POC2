import { LightningElement,api } from 'lwc';
import quoteDetails from '@salesforce/apex/RoiCalculationController.getQuoteInfo';
//import saveROI from '@salesforce/apex/RoiCalculationController.SaveQuoteReturnCalculation';
import saveROI from '@salesforce/apex/RoiCalculationController.CalculateReturn';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RoiCalculation extends LightningElement {
    currentResidualValue = 0;
    gapAnalysisInvestment = 0;
    maintenanceDerived = 0;
    futureResidualValue = 0;
    roi = 0; 
    activeVal ; 
    quoteDetails;
    @api trinityQuote;
    returnValues = 0;

    Current_Residual_Value      =   0;
    Gap_Analysis_Investment     =   0;
    bettermentAmountGap         =   0;
    maintanceAmountGap          =   0;
    AssuredAmount               =   0;
    Exposure                    =   0;
    Maintenance_Total		    =   0;
    Future_Residual_Value	    =   0;
    Return					    =   0;
    expenseAmount               =   0;
    runBackground               =   false;
    showAsync                   = 	false;
    runChecked                  = 	false;
    runAsyncMsg                 = 	'';
    monthlyLeaseRate            = 	0;
    isLoaded 					= 	true;
	gapcostperCar 				=	0;
	recidentialBetterment		=	0;
	quotePriceBookRate			=	0;
	baselinePricing				=	0;
    handleRefreshClick(){
        this.getQuotesInfo();
        this.runBackground = false;
        this.showAsync = false;
        this.runChecked  =  false;
    }
    headerCheckoxChanged(event){
        this.runBackground = event.target.checked;
        this.showAsync = event.target.checked
        this.runChecked  = event.target.checked;
        console.log('runBackground>>>>',this.runBackground);
    }
    connectedCallback() {
        console.log('trinityQuote>>>>>>',this.trinityQuote);
        this.getQuotesInfo();
        //Current_Residual_Value__c
        //Future_Residual_Value__c
        //Maintenance_Total__c
        //Gap_Analysis_Investment__c
        //Net_Present_Value__c
        //Return__c
    }
    getQuotesInfo(){
        quoteDetails({quoteId : this.trinityQuote})
        .then(result => {
            console.log('result>>>>>>',result);
            console.log('result>>bettermentAmount>>>>',result.bettermentAmount);
            console.log('result>>expenseAmount>>>>',result.expenseAmount);
            console.log('result>>maintanceAmount>>>>',result.maintanceAmount);
            console.log('result>>>>>>',result);
            if(result.success){
                var quoteLine = result.Quote;
				//PriceBookRate
				if(result.PriceBookRate != 'undefined' && result.PriceBookRate != 'null'){
                    this.quotePriceBookRate = result.PriceBookRate;
                }
                if(result.maintanceAmount != 'undefined' && result.maintanceAmount != 'null'){
                    this.maintanceAmountGap = result.maintanceAmount;
                }
                if(result.bettermentAmount != 'undefined' && result.bettermentAmount != 'null'){
                    this.bettermentAmountGap =   result.bettermentAmount;
                }
                if(result.expenseAmount != 'undefined' && result.expenseAmount != 'null'){
                  this.expenseAmount = result.expenseAmount;
                }
                if(quoteLine.Return__c != 'undefined'){
                    this.Return = quoteLine.Return__c;
                }
                if(result.monthlyLeaseRate != 'undefined' && result.monthlyLeaseRate != 'null'){
                    this.monthlyLeaseRate = result.monthlyLeaseRate;
                }
				if(result.ResidualBetterment != 'undefined' && result.ResidualBetterment != 'null'){
                    this.recidentialBetterment = result.ResidualBetterment;
                }  
				if(result.gapCostPerCar != 'undefined' && result.gapCostPerCar != 'null'){
                    this.gapcostperCar = result.gapCostPerCar;
                }  
                //this.monthlyLeaseRate = result.monthlyLeaseRate;
                console.log('this.expenseAmount>>>',this.expenseAmount);
                console.log('this.bettermentAmountGap>>>',this.bettermentAmountGap);
                console.log('this.maintanceAmountGap>>>',this.maintanceAmountGap);
                /*
                if(quoteLine.RFO_LeaseQty__c != 'undefined'){
                    this.RFO_LeaseQty = quoteLine.RFO_LeaseQty__c;
                }
                if(quoteLine.RFO_LeaseTerm__c != 'undefined'){
                    this.RFO_LeaseTerm = quoteLine.RFO_LeaseTerm__c;
                }
                */
                if(quoteLine.Current_Residual_Value__c != 'undefined'){
                    this.Current_Residual_Value = quoteLine.Current_Residual_Value__c;
                }
                if(quoteLine.Future_Residual_Value__c != 'undefined'){
                    this.Future_Residual_Value = quoteLine.Future_Residual_Value__c;
                }
                if(quoteLine.Maintenance_Total__c != 'undefined'){
                    this.Maintenance_Total = quoteLine.Maintenance_Total__c;
                }
                if(quoteLine.Gap_Analysis_Investment__c != 'undefined'){
                    this.Gap_Analysis_Investment = quoteLine.Gap_Analysis_Investment__c;
                }
				if(result.baseLinePrice != 'undefined' ){
						this.baselinePricing  =  result.baseLinePrice;
				}
                this.isLoaded = false;
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Error',
                        message : result.msg,
                        variant : 'error',
                    }),
                )
            }
            
            
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error',
                    message : 'Something went wrong, please try again or contact your system Admin.',
                    variant : 'error',
                }),
            )
        })
    }
    exposure(event){
            if(event.target.value !=null || event.target.value !='undefined' || event.target.value !='NaN'){
                this.Exposure = event.target.value;
            }
    }
    maintenace(event){
        if(event.target.value !=null || event.target.value !='undefined' || event.target.value !='NaN'){
            this.Maintenance_Total = event.target.value;
        }
    }
    currentResi(event){
        if(event.target.value !=null || event.target.value !='undefined' || event.target.value !='NaN'){
            this.Current_Residual_Value = event.target.value;
        }
    }
    handleSaveClick(){
        this.isLoaded = true;
        console.log('Current_Residual_Value',this.Current_Residual_Value);	        		
        console.log('Gap_Analysis_Investment',this.Gap_Analysis_Investment)	;				    	
        console.log('bettermentAmountGap',this.bettermentAmountGap);

        console.log('maintanceAmountGap',this.maintanceAmountGap);
        console.log('AssuredAmount',this.AssuredAmount);
        console.log('Exposure',this.Exposure);
        console.log('Maintenance_Total',this.Maintenance_Total);
        console.log('Future_Residual_Value',this.Future_Residual_Value);
        console.log('expenseAmount',this.expenseAmount);
        console.log('trinityQuote>>>>>>',this.trinityQuote);
        saveROI({
            QuoteId:this.trinityQuote,
            runAsync :this.runBackground,
            Exposure:this.Exposure,
            bettermentAmountGap:this.bettermentAmountGap,
            maintanceAmountGap:this.maintanceAmountGap,
            expenseAmountGap:this.expenseAmount
            /*
            Current_Residual_Value:this.Current_Residual_Value,
            Gap_Analysis_Investment:this.Gap_Analysis_Investment,
            bettermentAmountGap:this.bettermentAmountGap,
            maintanceAmountGap:this.maintanceAmountGap,
            AssuredAmount:this.AssuredAmount,
            Exposure:this.Exposure,
            Maintenance_Total:this.Maintenance_Total,
            Future_Residual_Value:this.Future_Residual_Value,
            expenseAmountGap:this.expenseAmount,
            */
            
            })
        .then(result => {
            console.log('result>>>>>>',result);
            if(result.success){
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Success',
                        message : result.msg,
                        variant : 'success',
                    }),
                )
                this.getQuotesInfo();
                 this.isLoaded = false;
                /*
                if(result.runAsync){
                    this.runAsyncMsg = result.runAsyncMsg;
                    //this.getQuotesInfo();
                    this.isLoaded = false;
                    //this.showAsync = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'Success',
                            message : result.runAsyncMsg,
                            variant : 'success',
                        }),
                    )
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'Success',
                            message : result.msg,
                            variant : 'success',
                        }),
                    )
                    this.getQuotesInfo();
                     this.isLoaded = false;
                }
                */
                
            }else{
                this.isLoaded = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Error',
                        message : result.msg,
                        variant : 'error',
                    }),
                )
                
            }
            
            
        }).catch(error => {
            console.log('error>>>>>',error);
            this.isLoaded = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error',
                    message : 'Something went wrong, please try again or contact your system Admin.',
                    variant : 'error',
                }),
            )
        })
        
    }
}