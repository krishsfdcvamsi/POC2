import { LightningElement,api } from 'lwc';

export default class AddButtons extends LightningElement {
    @api buttonInfo = [];
    connectedCallback() {
       
        this.buttonInfo[0].type = 'Brand';
        this.buttonInfo[0].label = 'Save';
        this.buttonInfo[0].title = 'Save';
        this.buttonInfo[0].name = 'Save';
        this.buttonInfo[1].type = 'Brand';
        this.buttonInfo[1].name = 'Cancel';
        this.buttonInfo[1].label = 'Cancel';
        this.buttonInfo[1].title = 'Cancel';
        //this.buttonInfo.label = 'Save';
        //title
        //alert('lwc'+this.currentRecordId);
        //this.loadRecords();
    }
}