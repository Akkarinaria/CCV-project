({

    doInitHelper : function(component, event)
    { 
        // getting List<songListWrapper> from apex controller method fetchSongWrapper
        var action = component.get("c.fetchSongWrapper");
        // passing value of genre from picklist filter to apex controller 
        var genre = component.get("v.song.Genre__c");
        action.setParams({ searchGenre : genre });
        // set a callBack
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                if (result.length > 0)
                {
                    component.set("v.noRecordsFound", false);
                    component.set("v.listOfAllSongs", result);
                    var pageSize = component.get("v.pageSize");
                    var totalSongsList = result;
                    var totalLength = totalSongsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage", 0);
                    component.set("v.endPage", pageSize - 1);
                    
                    var PaginationList = [];
                    for (var i = 0; i < pageSize; i++)
                    {
                        if(component.get("v.listOfAllSongs").length > i)
                        {
                            PaginationList.push(result[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationList);
                    
                    //if after changing genre we've got minus remaining Tracks or Length
                    // remove span-red class from
                    if (component.get("v.selectedCount") > 20) 
                    {
                        var changeColorSpan = component.find('remainingTracks');
            			$A.util.removeClass(changeColorSpan, 'span-red');
                    }
                    
                    if (component.get("v.selectedLength") > 90) 
                    {
                        var changeColorSpan = component.find('remainingLength');
            			$A.util.removeClass(changeColorSpan, 'span-red');
                    }
                    
                    //setting Track Count and Length to null
                    component.set("v.selectedCount" , 0);
                    component.set("v.selectedLength", 0);
 
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));    
                }
                else
                {
                    // if there is no records then display message
                    component.set("v.noRecordsFound" , true);
                } 
            }
            else
            {
                alert('Error...');
            }
        });
        // enqueue the Action
        $A.enqueueAction(action);  
    },
    
    // navigate to next pagination record set   
    next : function(component, event, SongsList, end, start, pageSize)
    {
        var Paginationlist = [];
        var counter = 0;
        for (var i = end + 1; i < end + pageSize + 1; i++)
        {
            if (SongsList.length > i)
            { 
                if (component.find("selectAllId").get("v.value"))
                {
                    Paginationlist.push(SongsList[i]);
                }
                else
                {
                    Paginationlist.push(SongsList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
    },
    
   	// navigate to previous pagination record set   
    previous : function(component, event, SongsList, end, start, pageSize)
    {
        var Paginationlist = [];
        var counter = 0;
        for (var i = start - pageSize; i < start ; i++)
        {
            if (i > -1)
            {
                if (component.find("selectAllId").get("v.value"))
                {
                    Paginationlist.push(SongsList[i]);
                }
                else
                {
                    Paginationlist.push(SongsList[i]); 
                }
                counter++;
            }
            else
            {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    // navigate to first pagination record set   
	first : function(component, event, SongsList, end, start, pageSize)
    {
        var Paginationlist = [];
        for(var i = 0; i < pageSize; i++)
        {
            if (component.get("v.listOfAllSongs").length > i)
            {
                Paginationlist.push(SongsList[i]);
            }
        }
        component.set("v.startPage", 0);
        component.set("v.endPage", pageSize - 1);
        component.set('v.PaginationList', Paginationlist);
    },
    
    // navigate to last pagination record set   
	last : function(component, event, SongsList, end, start, pageSize, totalPagesCount)
    {
        var Paginationlist = [];
        start = (totalPagesCount - 1) * pageSize;
        end = totalPagesCount * pageSize - 1;
        
        for (var i = start; i < end + 1; i++)
        {
            if (SongsList.length > i)
            { 
                if (component.find("selectAllId").get("v.value"))
                {
                    Paginationlist.push(SongsList[i]);
                }
                else
                {
                    Paginationlist.push(SongsList[i]);  
                }
            }
        }
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    // getting picklist values from apex controller method getGenreFieldValues
    getPicklistValues : function(component, event)
    {
        var action = component.get("c.getGenreFieldValue");
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for (var key in result)
                {
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    // change color remaining tracks and length values
    changeColorSpan : function(component, event)
    {
        // adding and removing red color for span tag with span-red class
		// when Track Count is more then 20
        if (component.get("v.selectedCount") > 20)
        {
            var changeColorSpan = component.find('remainingTracks');
        	$A.util.addClass(changeColorSpan, 'span-red');
        }
        else
        {
            var changeColorSpan = component.find('remainingTracks');
            $A.util.removeClass(changeColorSpan, 'span-red');
        }
        
        // adding and removing red color for span tag with span-red class
		// when Mix Length is more than 90
        if (component.get("v.selectedLength") > 90)
        {
            var changeColorSpan = component.find('remainingLength');
        	$A.util.addClass(changeColorSpan, 'span-red');
        }
        else
        {
            var changeColorSpan = component.find('remainingLength');
            $A.util.removeClass(changeColorSpan, 'span-red');
        }
    },
    
    //status message is shown for 1,5s when summary stats are being updated
    showStatusMessage : function(component, event)
    {
        component.set("v.showUpdateSummaryMessage", true);
        setTimeout($A.getCallback(function() {
            component.set("v.showUpdateSummaryMessage", false);
        }), 1500);
    },
    
    // passing the selected songs list value to parent component (NewMix)
    passSelectedSongsEvent : function(component, event)
    {
        var selectedSongsEvent = component.getEvent("selectedSongsEvent");
        selectedSongsEvent.setParams({
            "selectedSongsList" : component.get("v.selectedSongsList"),
            "selectedCount" : component.get("v.selectedCount"),
            "selectedLength" : component.get("v.selectedLength")
        });
        selectedSongsEvent.fire();
    }
    
    
    
})