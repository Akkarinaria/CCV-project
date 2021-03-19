public with sharing class SongTriggerHandler {
    public void afterInsert(List<Song__c> songList) {
        for (Song__c s : songList) {
            s.Track_Count__c = 0;
        }
        update songList;

        List<Id> songIdList = new List<Id>();

        for (Song__c so : songList) {
            songIdList.add(so.Id);
        }
        updateTrackCountField(songIdList);
    }

    public void afterUpdate(List<Song__c> songListNew, Map<Id, Song__c> songOldMap) {
        List<Id> songIdList = new List<Id>();

        for (Song__c s : songListNew) {
            for (Song__c so : songOldMap.values()) {
                if (songOldMap.get(s.Id).Id != so.Id) {
                    // add both new and old id to update
                    songIdList.add(s.Id);
                    songIdList.add(so.Id);
                }
            }
            songIdList.add(s.Id);
        }
        updateTrackCountField(songIdList);
    }

    public static void updateTrackCountField(List<Id> songIdList) {
        List<Song__c> songTrackCount = [
            SELECT Track_Count__c, (SELECT Id FROM Tracks__r)
            FROM Song__c
            WHERE Id IN :songIdList
        ];

        for (Song__c s : songTrackCount) {
            s.Track_Count__c = s.Tracks__r.size();
        }
        update songTrackCount;
    }
}