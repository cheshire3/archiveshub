
var recid = 'notSet';
var idExists = null;
var currentForm = 'collectionLevel';
var previousForm = null;
var accessPoints = new Array("subject", "persname", "famname", "corpname", "geogname", "title", "genreform", "function");
var someIdSet = false;
var countryCode = null;
var repositoryCode = null;
var baseUnitId = null;
var fileName = null;
var fileOwner = null;
var timeout;

function setCountryCode(code){
	if (countryCode == null){
		countryCode = code;
	}
}


function setRepositoryCode(code){
	if (repositoryCode == null){
		repositoryCode = code;
	}
}


function setBaseUnitId(id){
	if (baseUnitId == null){
		baseUnitId = id;
	}
}


function setOwner(owner){
	if (fileOwner == null){
		fileOwner = owner;
	}
}


function setRecid(){
	if (document.getElementById('recid') != null && document.getElementById('recid') != 'notSet'){
		recid = document.getElementById('recid').value;
	}
}


/* basic user operations: submit, delete etc. */

function deleteFromStore(){

	var recid = null;
	if (!document.getElementById('storeDirForm').recid){
		return;
	}
	if (document.getElementById('storeDirForm').recid.length){
		for (var i=0; i < document.getElementById('storeDirForm').recid.length; i++) {
			if (document.getElementById('storeDirForm').recid[i].checked) {
		      	recid = document.getElementById('storeDirForm').recid[i].value;
		    }
		}
	}
	else {
		if (document.getElementById('storeDirForm').recid.checked) {
			recid = document.getElementById('storeDirForm').recid.value;
		}
	}
	
	if (recid == null) {
		return;
	}
	else {
		var ok = confirmOp('You are about to delete ' + recid.split('-')[0] + ' from the editing store. All changes made since it was last submitted to the database will be lost.\nAre you sure you want to continue?')
		if (ok){
			deleteRec(recid);
		}
		else {
			return;
		}
	}
}

function deleteRec(id){
	var url = '/ead/edit/';
	var data = 'operation=delete&recid=' + id;
	var ajax = new Ajax.Request(url, {method:'post', asynchronous:false, postBody:data, evalScripts:true, onSuccess: function(transport) {	
		location.href="";		    
	}});		
}

function discardRec(id){
	var url = '/ead/edit/';
	var data = 'operation=discard&recid=' + id;
    if ($('owner') != null){    
    	setOwner($('owner').value);
    }	
	if (fileOwner != null){
		data += '&owner=' + fileOwner;
	}
	var ajax = new Ajax.Request(url, {method:'post', asynchronous:false, postBody:data, evalScripts:true, onSuccess: function(transport) {	
		location.href="";		    
	}});		
}


function submit(index){
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title')
		return;
	}
	if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false)
    }
	errors = document.getElementsByClassName('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before submitting. Errors will be marked with red shading in the text box.');
    	return;
    }
    
    //check the daoform details
    var daoform = document.getElementById('digitalobjectsform');
    var type = daoform.className;
    if (daoform){
    	var inputs = daoform.getElementsByTagName('input');
    	if (type == 'embed' || type == 'singlefile'){
    		if (inputs[0].value.strip() == '' && (inputs[1].value.strip() != '' || inputs[2].value.strip() != '')){
    			var confirmbox = confirm('The File URI value required for the digital object has not been completed. If you choose to proceed with this operation the digital object will not be included and the current details in the form will be lost.\n\nDo you want to continue?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				inputs[1].value = '';
    				inputs[2].value = '';
    			}
    		}

    	}
    	else if (type == 'thumb') {
    		if ((inputs[0].value.strip() == '' || inputs[1].value.strip() == '') && (inputs[2].value.strip() != '' || inputs[3].value.strip() != '')){   			
    			var confirmbox = confirm('The Thumbnail URI and/or File URI value required for the digital object has not been completed. If you choose to proceed with this operation the digital object will not be included and the current details in the form will be lost.\n\nDo you want to continue?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				inputs[0].value = '';
    				inputs[1].value = '';
    				inputs[2].value = '';
    				inputs[3].value = '';
    			}
    		} 		
    	}
    	else if (type == 'multiple'){
    		var length = inputs.length;
    		var number = (length-1)/3;
    		var problems = false;
    		var list = new Array();
    		for (var i = number; i < length-1; i+=2){
				if (inputs[i].value.strip() == '' && (inputs[i+1].value.strip() != '' || inputs[length-1].value.strip() != '')){
					list[list.length] = i;
					problems = true;
				}
    		}
    		if (problems == true){
    			var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you choose to proceed with this operation any incomplete URIs will not be included and the remaining incomplete details in the form will be lost.\n\nDo you want to continue?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				for (var j = 0; j < list.length; j++){
    					inputs[list[j]+1].value = '';
    				}
					if (list.length == number){
						inputs[length-1].value = '';
					}
    			}
    		}
    		
    	}
    }   
    
	saveForm(false);
	
	//validate whole record
	invalid = document.getElementsByClassName('invalid');
	if (invalid.length != 0){
		alert('Not all components of your record have the required fields completed. Please complete any components which are coloured red in the contents tree.');
		return;
	}
	
	url = "?operation=submit&recid=" + recid;
	if (fileOwner != null){
		url += '&owner=' + fileOwner;
	}
	if (fileName != null){
		url += '&filename=' + fileName;
	}
	if (index == false || index == 'false'){
		url += '&index=false';
	}
    location.href= url;
}


function resetForm(){
    if (recid == 'notSet'){
    	var data = 'operation=reset';
    	var loc = $('rightcol');
		new Ajax.Updater(loc, '/ead/edit', {method: 'get', asynchronous:false, parameters:data, evalScripts:true});	
		updateTitle(null);    	
    }
    //if there is a recid (the form has a saved version in the editing store) show the saved version
    else {
    	var form = $('eadForm');
    	var data = 'operation=navigate&recid=' + recid + '&newForm=' + currentForm; 
    	if (fileOwner != null){
    		data += '&owner=' + fileOwner;
    	}
    	if ($('ctype')){
    		data += '&ctype=' + ($('ctype')).value;
    	}
    	var loc = $('rightcol');
		new Ajax.Updater(loc, '/ead/edit', {method: 'get', asynchronous:false, parameters:data, evalScripts:true});	
		updateTitle(null);
    }
}


function save(){
	var body = document.getElementsByTagName('body')[0];
	body.className = 'waiting';
	//validate and check id existence etc.
    if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title');
		body.className = 'none';
		return;
	}
	var errors = document.getElementsByClassName('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before saving. Errors will be marked with red shading in the text box.');
    	body.className = 'none';
    	return;
    }
    //check the daoform details
    var daoform = document.getElementById('digitalobjectsform');
    var type = daoform.className;
    if (daoform){
    	var inputs = daoform.getElementsByTagName('input');
    	if (type == 'embed' || type == 'singlefile'){
    		if (inputs[0].value.strip() == '' && (inputs[1].value.strip() != '' || inputs[2].value.strip() != '')){
    			var confirmbox = confirm('The File URI value required for the digital object has not been completed. If you choose to proceed with saving this file the digital object will not be included and the current details in the form will be lost.\n\nDo you want to continue saving this file?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				inputs[1].value = '';
    				inputs[2].value = '';
    			}
    		}

    	}
    	else if (type == 'thumb') {
    		if ((inputs[0].value.strip() == '' || inputs[1].value.strip() == '') && (inputs[2].value.strip() != '' || inputs[3].value.strip() != '')){   			
    			var confirmbox = confirm('The Thumbnail URI and/or File URI value required for the digital object has not been completed. If you choose to proceed with saving this file the digital object will not be included and the current details in the form will be lost.\n\nDo you want to continue saving this file?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				inputs[0].value = '';
    				inputs[1].value = '';
    				inputs[2].value = '';
    				inputs[3].value = '';
    			}
    		} 		
    	}
    	else if (type == 'multiple'){
    		var length = inputs.length;
    		var number = (length-1)/3;
    		var problems = false;
    		var list = new Array();
    		for (var i = number; i < length-1; i+=2){
				if (inputs[i].value.strip() == '' && (inputs[i+1].value.strip() != '' || inputs[length-1].value.strip() != '')){
					list[list.length] = i;
					problems = true;
				}
    		}
    		if (problems == true){
    			var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you choose to proceed with saving this file any incomplete URIs will not be included and the remaining incomplete details in the form will be lost.\n\nDo you want to continue saving this file?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				for (var j = 0; j < list.length; j++){
    					inputs[list[j]+1].value = '';
    				}
					if (list.length == number){
						inputs[length-1].value = '';
					}
    			}
    		}
    		
    	}
    }

	saveForm(false);
	body.className = 'none';
    alert('This form is now saved as ' + recid + ' and can be reloaded from the admin menu for further editing at a later date.');
	
	
}


function saveForm(asynch){
	
	//collect the basic id information
	if (currentForm == 'collectionLevel'){
		setCountryCode($('countrycode').value);
	    setRepositoryCode($('archoncode').value);
	    setBaseUnitId($('unitid').value);
	    if ($('owner') != null){    
	    	setOwner($('owner').value);
	    }
	}
	// if this record has a recid (i.e. is already saved in the editing store) get its recid if we don't have it already
	if (currentForm == 'collectionLevel' && recid=='notSet'){
		if (document.getElementById('recid') != 'notSet'){
	    	recid = document.getElementById('recid').value;
	    }	    		
	}
	// gets filename if it is set in the form 
	if(currentForm == 'collectionLevel' && fileName == null){
		if (document.getElementById('filename') != null){
			fileName = document.getElementById('filename').value;
		}
	}
  	var data = ($('eadForm')).serialize();
  	data += ('&operation=save&location=' + currentForm);
  	previousForm = currentForm
  	if (currentForm != 'collectionLevel'){	  			
  		var parent = $(currentForm).parentNode.parentNode.parentNode;	  		
  		if (parent.tagName != 'LI'){
  			var parentId = 'collectionLevel';
  		}
  		else {
  			var linkParent = parent.childNodes[0];
  			parentId = parent.childNodes[1].id;
  		}	  	
  		data += ('&parent=' + parentId);
  	}   
  	else {
  		$('countrycode').readOnly = true;
  		$('archoncode').readOnly = true;
  		$('unitid').readOnly = true;
  	}	
    if (recid != null && recid != 'notSet'){
    	data += '&recid=' + recid;
    }
    else {
    	recid = ($('pui')).value;
    }
    if (fileOwner != null){
    	data += '&owner=' + fileOwner;
    }
    var loc = $('rightcol');
  	var ajax = new Ajax.Request(loc, {method:'post', asynchronous:asynch, postBody:data, evalScripts:true,  onSuccess: function(transport){ 
    	var response = transport.responseText;
	    var rid = response.substring(7,response.indexOf('</recid>'));	
	    var valid = response.substring(response.indexOf('<valid>')+7, response.indexOf('</valid>'));
		if (valid == 'False'){
			($(previousForm)).className = 'invalid';
		}
		else{
			($(previousForm)).className = 'valid';
		}
	}});	
}


function displayForm(id, level){
	/* for adding a new form */
	if (id == 'new'){
		var data = 'operation=add&recid=' + recid + '&clevel=' + level;
		var loc = $('rightcol');		
	   	new Ajax.Updater(loc, '/ead/edit/', {method: 'post', asynchronous:false, parameters:data, evalScripts:true});

	   	($('countrycode').value) = countryCode;	   			
	   	($('archoncode').value) = repositoryCode;
	   	($('unitid').value) = baseUnitId + '/' + currentForm.replace(/-/g, '/');
	   	($('pui').value) = recid
	   	updateId();
	}
	/* for navigating to an existing form*/
	else {	 
		if (!checkRequiredData()){
			alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title');
			return;
		} 	
		errors = document.getElementsByClassName('menuFieldError');
	    if (errors.length != 0){
	    	alert('Please fix the errors in the xml before leaving this page. Errors will be marked with red shading in the text box.');
	    	return;
	    }
	  	saveForm(false);
		var data = 'operation=navigate&recid=' + recid + '&newForm=' + id;
		if (fileOwner != null){
			data += '&owner=' + fileOwner;
		}
		var loc = $('rightcol');
		new Ajax.Updater(loc, '/ead/edit', {method: 'get', asynchronous:false, parameters:data, evalScripts:true, onSuccess: function(transport){		   	
			
			($(currentForm)).style.background = 'none';
		    currentForm = id;
		    ($(currentForm)).style.background = 'yellow';		    
		}});	    		  	 	  	
  	}
}


function addComponent(){	
    // check it does not exceed the c12 limit 
    if (currentForm != 'collectionLevel'){
     	var parent = document.getElementById(currentForm);    
      	var listItem = parent.parentNode;
      	var level = Number(listItem.parentNode.getAttribute('name'));
      	if (level == 12){
      		alert('You cannot add any more component levels to this description');
      		return;
      	}
    }
   
    //validate and check id existence etc.
    if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title')
		return;
	}
    if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false)
    }
    errors = document.getElementsByClassName('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before adding a component. Errors will be marked with red shading in the text box.');
    	return;
    }
    else if (currentForm == 'collectionLevel' && recid == 'notSet'){
		var url = '/ead/edit'
		var data = 'operation=checkId&id=' + ($('pui')).value + '&store=recordStore';
		new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 	    				
			var response = transport.responseText;
			var idExists = response.substring(7,response.indexOf('</value>')); 			 
	 	}});
	 	if (idExists == 'true'){
   				alert('A record with this ID already exists in this database\nyou must supply a unique id before proceeding');
   				return;
   		}   
	}
	if (currentForm == 'collectionLevel' && recid == 'notSet' && document.getElementById('recid') == 'notSet'){
		var url = '/ead/edit'
		var data = 'operation=checkId&id=' + ($('pui')).value + '&store=editStore';
		new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 	    				
			var response = transport.responseText;
			var idExists = response.substring(7,response.indexOf('</value>'));
   			if (idExists == 'true'){
   				var cont = confirmOp('A record with this ID already exists within the editing store which means it has either been loaded for editing or is in the process of being created by you or another user and has not yet been submitted to the main database. If you continue you will overwrite this record and it will be lost \n\n Are you sure you want to continue? ');
   				if (!cont){
					return;
				} 	
   			}     			
	 	}});
	}   	
	
	//update the menu bar first
    if (currentForm == 'collectionLevel'){	    	
      	var parent = document.getElementById('collectionLevel');
      	var level = 0;
      	var listItem = document.getElementById('treeDiv');
    } 
    else {  
      	var parent = document.getElementById(currentForm);    
      	var listItem = parent.parentNode;
      	var level = Number(listItem.parentNode.getAttribute('name'));
    }
	parent.style.background = 'none';

	//setAttribute('style', 'background:none');

    
    // find the right list or add a new one
    var childList = null;  
    childList = listItem.childNodes;
    var list = null;
    if (childList != null){
      	for(var i=0; i<childList.length; i++){
        	if (childList[i].tagName == 'UL'){
          		list = childList[i];
        	}
      	}
    }
    if (list == null){
      	list = document.createElement('ul');
      	list.setAttribute('name', (level + 1));
      	list.className =  'hierarchy';
      	if (someIdSet == false){
      		if (document.getElementById('someId')){
      			someIdSet = true;
      		}
      		else {
      			list.setAttribute('id', 'someId');
      			someIdSet = true;
      		}
      	}
      	listItem.appendChild(list);
    }  

    // create the linkId
    var linkId = '';    
    var elementCount = list.childNodes.length;

    
    var parentLoc = '';
    if (level > 0){
      	var parentId = parent.getAttribute('id');
      	var parentLoc = parentId;
      	if (parentLoc != undefined){
        	linkId += (parentLoc + '-');
      	}	
    }
    if (elementCount != undefined){
      	linkId += (elementCount + 1);
    }
    
	// create the html
    var newItem = document.createElement('li');

    var newLink = document.createElement('a');
    newLink.style.display = 'inline';
    newLink.setAttribute('id', linkId);
  	newLink.style.background = 'yellow';
    newLink.setAttribute('name', 'link');
    newLink.onclick = new Function("javascript: displayForm(this.id, 0)");
    newLink.className = 'invalid';
    newLink.appendChild(document.createTextNode(linkId));
 
       
    newItem.appendChild(newLink);
    list.appendChild(newItem);

	refreshTree('someId');
	
	//save the current form and display the new one
	saveForm(true);
	currentForm = linkId;
	setCurrent('none'); //used by character keyboard to display current field - when swap forms need to set to none
	displayForm('new', level + 1);
}


function viewXml(){
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title')
		return;
	}
	if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false)
    }
    errors = document.getElementsByClassName('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before viewing. Errors will be marked with red shading in the text box.');
    	return;
    }
    
    //check the daoform details
    var daoform = document.getElementById('digitalobjectsform');
    var type = daoform.className;
    if (daoform){
    	var inputs = daoform.getElementsByTagName('input');
    	if (type == 'embed' || type == 'singlefile'){
    		if (inputs[0].value.strip() == '' && (inputs[1].value.strip() != '' || inputs[2].value.strip() != '')){
    			var confirmbox = confirm('The File URI value required for the digital object has not been completed. If you choose to proceed with this operation the digital object will not be included and the current details in the form will be lost.\n\nDo you want to continue?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				inputs[1].value = '';
    				inputs[2].value = '';
    			}
    		}

    	}
    	else if (type == 'thumb') {
    		if ((inputs[0].value.strip() == '' || inputs[1].value.strip() == '') && (inputs[2].value.strip() != '' || inputs[3].value.strip() != '')){   			
    			var confirmbox = confirm('The Thumbnail URI and/or File URI value required for the digital object has not been completed. If you choose to proceed with this operation the digital object will not be included and the current details in the form will be lost.\n\nDo you want to continue?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				inputs[0].value = '';
    				inputs[1].value = '';
    				inputs[2].value = '';
    				inputs[3].value = '';
    			}
    		} 		
    	}
    	else if (type == 'multiple'){
    		var length = inputs.length;
    		var number = (length-1)/3;
    		var problems = false;
    		var list = new Array();
    		for (var i = number; i < length-1; i+=2){
				if (inputs[i].value.strip() == '' && (inputs[i+1].value.strip() != '' || inputs[length-1].value.strip() != '')){
					list[list.length] = i;
					problems = true;
				}
    		}
    		if (problems == true){
    			var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you choose to proceed with this operation any incomplete URIs will not be included and the remaining incomplete details in the form will be lost.\n\nDo you want to continue?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				for (var j = 0; j < list.length; j++){
    					inputs[list[j]+1].value = '';
    				}
					if (list.length == number){
						inputs[length-1].value = '';
					}
    			}
    		}
    		
    	}
    }      
    
	saveForm(false);
	url = '/ead/edit?operation=display&recid=' + recid;
	if (fileOwner != null){
		url += '&owner=' + fileOwner;
	}
	var xml = window.open(url);	
	if (window.focus) {xml.focus();}
}


function previewRec(){
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title')
		return;
	}
	if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false);
    }
    errors = document.getElementsByClassName('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before viewing. Errors will be marked with red shading in the text box.');
    	return;
    }
    
    //check the daoform details
    var daoform = document.getElementById('digitalobjectsform');
    var type = daoform.className;
    if (daoform){
    	var inputs = daoform.getElementsByTagName('input');
    	if (type == 'embed' || type == 'singlefile'){
    		if (inputs[0].value.strip() == '' && (inputs[1].value.strip() != '' || inputs[2].value.strip() != '')){
    			var confirmbox = confirm('The File URI value required for the digital object has not been completed. If you choose to proceed with this operation the digital object will not be included and the current details in the form will be lost.\n\nDo you want to continue?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				inputs[1].value = '';
    				inputs[2].value = '';
    			}
    		}

    	}
    	else if (type == 'thumb') {
    		if ((inputs[0].value.strip() == '' || inputs[1].value.strip() == '') && (inputs[2].value.strip() != '' || inputs[3].value.strip() != '')){   			
    			var confirmbox = confirm('The Thumbnail URI and/or File URI value required for the digital object has not been completed. If you choose to proceed with this operation the digital object will not be included and the current details in the form will be lost.\n\nDo you want to continue?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				inputs[0].value = '';
    				inputs[1].value = '';
    				inputs[2].value = '';
    				inputs[3].value = '';
    			}
    		} 		
    	}
    	else if (type == 'multiple'){
    		var length = inputs.length;
    		var number = (length-1)/3;
    		var problems = false;
    		var list = new Array();
    		for (var i = number; i < length-1; i+=2){
				if (inputs[i].value.strip() == '' && (inputs[i+1].value.strip() != '' || inputs[length-1].value.strip() != '')){
					list[list.length] = i;
					problems = true;
				}
    		}
    		if (problems == true){
    			var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you choose to proceed with this operation any incomplete URIs will not be included and the remaining incomplete details in the form will be lost.\n\nDo you want to continue?');
    			if (confirmbox == false){
    				body.className = 'none';
    				return;
    			}
    			else{
    				for (var j = 0; j < list.length; j++){
    					inputs[list[j]+1].value = '';
    				}
					if (list.length == number){
						inputs[length-1].value = '';
					}
    			}
    		}
    		
    	}
    }    
       
	saveForm(false);
	url = '/ead/edit?operation=preview&recid=' + recid;	
	if (fileOwner != null){
		url += '&owner=' + fileOwner;
	}
	var preview = window.open(url);	
	if (window.focus) {preview.focus();}

}
	


/* */


function reassignToUser(){
	var recid = null;
	var ok = false;
	if (!document.getElementById('storeDirForm').recid){
		return;
	}
	var user = document.getElementById('storeDirForm').user.value;
	if (document.getElementById('storeDirForm').recid.length){
		for (var i=0; i < document.getElementById('storeDirForm').recid.length; i++) {
			if (document.getElementById('storeDirForm').recid[i].checked) {
		      	recid = document.getElementById('storeDirForm').recid[i].value;
		    }
		}
	}
	else {
		if (document.getElementById('storeDirForm').recid.checked) {
			recid = document.getElementById('storeDirForm').recid.value;
		}
	}
	if (user != 'null' && recid != null){
		var conflict = conflicts(recid.substring(0, recid.lastIndexOf('-')+1)+user);
		if (conflict){
			ok = confirmOp(user + ' already has this file in the editing process. Continuing with this operation will result in ' + user + '\'s current version being lost.\n Are you sure you want to continue to assign this file to ' + user + '?')
		}
		if (ok || !conflict){
			var url = '/ead/edit/';
			var data = 'operation=reassign&recid=' + recid + '&user=' + user;
			var ajax = new Ajax.Request(url, {method:'post', asynchronous:false, postBody:data, evalScripts:true, onSuccess: function(transport) {  	
				location.href="";		    
			}});
		}	
	}
}



function addElement(s){
	$(s).toggle();
  	if ($(s).visible($(s))){
  		$(('link' + s)).update('hide content');		
  	}
 	else if (s == 'daooptnsdiv' || $(s).getValue($(s)) == '' || $(s).getValue($(s)) == ' '){
		$(('link' + s)).update('add content');	
  	} 
  	else { 
		$(('link' + s)).update('show content');
  	}
}



//================================================================================================
// passive UI Functions to update left hand column navigation menu

function updateTitle(field) {
  	var link = document.getElementById(currentForm);
  	var title = ($('cab')).value;
  	if (title.indexOf('<') != -1){
		title = title.replace(/<\/?\S+?>/g, '');
  	}
  	var id = $('unitid').value;
  	if(field){
  		validateField(field);
  	}
  	if (title == '' && id == ''){
  		//link.update(currentForm);
  		link.innerHTML = currentForm;
  	}
  	else {
    	//link.update(id + ' - ' + title);
    	link.innerHTML = id + ' - ' + title;
	}
}


function updateId() {
  	var link = document.getElementById(currentForm);
  	var title = ($('cab')).value;
  	if (title.indexOf('<') != -1){
		title = title.replace(/<\/?\S+?>/g, '');
  	}
  	var countryCode = $('countrycode').value.toLowerCase();
  	var repositoryCode = $('archoncode').value;
  	var id = $('unitid').value;
  	
  	if (title == '' && id == ''){
  		//link.update(currentForm);
  		link.innerHTML = currentForm;
  	}
  	else {
    	//link.update(id + ' - ' + title);
    	link.innerHTML = id + ' - ' + title;
	}
	var match = true;
	if (currentForm == 'collectionLevel'){ 
		if (($('pui')).getAttribute('disabled') == null || ($('pui')).getAttribute('disabled') == false){
			lowerCaseId = '';
			for (var i=0; i<id.length; i++){
				if (id.charAt(i) != ' '){
					lowerCaseId += id.charAt(i).toLowerCase();
				}
			}
			for (var i=0; i < countryCode.length; i++){
				if (countryCode.charAt(i) != lowerCaseId.charAt(i)){
					match = false
				}
			}
			if (match == true){
				for (var i=0; i < repositoryCode.length; i++){
					if (repositoryCode.charAt(i) != lowerCaseId.charAt(i+2)){
						match = false
					}
				}
				if (match == true){
					($('pui')).value = lowerCaseId;
				}
				else {
					($('pui')).value = countryCode + repositoryCode + lowerCaseId;
				}
			}
			else {
				($('pui')).value = countryCode + repositoryCode + lowerCaseId;
			}
		}	
	}
}


//================================================================================================
//validation related functions

function conflicts(recid){
	var conflict = null;
	if (recid != null){
		var url = '/ead/edit'
		var data = 'operation=checkId&id=' + recid + '&store=editStore';
		new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 
			var response = transport.responseText;
			conflict = response.substring(7,response.indexOf('</value>'));
		}});
	}
	else {
		return false;
	}
	if (conflict == 'true'){
		return true;
	}
	else {
		return false;
	}
}


function checkConflicts(){
	var filepath = null;
	for (var i=0; i < document.getElementById('sourceDirForm').filepath.length; i++) {
		if (document.getElementById('sourceDirForm').filepath[i].checked) {
	      	filepath = document.getElementById('sourceDirForm').filepath[i].value;
	    }
	}
	if (filepath != null){
	    var conflict = 'false';
	    var overwrite = 'false';
	    var users = null;
		var url = '/ead/edit'
		var data = 'operation=getCheckId&filepath=' + filepath;
		new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 
			var response = transport.responseText;
			conflict = response.substring(response.indexOf('<value>')+7, response.indexOf('</value>'));
			if (response.indexOf('<overwrite>') > -1){
				overwrite = response.substring(response.indexOf('<overwrite>')+11, response.indexOf('</overwrite>'));
			}
			if (response.indexOf('<users>') > -1){
				users = response.substring(response.indexOf('<users>')+7, response.indexOf('</users>'));
			}

		}});
		if (conflict == 'false'){
			document.sourceDirForm.submit();
		}
		else if (overwrite == 'true'){
			var ok = confirmOp('You already have this file open for editing - continuing with this operation will delete all changes you have made since the file was last submitted to the main database. \n Are you sure you want to continue?');
			if (ok){
				document.sourceDirForm.submit();
			}
			else {
				return;
			}
		}
		else if (users != null){
			var ok = confirmOp('The following users already have this file open for editing\n\n ' + users + '\n\n Are you sure you want to continue?');
			if (ok){
				document.sourceDirForm.submit();
			}
			else {
				return;
			}
		}
	}
	else {
		return;
	}	
}



function validateFieldDelay(field, asynch){
	clearTimeout(timeout);
	timeout = setTimeout(function() {validateXML(field, asynch)}, 2000);
}

function validateField(field, asynch){
	clearTimeout(timeout);
	validateXML(field, asynch);
}


function validateXML(field, asynch){
	var url = '/ead/edit/';
	var data = 'operation=validate&text=' + field.value.replace('%', '%25');
	
	var ajax = new Ajax.Request(url, {method: 'get', asynchronous: asynch, parameters: data, onSuccess: function(transport) { 		
		var response = transport.responseText;
		var valid = response.substring(7,response.indexOf('</value>'));
		if (valid == 'false'){
			field.className = 'menuFieldError';
		}
		else {
			field.className = 'menuField';
		}	    					    		     
	}});
}


function checkId(store){
	if ($('countrycode').value != ''){
		if ($('archoncode').value != ''){
			if ($('unitid').value != ''){
				var id = $('countrycode').value.toLowerCase() + $('archoncode').value + $('unitid').value.replace(' ', '').toLowerCase();
				var url = '/ead/edit'
				var data = 'operation=checkId&id=' + id + '&store=' + store;
				new Ajax.Request(url, {method: 'get', asynchronous: true, parameters: data, onSuccess: function(transport) { 	    				
				    var response = transport.responseText;
				    idExists = response.substring(7,response.indexOf('</value>'));
				    if (idExists == 'true' && !($('idError'))){
				    	var element = document.createElement('p');
				    	element.className = 'error';
				    	element.setAttribute('id', 'idError');
				    	element.appendChild(document.createTextNode('Id already exists in record store'));
				    	($('unitidparent')).appendChild(element);
				    }
				    else {
				    	if (idExists == 'false' && ($('idError'))){
				    		($('unitidparent')).removeChild($('idError'));
				    	}
				    }	    			    
	 			}});
			}
		}
	}	
	updateId();
}


function checkRequiredData(){
	if ($('cab').value == ''){
		return false;
	}
	else if ($('unitid').value == ''){
		return false;
	}
	else if ($('archoncode').value == '' && currentForm == 'collectionLevel'){
		return false;
	}
	else if ($('countrycode').value == '' && currentForm == 'collectionLevel'){
		return false;
	}	
	else {
		return true;
	}
}


//================================================================================================
//keyboard related functions

var currentCharTable = 'lower';

function toggleKeyboard(){
  	var keyboard = ($('keyboard')); 
  	keyboard.toggle();  
  	showCharTable('lower');
}


function showCharTable(type){
	if (type == 'lower'){
  		($('chartablelower')).style.display = 'block';
  		($('chartableupper')).style.display = 'none';
  	}
  	else if (type == 'upper'){
  		($('chartableupper')).style.display = 'block';
  		($('chartablelower')).style.display = 'none';   	
  	}
  	else {
		($('chartable' + currentCharTable)).style.display = 'block';
  	}
  	($('hideicon')).style.display = 'inline';
  	($('showicon')).style.display = 'none';
}


function hideCharTable(){
	if (($('chartableupper')).style.display == 'block'){
		currentCharTable = 'upper';
	}
	else {
		currentCharTable = 'lower';
	}
  	($('chartableupper')).style.display = 'none';
  	($('chartablelower')).style.display = 'none';
  	
  	($('showicon')).style.display = 'inline';
  	($('hideicon')).style.display = 'none';
}


//====================================================================================================
//context menu related functions 
function hideAllMenus(){
	document.getElementById('tagmenu').style.display = 'none';
	hideSubMenus();
}


function showSubMenu(type, pos){
	hideSubMenus();
	var menu = null;
	
	menu = ($(type + 'menu'))

	mainMenu = document.getElementById('tagmenu');
	size = mainMenu.getElementsByTagName('LI');
	menu.style.top = parseInt(mainMenu.style.top) + ((mainMenu.offsetHeight / size.length) * pos) + 'px' ;
	menu.style.left = parseInt(mainMenu.style.left) + mainMenu.offsetWidth  + 'px';
	menu.style.display = 'block';
}


function hideSubMenus(){
	($('titlemenu')).style.display = 'none';
	($('emphmenu')).style.display = 'none';
	($('extrefmenu')).style.display = 'none';

}


function hideSubMenu(type){
	($(type + 'menu')).style.display = 'none';
}

/*
// Description: a function to tag selected text in a specified field (text, textarea)
// Author:    John Harrison <johnpaulharrison@googlemail.com>
// Copyright &copy; John Harrison 2006
// Date:      04 January 2006
*/
function addTag(tagtype) {
	var field = currentEntryField;
	var scrollPos = field.scrollTop;
	if (tagtype == 'list'){
		var startTag = '<list><item>'
		var endTag = '</item></list>'
	}
	else if (tagtype == 'comment'){
		var startTag = '<!-- '
		var endTag = ' -->'
	}
	else {
		var startTag = '<' + tagtype + '>'
		var endTag = '</' + tagtype.split(' ', 2)[0] + '>'
	}
	if (field.selectionStart || field.selectionStart == '0') {
		// Firefox 1.0.7, 1.5.0 - tested
		var startPos = field.selectionStart;
		var endPos = field.selectionEnd;
		if (endPos < startPos)	{
			var temp = end_selection;
			end_selection = start_selection;
			start_selection = temp;
		}
		var selected = field.value.substring(startPos, endPos);
		field.value = field.value.substring(0, startPos) + startTag + selected + endTag + field.value.substring(endPos, field.value.length);
	}
	else if (document.selection) {
		//Windows IE 5,6 - tested
		field.focus();
		selection = document.selection.createRange();
		var seltext = selection.text;
		selection.text = startTag + seltext + endTag;
	}
	else if (window.getSelection) {
		// Mozilla 1.7, Safari 1.3 - untested
		selection = window.getSelection();
		var seltext = selection.text;
		selection.text = startTag + seltext + endTag;
	}
	else if (document.getSelection) {
		// Mac IE 5.2, Opera 8, Netscape 4, iCab 2.9.8 - untested
		selection = document.getSelection();
		var seltext = selection.text;
		selection.text = startTag + seltext + endTag;
	} 
	else field.value += startTag + endTag;
	if (scrollPos){
		field.scrollTop = scrollPos;
	}
}

/*
DAO related stuff
*/

function addFile(number){
	var doform = document.getElementById('digitalobjectsform');
	var tbody = document.getElementById('multipletbody' + number);
	var jsrow = document.getElementById('jsrow');
	rows = tbody.getElementsByTagName('tr').length;
	
	nextfile = ((rows - 2)/2) + 1
	
	if (nextfile%2 == 0){
		var shading = 'odd';
	}
	else{
		var shading = 'even';
	}
		
//file uri
 	var tr = document.createElement('tr');
 	tr.className = shading;
 	var td = document.createElement('td');
 	td.appendChild(document.createTextNode('File ' + nextfile + ' URI: '));
 	td.className = 'label';
 	tr.appendChild(td);
  				
 	href = document.createElement('input');
 	href.setAttribute('type', 'text');
 	href.setAttribute('name', 'daogrp/daoloc[' + nextfile + ']/@href');
 	href.setAttribute('size', '70');
 	td = document.createElement('td');		
 	td.appendChild(href);
 			
 	tr.appendChild(td);
  
 	tbody.insertBefore(tr, jsrow);   	
   			
   			
//file title   			
  	tr = document.createElement('tr');
  	tr.className = shading;
   	td = document.createElement('td');
   	td.appendChild(document.createTextNode('File ' + nextfile + ' title: '));
   	td.className = 'label';
   	tr.appendChild(td);
   			
   	href = document.createElement('input');
   	href.setAttribute('type', 'text');
   	href.setAttribute('name', 'daogrp/daoloc[' + nextfile + ']/@title');
   	href.setAttribute('size', '70');
   	td = document.createElement('td');		
   	td.appendChild(href);
   			
   	tr.appendChild(td);
   			
   	tbody.insertBefore(tr, jsrow);  
   			 
 //role info
    role = document.createElement('input');
   	role.setAttribute('type', 'hidden');
   	role.setAttribute('name', 'daogrp/daoloc[' + nextfile + ']/@role');
   	role.setAttribute('value', 'reference');
   	doform.insertBefore(role, tbody.parentNode);				
	
	
}


function createObjectsForm() {

	var type = null;
	for (var i=0; i < document.eadForm.daooptns.length; i++) {
   		if (document.eadForm.daooptns[i].checked) {
     		type = document.eadForm.daooptns[i].value;
     	}
   	}

   	if (type == null) {
   		return;
   	}
   	else {
   		var doform = document.getElementById('digitalobjectsform');
   		doform.className = type;
   		if (doform.childNodes.length > 0){
	   		for (var i = doform.childNodes.length-1; i > -1; i--) {
	   			doform.removeChild(doform.childNodes[i]);
	   		}
   		}
   		if (type == 'singlefile' || type == 'embed') {
   		
   			var table = document.createElement('table');
   			var tbody = document.createElement('tbody');
   			

	//file location   			
   			var tr = document.createElement('tr');
   			var td = document.createElement('td');
   			td.appendChild(document.createTextNode('File URI: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			var href = document.createElement('input');
   			href.setAttribute('type', 'text');
   			href.setAttribute('name', 'dao/@href');
   			href.setAttribute('size', '70');
   			td = document.createElement('td');		
   			td.appendChild(href);
   			
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr);

	//title   			
   			tr = document.createElement('tr');
   			td = document.createElement('td');
   			td.appendChild(document.createTextNode('Title: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			var title = document.createElement('input');
   			title.setAttribute('type', 'text');
   			title.setAttribute('name', 'dao/@title');
   			title.setAttribute('size', '70');
			td = document.createElement('td');
   			td.appendChild(title);
   			
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr);

	//DAO desciption
   			tr = document.createElement('tr');
   			td = document.createElement('td');
   			td.appendChild(document.createTextNode('Description: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			var desc = document.createElement('input');
   			desc.setAttribute('type', 'text');
   			desc.setAttribute('name', 'dao/daodesc');
   			desc.setAttribute('size', '70');
 			td = document.createElement('td');
   			td.appendChild(desc);
   			
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr);  			
 
 	//show  			   			
   			var show = document.createElement('input');
   			show.setAttribute('type', 'hidden');
   			show.setAttribute('name', 'dao/@show');
   			
   			if (type == 'singlefile'){
   				show.setAttribute('value', 'new');
   			}
   			else {
   				show.setAttribute('value', 'embed');
   			}

			table.appendChild(tbody);
			doform.appendChild(table);
   			doform.appendChild(show);

   		} 
   		else if (type=='thumb'){
   		
   			var table = document.createElement('table');
   			var tbody = document.createElement('tbody');

	//thumbnail location   			
  			var tr = document.createElement('tr');
   			var td = document.createElement('td');
   			td.appendChild(document.createTextNode('Thumbnail URI: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			var href = document.createElement('input');
   			href.setAttribute('type', 'text');
   			href.setAttribute('name', 'daogrp/daoloc[1]/@href');
   			href.setAttribute('size', '70');
   			td = document.createElement('td');		
   			td.appendChild(href);
   			
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr);  
   			
   	//role info
    		var role1 = document.createElement('input');
   			role1.setAttribute('type', 'hidden');
   			role1.setAttribute('name', 'daogrp/daoloc[1]/@role');
   			role1.setAttribute('value', 'thumb');
   			

	//file location
  			tr = document.createElement('tr');
   			td = document.createElement('td');
   			td.appendChild(document.createTextNode('File URI: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			href = document.createElement('input');
   			href.setAttribute('type', 'text');
   			href.setAttribute('name', 'daogrp/daoloc[2]/@href');
   			href.setAttribute('size', '70');
   			td = document.createElement('td');		
   			td.appendChild(href);
   			
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr);  
   			
	//file title   			
  			tr = document.createElement('tr');
   			td = document.createElement('td');
   			td.appendChild(document.createTextNode('Title: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			href = document.createElement('input');
   			href.setAttribute('type', 'text');
   			href.setAttribute('name', 'daogrp/daoloc[2]/@title');
   			href.setAttribute('size', '70');
   			td = document.createElement('td');		
   			td.appendChild(href);
   			
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr);  

 	//role info
    		var role2 = document.createElement('input');
   			role2.setAttribute('type', 'hidden');
   			role2.setAttribute('name', 'daogrp/daoloc[2]/@role');
   			role2.setAttribute('value', 'reference');


	//DAO desciption
   			tr = document.createElement('tr');
   			td = document.createElement('td');
   			td.appendChild(document.createTextNode('Description: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			var desc = document.createElement('input');
   			desc.setAttribute('type', 'text');
   			desc.setAttribute('name', 'daogrp/daodesc');
   			desc.setAttribute('size', '70');
 			td = document.createElement('td');
   			td.appendChild(desc);
   			
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr);  			

			table.appendChild(tbody);
			doform.appendChild(table);	
			doform.appendChild(role1);
			doform.appendChild(role2);

			
   		}
   		else if (type=='multiple'){
   		   	var table = document.createElement('table');
   			var tbody = document.createElement('tbody');
   			tbody.setAttribute('id', 'multipletbody1');
   			var start = 2;
   			for (var i=1; i<=start; i++){
   			
   				if (i%2 == 0){
   					var shading = 'odd';
   				}
   				else {
   					var shading = 'even';
   				}
   			//file uri
   				var tr = document.createElement('tr');
   				tr.className = shading;
   				var td = document.createElement('td');
   				td.appendChild(document.createTextNode('File ' + i + ' URI: '));
   				td.className = 'label';
   				tr.appendChild(td);
   				
	   			href = document.createElement('input');
	   			href.setAttribute('type', 'text');
	   			href.setAttribute('name', 'daogrp/daoloc[' + i + ']/@href');
	   			href.setAttribute('size', '70');
	   			td = document.createElement('td');		
	   			td.appendChild(href);
	   			
	   			tr.appendChild(td);
	   			
	   			tbody.appendChild(tr);     	
	   			
	   			
		//file title   			
	  			tr = document.createElement('tr');
	  			tr.className = shading;
	   			td = document.createElement('td');
	   			td.appendChild(document.createTextNode('File ' + i + ' title: '));
	   			td.className = 'label';
	   			tr.appendChild(td);
	   			
	   			href = document.createElement('input');
	   			href.setAttribute('type', 'text');
	   			href.setAttribute('name', 'daogrp/daoloc[' + i + ']/@title');
	   			href.setAttribute('size', '70');
	   			td = document.createElement('td');		
	   			td.appendChild(href);
	   			
	   			tr.appendChild(td);
	   			
	   			tbody.appendChild(tr);  
	   			 
	 	//role info
	    		role = document.createElement('input');
	   			role.setAttribute('type', 'hidden');
	   			role.setAttribute('name', 'daogrp/daoloc[' + i + ']/@role');
	   			role.setAttribute('value', 'reference');
	   			doform.appendChild(role);			
   			}
   			
   			tr = document.createElement('tr');
   			td = document.createElement('td');
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			td = document.createElement('td');
   			var link = document.createElement('a');
  			link.appendChild(document.createTextNode('add another file'));
   			link.className = 'smalllink';
   			
  			link.onclick = function () {addFile(1); };
   			td.appendChild(link);
   			tr.setAttribute('id', 'jsrow');
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr); 
   			
   		//DAO desciption
   			tr = document.createElement('tr');
   			td = document.createElement('td');
   			td.appendChild(document.createTextNode('Description: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			var desc = document.createElement('input');
   			desc.setAttribute('type', 'text');
   			desc.setAttribute('name', 'daogrp/daodesc');
   			desc.setAttribute('size', '70');
 			td = document.createElement('td');
   			td.appendChild(desc);
   			
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr);  	
   			
   			table.appendChild(tbody);
			doform.appendChild(table);
   			
   		}
   	}
}

