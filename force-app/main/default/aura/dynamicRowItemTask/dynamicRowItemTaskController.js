({
    AddNewRow : function(component, event, helper){
        component.getEvent("AddRowEvtTask").fire();     
    },
    
    removeRow : function(component, event, helper){
       component.getEvent("DeleteRowEvtTask").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }, 
  
})