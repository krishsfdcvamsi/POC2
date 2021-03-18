public class ProductOptionsListViewController {
    @auraEnabled
    public static map<String,Object> saveProductOption(
    		String packageName,
        	String pxPackageId,
        	Decimal quantity,
        	Decimal unitPrice,
        	Decimal labourHours,
        	Decimal markup,
        	String description,
        	//String laborCost,
        	String productId
    	){
        Map<String,Object> result = New Map<String,Object>();
        try{
			system.debug('packageName>>>>'+packageName);
			system.debug('pxPackageId>>>>'+pxPackageId); 
            system.debug('quantity>>>>'+quantity); 
            system.debug('unitPrice>>>>'+unitPrice); 
            system.debug('labourHours>>>>'+labourHours); 
            system.debug('markup>>>>'+markup); 
            system.debug('description>>>>'+description); 
            system.debug('productId>>>>'+productId); 
            List<SBQQ__ProductOption__c> lstOptions = [SELECT SBQQ__Number__c FROM SBQQ__ProductOption__c ORDER BY SBQQ__Number__c DESC LIMIT 1 ];
            decimal intNumber = 0;
            if(!lstOptions.isEmpty()){
                intNumber = lstOptions[0].SBQQ__Number__c;
            }
            //decimal intNumber = [SELECT SBQQ__Number__c FROM SBQQ__ProductOption__c ORDER BY SBQQ__Number__c DESC LIMIT 1 ].SBQQ__Number__c;
            SBQQ__ProductOption__c objProductOption = New SBQQ__ProductOption__c();
            objProductOption.Package_Name__c				=	packageName;
            objProductOption.SBQQ__ConfiguredSKU__c			=	productId;
            objProductOption.SBQQ__OptionalSKU__c			= 	system.label.Optional_SKU;
            objProductOption.Lx_Package_ID__c				=	pxPackageId;
            objProductOption.SBQQ__Quantity__c				=	quantity;
            objProductOption.SBQQ__UnitPrice__c				=	unitPrice;
            objProductOption.Labor_Hours__c					=	labourHours;
            objProductOption.Markup_Rate__c          		= 	markup;
            objProductOption.Description__c					=	description;
            objProductOption.SBQQ__Number__c				=	intNumber+1;
            if(objProductOption !=null){
                Insert objProductOption;
            }
            
            result.put('success',true);
        }catch(exception ex){
            result.put('success',false);
            result.put('msg',ex.getMessage());
        }
            return result;
    }
}