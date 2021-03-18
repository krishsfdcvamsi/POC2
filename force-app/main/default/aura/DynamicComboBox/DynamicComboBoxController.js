({
	getRecords : function(component, event, helper) {
        component.set("v.displayResults", true);
        if(!component.get("v.parentHandlesSearch")){
            helper.getRecords(component, event);
        }
	},
    
    selectItem : function(component, event, helper) {
        let name = event.currentTarget.dataset.name;
        component.set("v.searchText",name);
        component.set("v.displayResults", false);
    },
    
    selectItemWithKey : function(component,event,helper){
        let data = component.get("v.data");
        let key = event.currentTarget.dataset.id;
        let name = event.currentTarget.dataset.name;

        for(let i=0;i<data.length;++i){
            if(data[i][component.get("v.keyField")] == key){
                component.set("v.selectedRecord", data[i]);
                component.set("v.searchText",name);
        		component.set("v.displayResults", false);
                break;
            }
        }

    },
    
    clearData : function(component, event, helper) {
        setTimeout(function(){ 
           helper.clearData(component, event);
        }, 300);
    }
})