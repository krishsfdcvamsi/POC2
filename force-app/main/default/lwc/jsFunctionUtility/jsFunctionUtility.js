import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**************************************************************************
Purpose: Show Toast Message
Parameters
    strTitle: Title For Message
    strMessage: Detailed Message to Display
    strVariant: Variant (info/success/warning/error)
    strMode: Behaviour for Message Display (dismissable/pester/sticky)
Returns: Show Toast Event
****************************************************************************/
function showToast(strTitle, strMessage, strVariant="info", strMode="dismissable") {
    const event = new ShowToastEvent({
        title: strTitle,
        message: strMessage,
        variant: strVariant,
        mode: strMode
    });
    return event;
}
export { showToast }

/**************************************************************************
Purpose: Parse Error Messages to Display in Modal Popup
Parameters: 
Returns: List of Error Messages
****************************************************************************/
function parseErrorMessages(error){
    
    let listErrors = [];

    // - Get Errors from Message
    if (error && error.message) {
        listErrors.push(error);
    }
    // - Get Errors
    if (error && error.body && error.body.output && error.body.output.errors && error.body.output.errors.length > 0) {
        listErrors = listErrors.concat(error.body.output.errors);
    } else if (error && error.output && error.output.errors && error.output.errors.length > 0) {
        listErrors = error.output.errors;
    }

    // - Get Field Errors
    let listFieldErrors;
    if (error && error.body && error.body.output && error.body.output.fieldErrors) {
        listFieldErrors = error.body.output.fieldErrors;
    } else if (error && error.output && error.output.fieldErrors) {
        listFieldErrors = error.output.fieldErrors;
    }
    if (listFieldErrors) {
        for (let fieldErrorKey in listFieldErrors) {
            if (Object.prototype.hasOwnProperty.call(listFieldErrors, fieldErrorKey)) {
                let listAllFieldErrors = listFieldErrors[fieldErrorKey];
                for (let intI=0; intI<listAllFieldErrors.length; intI++) {
                    listErrors.push(listAllFieldErrors[intI]);
                }
            }
        }
    }

    // - Iterate through Errors and Prepare Error Message List to Return
    let listErrorMessages = [];
    if (listErrors && listErrors.length > 0) {
        for (let intI=0; intI<listErrors.length; intI++) {
            if (listErrors[intI].fieldLabel) {
                listErrorMessages.push(listErrors[intI].fieldLabel + ' - ' + listErrors[intI].message);
            } else {
                listErrorMessages.push(listErrors[intI].message);
            }
        }
    } else if (error && error.body && error.body.message) {
        listErrorMessages.push(error.body.message);
        listErrorMessages.push(error.body.stackTrace);
    }
    return listErrorMessages;
}
export { parseErrorMessages }

/**************************************************************************
Purpose: Navigation
Parameters
    strRecordId: Record Id
    strObjectAPIName: Object API Name
Returns: Navigation Page Reference Object
****************************************************************************/
function pageNavigation(strType, strRecordId, strObjectAPIName, strActionName, strRelationshipApiName){
    let objRedirectPageReference = {
        type: strType,
        attributes: {
            recordId: strRecordId,
            objectApiName: strObjectAPIName,
            relationshipApiName: strRelationshipApiName,
            actionName: strActionName
        }
    };
    return objRedirectPageReference;
}
export { pageNavigation }