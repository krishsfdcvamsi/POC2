import { LightningElement, wire, api, track  } from 'lwc';
import GetMileageEqualization from '@salesforce/apex/CDX_Mileage_Equalization.GetMileageEqualization';
import strUserId  from '@salesforce/user/Id';

const columns = [
    { label: 'Name', fieldName: 'Community_URL__c', type: 'url', typeAttributes: {label: { fieldName: 'Title' }}},
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Account', fieldName: 'Community_Account__c'},
    { label: 'File Type', fieldName: 'FileExtension'},
];

export default class CDXMilageEqualization extends LightningElement 
{
    @track results;

    @track foundId = strUserId ;
    @track columns = columns;
    @track Content;
    @track error;
    @api recordId;
    @api NoGVP;
    @wire(GetMileageEqualization, { UserID: '$foundId' })
    FoundGVP({ error, data }) {
      
      if (data) {
          // eslint-disable-next-line no-console
          console.log("Found ID: "+this.foundId);
          // eslint-disable-next-line no-console
          //console.log("Record: " +this.recordId);
          this.Content = data;
          this.error = undefined;
          // eslint-disable-next-line no-console
          console.log('Returned Data '+data);

          this.results= JSON.stringify(data);
          // eslint-disable-next-line no-console
          console.log('values-->'+this.results.length);

          // eslint-disable-next-line no-console
          console.log("Size of returned list: " +this.Content.lentgh);
      } else if (error) {
          this.error = error;
          this.Content = undefined;
      }
    }
}