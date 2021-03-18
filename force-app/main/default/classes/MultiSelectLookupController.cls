public with sharing class MultiSelectLookupController {

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String values, string recordType, string accountId) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            system.debug('@---- '+values);
            List<String> selectedvalues = (List<String>) JSON.deserialize(values, List<String>.class);
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(selectedvalues != null && selectedvalues.size() > 0) {
                query += ' WHERE Id IN: selectedvalues ';
            } else {
                query += ' WHERE '+filterField+
                        ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'';
            }
            
            list<String> profiles = new list<String>();
            if(recordType == 'New') {
                profiles = System.Label.New_Car_Profile_Names.split(',');
            }
            else {
                profiles = System.Label.Existing_Car_Profile_Names.split(',');
            }
            if(objectName == 'User' && profiles.size() > 0) {
                query += ' AND Profile.Name IN: profiles LIMIT 100';
            }
            else if(objectName == 'Contact') {
                query += ' AND AccountId =:  accountId  LIMIT 100';
            }
            system.debug('@query = '+query);
            for(SObject s : Database.query(query)) {
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
            }
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }

    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}