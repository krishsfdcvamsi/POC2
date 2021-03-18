import { LightningElement, wire, api, track } from 'lwc';
import getMechanicalList from '@salesforce/apex/CDX_Mechanical_Data_Object_Finder.getMechanicalList';

export default class MechList extends LightningElement {
  @track GVP;
  @track error;
  @api recordId;
  @api NoMecha;
  @wire(getMechanicalList, { WiredAssetId: '$recordId' })
  FoundMecha({ error, data }) {
    
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