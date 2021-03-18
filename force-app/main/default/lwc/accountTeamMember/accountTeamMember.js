import { LightningElement, api, wire } from 'lwc';
import getAccountTeamMemberList from '@salesforce/apex/CDX_GetAccountTeamMemberData.getAccountTeamMemberList';
export default class accountTeamMember extends LightningElement {
    @api recordId;

    @wire(getAccountTeamMemberList, {accId:'$recordId' })
  
    accounts;
}