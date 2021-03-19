public class UpdateTrackCountOnSongBatch implements Database.Batchable<sObject>, Database.Stateful {
    public integer processedRecords = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('HEEEEEEEEEEEEEEEEELP____START');
        
        return Database.getQueryLocator ([
            SELECT Id 
            FROM Song__c
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Song__c> songList) {
        System.debug('HEEEEEEEEEEEEEEEEELP____EXECUTE');
        List<Song__c> songTrackCount = [
            SELECT Track_Count__c, (SELECT Id FROM Tracks__r)
            FROM Song__c
            WHERE Id IN :songList
        ];

        for (Song__c s : songTrackCount) {
            s.Track_Count__c = s.Tracks__r.size();
        }
        update songTrackCount;


        /////////////////////////////
        // for (Song__c s : [SELECT Id, Track_Count__c, (SELECT Id FROM Tracks__r) FROM Song__c WHERE Id = :songList]) {
        //     s.Track_Count__c = s.Tracks__r.size();
        //     System.debug('s.Track_Count__c ----------> ' + s.Track_Count__c);
        //     System.debug('s.Tracks__r.size() ----------> ' + s.Tracks__r.size());
        // }



        try {
            database.saveresult[] ds =  Database.update(songList,false);
                for(database.SaveResult d : ds){
                    if(d.issuccess()) {
                        processedRecords++;
                    }
                    
                }
            } catch(exception e) {
            System.debug('update failed');
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('HEEEEEEEEEEEEEEEEELP____FINISH');
        
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