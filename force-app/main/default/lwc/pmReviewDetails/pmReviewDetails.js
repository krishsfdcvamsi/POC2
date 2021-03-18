import { LightningElement ,api,track} from 'lwc';
import getPRReview from '@salesforce/apex/PMReviewController.getQuoteInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class PmReviewDetails extends LightningElement {
    @api recordId;
    @track showEditForm = false;
    isLoaded = true;

    handleEdit(){
        this.showEditForm = true;
    }
    closeModal(){
        //alert('edit....');
        this.showEditForm = false;
    }
    handleSubmit(event){
        this.isLoaded  = false;
        console.log('updating>>>>>>');

    }
    handleCreate(updateQuote){
        const toastEvent = new ShowToastEvent({  
            title: 'Quote Updated',  
            message: 'Quote Updated Successfully!!!',  
            variant: 'success'  
        });  
        this.dispatchEvent( toastEvent );  
        console.log('updateQuote>>>>>>',updateQuote.detail);
        this.showEditForm = false;
    }
}