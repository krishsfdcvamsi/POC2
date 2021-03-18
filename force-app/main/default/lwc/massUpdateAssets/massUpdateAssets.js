import { LightningElement,api,wire,track } from 'lwc';
import getAllAssetLines from '@salesforce/apex/ManageMassAssetsController.getAllAssetsLines';
import updateAssetLines from '@salesforce/apex/ManageMassAssetsController.updateAssetLineGroups';

/*
const columns = [
            {label: 'Asset Name', fieldName: 'AssestLink', type: 'url',sortable:true, 
            typeAttributes: {label: { fieldName: 'AssestName' }, target: '_blank'}},
            {label: 'Account Name', fieldName: 'AccountLink', type: 'url',sortable:true, 
            typeAttributes: {label: { fieldName: 'AccountName' }, target: '_blank'}},
            {label: 'Product Name', fieldName: 'ProductLink', type: 'url',sortable:true, 
            typeAttributes: {label: { fieldName: 'ProductName' }, target: '_blank'}},
            {label: 'TR Number', fieldName: 'TRNUmber', type: 'text', sortable:true},
            {label: 'Project Number', fieldName: 'Projectnumber', type: 'text', sortable:true},
            {label: 'Car Type', fieldName: 'CarType', type: 'text', sortable:true},
            {label: 'Status', fieldName: 'Status', type: 'text', sortable:true}
        ];
        */
export default class MassUpdateAssets extends LightningElement {
    @api recordId;
    @track msgBackgrund;
    @track showSpiner = true;
    @track lstAllAssets;
    @track lstTempAllAssets =[];
    @track errorMessage;
    @track showErrorMessage = false;
    @track showAssets = false;
    @track showPopup =  false;
    @track columns;
    @track updatingGroupId;
    @track selectedAssestLines;
    @track showPopupSpiner = false;
    @track errorPopUpMessage;
    queryOffset;
    queryLimit ;
    totalRecordCount;
    inLoading =true;
    isLoaded = false;
    seachKey;
    currentRecordId;
    assetsData;
    tempAssets;
    allAssetCount;
    TotalAssets;
    infininityLoading = true;
    connectedCallback(){
        
        this.currentRecordId = this.recordId;
        this.columns = [
            {label: 'Asset Group', fieldName: 'AssestLineGroupLink', type: 'url',sortable:true, 
            typeAttributes: {label: { fieldName: 'AssestLineGroupName' }, target: '_blank'}},
            {label: 'Asset Name', fieldName: 'AssestLink', type: 'url',sortable:true, 
            typeAttributes: {label: { fieldName: 'AssestName' }, target: '_blank'}},
            {label: 'Account Name', fieldName: 'AccountLink', type: 'url',sortable:true, 
            typeAttributes: {label: { fieldName: 'AccountName' }, target: '_blank'}},
            {label: 'Product Name', fieldName: 'ProductLink', type: 'url',sortable:true, 
            typeAttributes: {label: { fieldName: 'ProductName' }, target: '_blank'}},
            {label: 'TR Number', fieldName: 'TRNUmber', type: 'text', sortable:true},
            {label: 'Project Number', fieldName: 'Projectnumber', type: 'text', sortable:true},
            {label: 'Car Type', fieldName: 'CarType', type: 'text', sortable:true},
            {label: 'Status', fieldName: 'Status', type: 'text', sortable:true}
        ];
        this.queryOffset = 0;
        this.queryLimit = 10;
        this.loadRecords();
    }
    /*
    constructor(){
        super();
        
    }
    */
    get lstTempAllAssets() {
        return this.lstTempAllAssets.length ? this.lstTempAllAssets : null;
    }
    loadNewMoreData(event){
        const { target } = event;
        target.isLoading = true;
        //this.inLoading  = true;
        console.log('this.queryOffset>>>>>>>',this.queryOffset);
        if(this.tempAssets.length > this.assetsData.length ){
            this.queryOffset = this.queryOffset + 10;
            var secondSetValues  = this.tempAssets.slice(this.queryOffset,this.queryOffset+10);
            var finalAssets = this.assetsData.concat(secondSetValues);
            console.log('finalAssets>>>>>>',finalAssets);
            this.assetsData = finalAssets;
            this.infininityLoading = true;
            target.isLoading = false;
        }else if(this.tempAssets.length == this.assetsData.length){
            console.log('this.queryOffset>>>>>>>in the else>>>',this.queryOffset);
            target.isLoading        = false;
            this.infininityLoading  = false;
        }else{
            console.log('this.queryOffset>>>>>>>in the else>>>',this.queryOffset);
            target.isLoading = false;
            this.infininityLoading = false;
           // this.inLoading  = false;
        }
    } 
    loadRecords(){
        let flatData;
        console.log('this.seachKey>>>>>>>>',this.seachKey);
        console.log('this.currentRecordId>>>>>>>>',this.currentRecordId);
        return getAllAssetLines({quoteId:this.currentRecordId,queryOffSet: this.queryOffset, 
            queryLimit: this.queryLimit,searchKey:this.seachKey})
        .then(result => { 
            console.log('result>>>ManageAssets>>>>>>',result);
            if(result.noAssetsLines){
                this.errorMessage = result.noAssestMsg;
                this.showErrorMessage = true;
                this.msgBackgrund = 'background-color:red';
                this.showAssets = false;
                this.showSpiner = false;
        }else if(result.success == false){
            this.errorMessage = result.msg;
            this.showErrorMessage = true;
            this.msgBackgrund = 'background-color:red';
            this.showAssets = false;
            this.showSpiner = false;
        }else if(result.success){
            this.showErrorMessage = false;
            flatData = result.AssetLinse;
            //this.lstTempAllAssets = result.AssetLinse;
            this.msgBackgrund = 'background-color:green';
            this.showAssets = true;
            this.showSpiner = false;
            var totalAssetsLines = result.AssetLinse;
            this.allAssetCount = totalAssetsLines.length;
            this.TotalAssets  = totalAssetsLines;
            this.tempAssets = totalAssetsLines;
            
            var firstAssets  = this.TotalAssets.slice(0,this.queryLimit);
            console.log('firstAssets>>>>>>>',firstAssets);
            this.assetsData = firstAssets;
           
        }
        })
        .catch(error => { 
            console.log('error>>>>>>>Massupdate>>>>>',error);
            //this.error = error ;
        })
    }
    
    handleUpdateGroupClick(){
        this.errorMessage ='';
        this.showErrorMessage = false;
        if(this.selectedAssestLines != 'undefined' && this.selectedAssestLines != null){
            if(this.selectedAssestLines.length>0){
                this.showPopup = true;
            }else{
                this.showErrorMessage = true;
                this.msgBackgrund = 'background-color:red';
                this.errorMessage = 'Please select Assests to change Group';
            }
            
        }else{
            this.showErrorMessage = true;
            this.msgBackgrund = 'background-color:red';
            this.errorMessage = 'Please select Assests to change Group';
        }
        
    }
    lookupSelected(event){
        //alert('lookup selected..');
        //var selectedgroupId = event.detail.recordId;
        this.updatingGroupId = event.detail.recordId;
        //console.log('selectedgroupId>>>',selectedgroupId);
        //var selectedGroupId = event.detail;
    }
    handleClosePopUp(){
        this.showPopup = false;
        this.errorPopUpMessage = '';
        this.showPopupErrorMsg = false;
        this.loadRecords();
    }
    handleUpdateClick(){
        //alert('updating assest lines to selected Assest Group.');
        var groupId = this.updatingGroupId;
        console.log('groupId>>>>>>>>',groupId);
        console.log('selectedAssestLines>>>>',this.selectedAssestLines);
        this.showPopupSpiner = true;
        updateAssetLines({groupId : groupId,assetLines:this.selectedAssestLines})
        .then(result => {
                if(result.success){

                        this.errorPopUpMessage = 'Succssfully Updated';
                        this.showPopupErrorMsg = true;
                        this.msgBackgrund = 'background-color:green';
                        this.showPopupSpiner = false; 
                        this.loadRecords();
                }else if(result.success == false){
                    this.errorPopUpMessage = result.msg;
                    this.msgBackgrund = 'background-color:red';
                    this.showPopupErrorMsg = true;
                    this.showPopupSpiner = false; 
                }
                
            //this.contacts = result;
            //this.error = undefined;
        }).catch(error => {
            this.errorPopUpMessage = error;
            this.showPopupErrorMsg = true;
            this.showPopupSpiner = false; 
            this.msgBackgrund = 'background-color:red';
            this.error = error;
            //this.showPopup = false;
            //this.contacts = undefined;
        });
    }
    getSelectedAssetLines(event){
        this.errorMessage ='';
        this.showErrorMessage = false;
        var selectedRows = event.detail.selectedRows;
        var selectedIds = [];
        if(selectedRows.length > 0) {
            for(var i =0 ; i< selectedRows.length; i++) {
                selectedIds.push(selectedRows[i].Id);
            }
        }
        console.log('selectedIds>>>>>>',selectedIds);
        this.selectedAssestLines = selectedIds;
    }
    handleCloseError(){
        this.showErrorMessage = false;
    }
    getSeachKey(event){
        this.queryOffset = 0;
        this.queryLimit = 10;
        this.lstTempAllAssets = [];
        //this.seachKey = null;
        //this.seachKey = event.target.value.toUpperCase();
        //this.seachKey = event.target.value;
        var term        = event.target.value;
        console.log('term>>>>>',term);
        if(term == 'undefined' || term == '' || term == 'null'){
            console.log('term is null');
            console.log('this.TotalAssets when term is empty',this.TotalAssets);
            var firstAssets  = this.TotalAssets.slice(0,10);
            console.log('this.firstAssets when term is empty',firstAssets);
            this.queryOffset = 0;
            this.tempAssets = this.TotalAssets;
            console.log('this.tempAssets when term is empty',this.tempAssets );
            this.assetsData = firstAssets;
            this.infininityLoading  = true;
        }else{
            console.log('term>>>>>',term);
            if(term.includes('|')){
                console.log('multiple filters are activated.');
                var searchValues = term.split('|');
                console.log('searchValues>>>>>>',searchValues);
                var finalSearchResults      = [];
                var finalSearchResultsId    = [];
                for(var x of searchValues){
                    console.log('x>>>>>>',x);
                    var results = this.TotalAssets, regex;
                    regex = new RegExp(x, "i");
                    results = this.TotalAssets.filter(
                        row =>regex.test(row.AssestLineGroupName) 
                            ||
                        regex.test(row.AssestName)
                            ||
                        regex.test(row.AccountName)
                            ||
                        regex.test(row.ProductName)
                            ||
                        regex.test(row.TRNUmber)
                            ||
                        regex.test(row.Projectnumber)
                            ||
                        regex.test(row.CarType)
                            || 
                        regex.test(row.Status)
                      );
                      console.log('after search>>>>>>',results);
                      for(var i = 0; i < results.length; i++){
                        if(finalSearchResultsId.includes(results[i].Id) == false){
                            finalSearchResultsId.push(results[i].Id);
                            finalSearchResults.push(results[i]);
                        }
                    }
                    var firstAssets  = finalSearchResults.slice(0,10);
                    this.assetsData = firstAssets;
                    this.tempAssets = finalSearchResults;
                    //this.TotalAssets = finalSearchResults;
                    this.queryOffset = 0;
                }
            }else{
                console.log('no multiple filters are activated.');
                var results = this.TotalAssets, regex;
        		regex = new RegExp(term, "i");
            	// filter checks each row, constructs new array where function returns true
            	results = this.TotalAssets.filter(
                        row =>regex.test(row.AssestLineGroupName) 
                            ||
                        regex.test(row.AssestName)
                            ||
                        regex.test(row.AccountName)
                            ||
                        regex.test(row.ProductName)
                            ||
                        regex.test(row.TRNUmber)
                            ||
                        regex.test(row.Projectnumber)
                            ||
                        regex.test(row.CarType)
                            || 
                        regex.test(row.Status)
                );
                console.log('after search>>>>>>',results);
                var firstAssets  = results.slice(0,10);
                    this.assetsData = firstAssets;
                    this.tempAssets = results;
                    //this.TotalAssets = results;
                    this.queryOffset = 0;
            }
        }
        //console.log('seachKey>>getsearch>>>>',this.seachKey);
        //this.loadRecords();
        /*
        var seachKey = event.target.value.toUpperCase();
        var allRecords = this.lstAllAssets;
        var tempArray = [];
        for(var i=0; i < allRecords.length; i++){
            if((allRecords[i].AssestLineGroupName && allRecords[i].AssestLineGroupName.toUpperCase().indexOf(seachKey) != -1) ||
               (allRecords[i].AccountName && allRecords[i].AccountName.toUpperCase().indexOf(seachKey) != -1 )
                ||
                (allRecords[i].AssestName && allRecords[i].AssestName.toUpperCase().indexOf(seachKey) != -1 )
                ||
                (allRecords[i].ProductName && allRecords[i].ProductName.toUpperCase().indexOf(seachKey) != -1 )
                )
            {
                tempArray.push(allRecords[i]);
            }
            }
            console.log('tempArray>>>>',tempArray);
            this.lstTempAllAssets = tempArray;
        */
    }
    handleClosePopError(){
        this.showPopupErrorMsg = false;
    }
}