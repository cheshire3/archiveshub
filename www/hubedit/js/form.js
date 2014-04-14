/*
// Program:		form.js
// Version:   	0.08
// Description:
//            	JavaScript functions for the editing form in the Archives Hub editing interface.  
//            	- produced for the Archives Hub v3.x. 
// Language:  	JavaScript
// Author(s):   Catherine Smith <catherine.smith@liv.ac.uk>
//              John Harrison <john.harrison@liv.ac.uk>
// Date:      	25/01/2013
// Copyright: 	&copy; University of Liverpool 2006 - 2013
//
// Version History:
// 0.01 - 09/01/2009 - CS - functions completed for first release of Archives 
                            Hub editing interface
// 0.02 - 07/06/2011 - JH - Catch and report when AJAX request to save record 
//                          fails (also required change in server-side code)
//                        - Prompt to save when leaving page withot saving
// 0.03 - 02/03/2012 - JH - Updated to prototype v1.7
//                        - Added function cloneTextField to clone previous 
                            text input for repeatable elements
// 0.04 - 24/04/2012 - JH - Added cloneField, capable of cloning multiple 
//                          fields within a block-level DOM element
// 0.05 - 07/06/2012 - JH - Fixed bug in saving new record (mandatory fields)
//                        - Don't warn about unsaved changes when deleting records
//                        - Check for username in response when saving record
// 0.06 - 18/01/2013 - JH - Fixed bug missing validation of normalized unitdate
// 0.07 - 24/01/2013 - JH - Removed debugging `console` calls. Introduced in
//                          0.04 - causes bug in IE9.
// 0.08 - 25/01/2013 - JH - Fixed validation of form fields
*/


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
var daocount = 0;
var required_xpaths_components = new Array('unitid', 'did/unittitle', 'did/unitdate');
var required_xpaths = new Array('unitid',
								'archoncode',
								'countrycode',
								'did/unittitle',
								'did/unitdate',
								'did/unitdate/@normal',
								'did/repository',
								'did/origination',
								'did/physdesc/extent',
								'scopecontent',
								'accessrestrict'
								);

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

function getMarkupStyle(){
    markupRadios = document.getElementsByName('markup');
    for (var i = 0; i < markupRadios.length; i++) {
        if (markupRadios[i].checked) {
            return markupRadios[i].value;
        }
    }
    // default to Archives Hub markup
    return 'hub';
}


/* Menu related stuff */
function populateInst(){
	var value = document.getElementById('instselect').value;
	var list = value.split('|');

	document.getElementById('editid').value = list[0];
	document.getElementById('editname').value = list[1];
	document.getElementById('editquota').value = list[2];
		
	document.getElementById('instselect').value = 'none';
}


function validateEmail(){
	var address = document.getElementById('email').value;
	address = address.replace(/^\s+|\s+$/g, '');
 	var emailpat = /^([a-zA-Z0-9])+([\.a-zA-Z0-9_-])*@([a-zA-Z0-9])([a-zA-Z0-9_-])+(\.[a-zA-Z0-9]+)+$/;
 	if (!emailpat.test(address)) {
  		alert('The email address supplied is not valid');
  		return false;
 	}
 	else {
 		return true;
 	}
}

function checkInstForm(type){
	var quota = document.getElementById(type + 'quota').value;
	var name = document.getElementById(type + 'name').value;
	var nameregex = /^([\s])*$/;
	var quotaregex = /^([0-9])+$/;
	
	if (!nameregex.test(name) && name != ''){
		if (quotaregex.test(quota)){
			return true;
		}
		else {
			alert('Quota must be a number');
			return false;
		}
	}
	else {
		alert('You must supply a name for this institution');
		return false;
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
		var ok = confirmOp('You are about to delete ' + recid.substring(0, recid.lastIndexOf('-')) + ' from the editing store. All changes made since it was last submitted to the database will be lost.\nAre you sure you want to continue?')
		if (ok){
		    // disable save warning
            warn = false;
			deleteRec(recid);
		}
		else {
			return;
		}
	}
}

function deleteRec(id){
	var url = 'delete.html';
	var data = 'operation=deleteRec&recid=' + encodeURIComponent(id);
	var ajax = new Ajax.Request(url, {method:'post', asynchronous:false, postBody:data, evalScripts:true, onSuccess: function(transport) {	
		location.href="menu.html";		    
	}});	
}

function discardRec(id){
	var url = 'discard.html';
	var data = 'operation=discard&recid=' + encodeURIComponent(id);
    if (document.getElementById('owner') != null){    
    	setOwner(document.getElementById('owner').value);
    }	
	if (fileOwner != null){
		data += '&owner=' + encodeURIComponent(fileOwner);
	}
	var ajax = new Ajax.Request(url, {method:'post', asynchronous:false, postBody:data, evalScripts:true, onSuccess: function(transport) {	
		location.href="menu.html";		    
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
	errors = $$('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before submitting. Errors will be marked with red shading in the text box.');
    	return;
    }
    var errors = $$('dateError');
    if (errors.length != 0){
    	alert('Please fix the error in the normalised date before submitting. This field can only contain numbers and the character /.');
    	return;
    }
    //check the daoform details   
	var daodetails = checkDao();
    if (daodetails[0] == true){
 	    var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you proceed with this operation any incomplete URIs will not be included and the title and/or description information relating to the missing URI will be lost. All other content will be saved.\n\nDo you want to continue?');
 		if (confirmbox == false){
 			return;
 		}   			
 		else {			
 			var wipeids = daodetails[1];
 			var descids = daodetails[2];
 			for (var i=0; i< wipeids.length; i++){
 				document.getElementById(wipeids[i]).value = '';
 			}
 			for (var i=0; i< descids.length; i++){
 				document.getElementById(descids[i]).value = '<p></p>';
 			}
 		}
    }
    if (!saveForm(false)) {
        alert('Record could not be saved due to server error.\n\nThis is probably caused by a recent change you\'ve made.');
        return false;
    }
	
	//validate whole record
	invalid = $$('invalid');
	if (invalid.length != 0){
		alert('Not all components of your record have the required fields completed. Please complete any components which are coloured red in the contents tree. The missing fields will also be indicated with a red border.');
		return;
	}
	
	url = "?operation=submit&recid=" + encodeURIComponent(recid);
	if (fileOwner != null){
		url += '&owner=' + encodeURIComponent(fileOwner);
	}
	if (fileName != null){
		url += '&filename=' + encodeURIComponent(fileName);
	}
	if (index == false || index == 'false'){
		url += '&index=false';
	}
    location.href = url;
}

var warn = false;

window.onbeforeunload = function (evt) {
    if (warn) {
        var message = "Any changes made since your last save will be lost unless you save them."
        if (typeof evt == 'undefined') {//IE
            evt = window.event;
        }
        if (evt) {
            evt.returnValue = message;
        }
        return message;
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
	var errors = $$('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before saving. Errors will be marked with red shading in the text box.');
    	body.className = 'none';
    	return;
    }
    var errors = $$('dateError');
    if (errors.length != 0){
    	alert('Please fix the error in the normalised date before saving. This field can only contain numbers and the character /.');
    	body.className = 'none';
    	return;
    }
    var values = checkEditStore();
    if (values[0] == 'error'){
    	alert('A problem occurred when trying to perform this operation. Please contact the hub team..');
    	body.className = 'none';
	   	return;
    }
    if (values[0]){
    	if (values[1] == 'user'){
    		var confirmbox = confirm('A file with this Reference code is already in the process of being created or edited. If you proceed with this operation the existing file will be overwritten with this one.\n\nAre you sure you want to continue with this operation?');
 			if (confirmbox == false){
	   			body.className = 'none';
	   			return;
	   		}
   		}
   		else if (values[1] == 'other'){
    		var confirmbox = confirm('A file with this Reference code is already in the process of being created or edited by another user.\n\nAre you sure you want to continue with this operation?');
 			if (confirmbox == false){
	   			body.className = 'none';
	   			return;
	   		}   		
   		}
    }
       
    //check the daoform details   
	var daodetails = checkDao();
    if (daodetails[0] == true){
 	    var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you proceed with this operation any incomplete URIs will not be included and the title and/or description information relating to the missing URI will be lost. All other content will be saved.\n\nDo you want to continue?');
 		if (confirmbox == false){
 			body.className = 'none';
 			return;
 		}   			
 		else {			
 			var wipeids = daodetails[1];
 			var descids = daodetails[2];
 			for (var i=0; i< wipeids.length; i++){
 				document.getElementById(wipeids[i]).value = '';
 			}
 			for (var i=0; i< descids.length; i++){
 				document.getElementById(descids[i]).value = '<p></p>';
 			}
 		}
    }
	findRequiredFields();
	body.className = 'none';
	if (saveForm(false)) {
        alert('This form is now saved as ' + recid + ' and can be reloaded from the admin menu for further editing at a later date.');
    } else {
        alert('Record could not be saved due to server error.');
    }
}


function saveForm(asynch){

	var relocate = false;
	warn = false;
	resetAllAccessPoints()
	// Collect the basic id information
	if (currentForm == 'collectionLevel'){
        var cc = Prototype.Selector.find($$("input[id*='countrycode[']"), "input[readOnly]");
        if (typeof(cc) == 'undefined'){
            // Fall back to first occurring
            var cc = $("countrycode[1]");
        }
        var rc = Prototype.Selector.find($$("input[id*='archoncode[']"), "input[readOnly]");
        if (typeof(rc) == 'undefined'){
            // Fall back to first occurring
            var rc = $("archoncode[1]");
        }
        var uid = Prototype.Selector.find($$("input[id*='unitid[']"), "input[readOnly]");
        if (typeof(uid) == 'undefined'){
            // Fall back to first occurring
            var uid = $("unitid[1]");
        }
		setCountryCode(cc.value);
	    setRepositoryCode(rc.value);
	    setBaseUnitId(uid.value);
	    if (document.getElementById('owner') != null){    
	    	setOwner(document.getElementById('owner').value);
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
  	var data = $('eadForm').serialize();
  	data += '&operation=save&location=' + currentForm;
  	previousForm = currentForm;
  	if (currentForm != 'collectionLevel'){	  			
  		var parent = document.getElementById(currentForm).parentNode.parentNode.parentNode;	  		
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
  	    // make at least one of the unitids readonly
  	    var cc = Prototype.Selector.find($$("input[id*='countrycode[']"), "input[readOnly]");
        if (typeof(cc) == 'undefined'){
            // Fall back to first occurring
            var cc = $("countrycode[1]");
        }
        var rc = Prototype.Selector.find($$("input[id*='archoncode[']"), "input[readOnly]");
        if (typeof(rc) == 'undefined'){
            // Fall back to first occurring
            var rc = $("archoncode[1]");
        }
        var uid = Prototype.Selector.find($$("input[id*='unitid[']"), "input[readOnly]");
        if (typeof(uid) == 'undefined'){
            // Fall back to first occurring
            var uid = $("unitid[1]");
        }
  		cc.readOnly = true;
  		rc.readOnly = true;
  		uid.readOnly = true;
  	}	
    if (recid != null && recid != 'notSet'){
    	data += '&recid=' + encodeURIComponent(recid);
    }
    else {
    	recid = (document.getElementById('pui')).value;
    	relocate = true;
    }
    if (fileOwner != null){
    	data += '&owner=' + encodeURIComponent(fileOwner);
    }
    var loc = document.getElementById('rightcol');
    loc = 'edit.html';
    var rid = null;
    var username = null;
    var retval = false;
	var ajax = new Ajax.Request(loc, {method:'post', asynchronous:asynch, postBody:data, evalScripts:true, onSuccess: function(transport){ 
	    if (transport.status == 200) {
	    	var response = transport.responseText;
		    rid = response.substring(response.indexOf('<recid>') + 7,response.indexOf('</recid>'));
		    username = response.substring(response.indexOf('<username>') + 10,response.indexOf('</username>'));	
		    var valid = response.substring(response.indexOf('<valid>') + 7, response.indexOf('</valid>'));
			if (valid == 'False'){
				($(previousForm)).className = 'invalid';
			}
			else{
				($(previousForm)).className = 'valid';
			}
			retval = true;
		}
	}});
	if (relocate == true){
		window.location.href='edit.html?operation=load&recid=' + encodeURIComponent(rid) + '&user=' + encodeURIComponent(username);
	}
    return retval;
}


function displayForm(id, level, nosave){

	if (nosave == undefined){
		nosave = false;
	}
	/* for adding a new form */
	if (id == 'new'){
		var data = 'operation=add&recid=' + encodeURIComponent(recid) + '&clevel=' + level;
		var loc = document.getElementById('rightcol');		
		
		new Ajax.Updater(loc, 'edit.html', {method: 'post', asynchronous:false, parameters:data, evalScripts:true});
		
	   	(document.getElementById('countrycode[1]').value) = countryCode;	   			
	   	(document.getElementById('archoncode[1]').value) = repositoryCode;
	   	(document.getElementById('unitid[1]').value) = baseUnitId + '/' + currentForm.replace(/-/g, '/');
	   	(document.getElementById('pui').value) = recid;
	   	updateId();
	}
	/* for navigating to an existing form*/
	else {	 
		if (nosave == false){
			if (!checkRequiredData()){
				alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title');
				return;
			} 	
			var errors = $$('menuFieldError');
		    if (errors.length != 0){
		    	alert('Please fix the errors in the xml before leaving this page. Errors will be marked with red shading in the text box.');
		    	return;
		    }	
		    var errors = $$('dateError');
			if (errors.length != 0){
			  	alert('Please fix the error in the normalised date before leaving this page. This field can only contain numbers and the character /.');
			    return;
			}
		    //check the daoform details   
			var daodetails = checkDao();
		    if (daodetails[0] == true){
		 	    var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you proceed with this operation any incomplete URIs will not be included and the title and/or description information relating to the missing URI will be lost. All other content will be saved.\n\nDo you want to continue?');
		 		if (confirmbox == false){
		 			return;
		 		}   			
		 		else {			
		 			var wipeids = daodetails[1];
		 			var descids = daodetails[2];
		 			for (var i=0; i< wipeids.length; i++){
		 				document.getElementById(wipeids[i]).value = '';
		 			}
		 			for (var i=0; i< descids.length; i++){
		 				document.getElementById(descids[i]).value = '<p></p>';
		 			}
		 		}
		    }		    
			if (!saveForm(false)) {
		        alert('Record could not be saved due to server error.');
		        return false;
		    }
		}	
		var data = 'operation=navigate&recid=' + encodeURIComponent(recid) + '&newForm=' + id;
		if (fileOwner != null){
			data += '&owner=' + encodeURIComponent(fileOwner);
		}
		var loc = document.getElementById('rightcol');
		new Ajax.Updater(loc, 'edit.html', {method: 'get', asynchronous:false, parameters:data, evalScripts:true, onSuccess: function(transport){		   	
	    
		}});
		if (document.getElementById(currentForm)){
			(document.getElementById(currentForm)).style.background = 'none';
		}
	    currentForm = id;
	    (document.getElementById(currentForm)).style.background = 'yellow';		    		  	 	  	
  	}
  	findRequiredFields();
}


function addComponent(){	
	var body = document.getElementsByTagName('body')[0];
	body.className = 'waiting';
    // check it does not exceed the c12 limit 
    if (currentForm != 'collectionLevel'){
     	var parent = document.getElementById(currentForm);    
      	var listItem = parent.parentNode;
      	var level = Number(listItem.parentNode.getAttribute('name'));
      	if (level == 12){
      		alert('You cannot add any more component levels to this description');
      		body.className = 'none';
      		return;
      	}
    }
   
    //validate and check id existence etc.
    if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title')
		body.className = 'none';
		return;
	}
    if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false);
    }
    errors = $$('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before adding a component. Errors will be marked with red shading in the text box.');
    	body.className = 'none';
    	return;
    }  
    var errors = $$('dateError');
    if (errors.length != 0){
    	alert('Please fix the error in the normalised date before adding a component. This field can only contain numbers and the character /.');
    	body.className = 'none';
    	return;
    }
	else if (currentForm == 'collectionLevel' && recid == 'notSet'){
		var url = 'edit.html'
		var data = 'operation=checkId&id=' + encodeURIComponent(($('pui')).value) + '&store=recordStore';
		new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 	    				
			var response = transport.responseText;
			var idExists = response.substring(7,response.indexOf('</value>')); 			 
	 	}});
	 	if (idExists == 'true'){
   				alert('A record with this ID already exists in this database\nyou must supply a unique id before proceeding');
   				body.className = 'none';
   				return;
   		}   
	}
	
    //check the daoform details   
	var daodetails = checkDao();
    if (daodetails[0] == true){
 	    var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you proceed with this operation any incomplete URIs will not be included and the title and/or description information relating to the missing URI will be lost. All other content will be saved.\n\nDo you want to continue?');
 		if (confirmbox == false){
 			body.className = 'none';
 			return;
 		}   			
 		else {			
 			var wipeids = daodetails[1];
 			var descids = daodetails[2];
 			for (var i=0; i< wipeids.length; i++){
 				document.getElementById(wipeids[i]).value = '';
 			}
 			for (var i=0; i< descids.length; i++){
 				document.getElementById(descids[i]).value = '<p></p>';
 			}
 		}
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
      	//if this element isn't collection level remove the delete option since it now isn't a leaf node
		if (currentForm != 'collectionLevel'){
			var del = null
			if (del = document.getElementById('delete_' + currentForm)){
				del.parentNode.removeChild(del);
			}
		}
    }  

    // create the linkId
    var linkId = '';    
      
    var parentLoc = '';
    if (level > 0){
      	var parentId = parent.getAttribute('id');
      	var parentLoc = parentId;
      	if (parentLoc != undefined){
        	linkId += (parentLoc + '-');
      	}	
    }

    var elementCount = list.childNodes.length;
    if (elementCount != undefined){
    	if (elementCount == 0){
    		linkId += 1;
    	}
    	else {
    		var previousNode;
    		if (previousNode = list.childNodes[elementCount-1].childNodes[1]){
	    		var previousId = previousNode.getAttribute('id');
	    		var number = Number(previousId.substring(previousId.lastIndexOf('-')+1)); 		
	    		linkId += number + 1;	
	    	}	
	    	else {
	    		linkId += '1';
	    	}
    	}    	
    }

	// create the html
    var newItem = document.createElement('li');

    var newLink = document.createElement('a');
    newLink.style.display = 'inline';
    newLink.setAttribute('id', linkId);
  	newLink.style.background = 'yellow';
    newLink.setAttribute('name', 'link');
    newLink.onclick = new Function("displayForm(this.id, 0)");
    newLink.className = 'invalid';
    newLink.appendChild(document.createTextNode(linkId));
    
    deleteLink = document.createElement('a');
    deleteLink.setAttribute('id', 'delete_' + linkId);
    deleteLink.onclick = new Function("deleteComponent('" + linkId + "')");
    
    deleteLink.className = 'delete delete-sprite';
    deleteLink.appendChild(document.createTextNode('[X]'));
        
    newItem.appendChild(newLink);
    newItem.appendChild(deleteLink);

    list.appendChild(newItem);
    

	refreshTree('someId');
	
	//save the current form and display the new one
	saveForm(true);
	currentForm = linkId;
	setCurrent('none'); //used by character keyboard to display current field - when swap forms need to set to none
	displayForm('new', level + 1);
	body.className = 'none';
}


function deleteComponent(id){
	var body = document.getElementsByTagName('body')[0];
	body.className = 'waiting';
	var link = document.getElementById(id);	
	var compid = link.innerHTML;
	
	var confirmbox = confirm('This operation will permanently delete the component "' + compid + '"\n\n Are you sure you want to continue?');
	if (confirmbox == false){
		body.className = 'none';
		return;
	}
	
	var data = 'operation=delete&recid=' + encodeURIComponent(recid) + '&id=' + id;
	if (fileOwner != null){
    	data += '&owner=' + encodeURIComponent(fileOwner);
    }
	var url = 'edit.html';
	var value = 'false';
	new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 	    				
		var response = transport.responseText;
		value = response.substring(7,response.indexOf('</value>'));			   					
	}});
	if (value == 'false'){
		alert('There was an error while deleting the component. Please reload the file and try again');
	}
	else{
		//delete from tree
		var listItem = link.parentNode;
		var ul = listItem.parentNode;
		ul.removeChild(listItem);
		if (ul.childNodes.length == 0){
			grandparent = ul.parentNode
			grandparent.removeChild(ul);
			if (id.length > 1){
				grandparentId = id.substring(0, id.lastIndexOf('-')).substring(0, id.lastIndexOf('-'));
				deleteLink = document.createElement('a');
			    deleteLink.setAttribute('id', 'delete_' + grandparentId);
			    deleteLink.onclick = new Function("javascript: deleteComponent('" + grandparentId + "')");
			
			    deleteImage = document.createElement('img');
			    deleteImage.setAttribute('src', '/images/editor/delete.png');
			    deleteImage.setAttribute('onmouseover', 'this.src=\'/images/editor/delete-hover.png\';')
    			deleteImage.setAttribute('onmouseout', 'this.src=\'/images/editor/delete.png\';')
			    deleteImage.className = 'deletelogo';
			    
			    deleteLink.appendChild(deleteImage);
			    
			    grandparent.appendChild(deleteLink);
			}
		}
	}
	//if current form has just been deleted display parent form
	if (id == currentForm){
		if (id.indexOf('-') == -1){
			displayForm('collectionLevel', '0', true);
		}
		else {
			displayForm(id.substring(0, id.lastIndexOf('-')), '0', true);
		}
	}

	refreshTree('someId');
	body.className = 'none';
}



function toDisk(){
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title');
		return;
	}
	if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false);
    }
    errors = $$('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before saving. Errors will be marked with red shading in the text box.');
    	return;
    } 
    var errors = $$('dateError');
    if (errors.length != 0){
    	alert('Please fix the error in the normalised date before saving. This field can only contain numbers and the character /.');
    	return;
    }
    //check the daoform details   
	var daodetails = checkDao();
    if (daodetails[0] == true){
 	    var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you proceed with this operation any incomplete URIs will not be included and the title and/or description information relating to the missing URI will be lost. All other content will be saved.\n\nDo you want to continue?');
 		if (confirmbox == false){
 			return;
 		}   			
 		else {			
 			var wipeids = daodetails[1];
 			var descids = daodetails[2];
 			for (var i=0; i< wipeids.length; i++){
 				document.getElementById(wipeids[i]).value = '';
 			}
 			for (var i=0; i< descids.length; i++){
 				document.getElementById(descids[i]).value = '<p></p>';
 			}
 		}
    }
	if (!saveForm(false)) {
        alert('Record could not be saved due to server error.');
        return false;
    }
	var url = 'save.html?operation=disk&recid=' + encodeURIComponent(recid);
	var markup = getMarkupStyle();
    url += '&markup=' + encodeURIComponent(markup)
	if (fileOwner != null){
		url += '&owner=' + encodeURIComponent(fileOwner);
	}
	window.location.href=url;
}


function emailRec(){
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title');
		return;
	}
	if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false);
    }
    var errors = $$('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before saving. Errors will be marked with red shading in the text box.');
    	return;
    } 
    var errors = $$('dateError');
    if (errors.length != 0){
    	alert('Please fix the error in the normalised date before saving. This field can only contain numbers and the character /.');
    	return;
    }
    //check the daoform details   
	var daodetails = checkDao();
    if (daodetails[0] == true){
 	    var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you proceed with this operation any incomplete URIs will not be included and the title and/or description information relating to the missing URI will be lost. All other content will be saved.\n\nDo you want to continue?');
 		if (confirmbox == false){
 			return;
 		}   			
 		else {			
 			var wipeids = daodetails[1];
 			var descids = daodetails[2];
 			for (var i=0; i< wipeids.length; i++){
 				document.getElementById(wipeids[i]).value = '';
 			}
 			for (var i=0; i< descids.length; i++){
 				document.getElementById(descids[i]).value = '<p></p>';
 			}
 		}
    }
	if (!saveForm(false)) {
        alert('Record could not be saved due to server error.');
        return false;
    }
	var url = 'email.html?operation=email&recid=' + encodeURIComponent(recid);
	var markup = getMarkupStyle();
    url += '&markup=' + encodeURIComponent(markup)
	if (fileOwner != null){
		url += '&owner=' + encodeURIComponent(fileOwner);
	}
	window.location.href=url;
}

function emailHub(){
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title');
		return;
	}
	if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false);
    }
    var errors = $$('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before saving. Errors will be marked with red shading in the text box.');
    	return;
    } 
    var errors = $$('dateError');
    if (errors.length != 0){
    	alert('Please fix the error in the normalised date before saving. This field can only contain numbers and the character /.');
    	return;
    }
    //check the daoform details   
	var daodetails = checkDao();
    if (daodetails[0] == true){
 	    var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you proceed with this operation any incomplete URIs will not be included and the title and/or description information relating to the missing URI will be lost. All other content will be saved.\n\nDo you want to continue?');
 		if (confirmbox == false){
 			return;
 		}   			
 		else {			
 			var wipeids = daodetails[1];
 			var descids = daodetails[2];
 			for (var i=0; i< wipeids.length; i++){
 				document.getElementById(wipeids[i]).value = '';
 			}
 			for (var i=0; i< descids.length; i++){
 				document.getElementById(descids[i]).value = '<p></p>';
 			}
 		}
    }
	if (!saveForm(false)) {
        alert('Record could not be saved due to server error.');
        return false;
    }
	var url = 'emailhub.html?operation=emailhub&recid=' + encodeURIComponent(recid);
	if (fileOwner != null){
		url += '&owner=' + encodeURIComponent(fileOwner);
	}
	window.location.href=url;
}


function viewXml(){
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title');
		return;
	}
	if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false);
    }
    errors = $$('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before viewing. Errors will be marked with red shading in the text box.');
    	return;
    } 
    var errors = $$('dateError');
    if (errors.length != 0){
    	alert('Please fix the error in the normalised date before viewing. This field can only contain numbers and the character /.');
    	return;
    }
    //check the daoform details   
	var daodetails = checkDao();
    if (daodetails[0] == true){
 	    var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you proceed with this operation any incomplete URIs will not be included and the title and/or description information relating to the missing URI will be lost. All other content will be saved.\n\nDo you want to continue?');
 		if (confirmbox == false){
 			return;
 		}   			
 		else {			
 			var wipeids = daodetails[1];
 			var descids = daodetails[2];
 			for (var i=0; i< wipeids.length; i++){
 				document.getElementById(wipeids[i]).value = '';
 			}
 			for (var i=0; i< descids.length; i++){
 				document.getElementById(descids[i]).value = '<p></p>';
 			}
 		}
    }
	if (!saveForm(false)) {
        alert('Record could not be saved due to server error.');
        return false;
    }
	var url = 'edit.html?operation=xml&recid=' + encodeURIComponent(recid);
	var markup = getMarkupStyle();
	url += '&markup=' + encodeURIComponent(markup)
	if (fileOwner != null){
		url += '&owner=' + encodeURIComponent(fileOwner);
	}
	window.open(url, '_blank')
}


function previewRec(){
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title')
		return;
	}
	if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false);
    }
    errors = $$('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before viewing. Errors will be marked with red shading in the text box.');
    	return;
    } 
    var errors = $$('dateError');
    if (errors.length != 0){
    	alert('Please fix the error in the normalised date before viewing. This field can only contain numbers and the character /.');
    	return;
    }
    //check the daoform details   
	var daodetails = checkDao();
    if (daodetails[0] == true){
 	    var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you proceed with this operation any incomplete URIs will not be included and the title and/or description information relating to the missing URI will be lost. All other content will be saved.\n\nDo you want to continue?');
 		if (confirmbox == false){
 			return;
 		}   			
 		else {			
 			var wipeids = daodetails[1];
 			var descids = daodetails[2];
 			for (var i=0; i< wipeids.length; i++){
 				document.getElementById(wipeids[i]).value = '';
 			}
 			for (var i=0; i< descids.length; i++){
 				document.getElementById(descids[i]).value = '<p></p>';
 			}
 		}
    }
	if (!saveForm(false)) {
        alert('Record could not be saved due to server error.');
        return false;
    }
	url = 'edit.html?operation=preview&recid=' + encodeURIComponent(recid);	
	if (fileOwner != null){
		url += '&owner=' + encodeURIComponent(fileOwner);
	}
	window.open(url, '_blank')
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
			var url = 'edit.html';
			var data = 'operation=reassign&recid=' + encodeURIComponent(recid) + '&user=' + encodeURIComponent(user);
			var ajax = new Ajax.Request(url, {
			         method:'post', 
			         asynchronous:true, 
			         postBody:data, 
			         evalScripts:true, 
			         onSuccess: function(transport) {  	
				       location.href="menu.html";
			         },
			         onLoading: function(){
			             $('storeDirForm').hide();
                         $('userFileListDiv').insert("<p>Reassigning record to user: " + user + "</p>").insert(new Element('img', {src: '/images/editor/ajax-loader.gif', alt: ''}));
			         }
			});
		}
	}
}


function addElement(s){
	$(s).toggle();
  	if ($(s).visible($(s))){
  		$(('link' + s)).update('hide content');		
  	}
 	else {
 		if (s == 'daooptnsdiv'){
 			$(('link' + s)).update('add content');
 		}
 		else {
	 		var value = document.getElementById(s).getValue(document.getElementById(s)).strip();
		 	if (value == '' || value == ' ' || value == '<p></p>' || value.replace(/[\s]+/g, ' ') == '<p> </p>'){
				$(('link' + s)).update('add content');	
		  	} 
		  	else { 
				$(('link' + s)).update('show content');
		  	}
		}
	}
}


function cloneTextField(cloner){
    /* 
     * Function to add a new form field by cloning the previous one
     * DEPRECATED in favour of more powerful cloneField()
     * 
     * John Harrison 2012
     *
     * cloner is the link/span/button that was clicked to call this function
     */
     // Get the thing to be cloned, 'donor'
     var donor = $(cloner).previous('input');
     var container = $(donor).ancestors()[0];
     // Create a clone
     var child = $(donor).clone(false);
     // Modify name and id
     var positionRegex = /\[\d+\]$/;
     var donorid = $(donor).identify();
     if (positionRegex.test(donorid)){
         // increment position predicate for child
         var donorPos = positionRegex.exec(donorid).toString();
         donorPos = new Number(donorPos.substr(1, donorPos.length-2));
         var childPos = donorPos + 1;
         child.id = donorid.replace(positionRegex, '[' + childPos + ']');
         child.name = donor.name.replace(positionRegex, '[' + childPos + ']');
     } else {
         // Add position predicate to donor and child
         child.id = donorid + '[2]';
         child.name = donor.name + '[2]'
         donor.id = donorid + '[1]';
         donor.name = donor.name + '[1]';
     }
     // clear the value
     child.value = '';
     // Add to document
     container.insertBefore(child, cloner);
}


function cloneAndIncrement(donor){
    /* 
     * Function to return a clone of donor, with names and ids incremented
     */
    if (donor.nodeType == Node.TEXT_NODE){
        return donor.textContent;
    }
    // Create a clone
    var clone = $(donor).clone(false);
    // Modify name(s) and id(s)
    var positionRegex = /\[\d+\](?!\.*\[\d+\])/;
    var donorid = $(donor).identify();
    if (positionRegex.test(donorid)){
        // increment position predicate for child
        var donorPos = positionRegex.exec(donorid).toString();
        donorPos = new Number(donorPos.substr(1, donorPos.length-2));
        var clonePos = donorPos + 1;
        clone.id = donorid.replace(positionRegex, '[' + clonePos + ']');
        clone.name = donor.name.replace(positionRegex, '[' + clonePos + ']');
     } else {
         // Add position predicate to donor and child
         clone.id = donorid + '[2]';
         clone.name = donor.name + '[2]'
         donor.id = donorid + '[1]';
         donor.name = donor.name + '[1]';
    }
    // clear the value and remove any disabled attributes 
    $(clone).writeAttribute({
        value: null,
        disabled: false,
        readOnly: false
    });
    // Clone all children of donor
    // Use childNodes because it keeps text nodes, where childElements doesn't 
    $A(donor.childNodes).each(function(item){clone.insert(cloneAndIncrement(item))});
    return clone;
}


function cloneField(cloner){
    /* 
     * Function to add new form field(s) by cloning previous DOM element
     *
     * If the previous DOM element is a block containing multiple inputs, then 
     * all inputs contained within should be cloned.
     * 
     * John Harrison 2012
     *
     * cloner is the link/span/button that was clicked to call this function
     */
    // Find donor and container elements
    var donor = $(cloner).previous();
    var container = $(donor).ancestors()[0];
    // Create a clone
    var clone = cloneAndIncrement(donor);
    // Modify name(s) and id(s)
    //$(clone).find().each(incrementCloneIds);
    // Add to document before the 'cloner' button
    container.insertBefore(clone, cloner);
}


//================================================================================================
// passive UI Functions to update left hand column navigation menu

function updateTitle(field) {
  	var link = document.getElementById(currentForm);
  	var title = (document.getElementById('did/unittitle')).value;
  	if (title.indexOf('<') != -1){
		title = title.replace(/<\/?\S+?>/g, '');
  	}
    var uid = Prototype.Selector.find($$("input[id*='unitid[']"), "input[readOnly]");
    if (typeof(uid) == 'undefined'){
        // Fall back to first occurring
        var uid = $("unitid[1]");
    }
  	var id = uid.value;
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
  	var title = (document.getElementById('did/unittitle')).value;
  	if (title.indexOf('<') != -1){
		title = title.replace(/<\/?\S+?>/g, '');
  	}
    var cc = Prototype.Selector.find($$("input[id*='countrycode[']"), "input[readOnly]");
    if (typeof(cc) == 'undefined'){
        // Fall back to first occurring
        var cc = $("countrycode[1]");
    }
    var rc = Prototype.Selector.find($$("input[id*='archoncode[']"), "input[readOnly]");
    if (typeof(rc) == 'undefined'){
        // Fall back to first occurring
        var rc = $("archoncode[1]");
    }
    var uid = Prototype.Selector.find($$("input[id*='unitid[']"), "input[readOnly]");
    if (typeof(uid) == 'undefined'){
        // Fall back to first occurring
        var uid = $("unitid[1]");
    }
  	var countryCode = cc.value.toLowerCase();
  	var repositoryCode = rc.value;
  	var id = uid.value;
  	
  	if (title == '' && id == ''){
  		link.innerHTML = currentForm;
  	}
  	else {
    	link.innerHTML = id + ' - ' + title;
	}
	var match = true;
	if (currentForm == 'collectionLevel'){ 
		if ((document.getElementById('pui')).getAttribute('disabled') == null || (document.getElementById('pui')).getAttribute('disabled') == false){
			lowerCaseId = '';
			for (var i=0; i<id.length; i++){
				if (id.charAt(i) != ' '){
					lowerCaseId += id.charAt(i).toLowerCase();
				}
			}
			for (var i=0; i < countryCode.length; i++){
				if (countryCode.charAt(i) != lowerCaseId.charAt(i)){
					match = false;
				}
			}
			lowerCaseId = lowerCaseId.replace(/ /g, '').replace(/\\/g, '-').replace(/'/g, '');
			if (match == true){
				for (var i=0; i < repositoryCode.length; i++){
					if (repositoryCode.charAt(i) != lowerCaseId.charAt(i+2)){
						match = false;
					}
				}
				if (match == true){
					(document.getElementById('pui')).value = lowerCaseId;
				}
				else {
					(document.getElementById('pui')).value = countryCode + repositoryCode + lowerCaseId;
				}
			}
			else {
				(document.getElementById('pui')).value = countryCode + repositoryCode + lowerCaseId;
			}
		}	
	}
}


//================================================================================================
//validation related functions


function findRequiredFields(){

	if (currentForm == 'collectionLevel'){
		var reqList = required_xpaths;
		//check there is a language
		var lang = document.getElementById('lang_name');
		var langcode = document.getElementById('lang_code');
		if (document.getElementById('addedlanguages').style.display == 'none'){
			lang.style.borderColor = 'red';
			langcode.style.borderColor = 'red';
		}
		else {
			lang.style.borderColor = 'white';
			langcode.style.borderColor = 'white';			
		}
	}
	else if (currentForm == 'template'){
		var reqList = required_xpaths_template;
	}
	else {
		var reqList = required_xpaths_components;		
	}
	for (var i=0; i<reqList.length; i++){
		if (document.getElementById(reqList[i])){
			var elem = document.getElementById(reqList[i]);
			value = elem.value.strip();
			if (value == '' || value == ' ' || value == '<p></p>' || value.replace(/[\s]+/g, '') == '<p> </p>'){	
				elem.style.borderColor = 'red';
			
			}
			else {	
				elem.style.borderColor = 'white';
			}
		}
		else if (document.getElementById(reqList[i] + '[1]')){
			var elem = document.getElementById(reqList[i] + '[1]');
			value = elem.value.strip();
			if (value == '' || value == ' ' || value == '<p></p>' || value.replace(/[\s]+/g, '') == '<p> </p>'){
				elem.style.borderColor = 'red';	
			}		
			else {
				elem.style.borderColor = 'white';
			}
		}
		else if (document.getElementById(reqList[i].split('/@').join('[1]/@'))){
            var elem = document.getElementById(reqList[i].split('/@').join('[1]/@'));
            value = elem.value.strip();
            if (value == '' || value == ' ' || value == '<p></p>' || value.replace(/[\s]+/g, '') == '<p> </p>'){
                elem.style.borderColor = 'red'; 
            }       
            else {
                elem.style.borderColor = 'white';
            }
        }
	}	
}

function checkDao(){
    var daodiv = document.getElementById('daocontainer');
    var divs = daodiv.getElementsByTagName('div');
    var daoerror = false;
    var descids = [];   
    var wipeids = [];
    for (var i=0; i<divs.length; i++){
    	if (divs[i].className == 'embed' || divs[i].className == 'new'){
    		var inputs = divs[i].getElementsByTagName('input');
    		var href = '';
    		var desc = '';
    		var descid;
    		for (var j=0; j<inputs.length; j++){
    			if (inputs[j].name.search(/href/) != -1){
    				href = inputs[j].value;
    			}
    			else if (inputs[j].name.search(/desc/) != -1){
    				desc = inputs[j].value;
					descid = inputs[j].id;
    			}
    		}
    		if (href.strip() == '' && (desc.strip() != '' && desc.strip() != '<p></p>' && desc.strip().replace('/[\s]+/g', ' ') != '<p> </p>')){
    			descids[descids.length] = descid;
				daoerror = true;
    		}   		
    	} else if (divs[i].className == 'thumb'){
    		var inputs = divs[i].getElementsByTagName('input');
    		var href1 = '';
    		var href2 = '';
    		var desc = '';	
    		var descid = '';
    		for (var j=0; j<inputs.length; j++){
    			if (inputs[j].name.search(/href1/) != -1){
    				href1 = inputs[j].value;
    				href1id = inputs[j].id;
    			}
    			if (inputs[j].name.search(/href2/) != -1){
    				href2 = inputs[j].value;
    				href2id = inputs[j].id;
    			}
    			else if (inputs[j].name.search(/desc/) != -1){
    				desc = inputs[j].value;
					descid = inputs[j].id;
    			}
    		}	
    		if (href1.strip() == '' || href2.strip() == ''){
    			if (href1.strip() != '' || href2.strip() != '' || (desc.strip() != '' && desc.strip() != '<p></p>' && desc.strip().replace('/[\s]+/g', ' ') != '<p> </p>')){
	    			wipeids[wipeids.length] = href1id;
	    			wipeids[wipeids.length] = href2id;
	    			descids[descids.length] = descid;
					daoerror = true;
	    		}
    		}
    	} else if (divs[i].className == 'multiple'){
    		var inputs = divs[i].getElementsByTagName('input');
    		var length = inputs.length;
    		var total = (length-2)/3;
    		var problems = false;
    		var list = new Array();
    		var pairs = new Array(); 		
    		var ids = new Array();
    		for (var j=0; j < total; j++){
    			pairs[j] = [];
    			ids[j] = [];
    		}
    		var desc = '';
    		var descid = '';	
    		for (var j=0; j<length-1; j++){
				var name = inputs[j].name;
				if (name.search(/desc/) != -1){
					desc = inputs[j].value;
					descid = inputs[j].id;
				}
				else {
					var number = (name.split('|')[1].match(/\d+/))-1;
					if (inputs[j].name.search(/href/) != -1){
						pairs[number][0] = inputs[j].value;
						ids[number][0] = inputs[j].id;
					}
					if (inputs[j].name.search(/title/) != -1){
						pairs[number][1] = inputs[j].value;
						ids[number][1] = inputs[j].id;
					}
				}
    		}
    		var wipecount = 0;
    		for (var j=0; j<pairs.length; j++){
    			if (pairs[j].length > 0 && pairs[j][0].strip() == ''){
    				wipecount++;
    				if (pairs[j][1].strip() != ''){  				
	    				wipeids[wipeids.length] = ids[j][0];
	    				wipeids[wipeids.length] = ids[j][1];
	    				problems = true;
	    			}  				
    			}
    		}  
    		if (wipecount == total){
 				descids[descids.length] = descid;
 			} 		
			if (problems == false){
				if ((desc.strip() != '' || desc.strip() != '<p></p>' || desc.strip().replace(/[\s]+/g, ' ') != '<p> </p>')){
					var entries = false;
					for (var j = 0; j < pairs.length; j++){
						if (pairs[j].length > 0 && pairs[j][0].strip() != ''){
							entries = true;
						}
					}
					if (entries == false){	
						descids[descids.length] = descid;
						problems = true;
					}
				}
			}
			if (problems == true){				
    			daoerror = true;
    			
   			}    		   		
    	}
    }
    return [daoerror, wipeids, descids];

}



function conflicts(recid){
	var conflict = null;
	var error = false;
	if (recid != null){
		
		var url = 'edit.html'
		var data = 'operation=checkId&id=' + encodeURIComponent(recid) + '&store=editStore';
		new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 
			if (response.substring(0, 4) == "<!--"){
				error = true;
			}
			var response = transport.responseText;
			conflict = response.substring(7,response.indexOf('</value>'));
		}});
	}
	else {
		return false;
	}
	if (error == true){
		alert('A problem occurred when trying to perform this operation. Please check that the spoke is responding to searches before trying again.');
	}
	else {
		if (conflict == 'true'){
			return true;
		}
		else {
			return false;
		}
	}
}




function checkEditStoreConflicts(form){
	var filepath = null;
	for (var i=0; i < document.getElementById(form).filepath.length; i++) {
		if (document.getElementById(form).filepath[i].checked) {
	      	filepath = document.getElementById(form).filepath[i].value;
	    }
	}
	if (filepath == null && document.getElementById(form).filepath){
		if (document.getElementById(form).filepath.checked) {
	      	filepath = document.getElementById(form).filepath.value;
	    }
	}
	if (filepath == null){
		filepath = document.getElementById('localEdit').value;
	}
	if (filepath != null){
	    var conflict = 'false';
	    var overwrite = 'false';
	    var error = false;
	    var users = null;
		var url = 'edit.html'
		var data = 'operation=getCheckId&filepath=' + filepath;
				new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 
			var response = transport.responseText;
			if (response.substring(0, 4) == "<!--"){
				error = true;
			}			
			conflict = response.substring(response.indexOf('<value>')+7, response.indexOf('</value>'));
			if (response.indexOf('<overwrite>') > -1){
				overwrite = response.substring(response.indexOf('<overwrite>')+11, response.indexOf('</overwrite>'));
			}
			if (response.indexOf('<id>') > -1){
				id = response.substring(response.indexOf('<id>')+4, response.indexOf('</id>'));
			}
			if (response.indexOf('<users>') > -1){
				users = response.substring(response.indexOf('<users>')+7, response.indexOf('</users>'));
			}
		}});
		if (error == true){
			alert('A problem occurred when trying to perform this operation. Please check that the spoke is responding to searches before trying again.');
			return;	
		}
		if (conflict == 'false'){
			document.getElementById(form).submit();
		}
		else if (overwrite == 'true'){
			alert('You already have this file open for editing as ' + id + '. Please delete the file currently in the Draft File Store before reloading');
			return;			
		}
		else if (users != null){
			var ok = confirmOp('The following users already have this file open for editing\n\n ' + users + '\n\n Are you sure you want to continue?');
			if (ok){
				document.getElementById(form).submit();
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
	var url = 'edit.html';
	var fieldvalue = field.value.replace(/%/g, '%25').replace(/&/g, '%26').replace(/#/g, '%23').replace(/;/g, '%3B');
	var data = 'operation=validate&field=' + field.name + '&text=' + fieldvalue;
    function success(transport)	{       
        var response = transport.responseXML;
        var valid = response.getElementsByTagName("valid")[0].firstChild.nodeValue;
        if (valid == 'false'){
            try {
                var msg = response.getElementsByTagName("message")[0].firstChild.nodeValue
            } catch(err) {
                var msg = "";
            }
            var attrs = {
                'class': 'menuFieldError',
                'title': msg
            };
        } else {
            var attrs = {
                'class': 'menuField',
                'title': null
            };
        }
        $(field).writeAttribute(attrs);
        findRequiredFields();
    }
    var params = {
        method: 'post',
        asynchronous: asynch,
        parameters: data,
        onSuccess: success
    }
    // Send the request
	var ajax = new Ajax.Request(url, params);
}

function validateNormdateDelay(field, asynch){
	clearTimeout(timeout);
	timeout = setTimeout(function() {validateDate(field, asynch)}, 2000);
}

function validateNormdate(field, asynch){
	clearTimeout(timeout);
	validateDate(field, asynch);
}

function validateDate(field, asynch){
	var data = field.value;
	var valid = true;
	for (var i=0; i<data.strip().length; i++){
		if (data.charAt(i) != '/' && data.charAt(i) != '-' && isNaN(parseInt(data.charAt(i)))){
			valid = false;
		}
	}	
	if (valid == false){
		field.className = 'dateError';
	}
	else {
		field.className = 'dateOK';
	}
}


function checkEditStore(){
	var value = false;
	var owner = '';
	var error = false;
	if (currentForm == 'collectionLevel'){		
		if (recid == null || recid == 'notSet'){
		    // find best unitid
	        var cc = Prototype.Selector.find($$("input[id*='countrycode[']"), "input[readOnly]");
	        if (typeof(cc) == 'undefined'){
	            // Fall back to first occurring
	            var cc = $("countrycode[1]");
	        }
	        var rc = Prototype.Selector.find($$("input[id*='archoncode[']"), "input[readOnly]");
	        if (typeof(rc) == 'undefined'){
	            // Fall back to first occurring
	            var rc = $("archoncode[1]");
	        }
	        var uid = Prototype.Selector.find($$("input[id*='unitid[']"), "input[readOnly]");
	        if (typeof(uid) == 'undefined'){
	            // Fall back to first occurring
	            var uid = $("unitid[1]");
	        }
			if (cc.value != ''){
				if (rc.value != ''){
					if (uid.value != ''){
						var id = cc.value.toLowerCase() + rc.value + '-' + uid.value.replace(' ', '').toLowerCase();
						var url = 'edit.html'
						var data = 'operation=checkEditId&id=' + encodeURIComponent(id);
						new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 	    				
						    var response = transport.responseText;
						    if (response.substring(0, 4) == "<!--"){
								error = true;
							}						    					
						    idExists = response.substring(response.indexOf('<value>')+7, response.indexOf('</value>'));	
						    if (idExists == 'true'){
						    	value = true;
						    	owner = response.substring(response.indexOf('<owner>')+7, response.indexOf('</owner>'));			    
						    }	
							
			 			}});
					} 
				} 
			} 
		} 
	}
	if (error == true){
		return ['error'];
	}
	else {
		var values = [value, owner];
		return values;
	}
}



function checkRequiredData(){
	if (document.getElementById('did/unittitle').value == ''){
		return false;
	}
    var cc = Prototype.Selector.find($$("input[id*='countrycode[']"), "input[readOnly]");
    if (typeof(cc) == 'undefined'){
        // Fall back to first occurring
        var cc = $("countrycode[1]");
    }
    var rc = Prototype.Selector.find($$("input[id*='archoncode[']"), "input[readOnly]");
    if (typeof(rc) == 'undefined'){
        // Fall back to first occurring
        var rc = $("archoncode[1]");
    }
    var uid = Prototype.Selector.find($$("input[id*='unitid[']"), "input[readOnly]");
    if (typeof(uid) == 'undefined'){
        // Fall back to first occurring
        var uid = $("unitid[1]");
    }
	if (uid.value == ''){
		return false;
	}
	else if (rc.value == '' && currentForm == 'collectionLevel'){
		return false;
	}
	else if (cc.value == '' && currentForm == 'collectionLevel'){
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
  	var keyboard = document.getElementById('keyboard'); 
  	if (keyboard.style.display == 'none'){
  		keyboard.style.display = 'block';
  	}
  	else {
  		keyboard.style.display = 'none';
  	}
//  	keyboard.toggle();  
  	showCharTable('lower');
}


function showCharTable(type){
	if (type == 'lower'){
  		(document.getElementById('chartablelower')).style.display = 'block';
  		(document.getElementById('chartableupper')).style.display = 'none';
  	}
  	else if (type == 'upper'){
  		(document.getElementById('chartableupper')).style.display = 'block';
  		(document.getElementById('chartablelower')).style.display = 'none';   	
  	}
  	else {
		(document.getElementById('chartable' + currentCharTable)).style.display = 'block';
  	}
  	(document.getElementById('hideicon')).style.display = 'inline';
  	(document.getElementById('showicon')).style.display = 'none';
}


function hideCharTable(){
	if ((document.getElementById('chartableupper')).style.display == 'block'){
		currentCharTable = 'upper';
	}
	else {
		currentCharTable = 'lower';
	}
  	(document.getElementById('chartableupper')).style.display = 'none';
  	(document.getElementById('chartablelower')).style.display = 'none';
  	
  	(document.getElementById('showicon')).style.display = 'inline';
  	(document.getElementById('hideicon')).style.display = 'none';
}


//====================================================================================================
//context menu related functions 
function hideAllMenus(){
	document.getElementById('tagmenu').style.display = 'none';
	hideSubMenus();
}


function showSubMenu(type, pos, parent){
	if (parent == 'tagmenu'){
		hideSubMenus();
	}
	var menu = null;
	
	menu = (document.getElementById(type + 'menu'));

	mainMenu = document.getElementById(parent);
	size = mainMenu.getElementsByTagName('LI');
	menu.style.top = parseInt(mainMenu.style.top) + ((mainMenu.offsetHeight / size.length) * pos) + 'px';
	var width = document.getElementById('content').offsetWidth;
	// if we don't have enough space on the right
	if (parseInt(mainMenu.style.left) + (mainMenu.offsetWidth * 2) > width){
		menu.style.left = parseInt(mainMenu.style.left) - (mainMenu.offsetWidth)  + 'px';
	}
	//if we do have enough space on the right
	else {
		menu.style.left = parseInt(mainMenu.style.left) + (mainMenu.offsetWidth) + 'px';
	}
	menu.style.display = 'block';
}


function hideSubMenus(){
	(document.getElementById('linkmenu')).style.display = 'none';
	(document.getElementById('titlemenu')).style.display = 'none';
	(document.getElementById('listmenu')).style.display = 'none';
	(document.getElementById('fontmenu')).style.display = 'none';
	(document.getElementById('archivalmenu')).style.display = 'none';
}

function hideSubMenu(type){
	(document.getElementById(type + 'menu')).style.display = 'none';
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

function addFile(id){
	var doform = document.getElementById(id);
	var tbody = doform.getElementsByTagName('tbody')[0];
	var rowList = tbody.getElementsByTagName('tr');	
	var rows = rowList.length;	
	var jsrow = rowList[rows-2];
	
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
 	href.onclick = function () {setCurrent(this); },
 	href.setAttribute('name', 'dao' + daocount + '|href' + nextfile);
 	href.setAttribute('id', 'dao' + daocount + '|href' + nextfile);
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
	href.onclick = function () {setCurrent(this); },
	href.setAttribute('name', 'dao' + daocount + '|title' + nextfile);
	href.setAttribute('id', 'dao' + daocount + '|title' + nextfile);
	href.setAttribute('size', '70');
	td = document.createElement('td');		
	td.appendChild(href);
	
	tr.appendChild(td);
	
	tbody.insertBefore(tr, jsrow);      			
   			 
 //role info
    role = document.createElement('input');
   	role.setAttribute('type', 'hidden');
   	role.setAttribute('name', 'dao' + daocount + '|role' + nextfile);
   	role.setAttribute('id', 'dao' + daocount + '|role' + nextfile);
   	role.setAttribute('value', 'reference');
   	doform.insertBefore(role, tbody.parentNode);				
		
}

function createDaoForm(){

	var container = document.getElementById('daocontainer');
	var create = document.getElementById('createnewdao');
	var type = document.getElementById('daoselect').value;

	if (type != 'null'){
		var doform = document.createElement('div');
		daocount++;
		doform.setAttribute('id', 'daoform' + daocount);
		doform.className = type; 
		
		if (type == 'new' || type == 'embed') {
		
			var span = document.createElement('b');
			if (type == 'new'){
				var text = document.createTextNode('Link to file');
			}
			if (type == 'embed'){
				var text = document.createTextNode('Display image');
			}
			span.appendChild(text);
		
			var table = document.createElement('table');
			table.className = 'daotable';
   			var tbody = document.createElement('tbody');
   			
   			
   		//file location   			
   			var tr = document.createElement('tr');
   			var td = document.createElement('td');
   			td.appendChild(document.createTextNode('File URI: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			var href = document.createElement('input');
   			href.setAttribute('type', 'text');
   			href.onclick = function () {setCurrent(this); },
   			href.setAttribute('name', 'dao' + daocount + '|href' );
   			href.setAttribute('id', 'dao' + daocount + '|href' );
   			href.setAttribute('size', '70');
   			td = document.createElement('td');		
   			td.appendChild(href);
   			
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
			desc.onclick = function () {setCurrent(this); },
			desc.onkeypress = function () {validateFieldDelay(this, 'true'); },
			desc.onchange = function () {validateField(this, 'true') },
   			desc.setAttribute('name', 'dao' + daocount + '|desc' );
   			desc.setAttribute('id', 'dao' + daocount + '|desc' );
   			desc.setAttribute('size', '70');
   			desc.setAttribute('value', '<p></p>');
   			desc.className = 'menuField';
 			td = document.createElement('td');
   			td.appendChild(desc);
   			
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr);  			

 	//show  			   			
   			var show = document.createElement('input');
   			show.setAttribute('type', 'hidden');
   			show.setAttribute('name', 'dao' + daocount + '|' + type );
   			show.setAttribute('value', type);

	//delete button
	
			var button = document.createElement('input');
			button.setAttribute('type', 'button');
			var string = 'daoform' + daocount;
			button.onclick = function () {deleteDao(string); },
			button.value = 'Delete';
			
			
			table.appendChild(tbody);
			doform.appendChild(span);
			doform.appendChild(table);
   			doform.appendChild(show);
   			doform.appendChild(button);
   			container.insertBefore(doform, create);   
   			   			
		} 
		else if (type=='thumb') {
		
			var span = document.createElement('b');
			var text = document.createTextNode('Thumbnail link to file');		
			span.appendChild(text);
				
			var table = document.createElement('table');
			table.className = 'daotable';
   			var tbody = document.createElement('tbody');

	//thumbnail location   			
  			var tr = document.createElement('tr');
   			var td = document.createElement('td');
   			td.appendChild(document.createTextNode('Thumbnail URI: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			var href = document.createElement('input');
   			href.setAttribute('type', 'text');
   			href.onclick = function () {setCurrent(this); },
   			href.setAttribute('name', 'dao' + daocount + '|href1' );
   			href.setAttribute('id', 'dao' + daocount + '|href1' );
   			href.setAttribute('size', '70');
   			td = document.createElement('td');		
   			td.appendChild(href);
   			
   			tr.appendChild(td);   			
   			tbody.appendChild(tr);  
   			
   	//role info
    		var role1 = document.createElement('input');
   			role1.setAttribute('type', 'hidden');
   			role1.setAttribute('name', 'dao' + daocount + '|thumb');
   			role1.setAttribute('id', 'dao' + daocount + '|thumb');
   			role1.setAttribute('value', 'thumb');
   			

	//file location
  			tr = document.createElement('tr');
   			td = document.createElement('td');
   			td.appendChild(document.createTextNode('File URI: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			href = document.createElement('input');
   			href.setAttribute('type', 'text');
   			href.onclick = function () {setCurrent(this); },
   			href.setAttribute('name', 'dao' + daocount + '|href2' );
   			href.setAttribute('id', 'dao' + daocount + '|href2' );
   			href.setAttribute('size', '70');
   			td = document.createElement('td');		
   			td.appendChild(href);
   			
   			tr.appendChild(td);   			
   			tbody.appendChild(tr);  


 	//role info
    		var role2 = document.createElement('input');
   			role2.setAttribute('type', 'hidden');
   			role2.setAttribute('name', 'dao' + daocount + '|reference');
   			role2.setAttribute('id', 'dao' + daocount + '|reference');
   			role2.setAttribute('value', 'reference');


	//DAO desciption
   			tr = document.createElement('tr');
   			td = document.createElement('td');
   			td.appendChild(document.createTextNode('Description: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			var desc = document.createElement('input');
   			desc.setAttribute('type', 'text');
   			desc.onclick = function () {setCurrent(this); },
			desc.onkeypress = function () {validateFieldDelay(this, 'true'); },
			desc.onchange = function () {validateField(this, 'true') },
   			desc.setAttribute('name', 'dao' + daocount + '|desc' );
   			desc.setAttribute('id', 'dao' + daocount + '|desc' );
   			desc.setAttribute('size', '70');
   			desc.setAttribute('value', '<p></p>');
   			desc.className = 'menuField';
 			td = document.createElement('td');
   			td.appendChild(desc);
   			
   			tr.appendChild(td);   			
   			tbody.appendChild(tr);  			

		
	//delete button
	
			var button = document.createElement('input');
			button.setAttribute('type', 'button');
			var string = 'daoform' + daocount;
			button.onclick = function () {deleteDao(string); },
			button.value = 'Delete';			
			
			
			table.appendChild(tbody);
			doform.appendChild(span);
			doform.appendChild(table);	
			doform.appendChild(role1);
			doform.appendChild(role2);
			doform.appendChild(button);
   			container.insertBefore(doform, create);   
		
		}
		else if (type=='multiple'){
		
			var span = document.createElement('b');
			var text = document.createTextNode('Link to multiple files');		
			span.appendChild(text);
		
   		   	var table = document.createElement('table');
   		   	table.className = 'daotable';
   			var tbody = document.createElement('tbody');
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
	   			href.onclick = function () {setCurrent(this); },
	   			href.setAttribute('name', 'dao' + daocount + '|href' + i);
	   			href.setAttribute('id', 'dao' + daocount + '|href' + i);
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
	   			href.onclick = function () {setCurrent(this); },
	   			href.setAttribute('name', 'dao' + daocount + '|title' + i);
	   			href.setAttribute('id', 'dao' + daocount + '|title' + i);
	   			href.setAttribute('size', '70');
	   			td = document.createElement('td');		
	   			td.appendChild(href);
	   			
	   			tr.appendChild(td);
	   			
	   			tbody.appendChild(tr);  
	   			 
	 	//role info
	    		role = document.createElement('input');
	   			role.setAttribute('type', 'hidden');
	   			role.setAttribute('name', 'dao' + daocount + '|role' + i);
	   			role.setAttribute('id', 'dao' + daocount + '|role' + i);
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
   			var string = 'daoform' + daocount;
  			link.onclick = function () {addFile(string); };
   			td.appendChild(link);
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr); 
   			
   		//DAO desciption
   			tr = document.createElement('tr');
   			td = document.createElement('td');
   			td.appendChild(document.createTextNode('Description of group: '));
   			td.className = 'label';
   			tr.appendChild(td);
   			
   			var desc = document.createElement('input');
   			desc.setAttribute('type', 'text');
   			desc.onclick = function () {setCurrent(this); },
			desc.onkeypress = function () {validateFieldDelay(this, 'true'); },
			desc.onchange = function () {validateField(this, 'true') },
   			desc.setAttribute('name', 'dao' + daocount + '|desc');
   			desc.setAttribute('id', 'dao' + daocount + '|desc');
   			desc.setAttribute('size', '70');
   			desc.setAttribute('value', '<p></p>');
   			desc.className = 'menuField';
 			td = document.createElement('td');
   			td.appendChild(desc);
   			
   			tr.appendChild(td);
   			
   			tbody.appendChild(tr);  	
   			
   			
   		//delete button
	
			var button = document.createElement('input');
			button.setAttribute('type', 'button');
			var string = 'daoform' + daocount;
			button.onclick = function () {deleteDao(string); },
			button.value = 'Delete';	
   			
   			table.appendChild(tbody);
   			doform.appendChild(span);
			doform.appendChild(table);
			doform.appendChild(button);
   			container.insertBefore(doform, create);   			
   		}
		
	}
	document.getElementById('daoselect').value = 'null';
}


function deleteDao(id){

	var container = document.getElementById('daocontainer');
	var form = document.getElementById(id);	
	container.removeChild(form);
	
}


function checkButtons(){
	if (document.getElementById('pui').value.strip() == ''){
		document.getElementById('xml-button').setAttribute('disabled', 'disabled');
		document.getElementById('xml-button').setAttribute('title', 'File must be saved before this operation can be performed');
		document.getElementById('preview-button').setAttribute('disabled', 'disabled');
		document.getElementById('preview-button').setAttribute('title', 'File must be saved before this operation can be performed');
		document.getElementById('email-button').setAttribute('disabled', 'disabled');
		document.getElementById('email-button').setAttribute('title', 'File must be saved before this operation can be performed');
		document.getElementById('disk-button').setAttribute('disabled', 'disabled');
		document.getElementById('disk-button').setAttribute('title', 'File must be saved before this operation can be performed');		
		document.getElementById('emailhub-button').setAttribute('disabled', 'disabled');
		document.getElementById('emailhub-button').setAttribute('title', 'File must be saved before this operation can be performed');
		document.getElementById('addC').setAttribute('disabled', 'disabled');
		document.getElementById('addC').setAttribute('title', 'File must be saved before this operation can be performed');			
		document.getElementById('collectionLevel').onclick = null;	
	}
}

function enableMenuButtons(){
	var inputs = document.getElementsByTagName('input');
	for (var i=0; i< inputs.length; i++){
		if (inputs[i].getAttribute('type') == 'button' || inputs[i].getAttribute('type') == 'submit'){
			inputs[i].removeAttribute('disabled');
		}
	}
	if (document.getElementById('userSelect')){
		var select = document.getElementById('userSelect');
		select.removeAttribute('disabled');
	}
}


function deleteUser(username){
	location.href="users.html?operation=deleteuser&confirm=true&user=" + username;
}

function deleteInst(inst){
	location.href="users.html?operation=deleteinst&confirm=true&inst=" + inst;
}

function findContacts() {
	var contactName = document.getElementById('usernameinput').value;
	var placeholder = document.getElementById('placeholderdiv')
	var url = 'users.html';
	var data = 'operation=findcontacts&un=' + contactName;
	
	if (contactName != ''){
		var ajax = new Ajax.Updater(placeholder, url, {method: 'post', asynchronous: true, parameters: data, onSuccess: function(transport) { 		

	    					    		     
		}});
	}
}