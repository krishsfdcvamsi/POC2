import { LightningElement,api,track } from 'lwc';

export default class GapProcessBaseCmp extends LightningElement {
    @api    objectApiName;
    @api    recordId;
    @track currenObjectName;
    @track currenRecordId;
    connectedCallback() {
        this.currenRecordId = this.recordId;
        this.currenObjectName = this.objectApiName;
        //alert('currenRecordId'+this.currenRecordId);
    }
}