/* Class Name : CreateAssumptionController
 * Description : Controller Class for all createAssumption component
 * Created By : Vihari Vanga
 * Created On : 11/09/20
 * Test Class - CreateAssumptionControllerTest
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 11/09/20                    Vihari Vanga                       ALPHA - 22
 */
public class CreateAssumptionController {

    /************************************************************************************************************************************************
       Description: Get Account Rider Records to Display in Create Assumption Component
       Parameters:  strAccountId - Account Id
       Returns: List of Rider Records
    *************************************************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static List<RFO_Rider__c> getAccountRiders(String strAccountId){
        List<RFO_Rider__c> listRider = new List<RFO_Rider__c>();
        List<RFO_Rider__c> queriedRiders = RiderService.getAllRidersByAccountIds(new Set<Id>{strAccountId})?.get(strAccountId);
        
        if(queriedRiders != null){
            for(RFO_Rider__c objRider:queriedRiders){
                if (String.isBlank(objRider.Assumption__c)) {
                    listRider.add(objRider);
                }
            }
        }
        return listRider;
    }

    /************************************************************************************************************************************************
       Description: Create Assumption Record and Update all rider records with Assumption Record Reference
       Parameters:  objAssumption - Assumption Object, listSelectedRider - List of Selected Rider, listEditedRider - List of Edited Rider
       Returns: Instance of AssumptionResult wrapper
    *************************************************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static AssumptionResult createAssumption(Assumption__c objAssumption, List<RFO_Rider__c> listSelectedRider, List<RFO_Rider__c> listEditedRider){
        Savepoint objSavePoint = Database.setSavepoint();
        AssumptionResult objAssumptionResult = new AssumptionResult();
        try {
            List<Assumption__c> listExistingAssumption = AssumptionService.getAssumptions(objAssumption.Source_Account__c, objAssumption.Destination_Account__c);
            if (listExistingAssumption?.size() > 0) objAssumption.Id = listExistingAssumption[0].Id;
            
            upsert objAssumption;
            
            Set<Id> setSelectedRiderId = new Set<Id>();
            Map<Id, RFO_Rider__c> mapEditedRider = new Map<Id, RFO_Rider__c>();
            for (RFO_Rider__c objRider:listEditedRider) {
                mapEditedRider.put(objRider.Id, objRider);
            }
            for (RFO_Rider__c objRider:listSelectedRider) {
                objRider.Assumption__c = objAssumption.Id;
                objRider.Assumption_Account_Number__c = objAssumption.Destination_Account__c;
                objRider.Assumed_of_Cars__c = Integer.valueOf(mapEditedRider?.get(objRider.Id)?.Assumed_of_Cars__c);
            }
            update listSelectedRider;
            
            objAssumptionResult.strAssumptionId = objAssumption.Id;
            return objAssumptionResult;
        } catch (Exception objEx) {
            Database.rollback(objSavePoint);
            objAssumptionResult.strErrorMessage = objEx.getMessage();
            return objAssumptionResult;
        }
    }

    public class AssumptionResult{
        @AuraEnabled public String strAssumptionId;
        @AuraEnabled public String strErrorMessage;
    }
}