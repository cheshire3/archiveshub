
var recid = 'notSet';
var idExists = null;
var currentForm = 'collectionLevel';
var accessPoints = new Array("subject", "persname", "famname", "corpname", "geogname", "title", "genreform", "function");
var someIdSet = false;
var countryCode = null;
var repositoryCode = null;
var baseUnitId = null;
var fileName = null;
var fileOwner = null;


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


function deleteFromStore(){
	var recid = null;
	for (var i=0; i < document.getElementById('storeDirForm').recid.length; i++) {
		if (document.getElementById('storeDirForm').recid[i].checked) {
	      	recid = document.getElementById('storeDirForm').recid[i].value;
	    }
	}
	if (recid == null) {
		return;
	}
	else {
		var ok = confirmOp('You are about to delete ' + recid + ' from the editing store. All changes made since it was last submitted to the database will be lost.\nAre you sure you want to continue?')
		if (ok){
			deleteRec(recid);
		}
		else {
			return;
		}
	}
}


function reassignToUser(){
	var recid = null;
	var ok = false;
	var user = document.getElementById('storeDirForm').user.value;
	for (var i=0; i < document.getElementById('storeDirForm').recid.length; i++) {
		if (document.getElementById('storeDirForm').recid[i].checked) {
	      	recid = document.getElementById('storeDirForm').recid[i].value;
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


function deleteRec(id){
	var url = '/ead/edit/';
	var data = 'operation=delete&recid=' + id;
	var ajax = new Ajax.Request(url, {method:'post', asynchronous:false, postBody:data, evalScripts:true, onSuccess: function(transport) {	
		location.href="";		    
	}});		
}


function submit(){
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title')
		return;
	}
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title')
		return;
	}
	if (currentEntryField != null && currentEntryField.value != ''){
    	validateField(currentEntryField, false)
    }
	errors = document.getElementsByClassName('menuFieldError');
    if (errors.length != 0){
    	alert('please fix errors');
    	return;
    }
	saveForm(false);
	url = "?operation=submit&recid=" + recid;
	if (fileOwner != null){
		url += '&owner=' + fileOwner;
	}
	if (fileName != null){
		url += '&filename=' + fileName;
	}
    location.href= url;
}



function addElement(s){
	$(s).toggle();
  	if ($(s).visible($(s))){
  		$(('link' + s)).update('hide');		
  	}
 	else if ($(s).getValue($(s)) == '' || $(s).getValue($(s)) == ' '){
		$(('link' + s)).update('add');	
  	} 
  	else { 
		$(('link' + s)).update('show');
  	}
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


function saveForm(asynch){

	//collect the basic id information
	if (currentForm == 'collectionLevel'){
		setCountryCode($('countrycode').value);
	    setRepositoryCode($('repositorycode').value);
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
    if (recid != null && recid != 'notSet'){
    	data += '&recid=' + recid;
    }
    else {
    	recid = ($('pui')).value;
    }
    if (fileOwner != null){
    	data += '&owner' + fileOwner;
    }

    var loc = $('rightcol');
  	var ajax = new Ajax.Request(loc, {method:'post', asynchronous:asynch, postBody:data, evalScripts:true,  onSuccess: function(transport){ 
    	var response = transport.responseText;
	    var rid = response.substring(7,response.indexOf('</recid>'));		    	
	}});	
}





function displayForm(id, level){
	/* for adding a new form */
	if (id == 'new'){
		var data = 'operation=add&recid=' + recid + '&clevel=' + level;
		var loc = $('rightcol');		
	   	new Ajax.Updater(loc, '/ead/edit/', {method: 'post', asynchronous:false, parameters:data, evalScripts:true});

	   	($('countrycode').value) = countryCode;	   			
	   	($('repositorycode').value) = repositoryCode;
	   	($('unitid').value) = baseUnitId + '/' + currentForm.replace(/-/g, '/');
	   	($('pui').value) = recid;
	   	updateId();
	}
	/* for navigating to an existing form*/
	else {	 
		if (!checkRequiredData()){
			alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title')
			return;
		} 	
	  	saveForm(false);
		var data = 'operation=navigate&recid=' + recid + '&newForm=' + id
		if (fileOwner != null){
			data += '&owner=' + fileOwner;
		}
		var loc = $('rightcol');
		new Ajax.Updater(loc, '/ead/edit', {method: 'get', asynchronous:false, parameters:data, evalScripts:true, onSuccess: function(transport){		   	

		   	($(currentForm)).className = 'link';
		    currentForm = id;
		    $(id).className = 'selected';		    
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
    	alert('please fix errors');
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
    if (elementCount != undefined){
      	linkId += (elementCount + 1);
    }
    var parentLoc = '';
    if (level > 0){
      	var parentId = parent.getAttribute('id');
      	var parentLoc = parentId;
      	if (parentLoc != undefined){
        	linkId += ('-' + parentLoc);
      	}	
    }
	// create the html
    var newItem = document.createElement('li');

    var newLink = document.createElement('a');
    newLink.style.display = 'inline';
    newLink.setAttribute('id', linkId);
    newLink.className = 'selected';
    newLink.setAttribute('name', 'link');
    newLink.onclick = new Function("javascript: displayForm(this.id, 0)");
    newLink.href = "#";
    newLink.appendChild(document.createTextNode(linkId));
 
    parent.className = 'none';
             
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
    	alert('please fix errors');
    	return;
    }
	saveForm(false);
	url = '/ead/edit?operation=display&recid=' + recid;
	if (fileOwner != null){
		url += '&owner=' + fileOwner;
	}
	window.open(url, 'new');	
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
    	alert('please fix errors');
    	return;
    }
	saveForm(false);
	url = '/ead/edit?operation=preview&recid=' + recid;	
	if (fileOwner != null){
		url += '&owner=' + fileOwner;
	}
	window.open(url, 'new');
}


//================================================================================================
// passive UI Functions to update left hand column navigation menu

function updateTitle(field) {
  	var link = document.getElementById(currentForm);
  	var title = ($('cab')).value;
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
  	var countryCode = $('countrycode').value.toLowerCase()
  	var repositoryCode = $('repositorycode').value
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



function validateField(field, asynch){
	var url = '/ead/edit/'
	var data = 'operation=validate&text=' + field.value;
	
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
		if ($('repositorycode').value != ''){
			if ($('unitid').value != ''){
				var id = $('countrycode').value.toLowerCase() + $('repositorycode').value + $('unitid').value.replace(' ', '').toLowerCase();
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
	else if ($('repositorycode').value == '' && currentForm == 'collectionLevel'){
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

function toggleKeyboard(){
  	var keyboard = ($('keyboard')); 
    keyboard.style.top = '100px';
    keyboard.style.left = '10px';
  	keyboard.toggle();  
  	showCharTable();
}


function showCharTable(){
  	($('chartable')).style.display = 'block';
}


function hideCharTable(){
  	($('chartable')).style.display = 'none';
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
	field = currentEntryField;
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
}



