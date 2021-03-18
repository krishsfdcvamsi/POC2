import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuotes from '@salesforce/apex/CustomerSpecController.getCustomerSpecInfo';
export default class customerSpecDetail extends LightningElement {
    @api customerSpecId;
    @api quoteId;
    @api isTrinity = false;
    isBoxCar =  false;
    isGeneralPurpseTankCar  = false;
    isCoveredHopperPD = false;
    isPressureTankCar = false;
    error;
    @track activeSections = [];
    
    connectedCallback() {
            //alert('quoteId>>>>'+this.quoteId);
        getQuotes({quoteId : this.quoteId, isTrinity:this.isTrinity})
        .then(result => { 
            console.log('result>>>>customerSpec',result);
            //alert('result>>'+result);
            this.customerSpecId = result.Id;
            var recordtypeName = result.RecordType.Name;
            if(recordtypeName  == 'General Purpose Tank Car'){
                this.isGeneralPurpseTankCar = true;
            }else if(recordtypeName  == 'Box Car'){
                this.isBoxCar = true;
            }else if(recordtypeName  == 'Covered Hopper and PD'){
                this.isCoveredHopperPD = true;
            }else if(recordtypeName  == 'Pressure Tank Car'){
                this.isPressureTankCar = true;
            }
        })
        .catch(error => { 
            console.log('error>>>>>>customerSpec>>',error);
            this.error = error ;
        })
    }
    handleCancel(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }
    handleSuccess() {
        const event = new ShowToastEvent({
            variant: 'success',
            title: 'Success!',
            message: 'Record has been created',
        });
        this.dispatchEvent(event);
    }
    sayhello(){
        alert('Hello..');
    }
}