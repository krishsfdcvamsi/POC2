trigger RFO_TaskTrigger on Task (after insert) {
    if(Trigger.isAfter){
       if(Trigger.isInsert){
             RFO_CoveragePlanHandlerClass logACallhelper = new RFO_CoveragePlanHandlerClass();
             logACallhelper.logACallToCreateNewCP(Trigger.newMap);
         } // end of after insert 
    }// end of after
} //end of Trigger