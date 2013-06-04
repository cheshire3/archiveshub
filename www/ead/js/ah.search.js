/*
// Program:		accesspoints.js
// Version:   	0.01
// Description:
//            	JavaScript functions for adding control access terms to Archives Hub editing interface.  
//            	- produced for the Archives Hub v3.x. 
// Language:  	JavaScript
// Author(s):   Catherine Smith <catherine.smith@liv.ac.uk>	
// Date:      	09/01/2009
// Copyright: 	&copy; University of Liverpool 2009
//
// Version History:
// 0.01 - 09/01/2009 - CS- functions completed for first release of Archives Hub editing interface
*/

    
var labelMapping = new Array();

	labelMapping['subject_subject'] = 'Subject';
	labelMapping['subject_a'] = 'Subject';
	labelMapping['subject_dates'] = 'Dates';
	labelMapping['subject_y'] = 'Dates';
	labelMapping['subject_loc'] = 'Location';
	labelMapping['subject_z'] = 'Location';
	labelMapping['subject_other'] = 'Other';
	labelMapping['subject_x'] = 'Other';
	labelMapping['subject_source'] = 'Thesauri';
	
	labelMapping['persname_surname'] = 'Surname';	
	labelMapping['persname_a'] = 'Surname';
	labelMapping['persname_forename'] = 'Forename';
	labelMapping['persname_dates'] = 'Dates';
	labelMapping['persname_y'] = 'Dates';
	labelMapping['persname_title'] = 'Title';
	labelMapping['persname_epithet'] = 'Epithet';
	labelMapping['persname_other'] = 'Other';
	labelMapping['persname_x'] = 'Other';
	labelMapping['persname_source'] = 'Source';
	
	labelMapping['famname_surname'] = 'Surname';
	labelMapping['famname_a'] = 'Surname';
	labelMapping['famname_other'] = 'Other';
	labelMapping['famname_x'] = 'Other';
	labelMapping['famname_dates'] = 'Dates';
	labelMapping['famname_y'] = 'Dates';
	labelMapping['famname_title'] = 'Title';
	labelMapping['famname_epithet'] = 'Epithet';
	labelMapping['famname_loc'] = 'Location';
	labelMapping['famname_z'] = 'Location';
	labelMapping['famname_source'] = 'Source';
		
	labelMapping['corpname_organisation'] = 'Organisation';
	labelMapping['corpname_a'] = 'Organisation';
	labelMapping['corpname_dates'] = 'Dates';
	labelMapping['corpname_y'] = 'Dates';
	labelMapping['corpname_loc'] = 'Location';
	labelMapping['corpname_z'] = 'Location';
	labelMapping['corpname_other'] = 'Other';
	labelMapping['corpname_x'] = 'Other';
	labelMapping['corpname_source'] = 'Source';
	
	labelMapping['geogname_geogname'] = 'Place Name';
	labelMapping['geogname_a'] = 'Place Name';
	labelMapping['geogname_dates'] = 'Dates';
	labelMapping['geogname_y'] = 'Dates';
	labelMapping['geogname_loc'] = 'Location';
	labelMapping['geogname_z'] = 'Location';
	labelMapping['geogname_source'] = 'Source';
	labelMapping['geogname_other'] = 'Other';
	labelMapping['geogname_x'] = 'Other';
	
	labelMapping['title_title'] = 'Title';
	labelMapping['title_a'] = 'Title';
	labelMapping['title_dates'] = 'Dates';
	labelMapping['title_y'] = 'Dates';
	labelMapping['title_source'] = 'Source';

	labelMapping['genreform_a'] = 'Genre';
	labelMapping['genreform_genre'] = 'Genre';
	labelMapping['genreform_source'] = 'Source';

	labelMapping['function_a'] = 'Function';
	labelMapping['function_function'] = 'Function';
	labelMapping['function_source'] = 'Source';



/*adds the selected field to the access point, s is the name of the access point ie. persname */
function addField(s){
	var tableDiv = ($(s + 'table'));
	var table = tableDiv.getElementsByTagName('tbody')[0];
	var dropdownRow = document.getElementById(s + 'dropdown').parentNode.parentNode;
	var value = document.getElementById(s + 'dropdown').value;
	var options = dropdownRow.getElementsByTagName('option');
	var text;
	for (var i=0; i<options.length; i++){
		if (options[i].value == value){
			text = options[i].text;
		}
	}	
	var newRow = document.createElement('tr');
	var cell1 = document.createElement('td');
	var cell2 = document.createElement('td');
	var cell3 = document.createElement('td');
	cell1.innerHTML = '<td class="label">' + text + ': </td>';
	if (value == 'famname_other'){
		cell2.innerHTML = '<input type="text" onfocus="parent.setCurrent(this);" name="' + value + '" id="' + value + '" size="40" value="family"></input>';
	}
	else {
		cell2.innerHTML = '<input type="text" onfocus="parent.setCurrent(this);" name="' + value + '" id="' + value + '" size="40"></input>';
	}
	cell3.innerHTML = '<img src="/ead/img/delete.png" class="deletelogo" onmouseover="this.src=\'/ead/img/delete-hover.png\';" onmouseout="this.src=\'/ead/img/delete.png\';" onclick="deleteRow(this.parentNode.parentNode);" />';
	newRow.appendChild(cell1);
	newRow.appendChild(cell2);
	newRow.appendChild(cell3);
	table.insertBefore(newRow, dropdownRow); 

	var rows = table.getElementsByTagName('tr');
	rows[rows.length-2].getElementsByTagName('input')[0].focus();    
	options[0].selected = true;	
	var tableDnD = new TableDnD();
	tableDnD.init($('table_' + s));
}

function resetAllAccessPoints(){
	var accessPoints = ['subject','persname', 'famname', 'corpname', 'geogname', 'title', 'genreform', 'function'];
	for (var i=0; i< accessPoints.length; i++){
		resetAccessPoint(accessPoints[i]);
	}
}

/*resets the access point back to its original appearance deleting any content, s is the name of the access point ie. persname */
function resetAccessPoint(s){
	var tableDiv = ($(s + 'table'));
	var table = tableDiv.getElementsByTagName('tbody')[0];
	var rows = table.getElementsByTagName('tr');
	if (s == 'language'){
		for (var i=0; i<rows.length; i++){
	  		rows[i].getElementsByTagName('input')[0].value = '';
	  	} 
	}
	else {
		if (s == 'genreform' || s == 'function'){
			for (var i=rows.length-1; i>0; i--){
	    		table.removeChild(rows[i]);
	  		}
		}
		else if (s == 'persname' || s == 'subject') {
			for (var i=rows.length-2; i>1; i--){
	    		table.removeChild(rows[i]);
	  		}			
		}
		else {
			for (var i=rows.length-2; i>0; i--){
	    		table.removeChild(rows[i]);
	  		}
	  	}
	  	rows[0].getElementsByTagName('input')[0].value = '';
	  	if (s == 'persname'){
	  		rows[1].getElementsByTagName('input')[0].value = '';
	  	}
	  	var rules = document.getElementById(s + '_rules');
	  	if (rules != null){
    		rules.options[0].selected=true;   	
      	}
      	if (s != 'subject'){
      		checkRules(s);
      	}
      	else {
      		document.getElementById(s + '_source').options[0].selected = true;
      	}
    }   
}

function addLanguage() {
  /*function to add a language to lang_list after,
  //checking for both lang_code and lang_name*/

  var form = document.getElementById('eadForm');
  var langcode = document.getElementById('lang_code').value;
  var language = document.getElementById('lang_name').value;
  var fields = new Array("lang_code", "lang_name"); 
  
  if (langcode == ""){
    alert("You must enter a 3-letter ISO code for this language.");
  }
  else if (language == ""){
    alert("You must enter a name for this language.");
  } else {
    buildAccessPoint('language');
    resetAccessPoint('language');
  }

}


function editSubject(s, type, number){
  
  	var string = document.getElementById(s + number + 'xml').value;
  	var values = string.split(' ||| ');
  
 	var tableDiv = ($(type + 'table'));

  	var table = tableDiv.getElementsByTagName('tbody')[0];
  	var rows = table.getElementsByTagName('tr');
  	
  	var dropdown = document.getElementById(type + 'dropdown');
	var dropdownRow = dropdown.parentNode.parentNode;
  	var inputs = table.getElementsByTagName('input');
  	for (var i = 0; i< values.length-1; i++){ 
  		value = values[i].split(' | ');
  		if (i == 0){
	  		inputs[i].value = value[1];
	  	}
  		else if (value[0].split('_', 2)[1] == 'source'){
 			var source = document.getElementById(type + '_source');
			for (var j=0; j<source.length; j++){
		  		if (source.options[j].value == value[1].toLowerCase()){
		  	 		source.options[j].selected = true;			  	 		
		  		}
			}
 		}
 		else if (value[0].split('_', 2)[0] != 'att') { 			
		  	var newRow = document.createElement('tr');
		  	var cell1 = document.createElement('td');
			var cell2 = document.createElement('td');
			cell1.innerHTML = '<td class="label">' + labelMapping[value[0]] + ': </td>';
			cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + value[0] + '" value="' + value[1] + '" size="40"></input>';
			newRow.appendChild(cell1);
			newRow.appendChild(cell2);
						
			var cell3 = document.createElement('td');
			cell3.innerHTML = '<img src="/ead/img/delete.png" class="deletelogo" onmouseover="this.src=\'/ead/img/delete-hover.png\';" onmouseout="this.src=\'/ead/img/delete.png\';" onclick="deleteRow(this.parentNode.parentNode);" />';
			newRow.appendChild(cell3);		
	  		table.insertBefore(newRow, dropdownRow);			  		
		  	
	  	}
  	}
	//delete the access point you are now editing
 	deleteAccessPoint(s + number);
  	
}


/* repopulate the access point with the details from the given entry so they can be edited, s is either the name of the access point or the name of the access point
followed by '_formgen' which is used to maintain distinct ids between access points read in from existing xml and those created in the current form,
number is the number which forms part of the unique id */
function editAccessPoint(s, number){
  	var type = s.substring(0, s.indexOf('_formgen'));
  	if (type == '') {
  		type = s;
  	}  
  	resetAccessPoint(type);
  	if (type == 'subject'){
  		editSubject(s, type, number);
  	}
  	else {
	  
	  	var string = document.getElementById(s + number + 'xml').value;
	  	var values = string.split(' ||| ');
	  
	 	var tableDiv = ($(type + 'table'));
	
	  	var table = tableDiv.getElementsByTagName('tbody')[0];
	  	var rows = table.getElementsByTagName('tr');
	  	var inputs = table.getElementsByTagName('input');
	  	if (type != 'language' && type != 'genreform' && type != 'function'){
		 	var dropdown = document.getElementById(type + 'dropdown');
	  	  	var dropdownRow = dropdown.parentNode.parentNode;
	  	}
	  	//check to see if the existing access point has either rules or source - one is required - files being edited may not have one 
	  	var hasSource = false;
	  	var hasRules = false;
		for (var i = 0; i< values.length-1; i++){
		  	if (values[i].split(' | ')[0].split('_', 2)[1] == 'rules'){
	  			hasRules = true;
	  		}
	  		else if (values[i].split(' | ')[0].split('_', 2)[1] == 'source'){
	  			hasSource = true;
	  		}	
	  	}
	  	// find all the values in the access point
	  	for (var i = 0; i< values.length-1; i++){  
	  		value = values[i].split(' | ');
	  		if (type == 'language'){
	  			inputs[i].value = value[1];
	  		}
	  		else if (type == 'persname') {
	  			if (value[0].split('_', 2)[1] == 'surname' || value[0].split('_', 2)[1] == 'a'){
	  				inputs[0].value = value[1];
	  			}
	  			else if (value[0].split('_', 2)[1] == 'forename'){
	  				inputs[1].value = value[1];
	  			}	
	  			else {
	  				if (value[0].split('_', 2)[1] == 'rules'){
		  				var rules = document.getElementById(type + '_rules');
						for (var j=0; j<rules.length; j++){
					  		if (rules.options[j].value == value[1]){
					  	 		rules.options[j].selected = true;			  	 		
					  		}
						}
						if (value[1] != 'none'){
					  	 	table.removeChild(rows[2]);
					  	}
		  			}
		  			else if (value[0].split('_', 2)[0] != 'att') { 			
					  	var newRow = document.createElement('tr');
					  	var cell1 = document.createElement('td');
						var cell2 = document.createElement('td');
						cell1.innerHTML = '<td class="label">' + labelMapping[value[0]] + ': </td>';
						cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + value[0] + '" value="' + value[1] + '" size="40"></input>';
						newRow.appendChild(cell1);
						newRow.appendChild(cell2);
						if (value[0].split('_', 2)[1] == 'source'){
							newRow.setAttribute('NoDrag', 'True');
							newRow.setAttribute('NoDrop', 'True');
							table.replaceChild(newRow, rows[2]);
						}
						else {			
							var cell3 = document.createElement('td');
							cell3.innerHTML = '<img src="/ead/img/delete.png" class="deletelogo" onmouseover="this.src=\'/ead/img/delete-hover.png\';" onmouseout="this.src=\'/ead/img/delete.png\';" onclick="deleteRow(this.parentNode.parentNode);" />';
							newRow.appendChild(cell3);		
					  		table.insertBefore(newRow, dropdownRow);			  		
					  	}
				  	}
	  			
	  			}
	  		}
	  		else {
	  			//fill in the lead for the access point
			  	if (i == 0){
			  		inputs[i].value = value[1];
			  	}
	
			  	else {
		  			if (value[0].split('_', 2)[1] == 'rules'){
		  				var rules = document.getElementById(type + '_rules');
						for (var j=0; j<rules.length; j++){
					  		if (rules.options[j].value == value[1]){
					  	 		rules.options[j].selected = true;
					  	 		if (value[1] != 'none'){
					  	 			table.removeChild(rows[1]);
					  	 		}
					  		}
						}
		  			}
		  			else if (value[0].split('_', 2)[0] != 'att') { 			
					  	var newRow = document.createElement('tr');
					  	var cell1 = document.createElement('td');
						var cell2 = document.createElement('td');
						cell1.innerHTML = '<td class="label">' + labelMapping[value[0]] + ': </td>';
						cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + value[0] + '" value="' + value[1] + '" size="40"></input>';
						newRow.appendChild(cell1);
						newRow.appendChild(cell2);
						if (value[0].split('_', 2)[1] == 'source'){
							newRow.setAttribute('NoDrag', 'True');
							newRow.setAttribute('NoDrop', 'True');
							table.replaceChild(newRow, rows[1]);
						}
						else {			
							var cell3 = document.createElement('td');
							cell3.innerHTML = '<img src="/ead/img/delete.png" class="deletelogo" onmouseover="this.src=\'/ead/img/delete-hover.png\';" onmouseout="this.src=\'/ead/img/delete.png\';" onclick="deleteRow(this.parentNode.parentNode);" />';
							newRow.appendChild(cell3);		
					  		table.insertBefore(newRow, dropdownRow);			  		
					  	}
				  	}		  	
		  		}
		  		
			}  
		  	
	  	}
	  	//if the current access point does not have rules or source specified then add an empty source box in row 2
	  	if (!hasSource && !hasRules && type != 'language'){
		  	var newRow = document.createElement('tr');
			var cell1 = document.createElement('td');
			var cell2 = document.createElement('td');
			cell1.innerHTML = '<td class="label">' + labelMapping[type+'_source'] + ': </td>';
			cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + type + '_source" size="40"></input>';
			newRow.appendChild(cell1);
			newRow.appendChild(cell2);
			newRow.setAttribute('NoDrag', 'True');
			newRow.setAttribute('NoDrop', 'True');
			table.replaceChild(newRow, rows[1]);
		}
	  	//delete the access point you are now editing
	  	deleteAccessPoint(s + number);
	  	
	  	//initiate drag and drop reordering of cells
	  	if (type != 'language' && type != 'genreform' && type != 'function'){
	  		var tableDnD = new TableDnD();
	  		tableDnD.init($('table_' + type));
	  	}
	}
}





/*deletes element with given id */
function deleteAccessPoint(d){
	var div = document.getElementById(d);
  	var xml = document.getElementById(d + 'xml');
  	var br = document.getElementById(d + 'br');  
  	var parent = div.parentNode;
  	parent.removeChild(div);
  	parent.removeChild(xml);
  	parent.removeChild(br);
  	if (parent.getElementsByTagName('div').length < 1){
  		parent.style.display = 'none';
  	} 
}



/* counter initialised for use in addAccessPoint() function*/
var nameCount = 0;

/* adds personal name to the 'addedpersnames' div etc.*/
function addAccessPoint(s){

	/* These values in these arrays must have a value - if there are more than one at least one of them must be present not all of them*/
	if (s == 'persname'){
		var reqfields = new Array("persname_surname", "persname_forename");
	}
	else if (s == 'famname'){
	  var reqfields = new Array("famname_surname");
	}
	else if (s == 'corpname'){
	  var reqfields = new Array("corpname_organisation");
	}
	else if (s == 'subject'){
	  var reqfields = new Array("subject_subject");
	}
	else if (s == 'geogname'){
	  var reqfields = new Array("geogname_location");
	}
	else if (s == 'title'){
	  var reqfields = new Array("title_title");
	}
	else if (s == 'genreform'){
	  var reqfields = new Array("genreform_genre");
	}
	else if (s == 'function'){
	  var reqfields = new Array("function_function");
	}
  
  	var fm = document.getElementById('eadForm');
  	//change this to for loop to allow multiple required fields to be set
  	if (reqfields.length > 1) {
  		var hasReqValues = false;
  		var string = '';
		for (var i=0; i<reqfields.length; i++){
			if (i == 0){
				string += reqfields[i].split('_', 2)[1];
			}
			else {
				string += ' or ';
				string += reqfields[i].split('_', 2)[1];
			}
			if (fm[reqfields[i]].value != ""){
				hasReqValues = true;
			}
		}
		if (hasReqValues == false){
			alert("You must give a " + string + " for this access point.");
			return;
		}
  	}
  	else {
	  	if (fm[reqfields[0]].value == "") {
	    	alert("You must give a " + reqfields[0].split('_', 2)[1] + " for this access point.");
	    	return;
	  	} 
  	}
 	if (document.getElementById(s + '_source') && document.getElementById(s + '_source').value == ""){
 		if (s == 'subject'){
 			alert("You must supply a thesaurus for this access point."); 
 		}
 		else if (s == 'genreform' || s == 'function'){
 			alert("You must supply a source for this access point."); 
 		}
 		else {
  			alert("You must supply a source or specify a rule set for this access point."); 
  		}
  	}
  	else {
    	buildAccessPoint(s);
    	resetAccessPoint(s);
  	}
}


function buildSubject(s){
	var tableDiv = $('subjecttable');
	var valueString = '';
    var textString = '';  
	var table = tableDiv.getElementsByTagName('tbody')[0];
	var rows = table.getElementsByTagName('tr');
	var length = rows.length-1
	for (var i = 0; i<length; i++){    
    	textbox = rows[i].getElementsByTagName('input')[0];
    	if (textbox == undefined){
    		textbox = rows[i].getElementsByTagName('select')[0];
    	}
    	if (textbox.value != ""){
    		if (textbox.id.split('_', 2)[1] == 'source'){
    			valueString +=  textbox.id + ' | ' + textbox.value + ' ||| ';
    			
    		}
    		else {
    			valueString += textbox.id + ' | ' + textbox.value + ' ||| ';
    			textString += textbox.value + ' ';
    		}
    	}   
    }
    var rules = document.getElementById(s + '_rules');
    if (rules != null){
    	valueString += rules.id + ' | ' + rules.value + ' ||| ';
    	rules.options[0].selected=true;
    }
        
    /* add to DOM */
    var div = document.getElementById('added' + s.toLowerCase() + 's');
    var txtnode = document.createTextNode(textString); 
	var number = nameCount;
    nameDiv = document.createElement('div');
    nameDiv.setAttribute('class', 'accesspoint');
    var link = document.createElement('a');    
    link.onclick = function () {editAccessPoint(s, number); },   
    link.setAttribute('title', 'Click to edit');
    link.appendChild(txtnode);
    nameDiv.appendChild(link);
    var icondiv = createIcons(s);

    var wrapper = document.createElement('div');
    wrapper.setAttribute('id', s + nameCount);  
    wrapper.appendChild(icondiv);

    wrapper.appendChild(nameDiv);   
    div.appendChild(wrapper);
    br = document.createElement('br');
    br.setAttribute('id', s + nameCount + 'br');
    div.appendChild(br);
    var hidden = document.createElement('input');
    hidden.setAttribute('type', 'hidden');
    hidden.setAttribute('id', s + nameCount + 'xml'); 
    hidden.setAttribute('name', 'controlaccess/' + s);
    hidden.setAttribute('value', valueString);

    div.appendChild(hidden);
    div.style.display = 'block';

    nameCount++;  
	
}


/* Build the xml and strings needed for the access point */
function buildAccessPoint(s){
	if (s == 'subject'){
		buildSubject(s);
	}
	else {
		var tableDiv = ($(s + 'table'));
	    /* retreive all values from section of form and reset form values*/
	    var valueString = '';
	    var textString = '';  
		var table = tableDiv.getElementsByTagName('tbody')[0];
		var rows = table.getElementsByTagName('tr');
		var length;
		if (s == 'language' || s == 'genreform' || s == 'function'){
			length = rows.length;
		}
		else {
			length = rows.length-1
		}    
	    for (var i = 0; i<length; i++){    
	    	textbox = rows[i].getElementsByTagName('input')[0]
	    	if (textbox.value != ""){
	    		if (textbox.id.split('_', 2)[1] == 'source'){
	    			valueString +=  textbox.id + ' | ' + textbox.value + ' ||| ';
	    			
	    		}
	    		else {
	    			valueString += textbox.id + ' | ' + textbox.value + ' ||| ';
	    			textString += textbox.value + ' ';
	    		}
	    	}   
	    }
	    var rules = document.getElementById(s + '_rules');
	    if (rules != null){
	    	valueString += rules.id + ' | ' + rules.value + ' ||| ';
	    	rules.options[0].selected=true;
	    }
	        
	    /* add to DOM */
	    var div = document.getElementById('added' + s.toLowerCase() + 's');
	    var txtnode = document.createTextNode(textString); 
		var number = nameCount;
	    nameDiv = document.createElement('div');
	    nameDiv.setAttribute('class', 'accesspoint');
	    var link = document.createElement('a');    
	    link.onclick = function () {editAccessPoint(s, number); },   
	    link.setAttribute('title', 'Click to edit');
	    link.appendChild(txtnode);
	    nameDiv.appendChild(link);
	    var icondiv = createIcons(s);
	
	    var wrapper = document.createElement('div');
	    wrapper.setAttribute('id', s + nameCount);  
	    wrapper.appendChild(icondiv);
	
	    wrapper.appendChild(nameDiv);   
	    div.appendChild(wrapper);
	    br = document.createElement('br');
	    br.setAttribute('id', s + nameCount + 'br');
	    div.appendChild(br);
	    var hidden = document.createElement('input');
	    hidden.setAttribute('type', 'hidden');
	    hidden.setAttribute('id', s + nameCount + 'xml'); 
	    if (s == 'language'){
	    	hidden.setAttribute('name', 'did/langmaterial/' + s);
	    }
	    else {
	    	hidden.setAttribute('name', 'controlaccess/' + s);
	    }
	    hidden.setAttribute('value', valueString);
	
	    div.appendChild(hidden);
	    div.style.display = 'block';
	
	    nameCount++;   	
	} 
}


function createIcons(s){
    var icondiv = document.createElement('div');
    	icondiv.className = 'icons'; 

   /* the delete icon */
   var d = "'" + s + nameCount + "'";
   var s = "'" + s + "'";
   innerHTMLString = '<a onclick ="deleteAccessPoint(' + d + ');" title="delete entry"><img src="/ead/img/delete.png" class="deletelogo" onmouseover="this.src=\'/ead/img/delete-hover.png\';" onmouseout="this.src=\'/ead/img/delete.png\';" id="delete' + nameCount + '"/></a>'; 

   icondiv.innerHTML = innerHTMLString;
   return icondiv
}



/* Function to make sure only source OR rules can be completed for an access point called when a rule is selected from the
drop down box and deletes the source box if present or puts it back if no rule is selected*/
function checkRules(s){
	var rules = ($(s + '_rules'));
	var tableDiv = ($(s + 'table'))
	if (tableDiv == null){
		tableDiv = ($(s.substring(0, s.indexOf('_formgen')) + 'table'));
  	}	
	var table = tableDiv.getElementsByTagName('tbody')[0];
	var rows = table.getElementsByTagName('tr');
	//get dropdown row so we can insert before that
	try {
		var dropdownrow = document.getElementById(s + 'dropdown').parentNode.parentNode;
	}
	catch (e){
		
	}
	
	if (rules == null){
		if (s == 'subject'){
			var label = 'Thesaurus';
		}
		else {
			var label = 'Source';
		}
		var newRow = document.createElement('tr')
		var cell1 = document.createElement('td');
		var cell2 = document.createElement('td');
		cell1.innerHTML = '<td class="label">' + label + ': </td>';
		cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + s + '_source" size="40"></input>';
		newRow.appendChild(cell1);
		newRow.appendChild(cell2);
		newRow.setAttribute('NoDrag', 'True');
		newRow.setAttribute('NoDrop', 'True');
		try {
			table.insertBefore(newRow, dropdownrow);
		}
		catch (e){
			table.appendChild(newRow);
		}
	}
	else if (rules.value == 'none'){
		var newRow = document.createElement('tr')
		var cell1 = document.createElement('td');
		var cell2 = document.createElement('td');
		cell1.innerHTML = '<td class="label">Source: </td>';
		cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + s + '_source" size="40"></input>';
		newRow.appendChild(cell1);
		newRow.appendChild(cell2);
		newRow.setAttribute('NoDrag', 'True');
		newRow.setAttribute('NoDrop', 'True');
		try {
			table.insertBefore(newRow, dropdownrow);
		}
		catch (e){
			table.appendChild(newRow);
		}
	}
	else {
		for (var r=0; r<rows.length; r++){
			if (rows[r].getElementsByTagName('input')[0] && rows[r].getElementsByTagName('input')[0].id == s + '_source'){
				table.removeChild(rows[r]);
			}
		}		
	}	
}


/* deletes the row from the accesspoint*/
function deleteRow(tr){
	var table = tr.parentNode;
	table.removeChild(tr);
}



/*
// Script:   	collapsibleLists.js
// Version:   	0.02
// Description:
//            JavaScript functions used in the Cheshire3 EAD search/retrieve and display interface 
//            - part of Cheshire for Archives v3.x
//
// Language:  	JavaScript
// Authors:     John Harrison <john.harrison@liv.ac.uk>
//				Catherine Smith <catherine.smith@liv.ac.uk>
// Date:      	11 January 2008
//
// Copyright: &copy; University of Liverpool 2005-2008
//
// Version History:
// 0.01 - 03/08/2006 - JH - Nested list manipulation functions pasted in from
//                          previous script for easier error tracking etc.
// 0.02 - 11/01/2008 - CS - Code adapted to allow list to begin collapsed or
//                          uncollapsed (collapseList boolean) and to allow for
//                          either each level to be controlled to that only one
//                          folder from it can be open at a time or not
//							(controlLevels boolean)
//                        - Function names changed to be more generic
//                          (necessary changes made in eadAdminHandler.py,
//                          htmlFragments.py and eadEditingHandler
// X.xx - 12/03/2013 - JH - Added function to truncate long lists (e.g. facets)
//
*/

/* Note: list must be well formed, all tags closed, 
// all sublists must be contained within a list item,
// NOT a direct descendent of parent list.
*/

var expandedLists = [];
var listCount = 0;

/* customisable display of icons in collapsible lists */
/* file explorer style */
var collapsedUrl = '/ead/img/folderClosed.gif';
var expandedUrl = '/ead/img/folderOpen.gif';
var itemUrl = '/ead/img/folderItem.jpg';
var lastItemUrl = '/ead/img/folderItem.jpg';
/* skeletal style - uncomment/comment to replace the above defaults */
//var collapsedUrl = '/ead/img/barPlus.gif';
//var expandedUrl = '/ead/img/barMinus.gif';
var itemUrl = '/ead/img/barT.gif'
var lastItemUrl = '/ead/img/barLast.gif'


function createTreeFromList(listId, treeState, collapseList, controlLevels) {

  	/* args: 
     	listId -> str - id attr of list to collapse
     	treeState -> str - string representation of state of list
     	collapseChildren -> bool - collapse the tree? if this is false controlLevels must also be false (is reset here just in case)
     	controlLevels -> bool - control Levels so that only one folder at each level can be open at any time
  	*/
  	if( !document.getElementsByTagName || !document.childNodes || !document.createElement ) {
  		return;
  	}	
 	var rootListObj = document.getElementById( listId ); 
  	if( !rootListObj ) { 
    	return; 
  	}
  	if (!collapseList){
  		controlLevels = false;
  	}
  	createSubLists(rootListObj, 0, listId, treeState, collapseList, controlLevels, rootListObj.tagName.toLowerCase());
}


function createSubLists(listObj, level, rootListId, treeState, collapseList, controlLevels, listTag) {
  	/* args: 
     	listObj -> obj - root node of tree to collapse
     	level -> int - level of the sub-list we're collapsing
     	rootListId -> str - id attr of root list
     	treeState -> str - string representation of state of list
     	collapseChildren -> bool - collapse the tree?
     	controlLevels -> bool - control Levels so that only one folder at each level can be open at any time
     	listTag - str - tag used for root list 'ul' or 'ol' 
  	*/
 
 	var temp = listObj.childNodes;
 	var listItems = []
 	var j = 0;
 	for (var i=0; i<temp.length; i++){
 		if (temp[i].tagName == 'LI'){
 			listItems[j] = temp[i];
 			j++;
 		}	
 	}
  	tocLevels = treeState.split(':');
  	if( !level ) { 
		rootListId = escape(rootListId); 
  		if( collapseList ) { 
      		expandedLists[rootListId] = []; 
    	}
    	else {
    		expandedLists[rootListId] = []; 
    	}
  	}
  	for( var i = 0 ; i < listItems.length; i++ ) { 
	    // for each <li>
	    if( listItems[i].tagName) {
	      	var nextSubList = listItems[i].getElementsByTagName( listTag )[0];
	      	if( nextSubList ) {    	
	      		if (collapseList){
					//collapse 1st sub-list
					nextSubList.style.display = 'none';
				}
				//create a link for expanding/collapsing
				var newLink = document.createElement('a');
				newLink.setAttribute( 'href', '#' );
				newLink.onclick = new Function( 'switchState(this,' + level + ',\'' + rootListId + '\',' + controlLevels + ',\'' + escape(listTag) + '\');return false;' );
				// wrap everything upto child list in the link
				var imgElem = document.createElement('img');
				var countElem = document.createElement('span');
				countElem.setAttribute( 'class', 'subcount');
				var countTxt = document.createTextNode(' {' + nextSubList.getElementsByTagName('li').length + ' entries}');
				countElem.appendChild(countTxt);

				if (tocLevels[level] && listCount == tocLevels[level] || !collapseList) {
					//re-inflate 1st sub-list
					nextSubList.style.display = 'block';
				  	imgElem.setAttribute( 'src', expandedUrl );
				  	imgElem.setAttribute( 'alt', '[-]');
				  	expandedLists[rootListId][level] = nextSubList;
				}
				else {
				  	imgElem.setAttribute( 'src', collapsedUrl );
				  	imgElem.setAttribute( 'alt', '[+]');
				}

				newLink.appendChild(imgElem);
				
				listItems[i].insertBefore(newLink, listItems[i].childNodes[0]);
				for (var j =0; j< listItems[i].childNodes.length; j++){
					if (listItems[i].childNodes[j].tagName == 'UL'){
						listItems[i].insertBefore(countElem, listItems[i].childNodes[j]);
					}
				}			
				nextSubList.colListId = listCount++;
				createSubLists( nextSubList, level + 1, rootListId, treeState, collapseList, controlLevels, listTag);
	      	}       
		    else {

				var imgElem = document.createElement('img');
				if (i < listItems.length-1){
					imgElem.setAttribute( 'src', itemUrl );
				} else {
					imgElem.setAttribute( 'src', lastItemUrl );
				}
				imgElem.setAttribute( 'alt', '-');
				listItems[i].insertBefore(imgElem, listItems[i].childNodes[0]);
		   	}
    	} 
  	} 
}


function switchState( thisObj, level, rootListId, controlLevels, listTag ) {
  	/* args:
     	thisObj = obj - node of tree to switch state expanded/collapsed
     	level = int - level of element being switched
     	rootListId -> str - id attr of root list
     	collapseChildren -> bool - keep sub-lists collapsed?
     	listTag - str - tag used for root list 'ul' or 'ol' 
   	*/
   	
   	if( thisObj.blur ) { 
    	thisObj.blur(); 
  	}
  	var linkElem = thisObj.parentNode.getElementsByTagName( 'a' )[0];
  	thisObj = thisObj.parentNode.getElementsByTagName( unescape(listTag) )[0];
  	if (!controlLevels){
  		if (linkElem) {
    		var imgElem = linkElem.getElementsByTagName( 'img' )[0];
    		if (imgElem) {
      			if (thisObj.style.display == 'block') {
      				imgElem.setAttribute( 'src', collapsedUrl);
					thisObj.style.display = 'none';
      			} else {
      				imgElem.setAttribute( 'src', expandedUrl);
					thisObj.style.display = 'block';
      			}
    		}
  		} 	
  	}
  	else {
  		var imgElem = linkElem.getElementsByTagName( 'img' )[0];
  		if (imgElem) {
      		if (imgElem.getAttribute('src') == expandedUrl) {
				imgElem.setAttribute( 'src', collapsedUrl);
				
      		} 
      		else {
				imgElem.setAttribute( 'src', expandedUrl);
				 
      		}
    	}
  		for( var x = expandedLists[rootListId].length - 1; x >= level; x-=1 ) { 
      		if( expandedLists[rootListId][x] ) {
				expandedLists[rootListId][x].style.display = 'none';
				var linkElem = expandedLists[rootListId][x].parentNode.getElementsByTagName('a')[0];
				if (linkElem) {
				 	var imgElem = linkElem.getElementsByTagName( 'img' )[0];
				  	if (imgElem) {
				    	imgElem.setAttribute( 'src', collapsedUrl);
				    	thisObj.style.display = 'none';
				  	}
				}
				if( level != x ) { 
				  	expandedLists[rootListId][x] = null; 
				}
      		} 
    	}
    	if( thisObj == expandedLists[rootListId][level] ) {
      		expandedLists[rootListId][level] = null; 
    	} 
    	else { 
      		thisObj.style.display = 'block'; 
      		expandedLists[rootListId][level] = thisObj; 
    	}
  	}
}


function refreshTree(listId){
	if( !document.getElementsByTagName || !document.childNodes || !document.createElement ) {
  		return;
  	}	
 	var rootListObj = document.getElementById( listId );

  	if( !rootListObj ) { 
    	return; 
  	}
  	refreshSubTrees(rootListObj, 0, listId, rootListObj.tagName.toLowerCase());
}


function refreshSubTrees(listObj, level, rootListId, listTag){
	
	var temp = listObj.childNodes;
 	var listItems = [];
 	var j = 0;
 	for (var i=0; i<temp.length; i++){
 		if (temp[i].tagName == 'LI'){
 			listItems[j] = temp[i];
 			j++;
 		}	
 	}
 	expandedLists[rootListId] = [];
 	for( var i = 0 ; i < listItems.length; i++ ) { 
	    // for each <li>
	    if( listItems[i].tagName) {
	      	var nextSubList = listItems[i].getElementsByTagName( listTag )[0];
	      	if( nextSubList ) {    	      			
	      		var image = listItems[i].getElementsByTagName('IMG')[0];
	      		source = image.getAttribute('src');
				if (source.substring(source.lastIndexOf('/')) == '/folderOpen.gif' || source.substring(source.lastIndexOf('/')) == '/folderClosed.gif'){
					var span = listItems[i].getElementsByTagName('SPAN')[0];
					span.firstChild.nodeValue = ' {' + nextSubList.getElementsByTagName('li').length + ' entries}';			
				}
				else {
					image = listItems[i].getElementsByTagName('IMG')[0];
					try{
						listItems[i].removeChild(image);
					}
					catch (e){
						image.parentNode.removeChild(image);
					}
					//create a link for expanding/collapsing
					var newLink = document.createElement('a');
					newLink.setAttribute( 'href', '#' );
					newLink.onclick = new Function( 'switchState(this,' + level + ',\'' + rootListId + '\',' + false + ',\'' + escape(listTag) + '\');return false;' );
					// wrap everything upto child list in the link
					var imgElem = document.createElement('img');
					var countElem = document.createElement('span');
					countElem.className = 'subcount';
					var countTxt = document.createTextNode(' {' + nextSubList.getElementsByTagName('li').length + ' entries}');
					countElem.appendChild(countTxt);

					imgElem.setAttribute( 'src', expandedUrl );
					imgElem.setAttribute( 'alt', '[-]');
	
					newLink.appendChild(imgElem);
					
					listItems[i].insertBefore(newLink, listItems[i].childNodes[0]);
					for (var j =0; j< listItems[i].childNodes.length; j++){
						if (listItems[i].childNodes[j].tagName == 'UL'){
							listItems[i].insertBefore(countElem, listItems[i].childNodes[j]);
						}
					}								
				}
				nextSubList.colListId = listCount++;
				refreshSubTrees(nextSubList, level+1, rootListId, listObj.tagName.toLowerCase())
	      	}       
		    else {
		    	//remove the straight images
				if (listItems[i].childNodes[0].tagName == 'IMG'){
					listItems[i].removeChild(listItems[i].childNodes[0]);
				}
				//remove folder images (wrapped in links)
				else if (listItems[i].childNodes[0].childNodes[0].tagName == 'IMG'){	
					listItems[i].removeChild(listItems[i].childNodes[0]);				
					//these will also have span class=subcount which needs deleting first
					var children = listItems[i].childNodes;
					for (var j=0; j< children.length; j++){
						if (children[j].tagName == 'SPAN'){
							var span = children[j];
							if (span.className == 'subcount'){
								listItems[i].removeChild(span);
							}
						}
					} 					
				}
				var imgElem = document.createElement('img');
				if (i < listItems.length-1){
					imgElem.setAttribute( 'src', itemUrl );
				} else {
					imgElem.setAttribute( 'src', lastItemUrl );
				}
				imgElem.setAttribute( 'alt', '-');
				listItems[i].insertBefore(imgElem, listItems[i].childNodes[0]);
		   	}
    	} 
  	} 
}


function stateToString(listId) {
  	/* args:
     listId = str - id attr of list to create string representation of state for
  	*/
  	if( !document.getElementsByTagName || !document.childNodes || !document.createElement ) { 
    	return ''; 
  	}
  	var rootListObj = document.getElementById(listId);
  	if (!rootListObj) {
    	return '';
  	}

  	var stateStr = ''
  	for (var level = 0; level < expandedLists[listId].length; level++) {
    	var listObj = expandedLists[listId][level]
    	if (listObj) {
      		stateStr += listObj.colListId + ':';
    	}
  	}
  	return stateStr;
}


function isInArray(obj, array) {
  	/* args:
     obj = obj - the object to look for existence of
     array = obj - array object to search in
  	*/
  	for(var i = 0; i < array.length; i++) { 
    	if(obj == array[i]) { 
      		return true;
    	}
  	} 
  	return false;
}


function truncateList(index, list) {
    if ($(list).children('li').length > 5) { 
        $(list).children('li:gt(2)').hide();
        // Add links to un-truncate
        
        $(list).append('<li class="unmarked"><a href="javascript:void(0);" title="Show all ' + $(list).children('li').length + '">' + ($(list).children('li').length - 3) + ' more...</a></li>')
        // Add action for un-truncate
        $(list).children('li:last').children('a').click(
            function(){
                if ($(this).closest('li').siblings(":last").is(":visible")) {
                    $(this).closest('ul').children('li:gt(2):not(:last)').slideUp();
                    $(this).text(' more...').attr('title', 'Show all');;
                } else {
                    $(this).closest('li').siblings().slideDown();
                    $(this).text('fewer...').attr('title', 'Show only the top 3');
                }
            }
        );
    }
}


/**
*
* Simple Context Menu
* http://www.webtoolkit.info/
*
*
*
**/

/*
// Script:   	contextmenu.js
// Version:   	0.01
// Description:
//            JavaScript functions used in the Cheshire3 EAD search/retrieve and display interface 
//            - part of Cheshire for Archives v3.x
// Origin: 		http://www,webtoolkit.info	
// Language:  	JavaScript
// Authors:     http://www.webtoolkit.info
//				Catherine Smith <catherine.smith@liv.ac.uk>
// Date:      	20 January 2009
//
//
// Version History:
// 0.01 - 20/01/2009 - CS - Adaptions made to downloaded script for use in editing interface of Archives Hub
*/

var SimpleContextMenu = {

    // private attributes
    _menus : new Array,
    _attachedElement : null,
    _menuElement : null,
    _preventDefault : true,
    _preventForms : true,


    // public method. Sets up whole context menu stuff..
    setup : function (conf) {

        if ( document.all && document.getElementById && !window.opera ) {
            SimpleContextMenu.IE = true;
        }

        if ( !document.all && document.getElementById && !window.opera ) {
            SimpleContextMenu.FF = true;
        }

        if ( document.all && document.getElementById && window.opera ) {
            SimpleContextMenu.OP = true;
        }

        if ( SimpleContextMenu.IE || SimpleContextMenu.FF ) {

            document.oncontextmenu = SimpleContextMenu._show;
            document.onclick = SimpleContextMenu._hide;

            if (conf && typeof(conf.preventDefault) != "undefined") {
                SimpleContextMenu._preventDefault = conf.preventDefault;
            }

            if (conf && typeof(conf.preventForms) != "undefined") {
                SimpleContextMenu._preventForms = conf.preventForms;
            }

        }

    },


    // public method. Attaches context menus to specific class names
    attach : function (classNames, menuId) {

        if (typeof(classNames) == "string") {
            SimpleContextMenu._menus[classNames] = menuId;
        }

        if (typeof(classNames) == "object") {
            for (x = 0; x < classNames.length; x++) {
                SimpleContextMenu._menus[classNames[x]] = menuId;
            }
        }

    },


    // private method. Get which context menu to show
    _getMenuElementId : function (e) {

        if (SimpleContextMenu.IE) {
            SimpleContextMenu._attachedElement = event.srcElement;
        } else {
            SimpleContextMenu._attachedElement = e.target;
        }

        while(SimpleContextMenu._attachedElement != null) {
            var className = SimpleContextMenu._attachedElement.className;

            if (typeof(className) != "undefined") {
                className = className.replace(/^\s+/g, "").replace(/\s+$/g, "")
                var classArray = className.split(/[ ]+/g);

                for (i = 0; i < classArray.length; i++) {
                    if (SimpleContextMenu._menus[classArray[i]]) {
                        return SimpleContextMenu._menus[classArray[i]];
                    }
                }
            }

            if (SimpleContextMenu.IE) {
                SimpleContextMenu._attachedElement = SimpleContextMenu._attachedElement.parentElement;
            } else {
                SimpleContextMenu._attachedElement = SimpleContextMenu._attachedElement.parentNode;
            }
        }

        return null;

    },


    // private method. Shows context menu
    _getReturnValue : function (e) {

        var returnValue = true;
        var evt = SimpleContextMenu.IE ? window.event : e;

        if (evt.button != 1) {
            if (evt.target) {
                var el = evt.target;
            } else if (evt.srcElement) {
                var el = evt.srcElement;
            }

            var tname = el.tagName.toLowerCase();

            if ((tname == "input" || tname == "textarea")) {
                if (!SimpleContextMenu._preventForms) {
                    returnValue = true;
                } else {
                    returnValue = false;
                }
            } else {
                if (!SimpleContextMenu._preventDefault) {
                    returnValue = true;
                } else {
                    returnValue = false;
                }
            }
        }
        return returnValue;

    },


    // private method. Shows context menu
    _show : function (e) {
        SimpleContextMenu._hide();
        var menuElementId = SimpleContextMenu._getMenuElementId(e);

        if (menuElementId) {
            var m = SimpleContextMenu._getMousePosition(e);
            var s = SimpleContextMenu._getScrollPosition(e);
            SimpleContextMenu._menuElement = document.getElementById(menuElementId);
            SimpleContextMenu._menuElement.style.left = (m.x - 10) + s.x + 'px';
            SimpleContextMenu._menuElement.style.top = (m.y - 10) + s.y + 'px';
            SimpleContextMenu._menuElement.style.display = 'block';
            return false;
        }

        return SimpleContextMenu._getReturnValue(e);

    },


    // private method. Hides context menu
    _hide : function () {

        if (SimpleContextMenu._menuElement) {
            SimpleContextMenu._menuElement.style.display = 'none';
            hideSubMenus();
        }

    },


    // private method. Returns mouse position
    _getMousePosition : function (e) {

        e = e ? e : window.event;
        var height = document.getElementById('rightcol').offsetHeight + 105; // 105 = header + navbar max-height
        var width = document.getElementById('content').offsetWidth;
        // if the menu is too near the bottom
        if ((e.clientY)+140 > height){ //160 = hardcoded hieght offsetHeight of tagmenu
        	// if the menu is too near the right
        	if ((e.clientX+100) > width){ //100 = hardcoded width offsetHeight of tagmenu
 				var position = {
	            'x' : width - 130, 
	            'y' : e.clientY - 80 - 140 //140 = hardcoded offsetHeight of tagmenu
	        	}       		
        	}
        	// if the menu is not too near the right
        	else {
	        	var position = {
	            'x' : e.clientX,
	            'y' : e.clientY - 80 - 140 //140 = hardcoded offsetHeight of tagmenu
	        	}
        	}
        }
        //if the menu is not too near the bottom
        else{
        	// if the menu is too near the right
        	if ((e.clientX+100) > width){ //100 = hardcoded width offsetHeight of tagmenu
 				var position = {
	            'x' : width - 130,
	            'y' : e.clientY - 100
	        	}       		   	
        	}
        	// if the menu is not too near the right
        	else {
		        var position = {
		            'x' : e.clientX,
		            'y' : e.clientY - 100
		        }
		   }
		}
        return position;

    },


    // private method. Get document scroll position
    _getScrollPosition : function () {

        var x = 0;
        var y = 0;

        if( typeof( window.pageYOffset ) == 'number' ) {
            x = window.pageXOffset;
            y = window.pageYOffset;
        } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
            x = document.documentElement.scrollLeft;
            y = document.documentElement.scrollTop;
        } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
            x = document.body.scrollLeft;
            y = document.body.scrollTop;
        }

        var position = {
            'x' : x,
            'y' : y
        }

        return position;

    }

}

/*
// Script:   cookies.js
// Version:   0.01
// Description:
//  functions to assist cookie management
*/

function setCookie(name, val) {
  if (!name) {return false;}
  // nullify any existing cookie crumb with this name
  var cookieList = document.cookie.split(';');
  for (var x = 0; x < cookieList.length; x++) {
    var cookie = cookieList[x]
    while(cookie.charAt(0) == ' '){cookie = cookie.substr(1, cookie.length)}
    cookie = cookie.split('=');
    if( cookie[0] == escape(name) || cookie[0] == name) {
    	cookieList[x] = null;
    }
  }
  // add specified crumb to cookie
  document.cookie = new Array(escape(name) + "=" + escape(val), 'path=/ead/').concat(cookieList).join(';');
}

function getCookie(name) {
  var cookieList = document.cookie.split(';');
  for (var x = 0; x < cookieList.length; x++) {
    var cookie = cookieList[x]
    while(cookie.charAt(0) == ' '){cookie = cookie.substr(1, cookie.length)}
    cookie = cookie.split('=');
    if( cookie[0] == escape(name) || cookie[0] == name) { 
      return unescape(cookie[1]); 
    }
  }
  return '';
}

/*
// Script:   counter.js
// Version:   0.01
// Description:
// 	functions to allow onscreen counter objects
*/

function incr(elementId) {
	if( !document.getElementById) {
		return;
	}
	var e = document.getElementById( elementId );
	var i = parseInt(e.innerHTML)
	i++
	e.innerHTML = i	
}

function decr(elementId) {
	if( !document.getElementById) {
		return;
	}
	var e = document.getElementById( elementId );
	var i = parseInt(e.innerHTML)
	i--
	e.innerHTML = i
}

/*
// Program:   ead.js
// Version:   0.10
// Description:
//            JavaScript functions used in the Cheshire3 EAD search/retrieve and display interface 
//            - part of Cheshire for Archives v3.x
//
// Language:  JavaScript
// Author:    John Harrison <john.harrison@liv.ac.uk>
// Date:      17/02/2009
//
// Copyright: &copy; University of Liverpool 2005-2011
//
// Version History:
// 0.01 - 25/05/2005 - JH - Nested list ToC manipulation functions scripted
// 0.02 - xx/06/2005 - JH - Rudimentary splash screen added
// 0.03 - 21/10/2005 - JH - Cookie support added to maintain state of expanded list when page is unloaded
// 0.04 - 04/01/2006 - JH - E-mail addresses checked before submission to save server time
// 0.05 - 18/06/2006 - JH - TOC state cookie stuff debugged
// 												- Search form manipulation to add more clauses
// 0.06 - 03/08/2006 - JH - Non EAD specific functions separated into aptly named files in a separate javascript dir
// 0.07 - 15/05/2007 - JH - toggleShow function added
// 0.08 - 23/07/2008 - JH - function stacks implemented using Simon Willison's addLoadEvent
// 0.09 - 26/09/2008 - JH - Visual effects (show/hide) superceded by those in visuals.js - removed
// 0.10 - 17/02/2009 - JH - Array prototype stuff added for standard functionality in v. old browsers (IE<5.5)
*/ 

Array.prototype.indexOf=function(n){for(var i=0;i<this.length;i++){if(this[i]===n){return i;}}return -1;}
Array.prototype.lastIndexOf=function(n){var i=this.length;while(i--){if(this[i]===n){return i;}}return -1;}
Array.prototype.forEach=function(f){var i=this.length,j,l=this.length;for(i=0;i<l;i++){if((j=this[i])){f(j);}}};
Array.prototype.insert=function(i,v){if(i>=0){var a=this.slice(),b=a.splice(i);a[i]=value;return a.concat(b);}}
Array.prototype.shuffle=function(){var i=this.length,j,t;while(i--){j=Math.floor((i+1)*Math.random());t=arr[i];arr[i]=arr[j];arr[j]=t;}}
Array.prototype.unique=function(){var a=[],i;this.sort();for(i=0;i<this.length;i++){if(this[i]!==this[i+1]){a[a.length]=this[i];}}return a;}
if(typeof Array.prototype.concat==='undefined'){Array.prototype.concat=function(a){for(var i=0,b=this.copy();i<a.length;i++){b[b.length]=a[i];}return b;};}
if(typeof Array.prototype.copy==='undefined'){Array.prototype.copy=function(a){var a=[],i=this.length;while(i--){a[i]=(typeof this[i].copy!=='undefined')?this[i].copy():this[i];}return a;};}
if(typeof Array.prototype.pop==='undefined'){Array.prototype.pop=function(){var b=this[this.length-1];this.length--;return b;};}
if(typeof Array.prototype.push==='undefined'){Array.prototype.push=function(){for(var i=0,b=this.length,a=arguments;i<a.length;i++){this[b+i]=a[i];}return this.length;};}
if(typeof Array.prototype.shift==='undefined'){Array.prototype.shift=function(){for(var i=0,b=this[0];i<this.length-1;i++){this[i]=this[i+1];}this.length--;return b;};}
if(typeof Array.prototype.slice==='undefined'){Array.prototype.slice=function(a,c){var i=0,b,d=[];if(!c){c=this.length;}if(c<0){c=this.length+c;}if(a<0){a=this.length-a;}if(c<a){b=a;a=c;c=b;}for(i;i<c-a;i++){d[i]=this[a+i];}return d;};}
if(typeof Array.prototype.splice==='undefined'){Array.prototype.splice=function(a,c){var i=0,e=arguments,d=this.copy(),f=a;if(!c){c=this.length-a;}for(i;i<e.length-2;i++){this[a+i]=e[i+2];}for(a;a<this.length-c;a++){this[a+e.length-2]=d[a-c];}this.length-=c-e.length+2;return d.slice(f,f+c);};}
if(typeof Array.prototype.unshift==='undefined'){Array.prototype.unshift=function(a){this.reverse();var b=this.push(a);this.reverse();return b;};}


function addLoadEvent(func) {
/*
// DEPRECATED: Use jQuery $(document).ready() instead
*/
	var oldonload = window.onload;
	if (typeof window.onload != 'function') {
    	window.onload = func;
	} else {
	window.onload = function() {
			if (oldonload) {
				oldonload();
			}
			func();
		}
	}
}

function addUnloadEvent(func) {
	var oldonunload = window.onunload;
	if (typeof window.onunload != 'function') {
    	window.onunload = func;
	} else {
	window.onunload = function() {
			if (oldonunload) {
				oldonunload();
			}
			func();
		}
	}
}



/* Splash Screen */
var splash = null;
var myBars = 'directories=no,location=no,menubar=no,status=no,titlebar=no,toolbar=no,scrollbars=no';
var myOptions = 'innerWidth=400,outerWidth=400,innerHeight=150,outerHeight=150,resizable=no';
//var myPosition = 'screenX=300, screenY=200';
var myPosition = 'left=300, top=200';

function splashScreen(){
  splash = window.open("/ead/ead-splash.html","splashScreen",myBars + ',' + myOptions + ',' + myPosition);
}

function closeSplash(){
  //splash = window.open("/ead/ead-splash.html", "splashScreen", myBars + ', height=1, width=1, left=1024, top=1024');
  if (splash) {
  	splash.close();
  	splash = null;
  }
}

var op = null;

function confirmOp(){
	switch(op) {
		case 'unindex':
			var msg = 'This operation will PERMANENTLY remove the file from the hard-disk. The record will also be removed from all indexes, which may take some time. Are you sure you wish to continue?';
			break
		case 'delete':
			var msg = 'This operation will PERMANENTLY remove the file from the hard-disk. Are you sure you wish to continue?';
			break
			
		default:
			if (arguments.length == 1){
				/*hopefully a message we should send*/
				var msg = arguments[0];
			}
			break
	}
	if (msg) {
		if (window.confirm) { return window.confirm(msg); }
		else if (confirm) { return confirm(msg); }
		else { return true; } // no mechanism for confirmation supported by browser - go ahead anyway
	} else {return true; } // no requirement for confirmation
}

/*
// Script:   	email.js
// Version:   0.01
// Description:
//            JavaScript functions used in the Cheshire3 EAD search/retrieve and display interface 
//            - part of Cheshire for Archives v3.x
//
// Language:  JavaScript
// Author:    John Harrison <john.harrison@liv.ac.uk>
// Date:      03 August 2006
//
// Copyright: &copy; University of Liverpool 2005, 2006
//
// Version History:
// 0.01 - 03/08/2006 - JH - Email address verification function(s) pasted in from previous script
//
*/

function checkEmailAddy(){
	var addy = document.email.address.value;
	var emailRe  = /^[a-zA-Z][^@ .]*(\.[^@ .]+)*@[^@ .]+\.[^@ .]+(\.[^@ .]+)*$/;
	if(emailRe.test(addy)) {
		return true;
	}
	else {
		alert('Your address did not match the expected form: name@company.domain\n\nPlease re-enter your address.');
		return false;
	}
}

function addFormValidation(){
	if( !document.getElementsByTagName) {
  		return;
  	}	
  	var forms = document.getElementsByTagName("form");
  	for (var i = 0; i < forms.length; i++) {
		if (forms[i].className.match('email')){
			forms[i].onsubmit = function() { return checkEmailAddy(); }
		}
	}
}

/*
// Program:		form.js
// Version:   	0.01
// Description:
//            	JavaScript functions for the Cheshire for Archives EAD Editor.  
//            	- part of Cheshire for Archives v3.x
// Language:  	JavaScript
// Author(s):   Catherine Smith <catherine.smith@liv.ac.uk>	
// Date:      	12/01/2009
// Copyright: 	&copy; University of Liverpool 2009
//
// Version History:
// 0.01 - 12/01/2009 - CS - functions completed for first release of Cheshire for Archives EAD Editor
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
var required_xpaths = new Array(
'unitid',
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
			deleteRec(recid);
		}
		else {
			return;
		}
	}
}

function deleteRec(id){
	var url = '/ead/edit/';
	var data = 'operation=deleteRec&recid=' + encodeURIComponent(id);
	var ajax = new Ajax.Request(url, {method:'post', asynchronous:false, postBody:data, evalScripts:true, onSuccess: function(transport) {	
		location.href="/ead/edit/menu.html";		    
	}});		
}

function discardRec(id){
	var url = '/ead/edit/';
	var data = 'operation=discard&recid=' + encodeURIComponent(id);
    if ($('owner') != null){    
    	setOwner($('owner').value);
    }	
	if (fileOwner != null){
		data += '&owner=' + encodeURIComponent(fileOwner);
	}
	var ajax = new Ajax.Request(url, {method:'post', asynchronous:false, postBody:data, evalScripts:true, onSuccess: function(transport) {	
		location.href="/ead/edit/menu.html";		    
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
    var errors = document.getElementsByClassName('dateError');
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
	saveForm(false);
	
	//validate whole record
	invalid = document.getElementsByClassName('invalid');
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
    	var data = 'operation=navigate&recid=' + encodeURIComponent(recid) + '&newForm=' + currentForm; 
    	if (fileOwner != null){
    		data += '&owner=' + encodeURIComponent(fileOwner);
    	}
    	if ($('ctype')){
    		data += '&ctype=' + ($('ctype')).value;
    	}
    	var loc = $('rightcol');
		new Ajax.Updater(loc, '/ead/edit', {method: 'get', asynchronous:false, parameters:data, evalScripts:true});	
		updateTitle(null);
    }
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
	checkId(false);
	if ($('idError')){
		alert('The form cannot be saved because a file in the database has the same reference code as the record you are creating. Please change the reference code and try again. If you are trying to replace the file in the main database you need to delete it from the database in the admin menu before creating the new file.');
		body.className = 'none';
		return;
	}
	var errors = document.getElementsByClassName('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before saving. Errors will be marked with red shading in the text box.');
    	body.className = 'none';
    	return;
    }
    var errors = document.getElementsByClassName('dateError');
    if (errors.length != 0){
    	alert('Please fix the error in the normalised date before saving. This field can only contain numbers and the character /.');
    	body.className = 'none';
    	return;
    }
    var values = checkEditStore();
    if (values[0] == 'error'){
    	alert('A problem occurred when trying to perform this operation. Please check that the spoke is responding to searches before trying again.');
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
	saveForm(false);
	body.className = 'none';
    alert('This form is now saved as ' + recid + ' and can be reloaded from the admin menu for further editing at a later date.');
		
}


function saveForm(asynch){
	var relocate = false;
	warn = false;
	resetAllAccessPoints()
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
  	previousForm = currentForm;
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
    	data += '&recid=' + encodeURIComponent(recid);
    }
    else {
    	recid = ($('pui')).value;
    	relocate = true;
    }
    if (fileOwner != null){
    	data += '&owner=' + encodeURIComponent(fileOwner);
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
	if (relocate == true){
		window.location.href='/ead/edit/?operation=load&recid=' + encodeURIComponent(recid);
	}
}


function displayForm(id, level, nosave){

	if (nosave == undefined){
		nosave = false;
	}
	/* for adding a new form */
	if (id == 'new'){
		var data = 'operation=add&recid=' + encodeURIComponent(recid) + '&clevel=' + level;
		var loc = $('rightcol');		
	   	new Ajax.Updater(loc, '/ead/edit/', {method: 'post', asynchronous:false, parameters:data, evalScripts:true});

	   	($('countrycode').value) = countryCode;	   			
	   	($('archoncode').value) = repositoryCode;
	   	($('unitid').value) = baseUnitId + '/' + currentForm.replace(/-/g, '/');
	   	($('pui').value) = recid;
	   	updateId();
	}
	/* for navigating to an existing form*/
	else {	 
		if (nosave == false){
			if (!checkRequiredData()){
				alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title');
				return;
			} 	
			errors = document.getElementsByClassName('menuFieldError');
		    if (errors.length != 0){
		    	alert('Please fix the errors in the xml before leaving this page. Errors will be marked with red shading in the text box.');
		    	return;
		    }
		    var errors = document.getElementsByClassName('dateError');
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
			saveForm(false);
		}	
		var data = 'operation=navigate&recid=' + encodeURIComponent(recid) + '&newForm=' + id;
		if (fileOwner != null){
			data += '&owner=' + encodeURIComponent(fileOwner);
		}
		var loc = $('rightcol');
		new Ajax.Updater(loc, '/ead/edit', {method: 'get', asynchronous:false, parameters:data, evalScripts:true, onSuccess: function(transport){		   	
	    
		}});
		if ($(currentForm)){
			($(currentForm)).style.background = 'none';
		}
	    currentForm = id;
	    ($(currentForm)).style.background = 'yellow';		    		  	 	  	
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
    errors = document.getElementsByClassName('menuFieldError');
    if (errors.length != 0){
    	alert('Please fix the errors in the xml before adding a component. Errors will be marked with red shading in the text box.');
    	body.className = 'none';
    	return;
    }  
    var errors = document.getElementsByClassName('dateError');
    if (errors.length != 0){
    	alert('Please fix the error in the normalised date before adding a component. This field can only contain numbers and the character /.');
    	body.className = 'none';
    	return;
    }
    else if (currentForm == 'collectionLevel' && recid == 'notSet'){
		var url = '/ead/edit'
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
	if (currentForm == 'collectionLevel' && recid == 'notSet' && document.getElementById('recid') == 'notSet'){
		var url = '/ead/edit';
		var data = 'operation=checkId&id=' + encodeURIComponent(($('pui')).value) + '&store=editStore';
		new Ajax.Request(url, {method: 'get', asynchronous: false, parameters: data, onSuccess: function(transport) { 	    				
			var response = transport.responseText;
			var idExists = response.substring(7,response.indexOf('</value>'));
   			if (idExists == 'true'){
   				var cont = confirmOp('A record with this ID already exists within the editing store which means it has either been loaded for editing or is in the process of being created by you or another user and has not yet been submitted to the main database. If you continue you will overwrite this record and it will be lost \n\n Are you sure you want to continue? ');
   				if (!cont){
					body.className = 'none';
					return;
				} 	
   			}     			
	 	}});
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
    newLink.onclick = new Function("javascript: displayForm(this.id, 0)");
    newLink.className = 'invalid';
    newLink.appendChild(document.createTextNode(linkId));
    
    deleteLink = document.createElement('a');
    deleteLink.setAttribute('id', 'delete_' + linkId);
    deleteLink.onclick = new Function("javascript: deleteComponent('" + linkId + "')");

    deleteImage = document.createElement('img');
    deleteImage.setAttribute('src', '/ead/img/delete.png');
    deleteImage.setAttribute('onmouseover', 'this.src=\'/ead/img/delete-hover.png\';')
    deleteImage.setAttribute('onmouseout', 'this.src=\'/ead/img/delete.png\';')
    deleteImage.className = 'deletelogo';
    
    deleteLink.appendChild(deleteImage);
        
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
	var url = '/ead/edit';
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
			    deleteImage.setAttribute('src', '/ead/img/delete.png');
			    deleteImage.setAttribute('onmouseover', 'this.src=\'/ead/img/delete-hover.png\';')
    			deleteImage.setAttribute('onmouseout', 'this.src=\'/ead/img/delete.png\';')
			    deleteImage.className = 'deletelogo';
			    
			    deleteLink.appendChild(deleteImage);
			    
			    grandparent.appendChild(deleteLink);
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
	}
	refreshTree('someId');
	body.className = 'none';
}

function viewXml(){
	if (!checkRequiredData()){
		alert ('the following fields must be entered before proceeding:\n  - Reference Code \n  - Title');
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
    var errors = document.getElementsByClassName('dateError');
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
	saveForm(false);
	var url = '/ead/edit?operation=xml&recid=' + encodeURIComponent(recid);
	if (fileOwner != null){
		url += '&owner=' + encodeURIComponent(fileOwner);
	}
	window.location.href=url;
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
    var errors = document.getElementsByClassName('dateError');
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
	saveForm(false);
	url = '/ead/edit?operation=preview&recid=' + encodeURIComponent(recid);	
	if (fileOwner != null){
		url += '&owner=' + encodeURIComponent(fileOwner);
	}
	window.location.href=url;
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
			var data = 'operation=reassign&recid=' + encodeURIComponent(recid) + '&user=' + encodeURIComponent(user);
			var ajax = new Ajax.Request(url, {method:'post', asynchronous:false, postBody:data, evalScripts:true, onSuccess: function(transport) {  	
				location.href="/ead/edit/menu.html";		    
			}});
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
	 		var value = $(s).getValue($(s)).strip();
		 	if (value == '' || value == ' ' || value == '<p></p>' || value.replace(/[\s]+/g, ' ') == '<p> </p>'){
				$(('link' + s)).update('add content');	
		  	} 
		  	else { 
				$(('link' + s)).update('show content');
		  	}
		}
	}
}



//================================================================================================
// passive UI Functions to update left hand column navigation menu

function updateTitle(field) {
  	var link = document.getElementById(currentForm);
  	var title = ($('did/unittitle')).value;
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
  	var title = ($('did/unittitle')).value;
  	if (title.indexOf('<') != -1){
		title = title.replace(/<\/?\S+?>/g, '');
  	}
  	var countryCode = $('countrycode').value.toLowerCase();
  	var repositoryCode = $('archoncode').value;
  	var id = $('unitid').value;
  	
  	if (title == '' && id == ''){
  		link.innerHTML = currentForm;
  	}
  	else {
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
					match = false;
				}
			}
			lowerCaseId = lowerCaseId.replace(/ /g, '').replace(/\//g, '-').replace(/\\/g, '-').replace(/'/g, '');
			if (match == true){
				for (var i=0; i < repositoryCode.length; i++){
					if (repositoryCode.charAt(i) != lowerCaseId.charAt(i+2)){
						match = false;
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
		
		var url = '/ead/edit'
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


/*function checkRecordStoreConficts(form){
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
		var url = '/ead/edit'
		var data = 'operation=getCheckRecStoreId&filepath=' + filepath;
		new Ajax.Request(url, {method: 'post', asynchronous: false, parameters: data, onSuccess: function(transport) { 
			var response = transport.responseText;	
			if (response.substring(0, 4) == "<!--"){
				alert('A problem occurred when trying to perform this operation. Please check that the spoke is responding to searches before trying again.');
				return;
			}
			conflict = response.substring(response.indexOf('<value>')+7, response.indexOf('</value>'));
		}});
		if (conflict == 'false'){
			checkEditStoreConflicts(form);
		}
		else {
			alert('A file with the same ID as the file you are trying to upload already exists in your spokes database. In order to edit this file you must import it from the spoke database rather than uploading from your local file store.');
			return;	
		}
	}	
}*/


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
		var url = '/ead/edit'
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
	var url = '/ead/edit/';
	var data = 'operation=validate&text=' + field.value.replace(/%/g, '%25').replace(/&/g, '%26').replace(/#/g, '%23').replace(/;/g, '%3B');	
	var ajax = new Ajax.Request(url, {method: 'post', asynchronous: asynch, postBody:data, onSuccess: function(transport) { 		
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

function checkEditStore(){
	var value = false;
	var owner = '';
	var error = false;
	if (currentForm == 'collectionLevel'){		
		if (recid == null || recid == 'notSet'){
			if ($('countrycode').value != ''){
				if ($('archoncode').value != ''){
					if ($('unitid').value != ''){
						var id = $('countrycode').value.toLowerCase() + $('archoncode').value + $('unitid').value.replace(' ', '').replace('/', '-').replace('\\', '-').replace('\'', '').toLowerCase();
						var url = '/ead/edit'
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


// NEED TO ADD ERROR CATCH HERE
function checkId(asynch){
	if (recid == null || recid == 'notSet'){
		if ($('countrycode').value != ''){
			if ($('archoncode').value != ''){
				if ($('unitid').value != ''){
					var id = $('countrycode').value.toLowerCase() + $('archoncode').value + $('unitid').value.replace(' ', '').replace('/', '-').replace('\\', '-').replace('\'', '').toLowerCase();
					var url = '/ead/edit';
					var data = 'operation=checkId&id=' + encodeURIComponent(id) + '&store=recordStore';
					new Ajax.Request(url, {method: 'get', asynchronous: asynch, parameters: data, onSuccess: function(transport) { 	    				
					    var response = transport.responseText;
					    var idExists = response.substring(7,response.indexOf('</value>'));					    
					    if (idExists == 'true' && !($('idError'))){
					    	var element = document.createElement('p');
					    	element.className = 'error';
					    	element.setAttribute('id', 'idError');
					    	element.appendChild(document.createTextNode('Reference code already exists in database'));
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
	}	
	updateId();
}


function checkRequiredData(){
	if ($('did/unittitle').value == ''){
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


function showSubMenu(type, pos, parent){
	if (parent == 'tagmenu'){
		hideSubMenus();
	}
	var menu = null;
	
	menu = ($(type + 'menu'));

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
	($('linkmenu')).style.display = 'none';
	($('titlemenu')).style.display = 'none';
	($('listmenu')).style.display = 'none';
	($('fontmenu')).style.display = 'none';
	($('archivalmenu')).style.display = 'none';
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
		document.getElementById('xml-button').setAttribute('disabled', 'true');
		document.getElementById('xml-button').setAttribute('title', 'File must be saved before this operation can be performed');
		document.getElementById('preview-button').setAttribute('disabled', 'true');
		document.getElementById('preview-button').setAttribute('title', 'File must be saved before this operation can be performed');
		document.getElementById('tofile-button').setAttribute('disabled', 'true');
		document.getElementById('tofile-button').setAttribute('title', 'File must be saved before this operation can be performed');
		document.getElementById('submit-button').setAttribute('disabled', 'true');
		document.getElementById('submit-button').setAttribute('title', 'File must be saved before this operation can be performed');		
		document.getElementById('addC').setAttribute('disabled', 'true');
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

/*
// Script:   hijax.js
// Version:   0.03
// Description:
//            JavaScript functions for Ajax manipulations of HTML pages.  
//            - produced for the Archives Hub v3.0
//
// Language:  JavaScript
// Author:    John Harrison <john.harrison@liv.ac.uk>
// Date:      05/10/2010
//
// Copyright: &copy; University of Liverpool 2005-2010
//
// Version History:
// 0.01 - 28/07/2008 - JH - functions scripted
// 0.02 - 28/01/2009 - JH - useability tweaks
// 0.03 - 05/10/2010 - JH - Provision for search/browse preview on form page
// 0.04 - 25/01/2011 - JH - Bug fix for browse preview
*/

function createXMLHttpRequest() {
	var xmlHttp=null;
	try {
		// Firefox, Opera 8.0+, Safari
		xmlHttp=new XMLHttpRequest();
	}
	catch (e) {
		// Internet Explorer
		try {
			xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
			}
		catch (e) {
			try {
		    	xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
		    }
			catch (e) {
			    alert("Your browser does not support AJAX! Some functionality will be unavailable.");
			    return false;
		    }
		}
	}
	return xmlHttp;
}


function updateElementByUrl(id, url, loadImg) {
	if( !document.getElementById) {
		window.alert("Your browser does not support functions essential for updating this page with AJAX!\n\nYou should still be able to use all functions of this site by disabling JavaScript in your browser settings.")
		return true;
	}
	var el = document.getElementById(id);
	// first obscure target to avoid repeat clicks
	try {
		displayLoading(el, loadImg);
	}
	catch (e) {
		alert('No element with id: ' + id)
	}
	var xmlHttp = createXMLHttpRequest();
	if (xmlHttp==null) {
		alert ("Your browser does not support AJAX!");
		return true;
	}
	xmlHttp.onreadystatechange=function() {
		if(xmlHttp.readyState==4) {
			if (xmlHttp.status == 200 || xmlHttp.status == 304) {
				el.innerHTML=xmlHttp.responseText;
				ajaxifyLinks(el);
				ajaxifyForms(el);
				try {
					hideStuff(el);
				} catch(err) {
				}
				try {
					fadeToWhite(el, 183, 232, 245);
				} catch(err) {
				}
			}
		}
	}
	xmlHttp.open("GET",url,true);
  	xmlHttp.send(null);
  	return false;
}


function addListener(element, type, listener) {
    if(element.addEventListener) {
        element.addEventListener(type, listener, false);
    } else {
        element.attachEvent('on' + type, listener);
    }
};


function addKeyListener(element, listener) {
    if (navigator.userAgent.indexOf("Safari") > 0) {
        element.addEventListener("keydown", listener, false);
    } else if (navigator.product == "Gecko") {
        element.addEventListener("keypress", listener, false);
    } else {
        element.attachEvent("onkeydown", listener);
    }
};


function xmlToString(node) {
    if (typeof XMLSerializer != "undefined") {
        return (new XMLSerializer()).serializeToString(node) ;
    } else if (node.xml) {
        return node.xml;
    } else {
        throw "Unable to serialize XML " + node;
    }
}; 

function liveUpdater(uriFunc, resultid, preFunc, postFunc) {
    if(!preFunc) preFunc = function () {};
    if(!postFunc) postFunc = function () {};
    var xmlHttp = createXMLHttpRequest();
    if (xmlHttp==null) {
        alert ("Your browser does not support AJAX!");
        return;
    }
    
    if ( !document.getElementById) {
            window.alert("Your browser does not support functions essential for updating this page with AJAX!");
            return;
        }
    var el = document.getElementById(resultid); 
        
    function update() {
        preFunc();
        xmlHttp.onreadystatechange = processRequestChange;
        xmlHttp.open("GET", uriFunc());
        xmlHttp.send(null);
        return true;
    };
    
    function processRequestChange() {
        if(xmlHttp.readyState==4) {
            if (xmlHttp.status == 200 || xmlHttp.status == 304) {
                var data = xmlHttp.responseXML.documentElement;
                var dataEl = data.getElementsByTagName("table")[0];
                el.innerHTML = xmlToString(dataEl); 
                ajaxifyLinks(el);
                ajaxifyForms(el);
                try {
                    hideStuff(el);
                } catch(e) {
                }
            }
        }
        postFunc();
    };
    
    return update
};


function liveSearch(id, resultid, field_event_type, preFunc, postFunc) {
    function formToURL(){
        if ( !document.getElementById) {
	        window.alert("Your browser does not support functions essential for updating this page with AJAX!");
	        return;
	    }
        myForm = document.getElementById(id).form; 
	    var i = 0;
	    var params = new Array();
	    params.push('operation=' + myForm.elements['operation'].value);
	    while (myForm.elements['fieldcont' + (i+1)] && myForm.elements['fieldcont' + (i+1)].value != "") {
	        if (i > 0) {
	            var boolgrp = document.getElementsByName('fieldbool' + i);
	            //while (!boolgrp[0].value) {boolgrp = boolgrp.slice(1);}
	            for (var j = 0; j < boolgrp.length; j++) {
	                if (boolgrp[j].checked == true) {
	                    params.push('fieldbool' + i + '=' + boolgrp[j].value);
	                }
	            }
	        }
	        i++;
	        var idxSel = myForm.elements['fieldidx' + i];
            try {
	           var idxI = idxSel.selectedIndex;
	           params.push('fieldidx' + i + '=' + idxSel.options[idxI].value);
            } catch(e) {};
            try { 
	           params.push('fieldrel' + i + '=' + myForm.elements['fieldrel' + i].value);
            } catch(e) {};
	        params.push('fieldcont' + i + '=' + escape(myForm.elements['fieldcont' + i].value));
	    }
	    url = myForm.action + '?' + params.join('&'); 
	    return url + '&maximumTerms=7&ajax=1';
	};

    var updater = liveUpdater(formToURL, resultid);
    var timeout = false;
        
    function start() {
		if (timeout) {
		    window.clearTimeout(timeout);
		}
		timeout = window.setTimeout(updater, 200);
    };
    
    if (typeof field_event_type != "undefined") {
        addListener(document.getElementById(id), field_event_type.toLowerCase(), updater);
	} else {
	    addKeyListener(document.getElementById(id), start);
	}
};


function displayLoading(el, loadImg) {
	if (typeof loadImg == 'undefined'){
		loadImg = '/ead/img/ajax-loader.gif';
	}
	el.innerHTML = '<div class="loading"><img src="' + loadImg + '" alt=""/></div>';
};


function ajaxifyLinks(el){
	if( !el.getElementsByTagName) {
  		return;
  	}
  	var linkList = el.getElementsByTagName("a");
	for (var i = 0; i < linkList.length; i++) {
		var el = linkList[i]
		if (el.className.match('ajax')){
			el.onclick = function() {
				var hrefParts = this.getAttribute("href").split("#")
				var div = hrefParts.pop()
				hrefParts.push("&ajax=1")
				updateElementByUrl(div, hrefParts.join(""));
				return false;
			}
		}
	}
};

function ajaxifyForms(el){
	if( !el.getElementsByTagName) {
  		return;
  	}
  	var formList = el.getElementsByTagName("form");
	for (var i = 0; i < formList.length; i++) {
		var el = formList[i]
		if (el.className.match('ajax')){
			el.onsubmit = function() {
                var div = this.className.split('-').pop();
				var hrefParts = new Array([this.getAttribute("action")]);
				hrefParts.push("?ajax=1")
				// INPUTS
				var inputList = this.getElementsByTagName("input");
				for (var j = 0; j < inputList.length; j++) {
					var inp = inputList[j];
					hrefParts.push('&');
				   	if (inp.type == "checkbox") {
						if (inp.checked) {
						   hrefParts.push(inp.name + "=" + inp.value);
						} else {
						   hrefParts.push(inp.name + "=0");
						}
					} else if (inp.type == "radio") {
					   if (inp.checked) {
					      hrefParts.push(inp.name + "=" + inp.value);
					   }
					} else {
						hrefParts.push(inp.name + "=" + inp.value);
					}
				}
				//SELECTS
				var inputList = el.getElementsByTagName("select");
				for (var j = 0; j < inputList.length; j++) {
					hrefParts.push('&');
					hrefParts.push(inputList[j].name + "=" + inputList[j].options[inputList[j].selectedIndex].value);
				}
				updateElementByUrl(div, hrefParts.join(""));
				return false;
			}
		}
	}
};

/*
// Program:		keyboard.js
// Version:   	0.02
// Description:
//            	JavaScript functions for input of special characters into the ead template.  
//            	- produced for the Archives Hub v3.x. 
// Language:  	JavaScript
// Author(s):   John Harrison <john.harrison@liv.ac.uk>
//				Catherine Smith <catherine.smith@liv.ac.uk>
// Date:      	09/01/2009
// Copyright: 	&copy; University of Liverpool 2005-2009
//
// Version History:
// 0.01 - 08/08/2006 - JH - basic functions completed for original ead2002 template
// 0.02 - 09/01/2009 - CS - Addition of code to maintain current scroll position in text area after adding character
//							field codes changes to represent new ead editing interface
*/



var	currentEntryField = null;
var	theFieldName = "Error. You have not yet selected a field to enter text into.";

var fieldMap = new Array();

	fieldMap['countrycode'] = 'Country Code';
	fieldMap['archoncode'] = 'Archon Code';
	fieldMap['unitid'] = 'Unit ID';
	fieldMap['did/unittitle'] = 'Title';
	fieldMap['did/unitdate'] = 'Dates of Creation';
	fieldMap['did/unitdate/@normal'] = 'Normalised Date - This should NOT contain character entities';
	fieldMap['did/physdesc/extent'] = 'Extent of Unit Description';
	fieldMap['did/repository'] = 'Repository';
	fieldMap['filedesc/titlestmt/sponsor'] = 'Sponsor';
	fieldMap['did/origination'] = 'Name of Creator';
	fieldMap['bioghist'] = 'Administrative/Biographical History';
	fieldMap['custodhist'] = 'Archival History';
	fieldMap['acqinfo'] = 'Immediate Source of Acquisition';
	fieldMap['scopecontent'] = 'Scope and Content';
	fieldMap['appraisal'] = 'Appraisal';
	fieldMap['accruals'] = 'Accruals';
	fieldMap['arrangement'] = 'System of Arrangement';
	fieldMap['accessrestrict'] = 'Conditions Governing Access';
	fieldMap['userestrict'] = 'Conditions Governing Reproduction';
	fieldMap['lang_name'] = 'Language of Material - Language Name';
	fieldMap['lang_code'] = 'Language of Material - Language Code - This should NOT contain character entities';
	fieldMap['phystech'] = 'Physical Characteristics';
	fieldMap['otherfindaid'] = 'Finding Aids';
	fieldMap['originalsloc'] = 'Existence/Location of Orginals';
	fieldMap['altformavail'] = 'Existence/Location of Copies';
	fieldMap['relatedmaterial'] = 'Related Units of Description';
	fieldMap['bibliography'] = 'Publication Note';
	fieldMap['note'] = 'Note';
	fieldMap['processinfo'] = 'Archivist\'s Note';
	fieldMap['dao/@href'] = 'Digital Object - URI';
	fieldMap['did/dao/@href'] = 'Digital Object - URI';
	fieldMap['dao/@title'] = 'Digital Object - Title';
	fieldMap['did/dao/@title'] = 'Digital Object - Title';
	fieldMap['dao/daodesc'] = 'Digital Object - Description';
	fieldMap['did/dao/daodesc'] = 'Digital Object - Description';
	fieldMap['daogrp/daoloc/@href'] = 'Digital Object - URI';
	fieldMap['did/daogrp/daoloc/@href'] = 'Digital Object - URI';
	fieldMap['daogrp/daoloc/@title'] = 'Digital Object - Title';
	fieldMap['did/daogrp/daoloc/@title'] = 'Digital Object - Title';
	fieldMap['daogrp/daodesc'] = 'Digital Object - Description';
	fieldMap['did/daogrp/daodesc'] = 'Digital Object - Description';
	fieldMap['persname_surname'] = 'Personal Name - Surname';
	fieldMap['persname_forename'] = 'Personal Name - Forename';
	fieldMap['persname_dates'] = 'Personal Name - Dates';
	fieldMap['persname_title'] = 'Personal Name - Title';
	fieldMap['persname_epithet'] = 'Personal Name - Epithet';
	fieldMap['persname_other'] = 'Personal Name - Other';
	fieldMap['persname_source'] = 'Personal Name - Source';
	fieldMap['famname_surname'] = 'Family Name - Surname';
	fieldMap['famname_other'] = 'Family Name - Other';
	fieldMap['famname_dates'] = 'Family Name - Dates';
	fieldMap['famname_title'] = 'Family Name - Title';
	fieldMap['famname_epithet'] = 'Family Name - Epithet';
	fieldMap['famname_loc'] = 'Family Name - Location';
	fieldMap['famname_source'] = 'Family Name - Source';
	fieldMap['corpname_organisation'] = 'Corporate Name - Organisation';
	fieldMap['corpname_dates'] = 'Corporate Name -_Dates';
	fieldMap['corpname_loc'] = 'Corporate Name - Location';
	fieldMap['corpname_other'] = 'Corporate Name - Other';
	fieldMap['corpname_source'] = 'Corporate Name - Source';
	fieldMap['subject_subject'] = 'Subject';
	fieldMap['subject_dates'] = 'Subject - Dates';
	fieldMap['subject_loc'] = 'Subject - Location';
	fieldMap['subject_other'] = 'Subject - Other';	
	fieldMap['subject_source'] = 'Subject - Thesaurus';
	fieldMap['geogname_location'] = 'Place Name - Location';
	fieldMap['geogname_other'] = 'Place Name - Other';
	fieldMap['geogname_source'] = 'Place Name - Source';
	fieldMap['title_title'] = 'Book Title';
	fieldMap['title_dates'] = 'Book Title - Dates';
	fieldMap['title_source'] = 'Book Title - Source';
	fieldMap['genreform_genre'] = 'Genre Form';	
	fieldMap['genreform_source'] = 'Genre Form - Source';	
	fieldMap['function_function'] = 'Function';
	fieldMap['function_source'] = 'Function - Source';
			
	
	function getFieldName(code){
		if (code.indexOf('[') != -1){
			var lookup = code.replace(/\[[0-9]+\]/g, '');
		}
		else {
			var lookup = code;
		}
		return fieldMap[lookup];
	}
	
	function setCurrent(which) {
	  // onChange fires only when focus leaves, so use onFocus
	  if (which == 'none'){
	  	currentEntryField = null;
	  	theFieldName = "Error. You have not yet selected a field to enter text into.";
	  }
	  else {
	  	currentEntryField = which;
	  	theFieldName = getFieldName(which.id);
	  }
	}



function cursorInsert(field, insert) {
	/*
	// Description: a function to insert text at the cursor position in a specified field (textarea, text)
	*/

	if (insert == 'quot'){
		insert = '"';
	}
	if (field){
		//get scroll position
		var scrollPos = field.scrollTop;
		if (field.selectionStart || field.selectionStart == '0') {
			// Firefox 1.0.7, 1.5.0.6 - tested
			var startPos = field.selectionStart;
			var endPos = field.selectionEnd;
			if (endPos < startPos)	{
	          var temp = end_selection;
	          end_selection = start_selection;
	          start_selection = temp;
			}
			var selected = field.value.substring(startPos, endPos);
			field.value = field.value.substring(0, startPos) + insert + field.value.substring(endPos, field.value.length);
			//for FF at least we can get the curser to stay after the entered letter instead of at end of field
			//see http://www.scottklarr.com/topic/425/how-to-insert-text-into-a-textarea-where-the-cursor-is/ for possible improvements to IE version
			field.focus(); 
			field.selectionEnd = endPos + insert.length;
			field.selectionStart = endPos + insert.length;
		}
		else {
			 if (document.selection) {
				//Windows IE 5+ - tested
				field.focus();
				selection = document.selection.createRange();
				selection.text = insert;
			}
			else if (window.getSelection) {
				// Mozilla 1.7, Safari 1.3 - untested
				selection = window.getSelection();
				selection.text = insert;
			}
			else if (document.getSelection) {
				// Mac IE 5.2, Opera 8, Netscape 4, iCab 2.9.8 - untested
				selection = document.getSelection();
				selection.text = insert;
			} 
			else {
				field.value += insert;
			}
			field.focus(); //this puts cursor at end
		}
		//reset scroll to right place in text box
		if (scrollPos){
			field.scrollTop = scrollPos;
		}
	}
}

/*
// Script:	searchForm.js
// Version:	0.09
// Description:
//          JavaScript functions used in the Cheshire3 EAD search/retrieve and display interface 
//          - part of Cheshire for Archives v3.x
//
// Language:  JavaScript
// Author:    John Harrison <john.harrison@liv.ac.uk>
// Date:      11 January 2011
//
// Copyright: &copy; University of Liverpool 2005-2011
//
// Version History:
// 0.01 - 03/08/2006 - JH - Search form DOM manipulation functions pasted in from previous script for easier error tracking etc.
// 0.02 - 24/10/2006 - JH - Additions for adding/removing phrase option to relation drop-down when necessary
// 0.03 - 11/12/2006 - JH - Mods for compatibility with IE7
//							- get elements by id rather than name wherever possible
//							- use innerHTML to setup radio buttons
// 0.04 - 14/12/2006 - JH - Search form state maintained in cookie. Reset function added.
// 0.05 - 25/01/2007 - JH - Muchos new stuff in anticipation of date searching
// 0.06 - 19/12/2007 - JH - Multiple indexes specified in fieldidx
// 0.07 - 26/09/2008 - JH - Bug fixed in createClause (title index not being assigned correct relations) ln 126
// 0.08 - 17/02/2009 - JH - Functions re-orders so not referenced before declared
// 0.09 - 11/01/2011 - JH - Date searching options simplified
//
*/

var indexList = new Array(
                        'cql.anywhere||dc.description||dc.title|||Keywords', 
                        'dc.title|||Titles', 
                        'dc.creator|||Creators', 
                        'dc.date|||Dates', 
                        'dc.identifier|||Ref. Number', 
                        'dc.subject|||Subjects', 
                        'bath.name|||Names', 
                        'bath.personalName|||&nbsp;&nbsp;Personal Names', 
                        'bath.corporateName|||&nbsp;&nbsp;Corporate Names', 
                        'bath.geographicName|||&nbsp;&nbsp;Geographical Names', 
                        'bath.genreForm|||Genre'
                    );
var kwRelationList = new Array(
                        'all/relevant/proxinfo|||All', 
                        'any/relevant/proxinfo|||Any'
                    );
var exactRelationList = new Array(
                        'exact/relevant/proxinfo|||Exactly'
                    );
var proxRelationList = new Array(
                        '=/relevant/proxinfo|||Phrase'
                    );
//var dateRelationList = new Array('%3C|||Before', '%3E|||After', 'within/relevant/proxinfo|||Between', 'encloses/relevant/proxinfo|||Spans...');
var dateRelationList = new Array(
						'range.overlaps/relevant/proxinfo|||Contains', 
						'%3C|||Before', 
						'%3E|||After', 
						'within/relevant/proxinfo|||Between'
				    );

//var relSelectPhraseElement = document.createElement('option');
//relSelectPhraseElement.value = '=/relevant/proxinfo';
//relSelectPhraseElement.appendChild(document.createTextNode('Phrase'));


function updateSelects(current){
	var idxSelect = document.getElementById('fieldidx' + current)
	var relSelect = document.getElementById('fieldrel' + current)
	if  (!idxSelect || !relSelect || !idxSelect.options || !relSelect.options) {
		return
	}
	relSelect.options[relSelect.selectedIndex].selected = false;
	var iSelIdx = idxSelect.selectedIndex;
	if(idxSelect.options[iSelIdx].value == 'dc.identifier'){
		var rSelIdx = 2;
	} else {
		var rSelIdx = 0;
	}
	// complex conditional to decide available relations
	var relationList = new Array()
	if (iSelIdx != 3) { var relationList = kwRelationList; }
	if (iSelIdx > 0) { var relationList = relationList.concat(exactRelationList); }
	if (iSelIdx < 2) { var relationList = relationList.concat(proxRelationList); }
	if (iSelIdx == 3) {
		//var rSelIdx = 4;
		var relationList = dateRelationList; 
	}
	// now replace existing relation select element
	relSelect.parentNode.insertBefore(createSelect('fieldrel' + current, relationList, rSelIdx), relSelect);
	relSelect.parentNode.removeChild(relSelect);

}

function addSearchClause(current, boolIdx, clauseState){
  if ( !document.getElementById || !document.createElement ) {
 	return
  }
  //var form = document.getElementsByName('searchform')[0]
  var insertHere = document.getElementById('addClauseP');
  if (current > 0) {
	  newBool = createBoolean(current, boolIdx)
	  insertHere.parentNode.insertBefore(newBool, insertHere);
	  //form.insertBefore(boolOp, form.childNodes[insertBeforePosn])
  }
  current++
  newClause = createClause(current, clauseState)
  insertHere.parentNode.insertBefore(newClause, insertHere);
  //form.insertBefore(clause, form.childNodes[insertBeforePosn+1])
  document.getElementById('addClauseLink').href = 'javascript:addSearchClause(' + current + ');';
}

function createBoolean(current, selIdx){
	/* radio buttons cannot be created by DOM for IE - use innerHTML instead */
	if (!selIdx) {var selIdx = 0;}
	var pElem = document.createElement('p');
	pElem.setAttribute('id', 'boolOp' + current);
	pElem.setAttribute('class', 'boolOp');
	var boolList = new Array('and/relevant/proxinfo', 'or/relevant/proxinfo', 'not');
	var inputs = new Array();
	for (var i=0;i<boolList.length;i++) {
		var val = new String(boolList[i]);
		if (val.indexOf('/') > 0) {
			var shortName = val.substring(0, val.indexOf('/'));
		} else {
			var shortName = val;
		}
		inputs[i] = '<input type="radio" name="fieldbool' + current + '" value="' + val + '" id="fieldbool' + current + '-' + shortName + '"';
		if (i == selIdx) {
			inputs[i] += ' checked="checked"'
		}
		inputs[i] += '/><label for="fieldbool' + current + '-' + shortName + '">' + shortName.toUpperCase() + '&nbsp;&nbsp;</label>';
	}
  	pElem.innerHTML = inputs.join('\n');
	return pElem
}

function createSelect(name, optionList, selIdx){
	// set 1st option as selected by default
	if (!selIdx) {var selIdx = 0;}
	var selectElem = document.createElement('select')
	selectElem.id = name;
  	selectElem.name = name;
	for (var i=0; i < optionList.length; i++){
		var optionData = optionList[i].split('|||')
		var optionElem = document.createElement('option')
		optionElem.value = optionData[0];
		optionElem.innerHTML = optionData[1];
		
		if (i == selIdx) {optionElem.selected = 'selected'}
		selectElem.appendChild(optionElem)
	}
	return selectElem
}

function createClause(current, clauseState){
	if (!clauseState) {var clauseState = '0,0,';}
	var parts = clauseState.split(',');
	var pElem = document.createElement('div')
	pElem.setAttribute('id', 'searchClause' + current);
	pElem.setAttribute('class', 'row searchClause')
	// index select
	var iSelIdx = parts.shift();
	var idxSelect = createSelect('fieldidx' + current, indexList, iSelIdx)
	idxSelect.onchange = new Function('updateSelects(' + current + ');')
	pElem.appendChild(idxSelect)
	pElem.appendChild(document.createTextNode(' for '))
	// relation select
	var rSelIdx = parts.shift();
	// complex conditional to decide available relations
	var relationList = new Array()
	if (iSelIdx != 3) { var relationList = kwRelationList; }
	if (iSelIdx > 0) { var relationList = relationList.concat(exactRelationList); }
	if (iSelIdx < 2) { var relationList = relationList.concat(proxRelationList); }
	if (iSelIdx == 3) {
		var relationList = dateRelationList; 
	}
	pElem.appendChild(createSelect('fieldrel' + current, relationList, rSelIdx));
	// text input
	var inputElem = document.createElement('input');
	inputElem.name = 'fieldcont' + current;
	inputElem.id = 'fieldcont' + current;
	inputElem.type = 'text';
	inputElem.size = 35;
	// last entered value
	inputElem.value = parts.join(',');
	pElem.appendChild(inputElem);
	return pElem;
}

function removeClause(current) {
	var pElem = document.getElementById('boolOp' + (current-1));
	if (pElem) {
		pElem.parentNode.removeChild(pElem);
	}
	var pElem = document.getElementById('searchClause' + current);
	pElem.parentNode.removeChild(pElem);
	document.getElementById('addClauseLink').href = 'javascript:addSearchClause(' + current + ');';
}

function resetForm(formid) {
	if (typeof formid == "undefined") {
    		formid = "searchform";
  	}
	var i = 1;
	while (document.getElementById('searchClause' + i)) {
		removeClause(i);
		i++;
	}
	addSearchClause(0);
	document.getElementById('addClauseLink').href = 'javascript:addSearchClause(1);';
	setCookie(formid, '');
}

function formToString(form) {
	var i = 0;
	var fields = new Array();
	var bools = new Array();
	while (document.getElementById('fieldcont' + (i+1)) && document.getElementById('fieldcont' + (i+1)).value != "") {
		bools[i] = 0;
		if (i > 0) {
			var boolgrp = document.getElementsByName('fieldbool' + i);
			//while (!boolgrp[0].value) {boolgrp = boolgrp.slice(1);}
			for (var j=0;j<boolgrp.length;j++) {
				if (boolgrp[j].checked == true) {
					bools[i] = j;
				}
			}
		}
		i++;
		var idx = document.getElementById('fieldidx' + i).selectedIndex;
		var rel = document.getElementById('fieldrel' + i).selectedIndex;
		var cont = document.getElementById('fieldcont' + i).value;
		fields[i-1] = new Array(idx, rel, cont).join();
	} 
	stateString = fields.join('||') + '<CLAUSES|BOOLS>' + bools.join('||');
	return stateString;
}

function formFromString(s) {
	if (s && s.length > 0) {
		var parts = s.split('<CLAUSES|BOOLS>');
	} else {
		var parts = new Array()
	}
	if (parts.length == 2) {
		var clauseList = parts[0].split('||');
		var boolList = parts[1].split('||');
		for (var i=0;i<clauseList.length;i++) {
			addSearchClause(i, boolList[i], clauseList[i]);
		}
	} else {
		// no state - initialise empty search form
		addSearchClause(0);
	}

	return;
}

/*
// Script: template.js
// Version: 0.01
// Description: manipulating EAD templates
*/

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

/*
// Script:   visuals.js
// Version:   0.01
// Description:
//            JavaScript functions for creating visual effects on HTML pages  
//            - produced for the Archives Hub v3.0
//
// Language:  JavaScript
// Author:    John Harrison <john.harrison@liv.ac.uk>
// Date:      28/07/2008
//
// Copyright: &copy; University of Liverpool 2005-2008
//
// Version History:
// 0.01 - 28/07/2008 - JH - functions scripted
// X.xx - 12/03/2013 - JH - Replace some low-level code with jQuery
//                          (ported from Archives Hub)
*/

function fadeToWhite(element,red,green,blue) {
    
  if ($(element).fade) {
    clearTimeout($(element).fade);
  }
  $(element).css('background-color', "rgb("+red+","+green+","+blue+")")
  if (red == 255 && green == 255 && blue == 255) {
    return;
  }
  var newred = red + Math.ceil((255 - red)/10);
  var newgreen = green + Math.ceil((255 - green)/10);
  var newblue = blue + Math.ceil((255 - blue)/10);
  var repeat = function() {
    fadeToWhite($(element), newred, newgreen, newblue)
  };
  $(element).fade = setTimeout(repeat,10);
}

linkHash = new Array();
linkHash['text'] = new Array('[ show ]', '[ hide ]');
linkHash['plusMinus'] = new Array('[+]', '[-]');
linkHash['arrows'] = new Array('<img src="/icons/right.png" alt="&gt;"/>', '<img src="/icons/down.png" alt="V"/>');
linkHash['folders'] = new Array('<img src="/ead/img/folderClosed.gif" alt="[+]"/>', '<img src="/ead/img/folderOpen.gif" alt="[-]"/>');

function hideStuff() {
    $('a[class|="jstoggle"]').each(function(i, el){
        var classBits = el.className.split('-')
        var toggleStyle = classBits[classBits.length-1]
        if (toggleStyle != 'jstoggle') {
            $(el).html(linkHash[toggleStyle][0]);
        }
        var hrefParts = el.getAttribute("href").split("#");
        var divId = hrefParts.pop();
        var div = $('#' + divId)
        $(el).click(function(evt){
            $(div).slideToggle(200, function(){
                // after toggle, change link text
                if (typeof(toggleStyle) != "undefined" && toggleStyle != 'jstoggle') {
                    if (linkHash[toggleStyle].indexOf($(el).html()) == -1){
                        $(el).html(linkHash[toggleStyle][1 - linkHash[toggleStyle].indexOf($(el).text())]);
                    } else {
                        $(el).html(linkHash[toggleStyle][1 - linkHash[toggleStyle].indexOf($(el).html())]);
                    }
                }
            });
            // make sure displayed is not off bottom of screen
            if ($(div).is(":visible")) {
                $(div).parents(".column:eq(0)").animate({scrollTop: $(div).offset().top}, 500);
            }
            return false;
        });
    });
    $('div[class*="jshide"]').hide();
}
