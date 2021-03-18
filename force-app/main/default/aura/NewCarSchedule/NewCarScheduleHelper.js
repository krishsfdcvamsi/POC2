({
    doInit : function(component,event) {
        var data = [];
        var action = component.get("c.getAssetFiles");

        action.setParams({orderId : component.get("v.orderId")});
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            console.log(response.getReturnValue());

            this.setWeeks(component,event,resp);
        });
        $A.enqueueAction(action);
    },
    setWeeks : function(component,event, resp){
        const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul'];
        var today = new Date();
        var dayOfWeek = new Date().getDay()
        var currentWeekend = new Date(today.setDate(today.getDate()+(5-dayOfWeek)));
        var tmp = new Date(currentWeekend.getFullYear(),currentWeekend.getMonth(),currentWeekend.getDate());
        var lastWeekend = new Date(tmp.setDate(tmp.getDate()-7));
        var pastDate = new Date();;
        var pastData = {};
        try{
            for(var i=0;i<resp.length;i++){
                var pastOrderSchedules = [];
                var dataByWeek = this.getDataByWeek(currentWeekend);
                resp[i]['data'] = [];
                if(resp[i].Order_Schedule__r)
                    for(var j=0;j<resp[i].Order_Schedule__r.length;j++){
                        var dueDate = new Date(resp[i].Order_Schedule__r[j].Due_Date__c+'T00:00:00.000-07:00');

                        var tmpDueDate = new Date(resp[i].Order_Schedule__r[j].Due_Date__c+'T00:00:00.000-07:00');
                        console.log(dueDate)

                        pastDate = pastDate < dueDate ? pastDate : dueDate;
                        if(dueDate < lastWeekend){
                            pastOrderSchedules.push(resp[i].Order_Schedule__r[j]);
                            pastData[resp[i].Id] = {}
                            pastData[resp[i].Id]['data'] = pastOrderSchedules;

                            dataByWeek[0].committed += resp[i].Order_Schedule__r[j].Committed__c? parseInt(resp[i].Order_Schedule__r[j].Committed__c) : 0;

                            dataByWeek[0].scheduled += parseInt(resp[i].Order_Schedule__r[j].Scheduled_Actuals__c);
                        }
                        else{

                            var dueDateWeekend = new Date(tmpDueDate.setDate(tmpDueDate.getDate()+( 5 - tmpDueDate.getDay())));

                            var weekNumber = Math.ceil((dueDateWeekend.getTime()- currentWeekend.getTime())/(1000*60*60*24));
                            var tmp;
                            weekNumber =  Math.floor(weekNumber/7);
                            if(weekNumber >= 0 && weekNumber < 9  ){
                                //dataByWeek[weekNumber+1].week = (dueDateWeekend.getMonth()+1)+'/'+dueDateWeekend.getDate();
                                dataByWeek[weekNumber+1].committed += parseInt(resp[i].Order_Schedule__r[j].Committed__c);
                                dataByWeek[weekNumber+1].scheduled += parseInt(resp[i].Order_Schedule__r[j].Scheduled_Actuals__c);
                                tmp = dueDateWeekend;

                            }
                            else{
                                tmp = dataByWeek[8].date;
                                if(dueDate.getFullYear() == tmp.getFullYear()){

                                if( dueDate.getMonth() == tmp.getMonth()){
                                    dataByWeek[9].committed += parseInt(resp[i].Order_Schedule__r[j].Committed__c);
                                    dataByWeek[9].scheduled += parseInt(resp[i].Order_Schedule__r[j].Scheduled_Actuals__c);
                                }
                                else if(dueDate.getMonth() == tmp.getMonth()+1){


                                    dataByWeek[10].committed += parseInt(resp[i].Order_Schedule__r[j].Committed__c);
                                    dataByWeek[10].scheduled += parseInt(resp[i].Order_Schedule__r[j].Scheduled_Actuals__c);
                                }
                                    else if(dueDate.getMonth() == tmp.getMonth()+2){
                                        dataByWeek[11].committed += parseInt(resp[i].Order_Schedule__r[j].Committed__c);
                                        dataByWeek[11].scheduled += parseInt(resp[i].Order_Schedule__r[j].Scheduled_Actuals__c);
                                    }
                                        else{
                                            dataByWeek[12].committed += parseInt(resp[i].Order_Schedule__r[j].Committed__c);
                                            dataByWeek[12].scheduled += parseInt(resp[i].Order_Schedule__r[j].Scheduled_Actuals__c);
                                        }

                                }
                                else{
                                    dataByWeek[12].committed += parseInt(resp[i].Order_Schedule__r[j].Committed__c);
                                    dataByWeek[12].scheduled += parseInt(resp[i].Order_Schedule__r[j].Scheduled_Actuals__c);
                                }

                            }
                        }
                    }
                resp[i]['data'] = dataByWeek;
                if(pastData[resp[i].Id] && pastData[resp[i].Id].data){
                    pastData[resp[i].Id]['assetFile'] = resp[i];
                }
                else{
                    pastData[resp[i].Id] = {'assetFile':resp[i]}
                }
            }
        }
        catch(e){
            console.log(e);
        }
        console.log(resp);
        component.set("v.data",  resp);
        component.set("v.pastData",  pastData);
        component.set("v.pastDate", pastDate);
    },
    getDataByWeek : function(currentWeekend){
        const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        var tmpDate = new Date(currentWeekend.getTime());
        var dataByWeek = [{
            "week" : "Past",
            "committed": 0,
            "scheduled": 0
        },
                          {
                              "week" : (tmpDate.getMonth()+1)+'/'+tmpDate.getDate(),
                              "committed": 0,
                              "scheduled": 0,
                              "date": tmpDate
                          }];
        for(var i=0;i<8;i++){
            var weekDate = new Date(tmpDate.setDate(tmpDate.getDate()+7));
            if(i<7){
                dataByWeek.push({
                    "week" : (weekDate.getMonth()+1)+'/'+weekDate.getDate(),
                    "committed": 0,
                    "scheduled": 0,
                    "date": weekDate
                });
            }
            else{
                for(var k=0;k<3;k++){
                    dataByWeek.push({
                        "week" : MONTHS[weekDate.getMonth()+k]+'-'+weekDate.getFullYear(),
                        "committed": 0,
                        "scheduled": 0,
                    });
                }
                dataByWeek.push({
                    "week" : 'Future',
                    "committed": 0,
                    "scheduled": 0
                });
            }
        }
        return dataByWeek
    },
    handlePast : function(component, event){
        var assetFileId = event.getSource().get("v.name");
        var pastData = component.get("v.pastData");
        var pastDataList = [];
        const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        var today = new Date();
        var d;
        let dataByMonth = {}
        var pastDate = new Date(component.get("v.pastDate"));
        try{
        var months = today.getMonth() - pastDate.getMonth()  + (today.getFullYear() - pastDate.getFullYear()) * 12;
        for(var i = months; i > 0; i -= 1) {
            d = new Date(today.getFullYear(), today.getMonth() - i, 1);
            dataByMonth['_'+d.getMonth()+'-'+d.getFullYear()] = {
                "month" : MONTHS[d.getMonth()]+'-'+d.getFullYear(),
                "committed": 0,
                "scheduled": 0
            };
        }
        dataByMonth['_'+today.getMonth()+'-'+today.getFullYear()] = {
            "month" : MONTHS[today.getMonth()]+'-'+today.getFullYear(),
            "committed": 0,
            "scheduled": 0
        }
        if(pastData[assetFileId].data)
            for(var i=0;i<pastData[assetFileId].data.length;i++){
                var dueDate = new Date(pastData[assetFileId].data[i].Due_Date__c);
                console.log(dataByMonth);
                dataByMonth['_'+dueDate.getMonth()+'-'+dueDate.getFullYear()].committed += parseInt(pastData[assetFileId].data[i].Committed__c);
                dataByMonth['_'+dueDate.getMonth()+'-'+dueDate.getFullYear()].scheduled += parseInt(pastData[assetFileId].data[i].Scheduled_Actuals__c);
                // pastDataList.push(dataByMonth[dueDate.getMonth()]);
            }  
    }
        catch(e){
            console.log(e);
        }
        console.log( Object.values(dataByMonth));
        component.set("v.pastDataList", Object.values(dataByMonth));
        component.set("v.currentAssetFile", pastData[assetFileId].assetFile);
    }
})