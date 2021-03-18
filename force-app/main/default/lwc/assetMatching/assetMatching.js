import { LightningElement, wire, api, track } from 'lwc';
import getRecords from '@salesforce/apex/gapProcessSelectedCarsController.getRecords';
import createLineItem from '@salesforce/apex/gapProcessSelectedCarsController.createLineItem';
import getCustomerSpec from '@salesforce/apex/CustomerSpecController.getCustomerSpecInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import errorMessage from '@salesforce/label/c.Asset_Matching_Error_Message';
export default class AssetMatching extends LightningElement {
    @track records = [];
    @track error;
    @api recordId;
    @track currentRecordId;
    @track showcheckBox = true;
    @track hideColumnNumbers = true;
    @track preSelectedRows = [];
    @track setLineItems=[];
    inLoading =true;
    queryOffset  = 0;
    queryLimit   = 10;
    totalRecordCount;
    allRrecords;
    isLoaded = false;
    needConfigIds  = [];
    selectAsIn  = [];
    isShowError = false;
    custmerSpecMessage ;
    vfPageURL ;
    isShowAssetLines = false;
    allSelectedGroups = [];
    @track columns = [
        {label: 'Group Name', initialWidth: 100,fieldName: 'GroupLink', type: 'url',sortable:true, 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank',initialWidth: 100}},

            //{label: 'Group Name', fieldName: 'GroupLink', type: 'url',sortable:true, 
            //typeAttributes: {label: { fieldName: 'GroupName' }, target: '_blank'}},
        {
            label: '# of Cars',
            fieldName: 'NumberOfAssets',
            type: "number",
            initialWidth: 150
        },
        {
        label: 'Group Definition',
        fieldName: 'Description',
        },
        
        {
            label: 'Max Score',
            fieldName: 'MaxAssetScore',
            type: "percent",
            initialWidth: 150,
            typeAttributes: { maximumFractionDigits: '2' }
        },
        {
            label: 'Min Score',
            fieldName: 'MinAssetScore',
            type: "percent",
            initialWidth: 150,
            typeAttributes: { maximumFractionDigits: '2' }
        },
        {
            label: 'Project Number',
            fieldName: 'ProjectNumber',
            type: "text",
            initialWidth: 150
        },
        {
            label: 'TR Number',
            fieldName: 'TRNumber',
            type: "text",
            initialWidth: 250
        },
        { type: 'button-icon', 
        label: 'Select As-Is',
        initialWidth: 100,
        typeAttributes: { iconName:'utility:automate',label: 'Select As-In', title:'Select As-In',
        name: 'Select_As_Is', variant: 'brand',
        disabled: { fieldName: 'selectAsInActive'},
        iconPosition: 'left' } },

        { type: 'button-icon',label: 'Need Configuration',
        initialWidth: 150,
        title:'Need Configuration',
        typeAttributes: {iconName:'utility:custom_apps', label: 'Need Configuration', 
        name: 'Need_Configuration', variant: 'brand',
        disabled: { fieldName: 'needConfigurationIsActive'},
        iconPosition: 'left' } },
        { type: 'button-icon',label: 'Manage Assets',
        initialWidth: 120,
         title:'Manage Assets',
        typeAttributes: {iconName:'utility:copy', label: 'Manage Assets', 
        name: 'Manage_Assets', variant: 'brand',
        disabled: { fieldName: 'manageAssets'},
        iconPosition: 'left' } }
    ];
    
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'Select_As_Is':
                this.addLineItem(row,'As Configured');
                break;
             case 'Need_Configuration':   
                this.addLineItem(row,'Need Configuration');
                break;
            case 'Manage_Assets':
                this.showAssetLines(row);
                break;

          }
     }
    needConfig(tableRow){
        var groupId = tableRow.Id;
                if(this.selectAsIn.includes(groupId)){
                    var index = this.selectAsIn.indexOf(groupId);
                    if (index > -1) {
                        this.selectAsIn.splice(index, 1);
                    }
                }
        this.needConfigIds.push(groupId);
    }
    selectAsIs(tableRow){
        var groupId = tableRow.Id;
                if(this.needConfigIds.includes(groupId)){
                    var index = this.needConfigIds.indexOf(groupId);
                    if (index > -1) {
                        this.needConfigIds.splice(index, 1);
                    }
                }
        this.selectAsIn.push(groupId);
    }
    showAssetLines(tableRow){
        var groupId = tableRow.Id;
        debugger;
        console.log('groupid-->> ' +groupId);
        this.vfPageURL = this.vfPageURL+'/apex/AssetGroup?Id='+groupId;
        this.isShowAssetLines = true;
    }
    handleGroupClose(){
        this.isShowAssetLines = false;
    }
    addLineItem(tableRow,actionType){
        this.isLoaded = false;
        var groupId = tableRow.Id;
       var deleteRecords = this.records;
       for ( var i = 0; i < deleteRecords.length; i++ ) {
            if(actionType == 'Need Configuration'){
                if(groupId == deleteRecords[i].Id){
                    this.needConfigIds.push(deleteRecords[i].Id);
                    if(this.allSelectedGroups.includes(groupId) == false){
                        this.allSelectedGroups.push(deleteRecords[i].Id);
                    }
                   deleteRecords[i].needConfigurationIsActive  = true;
                    deleteRecords[i].selectAsInActive  = false;
                    if(this.selectAsIn.includes(groupId)){
                        var index = this.selectAsIn.indexOf(groupId);
                        if (index > -1) {
                            this.selectAsIn.splice(index, 1);
                        }
                    }
                }
                
            }else if(actionType == 'As Configured'){
                if(groupId == deleteRecords[i].Id){
                    if(this.allSelectedGroups.includes(groupId) == false){
                        this.allSelectedGroups.push(deleteRecords[i].Id);
                    }
                    this.selectAsIn.push(deleteRecords[i].Id);
                    deleteRecords[i].needConfigurationIsActive  = false;
                    deleteRecords[i].selectAsInActive  = true;
                    if(this.needConfigIds.includes(groupId)){
                        var index = this.needConfigIds.indexOf(groupId);
                        if (index > -1) {
                            this.needConfigIds.splice(index, 1);
                        }
                    }
                }
                
            }
        }
        this.records = [...deleteRecords];
        this.isLoaded = true;
       }
    getSelectedRecords(event) {
        const selectedRows = event.detail.selectedRows;
       for ( var i = 0; i < selectedRows.length; i++ ) {
            this.setLineItems.push(selectedRows[i]);
        }
      }
      handleSubmitClick(){
        this.isLoaded = false;
        createLineItem({selectAsIdGroups: this.selectAsIn,selectNeedConfig:this.needConfigIds, quoteId : this.currentRecordId}).then(result => {
                if(result.success){
                    var allrecordValues = this.records;
                    var finalValues = [];
                    for( var i = 0; i < allrecordValues.length; i++ ) {
                        var groupId = allrecordValues[i].Id;
                       if(this.allSelectedGroups.includes(groupId) == false){
                            finalValues.push(allrecordValues[i]);
                        }
                    }
                    this.records = [...finalValues];
                    this.showToast('Success','Quote Line Items Created Successfully.','success');
                    this.isLoaded = true;
                }else{
                    this.showToast('Error',result.msg,'error');
                }
                
            }).catch(error => {
                console.log('error',error);
                this.error = error;
                this.showToast('Error','Something went wrong, please contact you Admin','error');
              });
            
      }
    connectedCallback() {
       this.currentRecordId = this.recordId;
       this.custmerSpecMessage  = errorMessage;
        this.loadRecords();
        this.getCustomerSpec();
    }
    getCustomerSpec(){
        getCustomerSpec({quoteId : this.currentRecordId,isTrinity : false}).then(result => {
            console.log('resultpricingtable',result);
            if(result.Status__c == 'In Progress'  || result.Status__c == 'ready for matching'){
                this.isShowError = true;
            }else{
                this.isShowError = false;
            }
        }).catch(error => {
            console.log('error',error);
            this.error = error;
            //this.record = undefined;
        });
    }
    loadMoreData(event) {
        this.isLoaded = false;
        console.log('totalRecordCount>>>>>>',this.totalRecordCount);
        console.log('records>>>>>>',this.records.length)
        if(this.totalRecordCount != this.records.length){
            const currentRecord = this.records;
            const { target } = event;
            target.isLoading = true;
            console.log('loading more data...');
            this.queryOffset = this.queryOffset + this.queryLimit;
            console.log('rowOffSet>>',this.queryOffset);
            this.loadRecords()
                .then(()=> {
                    target.isLoading = false;
                });   
        }else{
            const { target } = event;
            target.isLoading = false;
            this.isLoaded = true;
            this.inLoading = false;
        }
        
    }

    loadRecords(){
        let flatData;
        return getRecords({reocrdId : this.currentRecordId,queryLimit: this.queryLimit, queryOffset: this.queryOffset})
        .then(result => { 
            console.log('result>>>>get>>>',result);
            if(result.success){
                    
                    if(result.totalGroups == 0){
                        //this.showToast('Warning..','No records to load.','warning');
                    }else{
                        let updatedRecords = [...this.records, ...result.totalGroups];
                        this.records        = updatedRecords;
                        this.totalRecordCount = result.totalCount;
                    }
                    this.isLoaded = true;
            }else{
                this.isLoaded = true;
            }
            this.vfPageURL = result.strURL;
            //this.totalRecordCount = result.totalCount;
        }).catch(error => { 
            this.error = error ;
            this.showToast('Error!!',error,'error');
            this.isLoaded = true;
        })
    }
    showToast(title,message,type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}