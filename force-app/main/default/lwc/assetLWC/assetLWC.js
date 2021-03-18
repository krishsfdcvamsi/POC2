import { LightningElement, track, api } from 'lwc';
import getAssetDrawingsList from '@salesforce/apex/AssetLWCCtrl.getAssetDrawingsList';
import getFile from '@salesforce/apex/assetDrawingsFile.getFile';

const columns = [
    // { label: "Asset", fieldName: 'assetId', type: 'text'},
    { label: "Drawing Title", fieldName: 'Drawing__c', type: 'text', wrapText: true},
    { label: "Drawing#", fieldName: 'drawingNumber__c', type: 'text'},
    { label: "COC#", fieldName: 'COCNumber__c', type: 'text'},
    { label: "R1 Inspection", fieldName: 'R1__c', type: 'text'},
    { label: 'Drawing File', type:  'button',
      typeAttributes: 
      {
        label: 'Get File', 
        name: 'getFile', 
        title: 'getFile', 
        disabled: false, 
        value: 'test'
      }
    }
];

export default class DatatableBasic extends LightningElement {
    @track data = [];
    @track columns = columns;
    @track showLoadingSpinner = false;
    @track errorDownloadingFile = false;
    @track errorDownloadingDrawingNumber = '';
    @api foundDrawings;
    @api NoDrawings;
    @api recordId

     connectedCallback() {
        this.showLoadingSpinner = true;
        console.log('$recordId:' + this.recordId);
        getAssetDrawingsList({WiredAssetId: this.recordId})
            .then(result =>{
              this.data = JSON.parse(result);
              if (this.data.length !== 0)
                this.foundDrawings = true;
                console.log('result:' + this.data);
            })
            .catch(error => {
              this.data = [];
              this.foundDrawings = false;
              console.log('error:' + error);
          });
          this.showLoadingSpinner = false;
    }

    handleClick(event) {
      let row = event.detail.row;
      console.log('DrawingNUmber clicked:' + row.drawingNumber__c);
      //alert('Get File clicked');

      getFile({
        drawingNumber: row.drawingNumber__c
        })
        .then(result => {
          if(result === 'failed') {
              this.errorDownloadingFile = true;
              this.errorDownloadingDrawingNumber = row.drawingNumber__c;
              return;
          }
            this.errorDownloadingFile = false;
            this.errorDownloadingDrawingNumber = '';
            var firstChar = result.charAt(0);
            var lastChar = result[result.length -1];
            //remove double quotes from begin and end
            if(firstChar && lastChar === String.fromCharCode(34)){
                result = result.slice(1, -1);
            }
           
            var link = document.createElement('a');
            link.download = row.drawingNumber__c + '.pdf';
            link.href = 'data:application/octet-stream;base64,' + result;

            link.click();

        })
        .catch(error => {
            console.log('error:' + error);
           // alert('failed!');
        });
    }
}