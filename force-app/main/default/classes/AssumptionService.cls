/* Class Name : AssumptionService
 * Description : Service  Class for all Assumption object
 * Created By : Vihari Vanga
 * Created On : 11/09/20
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/09/20                    Vihari Vanga                       ALPHA - 22
 */
public class AssumptionService {
    
    public static List<Assumption__c> getAssumptions(Id sourceAccId, Id destAccId){
        return [SELECT Id FROM Assumption__c WHERE 
                Source_Account__c = :sourceAccId AND Destination_Account__c = :destAccId
                AND (Status__c = :RFO_Constant.Assumption_Status_Initiated OR Status__c = :RFO_Constant.Assumption_Status_InProcess)];
        
    }

}