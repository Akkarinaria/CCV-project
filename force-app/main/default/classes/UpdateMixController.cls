public class UpdateMixController {
    
    //return existing Mix__c object for updating
    //and setting input feilds + selected songs
    @AuraEnabled
    public static Mix__c getMix(String mixId)
    {
        Mix__c mix = [SELECT Id, Name, Customer__c FROM Mix__c WHERE Id = :mixId LIMIT 1];
        return mix;
    }
    
    @AuraEnabled
    public static Contact getCustomer(String mixId) {
        Mix__c mix = [SELECT Id, Name, Customer__c FROM Mix__c WHERE Id = :mixId LIMIT 1];
        Contact con = [SELECT Id, Name FROM Contact WHERE Id = :mix.Customer__c limit 1];
        return con;
    }
    
/*	@AuraEnabled
    public static Id updateMix(Mix__c mix, List<Song__c> curSelectedSongs, List<Song__c> prevSelectedSongs){
        upsert mix;
        
        Map<Id, Track__c> prevSelectedTrackMap = new Map<Id, Track__c>();
        for (Track__c t : [SELECT Id, Name, Mix__c, Song__c FROM Track__c WHERE Mix__c IN (:mix.Id)]) {
            prevSelectedTrackMap.put(t.Id, t);
        }
        
        
        List<Track__c> oldSelectedTrackList = new List<Track__c>();
        Set<Track__c> newSelectedTrackSet = new Set<Track__c>();
        // only for insert in the end
        List<Track__c> newTrackList = new List<Track__c>();
                
        for (Song__c s : curSelectedSongs) {
            for (Track__c t : prevSelectedTrackMap.values()) {
                if (t.Song__c == s.Id) {
                    newSelectedTrackSet.add(t);
                } else {
                    oldSelectedTrackList.add(t);
                }
            }
        }
        delete oldSelectedTrackList;
        
        //set without dublicate values
        for (Song__c song : curSelectedSongs) {
            newSelectedTrackSet.add(new Track__c(Song__c = song.Id, Mix__c = mix.Id));
        }
        
        // only for insert in the end
        for (Track__c tr : newSelectedTrackSet) {
            newTrackList.add(tr);
        }

        insert newTrackList;
        return mix.Id;
    }*/
    

    
 	@AuraEnabled
    public static Id updateMix(Mix__c mix, List<Song__c> curSelectedSongs){
        upsert mix;
        
        List<Track__c> trackPrevSelectedList = new List<Track__c> ([SELECT Id, Name, Mix__c, Song__c FROM Track__c WHERE Mix__c IN (:mix.Id)]);
        delete trackPrevSelectedList;
        
        List<Track__c> newTracks = new List<Track__c>();
        for(Song__c song : curSelectedSongs) {
            newTracks.add(new Track__c(Song__c = song.Id, Mix__c = mix.Id));
        }
        insert newTracks;
        return mix.Id;
    } 
    
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
    
    //returns all list views for the mix object
    @AuraEnabled
	public static List<ListView> getListViews() {
        List<ListView> listviews = [SELECT Id, Name
                                    FROM ListView
                                    WHERE SobjectType = 'Mix__c'];
        return listviews;
    }

}