({
    init: function (cmp, event, helper) {
        
        // Maximum Row Selection
        if(cmp.get('v.singleSelection') == '1') {
            cmp.set('v.maxRowSelection','1')
        }
        
        // Hide Checkbox Column
        if(cmp.get('v.hideShow').toLowerCase() == 'hide') {
            cmp.set('v.hideCheckboxColumn', true)
        }

        // Column Settings
        var cols = new Array();
        for (var i=101; i < 111; i++) {
            var varIcon = ''            
            if(cmp.get('v.column'+i.toString().substring(1)+'_fieldName')) {
                if (i.toString().substring(1) === '01') {
                    varIcon = cmp.get('v.column'+i.toString().substring(1)+'_icon')
                }
				console.log(i);  
				var cellClass =  
					cmp.get('v.column'+i.toString().substring(1)+'_type').toLowerCase() == 'number' ||
					cmp.get('v.column'+i.toString().substring(1)+'_type').toLowerCase() == 'currency'
					? 
                	{
                		fieldName : cmp.get('v.column'+i.toString().substring(1)+'_fieldName') + 'class'
                	}
            		:
            		{};
            	
                if (cmp.get('v.column'+i.toString().substring(1)+'_type').toLowerCase() == 'url') {
                    cols.push({
                        iconName: varIcon,
                        label: cmp.get('v.column'+i.toString().substring(1)+'_label'), 
                        fieldName: cmp.get('v.column'+i.toString().substring(1)+'_fieldName'), 
                        type: cmp.get('v.column'+i.toString().substring(1)+'_type'),
                        typeAttributes: {
                            label: { fieldName: 'Title' }, 
                            target: '_blank'
                        },
                        sortable: true, 
                        initialWidth: cmp.get('v.column'+i.toString().substring(1)+'_width'), 
                        cellAttributes: {
                            alignment: cmp.get('v.column'+i.toString().substring(1)+'_align'),
                            class: cellClass                        	
                        }
                    });
                } else {
                    cols.push({
                        iconName: varIcon,
                        label: cmp.get('v.column'+i.toString().substring(1)+'_label'), 
                        fieldName: cmp.get('v.column'+i.toString().substring(1)+'_fieldName'), 
                        type: cmp.get('v.column'+i.toString().substring(1)+'_type'),
                        sortable: true, 
                        initialWidth: cmp.get('v.column'+i.toString().substring(1)+'_width'), 
                        cellAttributes: {
                            alignment: cmp.get('v.column'+i.toString().substring(1)+'_align'),
                            class: cellClass                        	
                        }
                    });
                }
            }
        }
        
        var rowActions = [{
            'label': 'View File',
            'iconName': 'utility:zoomin',
            'name': 'show_details'
        }];
		cols.push( { type: 'action', typeAttributes: { rowActions: rowActions } })
        cmp.set('v.mycolumns', cols);

        // Object Selection
        if(cmp.get('v.ContentDocument_Input_Variable') && cmp.get('v.ContentDocument_Input_Variable').length > 0){
            cmp.set('v.mydata', cmp.get('v.ContentDocument_Input_Variable'));
            cmp.set('v.obj', 'ContentDocuments');
            cmp.set('v.preSelection', cmp.get('v.ContentDocument_Output_Variable'));
        }
        console.log(cmp.get('v.mydata'));
     	
        // Pre-selected Rows
        var rows = cmp.get('v.preSelection');
        var list = [];
        for (var i=0, len = rows.length; i < len; i++) {
            list.push(rows[i].Id);
        }
        cmp.set('v.preSelectedIds', list);

    },

    // Return Selected Table Rows
    getSelectedName: function (cmp, event) {
        //save the selected rows into a flow-accessible attribute
        var selectedRows = event.getParam('selectedRows');
        var obj = cmp.get('v.obj');
        if(obj == 'ContentDocuments'){
            cmp.set("v.ContentDocument_Output_Variable", selectedRows);    
        }      
    },

    // Client-side controller called by the onsort event handler
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    
    //Row Header Action
    handleRowAction: function (cmp, event, helper) {
        console.log("IN ROW ACTION");
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log("ACTION: "+action.name);
        switch (action.name) {
            case 'show_details':
                console.log("In Case");
                helper.UrlLink(cmp, row);
                break;
        }
    },
})