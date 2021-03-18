/******************************************************************************************************************* 
 * Class Name : CaseService
 * Description : Service Class for Case Object
 * Created By : Haseeb Ahmed
 * Created On : 9/24/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 9/24/20                    Haseeb                       		ALPHA - 521 - Query case records based on Order Id
 * 
 *******************************************************************************************************************/

public class CaseService {

    //Haseeb - Return list of Cases based on the Order Id passed
    public static list<case> getCasesByOrderId(list<String> OrderIdList, string existingRTId, string newRTId){
        return new list<case>([select id,status,RFO_OrderID__c,RFO_OrderID__r.RecordTypeID from case where RFO_OrderID__c in: OrderIdList and (RFO_OrderID__r.RecordTypeID =:existingRTId or RFO_OrderID__r.RecordTypeID =:newRTId)]);
    }
}