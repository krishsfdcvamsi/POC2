import { LightningElement , api } from 'lwc';
import saveRecord from '@salesforce/apex/AddSaveandCancelButtonController.saveSobject';

export default class AddSaveandCancelButton extends LightningElement {
    @api objectInfo;
    error;
    handleSaveClick(){
        saveRecord({objectInfo : this.objectInfo})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : 'Record Created succesfully!',
                    variant : 'success',
                }),
            )
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
        })
    }
    handleCancelClick(){
        const okButtonAction = new CustomEvent('cancel');
        this.dispatchEvent(okButtonAction);
    }
}