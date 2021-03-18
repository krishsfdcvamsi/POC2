import { LightningElement,  api ,track} from 'lwc';
export default class AssetGroupLine extends LightningElement {
    @api recordId;
    @api objectApiName;
    currenObjectName;
    groupId;
    //assetGroupInfo =[];

    isLoaded =  true;
    error;
    connectedCallback() {
        this.groupId = this.recordId;
        this.isLoaded =  false;
        
     }
}