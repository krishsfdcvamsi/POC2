import { LightningElement,api,wire, track } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import getQuoteInfo from '@salesforce/apex/CPQ_QuoteNavigationController.getCPQQuoteInfo';
export default class CpqQuoteNavigation extends LightningElement {
    @api recordId;
    @track isLoaded;
    connectedCallback(){
        console.log('currentrecord id>>>',this.recordId);
        this.isLoaded = false;
        this.intialData();
    }
    intialData(){
    return getQuoteInfo({cpqQuoteId : this.recordId})
        .then(result => { 
            console.log('result>>>>',result);
            if(result == null || result == 'undefined' || result    == '' ){
                    this.isLoaded = true;
                    return false;
            }else{
                console.log('result>>>>>> navigation>>',result);
                location.replace("/"+result.Id);
                //window.location('/'+result.Id);
            }
        }).catch(error => { 
            this.isLoaded = true;
            console.log('error>>>>>>',error);
            //this.error = error ;
        })
    }
}