public class SongTableController {
    @AuraEnabled 
    public static List<songListWrapper> fetchSongWrapper(String searchGenre)
    {     
        List<songListWrapper> lstsongListWrapper = new List<songListWrapper>();
        
        // value from search genre filter
        searchGenre = '%' + searchGenre + '%'; 
        // query song records and create 'songListWrapper' class instance for each record
        for(Song__c song : [SELECT Id, Name, Genre__c, Length_m__c, Track_Count__c, Track_Licenses__c
                            FROM Song__c
                            WHERE Genre__c
                            LIKE :searchGenre
                            ORDER BY Name
                            LIMIT 1000])
        {
            // by default checkbox should be false
            lstsongListWrapper.add(new songListWrapper(false, song));
        } 
        // return the 'lstsongListWrapper' list 
        return lstsongListWrapper; 
    }
    
    /* wrapper class */  
    public class songListWrapper
    {
        // for checkboxes state (true or false) in songs table
        @AuraEnabled public boolean isChecked {get;set;}
        
        //for song object
        @AuraEnabled public Song__c objSong {get;set;}
        
        public songListWrapper(boolean isChecked, Song__c objSong)
        {
            this.isChecked = isChecked;
            this.objSong = objSong;
        }
    }
    
    /* getting all possible genre values  */
    @AuraEnabled 
    public static Map<String, String> getGenreFieldValue()
    {
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Song__c.Genre__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues)
        {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    

}