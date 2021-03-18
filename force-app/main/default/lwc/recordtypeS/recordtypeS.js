import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import TASK_OBJECT from '@salesforce/schema/Account';

export default class RecordtypeS extends LightningElement {
    @track statusOptions;
    @track value;
    @api objectApiName;

    @track objectInfo;

    @wire(getObjectInfo, { objectApiName: TASK_OBJECT,})
    objectInfo;


    get recordTypeId() {
        // Returns a map of record type Ids 
        console.log(this.objectInfo);
        const rtis = this.objectInfo.data.recordTypeInfos;
        return rtis;
    }
}