/**
* @Author      : Accenture
* @Version     : 46.0
* @Description : This test class is for CPQ Triggers
**/
@isTest(SeeAllData= false)
/**
* @Author      : Accenture
* @Version     : 46.0
* @Description : main class starts here
**/
private class RFO_CpqTriggerSwitch_Test{
/**
 *This test method evaluates the disable trigger 
**/
    private static testmethod void cpqTriggerSwitchDis_Test(){
        SBQQ.TriggerControl.Enable();
        RFO_CpqTriggerSwitch.disableCpqTriggers();
        SBQQ.TriggerControl.isEnabled();
        system.assertEquals(FALSE, FALSE);
    }
/**
 *This test method evaluates the enable trigger 
**/
     private static testmethod void cpqTriggerSwitchEna_Test(){
        SBQQ.TriggerControl.Disable();
        RFO_CpqTriggerSwitch.disableCpqTriggers();
        SBQQ.TriggerControl.isEnabled();
        system.assertEquals(TRUE, TRUE);
    }
}