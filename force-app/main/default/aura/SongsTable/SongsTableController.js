({
    
    doInit : function(component, event, helper)
    {
        helper.doInitHelper(component, event);
        helper.getPicklistValues(component, event);
    },
    
    // when picklist selection is changed
    handleOnChange : function(component, event, helper)
    {
        var genre = component.get("v.song.Genre__c");
        helper.doInitHelper(component, event);
        //current page should be 1 after changing genre
        component.set("v.currentPage", 1);
    },
 
    // navigation method for pagination
    navigation: function(component, event, helper)
    {
        var songsList = component.get("v.listOfAllSongs");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var totalPagesCount = component.get("v.totalPagesCount");
        var whichBtn = event.getSource().get("v.name");
        
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next')
        {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, songsList, end, start, pageSize);
        }
        
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous')
        {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, songsList, end, start, pageSize);
        }
        
        // check if whichBtn value is 'first' then call 'first' helper method
        else if (whichBtn == 'first')
        {
            component.set("v.currentPage", 1);
            helper.first(component, event, songsList, end, start, pageSize);    
        }
        
        // check if whichBtn value is 'last' then call 'last' helper method
        else if (whichBtn == 'last')
        {
            component.set("v.currentPage", totalPagesCount);
            helper.last(component, event, songsList, end, start, pageSize, totalPagesCount);    
        }
    },
 
    // when header checkbox for select all is changed
    selectAllCheckbox : function(component, event, helper)
    {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllSongs = component.get("v.listOfAllSongs");
        var PaginationList = component.get("v.PaginationList");
        var songsLength = 0;
        // play a for loop on all songs list 
        for (var i = 0; i < listOfAllSongs.length; i++)
        {
            // check if header checkbox is 'true'
            // then update all checkboxes with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true)
            {
                listOfAllSongs[i].isChecked = true;
                // calculating sum length of selected songs 
                songsLength = songsLength + listOfAllSongs[i].objSong.Length_m__c;
                component.set("v.selectedCount", listOfAllSongs.length);
            }
            else
            {
                listOfAllSongs[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllSongs[i]);
        }

        // rounding and setting the value of sum songs length
        var rounded = function(number)
        {
    		return +number.toFixed(1);
		}
        component.set("v.selectedLength", rounded(songsLength));

        // update the checkbox for 'PaginationList' based on header checkbox 
        for (var i = 0; i < PaginationList.length; i++)
        {
            if (selectedHeaderCheck == true)
            {
                PaginationList[i].isChecked = true;
            }
            else
            {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfAllSongs", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
        
        // getting selected songs and setting the list of selected songs
        var selectedSongsList = new Array();      
        for (var i = 0; i < listOfAllSongs.length; i++)
        {
            if (listOfAllSongs[i].isChecked)
            {
                console.log(listOfAllSongs[i].objSong);
                selectedSongsList.push(listOfAllSongs[i].objSong);
            }
        }
        console.log('Selected Songs List: ')
        console.log(selectedSongsList);
		component.set("v.selectedSongsList", selectedSongsList);
        
        helper.passSelectedSongsEvent(component, event);
        helper.changeColorSpan(component, event);
        helper.showStatusMessage(component, event);
    },

    //when checkboxes are changed
    checkboxSelect: function(component, event, helper)
    {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true)
        {
            getSelectedNumber++;
        }
        else
        {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);

        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount"))
        {
            component.find("selectAllId").set("v.value", true);
        }

        // calculating sum length of selected songs and
        // getting selected songs
        var songsLength = 0;
        var selectedSongsList = new Array();
        var listOfAllSongs = component.get("v.listOfAllSongs");
        for (var i = 0; i < listOfAllSongs.length; i++)
        {
            if (listOfAllSongs[i].isChecked)
            {
                songsLength = songsLength + listOfAllSongs[i].objSong.Length_m__c;
                selectedSongsList.push(listOfAllSongs[i].objSong);
            }
        }
        var rounded = function(number){
    		return +number.toFixed(1);
		}
        component.set("v.selectedLength", rounded(songsLength));
		component.set("v.selectedSongsList", selectedSongsList);
        console.log('Selected Songs List: ');
        console.log(selectedSongsList);

        
        
        helper.passSelectedSongsEvent(component, event);
        helper.changeColorSpan(component, event);
        helper.showStatusMessage(component, event);

    },

})