/*
// Program:   hijax.js
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
//
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
                try {
                    Cufon.replace('h1, h2, h3');
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

olf = function() { ajaxifyLinks(document); ajaxifyForms(document); };
if (addLoadEvent) {
	addLoadEvent(olf);
} else {
	window.onload = olf;
};
