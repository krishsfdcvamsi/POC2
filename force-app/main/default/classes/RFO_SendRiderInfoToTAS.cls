/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 12 June 2019
* @Description :This Controller class is to send the Rider info to TAS.
**/
public class RFO_SendRiderInfoToTAS {
    public String currentRecordId {get;set;}
    public String responseStatusCode {get;set;}
    public RFO_Rider__c riderRec {get;set;}
    public Id userId;
    public String Message{get;set;}
    public Boolean userAccessFlag{get;set;}
    String fieldLabel='';
/**
 * Constructor
 **/
    public RFO_SendRiderInfoToTAS(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        userId = Userinfo.getUserId();
    }
/**
 *     method to send rider info to TAS 
 * */
    public void callouttoTAS(){
        try{
            riderRec = [select RFO_IntegrationStatus__c, id ,Name, RFO_Contract__c,RFO_Contract__r.RFO_ExecuteDate__c, RFO_Contract__r.RFO_ContractType__c,
                        RFO_Contract__r.RFO_ContractDate__c, RFO_Contract__r.StartDate, 
                        RFO_RiderNumber__c, RFO_RiderNumberSuffix__c, RFO_TotalOfCars__c,RFO_MileageLimit__c,
                        RFO_Term__c, RFO_RiderDate__c, RFO_ExecutedDate__c, RFO_StartMethod__c,
                        RFO_RiderRateType__c, RFO_RiderType__c, RFO_ExcessMileageMethod__c, RFO_UnitofMeasure__c,
                        RFO_ExcessMileagePremium__c, RFO_PurchaseOptionMonths__c, RFO_PurchaseOptionNoticeDays__c,
                        RFO_PurchaseOptionValue__c, RFO_EarlyTerminationCost__c, RFO_EarlyTerminationMonth__c, 
                        RFO_EarlyTerminationNoticeRequired__c, RFO_EarlyTerminationQuantity__c, 
                        RFO_RiderRate__c, RFO_TASRiderId__c, RFO_EndDate__c, RFO_AdditionalLeaseRateFactor__c, 
                        RFO_StartDate__c, RFO_RiderFixedRate__c, RFO_RiderId__c, 
                        RFO_IncreaseEffectiveUpon__c, RFO_NotesComments__c, RFO_LesseeRightofTermination__c,
                        RFO_EstimatedMiles__c,  RFO_PerModCostPerCar__c,
                        RFO_AutoRenewalTermTermMonths__c, RFO_RenewalDaysNotice__c, RFO_RenewalRateChange__c, 
                        RFO_Contract__r.RFO_ContractId__c, RFO_Contract__r.Account.RFO_OracleId__c 
                        from RFO_Rider__c where id =: currentRecordId ];
            List<PermissionSetAssignment> lstcurrentUserPerSet =    [   SELECT Id, PermissionSet.Name,AssigneeId
                                                                     FROM PermissionSetAssignment
                                                                     WHERE AssigneeId = :userId];
            for (PermissionSetAssignment psa: lstcurrentUserPerSet)
            {
                if(psa.PermissionSet.Name.equals(RFO_Constant.RFO_OM_CONTRACT_PS)){
                    userAccessFlag = true;
                    if(riderRec.RFO_IntegrationStatus__c=='Success'&& riderRec.RFO_TASRiderId__c==null){
                        Message = 'Rider info already sent to TAS.';
                        createChatterPost(riderRec.Id,Message);
                    }
                    else{
                    	generateRequestBody(riderRec);
                    }
                }
            }
        }
        catch(Exception e) { 
            Message = 'Invalid Data for the Field: '+fieldLabel;
            createChatterPost(riderRec.Id,Message);
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
/**
 * to generate JSON Payload of Rider record
 **/
    public void generateRequestBody(RFO_Rider__c riderRec){
        Map<Id, Integer> requestsLogDetails;
        Map<String, Integer> contractTypeMap = createContractTypeMap();
        Map<String, Integer> earlyTermMonthMap = createEarlyTermMonthMap();
        Map<String, Integer> startMethodsMap = createstartMethodsMap();
        Map<String, Integer> riderTypeMap = createRiderTypeMap();
        Map<String, Integer> uomMap = createUOMMap();
        Map<String, Integer> increaseEffecMap = createIncreaseEffecMap();
        Map<String, Integer> excessMileageMethodMap = createExcessMileageMethodMap();
        
        ContractClass contractReqBody = new ContractClass();
        if(riderRec.RFO_Contract__r.Account.RFO_OracleId__c!=null){
            fieldLabel = 'Oracle Id on Account';
            contractReqBody.customerId = Integer.valueOf(riderRec.RFO_Contract__r.Account.RFO_OracleId__c);
        }
        if(riderRec.RFO_Contract__r.RFO_ContractId__c!=null){
            fieldLabel = 'TAS Contract Id on related Contract';
            contractReqBody.contractId = Integer.valueOf(riderRec.RFO_Contract__r.RFO_ContractId__c);
        }
        if(contractTypeMap.get(riderRec.RFO_Contract__r.RFO_ContractType__c)!=null){
            contractReqBody.contractType = contractTypeMap.get(riderRec.RFO_Contract__r.RFO_ContractType__c);
        }
        if(riderRec.RFO_Contract__r.RFO_ContractDate__c!=null){
            contractReqBody.contractDate = datetime.newInstance((riderRec.RFO_Contract__r.RFO_ContractDate__c).year(), (riderRec.RFO_Contract__r.RFO_ContractDate__c).month(),(riderRec.RFO_Contract__r.RFO_ContractDate__c).day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
        }
        if(riderRec.RFO_Contract__r.RFO_ExecuteDate__c!=null){
            contractReqBody.executeDate = datetime.newInstance((riderRec.RFO_Contract__r.RFO_ExecuteDate__c).year(), (riderRec.RFO_Contract__r.RFO_ExecuteDate__c).month(),(riderRec.RFO_Contract__r.RFO_ExecuteDate__c).day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
        }

        List<DocumentClass> documentsList = new List<DocumentClass>();
        
        DocumentClass documents = new DocumentClass();
        documentsList.add(documents);
        
        RiderRate riderRateObj = new RiderRate();
        if(riderRec.RFO_RiderRateType__c!=null){
            riderRateObj.noOfPayments = riderRec.RFO_RiderRateType__c=='Term'?Integer.valueOf(riderRec.RFO_Term__c):0;
        }
        riderRateObj.paymentAmount = 0;
        RiderClass riderObj = new RiderClass();
        if(riderRec.RFO_RiderId__c!=null){
            fieldLabel = 'Rider TransactionID';
            riderObj.rfTransactionId = Integer.valueOf(riderRec.RFO_RiderId__c);
        }
        riderObj.tasRiderId = riderRec.RFO_TASRiderId__c!=null?Integer.valueOf(riderRec.RFO_TASRiderId__c):0; //y zero value
        
        riderObj.tasRiderNumber = riderRec.RFO_RiderNumber__c;
        if(riderRec.RFO_RiderNumberSuffix__c!=null){
            riderObj.tasRiderNumberSuffix = Integer.valueOf(riderRec.RFO_RiderNumberSuffix__c);
        }
        if(riderRec.RFO_TotalOfCars__c!=null){
            riderObj.quantity = Integer.valueOf(riderRec.RFO_TotalOfCars__c);
        }
        if(riderRec.RFO_Term__c!=null){
            riderObj.term = Integer.valueOf(riderRec.RFO_Term__c);
        }
        if(riderRec.RFO_RiderDate__c!=null){
            riderObj.riderDate = datetime.newInstance((riderRec.RFO_RiderDate__c).year(), (riderRec.RFO_RiderDate__c).month(),(riderRec.RFO_RiderDate__c).day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
        }
        //riderObj.riderDate
        if(startMethodsMap.get(riderRec.RFO_StartMethod__c)!=null){
            riderObj.startMethods = startMethodsMap.get(riderRec.RFO_StartMethod__c);
        }
        if(riderTypeMap.get(riderRec.RFO_RiderType__c)!=null){
            riderObj.riderType = riderTypeMap.get(riderRec.RFO_RiderType__c); 
        }
        if(riderRec.RFO_RiderRateType__c!=null){
            riderObj.riderRateType = riderRec.RFO_RiderRateType__c.toLowercase();
        }
        /*if(riderRec.RFO_StartDate__c!=null){
            riderObj.riderFixedStartDate =  datetime.newInstance((riderRec.RFO_StartDate__c).year(), (riderRec.RFO_StartDate__c).month(),(riderRec.RFO_StartDate__c).day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');//(riderRec.RFO_StartDate__c).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
        }
        if(riderRec.RFO_EndDate__c!=null){
            riderObj.riderFixedEndDate = datetime.newInstance((riderRec.RFO_EndDate__c).year(), (riderRec.RFO_EndDate__c).month(),(riderRec.RFO_EndDate__c).day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');//(riderRec.RFO_EndDate__c).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
        }*/
        /*if(riderRec.RFO_RiderRate__c!=null){
            riderObj.riderFixedRate = Integer.valueOf(riderRec.RFO_RiderRate__c);
        }*/
        if(uomMap.get(riderRec.RFO_UnitofMeasure__c)!=null){
            riderObj.unitOfMeasure = uomMap.get(riderRec.RFO_UnitofMeasure__c);
        }
        riderObj.riderRate = riderRateObj;
        
        if(excessMileageMethodMap.get(riderRec.RFO_ExcessMileageMethod__c)!=null){
            riderObj.excessMileageMethod = excessMileageMethodMap.get(riderRec.RFO_ExcessMileageMethod__c);
        }
        if(riderRec.RFO_ExcessMileagePremium__c!=null){
            riderObj.excessMileagePremium = riderRec.RFO_ExcessMileagePremium__c;
        }
        if(riderRec.RFO_MileageLimit__c!=null){
            riderObj.mileageLimit = Integer.valueOf(riderRec.RFO_MileageLimit__c);
        }
        if(riderRec.RFO_PurchaseOptionMonths__c!=null){
            riderObj.purchaseOptionMonths = Integer.valueOf(riderRec.RFO_PurchaseOptionMonths__c);
        }
        if(riderRec.RFO_PurchaseOptionNoticeDays__c!=null){
            riderObj.purchaseOptionNoticeDays = Integer.valueOf(riderRec.RFO_PurchaseOptionNoticeDays__c);
        }
        if(riderRec.RFO_PurchaseOptionValue__c!=null){
            riderObj.purchaseOptionValue = Integer.valueOf(riderRec.RFO_PurchaseOptionValue__c);
        }
        if(riderRec.RFO_EarlyTerminationNoticeRequired__c!=null){
            riderObj.earlyTerminationNoticeRequired = riderRec.RFO_EarlyTerminationNoticeRequired__c;
        }
        if(riderRec.RFO_EarlyTerminationMonth__c!=null){
            riderObj.earlyTerminationMonth = Integer.valueOf(riderRec.RFO_EarlyTerminationMonth__c);
        }
        if(riderRec.RFO_EarlyTerminationCost__c!=null){
            riderObj.earlyTerminationCost = Integer.valueOf(riderRec.RFO_EarlyTerminationCost__c);
        }
        if(riderRec.RFO_EarlyTerminationQuantity__c!=null){
            riderObj.earlyTerminationQuantity = Integer.valueOf(riderRec.RFO_EarlyTerminationQuantity__c);
        }
        if(riderRec.RFO_EstimatedMiles__c!=null){
            riderObj.estimatedMiles = Integer.valueOf(riderRec.RFO_EstimatedMiles__c);
        }
        if(riderRec.RFO_ExecutedDate__c!=null){
            riderObj.executedDate = datetime.newInstance((riderRec.RFO_ExecutedDate__c).year(), (riderRec.RFO_ExecutedDate__c).month(),(riderRec.RFO_ExecutedDate__c).day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
        }
        
        AARClass aarObj = new AARClass();
		if(riderRec.RFO_AdditionalLeaseRateFactor__c!=null){
            aarObj.additionalLeaseRate = (riderRec.RFO_AdditionalLeaseRateFactor__c);
        }
        If(riderRec.RFO_PerModCostPerCar__c!=null){
            aarObj.dollarAmountPerCar = Integer.valueOf(riderRec.RFO_PerModCostPerCar__c);
        }
        aarObj.termRights = 
            (riderRec.RFO_LesseeRightofTermination__c=='No' || riderRec.RFO_LesseeRightofTermination__c==null)?false:true;
        if(riderRec.RFO_IncreaseEffectiveUpon__c!=null){
            aarObj.increaseEffective = increaseEffecMap.get(riderRec.RFO_IncreaseEffectiveUpon__c);
        }
        aarObj.modNotes = riderRec.RFO_NotesComments__c!=null?riderRec.RFO_NotesComments__c:'';
        
        RenewalTerms renewalObj = new RenewalTerms();
        if(riderRec.RFO_AutoRenewalTermTermMonths__c!=null){
            renewalObj.term = Integer.valueOf(riderRec.RFO_AutoRenewalTermTermMonths__c);
        }
        if(riderRec.RFO_RenewalDaysNotice__c!=null){
            renewalObj.daysNotice = Integer.valueOf(riderRec.RFO_RenewalDaysNotice__c);
        }
        renewalObj.rateChange = riderRec.RFO_RenewalRateChange__c!=null?Integer.valueOf(riderRec.RFO_RenewalRateChange__c):0;
        
        riderObj.aar = aarObj;
        riderObj.renewalTerms = renewalObj;
        
        RequestBody reqbody = new RequestBody();
        
        reqbody.contract = contractReqBody;
        reqbody.documents = documentsList;
        reqbody.rider = riderObj;
        
        String jsonReqBody = json.serialize(reqbody, false);
        
        Map<Id, Object> messageIdRequest = new Map<Id, Object>();
        messageIdRequest.put(riderRec.Id, reqbody);
        requestsLogDetails = RFO_IntegrationUtility.createLogDetail(  messageIdRequest
                                                                    , RFO_Constant.RIDER
                                                                    , RFO_Constant.R_CREATE
                                                                    , '.'
                                                                    , RFO_Constant.POST_METHOD
                                                                    , 'RFO_SendRiderInfoToTAS');
        reqbody.messageId = requestsLogDetails.get(riderRec.Id);
        String jsonBody = json.serialize(reqbody, true);
        if(riderRec.RFO_Contract__r.Account.RFO_OracleId__c!=null && 
           (riderRec.RFO_Contract__r.RFO_ContractType__c!=null||contractTypeMap.get(riderRec.RFO_Contract__r.RFO_ContractType__c)!=null)
           && riderRec.RFO_RenewalDaysNotice__c!=null && riderRec.RFO_RiderRateType__c!=null 
           && riderRec.RFO_Contract__r.RFO_ContractId__c!=null
           && riderRec.RFO_StartMethod__c != null 
           && riderRec.RFO_RiderType__c != null)
        {
            System.debug('Payload: '+jsonBody);
            RFO_SendToTASFutureClass.getRider(riderRec.Id, JsonBody, String.valueOf(requestsLogDetails.get(riderRec.Id)), String.valueOf(riderObj.tasRiderId));
            Message = 'Rider Info has been sent to TAS.';
        }
        else{
            Message = 'Renewal Days Notice, Rider Rate Type, Related Account OracleId, TAS Contract Id,Start Method,RiderType and Contract Type(or the value you have selected for Contract Type id not acceptable) field values are Required , it cannot be sent to TAS.';
            createChatterPost(riderRec.Id,Message);
        }
        
    }
/**
 * page reference to redirect to vf page
 **/
    public PageReference reset() { 
        PageReference pageRef = new PageReference('/' + riderRec.Id);
        pageRef.setRedirect(true);
        return pageRef;
    } 
/**
 *     Wrapper Class
 **/
    public class RequestBody{
        public Integer messageId;
        public RFO_SendRiderInfoToTAS.ContractClass contract;
        public List<RFO_SendRiderInfoToTAS.DocumentClass> documents;
        public RFO_SendRiderInfoToTAS.RiderClass rider;
    }
/**
 *     Wrapper Class
 **/
    public class ContractClass{
        public Integer customerId;
        public Integer contractId;
        public Integer contractType;
        public String salesRep;
        public DateTime startDate;
        public String contractDate;
        public String executeDate;
        public Boolean mlanda;
    }
/**
 *     Wrapper Class
 **/
    public class DocumentClass{
        //public String stream;
        //public Integer type;
        //public String extension;
    }
/**
 *     Wrapper Class
 **/
    public class RiderClass{
        public Integer rfTransactionId;
        public Integer tasRiderId;
        public String tasRiderNumber;
        public Integer tasRiderNumberSuffix;
        public Integer quantity;
        public Integer term;
        public String riderDate;
        public String executedDate;
        public Integer startMethods;
        public Integer riderType;
        public String riderRateType;
        public String riderFixedStartDate;
        public String riderFixedEndDate;
        public Integer riderFixedRate;
        public Integer unitOfMeasure;
        public Boolean riderNDA;
        public RFO_SendRiderInfoToTAS.RiderRate riderRate;
        public Integer excessMileageMethod;
        public Decimal excessMileagePremium;
        public Integer mileageLimit;
        public String returnProvision;
        public Integer purchaseOptionMonths;
        public Integer purchaseOptionNoticeDays;
        public Integer purchaseOptionValue;
        public Decimal earlyTerminationNoticeRequired;
        public Integer earlyTerminationMonth;
        public Integer earlyTerminationCost;
        public Integer earlyTerminationQuantity;
        public Integer abatementDelayDays;
        public Integer estimatedMiles;
        public RFO_SendRiderInfoToTAS.AARClass aar;
        public RFO_SendRiderInfoToTAS.RenewalTerms renewalTerms;
    }
/**
 *     Wrapper Class
 **/
    public class RiderRate{
        public Integer noOfPayments;
        public Integer paymentAmount;
    }
/**
 *     Wrapper Class
 **/
    public class AARClass{
        public Decimal additionalLeaseRate;
        public Integer dollarAmountPerCar;
        public Boolean termRights;
        public Integer increaseEffective;
        public String modNotes;
    }
/**
 *     Wrapper Class
 **/
    public class RenewalTerms{
        public Integer term;
        public Integer daysNotice;
        public Integer rateChange;
    }
/**
 * wrapper class to create ContractType Map
 **/
    public static Map<String, Integer> createContractTypeMap(){
        Map<String, Integer> contractTypeMap = new Map<String, Integer>();
        contractTypeMap.put('MANAGEMENT AGREEMENT',1);
        contractTypeMap.put('MAINTENANCE AGREEMENT',2);
        contractTypeMap.put('NET LEASE',3);
        contractTypeMap.put('FULL SERVICE LEASE',4);
        contractTypeMap.put('PURCHASE &  SALE AGREEMENT',5);
        contractTypeMap.put('PER DIEM',7);
        contractTypeMap.put('DIRECT SALE',24);
        contractTypeMap.put('NO CONTRACT',8);
        return contractTypeMap;
    }
/**
 * wrapper class to create StartMethods Map
 **/
    public static Map<String, Integer> createStartMethodsMap(){
        Map<String, Integer> startMethodsMap = new Map<String, Integer>();
        startMethodsMap.put('Fixed Date',1);
        startMethodsMap.put('Shipped Date',2);
        startMethodsMap.put('Arrival Date',3);
        startMethodsMap.put('Accepted Date',4);
        startMethodsMap.put('Delivery Date',5);
        startMethodsMap.put('Rider Effective Date',6);
        return startMethodsMap;
    }
/**
 * wrapper class to create EarlyTermMonth Map
 **/
    public static Map<String, Integer> createEarlyTermMonthMap(){
        Map<String, Integer> earlyTermMonthMap = new Map<String, Integer>();
        earlyTermMonthMap.put('January',1);
        earlyTermMonthMap.put('February',2);
        earlyTermMonthMap.put('March',3);
        earlyTermMonthMap.put('April',4);
        earlyTermMonthMap.put('May',5);
        earlyTermMonthMap.put('June',6);
        earlyTermMonthMap.put('July',7);
        earlyTermMonthMap.put('August',8);
        earlyTermMonthMap.put('September',9);
        earlyTermMonthMap.put('October',10);
        earlyTermMonthMap.put('November',11);
        earlyTermMonthMap.put('December',12);
        return earlyTermMonthMap;
    }
/**
 * wrapper class to create Rider Type Map
 **/
    public static Map<String, Integer> createRiderTypeMap(){
        Map<String, Integer> riderTypeMap = new Map<String, Integer>();
        riderTypeMap.put('Management Agreement',1);
        riderTypeMap.put('Maintenance Agreement',2);
        riderTypeMap.put('Net Lease',3);
        riderTypeMap.put('Full Service Lease',4);
        riderTypeMap.put('Purchase & Sale Agreement',5);
        riderTypeMap.put('Lpg Contract',6);
        riderTypeMap.put('Per Diem',7);
        riderTypeMap.put('No Contract',8);
        riderTypeMap.put('Tcrp Full Service Lease',11);
        riderTypeMap.put('Tcrp Net Lease',12);
        riderTypeMap.put('Master Lease Agreement',13);
        riderTypeMap.put('THIRD PARTY FULL SERVICE LEASE',14);
        riderTypeMap.put('THIRD PARTY NET LEASE',15);
        riderTypeMap.put('SUBLEASE FULL SERVICE LEASE',16);
        riderTypeMap.put('SUBLEASE NET LEASE',17);
        riderTypeMap.put('NET SERVICE-TANK BARGES',18);
        riderTypeMap.put('FULL SERVICE-TANK BARGES',19);
        riderTypeMap.put('NET SERVICE-FREIGHT BARGES',20);
        riderTypeMap.put('FULL SERVICE-FREIGHT BARGES ',21);
        riderTypeMap.put('Cit Full Service Lease',22);
        riderTypeMap.put('Cit Net Lease ',23);
        riderTypeMap.put('DIRECT SALE',24);
        riderTypeMap.put('Trams',25);
        riderTypeMap.put('Operating Lease',26);
        riderTypeMap.put('Capital Lease',27);
        return riderTypeMap;
    }
/**
 * wrapper class to create UOM Map
 **/
    public static Map<String, Integer> createUOMMap(){
        Map<String, Integer> uomMap = new Map<String, Integer>();
        uomMap.put('per car, per month',1);
        uomMap.put('per car, per mile',2);
        uomMap.put('per car, per diem',3);
        return uomMap;
    }
/**
 * wrapper class to create IncreaseEffective up on Map
 **/
    public static Map<String, Integer> createIncreaseEffecMap(){
        Map<String, Integer> increaseEffecMap = new Map<String, Integer>();
        increaseEffecMap.put('Completion of Modification',1);
        increaseEffecMap.put('Issuance Of Mandate',2);
        increaseEffecMap.put('Effective Mandate',3);
        return increaseEffecMap;
    }
/**
 * wrapper class to create ExcessMileageMethod Map
 **/
    public static Map<String, Integer> createExcessMileageMethodMap(){
        Map<String, Integer> excessMileageMethodMap = new Map<String, Integer>();
        excessMileageMethodMap.put('Rider Average',1);
        excessMileageMethodMap.put('Fleet Average',2);
        excessMileageMethodMap.put('Individual Car',3);
        return excessMileageMethodMap;
    }
    public static void createChatterPost(String riderRecId, String Message){
        FeedItem post = new FeedItem();
            post.ParentId = riderRecId;
            post.Body = Message+'\n'+System.label.RFO_URL_head+riderRecId;
            insert post;
    }
}