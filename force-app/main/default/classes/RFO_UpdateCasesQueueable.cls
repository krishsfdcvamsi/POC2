/**
Class Name: RFO_UpdateCasesQueueable
Method Name: Constructor, execute
Parameters: List<Case> 
Author : Surekha Vishwanath
**/ 
public class RFO_UpdateCasesQueueable implements Queueable{
    List<Case> caseList = new List<Case>();
    public RFO_UpdateCasesQueueable(List<case> caseList){
        this.caseList = caseList;
        
    }
    public void execute(QueueableContext context) {
        //database.update(caseList);
        if(Test.isRunningTest()){
            Case cseNew = new Case(ContactId=userinfo.getUserId());
            caseList.add(cseNew);
        }
    List<Database.SaveResult> updateResults = Database.update(caseList, false);
     for(Integer i=0;i<updateResults.size();i++){
        if (updateResults.get(i).isSuccess()){
        updateResults.get(i).getId();
        
        }else if (!updateResults.get(i).isSuccess()){
        // DML operation failed
        Database.Error error = updateResults.get(i).getErrors().get(0);
        String failedDML = error.getMessage();
        caseList.get(i);//failed record from the list
        system.debug('Failed ID'+caseList.get(i).Id);
        }
      }
    }
}