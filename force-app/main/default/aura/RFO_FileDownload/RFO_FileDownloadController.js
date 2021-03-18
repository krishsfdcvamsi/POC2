({
    doInit : function(component, event, helper) {
        	component.set('v.columns', [
            {
                label: 'Name', 
                fieldName: 'name', 
                type: 'text',
                sortable: true,
                cellAttributes:
                { iconName: {fieldName: 'iconName'}, 
                 iconPosition: 'left' }
            },{
                label: 'Created Date', 
                fieldName: 'fileDate', 
                type: 'date',
                sortable: true,
                cellAttributes: { iconName: 'utility:event' }
            },{
                label: 'Download', 
                fieldName: 'fileurl', 
                type: 'url', 
                typeAttributes: { 
                    label: 'Download'
                },
                cellAttributes:
                { iconName: 'standard:product_consumed', 
                 iconPosition: 'left' }
            }
        	]);       
        helper.fetchData(component, event, helper);
    },
    
    getAllData: function (component, event, helper) {
        helper.fetchAllData(component, event, helper);
    },
    
    updateSelectedText: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        var objfiles = component.get('v.files');
        var strUlrs = objfiles[0].DownloadURL;
        for(var i=0; i<selectedRows.length;  i++){
			  strUlrs = strUlrs + "/" + selectedRows[i].fileId;         
        }
        component.set('v.selectedRowsCount', selectedRows.length);
        component.set('v.strDocIds', strUlrs);
        if(selectedRows.length > 0){
            component.set('v.showDownload', true);
        } else {
            component.set('v.showDownload', false);
        }
    },
    
    filter: function(component, event, helper) {
        var data = component.get("v.allData"),
            term = component.get("v.filter"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = data.filter(row=>regex.test(row.name) || regex.test(row.fileType));
        } catch(e) {
            // invalid regex, use full list
        }
        component.set("v.files", results);
    },
    
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }
})