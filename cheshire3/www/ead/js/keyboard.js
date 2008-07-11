/*
// keyboard.js
// Author:    John Harrison <john.harrison@liv.ac.uk>
// Date:      08 August 2006
// Copyright &copy; University of Liverpool 2006
// 
*/


var defaultsetting = "100%, *"
	characterframe = null;
	currentEntryField = null;
	theFieldName = "Error. You have not yet selected a field to enter text into.";

	fieldcodes = new Array("rep", "caa-rc", "caa-id", "cab", "cac", "can", "cae", "cba", "cbb", "cbc", "cbd", "cca", "ccb", "ccc", "ccd", "cda", "cdb", "lang_name", "cdd", "cde", "cea", "ceb", "cec", "ced", "cfa", "cga", "pn_surname", "pn_forename", "pn_dates", "pn_title", "pn_epithet", "pn_other", "pn_source", "fn_surname", "fn_other", "fn_dates", "fn_title", "fn_epithet", "fn_loc", "fn_source", "cn_name", "cn_dates", "cn_loc", "cn_other", "cn_source", "su_subject", "su_dates", "su_loc", "su_other", "su_source", "gn_geogname", "gn_dates", "gn_source", "bt_title", "bt_dates", "bt_source")

	fieldnames = new Array("Repository", "Reference Code", "Reference Code", "Title", "Dates of Creation", "Normalised Date - This should NOT contain character entities", "Extent of Unit Description", "Name of Creator", "Administrative/Biographical History", "Archival History", "Immediate Source of Acquisition", "Scope and Content", "Appraisal", "Accruals", "System of Arrangement", "Conditions Governing Access", "Conditions Governing Reproduction", "Language of Material - Language Name", "Physical Characteristics ", "Finding Aids", "Existence/Location of Orginals", "Existence/Location of Copies", "Related Units of Description", "Publication Note", "Note", "Archivist's Note", "Personal Name - Surname", "Personal Name - Forename", "Personal Name - Dates", "Personal Name - Title", "Personal Name - Epithet", "Personal Name - Other", "Personal Name - Source", "Family Name - Surname", "Family Name - Other", "Family Name - Dates", "Family Name - Title", "Family Name - Epithet", "Family Name - Location", "Family Name - Source", "Corporate Name - Organisation", "Corporate Name -_Dates", "Corporate Name - Location", "Corporate Name - Other", "Corporate Name - Source", "Subject - Subject", "Subject - Dates", "Subject - Location", "Subject - Other", "Subject - Thesaurus", "Place Name - Location", "Place Name - Dates", "Place Name - Source", "Book Title", "Book Title - Dates", "Book Title - Source")


	function addfield(type, tag) {
	  tag.href = "template.html"
	}

	function getCurrentSetting(){
	  if (document.body) {
	    return (document.body.rows)
	  }
	}
	

	function getFieldName(code) {
	  for (i=0;i<fieldcodes.length;i++) {
	    if (code == fieldcodes[i]) {
	      return fieldnames[i];
	      break;
	    }
	  }
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
	// Description: a function to insert text at the cursor position in a specified field (text, textarea)
	*/
	if (insert == 'quot'){
		insert = '"';
	}
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
	}
	else if (document.selection) {
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
	else field.value += insert;
	field.focus();

}
		
