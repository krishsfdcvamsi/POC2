({
	getRecords : function(component, event) {
		let action = component.get("c.searchRecords");
        action.setParams({
            			searchText : component.get("v.searchText"),
            			sObjectName : component.get("v.sObjectName"),
            			fieldName : component.get("v.fieldName"),
            			additionalFields : component.get("v.additionalFields"),
            			whereClause : component.get("v.whereClause"),
            			matchAny : component.get("v.matchAnyString")
        				});
        action.setCallback(this, function(response) {
            
            let resp = response.getReturnValue();
            component.set("v.data", resp);
            let names = [];
            let tempIds = [];
            for(let i=0;i<resp.length;i++){
                if(component.get("v.isArrayList")){
                    if(!tempIds.includes(resp[i][component.get("v.keyField")])){
                        names.push({
                            'value' : resp[i][component.get("v.fieldName")],
                            'key' : resp[i][component.get("v.keyField")]
                        });
                        tempIds.push(resp[i][component.get("v.keyField")]);
                    }
                }
                else{
                    if(!names.includes(resp[i][component.get("v.fieldName")])){
                        names.push(resp[i][component.get("v.fieldName")]);
                    }
                }
            }
            
            component.set("v.matchedListDisplay", names);
        });
        $A.enqueueAction(action);
	},
    clearData : function(component, event){
    	component.set("v.displayResults", false);
	}
})