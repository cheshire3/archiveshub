
var required_xpaths_template = new Array('/template/@name');
var tempId = 'notSet';

function setTempId(){
	if (document.getElementById('tempid') != null && document.getElementById('tempid') != 'notSet'){
		tempId = document.getElementById('tempid').value;
	}
}


function discardTemplate(){
	var url = 'discard.html';
	var data = 'operation=discardtemplate&recid=' + encodeURIComponent(document.getElementById('/template/@name').value);
	var ajax = new Ajax.Request(url, {method:'post', asynchronous:false, postBody:data, evalScripts:true, onSuccess: function(transport) {	
		location.href="menu.html";		    
	}});
}

function saveTemplate(asynch){
	var body = document.getElementsByTagName('body')[0];
	body.className = 'waiting';
	if (document.getElementById('/template/@name').value.strip() == ''){
		alert('You must enter a name for this template before saving it.');
		body.className = 'none';
		return;
	}
	//check xml all valid
	var errors = document.getElementsByClassName('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before saving. Errors will be marked with red shading in the text box.');
    	body.className = 'none';
    	return;
    }
    if (tempId == 'notSet'){
    	var conflict = templateConflicts();
	    if (conflict == 'true'){
	    	alert('A template with this name already exists, please choose an alternative name.')
	    	body.className = 'none';
	    	return;	    	
	    }
    }	
	//save file
	resetAllAccessPoints()
  	var data = $('eadForm').serialize();
  	data += '&operation=savetemplate';
    var loc = 'edit.html';
	var ajax = new Ajax.Request(loc, {method:'post', asynchronous:asynch, postBody:data, evalScripts:true,  onSuccess: function(transport){ 
    	var response = transport.responseText;
	    var template = response.substring(6,response.indexOf('</name>'));	
		alert('This template is now saved as ' + template + ' and can be used as the basis for creating records. It can also be loaded back into this interface and edited if required.');
		if (tempId == 'notSet'){
			tempId = template;
		}
		body.className = 'none';
	}});
}

//
function templateConflicts(){
	var conflict = null;
	var error = false;
	var recid = document.getElementById('/template/@name').value;
	if (recid != null){		
		var url = 'edit.html'
		var data = 'operation=checkId&id=' + encodeURIComponent(recid) + '&store=templateStore';
		new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 
			var response = transport.responseText;
			conflict = response.substring(7,response.indexOf('</value>'));
		}});
	}
	else {
		return 'false';
	}		
	if (conflict == 'true'){
		return 'true';
	}
	else {
		return 'false';
	}
}

