/**
* @Author      : Accenture
* @Version     : 46.0
* @Description : This class is for CPQ Triggers
**/
public class RFO_CpqTriggerSwitch {
    @InvocableMethod(label='CPQ Trigger')
/**
* This method is to enable and disable CPQ triggers 
**/ 
    public static void disableCpqTriggers(){
        IF (SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.Disable();
        }
        ELSE{
            SBQQ.TriggerControl.Enable();
        }
    }
}