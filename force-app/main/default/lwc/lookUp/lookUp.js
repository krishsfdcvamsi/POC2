import getResults from '@salesforce/apex/lwcCustomLookupController.getResults';
import getResultsWithParents from '@salesforce/apex/lwcCustomLookupController.getResultsWithParent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { api, LightningElement, track, wire } from 'lwc';

export default class LookUp extends LightningElement {

    @api objectName = 'Account';
    @api fieldName = 'Name';
    @api parentFieldName = '';
    @api parentId = '';
    @api selectRecordId = '';
    @api selectRecordName;
    @api Label;
    @track searchRecords = [];
    @api required = false;
    @api iconName = 'action:new_account'
    @api LoadingText = false;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;
    @track iconFlag =  true;
    @track clearIconFlag = false;
    @track inputReadOnly = false;
   

    searchField(event) {
        var currentText = event.target.value;
        //alert(currentText);
        this.LoadingText = true;
        
        getResultsWithParents({ 
            ObjectName: this.objectName, 
            fieldName: this.fieldName,
            ParentField : this.parentFieldName,
            ParentId : this.parentId,
            value: currentText  })
        .then(result => {
            this.searchRecords= result;
            this.LoadingText = false;
            console.log('result>>>lookup>>>>',result);
            this.txtclassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            if(currentText.length > 0 && result.length == 0) {
                this.messageFlag = true;
            }
            else {
                this.messageFlag = false;
            }

            if(this.selectRecordId != null && this.selectRecordId.length > 0) {
                this.iconFlag = false;
                this.clearIconFlag = true;
            }
            else {
                this.iconFlag = true;
                this.clearIconFlag = false;
            }
        })
        .catch(error => {
            console.log('-------error-------------'+error);
            console.log(error);
        });
        
    }
    
   setSelectedRecord(event) {
        var currentRecId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        this.txtclassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        this.iconFlag = false;
        this.clearIconFlag = true;
        this.selectRecordName = event.currentTarget.dataset.name;
        this.selectRecordId = currentRecId;
        this.inputReadOnly = true;
        const selectedEvent = new CustomEvent('selected', { detail: {recordId:currentRecId}});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    
    resetData(event) {
        this.selectRecordName = "";
        this.selectRecordId = "";
        this.inputReadOnly = false;
        this.iconFlag = true;
        this.clearIconFlag = false;
       
    }
}