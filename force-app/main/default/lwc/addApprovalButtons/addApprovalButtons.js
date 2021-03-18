import { LightningElement ,api, track } from 'lwc';
import approve from '@salesforce/apex/AddApprovalButtonsController.approve';
import reject from '@salesforce/apex/AddApprovalButtonsController.rejectRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AddApprovalButtons extends LightningElement {
    @api recordId;
    @track currentRecordId;
    @api    cqpQuoteId;
    @api    isCpq;
    @track isLoaded= false;
    @track isShowApproveButton ;
    @track isShowRejectButton  ;
    @track isShowSendGapButton ;
    @track labelForApproveButton;
    @track labelForRejectButton;
    @track labelForSendGapButton;
    @api labelApproveButton   ;
    @api labelRejectButton    ;
    @api labelSendGapButton   ;
    isApproveButtonDisabled = false;
    isGAPButtonDisabled     = false;
    isRejectButtonDisabled  = false;
    connectedCallback() {
        
       this.isLoaded = false;
        this.currentRecordId = this.cqpQuoteId;
        this.labelForApproveButton  = this.labelApproveButton;
        this.labelForRejectButton   = this.labelRejectButton;
        this.labelForSendGapButton  = this.labelSendGapButton;
        console.log('labelSendGapButton',this.labelSendGapButton);
        if(this.labelSendGapButton == null 
            ||
        this.labelSendGapButton == 'undefined'
            ||
            this.labelSendGapButton == '' 
        ){
            this.isShowSendGapButton = false;
        }else{
            this.isShowSendGapButton = true;
        }
        if(this.labelApproveButton == null 
        ||
        this.labelApproveButton == 'undefined' 
        ||
        this.labelApproveButton == ''
        ){
            this.isShowApproveButton = false;
        }else{
            this.isShowApproveButton = true;
        }
        if(this.labelRejectButton == null 
            ||
        this.labelRejectButton == 'undefined' 
            ||
        this.labelRejectButton == '' 
        ){
            this.isShowRejectButton = false;
        }else{
            this.isShowRejectButton = true;
        }
        //alert(this.cqpQuoteId);
        console.log('isShowRejectButton',this.isShowRejectButton);
        console.log('isShowApproveButton',this.isShowApproveButton);
        console.log('isShowSendGapButton',this.isShowSendGapButton);
    }
    handleCompleteClick(){
        console.log('record id>>>>',this.currentRecordId);
        this.isApproveButtonDisabled = true;
        //this.isGAPButtonDisabled     = true;
        this.isRejectButtonDisabled  = true;
        this.isLoaded = true;
        approve({recordId : this.currentRecordId,isCpq:this.isCpq}).then(result => {
            if(result.success){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Success',
                        message : 'Approved succesfully!',
                        variant : 'success',
                    }),
                    
                )
                const okButtonAction = new CustomEvent('refreshview');
                this.dispatchEvent(okButtonAction);
                this.isLoaded = false;
                this.isApproveButtonDisabled = false;
                //this.isGAPButtonDisabled     = false;
                this.isRejectButtonDisabled  = false;
                //location.reload();
                //this.isLoaded = false;
                /*
                setTimeout(function(){
                     location.reload();
                     }, 5000);
                */
                
            }else if(result.success == false){
                var errorMessage = result.msg;
                if(errorMessage.includes('ENTITY_IS_LOCKED') || errorMessage.includes('This record is locked')){
                    errorMessage = 'You do not have permission to update the Quote at this time.'
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Error',
                        message : errorMessage,
                        variant : 'error',
                    }),
                )
                this.isLoaded = false;
                this.isApproveButtonDisabled = false;
                //this.isGAPButtonDisabled     = false;
                this.isRejectButtonDisabled  = false;
            }
            
        
    }).catch(error => {
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Error',
                message : error,
                variant : 'error',
            }),
        )
        this.isLoaded = false;
        this.isApproveButtonDisabled = false;
        //this.isGAPButtonDisabled     = false;
        this.isRejectButtonDisabled  = false;
    });
    }
    handleRejectClick(){
        this.isLoaded = true;
        this.isApproveButtonDisabled = true;
        //this.isGAPButtonDisabled     = true;
        this.isRejectButtonDisabled  = true;
        reject({recordId : this.currentRecordId,isCpq:this.isCpq}).then(result => {
            if(result.success){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Rejected',
                        message : 'Rejected succesfully!',
                        variant : 'success',
                    }),
                )
                const okButtonAction = new CustomEvent('refreshview');
                this.dispatchEvent(okButtonAction);
                this.isLoaded = false;
                this.isApproveButtonDisabled = false;
                //this.isGAPButtonDisabled     = false;
                this.isRejectButtonDisabled  = false;
                //location.reload();
                //this.isLoaded = false;
                /*
                setTimeout(function(){
                    location.reload();
                    }, 5000);
                //location.reload();
                */
                
            }else if(result.success == false){
                var errorMessage = result.msg;
                if(errorMessage.includes('ENTITY_IS_LOCKED') || errorMessage.includes('This record is locked')){
                    errorMessage = 'You do not have permission to update the Quote at this time.'
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Error',
                        message : errorMessage,
                        variant : 'error',
                    }),
                )
                this.isLoaded = false;
                this.isApproveButtonDisabled = false;
                //this.isGAPButtonDisabled     = false;
                this.isRejectButtonDisabled  = false;
            }
            
        
    }).catch(error => {
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Error',
                message : error,
                variant : 'error',
            }),
        )
        this.isLoaded = false;
        this.isApproveButtonDisabled = false;
                //this.isGAPButtonDisabled     = false;
                this.isRejectButtonDisabled  = false;
    });
    }
    handleManualOverrideClick(){
        //const okButtonAction = new CustomEvent('manualOverRide');
        //this.dispatchEvent(okButtonAction);
        alert("Run Asset Matching..");
    }
}