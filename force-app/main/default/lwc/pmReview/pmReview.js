import { LightningElement,api } from 'lwc';
import getQuoteProduct from '@salesforce/apex/PMReviewController.getQuotePRoductInfo';
export default class PmReview extends LightningElement {
    @api trinityQuoteId;
    productId;
    connectedCallback() {
        //alert(this.recordId);
        this.currentRecordId = this.recordId;
        //alert('currentRecordId'+this.currentRecordId);
        this.getQuotesInfo();
    }
    getQuotesInfo(){
        
        getQuoteProduct({quoteId : this.trinityQuoteId}).then(result => {
            console.log('resultpricingtable',result);
            this.productId = result.RFO_Product__c;
            console.log('productId>>>>>>>',this.productId);
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error',
                    message : error.body.message+' , Please contact your system admin.',
                    variant : 'error',
                }),
            )
            this.isLoaded =  false;
            console.log('error>>>>',error.body.message);
            this.error = error;
        })
    }
}