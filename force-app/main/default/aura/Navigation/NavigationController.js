({
    navigate : function(component,event,helper){
        
        try{
        var actionClicked = event.getSource().getLocalId();
        // Fire that action
        var navigate = component.get('v.navigateFlow');
        navigate(actionClicked);
        }
        catch(e){
            console.log(e);
        }
    },
    finish : function(component,event,helper){
        window.location.reload();
    }
})