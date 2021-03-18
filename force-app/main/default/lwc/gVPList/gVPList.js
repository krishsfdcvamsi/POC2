import { LightningElement, wire,api} from 'lwc';
import getGVPExternalData from '@salesforce/apex/CDX_RetrieveGVPExternalData.getGVPExternalData';

export default class GVPList extends LightningElement {

    @api recordId;
    @wire(getGVPExternalData, {asId:'$recordId' })
      GVPExternalList;
}