import { LightningElement, track , api} from 'lwc';
import getQuotes from '@salesforce/apex/PricingScenariosController.getallRecords';

import deleteQuoteLine from '@salesforce/apex/PricingScenariosController.deleteQuoteLine';

//import deleteAccounts from '@salesforce/apex/dynamicRowsController.deleteAccounts';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class PricingScenariosTable extends NavigationMixin(LightningElement) {
    
    @track isEdited = false;
    @track toggleSaveLabel = 'Save';
    @track myList = [];
    @track viewRecordId;
    @track viewObjectName;
    @track isView = false;
    @track isCreate = false;
    @track isLoaded =true;
    @api    recordId;
    @track currentRecordId;
    @api productId;
    isCalculate = false;
    quoteLineItemId;
    
    /*--------------------Mapping field values to the list onchange START --------------------*/                
    deletePricingScenario(event){
        this.isLoaded =  true;
        let currentId =  event.currentTarget.dataset.id;
        console.log('keyvalue>>>>>>',currentId);
        console.log('delete....');
        var currentValue = this.myList[currentId];
        console.log('currentValue>>>>>',currentValue.Id);
        deleteQuoteLine({quoteLineId : currentValue.Id}).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : 'QuoteLine deleted succesfully!',
                    variant : 'success',
                }),
            )
        
            if(this.myList.length > 1) 
            this.myList.splice(currentId, 1);
            this.error = undefined;
            this.isLoaded =  false;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error',
                    message : error.body.message+' , Please contact your system admin.',
                    variant : 'error',
                }),
            )
            this.isLoaded =  false;
            console.log('error>>>>',error.body.message);
            this.error = error;
        })
    }
    handleError(event){
        event.preventDefault();
        event.stopImmediatePropagation();
        let message = event.detail.detail;
        console.log('error happen....',message);
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Error',
                message : message,
                variant : 'error',
            }),
        )
        this.isLoaded = false;
    }
    handleSuccess(event){
        this.isCreate = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Success',
                message : 'Quote Line Created Successfully.',
                variant : 'success',
            }),
        )
        this.getQuotesInfo();
    }
    onSubmitHandler(event){
        this.isLoaded = true;
        event.preventDefault();
        const fields = event.detail.fields;
        console.log('hhhhhhh>',fields.RFO_LeaseQty__c);
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        console.log('hhhhhhh>');
        
    }
    handleNameChange(event) {
        let element = this.myList.find(ele  => ele.Id === event.target.dataset.id);
        element.Name = event.target.value;
        this.myList = [...this.myList];
        console.log(JSON.stringify(this.myList));
    }
    navigateToRecordQuteCalculator(event){
        let currentId =  event.currentTarget.dataset.id;
        this.isCalculate = true;
        this.quoteLineItemId = currentId;
    }
    handleCalClose(){
        this.isCalculate = false;
    }
    handlePicklistChange(event) {
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        alert(pickValue);
        let element = thishandleSelection.myList.find(ele  => ele.Id === uniqueKey);
        element.RFO_LeaseType = pickValue;
        this.myList = [...this.myList];
    }

    handleDependentPicklistChange(event) {
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        let uniqueKey = event.detail.key;

        let element = this.myList.find(ele  => ele.Id === uniqueKey);
        element.Dependent_Picklist__c = pickValue;
        this.myList = [...this.myList];
    }

    handleSelection(event) {
        alert('lookup selected.');
        let eventData = event.detail;
        let id = event.detail.selectedId;
        let uniqueKey = event.detail.key;
       
        let element = this.myList.find(ele  => ele.Id === uniqueKey);
        element.RFO_Product__c = id;
        this.myList = [...this.myList];
    }
    add() {
        let newList = this.myList;
        newList.push({Name : "", RFO_Product__c : "",  key : Math.random().toString(36).substring(2, 15)});
        this.myList = newList;
    }

    remove(event) { 
        let indexPosition = event.currentTarget.name;
        const recId = event.currentTarget.dataset.id;
                
        deleteAccounts({toDeleteId : recId})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : 'Record deleted succesfully!',
                    variant : 'success',
                }),
            )
            if(this.myList.length > 1) 
            this.myList.splice(indexPosition, 1);
            this.error = undefined;
        }).catch(error => {
            this.error = error;
        })
    }

    handleSave() {
        this.toggleSaveLabel = 'Saving...'
        let toSaveList = this.myList;
        toSaveList.forEach((element, index) => {
            if(element.Name === ''){
                toSaveList.splice(index, 1);
            }
        });

        this.myList = toSaveList;
        saveQuotes({records : toSaveList})
        .then(() => {
            this.toggleSaveLabel = 'Saved';
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : 'Records saved succesfully!',
                    variant : 'success',
                }),
            )
            this.getQuotesInfo();
            this.isEdited = false;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            //this.record = undefined;
            console.log("Error in Save call back:", this.error);
        })
        .finally(() => {
            setTimeout(() => {
                this.toggleSaveLabel = 'Save';
            }, 3000);
        });
    }

    connectedCallback() {
        //alert(this.recordId);
        this.currentRecordId = this.recordId;
        
        //alert('currentRecordId'+this.currentRecordId);
        this.getQuotesInfo();
       
    }
    
    getQuotesInfo() {
        getQuotes({quoteId:this.currentRecordId})
            .then(result => {
                console.log('resultpricingtable',result);
                //this.record = result;
                //result = 
                /*
                this.myList = result;
                for(let i = 0; i < this.myList.length; i++) {
                    if(this.myList[i].RFO_Product__c) {
                        this.myList[i].ProductName = this.myList[i].RFO_Product__r.Name;
                        this.myList[i].ProductURL = '/${this.myList[i].RFO_Product__r.Id}';
                    }
                    if(myList[i].Id)
                    myList[i].recordUrl = '/${loopResult[i].Id}';
                }
                */

                console.log('resultpricingtablerecord',result);
                this.myList = result;
                this.error = undefined;
                this.isLoaded = false;
            })
            .catch(error => {
                console.log('error',error);
                this.error = error;
                //this.record = undefined;
            });
    }

    onDoubleClickEdit(event) {
        let currentId =  event.currentTarget.dataset.id;
        this.myList[currentId].Edit = true;
        //console.log('currentIndex',currentId);
        //alert(currentId);
        //this.isEdited = true;
    }
    edit(event){
        let currIndex = event.currentTarget.dataset.id;
        //alert(currIndex);
        this.myList[currIndex].Edit = true;
        
    }
    handleRefresh(event){
        this.getQuotesInfo();
    }
    navigateToRecordEditPage(event) {
        let currentId =  event.currentTarget.dataset.id;
        this.viewRecordId = this.myList[currentId].Id;
        // Opens the Account record modal
        // to view a particular record.
        //let { Id } = row;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
               recordId: this.viewRecordId,
               actionName: 'edit'
            }
        });
    }
    view(event){
      let currentId =  event.currentTarget.dataset.id;
        //this.currentId
        this.viewRecordId = this.myList[currentId].Id;
        this.viewObjectName = 'SBQQ__QuoteLine__c';
        this.isView = true;
       /*
        const defaultValues = encodeDefaultFieldValues({
            Id: this.viewRecordId
        });
        let temp = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__QuoteLine__c',
                actionName: 'edit'                
            },
            state: {
                defaultFieldValues: defaultValues
            }
            
        };
        this[NavigationMixin.Navigate](temp);
        */
    }
    handleCancel() {
        for(let i = 0; i < this.myList.length; i++) {
            if(this.myList[i].Edit) {
                this.myList[i].Edit = false;
            }
        }
        //this.isEdited = false;
    }
    handleClose() {
        this.isView = false;
    }
    handleCreateSuccess(){
        this.isCreate = false;
        alert('Successfully Created');
    }
    handleCreateClose(){
        this.isCreate = false;
    }
    refreshTableAfterCreation(event){
        //alert('new record created');
        this.isCreate = false;
        this.getQuotesInfo();
    }
    handleCreateNew(){
        this.isCreate = true;
        /*
        let temp = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__QuoteLine__c',
                actionName: 'new'                
            },
            state : {
                nooverride: '1'
            }
            
        };
        this[NavigationMixin.Navigate](temp);
        //
        */
    }
}