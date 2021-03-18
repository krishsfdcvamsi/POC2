/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 27 Sep 2019
* @Description : This class is to add new products to the PriceBookEntry records with Standard PriceBook.
*                
**/
public class RFO_Product2TriggerHandler implements ITriggerHandler{
    public static Boolean triggerDisabled = false;
    public String prdTrigName = 'Product2TriggerHandler';
    RFO_TriggerSetting__mdt pbeTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt 
                                          where MasterLabel =:prdTrigName Limit 1];
    
    /**
* Checks to see if the trigger has been disabled either by custom setting or by running code
**/
    public Boolean isDisabled()
    {
        if (pbeTrigger.RFO_Active__c){
            return triggerDisabled;
           }
        else{
            return true;
        }
    }
    /**
* This Method is called for before products are inserted.
**/      
    public void beforeInsert(List<SObject> newItems){
        
    }
    /**
* This Method is called for before products are updated.
**/ 
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        
    }
    /**
* This Method is called for before products are deleted.
**/  
    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    
    /**
* After products are created corresponding records along with standard price book is created in PriceBookEntry object.
**/    
    public void afterInsert(Map<Id, SObject> newPRDs) {
        try{
            List<PricebookEntry> pbRecList = new List<PriceBookEntry>();
            List<Pricebook2> pbook = [SELECT ID FROM Pricebook2
                                      WHERE IsStandard  = TRUE LIMIT 1];
            Set<Id> productsIDs = new Set<Id>();
            if (!newPRDs.KeySet().isEmpty()){
                productsIDs.addall(newPRDs.KeySet());
            }
            if (!productsIDs.isEmpty()){   
                for (Product2 pbList : [SELECT ID,NAME FROM PRODUCT2 WHERE ID IN: productsIDs Limit 49999]){
                    PricebookEntry pbRec= new PricebookEntry();
                    pbRec.Product2Id	= pbList.Id;
                    pbRec.Pricebook2Id	= pbook[0].Id;
                    pbRec.unitprice		= 8000;
                    pbRec.UseStandardPrice = False;
                    pbRec.IsActive 		= TRUE;
                    pbRecList.add(pbRec);
                }
            }
            if (!pbRecList.isEmpty()){
                Database.insert(pbRecList);    
            }
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }  
    }
    /**
* This Method is called for after products are updated.
**/
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        
    }
    /**
* This Method is called for after products are deleted.
**/
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
    /**
* This Method is called for after products are undeleted.
**/    
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
}