@isTest
private class UpdateGenresOnMixBatchTest {

    @testSetup
    static void setup() {
        
        List<Song__c> songs = new List<Song__c>();
        List<Track__c> tracks = new List<Track__c>();
        List<Mix__c> mixes =new List<Mix__c>();
        
        // insert mix
        mixes.add(new Mix__c(Name = 'The_Mix0'));
        mixes.add(new Mix__c(Name = 'The_Mix1', Primary_Genre__c = 'Dance Music'));

        insert mixes;

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
        Mix__c primGenre0 = [SELECT Primary_Genre__c FROM Mix__c WHERE Name = 'The_Mix0'];
        Mix__c primGenre1 = [SELECT Primary_Genre__c FROM Mix__c WHERE Name = 'The_Mix1'];

        UpdateGenresOnMixBatch updateGenres = new UpdateGenresOnMixBatch();
        Id batchId = Database.executeBatch(updateGenres);

        Test.stopTest();

        System.assertEquals(primGenre1.Primary_Genre__c, primGenre0.Primary_Genre__c);
    }
}