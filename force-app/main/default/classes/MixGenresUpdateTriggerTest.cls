@isTest
private class MixGenresUpdateTriggerTest {
    
    @TestSetup
    static void setup() {
        List<Song__c> songs = new List<Song__c>();
        List<Track__c> tracks = new List<Track__c>();
        List<Mix__c> mixes =new List<Mix__c>();
        
        // insert mix
        Mix__c mix0 = new Mix__c(Name = 'The_Mix0');
        Mix__c mix1 = new Mix__c(Name = 'The_Mix1', Primary_Genre__c = 'Dance Music');
        Mix__c mix2 = new Mix__c(Name = 'The_Mix2', Secondary_Genre__c = 'Blues');
        Mix__c mix3 = new Mix__c(Name = 'The_Mix3', Secondary_Genre__c = '');

        mixes.add(mix0);
        mixes.add(mix1);
        mixes.add(mix2);
        mixes.add(mix3);

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
        System.debug('songs ----- ' + songs);

        Mix__c mixForId = [
            SELECT Id
            FROM Mix__c
            WHERE Name = 'The_Mix0'
        ];
        System.debug('mixForId ----- ' + mixForId.Id);

        // insert tracks
        for (Song__c s : [
            SELECT Id
            FROM Song__c
        ]) {
            tracks.add(new Track__c(
                Song__c = s.Id,
                Mix__c = mixForId.Id
            ));
        }

        Song__c ss = [SELECT Id FROM Song__c WHERE Name = 'Song3'];
        Mix__c mm = [SELECT Id FROM Mix__c WHERE Name = 'The_Mix2'];
        tracks.add(new Track__c (Song__c = ss.Id,
                                 Mix__c = mm.Id));

        insert tracks;
        System.debug('tracks ----- ' + tracks);
    }

    @isTest static void testInsertTracksCheckPrimaryGenre() {
        Test.startTest();
        Mix__c primGenre = [SELECT Primary_Genre__c FROM Mix__c WHERE Name = 'The_Mix0'];
        Mix__c primGenre1 = [SELECT Primary_Genre__c FROM Mix__c WHERE Name = 'The_Mix1'];
        Test.stopTest();

        System.assertEquals(primGenre1.Primary_Genre__c, primGenre.Primary_Genre__c);
    }

    @isTest static void testInsertOneTrack() {
        Test.startTest();
        Mix__c primGenre2 = [SELECT Secondary_Genre__c FROM Mix__c WHERE Name = 'The_Mix2'];
        Mix__c primGenre3 = [SELECT Secondary_Genre__c FROM Mix__c WHERE Name = 'The_Mix3'];
        Test.stopTest();
        
        System.assertEquals(primGenre3.Secondary_Genre__c, primGenre2.Secondary_Genre__c);
    }

    @isTest static void testInsertTracksCheckSecondaryGenre() {
        Test.startTest();
        Mix__c primGenre = [SELECT Secondary_Genre__c FROM Mix__c WHERE Name = 'The_Mix0'];
        Mix__c primGenre1 = [SELECT Secondary_Genre__c FROM Mix__c WHERE Name = 'The_Mix1'];
        Test.stopTest();

        System.assertEquals(primGenre1.Secondary_Genre__c, primGenre.Secondary_Genre__c);
    }



    //Secondary_Genre__c


    // @isTest static void testDeleteTracks() {
    //     Test.startTest();
    //     Track__c t = [
    //         SELECT Id
    //         FROM Track__c
    //         LIMIT 1
    //     ];
    //     Database.DeleteREsult result = Database.delete(t, true);
    //     Test.stopTest();

    //     System.assertNotEquals(null, [
    //         SELECT Track_Count__c
    //         FROM Song__c
    //     ]);
    // }

    // @isTest static void testUpdateTracks() {
    //     Test.startTest();
    //     Song__c s1 = [
    //         SELECT Id
    //         FROM Song__c
    //         WHERE Name = 'Song1'
    //         LIMIT 1
    //     ];
    //     Track__c t = [
    //         SELECT Id
    //         FROM Track__c
    //         WHERE Song__c = :s1.Id
    //         LIMIT 1 
    //     ];
    //     Song__c s2 = [
    //         SELECT Id
    //         FROM Song__c
    //         WHERE Name = 'Song2'
    //         LIMIT 1
    //     ];

    //     t.Song__c = s2.Id;

    //     Database.SaveResult result = Database.update(t, true);
    //     Test.stopTest();

    //     Song__c sTest = [
    //         SELECT Track_Count__c
    //         FROM Song__c
    //         WHERE Name = 'Song2'
    //         LIMIT 1
    //     ];
    //     System.assertEquals(2, sTest.Track_Count__c);
    // }
}