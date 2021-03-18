/**
 * @Author      : Accenture
 * @Version     : 1.0
 * @Created Date: 24th April 2018
 * @Description : Implements the Database.Batchable<sObject> base class to execute batch class.
 *                The class updates OrderID on Asset
 *                if File number is matched
 **/
global class RFO_OrderHandlerBatchJob implements Database.Batchable<sObject>
{
    /**
     *   Start method retrieves all Orders data where RFO_File__c is not null.
     *   It sends retrieved data to execute method to process
     **/
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id, RFO_File__c, RFO_LinktoEngineeringSpec__c, EffectiveDate FROM Order WHERE RFO_File__c!=null ORDER BY EffectiveDate ASC';
        System.debug('-within Start method-');
        return Database.getQueryLocator(query);
    }
    
     /**
     *   Execute method receives the Orders data and process on chunk basis.
     *   And SOQL query gets data of Assets of matched File number from Order object.
     *   If Asset File number match with Order File num then Order Id will update on Asset 'RFO_FileOrder__c'
     **/
    global void execute(Database.BatchableContext BC, List<Order> scope)
    {
        System.debug('-execute method start-');
        List<Asset> astUpdate = new List<Asset>();
        
        Map<String, Order> FileOrderNumberMap = new Map<String, Order>();
        System.debug('-within execute method-');
        for(Order od: scope){
            FileOrderNumberMap.put(od.RFO_File__c, od);
        }
        
        List<Asset> AssetList = [SELECT RFO_File__c, RFO_FileOrder__c FROM Asset 
                                    WHERE RFO_File__c IN: FileOrderNumberMap.keySet() LIMIT 10000];
        System.debug('--within batch: AssetList --'+AssetList );
        
        if(!scope.isEmpty()){                                
            for(Asset ast: AssetList){
                if(FileOrderNumberMap.containsKey(ast.RFO_File__c)){
                    order ord = new order();
                    ord = FileOrderNumberMap.get(ast.RFO_File__c);
                    ast.RFO_FileOrder__c = ord.Id;
                    //ast.RFO_LinktoEngineeringSpec__c = '<a href="http://'+ord.RFO_LinktoEngineeringSpec__c+'" target="_blank">'+ord.RFO_LinktoEngineeringSpec__c+'</a>';
                    System.debug('++ ast.RFO_FileOrder__c ++'+ast.RFO_FileOrder__c);
                    astUpdate.add(ast);
                }
            }
        }
        Database.update(astUpdate);
        System.debug('--within batch: after update astUpdate.size()--'+astUpdate.size()+'--asset details--'+astUpdate);
        
        System.debug('-execute method end-');
    }
    
    /**
     *   Executes finish method of batch
     **/
    global void finish(Database.BatchableContext BC) {
        System.debug('-within finish method-');
    }
}