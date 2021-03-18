import { LightningElement } from 'lwc';

export default class AddOkButton extends LightningElement {
    handleOkClick(){
        const okButtonAction = new CustomEvent('closeModal');
        this.dispatchEvent(okButtonAction);
        //var modal           = document.getElementsByClassName('slds-backdrop');
        //var modalBackDrop   = document.getElementsByClassName('slds-modal');
        }
}