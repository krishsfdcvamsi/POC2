import { LightningElement ,api, track } from 'lwc';
import configButton from '@salesforce/apex/QuoteConfigButtonController.configButton';
import getQuoteUIDetails from '@salesforce/apex/QuoteConfigButtonController.getQuoteUIDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
export default class QuoteConvertButtons extends LightningElement {
    @api recordId;
    @track currentRecordId;
    @track showTrinityButton;
    @track showTCPQButton;
    handleChange(){
        //alert(this.currentRecordId);
        configButton({QuoteId : this.currentRecordId}).then(result => {
            //$A.get('e.force:refreshView').fire();
            //updateRecord({fields: this.currentRecordId})
            location.reload();
            //eval("$A.get('e.force:refreshView').fire();");
        }).catch(error => {
            console.log('error>>>>',error);
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Error',
                message : error,
                variant : 'error',
            }),
        )
        //this.contacts = undefined;
    });
        //alert('Change to Config...');
        //alert(this.currentRecordId);
    }
    connectedCallback(){
    this.currentRecordId = this.recordId;
    this.loadQuoteinfomation();
    }
    loadQuoteinfomation(){
        //alert(this.currentRecordId);
        getQuoteUIDetails({QuoteId : this.currentRecordId}).then(result => {
            console.log('result>>>>>>',result);
            console.log('result>>>>>>',result.Quote_UI__c);
            if(result.Quote_UI__c == 'CPQ Quote'){
                this.showTrinityButton = true;
                this.showTCPQButton = false;
            }else{
                this.showTrinityButton = false;
                this.showTCPQButton = true;
            }
            //location.reload();
        }).catch(error => {
            console.log('error>>>>',error);
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Error',
                message : error,
                variant : 'error',
            }),
        )
        //this.contacts = undefined;
    });
    }
}