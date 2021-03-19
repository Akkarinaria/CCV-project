@isTest
private class UpdateTrackCountOnSongBatchTest {
    @testSetup
    static void setup() {
        
        List<Song__c> songs = new List<Song__c>();
        List<Track__c> tracks = new List<Track__c>();

        insert new Mix__c(Name = 'The_Mix0');
        // insert songs
        songs.add(new Song__c(
            Name = 'Song1',
            Artist__c = 'Artist1',
            Genre__c = 'Blues',
            Length_m__c = 0.5 ,
            Track_Licenses__c = 3 
        ));
        songs.add(new Song__c(
            Name = 'Song2',
            Artist__c = 'Artist2',
            Genre__c = 'Dance Music',
            Length_m__c = 0.5 ,
            Track_Licenses__c = 3 
        ));
        songs.add(new Song__c(
            Name = 'Song3',
            Artist__c = 'Artist3',
            Genre__c = 'Dance Music',
            Length_m__c = 1.5 ,
            Track_Licenses__c = 3 
        ));

        insert songs;

        // mix for id
        Mix__c mixId0 = [
            SELECT Id
            FROM Mix__c
            WHERE Name = 'The_Mix0'
        ];

        // insert 3 tracks for each song for mix0
        for (Song__c s : [
            SELECT Id
            FROM Song__c
        ]) {
            tracks.add(new Track__c(
                Song__c = s.Id,
                Mix__c = mixId0.Id
            ));
        }    
        insert tracks;
    }

    @isTest static void testCheckPrimaryGenre() {
        Test.startTest();
        Track__c t = [
            SELECT Id
            FROM Track__c
            LIMIT 1
        ];
        UpdateTrackCountOnSongBatch updateTrackCount = new UpdateTrackCountOnSongBatch();
        Id batchId = Database.executeBatch(updateTrackCount);

        Test.stopTest();

        Song__c s = [SELECT Track_Count__c FROM Song__c LIMIT 1];

        System.assertNotEquals(null, s);
        System.assertEquals(1, s.Track_Count__c);
    }
}