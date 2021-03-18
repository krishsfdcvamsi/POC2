/**
Copyright 2017 OpFocus, Inc

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
({
    /**
     * javascript positioning for field help text
     * @param  {[aura]}  component [description]
     * @param  {Boolean} isInit    [if function is being called from init event]
     * @return {[type]}            [void]
     */
    hlpSetHelpTextProperties: function(component, isInit) {
        try{
            var divName = component.getGlobalId() + '_helpDiv';
            var helpDiv = document.getElementById(divName);
            if(!helpDiv){
                return;
            }
            var helpButton = helpDiv.getElementsByTagName("button");
            var leftPos = helpButton[0].offsetLeft - 16;
            var helpTextBelow = component.get("v.helpTextBelow");
            
            var toolTipPosition = 'position:absolute;';
            toolTipPosition += helpTextBelow ? 'top:40px;' : 'bottom:65px;';
            toolTipPosition += 'left:' + leftPos + 'px;';
            component.set("v.toolTipPosition", toolTipPosition);
        }
        catch(e){
            this.showError(component, 'hlpSetHelpTextProperties - ' + e.message);
        }
        
    },
    
    /**
     * server call to describe field and set sObject Name
     * chains hlpGetRecords and initField
     * @param  {[aura]} component [description]
     * @return {[type]}           [void]
     */
    hlpGetField : function(component){
        try{
            var action = component.get('c.getReference');
            var field = component.get('v.sObjectField');
            
            if(!field){
                this.hlpGetRecords(component,true);
                this.initField(component);
                return;
            }
            action.setParams({
                'field' : field
            });
            
            action.setCallback(this, function(response){
                if(!this.handleResponse(component, response)){
                  console.log('bad getField')
                    return;
                }
                if($A.util.isUndefinedOrNull(component.get('v.sObjectName'))){
                    component.set('v.sObjectName',response.getReturnValue());
                }
                this.hlpGetRecords(component,true);
                this.initField(component);
            })
            $A.enqueueAction(action);
        }
        catch(e){
            this.showError(component,'hlpGetFieldHelp - ' + e.message)
        }
    },
    /**
     * server call to describe field and set help text
     * [hlpGetFieldHelp description]
     * @param  {[type]} component [description]
     * @return {[type]}           [description]
     */
    hlpGetFieldHelp : function(component){
        try{
            var action = component.get('c.getHelpText');
            var field = component.get('v.sObjectField');
            if(!field){
                return;
            }
            action.setParams({
                'field' : field
            });
            
            action.setCallback(this, function(response){
                if(!this.handleResponse(component, response)){
                  console.log('bad getFieldHelp')
                    return;
                }
                if($A.util.isUndefinedOrNull(component.get('v.helpText'))){
                    component.set('v.helpText',response.getReturnValue());
                }
                
            })
            $A.enqueueAction(action);
        }
        catch(e){
            this.showError(component,'hlpGetFieldHelp - ' + e.message)
        }
    },
    
    // Description		: fetched records to display in pick list
    // @param isInit	: Is this call from the init method ? (If so, the drop down will NOT be displayed)
    hlpGetRecords : function(component, isInit) {
        
        try{
            var records = component.get('v.availableRecords');
            var searchWhereClause = component.get("v.searchWhereClause");
            console.log(searchWhereClause);
            var displayedFieldName = component.get("v.displayedFieldName");
            console.log('displayedFieldName');
            var valueFieldName = component.get("v.valueFieldName");
            if(!document.getElementById(component.getGlobalId() + "_myinput")){
                return;
            }
            
            var action = component.get("c.getRecords");
            var sObjectName = component.get("v.sObjectName");
            if(!sObjectName) return;
            var otherFields = component.get("v.otherFields");
            var whereClause = component.get("v.whereClause");
            var filteredFieldName = component.get("v.filteredFieldName");
            var filterFieldValue = component.get("v.filterFieldValue");
            var isParent = (component.get('v.parentChild') == 'Parent');
            var isChild = (component.get('v.parentChild') == 'Child');
            console.log('hlpGetRecords: I1_'+ sObjectName + ' I2_' + displayedFieldName + ' isI_' + isInit + ' isP_' + isParent +
                        ' isC_' + isChild + ' I6_' + filteredFieldName + ' I7_' + filterFieldValue + ' M_' + component.get("v.masterFilterValue") + 
                        ' W_' + whereClause + ' D_' + component.get("v.defaultValue"));
            
            if(isChild){
                var filterFieldValue = component.get("v.masterFilterValue");
            }
            
            if(searchWhereClause && searchWhereClause != ''){
                whereClause = whereClause ? '(' + whereClause + ') AND (' + searchWhereClause + ')': searchWhereClause;
            }
            
            action.setParams({ "sObjectName" : sObjectName ,
                              "valueFieldName" : valueFieldName,
                              "otherFields" : otherFields,
                              "displayedFieldName" : displayedFieldName,
                              "whereClause" : whereClause,
                              "filteredFieldName" : filteredFieldName,
                              "filterFieldValue" : filterFieldValue,
                              "isParent" : isParent});
            console.log({ "sObjectName" : sObjectName ,
                              "valueFieldName" : valueFieldName,
                              "otherFields" : otherFields,
                              "displayedFieldName" : displayedFieldName,
                              "whereClause" : whereClause,
                              "filteredFieldName" : filteredFieldName,
                              "filterFieldValue" : filterFieldValue,
                              "isParent" : isParent});
            
            action.setCallback(this, function(response){
                if(!this.handleResponse(component, response)){
                  console.log('bad getRecords')
                    return;
                }
                var resp = response.getReturnValue();
                var lstDisplay = [];
               /* for(var i=0;i<resp.lstRecords.length;i++){
                    if(resp.lstRecords[i].RFO_CurrComm__r != undefined)
                    	lstDisplay.push(resp.lstRecords[i].Name+' - '+resp.lstRecords[i].RFO_CurrComm__r.Name+' - '+resp.lstRecords[i].RFO_CurrComm__r.RFO_STCC__c)
                    else
                        lstDisplay.push(resp.lstRecords[i].Name)
                }*/
                component.set("v.matchedListDisplay", resp.lstDisplay);
                component.set("v.matchedListValue", resp.lstValue);
                component.set("v.matchedListRecords", resp.lstRecords);
                
                
                if(resp.lstDisplay && resp.lstDisplay.length > 0 && !isInit){
                    this.showDropDown(component,false);
                }
                
            });
            $A.enqueueAction(action);
        }
        catch(e){
            console.error(e);
            this.showError(component, e.message);
        }
        
    },

    getRecordsFromList : function(component){
      var records = component.get('v.availableRecords');
      var searchWhereClause = component.get("v.searchWhereClause");
      var displayedFieldName = component.get("v.displayedFieldName");
      var valueFieldName = component.get("v.valueFieldName");
      if(!document.getElementById(component.getGlobalId() + "_myinput")){
          return;
      }
      var searchString = document.getElementById(component.getGlobalId() + "_myinput").value;
      if(records){
          var ld = [], lv = [], lr = [];
          for(var i in records){
            var r = records[i];
            var reg = RegExp('.*' + searchString + '.*');
            if(reg.test(r[displayedFieldName])){
              ld.push(r[displayedFieldName]);
              lv.push(r[valueFieldName]);
              lr.push(r);
            }

          }
          var sn = component.get('v.selectedName');
          var sv = component.get('v.selectedValue');
          var sr = component.get('v.selectedRecord');
          if(sn && sv && sr){
              ld.push(sn);
              lv.push(sv);
              lr.push(sr);
          }
          component.set("v.matchedListDisplay", ld);
          component.set("v.matchedListValue", lv);
          component.set("v.matchedListRecords", lr);
      }
    },
    /**
     * validate lookup field
     * @param  {[aura]} component [description]
     */
    hlpCheckValidity : function(component) {
        try{
            var myinput = document.getElementById(component.getGlobalId() + "_myinput").value;
            var required = component.get("v.required");
            var dropDown = component.find("dropDown");
            if(required && (!myinput || myinput == '')){
                $A.util.addClass(dropDown, 'slds-has-error');
                component.set("v.valid", false);
            }
            else{
                $A.util.removeClass(dropDown, 'slds-has-error');
                component.set("v.valid", true);
            }
        }
        catch(e){
            this.showError(component, e.message);
        }
    },
    
    /**
     * server call to query typeahead
     * @param  {[aura]} component []
     */
    hlpPerformLookup : function(component, fromToggle) {
        try{
            // we need to reset selected value and and name because the user is typing again, but since
            // selectedName is tied to the value of the input, we should save what the user has typed and restore
            // it after we change selectedName
            var searchString = document.getElementById(component.getGlobalId() + "_myinput").value;
            console.log(searchString);
            this.clearField(component,false);
            document.getElementById(component.getGlobalId() + "_myinput").value = searchString;

            
            
            // since user is typing, clear the default value and reset the whereClause
            if(!fromToggle){
              component.set("v.defaultValue","");            
              component.set("v.whereClause", component.get('v.saveWhereClause'));
            }
            
            if(searchString.length < 2 && !fromToggle){
                component.set("v.searchWhereClause", '');
                component.set("v.selectedValue", '');
                var selectedId;
                component.set("v.selectedValue", selectedId);
            }
            else{
                var searchWhereClause = component.get("v.displayedFieldName") + " LIKE '%" +
                    searchString.replace(/'/g,'\\\'') + "%'";
                component.set("v.searchWhereClause", searchWhereClause);	
            }
            
            this.hlpGetRecords(component, false);
        }
        catch(e){
            this.showError(component, e.message);
        }
    },
    
    /**
     * handles suggestion selection
     * @param  {[aura]} component []
     * @param  {[Int]} index     [Index of the suggestion list that was clicked]
     */
    hlpSelectItem : function(component, index){
        try{
            var matchedListDisplay = component.get("v.matchedListDisplay");
            var matchedListValue = component.get("v.matchedListValue");
            var matchedListRecords = component.get("v.matchedListRecords");
            var isParent = (component.get("v.parentChild") == 'Parent');
            component.set("v.selectedRecord", matchedListRecords[index]);
            component.set("v.selectedValue", matchedListValue[index]);
            if(matchedListDisplay[index].toLowerCase() != 'no records found!'){
                component.set("v.selectedName", matchedListDisplay[index]);
                this.populateField(component,matchedListDisplay[index],matchedListValue[index]);
                this.fireUpdate(component.get('v.cmpId'), matchedListRecords[index],matchedListValue[index],matchedListDisplay[index]);
            }
            
            /** 
             * handle saving recordId for MasterFilterValue
            */
            if(isParent){
                this.fireSaveFilter(component, matchedListValue[index]);
            }
            
            this.hlpCheckValidity(component);
            this.hideDropDown(component);
        }
        catch(e){
            this.showError(component, e.message);
        }
    },
    
    /**
     * fire EvtChangeLookup app event
     * @param  {[String]} name       [component id]
     * @param  {[Object]} record     [SObject record]
     * @param  {[String]} recordId   [Record Id]
     * @param  {[String]} recordName [Record Label]
     */
    fireUpdate : function(name, record, recordId, recordName){
        console.log('EVENT: EvtChangeLookup');
         var ev = $A.get('e.c:EvtChangeLookup'); 
        // var ev = component.get("e.updateLookup"); 
        ev.setParams({
            'name' : name,
            'record' : record,
            'recordId' : recordId,
            'recordName' : recordName
        });
        ev.fire();
        
       //  this.clearField(component,false);
    },
    
    /**
     * fire EvtFilterValue app event
     * @param  {[String]} recordId   [Record Id]
     */
    fireSaveFilter : function(component, recordId){
        console.log('EVENT: EvtFilterValue');
        var ev = $A.get('e.c:EvtFilterValue'); 
        console.log(ev);
        console.log(component.get('v.cmpId'));
        // var ev = component.get("e.filtervalue"); 
        ev.setParams({
            'MasterFilterValue' : recordId,
            'parent': component.get('v.cmpId')
        });
        ev.fire();
    },
    
    /**
     * fire EvtClearLookup app event
     * @param  {[String]} name  [component id]
     */
    fireClear : function(name, rid, rname){
        console.log('EVENT: EvtClearLookup');
        var ev = $A.get('e.c:EvtClearLookup'); 
        // var ev = component.get("e.clearLookup");
        ev.setParams({
            'name' : name,
            'recordId' : rid,
            'recordName' : rname
        });
        ev.fire();
    },
    
    /**
     * fire EvtInitLookup app event
     * @param  {[String]} name  [component id]
     */
    fireInit : function(name){
        console.log('EVENT: EvtInitLookup');
        var ev = $A.get('e.c:EvtInitLookup'); 
        // var ev = component.get("e.initLookup");
        ev.setParams({
            'name' : name
        });
        ev.fire();
    },
    
    /**
     * populates lookup field based on record id given at component init
     * @param  {[aura]} component   []
     * @param  {[String]} name      [Record label]
     * @param  {[String]} val       [Record Id]
     */
    populateField : function(component,name,val){
        try{
            var f = component.find('inputField')
            if(!component.get('v.pills')){
                document.getElementById(component.getGlobalId() + "_myinput").value = name;
                $A.util.removeClass(component.find('removebtn'),'hide');
            }
            else{
                $A.util.addClass(f,'hide');
                this.toggleIcons(component,false);
                var l = name;
                var a = component.getReference('c.clearField');
                var i = component.get('v.svg')
                $A.createComponent('c:CmpPills',
                                   {
                                       'label' : l ,
                                       'onremove' : a,
                                       'iconName': i
                                   },
                                   function(nc){
                                       component.find('pillsdiv').set('v.body',nc);
                                   }
                                  );
            }
            this.fireInit(component.get('v.cmpId'));
        }
        catch(e){
            this.showError(component, e.message);
        }
    },
    
    /**
     * gets the data needed for lookup based on record id given at component init
     * @param  {[aura]} component []
     */
    initField: function(component){
        var action = component.get('c.getFieldValue');
        var label = component.get('v.selectedName');
        var val = component.get('v.selectedValue');
        if(label && val){
            this.populateField(component,label,val);
        }
        else if (val) {
            action.setParams({
                'obj' : component.get('v.sObjectName'),
                'objId' : val,
                'label' : component.get('v.displayedFieldName')
            });
            
            action.setCallback(this,function(response){
                if(!this.handleResponse(component, response)){
                  console.log('bad init field');
                    return;
                }
                var res = response.getReturnValue();
                if(res.lstDisplay && res.lstValue){
                  this.populateField(component,res.lstDisplay[0],res.lstValue[0]);
                }
            })
            
            $A.enqueueAction(action);
        }
    },
    
    /**
     * toggle display of dropdown
     * @param  {[type]} component [description]
     * @return {[type]}           [description]
     */
    hlpToggleMenu : function(component){
        this.showDropDown(component,true);
    },
    
    /**
     * parses and handles server response
     * @param  {[aura]} component    []
     * @param  {[Object]} response   [server response]
     * @return {[Boolean]}           [Pass/Fail]
     */
    handleResponse : function(component, response) {
        try{
            var state = response.getState();
            if (state !== "SUCCESS") {
                var unknownError = true;
                if(state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            unknownError = false;
                            this.showError(component, errors[0].message);
                        }
                    }
                }
                if(unknownError){
                    this.showError(component, 'Unknown error from Apex class');
                }
                return false;
            }
            return true;
        }
        catch(e){
            this.showError(component, e.message);
            return false;
        }
    },
    
    /**
     * shows/toggles dropdown for suggestions
     * @param  {[aura]} component []
     * @param  {[Bool]} toggle    [is toggle or show]
     */
    showDropDown : function(component,toggle){
        try{
            var dropDown = component.find("dropDown");
            if(toggle){
                $A.util.toggleClass(dropDown, "slds-is-open");
            }
            else{
                $A.util.addClass(dropDown, "slds-is-open");
            }
            this.toggleIcons(component,true);
            // $A.util.addClass(component.find('diplayedul').get('v.body')[0].elements[0],'hlight');
        }
        catch(e){
            this.showError(component, e.message);
        }
    },

    isDropDownOpen : function (component){
        return $A.util.hasClass(component.find("dropDown"),'slds-is-open');
    },
    
    /**
     * hides dropdown box
     * @param  {[aura]} component []
     */
    hideDropDown : function(component){
        try{
            var dropDown = component.find("dropDown");
            $A.util.removeClass(dropDown, "slds-is-open");
        }
        catch(e){
            this.showError(component, e.message);
        }
    },
    
    /**
     * shows toast error message
     * @param  {[aura]} component   []
     * @param  {[String]} message   [Error message]
     */
    showError : function(component, message){
        try{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "mode": "sticky",
                "message": message
            });
            toastEvent.fire(); 
        }
        catch(e){
            this.showError(component, e.message);
        }   
    },
    
    /**
     * clears lookup field
     * @param  {[aura]} component []
     * @param  {[Bool]} fireEvent [Fire or not fire EvtClearLookup event]
     */
    clearField : function(component, fireEvent){
        try{
          var ov = component.get('v.selectedValue');
          var oname = component.get('v.selectedName');
            component.set('v.selectedName',null);
            component.set('v.selectedValue',null);
            component.set('v.selectedRecord',null);
            component.find('pillsdiv').set('v.body',null);
            component.set("v.matchedListDisplay", null);
            component.set("v.matchedListValue", null);
            component.set("v.matchedListRecords", null);
            $A.util.removeClass(component.find("inputField"),'hide');
            $A.util.addClass(component.find('removebtn'),'hide');
            
            
            if(fireEvent)
                this.fireClear(component.get('v.cmpId'), ov, oname);
        }
        catch(e){
            this.showError(component, e.message);
        }
    },
    
    /**
     * Show/Hide icons (Search, downarrow)
     * @param  {[aura]} component []
     * @param  {[Bool]} show      [Show or Hide]
     */
    toggleIcons : function(component,show){
        if(show){
            $A.util.removeClass(component.find('dropdownicon'),'hide');
            $A.util.removeClass(component.find('search_icon'),'hide');
        }
        else{
            $A.util.addClass(component.find('dropdownicon'),'hide');
            $A.util.addClass(component.find('search_icon'),'hide');
        }
    }
})