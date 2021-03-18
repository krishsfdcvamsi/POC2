/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 10th Sep 2018
* @Description : Implements the Database.Batchable<sObject> base class to execute batch class.
*                The class updates Quantity field on Product with associated Assets count.  
**/

global class RFO_ProductQuantityCalcBatchJob implements Database.Batchable<sObject>
{
    /**
*   Start method retrieves all Assets count for a Product.
*   It sends retrieved data to execute method to process
**/
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('Start method');
        return Database.getQueryLocator('select id, RFO_Qty__c from Product2');
    }
    
    /**
*   Execute method receives the Orders data and process on chunk basis.
*   And SOQL query gets data of Assets from Order object.
*   If Asset File number match with Order File num then Order Id will update on Asset 'RFO_FileOrder__c'
**/
    global void execute(Database.BatchableContext BC, List<Product2> scope)
    {  
        System.debug('-execute method start-');
        List<Product2> prdListToUpdate = new List<Product2>();
        
        AggregateResult[] groupedResults = [SELECT COUNT(Id), Product2ID FROM Asset where Product2Id IN :scope GROUP BY Product2Id ];
        if(groupedResults != null){
            for(AggregateResult ar:groupedResults) {
                //Id prdId = (ID)ar.get('Product2ID');
                Integer count = (INTEGER)ar.get('expr0');
                Product2 prdRec = new Product2(Id= (ID)ar.get('Product2ID'));
                prdRec.RFO_Qty__c = count;
                system.debug('%%%%%%prdRec.RFO_Qty__c'+prdRec.RFO_Qty__c);
                prdListToUpdate.add(prdRec);
            }
        }
        if(!prdListToUpdate.isEmpty()){
            Database.update(prdListToUpdate);
            system.debug('%%%%%%prdListToUpdate'+prdListToUpdate);
        }
    }
    /**
*   Executes finish method of batch
**/
    global void finish(Database.BatchableContext BC) {
        System.debug('Within finish method');
    }
}