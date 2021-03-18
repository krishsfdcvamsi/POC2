import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedFilesByRecordId from '@salesforce/apex/FileViewerController.getRelatedFilesByRecordId';
import id from '@salesforce/user/Id';

export default class ShowRelatedToRecordId extends NavigationMixin(LightningElement) {
    // Current record ID. *recordId* is a reserved identifier
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: [id] })
    record;
    // Declare to pass heightInRem to the child component in markup
    @api heightInRem;
    // Specify which file for child component to render
    @track fileID;
    allFiles = [];
    // Determine if in Community
    @api isCommunity;

    @wire(getRelatedFilesByRecordId, { recordId: '$recordId' })
    wiredFieldValue({ error, data, recordId }) {
        console.log("Record Id: " + this.recordId);
        if (data) {
            this.allFiles = data;
            this.error = undefined;
            // Save the first related file ID to fileID            
            const fileIDs = Object.keys(data);
            this.fileID =  fileIDs.length ? fileIDs[0] : undefined; 
        } else if (error) {
            this.error = error;
            this.allFiles = undefined; 
            this.fileID = undefined; 
        }
    }

    // Maps file ID and title to value and label
    get fileList() {
        if (!this.fileID) return [];

        const fileList = [];
        const files = Object.entries(this.allFiles);
        console.log('File List: ' + files[0]);
        for (const [ID, title] of files) {
            fileList.push({
                value: ID,
                label: title
            });
        }        
        return fileList;
    }

    // event handler for each file: onclick, change fileID
    setFileID(event) {
            // Can be used for non Community pages only
            /*
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state : {
                    selectedRecordId: event.target.value
                }
            });
            */
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.value,
                    objectApiName: 'ContentDocument',
                    actionName: 'view'
                }
            });
    }
    
}