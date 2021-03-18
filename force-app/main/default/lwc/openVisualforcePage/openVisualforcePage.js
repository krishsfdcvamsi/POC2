import { LightningElement , api ,track } from 'lwc';

export default class OpenVisualforcePage extends LightningElement {
    @api currentRecordId;
    //dummyURL = '/apex/sbqq__sb?scontrolCaching=1&id=a2b3D000000jCrnQAE#quote/le?qId=a2b3D000000jCrnQAE';
    @track fullUrl ;
    connectedCallback() {
        this.fullUrl = '/apex/sbqq__sb?scontrolCaching=1&id='+this.currentRecordId+'#quote/le?qId='+this.currentRecordId+'';
        //alert(this.fullUrl);
        //alert(this.dummyURL);
        //this.currenRecordId = this.recordId;
        //this.currenObjectName = this.objectApiName;
        //alert('currenRecordId'+this.currenRecordId);
    }
    refresh(){
        alert('refresh..');
        let elements = document.querySelectorAll('iframe');
        console.log('elements>>>>',elements);
        for (let elem of elements) {
            var idVal = elem.Id;
            alert(idVal);
            if(idVal.includes('cpqQuoteIframe')){
               // elem.src = elem.src; 
                break;
            }
             // "test", "passed"
          }
        
    }
}