public class CDX_MechanicalDataController {
    @TestVisible private static list<CDX_MechanicalDataExternal__x> mockedMechanicalDatalist = new List<CDX_MechanicalDataExternal__x>();

    @AuraEnabled
    public static List<CDX_MechanicalDataExternal__x> getMechanicalDataExternal(string AID) {
        List<CDX_MechanicalDataExternal__x> MechanicalDataExt = new List<CDX_MechanicalDataExternal__x>();
         Asset AssetRec =new asset();
         AssetRec=[SELECT Id, Name, RFO_TASId__c FROM Asset where id=:AID];
        
        if(!Test.isRunningTest()){       
         MechanicalDataExt=[Select Id, ExternalId, DisplayUrl, CDX_File_Number__c, CDX_Manufacturer__c, CDX_Length_Over_Striker__c, CDX_Extreme_Width__c, CDX_A_End_Coupler__c, CDX_B_End_Coupler__c, CDX_Capacity__c,
                    CDX_Unit_of_Measure__c, CDX_Light_Weight__c, CDX_Gross_Rail_Limit__c, CDX_Load_Limit__c, CDX_Truck_Capacity__c, CDX_DOT_Stencil_Class__c, CDX_DOT_Construction_Class__c, CDX_Number_of_Compartments__c, 
                    CDX_Insulation_Material__c, CDX_Number_of_Coil_Lines__c, CDX_Coil_Type__c, CDX_Coil_Material__c, CDX_Lining_Material__c, CDX_Lining_Type__c, CDX_Lining_Date__c, CDX_Lining_By__c, CDX_Manway_Size__c, 
                    CDX_Eduction_Pipe__c, CDX_Eduction_Valve__c, CDX_Safety_Valve_Composition__c, CDX_Safety_Valve_QTY__c, CDX_Air_Connector_Type__c, CDX_Paint_Material__c, CDX_Paint_Color__c, CDX_Paint_By__c, CDX_Paint_Date__c, 
                    CDX_Manway_Gasket__c, CDX_Bottom_Outlet_Valve_Cap_Gasket__c, CDX_BOV_Handle_Type__c, CDX_Flange_Gasket__c, CDX_O_Ring__c, CDX_Nitrogen_Pad__c, CDX_VRV__c, CDX_Gauging_Device__c, CDX_Sample_Valve__c, 
                    CDX_Thermowell__c, CDX_Safety_Vent__c, CDX_Hatch_Cover_Composition__c, CDX_Hatch_Cover_Manufacturer__c, CDX_Hatch_Cover_Model__c, CDX_Rupture_Disc__c, CDX_Bottom_Gate_Manufacturer__c, CDX_Bottom_Gate_Model__c, 
                    CDX_Number_of_Bottom_Gates__c, CDX_Bottom_Gate_Type__c, CDX_BOV_Current_per_Mechanical_Data__c, CDX_Hatch_Opening_Type__c, CDX_Hatch_Opening_Number_Of_Hatches__c, CDX_Asset__c, CDX_AccountId__c, CDX_Length_Over_Coupler_Pulling__c,
                    CDX_Extreme_Height__c FROM CDX_MechanicalDataExternal__x where CDX_Asset__c=:AssetRec.RFO_TASId__c];
        }
        else{
          MechanicalDataExt.addAll(mockedMechanicalDatalist);  
        }
        return MechanicalDataExt;
    }
    
    
}