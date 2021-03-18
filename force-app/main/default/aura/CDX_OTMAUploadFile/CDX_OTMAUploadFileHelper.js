({
    MAX_FILE_SIZE: 4500000, /* 6 000 000 * 3/4 to account for base64 */
    CHUNK_SIZE: 950000, /* Use a multiple of 4 */
    
    save: function (component) {
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];  
        if(file){
            if (file.size > this.MAX_FILE_SIZE) { 
                alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
                      'Selected file size: ' + file.size);
                return;
            } 
            
            var fr = new FileReader();
            
            var self = this;
            fr.onload = function () {
                var fileContents = fr.result; 
                var base64Mark = 'base64,';
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                
                fileContents = fileContents.substring(dataStart);
                
                self.upload(component, file, fileContents);
            };
            
            fr.readAsDataURL(file);
        }
        else{
            alert('Please upload the file.');  
        }
    },
    upload: function (component, file, fileContents) {
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
        
        // start with the initial chunk
        this.uploadChunk(component, file, fileContents, fromPos, toPos, '');
    },
    uploadChunk: function (component, file, fileContents, fromPos, toPos, attachId) {
        console.log('uploadChunk'); 
        var action = component.get("c.saveTheChunk");
        var chunk = fileContents.substring(fromPos, toPos);
        action.setParams({  
            parentId: component.get("v.recordId"), 
            fileName: file.name,
            base64Data: encodeURIComponent(chunk),
            contentType: file.type,
            fileId: attachId
        });
        
        var self = this;
        action.setCallback(this, function (a) { 
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log('uploadChunk: Callback');
                attachId = a.getReturnValue();
                
                fromPos = toPos;
                toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);
                
                if (fromPos < toPos) {
                    self.uploadChunk(component, file, fileContents, fromPos, toPos, attachId);
                } else {
                    console.log('uploadChunk: done');
                    setTimeout(function(){
                        $A.get("e.force:closeQuickAction").fire(); 
                    }, 500);  
                    self.showToast('Upload Complete', 'File has been uploaded Successfully with name:'+' '+file.name, 'success', null);
                }
            }
            else if (state === "ERROR") {
                var errors = a.getError(); 
                if (errors) { 
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error"); 
                }
                self.showToast('Upload Incomplete', 'There is some error please contact your system administrator.', 'error', null);

            }
        });   
        
        $A.getCallback(function () {
            $A.enqueueAction(action);
        })();
    },
    showToast: function (title, message, type, icon) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: '2000',
            key: icon,
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
})