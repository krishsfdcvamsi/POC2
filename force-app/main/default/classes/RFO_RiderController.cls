public class RFO_RiderController {
    public class RiderWrapperClass {
        @AuraEnabled Public  RFO_Rider__c  RiderRecord {get;set;}
        @AuraEnabled Public string RenewalOpptyRecType {get;set;}
        @AuraEnabled Public string StandardPriceBookId {get;set;}
        @AuraEnabled Public string OriginalMaturityDate{get;set;}
    }
    @AuraEnabled 
    public static RiderWrapperClass getRiderDetails(String riderId){
        system.debug('riderId>>'+riderId);
        RiderWrapperClass rWC=new RiderWrapperClass();
        rWC.RiderRecord = [SELECT Id, Name, RFO_Account__c  ,Account_Name__c, RFO_ProductType__c,RFO_MileageLimit__c,
                           RFO_ExcessMileagePremium__c,RFO_Commodity__c,RFO_OriginalMaturityDate__c,RFO_RiderNumber__c,RFO_RiderNumberSuffix__c,
                           RFO_TotalActiveCars__c,RFO_Product__c FROM RFO_Rider__c where Id = :riderId Limit 1];
        List<RecordType> opptyRecType = [SELECT Id,Name 
                                         FROM RecordType 
                                         where SobjectType='Opportunity' and IsActive=true and Name='Renewals' Limit 1];
        List<Pricebook2 > priceBookLst = [SELECT Id FROM Pricebook2 where IsActive=true and IsStandard =true Limit 1];
        if(!opptyRecType.isEmpty()){
            rWC.RenewalOpptyRecType=opptyRecType[0].Id;
            System.debug('renewal RecType :'+opptyRecType[0].Id);
            
        }
        if(!priceBookLst.isEmpty()){
            rWC.StandardPriceBookId=priceBookLst[0].Id;
            System.debug('Standard pricebookId :'+priceBookLst[0].Id);
        }
        /* if(!priceBookLst.isEmpty()){
            rWC.OriginalMaturityDate=RFO_OriginalMaturityDate__c
            System.debug('Standard pricebookId :'+priceBookLst[0].Id);
        }*/
        
        System.debug('rider Rec :'+rWC.RiderRecord);
        
        return rWC;
    }
}