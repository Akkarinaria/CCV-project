public class NewMixController {
	@AuraEnabled
    public static Id createMix(Mix__c mix, List<Song__c> selectedSongs)
    {
        insert mix;
        
        List<Track__c> newTracks = new List<Track__c>();
        
        for (Song__c song : selectedSongs)
        {
            newTracks.add(new Track__c(Song__c = song.Id, Mix__c = mix.Id));
        }

        insert newTracks;
        return mix.Id;
    }
    
    //returns all list views for the mix object
    @AuraEnabled
	public static List<ListView> getListViews() {
        List<ListView> listviews = [SELECT Id, Name
                                    FROM ListView
                                    WHERE SobjectType = 'Mix__c'];
        return listviews;
    }
}