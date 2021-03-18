import { LightningElement, track , api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordTypes from '@salesforce/apex/RecordTypeController.getRecordTypeValues';
export default class LwcCreateNewRecord extends LightningElement {
    @api    objectApiName;
    @api    recordId;
    @api    showForm= false;
    @track  recordTypeIds;
    @track  defaultRecordTypeId;
    @api    showCreateForm = false;
    @api    showEditForm = false;
    @track  error;
    @track isLoaded = true;
    //alert(objectName);
    connectedCallback() {
        this.setQuote();
        getRecordTypes({objectName:this.objectApiName}).then(result => {
            //console.log('resultVamsi',result);
            //this.recordTypeIds = result.RecordTypes;
            const recordTypeInfo = [];
                    for (var key in result.RecordTypes) {
                        console.log('label',result.RecordTypes[key]);
                        console.log('key',key);
                        recordTypeInfo.push({ label:result.RecordTypes[key], value:key});    
                    }
                    console.log('recordTypeInfo>>>',recordTypeInfo);
            this.recordTypeIds = recordTypeInfo;
            console.log('recordTypeIds>>>',this.recordTypeIds);
            this.defaultRecordTypeId = result.defaultRecordTypeId;
            this.error = undefined;
            this.isLoaded = false;
        })
        .catch(error => {
            this.error = error;
            this.recordTypeIds = undefined;
            this.defaultRecordTypeId = undefined;
        });
        
    }
    setQuote(){
        var allFields = document.querySelectorAll("input");
        console.log('allFields>>>>>',allFields);
    }
    handleSelecteRecordType(){
        //alert(this.defaultRecordTypeId);
        this.showForm = false;
        this.showCreateForm = true;
        this.showEditForm = false;
        //this.isLoaded = true;
    }
    handleSuccess(event) {
        console.log(event.detail.id);
        //alert('successfully created..');
        const evt = new ShowToastEvent({
            title: "Success",
            message: "Record Created Succesfully",
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.showForm = false;
        this.showCreateForm = false;
        this.showEditForm = false;
        const handleSuccessEvent = new CustomEvent("successfullynewrecordcreation", {
            //detail: this.progressValue
          });
          // Dispatches the event to refresh the Price Table.
          this.dispatchEvent(handleSuccessEvent);
    }
}