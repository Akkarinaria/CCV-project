({
    
    /* init when click save button */
    handleCreateMix: function(component, event)
    {
        var mixObj = component.get("v.newMix");
        mixObj.Customer__c = null;
        
        // setting Customer__c field as value in v.selectedLookUpContact
		if (component.get("v.selectedLookUpContact").Id != undefined)
        {
            mixObj.Customer__c = component.get("v.selectedLookUpContact").Id;
        }
        
        /* Validation */
        component.set("v.showErrorBox", false);
        //remove error message from name input field
        var nameInput = component.find('mix');
        nameInput.setCustomValidity("");
        nameInput.reportValidity();
        //remove error message from customer input field
        component.set('v.showErrorCustomerMessage', false);
        component.set('v.showErrorNameMessage', false);
        component.set('v.showErrorTrackCountMessage', false);
        component.set('v.showErrorMixLengthMessage', false);
        component.set('v.showErrorSongLimitMessage', false);
        
        
        // checking mix name + customer inputs
        //if Mix Name AND Customer fields are bold, show error box
        // with Mix Name Error and Customer Error
        if(component.get("v.newMix.Name") == '' && mixObj.Customer__c == null)
        {
            component.set("v.showErrorBox", true);
            // show error message under input Name field
            var nameInput = component.find('mix');
            if (nameInput.checkValidity() == false)
            {
                //displays the error message
                nameInput.setCustomValidity("Error: You must enter a value");
                nameInput.reportValidity();
            }
            component.set('v.showErrorNameMessage', true);
            component.set('v.showErrorCustomerMessage', true);
        }
        //if Mix Name OR Customer field is bold, show error box
        // with Mix Name Error OR Customer Error
        else if(component.get("v.newMix.Name") == '' || mixObj.Customer__c == null)
        {
            component.set("v.showErrorBox", true);
            if(component.get("v.newMix.Name")=='') {
                var nameInput = component.find('mix');
                if (nameInput.checkValidity() == false)
                {
                    //displays the error message
                    nameInput.setCustomValidity("Error: You must enter a value");
                    nameInput.reportValidity();
                }
                component.set('v.showErrorNameMessage', true);
            }
            else if (mixObj.Customer__c == null)
            {
                component.set('v.showErrorCustomerMessage', true);
            }
            
        }
        // checking Track Count + Mix Length
        //if Track Count AND Mix Length are more, than they should be, show error box
        // with Track Count AND Mix Length Error
        else if (component.get("v.selectedCountFromEvent") > 20 && component.get("v.selectedLengthFromEvent") > 90)
        {
            component.set("v.showErrorBox", true);
            component.set('v.showErrorTrackCountMessage', true);
            component.set('v.showErrorMixLengthMessage', true);
        }
        //if Track Count OR Mix Length are more, than they should be, show error box
        // with Track Count OR Mix Length Error
        else if(component.get("v.selectedCountFromEvent") > 20 || component.get("v.selectedLengthFromEvent") > 90)
        {
            component.set("v.showErrorBox", true);
            if (component.get("v.selectedCountFromEvent") > 20)
            {
                component.set('v.showErrorTrackCountMessage', true);
            }
            else if(component.get("v.selectedLengthFromEvent") > 90)
            {
                component.set('v.showErrorMixLengthMessage', true);
            } 
        }
        // checking selected songs limits
        // if everything is OK, insert new mix
        else
        {
            var selectedSongs = component.get("v.selectedSongsListFromEvent");
            console.log('Selected Songs List: ');
        	console.log(selectedSongs);
            // array for songs, where Song Licences are over
            var overLicensesSongs = new Array();
            for (var i = 0; i < selectedSongs.length; i++)
            {
                if (selectedSongs[i].Track_Count__c >= selectedSongs[i].Track_Licenses__c)
                {
                    overLicensesSongs.push(selectedSongs[i]);
                }
            }
            console.log('Songs, where Song Licences are over:');
            console.log(overLicensesSongs);
            
            if(overLicensesSongs.length != 0)
            {
                component.set("v.showErrorBox", true);
                component.set('v.showErrorSongLimitMessage', true);
                component.set("v.listOfSongLimit", overLicensesSongs);
            }
            else
            {
                var saveMixAction = component.get("c.createMix");
                saveMixAction.setParams({
                    "mix": mixObj,
                    "selectedSongs": selectedSongs
                });
            
                // Configure the response handler for the action
                saveMixAction.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS") {
                        //alert('Mix saved');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "New Mix",
                            "message": "New Mix has been created successfully!"
                        });
                        toastEvent.fire();
                        
                        var mixId = response.getReturnValue();
                        // navigate to page of just created mix
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                           "recordId": mixId,
                           "slideDevName": "related"
                       });
                       navEvt.fire();
                    }
                    else if (state === "ERROR")
                    {
                        console.log('Problem saving mix, response state: ' + state);
                    }
                    else
                    {
                        console.log('Unknown problem, response state: ' + state);
                    }
                });
        
                // Send the request to create the new mix
                $A.enqueueAction(saveMixAction);
            }
        }
    },
    
    handleCloseMix : function(component, event) {
        //window.history.back();
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Mix__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSelectedSongsEvent : function(component, event) {
        var selectedSongs = event.getParam("selectedSongsList");
        component.set("v.selectedSongsListFromEvent", selectedSongs);
        var selectedSongsCount = event.getParam("selectedCount");
        component.set("v.selectedCountFromEvent", selectedSongsCount);
        var selectedSongsLength = event.getParam("selectedLength");
        component.set("v.selectedLengthFromEvent", selectedSongsLength);
    }
})