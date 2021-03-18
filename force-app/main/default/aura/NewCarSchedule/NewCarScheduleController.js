({
	doInit : function(component, event, helper) {
		helper.doInit(component, event);
	},
    
    handlePast : function(component, event, helper){
         component.set("v.isModalOpen", true);
        helper.handlePast(component, event);
    },
    
    
   openModel: function(component, event, helper) {
      // Set isModalOpen attribute to true
     
   },
  
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   },
  
   submitDetails: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      component.set("v.isModalOpen", false);
   },

})