({
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.mydata");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.mydata", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    
    UrlLink: function (cmp, row) {
        console.log("In url function");
        var rows = cmp.get('v.mydata');
        console.log("MY DATA: "+rows);
        var rowIndex = rows.indexOf(row);
        console.log("INDEX: "+rowIndex);
        var comurlz = window.location.hostname;
        console.log(comurlz);
        var fulllink = "https://"+comurlz+"/s/file/"+rows[rowIndex].ContentDocumentId;
        console.log(fulllink);
        var win = window.open(fulllink, '_blank');
        win.focus();
        
    }
})