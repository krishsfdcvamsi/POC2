public class MassAssetUpdatesController {
	Public String strId{get;set;}
    Public String errorMsg{get;set;}
    Public boolean isError{get;set;}
    public MassAssetUpdatesController(){
        strId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('strId>>>>>>>'+strId);
        if((String.isEmpty(strId) && String.isBlank(strId)) ||strId =='undefined'){
            errorMsg = 'Please click save before attempting to Update the Assets.';
            isError = true;
                }else{
                    isError = false;
                }
    }
}