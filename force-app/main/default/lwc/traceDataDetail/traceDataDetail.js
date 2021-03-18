import { LightningElement, wire, api, track } from 'lwc';
import getGVPList from '@salesforce/apex/CDX_GVP_Controller.getGVPList';

export default class GVPList extends LightningElement {

  @track GVP;
  @track error;
  @api recordId;
  @api NoGVP;
  @wire(getGVPList, { WiredAssetId: '$recordId' })
  FoundGVP({ error, data }) {
    
    if (data) {
        // eslint-disable-next-line no-console
        //console.log("Data: "+data);
        // eslint-disable-next-line no-console
        //console.log("Record: " +this.recordId);
        this.GVP = data;
        this.error = undefined;
        // eslint-disable-next-line no-console
        //console.log("GVP: " +this.GVP);
    } else if (error) {
        this.error = error;
        this.GVP = undefined;
    }
  }
  
}