public class CustomLookUpController {
    @AuraEnabled
    public static List<sObject> fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List <sObject> returnList = new List<sObject>();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10   
        String sQuery =  'SELECT id, Name FROM ' + ObjectName + ' WHERE Name LIKE: searchKey ORDER BY createdDate DESC LIMIT 10';
        List <sObject> lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled(cacheable=true)
    public static  sObject  getDefaultValue(String recordId, String ObjectName) {
        List<sObject> returnList = new List<sObject>();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10   
        String sQuery =  'SELECT id, Name FROM ' + ObjectName + ' WHERE Id = :recordId ORDER BY createdDate DESC LIMIT 5';
        return Database.query(sQuery);
      
    }
}