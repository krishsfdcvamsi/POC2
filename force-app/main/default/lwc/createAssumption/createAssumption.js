import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getAccountRiders from '@salesforce/apex/CreateAssumptionController.getAccountRiders';
import createAssumption from '@salesforce/apex/CreateAssumptionController.createAssumption';
import { NavigationMixin } from 'lightning/navigation';

// - Object & Fields
import RIDER_OBJECT from '@salesforce/schema/RFO_Rider__c';

// - Utility Functions
import { showToast, parseErrorMessages, pageNavigation } from 'c/jsFunctionUtility';

export default class CreateAssumption extends NavigationMixin(LightningElement) {

    // ------- Public Attributes -------//
    @api recordId;

    // ------- Private Attributes -------//
    @track strDestinationAccountId;
    @track listRiderColumns;
    @track listRiderData;
    @track listEditedRider = [];
    @track isLoaded = false;

    // ------- Wire Method to Get Rider Object Fields and Prepare Rider Columns -------//
    @wire(getObjectInfo, { objectApiName: RIDER_OBJECT })
    riderObjectSchema({ data }) {
        if (data && data.fields) {
            let riderObjectFields = data.fields;
            this.listRiderColumns = [
                { label: riderObjectFields.RFO_TASRiderId__c.label, fieldName: 'RFO_TASRiderId__c' },
                { label: riderObjectFields.RFO_TotalOfCars__c.label, fieldName: 'RFO_TotalOfCars__c'},
                { label: riderObjectFields.Assumed_of_Cars__c.label, fieldName: 'Assumed_of_Cars__c', type: 'number', editable: true },
                { label: riderObjectFields.RFO_RiderType__c.label, fieldName: 'RFO_RiderType__c' },
                { label: riderObjectFields.RFO_OriginalMaturityDate__c.label, fieldName: 'RFO_OriginalMaturityDate__c', type: "date-local" },
                { label: riderObjectFields.RFO_CurrentMaturityDate__c.label, fieldName: 'RFO_CurrentMaturityDate__c', type: "date-local" },
                { label: riderObjectFields.RFO_RiderRate__c.label, fieldName: 'RFO_RiderRate__c', type: 'currency', cellAttributes: { alignment: 'left' } },
                { label: riderObjectFields.RFO_Term__c.label, fieldName: 'RFO_Term__c' },
                { label: riderObjectFields.RFO_RiderAverageBeginDate__c.label, fieldName: 'RFO_RiderAverageBeginDate__c', type: "date-local" },
                { label: riderObjectFields.RFO_RiderAverageEndDate__c.label, fieldName: 'RFO_RiderAverageEndDate__c', type: "date-local" },
                { label: riderObjectFields.RFO_Status__c.label, fieldName: 'RFO_Status__c' }
            ];
        }else{
        }
    }

    // ------- Connected Call Back, Get Rider Records -------//
    connectedCallback(){
        //this.isLoaded = true;
        getAccountRiders({strAccountId:this.recordId})
        .then(listRiders => {
            if(listRiders.length==0){
                this.showToastMessage('Failed', 'There are no Riders on this Account', 'error', 'dismissable');
            }
            this.listRiderData = listRiders;
            this.isLoaded = false;
            
        })
        .catch(error => {
            let listErrorMessages = parseErrorMessages(error);
            this.showToastMessage('Failed', listErrorMessages, 'error', 'dismissable');
            this.isLoaded = false;
        })
    }

    handleDestinationAccountChange(event){
        this.strDestinationAccountId = event.detail.value;
    }

    handleCellChange(event){
        if (event.detail && event.detail.draftValues && event.detail.draftValues.length > 0) {
            let objEditedRider = new Object();
            objEditedRider.Id = event.detail.draftValues[0].Id;
            objEditedRider.Assumed_of_Cars__c = event.detail.draftValues[0].Assumed_of_Cars__c;
            this.listEditedRider.push(objEditedRider);
        }
    }

    handleCustomSubmit(){
        this.template.querySelector('lightning-button.submitButton').click();
    }

    // ------- Submit to Save Assumption and Update Riders -------//
    handleSubmit(event){
        event.preventDefault();
        let listAssumptionFields = event.detail.fields;
        // - Destination Account Validation
        if (!listAssumptionFields.Destination_Account__c) {
            this.showToastMessage('Failed', 'Please select Destination Account.', 'error', 'dismissable');
            return;
        } else if (listAssumptionFields.Source_Account__c === listAssumptionFields.Destination_Account__c) {
            this.showToastMessage('Failed', 'Source and Destination Account cannot be same, Please select different Destination Account.', 'error', 'dismissable');
            return;
        }
        let listRider = this.template.querySelector('lightning-datatable.riderTable').getSelectedRows();
        if (listRider && listRider.length > 0) {
            this.isLoaded = true;
            let objAssumption = new Object();
            objAssumption.sobjectType = 'Assumption__c';
            objAssumption = listAssumptionFields;
            createAssumption({objAssumption:objAssumption, listSelectedRider:listRider, listEditedRider:this.listEditedRider})
            .then(objAssumptionResult => {
                if (objAssumptionResult.strAssumptionId) {
                    let objRedirectPageReference = pageNavigation('standard__recordPage', objAssumptionResult.strAssumptionId, 'Assumption__c', 'view', undefined);
                    this[NavigationMixin.Navigate](objRedirectPageReference);
                } else if (objAssumptionResult.strErrorMessage) {
                    this.showToastMessage('Failed', objAssumptionResult.strErrorMessage, 'error', 'dismissable');
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                let listErrorMessages = parseErrorMessages(error);
                this.showToastMessage('Failed', listErrorMessages, 'error', 'dismissable');
                this.isLoaded = false;
            })
        } else {
            this.showToastMessage('Failed', 'Please select at least one Rider.', 'error', 'dismissable');
            this.isLoaded = false;
        }
    }

    // ------- Close Component -------//
    handleCancel(){
        this.dispatchEvent(new CustomEvent('closecomponent'));
    }

    // ------- Show Toast Message -------//
    showToastMessage(strTitle, strMessage, strVariant, strMode){
        let objShowToastEvent = showToast(strTitle, strMessage, strVariant, strMode);
        this.dispatchEvent(objShowToastEvent);
    }

}