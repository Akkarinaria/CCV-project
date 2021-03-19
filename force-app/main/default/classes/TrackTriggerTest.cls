@isTest
private class TrackTriggerTest {
    
    @TestSetup
    static void setup() {
        List<Song__c> songs = new List<Song__c>();
        List<Track__c> tracks = new List<Track__c>();
        List<Mix__c> mixes =new List<Mix__c>();
        
        // insert mix
        Mix__c mix0 = new Mix__c(Name = 'The_Mix0', Primary_Genre__c = '', Secondary_Genre__c = '');
        Mix__c mix1 = new Mix__c(Name = 'The_Mix1', Primary_Genre__c = 'Dance Music');
        Mix__c mix2 = new Mix__c(Name = 'The_Mix2', Primary_Genre__c = '', Secondary_Genre__c = 'Blues');
        Mix__c mix3 = new Mix__c(Name = 'The_Mix3', Secondary_Genre__c = 'Blues');
        Mix__c mix4 = new Mix__c(Name = 'The_Mix4');

        mixes.add(mix0);
        mixes.add(mix1);
        mixes.add(mix2);
        mixes.add(mix3);
        mixes.add(mix4);

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

        // insert track for song3 for mix2
        Song__c ss = [SELECT Id FROM Song__c WHERE Name = 'Song3'];
        Mix__c mm = [SELECT Id FROM Mix__c WHERE Name = 'The_Mix2'];
        tracks.add(new Track__c (Song__c = ss.Id,
                                 Mix__c = mm.Id));

        insert tracks;
    }

    // tests from genres
    @isTest static void testInsertTracksCheckPrimaryGenre() {
        Test.startTest();
        Mix__c primGenre0 = [SELECT Primary_Genre__c FROM Mix__c WHERE Name = 'The_Mix0'];
        Mix__c primGenre1 = [SELECT Primary_Genre__c FROM Mix__c WHERE Name = 'The_Mix1'];
        Test.stopTest();

        //System.debug('primGenre0 -------- ' + primGenre0 + ' primGenre1 =========== ' + primGenre1);

        System.assertEquals(primGenre1.Primary_Genre__c, primGenre0.Primary_Genre__c);
    }

    // secondary genre to null when only 1 track 
    @isTest static void testInsertOneTrack() {
        Test.startTest();
        Mix__c mixCheck2 = [SELECT Primary_Genre__c, Secondary_Genre__c FROM Mix__c WHERE Name = 'The_Mix2'];
        Test.stopTest();
        
        System.assertEquals(null, mixCheck2.Secondary_Genre__c);
    }

    // test secondary genre 
    @isTest static void testInsertTracksCheckSecondaryGenre() {
        Test.startTest();
        Mix__c secGenre0 = [SELECT Id, Name, Primary_Genre__c, Secondary_Genre__c FROM Mix__c WHERE Name = 'The_Mix0'];
        Mix__c mixCheck3 = [SELECT Id, Name, Primary_Genre__c, Secondary_Genre__c FROM Mix__c WHERE Name = 'The_Mix3'];
        Test.stopTest();

        //System.debug('mix0 -------- ' + secGenre0 + ' mix3 =========== ' + mixCheck3);
        System.assertEquals(mixCheck3.Secondary_Genre__c, secGenre0.Secondary_Genre__c);
        
    }

    // test mix length error
    @isTest static void testInsertLongSong() {
        Song__c longSong = new Song__c(
            Name = 'LongSong',
            Artist__c = 'Artist',
            Genre__c = 'Dance Music',
            Length_m__c = 100,
            Track_Licenses__c = 3
        );
        insert longSong;

        try {
            Track__c trackLongSong = new Track__c(Song__c = longSong.Id, Mix__c = [SELECT Id FROM Mix__c WHERE Name = 'The_Mix2'].Id);
            insert trackLongSong;
        }
        catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('This song will exceed the Mix length limit.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }

    // test license error
    @isTest static void testInsertExpiredLicenseSong() {
        Song__c expiredLicenseSong = new Song__c(
            Name = 'ExpiredSong',
            Artist__c = 'Artist',
            Genre__c = 'Dance Music',
            Length_m__c = 1,
            Track_Count__c = 1,
            Track_Licenses__c = 1
        );
        insert expiredLicenseSong;

        try {
            Track__c trackExpiredLicenseSong = new Track__c(Song__c = expiredLicenseSong.Id, Mix__c = [SELECT Id FROM Mix__c WHERE Name = 'The_Mix2'].Id);
            insert trackExpiredLicenseSong;
        }
        catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Song usage limit reached.\nPlease choose another song.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }

    // tests from song
    @isTest static void testInsertTracks() {
        Test.startTest();
        List<Track__c> tList = [
            SELECT Id
            FROM Track__c 
        ];
        Test.stopTest();

        System.assertEquals(4, tList.size());
    }

    @isTest static void testDeleteTracks() {
        Test.startTest();
        Track__c t = [
            SELECT Id
            FROM Track__c
            LIMIT 1
        ];
        Database.DeleteREsult result = Database.delete(t, true);
        Test.stopTest();

        System.assertNotEquals(null, [
            SELECT Track_Count__c
            FROM Song__c
        ]);
    }

    @isTest static void testUpdateTracks() {
        Test.startTest();
        Song__c s1 = [
            SELECT Id
            FROM Song__c
            WHERE Name = 'Song1'
            LIMIT 1
        ];
        Track__c t = [
            SELECT Id
            FROM Track__c
            WHERE Song__c = :s1.Id
            LIMIT 1 
        ];
        Song__c s2 = [
            SELECT Id
            FROM Song__c
            WHERE Name = 'Song2'
            LIMIT 1
        ];

        t.Song__c = s2.Id;

        Database.SaveResult result = Database.update(t, true);
        Test.stopTest();

        Song__c sTest = [
            SELECT Track_Count__c
            FROM Song__c
            WHERE Name = 'Song2'
            LIMIT 1
        ];
        System.assertEquals(2, sTest.Track_Count__c);
    }
}