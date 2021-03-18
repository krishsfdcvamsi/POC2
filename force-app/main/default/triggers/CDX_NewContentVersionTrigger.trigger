/*  Edited By Aniket Bajaj*/
/**************************************************************************************
* @Author : Aniket Bajaj, Ashish Reddy
* @Modified Date : 9/10/2020
* @Description       
* @User Story : ALPHA-119    
**************************************************************************************/
trigger CDX_NewContentVersionTrigger on ContentVersion (after insert,before insert) {
    
    
    if(Trigger.isBefore)
    {
        CDX_ContentVersionHandler.handleBeforeInsert(trigger.new);
    }
    else
    {
        CDX_ContentVersionHandler.handleAfterInsert(trigger.new);
    }
}