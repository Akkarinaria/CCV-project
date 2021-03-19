public class CustomLookUpNewController {
    @AuraEnabled
    public static List <Contact> fetchLookUpValues(String searchKeyWord) {
        String searchKey = '%' + searchKeyWord + '%';
        
        List <Contact> returnList = new List <Contact> ();
      
        // SOQL Query For Fetch Record List with LIMIT 10  
        String soql =  'SELECT Id, Name FROM Contact WHERE Name LIKE :searchKey ORDER BY createdDate DESC LIMIT 10';
        List <Contact> lstOfRecords = Database.query(soql);
        
        for (Contact con: lstOfRecords) {
            returnList.add(con);
        }
        return returnList;
    }
}