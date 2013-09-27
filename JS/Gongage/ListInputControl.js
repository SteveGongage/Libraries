// ***********************************************************************************
// Purpose: 	Provides a simple way of adding values to a list using a text input
//			 	and storing the values in a hidden field as well as displaying a 
//				list of items to the user.
// Created By:	Steve Gongage (6/1/2013)
// Usage:		var myListControl = new ListInputControl('myPrefix');
//
// ***********************************************************************************


var ListInputControl = (
	function () {		
		//++++++++++++++++++++++++++++++++++++++++
		// Modify these variables to customize this control 
		var closeHTML	= '<span class="close">&times;</span>';
		
		
		//----------------------------------------
		// Other variables.  Do not change these.
		var items			= {};
		var lastItemID		= -1;
		var fields			= {					
			input			: null
			, hiddenOutput	: null
			, displayOutput	: null
		};


		// ------------------------------------------------------------
		// Public: addToList
		var addToList = function(textIn) {
			// New list item
			var listItem = {
				text 		: fields.input.value.trim()
				, label		: fields.input.value.trim()
				, itemID	: 'listItem_'+ ++lastItemID
				, domObj 	: null
				
			};
			// if the textIn argument has been supplied, use it instead.
			if (typeof(textIn) != 'undefined') { 
				listItem.text = textIn;
			}
			// remove the special character "|"
			listItem.text 	= listItem.text.replace('|', '', 'g');
			listItem.label	= listItem.text;
			if (listItem.label.split(':').length == 2) {
				// If there is a colon in the text, we want to show the last part (the label), not the first part (the ID).
				listItem.label 	= listItem.label.split(':')[1];
			}
			
			/* Does this exist? */
			var isAlreadyInList = false;
			jQuery.each(items, function(key, value) {
				if (value.text == listItem.text) {
					isAlreadyInList = true;
				}
			});
			
			// If this doesn't already exist or is not blank
			if (!isAlreadyInList && listItem.text != '') {
				
				outputListItem(listItem, this);
				items[listItem.itemID] = listItem; // Save this item in memory
				updateListInput();

			}
			
			// Clear out the text entry field
			jQuery(fields.input).val(null);
					
		};
		
		// ------------------------------------------------------------
		// Public: removeFromList
		var removeFromList = function(itemID) {

			if (items[itemID]) {
				jQuery(items[itemID].domObj).remove();
				delete items[itemID];
			}

			updateListInput();
		};
		
		// ------------------------------------------------------------
		// Private: outputListItem
		var outputListItem = function (listItem, thisObj) {
			listItem.domObj 			= document.createElement('li');
			listItem.domObj.id 			= listItem.itemID;
			listItem.domObj.innerHTML 	= '<a href="javascript: void(0);" class="btn">'+ closeHTML + listItem.label +'</a>';
			listItem.domObj.onclick 	= (function(obj, listItem) { 
				return function() { 
					obj.removeFromList(listItem.itemID);
				}
			}) (thisObj, listItem);

			
			fields.displayOutput.appendChild(listItem.domObj);
		}

		// ------------------------------------------------------------
		// Private: outputListItem
		var updateListInput = function() {
			var outputList = '';

			jQuery.each(items, function(key, value) {			
				outputList += value.text +'|';
			});

			if (outputList.length > 0) {  
				outputList = outputList.slice(0, outputList.length - 1); // Remove the last delimiter
			}
			
			jQuery(fields.hiddenOutput).val(outputList);

		};


		// ------------------------------------------------------------
		// Constructor 
		Constr = function(namePrefix) {
			this.addToList 		= addToList;
			this.removeFromList = removeFromList;

			fields = {				
				input			: jQuery('#'+ namePrefix +'_input')[0]
				, hiddenOutput	: jQuery('#'+ namePrefix)[0]
				, displayOutput	: jQuery('#'+ namePrefix +'_tagOutput')[0]
			}
			
		}


		return Constr;

	}
)();

