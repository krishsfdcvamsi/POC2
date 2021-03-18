/***
* Class Name: RFO_ChangeOrderEmailController  
***/
public  class RFO_ChangeOrderEmailController
{
    public Id orderId {get;set;}
/***
* Method Name: getchangeorderlineitems
***/
    public List <WrapperClass> getchangeorderlineitems(){
            List<WrapperClass> resultList = new List<WrapperClass>();
        Integer index=1;
        WrapperClass wrapper = new WrapperClass();
        try{
        for (RFO_ChangeOrderLineItem__c  temp :[SELECT Name, RFO_ChangeOrderLineItemComments__c 
                                                FROM RFO_ChangeOrderLineItem__c 
                                                WHERE RFO_ChangeOrderID__c=:orderId Limit 49999]) {
            wrapper = new WrapperClass();
            wrapper.index = index;
            wrapper.changeOrder = temp;
            index++;
            resultList.add(wrapper);
        }
        }catch(Exception e){     
        }
        return resultList;
    }
/***
* Class Name: WrapperClass 
***/    
    public class WrapperClass {
        public Integer index {get;set;}
        public RFO_ChangeOrderLineItem__c changeOrder{get;set;}
    }
}