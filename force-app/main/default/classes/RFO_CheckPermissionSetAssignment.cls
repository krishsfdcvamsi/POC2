/*
Author Name   : I. Martinez
Created Date  : August 15, 2019 
Description   : Class w/ Invocable method used by flows: ChangeOrder and CreatePlainFile
                without sharing to be able to query the PermissionSetAssignment object by any user

History
*
* 15JAUG2019 | I Martinez |  | Initial version 
*/
global without sharing class RFO_CheckPermissionSetAssignment {
   
/* Method Name: checkPermissionSetAssignment - Invocable method called by the flow*/
   @InvocableMethod(label='Check PermissionSetAssignment' description='Checks if the permission set is asssigned to the user')
   public static List<CheckPermissionSetResult> checkPermissionSetAssignment(List<CheckPermissionSetRequest> requests) {

      List<CheckPermissionSetResult> results = new List<CheckPermissionSetResult>();
      for (CheckPermissionSetRequest request : requests) {
         results.add(chkPermissionSetAssignment(request.userId, request.permissionSetName));
      }
      return results;
   }

/* Method Name: chkPermissionSetAssignment - searches the PSA object to see if the user is assigned to such PS */
   public static CheckPermissionSetResult chkPermissionSetAssignment(String userId, String permissionSetName) {
      Integer assignmentCount = [SELECT count() FROM PermissionSetAssignment 
                                  where AssigneeId = :userId
                                    and PermissionSet.Name = :permissionSetName Limit 50];
      CheckPermissionSetResult result = new CheckPermissionSetResult();
      result.permissionSetAssigned = assignmentCount == 0 ? false : true;
      return result;
   }

/* Subclass that defines the input parameters */
   global class CheckPermissionSetRequest {
      @InvocableVariable(label='User Id' description='Current User Id' required=true)
      global String userId;

      @InvocableVariable(label='Permission Set Name' description='(API) name of the permission set)' required=true)
      global String permissionSetName;

   }

/* Subclass that defines the outpu parameters */
   global class CheckPermissionSetResult {
      @InvocableVariable(label='Permission Set Assigned' description='Indicates if the Permission Set is assiged to the user')
      global Boolean permissionSetAssigned;
   }

/* Subclass to capture exceptions */
   class RFO_CheckPermissionSetAssignmentException extends Exception {}

}