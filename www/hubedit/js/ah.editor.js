/*
// Program:        accesspoints.js
// Version:       0.02
// Description:
//                JavaScript functions for adding control access terms to Archives Hub editing interface.
//                - produced for the Archives Hub v3.x.
// Language:      JavaScript
// Author(s):   Catherine Smith <catherine.smith@liv.ac.uk>
//              John Harrison <john.harrison@liv.ac.uk>
// Date:          23/01/2013
// Copyright:     &copy; University of Liverpool 2013
//
// Version History:
// 0.01 - 09/01/2009 - CS - functions completed for first release of Archives
//                          Hub editing interface
// 0.02 - 23/01/2013 - JH - Improved function documentation
//                        - Ensure that 'title' is be put into the correct
//                          place in the entry, e.g. Lord should come before
//                          forename
//
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

    labelMapping['persname-non-western_name'] = 'Name';
    labelMapping['persname-non-western_dates'] = 'Dates';
    labelMapping['persname-non-western_y'] = 'Dates';
    labelMapping['persname-non-western_title'] = 'Title';
    labelMapping['persname-non-western_epithet'] = 'Epithet';
    labelMapping['persname-non-western_other'] = 'Other';
    labelMapping['persname-non-western_x'] = 'Other';
    labelMapping['persname-non-western_source'] = 'Source';

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


var beforeForenameTitles = new Array("Sir", "Lady", "Lord", "Dame");

// Add insert functionality to Arrays
Array.prototype.insert = function (idx, item) {
  this.splice(idx, 0, item);
};


function addField(s){
    /* Add the selected field to the access point
     *
     * s is the name of the access point ie. persname
     */
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
        cell2.innerHTML = '<input type="text" onfocus="parent.setCurrent(this);" name="' + value + '" id="' + value + '" size="35" value="family"></input>';
    }
    else {
        cell2.innerHTML = '<input type="text" onfocus="parent.setCurrent(this);" name="' + value + '" id="' + value + '" size="35"></input>';
    }
    cell3.innerHTML = '<img src="/images/editor/delete.png" class="deletelogo" onmouseover="this.src=\'/images/editor/delete-hover.png\';" onmouseout="this.src=\'/images/editor/delete.png\';" onclick="deleteRow(this.parentNode.parentNode);" />';
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


function resetAccessPoint(s){
    /* Resets the access point back to its original appearance deleting any content
     *
     * s is the name of the access point ie. persname
     */
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
  /* Add a language to lang_list
   *
   * Only if for both lang_code and lang_name are given
   */
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
  // Try to re-check
  try {
    findRequiredFields();
  } catch(err) {
    // Do nothing
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
            cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + value[0] + '" value="' + value[1] + '" size="35"></input>';
            newRow.appendChild(cell1);
            newRow.appendChild(cell2);

            var cell3 = document.createElement('td');
            cell3.innerHTML = '<img src="/images/editor/delete.png" class="deletelogo" onmouseover="this.src=\'/images/editor/delete-hover.png\';" onmouseout="this.src=\'/images/editor/delete.png\';" onclick="deleteRow(this.parentNode.parentNode);" />';
            newRow.appendChild(cell3);
              table.insertBefore(newRow, dropdownRow);

          }
      }
    // Delete the access point you are now editing
     deleteAccessPoint(s + number);

}


function editAccessPoint(s, number){
    /* Repopulate the access point with the details from the given entry so they
     * can be edited, s is either the name of the access point or the name of the
     * access point followed by '_formgen' which is used to maintain distinct ids
     * between access points read in from existing xml and those created in the
     * current form, number is the number which forms part of the unique id
     */
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
        // Check to see if the existing access point has either rules or source
        // - one is required - files being edited may not have one
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
        // Find all the values in the access point
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
                        cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + value[0] + '" value="' + value[1] + '" size="35"></input>';
                        newRow.appendChild(cell1);
                        newRow.appendChild(cell2);
                        if (value[0].split('_', 2)[1] == 'source'){
                            newRow.setAttribute('NoDrag', 'True');
                            newRow.setAttribute('NoDrop', 'True');
                            table.replaceChild(newRow, rows[2]);
                        }
                        else {
                            var cell3 = document.createElement('td');
                            cell3.innerHTML = '<img src="/images/editor/delete.png" class="deletelogo" onmouseover="this.src=\'/images/editor/delete-hover.png\';" onmouseout="this.src=\'/images/editor/delete.png\';" onclick="deleteRow(this.parentNode.parentNode);" />';
                            newRow.appendChild(cell3);
                            table.insertBefore(newRow, dropdownRow);
                        }
                    }

                }
            }
            else {
                // Fill in the lead for the access point
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
                        cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + value[0] + '" value="' + value[1] + '" size="35"></input>';
                        newRow.appendChild(cell1);
                        newRow.appendChild(cell2);
                        if (value[0].split('_', 2)[1] == 'source'){
                            newRow.setAttribute('NoDrag', 'True');
                            newRow.setAttribute('NoDrop', 'True');
                            table.replaceChild(newRow, rows[1]);
                        }
                        else {
                            var cell3 = document.createElement('td');
                            cell3.innerHTML = '<img src="/images/editor/delete.png" class="deletelogo" onmouseover="this.src=\'/images/editor/delete-hover.png\';" onmouseout="this.src=\'/images/editor/delete.png\';" onclick="deleteRow(this.parentNode.parentNode);" />';
                            newRow.appendChild(cell3);
                            table.insertBefore(newRow, dropdownRow);
                        }
                      }
                }

            }

        }
        // If the current access point does not have rules or source specified
        // then add an empty source box in row 2
        if (!hasSource && !hasRules && type != 'language'){
            var newRow = document.createElement('tr');
            var cell1 = document.createElement('td');
            var cell2 = document.createElement('td');
            cell1.innerHTML = '<td class="label">' + labelMapping[type+'_source'] + ': </td>';
            cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + type + '_source" size="35"></input>';
            newRow.appendChild(cell1);
            newRow.appendChild(cell2);
            newRow.setAttribute('NoDrag', 'True');
            newRow.setAttribute('NoDrop', 'True');
            if (type == "persname") {
                table.replaceChild(newRow, rows[2]);
            } else {
                table.replaceChild(newRow, rows[1]);
            }
        }
        // Delete the access point you are now editing
        deleteAccessPoint(s + number);

         // Initiate drag and drop reordering of cells
        if (type != 'language' && type != 'genreform' && type != 'function'){
            var tableDnD = new TableDnD();
            tableDnD.init($('table_' + type));
        }
    }
}


function deleteAccessPoint(d){
    /* Deletes element with given id */
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



/* Counter initialised for use in addAccessPoint() function*/
var nameCount = 0;


function addAccessPoint(s){
    /* Adds personal name to the 'addedpersnames' div etc.
     *
     * These values in these arrays must have a value - if there are more than
     * one at least one of them must be present not all of them
     */
    if (s == 'persname'){
        var reqfields = new Array("persname_surname", "persname_forename");
    }
    else if (s == 'persname-non-western'){
      var reqfields = new Array("persname-non-western_name");
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
      // Change this to for loop to allow multiple required fields to be set
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

    /* Add to DOM */
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


function buildAccessPoint(s){
    /* Build the xml and strings needed for the access point */
    if (s == 'subject'){
        buildSubject(s);
    }
    else {
        var tableDiv = ($(s + 'table'));
        /* Retreive all values from section of form and reset form values*/
        var valueString = '';
        var textString = '';
        var table = tableDiv.getElementsByTagName('tbody')[0];
        var rows = table.getElementsByTagName('tr');
        var length;
        if (s == 'language' || s == 'genreform' || s == 'function'){
            length = rows.length;
        }
        else {
            length = rows.length - 1
        }
        valueList = new Array();
        displayList = new Array();
        for (var i = 0; i < length; i++){
            textbox = rows[i].getElementsByTagName('input')[0]
            if (textbox.value != ""){
                if (textbox.id.split('_', 2)[1] == 'source'){
                    valueList.push(textbox.id + ' | ' + textbox.value);
                } else if (s == "persname" && textbox.id.split('_', 2)[1] == 'title' && beforeForenameTitles.indexOf(textbox.value) > -1) {
                    valueList.insert(1, textbox.id + ' | ' + textbox.value);
                    displayList.insert(1, textbox.value);
                } else {
                    valueList.push(textbox.id + ' | ' + textbox.value);
                    displayList.push(textbox.value);
                }
            }
        }
        valueString = valueList.join(' ||| ') + ' ||| ';
        textString = displayList.join(' ');
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

   /* The delete icon */
   var d = "'" + s + nameCount + "'";
   var s = "'" + s + "'";
   innerHTMLString = '<a onclick ="deleteAccessPoint(' + d + ');" title="delete entry"><img src="/images/editor/delete.png" class="deletelogo" onmouseover="this.src=\'/images/editor/delete-hover.png\';" onmouseout="this.src=\'/images/editor/delete.png\';" id="delete' + nameCount + '"/></a>';

   icondiv.innerHTML = innerHTMLString;
   return icondiv
}


function checkRules(s){
    /* Chack that either source or rules completed, but not both.
     *
     * Function to make sure only source OR rules can be completed for an
     * access point called when a rule is selected from the drop-down box and
     * deletes the source box if present or puts it back if no rule is selected.
     */
    var rules = ($(s + '_rules'));
    var tableDiv = ($(s + 'table'))
    if (tableDiv == null){
        tableDiv = ($(s.substring(0, s.indexOf('_formgen')) + 'table'));
      }
    var table = tableDiv.getElementsByTagName('tbody')[0];
    var rows = table.getElementsByTagName('tr');
    // Get dropdown row so we can insert before that
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
        cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + s + '_source" size="35"></input>';
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
        cell2.innerHTML = '<input type="text" onfocus="setCurrent(this);" id="' + s + '_source" size="35"></input>';
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


function deleteRow(tr){
    /* Delete the given row from the accesspoint */
    var table = tr.parentNode;
    table.removeChild(tr);
}



/*
// Script:       collapsibleLists.js
// Version:       0.03
// Description:
//            JavaScript functions used in the Cheshire3 EAD search/retrieve and display interface
//            - part of Cheshire for Archives v3.x
//
// Language:      JavaScript
// Authors:     John Harrison <john.harrison@liv.ac.uk>
//                Catherine Smith <catherine.smith@liv.ac.uk>
// Date:          2 June 2011
//
// Copyright: &copy; University of Liverpool 2005-2011
//
// Version History:
// 0.01 - 03/08/2006 - JH - Nested list manipulation functions pasted in from previous script for easier error tracking etc.
// 0.02 - 11/01/2008 - CS - Code adapted to allow list to begin collapsed or uncollapsed (collapseList boolean) and to allow
//                            for either each level to be controlled to that only one folder from it can be open at a time or not
//                            (controlLevels boolean)
//                          - Function names changed to be more generic (necessary changes made in eadAdminHandler.py, htmlFragments.py and eadEditingHandler
// 0.03 - 02/06/2011 - JH - Updates for hub rebrand ported from hub/js
*/

/* Note: list must be well formed, all tags closed,
// all sublists must be contained within a list item,
// NOT a direct descendent of parent list.
*/

var expandedLists = [];
var listCount = 0;

/* customisable display of icons in collapsible lists */
/* file explorer style */
var collapsedUrl = '/images/search/folderClosed.png';
var expandedUrl = '/images/search/folderOpen.png';
var itemUrl = '/images/search/barT.png'
var lastItemUrl = '/images/search/barLast.png'


function createTreeFromList(listId, treeState, collapseList, controlLevels) {

      /* args:
         listId -> str - id attr of list to collapse
         treeState -> str - string representation of state of list
         collapseChildren -> bool - collapse the tree? if this is false controlLevels must also be false (is reset here just in case)
         controlLevels -> bool - control Levels so that only one folder at each level can be open at any time
      */
      if( !document.getElementById || !document.getElementsByTagName || !document.childNodes || !document.createElement ) {
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
     try {
         var tocLevels = treeState.split(':');
    } catch (err) {
        var tocLevels = new Array();
    }
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
                // create a link for expanding/collapsing
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
                    countElem.setAttribute( 'class', 'subcount');
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
      if( !document.getElementById ) {
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

/**
*
* Simple Context Menu
* http://www.webtoolkit.info/
*
*
*
**/

/*
// Script:       contextmenu.js
// Version:       0.01
// Description:
//            JavaScript functions used in the Cheshire3 EAD search/retrieve and display interface
//            - part of Cheshire for Archives v3.x
// Origin:         http://www,webtoolkit.info
// Language:      JavaScript
// Authors:     http://www.webtoolkit.info
//                Catherine Smith <catherine.smith@liv.ac.uk>
// Date:          20 January 2009
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
// Script:    cookies.js
// Version:    0.02
// Description:
//          JavaScript functions used in the Cheshire3 EAD search/retrieve and display interface
//          - part of Cheshire for Archives v3.x
//
// Language:  JavaScript
// Author:    John Harrison <john.harrison@liv.ac.uk>
// Date:      22 April 2009
//
// Copyright: &copy; University of Liverpool 2008-2009
//
// Version History:
// 0.01 - ??/??/2008 - JH - Functions ported from Spokes Software
// 0.02 - 22/04/2009 - JH - deleteCookie function added
//
*/

function deleteCookie(name) {
    if (!name) {return false;}
    setCookie(name, "", -1);
}

function setCookie(name, val, expires, path, domain, secure) {
    if (!name) {return false;}
    // nullify any existing cookie crumb with this name
    var cookieList = document.cookie.split(';');
    var newCookieList = new Array()
    for (var x = 0; x < cookieList.length; x++) {
        var cookie = cookieList[x]
        while(cookie.charAt(0) == ' '){cookie = cookie.substr(1, cookie.length)}
        crumbs = cookie.split('=');
        if( crumbs[0] != escape(name) && crumbs[0] != name) {
            newCookieList.push(cookie);
        }
    }
    var cookie = newCookieList.join(';');
    var now = new Date();
    now.setTime(now.getTime());
    if (typeof expires == "undefined") {
        expires = 0;
    } else {
        expires = expires * 1000; //expiry time comes in seconds (like mod_python), not milliseconds
    }
    var expires_date = new Date(now.getTime() + (expires));
    if (typeof path == "undefined") {
        path='/'
    }

    // add specified crumb to cookie
    document.cookie = escape(name) + "=" + escape(val) +
                      ( ( expires ) ? ";expires=" + expires_date.toGMTString() : "" ) +
                      ( ( path ) ? ';path=' + path : "" ) +
                      ( ( domain ) ? ";domain=" + domain : "" ) +
                      ( ( secure ) ? ";secure" : "" ) +
                      ';' + cookie;
}

function getCookie(name) {
    var cookieList = document.cookie.split(';');
    for (var x = 0; x < cookieList.length; x++) {
        var cookie = cookieList[x]
        while(cookie.charAt(0) == ' '){cookie = cookie.substr(1, cookie.length)}
        crumbs = cookie.split('=');
        if( crumbs[0] == escape(name) || crumbs[0] == name) {
          return unescape(crumbs[1]);
        }
    }
    return null;
}
/*
// Program:        form.js
// Version:       0.08
// Description:
//                JavaScript functions for the editing form in the Archives Hub editing interface.
//                - produced for the Archives Hub v3.x.
// Language:      JavaScript
// Author(s):   Catherine Smith <catherine.smith@liv.ac.uk>
//              John Harrison <john.harrison@liv.ac.uk>
// Date:          25/01/2013
// Copyright:     &copy; University of Liverpool 2006 - 2013
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
    $('editinst').select('select[name="docstore"]').each(function(sel, idx){
        console.log('here');
        sel.setValue(list[3])
    });
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

var NOT_ALL_REQUIRED_DATA_MESSAGE = 'the following fields must be entered before proceeding:\n - Reference Code \n - Title';
var CREATOR_TYPE_NOT_SELECTED = 'You must select the type of each Creator entered';
var NORMALIZED_DATE_ERROR_MESSAGE = 'Please fix the error in the normalised date before saving. This field can only contain numbers and the character /.';
var NOT_VALID_XML_MESSAGE = 'Please fix the errors in the xml before saving. Errors will be marked with red shading in the text box.';


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
        var ok = confirmOp('WARNING: This operation will DELETE THE ENTIRE DESCRIPTION ' + recid.substring(0, recid.lastIndexOf('-')) + ' from the EAD Editor.\n\n* If you have never submitted this description to the Archives Hub, it will not be retrievable.\n* Any changes made since you last submitted this description to the Archives Hub will be irretrievably lost.\n\nAre you sure you want to PERMANENTLY DELETE THIS DESCRIPTION?')
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
    if (!checkValidDescription()){
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
    invalid = $$('.invalid');
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
    body.className = 'splitscreen waiting';
    background('content');

    //validate and check id existence etc.
    if (!checkRequiredData()){
        alert (NOT_ALL_REQUIRED_DATA_MESSAGE);
        body.className = 'splitscreen';
        foreground('content');
        return;
    }

    if (!checkValidDescription()) {
        body.className = 'splitscreen';
        foreground('content');
        return;
    }

    var values = checkEditStore();
    if (values[0] == 'error'){
        alert('A problem occurred when trying to perform this operation. Please contact the hub team..');
        body.className = 'splitscreen';
        foreground('content');
        return;
    }
    if (values[0]){
        if (values[1] == 'user'){
            var confirmbox = confirm('A file with this Reference code is already in the process of being created or edited. If you proceed with this operation the existing file will be overwritten with this one.\n\nAre you sure you want to continue with this operation?');
             if (confirmbox == false){
                   body.className = 'splitscreen';
                   foreground('content');
                   return;
               }
           }
           else if (values[1] == 'other'){
            var confirmbox = confirm('A file with this Reference code is already in the process of being created or edited by another user.\n\nAre you sure you want to continue with this operation?');
             if (confirmbox == false){
                   body.className = 'splitscreen';
                   foreground('content');
                   return;
               }
           }
    }

    //check the daoform details
    var daodetails = checkDao();
    if (daodetails[0] == true){
         var confirmbox = confirm('At least one of File URI values required for the digital object has not been completed. If you proceed with this operation any incomplete URIs will not be included and the title and/or description information relating to the missing URI will be lost. All other content will be saved.\n\nDo you want to continue?');
         if (confirmbox == false){
             body.className = 'splitscreen';
             foreground('content');
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
    if (saveForm(false)) {
        alert('This form is now saved as ' + recid + ' and can be reloaded from the admin menu for further editing at a later date.');
    } else {
        alert('Record could not be saved due to server error.');
    }
    body.className = 'splitscreen';
    foreground('content');
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
                alert (NOT_ALL_REQUIRED_DATA_MESSAGE);
                return;
            }
            if (!checkValidDescription()){
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
    body.className = 'splitscreen waiting';
    // check it does not exceed the c12 limit
    if (currentForm != 'collectionLevel'){
         var parent = document.getElementById(currentForm);
          var listItem = parent.parentNode;
          var level = Number(listItem.parentNode.getAttribute('name'));
          if (level == 12){
              alert('You cannot add any more component levels to this description');
              body.className = 'splitscreen';
              return;
          }
    }

    //validate and check id existence etc.
    if (!checkRequiredData()){
        alert (NOT_ALL_REQUIRED_DATA_MESSAGE)
        body.className = 'none';
        return;
    }
    if (!checkValidDescription()){
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
        alert (NOT_ALL_REQUIRED_DATA_MESSAGE);
        return;
    }
    if (!checkValidDescription()){
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
        alert (NOT_ALL_REQUIRED_DATA_MESSAGE);
        return;
    }
    if (!checkValidDescription()){
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
        alert (NOT_ALL_REQUIRED_DATA_MESSAGE);
        return;
    }
    if (!checkValidDescription()){
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
        alert (NOT_ALL_REQUIRED_DATA_MESSAGE);
        return;
    }
    if (!checkValidDescription()){
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
        alert (NOT_ALL_REQUIRED_DATA_MESSAGE)
        return;
    }
    if (!checkValidDescription()){
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
        if (typeof donor.name !== 'undefined'){
            clone.name = donor.name.replace(positionRegex, '[' + clonePos + ']');
        }
        if (donor.nodeName.toLowerCase() == 'option'){
            // clone value too
            clone.value = donor.value.replace(positionRegex, '[' + clonePos + ']');
        }

    } else {
        // Add position predicate to donor and child
        clone.id = donorid + '[2]';
        donor.id = donorid + '[1]';
        if (typeof donor.name !== 'undefined'){
            clone.name = donor.name + '[2]';
            donor.name = donor.name + '[1]';
        }
        if (donor.nodeName.toLowerCase() == 'option'){
            // clone value too
            clone.value =  donor.value + '[2]';
            donor.value = donor.value + '[1]';
        }
    }
    // clear the value
    if (donor.nodeName.toLowerCase() != 'option'){
        try {
            $(clone).setValue('');
        } catch(err) {
            // Not a form element
            $(clone).writeAttribute({
                value: null
            });
        }
    }
    // Remove any disabled attributes
    $(clone).writeAttribute({
        disabled: false,
        readOnly: false
    });
    // Remove any validation errors, or mandatory field markers from clone
    $(clone).removeClassName('menuFieldError');
    $(clone).setStyle({'border-color': 'white'});

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


function initCreatorSelect(){
    /*
     * Function to call onload to activate creator type selection
     */
     $$('.originationType').each(function(item){
        item.observe('change', function(){
            $(event.target).next().name = $(event.target).value;
            validateField($(event.target).next(), 'true');
        });
     });
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
                    (document.getElementById('pui')).value = countryCode + repositoryCode + '-' + lowerCaseId;
                }
            }
            else {
                (document.getElementById('pui')).value = countryCode + repositoryCode + '-' + lowerCaseId;
            }
        }
    }
}


//================================================================================================
// validation related functions


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

    if (field.name.match(/did\/origination/g)){
        // Check for selection of creator type
        if (field.value && !field.name.match(/persname|famname|corpname/)){
            // No creator type selected - bypass sending to server
            var attrs = {
                'class': 'menuFieldError',
                'title': "You must select a creator type"
            }
            $(field).writeAttribute(attrs).previous().writeAttribute(attrs);
            findRequiredFields();
            return;
        } else {
            // Remove any error message from select
            $(field).previous().writeAttribute({
                'class': 'menuField',
                'title': null
            });
        }

    }
    var url = 'edit.html';
    var fieldvalue = field.value.replace(/%/g, '%25').replace(/&/g, '%26').replace(/#/g, '%23').replace(/;/g, '%3B');
    var data = 'operation=validate&field=' + field.name + '&text=' + fieldvalue;
    function success(transport)    {
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
    var data = field.value;
    var valid = true;
    for (var i=0; i<data.strip().length; i++){
        if (data.charAt(i) != '/' && data.charAt(i) != '-' && isNaN(parseInt(data.charAt(i)))){
            valid = false;
        }
    }
    if (data.length % 2){
        // Odd length - logically must be a range
        if (data.charAt(data.length / 2) != '/'){
            valid = false;
            field.title = "Ranges must be symmetrical and separated by a solidus (/)'";
        }
    }
    if (valid == false){
        field.className = 'dateError';
    }
    else {
        field.className = 'dateOK';
    }
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

    // All checks passed
    return true;
}

function checkValidDescription() {

    // Check basic required data
    if (!checkRequiredData()){
        alert(NOT_ALL_REQUIRED_DATA_MESSAGE);
        return false
    }

    if (currentEntryField != null && currentEntryField.value != ''){
        validateField(currentEntryField, false)
    }

    // Creator (<origination>)
    //validateField(Prototype.Selector.find($$("input[name*='did/origination[']"), "input[value='']"), 'true');
    var orig = Prototype.Selector.find($$("input[name*='did/origination[']"), ":not(input[name*='/persname']):not(input[name*='/famname']):not(input[name*='/corpname']):not(input[value=''])");
    if (orig){
        alert(CREATOR_TYPE_NOT_SELECTED);
        return false;
    }


    // Normalized Date
    $$("input[name^='did/unitdate'][name$='@normal']").each(function(el, idx){
        validateNormdate(el, false)
    });

    var errors = $$('.dateError');
    if (errors.length != 0){
        alert(NORMALIZED_DATE_ERROR_MESSAGE);
        return false;
    }

    var errors = $$('.menuFieldError');
    if (errors.length != 0){
        alert(NOT_VALID_XML_MESSAGE);
        return false;
    }

    // All checks passed
    return true;
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
//      keyboard.toggle();
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
        if (endPos < startPos)    {
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

/*
// Program:   hub.js
// Version:   0.02
// Description:
//            JavaScript functions used in the Archives Hub v3 search/retrieve and display interface
//
// Language:  JavaScript
// Author:    John Harrison <john.harrison@liv.ac.uk>
// Date:      02/06/2011
//
// Copyright: &copy; University of Liverpool 2005-2011
//
// Version History:
// 0.01 - 28/07/2008 - JH - Forked from Cheshire3 for Archives ead.js v0.08
// 0.02 - 02/06/2011 - JH - Update with ports from Cheshire for Archives ead.js v0.10
//
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

/* Deactivate certain links in record preview */
function disableLinksByClass() {
    var linkList = document.getElementsByTagName("a");
    for (var i = 0; i < linkList.length; i++) {
        var el = linkList[i]
        if (el.className.match('disabled')){
            el.onclick = function() {
                window.alert("This feature is not available in preview mode.");
                return false;
            }
        }
    }
}

addLoadEvent(disableLinksByClass);

/*
// Program:        keyboard.js
// Version:       0.02
// Description:
//                JavaScript functions for input of special characters into the ead template.
//                - produced for the Archives Hub v3.x.
// Language:      JavaScript
// Author(s):   John Harrison <john.harrison@liv.ac.uk>
//                Catherine Smith <catherine.smith@liv.ac.uk>
// Date:          09/01/2009
// Copyright:     &copy; University of Liverpool 2005-2009
//
// Version History:
// 0.01 - 08/08/2006 - JH - basic functions completed for original ead2002 template
// 0.02 - 09/01/2009 - CS - Addition of code to maintain current scroll position in text area after adding character
//                            field codes changes to represent new ead editing interface
*/



var    currentEntryField = null;
var    theFieldName = "Error. You have not yet selected a field to enter text into.";

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
            if (endPos < startPos)    {
              var temp = end_selection;
              end_selection = start_selection;
              start_selection = temp;
            }
            var selected = field.value.substring(startPos, endPos);
            field.value = field.value.substring(0, startPos) + insert + field.value.substring(endPos, field.value.length);
            //for FF at least we can get the curser to stay after the entered letter instead of at end of field
            //see http://www.scottklarr.com/topic/425/how-to-insert-text-into-a-textarea-where-the-cursor-is/ for possible improvements to IE version
            field.focus();
            field.selectionEnd = endPos + 1;
            field.selectionStart = endPos + 1;
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
        alert('This template is now saved as ' + template.substring(0, template.lastIndexOf('-')) + ' and can be used as the basis for creating records. It can also be loaded back into this interface and edited if required.');
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
// Program:   visuals.js
// Version:   0.03
// Description:
//            JavaScript functions for creating visual effects on HTML pages
//            - produced for the Archives Hub v3.0
//
// Language:  JavaScript
// Author:    John Harrison <john.harrison@liv.ac.uk>
// Date:      08/02/2012
//
// Copyright: &copy; University of Liverpool 2005-2012
//
// Version History:
// 0.01 - 28/07/2008 - JH - functions scripted
// 0.02 - 12/03/2010 - JH - updates for Hub rebrand
// 0.03 - 08/02/2012 - JH - Replace some low-level code with jQuery
//                          (jQuery already in use by the new style Hub)
*/

function fadeToWhite(element,red,green,blue) {
  if (element.fade) {
    clearTimeout(element.fade);
  }
  element.style.backgroundColor = "rgb("+red+","+green+","+blue+")";
  if (red == 255 && green == 255 && blue == 255) {
    return;
  }
  var newred = red + Math.ceil((255 - red)/10);
  var newgreen = green + Math.ceil((255 - green)/10);
  var newblue = blue + Math.ceil((255 - blue)/10);
  var repeat = function() {
    fadeToWhite(element,newred,newgreen,newblue)
  };
  element.fade = setTimeout(repeat,10);
}

linkHash = new Array();
linkHash['text'] = new Array('[ show ]', '[ hide ]');
linkHash['plusMinus'] = new Array('[+]', '[-]');
linkHash['arrows'] = new Array('<img src="/icons/right.png" alt="&gt;"/>', '<img src="/icons/down.png" alt="V"/>');
linkHash['folders'] = new Array('<img src="/images/search/folderClosed.png" alt="[+]"/>', '<img src="/images/search/folderOpen.png" alt="[-]"/>');


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
            $(div).slideToggle(500, function(){
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

function blankout(id, splash) {
    if (typeof id == 'undefined'){
        id = 'content';
    }
    $(id).setOpacity(0.25);
    if (typeof splash == 'undefined'){
        splash = 'loadSplash';
    }
    try {
        $(splash).show();
    } catch(e) {}
}

function background(id, splash){
    blankout(id, splash);
}

function foreground(id, splash){
    if (typeof id == 'undefined'){
        id = 'content';
    }
    if (typeof splash == 'undefined'){
        splash = 'loadSplash';
    }
    try {
        $(splash).hide();
    } catch(e) {}

    $(id).setOpacity(1.0);
}


