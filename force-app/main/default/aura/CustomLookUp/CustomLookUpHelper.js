({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    doInit : function(component, event, helper) {
        //first, i initialize any contact, not the right one
        // and then in update component controller (line 42) i pass the right value
        component.set("v.selectedRecord.Id", "0035g000003REwZAAW")
        var selectedRecord = component.get("v.selectedRecord");
        //searchText = event.getParam("defaultValue");
        if(!$A.util.isEmpty(selectedRecord )) {
            this.clearSelection(component, event, helper);
	
            var objectAPIName = component.get("v.objectAPIName");
           

            var action = component.get('c.getDefaultValue');

            action.setParams({
                recordId: selectedRecord.Id,
                ObjectName: objectAPIName
               
            });

            action.setCallback(this, function (a) {
                
                if (a.getState() === 'SUCCESS') {
                    console.log( a.getReturnValue());
                 		component.set("v.selectedRecord" , a.getReturnValue()); 
       
                    var forclose = component.find("lookup-pill");
                       $A.util.addClass(forclose, 'slds-show');
                       $A.util.removeClass(forclose, 'slds-hide');
              
                    var forclose = component.find("searchRes");
                       $A.util.addClass(forclose, 'slds-is-close');
                       $A.util.removeClass(forclose, 'slds-is-open');
                    
                    var lookUpTarget = component.find("lookupField");
                        $A.util.addClass(lookUpTarget, 'slds-hide');
                        $A.util.removeClass(lookUpTarget, 'slds-show');  
                } else if (a.getState() === "ERROR") {
					var errors = a.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							console.log("Error message: " +
								errors[0].message);
							var message = "Error message: " + errors[0].message;
							
						}
					} else {
						console.log('Unknown error');
						var message = 'Unknown error';
						
					}
				}
            });

            $A.enqueueAction(action);
        }
    },
    clearSelection : function(component, event, helper) {
          var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );   
    }
})