trigger SongTrigger on Song__c (before delete) {
    SongTriggerHandler handler = new SongTriggerHandler();
    handler.searchTracks(Trigger.New);
}