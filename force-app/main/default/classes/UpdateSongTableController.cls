public class UpdateSongTableController {
    /* wrapper class */  
    public class songListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public Song__c objSong {get;set;}
        public songListWrapper(boolean isChecked, Song__c objSong){
            this.isChecked = isChecked;
            this.objSong = objSong;
        }
    }
    
    
        //for songs
    @AuraEnabled 
    public static List<songListWrapper> getSongs(String mixId){     
        List<Track__c> trackSelectedList = new List<Track__c>([SELECT Id, Name, Mix__c, Song__c FROM Track__c WHERE Mix__c IN (:mixId)]);
        List<Song__c> songList = new List<Song__c>([SELECT Id, Name, Genre__c, Length_m__c, Track_Count__c, Track_Licenses__c FROM Song__c]);
        
        List<songListWrapper> lstsongListWrapper = new List<songListWrapper>();
        // query song records and create 'songListWrapper' class instance for each record
        for (Track__c track : trackSelectedList) {
            Song__c song = [SELECT Id, Name, Genre__c, Length_m__c, Track_Count__c, Track_Licenses__c FROM Song__c WHERE Id = :track.Song__c];
            lstsongListWrapper.add(new songListWrapper(true, song));
            for(Integer i = 0; i<songList.size(); i++) {
                if (song.Id == songList[i].Id) {
                    songList.remove(i);
                }
            }
        }
        for(Song__c song : songList){
            lstsongListWrapper.add(new songListWrapper(false, song));
        }

        return lstsongListWrapper; 
    }


	@AuraEnabled 
    public static List<songListWrapper> fetchSongWrapper(String searchGenre){     
        List<songListWrapper> lstsongListWrapper = new List<songListWrapper>();
        searchGenre = '%' + searchGenre + '%'; 
        // query song records and create 'songListWrapper' class instance for each record
        for(Song__c song : [SELECT Id, Name, Genre__c, Length_m__c, Track_Count__c, Track_Licenses__c FROM Song__c WHERE Genre__c LIKE :searchGenre ORDER BY Name LIMIT 1000]){
                               // by default checkbox should be false 
                               lstsongListWrapper.add(new songListWrapper(false, song));
                           } 
        // return the 'lstsongListWrapper' list 
        return lstsongListWrapper; 
    }

    
    
    @AuraEnabled 
    public static Map<String, String> getGenreFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Song__c.Genre__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
}