/*
Method Name:-RFO_VariationReportScheduleClass
*/
global class RFO_VariationReportScheduleClass implements Schedulable {

    public final static String DATE_TIME_FORMAT= 'yyyy-MM-dd\'T\'HH:mm:ssZ';
    public final static String DATE_FORMAT= 'MM/dd/yyyy';
    public final static String CNT= 'cnt';
  
    global Set<String> objectsSet = new Set<String>();
    Map<String, RFO_ObjectsAPINames__c> objectsApiCustSetgMap = RFO_ObjectsAPINames__c.getAll();
    global List<RFO_Variance__c> countList = new List<RFO_Variance__c>();
    
/*
Method Name:-execute
*/
    global void execute(SchedulableContext ctx) {
        
        for(RFO_ObjectsAPINames__c sobjType : objectsApiCustSetgMap.values()){
            DateTime dt = System.today();
            String dateStr = dt.formatGMT(DATE_FORMAT);
            //System.debug('--dateStr-'+dateStr);
            Date convertedDate = Date.parse(dateStr);
            //System.debug('--convertedDate-'+convertedDate);
            String formatted = dt.formatGMT(DATE_TIME_FORMAT);
            //System.debug('--@@-DATE_TIME_FORMAT--'+formatted);
            
            String lastModifiedDtQry = 'select count(Id)cnt ' + 'from ' + sobjType.name + ' where lastModifiedDate> '+formatted;
            //System.debug('last modified query - '+lastModifiedDtQry);
            Integer lastModifiedCount = (Integer) Database.query(lastModifiedDtQry).get(0).get(CNT);
            //System.debug('last modified - obj api name-'+sobjType.name+'-obj Label Name-'+sobjType.RFO_ObjectLabelName__c+'-count- '+lastModifiedCount);
            
            String createdDtQry = 'select count(Id)cnt ' + 'from ' + sobjType.name + ' where createdDate> '+formatted;
            //System.debug('created dt query - '+createdDtQry);
            Integer createdCount = (Integer) Database.query(createdDtQry).get(0).get(CNT);
            //System.debug('created dt - obj api name-'+sobjType.name+'-obj Label Name-'+sobjType.RFO_ObjectLabelName__c+'-count- '+createdCount);
            
            RFO_Variance__c calc = new RFO_Variance__c();
            calc.name = sobjType.RFO_ObjectLabelName__c;
            calc.RFO_ExecutedLastModifiedDate__c = convertedDate;
            calc.RFO_CountofLastModified__c = lastModifiedCount;
            calc.RFO_ExecutedCreatedDate__c  = convertedDate;
            calc.RFO_CountofCreated__c = createdCount;
            //System.debug('calc obj'+calc);
            countList.add(calc);
        }
        //System.debug('before upsert countList-'+countList);
        if(!countList.isEmpty()){
            Database.upsert(countList);
            //System.debug('after upsert countList-'+countList);
        }
    
    } //end of execute method
    
} //end of class RFO_VariationReportScheduleClass