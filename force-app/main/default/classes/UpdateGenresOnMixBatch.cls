public class UpdateGenresOnMixBatch implements Database.Batchable<sObject>, Database.Stateful {
    public integer processedRecords = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator ([
            SELECT Id 
            FROM Mix__c
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Mix__c> mixList) {
        // List of mixes to update
        List<Mix__c> mixListToUpdate = new List<Mix__c>();

        String primGenre = ''; 
        String secondGenre = '';
        
        // for each mix
        for (Mix__c curMix : [SELECT Id, Name, Primary_Genre__c, Secondary_Genre__c FROM Mix__c	WHERE Id IN :mixList] ) {
            List<Id> songIdsFromMix = new List<Id>();
            List<String> allSongGernesFromMix = new List<String>();
            Set<String> uniqueGenresFromMix = new Set<String>();
            
            // get all songs from the mix (for each track)
            for (Track__c curTrack : [SELECT Id, Name, Mix__c, Song__c FROM Track__c WHERE Mix__c = :curMix.Id]) {
                songIdsFromMix.add(curTrack.Song__c);
            }

            // get all song genres for the mix
            for (Song__c curSong : [SELECT Genre__c FROM Song__c WHERE Id IN :songIdsFromMix]) {
                allSongGernesFromMix.add(curSong.Genre__c);
            }

            // identify unique genres
            for (String str : allSongGernesFromMix) {
                uniqueGenresFromMix.add(str);
            }

            // rewrite map <genre, count of songs> because of the same key in map
            // so we get unique keys (genres) with value of total number of usage
            Map<String, Integer> genreCountMap = new Map<String, Integer>();
            Map<String, Integer> secGenreCountMap = new Map<String, Integer>();
            
            if (!uniqueGenresFromMix.isEmpty()) {
                
                if (uniqueGenresFromMix.size() > 1) {

                    for (String u : uniqueGenresFromMix) {
                        Integer numInUnique = 0;
                        
                        for (Song__c allSongs : [SELECT Id, Genre__c FROM Song__c WHERE Id IN :songIdsFromMix]) {
                            
                            if (allSongs.Genre__c == u) {
                                numInUnique++;
                                // rewrite is here
                                genreCountMap.put(allSongs.Genre__c, numInUnique);
                            }
                        }
                    }
                    
                    // look for the highest number 1
                    Integer highestValue = 0;
                    for (Integer i : genreCountMap.values()) {
                        if (i > highestValue) {
                            highestValue = i;
                        }
                        
                    }
                    secGenreCountMap = genreCountMap.clone();

                    for (String k : genreCountMap.keySet()) {
                        if (genreCountMap.get(k) == highestValue) {
                            primGenre = k;
                            secGenreCountMap.remove(k);
                        }
                    }

                    
                    // look for the highest number 2
                    Integer highestValueSecond = 0;
                    for (Integer i : secGenreCountMap.values()) {
                        if (i > highestValueSecond) {
                            highestValue = i;
                        }
                        
                    }
                    for (String k : secGenreCountMap.keySet()) {
                        if (secGenreCountMap.get(k) == highestValueSecond) {
                            secondGenre = k;
                        }
                    }
                } 

                // if the only genre
                if (uniqueGenresFromMix.size() == 1) {
                    for (String u : uniqueGenresFromMix) {
                        primGenre = u;
                        secondGenre = '';
                    }
                }
            }

                curMix.Primary_Genre__c = primGenre;
                curMix.Secondary_Genre__c = secondGenre;
                mixListToUpdate.add(curMix);
        }

        try {
            database.saveresult[] ds =  Database.update(mixList,false);
                for(database.SaveResult d : ds){
                    if(d.issuccess()) {
                        processedRecords++;
                    }
                    
                }
            } catch(exception e) {
            System.debug('update failed');
        }

        update mixListToUpdate;
    }

    public void finish(Database.BatchableContext bc) {
        
        // send email about the job
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        AsyncApexJob apexJob = [
            SELECT Id, Status, NumberOfErrors, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id =: bc.getJobId()
        ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        List<String> toAddresses = new List<String>{'akkannteam@gmail.com'};

        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch UpgradeOpptyToActiveDialogue finished. Status: ' + apexJob.Status);
        mail.setPlainTextBody('The batch apex job processed.\nTotal job items: ' 
            + apexJob.TotalJobItems + '.\nBatches errors: ' + apexJob.NumberOfErrors
            + ' failures.\nTotat ' + processedRecords + ' records were processed.');

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        emailsToSend.addAll(emails);
        emailsToSend.add(mail);

        if (!Test.isRunningTest()) {
            Messaging.sendEmail(emailsToSend);
        }
    }


}