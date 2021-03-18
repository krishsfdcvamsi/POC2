public without sharing  class LxPackageController {
	Public String strId{get;set;}
    Public String errorMsg{get;set;}
    Public boolean isError{get;set;}
    public LxPackageController(){
        strId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('strId>>>>>>>'+strId);
        if((String.isEmpty(strId) && String.isBlank(strId)) || strId =='undefined'){
            errorMsg = 'Please click save before attempting to configure Lx Package.';
            isError = true;
                }else{
                    isError = false;
                }
    }
}