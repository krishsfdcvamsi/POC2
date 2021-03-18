import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
/*
import PRODUCT_OPTION_NAME from '@salesforce/schema/SBQQ__ProductOption__c.Product_Option_Name__c';
import LX_PACKAGE_ID from '@salesforce/schema/SBQQ__ProductOption__c.Lx_Package_ID__c';
import DESCRIPTION from '@salesforce/schema/SBQQ__ProductOption__c.Description__c';
import LEAD_TIME from '@salesforce/schema/SBQQ__ProductOption__c.Lead_Time__c';
import LABOR_HOURS from '@salesforce/schema/SBQQ__ProductOption__c.Labor_Hours__c';
import MARKUP_RATE from '@salesforce/schema/SBQQ__ProductOption__c.MarkupRate__c';
import CONFIGUREDSKU from '@salesforce/schema/SBQQ__ProductOption__c.SBQQ__ConfiguredSKU__c';
import NUMBER from '@salesforce/schema/SBQQ__ProductOption__c.SBQQ__Number__c';
import OPTIONALSKU from '@salesforce/schema/SBQQ__ProductOption__c.SBQQ__OptionalSKU__c';
import QUANTITY from '@salesforce/schema/SBQQ__ProductOption__c.SBQQ__Quantity__c';
import TYPE from '@salesforce/schema/SBQQ__ProductOption__c.SBQQ__Type__c';
import UNITPRICE from '@salesforce/schema/SBQQ__ProductOption__c.SBQQ__UnitPrice__c';

import getProducts from '@salesforce/apex/ProductOptionsListViewController.getAllProducts';
*/
import saveProductOption from '@salesforce/apex/ProductOptionsListViewController.saveProductOption';
import labourRate from '@salesforce/label/c.Labour_Rate';

/*
const columns = [
    { label:'Product Name', 
    fieldName: 'productLink', 
    type: 'url', 
    typeAttributes: {label: {fieldName: 'Name'},
    tooltip:'Go to detail page', target: '_blank'}}, 
    { label: 'Car Type', fieldName: 'RFO_STDCarType__c', type: 'text' },
    { label: 'Quantity', fieldName: 'RFO_Qty__c', type: 'text', },
    
    
    { label: 'Category', fieldName:'RFO_Category__c', type: 'text'}, 
    { label: 'Charge Type', fieldName: 'SBQQ__ChargeType__c', type: 'text'}, 
    { label: 'Component', fieldName: 'SBQQ__Component__c', type: 'boolean'},
    { label: 'Configuration Type', fieldName: 'SBQQ__ConfigurationType__c', type: 'text'},
    { label: 'Finance Type', fieldName: 'RFO_FinanceType__c', type: 'text'},
    { label: 'Car Type Group Name', fieldName: 'RFO_CarTypeGroupName__c', type: 'text'},
    { label: 'Family', fieldName: 'Family', type: 'text'}, 
    
];
*/
export default class ProductOptionsListViewLwc extends LightningElement {
    @api productId;
    @track error;
    @track productOptionName;
    @track lxPackageId;
    @track quantity     =   0;
    @track unitPrice    =   0;
    @track labourHours  =   0;
    @track markUp       =   0;
    @track laborCost    =   0;
    @track description;
    @track rate=  labourRate;
    @track cardTitle='Create New LX Package';
    @api showSpiner = false;
    @track toast =false;
    @track toastType = '';
    @track toastCss = '';
    @track toastMessage ='';
	lxPackageErrorShow = false;
    /*
    @wire(getProducts)
    wProducts({error,data}){
        console.log('data>>>>>',data);
        if(data){
            let recs = [];
            for(let i=0; i<data.length; i++){
                let product = {};
                product.rowNumber = ''+(i+1);
                product.productLink = '/'+data[i].Id;
                product = Object.assign(product, data[i]);
                recs.push(product);
            }
            this.products = recs;
            this.showTable = true;
        }else{
            this.error = error;
        }       
    }
    
    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }

   getSelectedProductOption(event) {
        var selectedRows = event.detail.selectedRows;
        this.productOptions = selectedRows;
    }
    AddOptions(){
        alert('Add as options');
        console.log('selectedOptions',this.selectedOptions);
    }
    createNewOption(){
        //alert('create New..');
        this.createNew = true;
        this.showTable = false;
        this.cardTitle = 'Create New Product Options';
    }
    handleSuccess(event){
        this.cardTitle = 'All Product Options';
        this.createNew = false;
        this.showTable = true;
        const evt = new ShowToastEvent({
            title: "Product Option Created Successfully",
            message: "Product Option Created Successfully: " + event.detail.Name,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }
    */
   handleCancelClick(){
    this.showSpiner = true;
     //  alert('close..');
    this.productOptionName  =   null;
    this.lxPackageId        =   null;
    this.quantity           =   0;
    this.unitPrice          =   0;
    this.labourHours        =   0;
    this.markUp             =   0;
    this.description        =   null;
    this.showSpiner = false;
     this.toast              = true;
     this.toastCss           =   'slds-notify slds-notify_toast slds-theme_warning';
     this.toastMessage        =   'Please Click on "X" button to go back or close this window.';
    }
    updateDescription(event){
        this.description = event.target.value;
    }
    calculateLaborCost(event){
        var  laborHours  = event.target.value;
        this.laborCost  =   laborHours*this.rate;
    }
    handleSaveClick(){
        this.showSpiner = true;
        var formElements     =   this.template.querySelectorAll("lightning-input");
        formElements.forEach(function(element){
            if(element.name=="productOptionName")
                this.productOptionName  =   element.value;
            else if(element.name=="lxPackageId")
                this.lxPackageId    =   element.value;
            else if(element.name=="quantity")
                this.quantity    =   element.value;
            else if(element.name=="unitPrice")
                this.unitPrice    =   element.value;
            else if(element.name=="labourHours")
                this.labourHours    =   element.value;
            else if(element.name=="markUp")
                this.markUp    =   element.value;
        },this);
        
		if(this.lxPackageId == '' || this.lxPackageId == null){
			this.lxPackageErrorShow = true;
			this.showSpiner = false;
			return false;
		}else{
			this.lxPackageErrorShow = false;
		}
		if(this.lxPackageErrorShow == false){
        saveProductOption({packageName: this.productOptionName,
                            pxPackageId:this.lxPackageId,
                            quantity : this.quantity,
                            unitPrice:this.unitPrice,
                            labourHours:this.labourHours,
                            markup:this.markUp,
                            description:this.description,
                            //laborCost :this.laborCost,
                            productId:this.productId
        })
        .then(result => {
            //this.recordId = result;
            //console.log(result);
            //alert('success');
            if(result.success){
               
                this.productOptionName  =   null;
                this.lxPackageId        =   null;
                this.quantity           =   0;
                this.unitPrice          =   0;
                this.labourHours        =   0;
                this.markUp             =   0;
                this.description        =   null;
                this.toast              = true;
                this.toastCss           =   'slds-notify slds-notify_toast slds-theme_success';
                this.toastMessage        =   'New Lx Package Created successfully.';
                this.showSpiner = false;
            }else{
                this.toast              = true;
                this.toastCss           =   'slds-notify slds-notify_toast slds-theme_warning';
                this.toastMessage        =   result.msg;
                this.showSpiner = false;
            }
        })
        .catch(error => {
            console.log('error>>>>',error.body['message']);
            this.toast              = true;
                this.toastCss           =   'slds-notify slds-notify_toast slds-theme_warning';
                this.toastMessage        =   error.body['message'];
            
                this.showSpiner = false;
        });
		}
    }
}