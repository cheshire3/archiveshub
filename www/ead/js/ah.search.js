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
	//pElem.appendChild(document.createTextNode(' for '))
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
