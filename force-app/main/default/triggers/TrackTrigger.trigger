trigger TrackTrigger on Track__c (after insert, after update, after delete, after undelete) {
    TrackTriggerHandler handler = new TrackTriggerHandler();

    if ((Trigger.isInsert)||(Trigger.isUndelete)) {
        handler.trackInsertedUndeletedDeleted(Trigger.NewMap);
    } 

    if (Trigger.isDelete) {
        handler.trackInsertedUndeletedDeleted(Trigger.OldMap);
    }

    if (Trigger.isUpdate) {
        handler.trackUpdated(Trigger.NewMap, Trigger.OldMap);
    }
}