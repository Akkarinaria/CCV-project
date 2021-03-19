public with sharing class TrackTriggerHandler {
    
    // get list of mix Ids which tracks were inserted, deleted or undeleted
    public void trackInsertedUndeletedDeleted(Map<Id, Track__c> trackMap) {
        List<Id> songIdList = new List<Id>();
        List<Id> mixIdList = new List<Id>();

        for (Track__c t : trackMap.values()) {
            songIdList.add(t.Song__c);
            mixIdList.add(t.Mix__c);
        }

        List<Song__c> songLicenseUsageList = [SELECT Track_Licenses__c, Track_Count__c FROM Song__c WHERE Id = :songIdList];

        // add error when Track licenses expired
        for (Track__c t : trackMap.values()) {
            for (Song__c so : songLicenseUsageList) {
                if (so.Track_Count__c == so.Track_Licenses__c) {
                    Track__c tr = trackMap.get(t.Id);
                    tr.addError('Song usage limit reached.\nPlease choose another song.');
                }
            }
        }

        List<Mix__c> mixList = [SELECT Id FROM Mix__c WHERE Id IN :mixIdList];

        // add error when Mix is going to be too long
        for (Mix__c m : mixList) {
            Double lengthOfMix = 0;
            List<Id> songIdOfMix = new List<Id>();
            List<Track__c> trackList = [SELECT Song__c, Mix__c FROM Track__c WHERE Mix__c = :m.Id];
            
            for (Track__c t : trackList) {
                songIdOfMix.add(t.Song__c);
                List<Song__c> songList = [SELECT Length_m__c FROM Song__c WHERE Id IN :songIdOfMix];
            
                for (Song__c s : songList) {
                    lengthOfMix += s.Length_m__c;
                    if (lengthOfMix > 90) {
                        Track__c tr = trackMap.get(t.Id);
                        tr.addError('This song will exceed the Mix length limit.');
                    }
                }  
            }    
        }
        
        updateTrackCountField(songIdList);
        updateGenresField(mixIdList);
    }
    
    // get list of mix Ids which tracks were changed
    // public void trackUpdated(List<Track__c> trackListNew, Map<Id, Track__c> trackOldMap) {
    public void trackUpdated(Map<Id, Track__c> trackNewMap, Map<Id, Track__c> trackOldMap) {
        List<Id> songIdList = new List<Id>();
        List<Id> mixIdList = new List<Id>();

        List<Song__c> songFieldsList = [SELECT Track_Licenses__c, Track_Count__c FROM Song__c WHERE Id = :songIdList];

        // add error when Track licenses expired
        for (Track__c t : trackNewMap.values()) {
            for (Song__c so : songFieldsList) {
                if (so.Track_Count__c == so.Track_Licenses__c) {
                    Track__c tr = trackNewMap.get(t.Id);
                    tr.addError('Song usage limit reached.\nPlease choose another song.');
                }
            }
        }

        // for (Track__c t : trackListNew) {
        for (Track__c t : trackNewMap.values()) {
            if (t.Song__c != trackOldMap.get(t.Id).Song__c) {
                // add both new and old id to update
                songIdList.add(t.Song__c);
                songIdList.add(trackOldMap.get(t.Id).Song__c);
            }
            songIdList.add(t.Song__c);

            if (t.Mix__c != trackOldMap.get(t.Id).Mix__c) {
                // add both new and old id to update
                mixIdList.add(t.Mix__c);
                mixIdList.add(trackOldMap.get(t.Id).Mix__c);
            }
            mixIdList.add(t.Mix__c);
        }
        updateTrackCountField(songIdList);
        updateGenresField(mixIdList);
    }

    // update fields on Song__c
    public static void updateTrackCountField(List<Id> songIdList) {
        List<Song__c> songTrackCount = [
            SELECT Track_Count__c, Track_Licenses__c, (SELECT Id FROM Tracks__r)
            FROM Song__c
            WHERE Id IN :songIdList
        ];

        for (Song__c s : songTrackCount) {
            if (s.Track_Count__c < s.Track_Licenses__c) {
                s.Track_Count__c = s.Tracks__r.size();
            }
        }
        update songTrackCount;
    }
    
    // update fields on Mix__c
    public static void updateGenresField(List<Id> mixIdList) {
        // List of mixes to update
        List<Mix__c> mixListToUpdate = new List<Mix__c>();
        
        String primGenre = ''; 
        String secondGenre = '';
        
        // for each mix
        for (Mix__c curMix : [SELECT Id, Name, Primary_Genre__c, Secondary_Genre__c FROM Mix__c	WHERE Id IN :mixIdList] ) {
            List<Id> songIdsFromMix = new List<Id>();
            List<String> allSongGernes = new List<String>();
            Set<String> uniqueGenres = new Set<String>();
            
            // get all songs from the mix (for each track)
            for (Track__c curTrack : [SELECT Id, Name, Mix__c, Song__c FROM Track__c WHERE Mix__c = :curMix.Id]) {
                songIdsFromMix.add(curTrack.Song__c);
            }
            
            // get all song genres for the mix
            for (Song__c curSong : [SELECT Genre__c FROM Song__c WHERE Id IN :songIdsFromMix]) {
                allSongGernes.add(curSong.Genre__c);
            }
            
            // identify unique genres
            for (String str : allSongGernes) {
                uniqueGenres.add(str);
            }

            // rewrite map <genre, count of songs> because of the same key in map
            // so we get unique keys (genres) with value of total number of usage
            Map<String, Integer> genreCountMap = new Map<String, Integer>();
            Map<String, Integer> secGenreCountMap = new Map<String, Integer>();
            

            List<Song__c> songGenreList = [SELECT Id, Genre__c FROM Song__c WHERE Id IN :songIdsFromMix];

            if (!uniqueGenres.isEmpty()) {
                
                if (uniqueGenres.size() > 1) {
                    
                    for (String u : uniqueGenres) {
                        Integer numInUnique = 0;
                        
                        for (Song__c allSongs : songGenreList) {
                            
                            if (allSongs.Genre__c == u) {
                                numInUnique++;
                                // rewrite is here
                                genreCountMap.put(allSongs.Genre__c, numInUnique);
                            }
                        }
                    }
                    
                    // look for 2 the highest numbers
                    Integer highestValue = 0;
                    Integer secondValue = 0;

                    for (Integer i : genreCountMap.values()) {
                        if (i > highestValue) {
                            secondValue = highestValue;
                            highestValue = i;
                        }
                        if ((i < highestValue) && (i > secondValue)) {
                            secondValue = i;
                        }
                        
                    }
                    
                    for (String k : genreCountMap.keySet()) {
                        if (genreCountMap.get(k) == highestValue) {
                            primGenre = k;
                        }
                        if (genreCountMap.get(k) == secondValue) {
                            secondGenre = k;
                        }
                    }
                }
                        
                // if the only genre
                if (uniqueGenres.size() == 1) {
                    for (String u : uniqueGenres) {
                        primGenre = u;
                        secondGenre = '';
                    }
                }
            }
                
            curMix.Primary_Genre__c = primGenre;
            curMix.Secondary_Genre__c = secondGenre;
            mixListToUpdate.add(curMix);
        }
        
        update mixListToUpdate;
    }
}