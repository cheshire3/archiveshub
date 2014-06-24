
var AH = {

    init: function(){
        // hide content that should be hidden
        hideStuff();
        // add validation to certain form elements
        addFormValidation();
        // Wrap any desired links or forms in AJAX requests
        //ajaxifyLinks(document);
        //ajaxifyForms(document);
        AH.searchWithin();
    },

    searchWithin: function(){
        // Make searchWithin stay within
        $("div#leftcol div.withinCollection form").submit(function(event){
            event.preventDefault();
            $(this).fadeTo(100, 0.25).find("input").disabled = true;
            // Remove any old error message
            $("#leftcol div.withinCollection").find("div.error").remove()
            // Set charset
            $(this).find("input[name='_charset_']").val('utf8');
            var postData = $(this).serializeArray();
            var formURL = this.action;
            $.ajax({
                type: "POST",
                url: formURL,
                accepts: "text/html",
                data: postData,
                dataType: "html",
                success: function(data, textStatus, jqXHR) {
                    // Check for no hits
                    if ($(data).find("#no-hits-img").length){
                        // No hits - report and re-enable form
                        $("#leftcol div.withinCollection").append($(data).find("p.hitreport"));
                        $("p.hitreport").wrap('<div class="error">');
                        $("#leftcol div.withinCollection").find("form").fadeTo(100, 1.0).find("button, input").prop("disabled", false);
                    } else {
                        // Update the leftcol
                        $("#leftcol").html($(data).find("#leftcol").html());
                    }
                },
            });
        });
    }

}

/*
// Script:      collapsibleLists.js
// Version:     0.02
// Description:
//            JavaScript functions used in the Cheshire3 EAD search/retrieve and display interface 
//            - part of Cheshire for Archives v3.x
//
// Language:    JavaScript
// Authors:     John Harrison <john.harrison@liv.ac.uk>
//              Catherine Smith <catherine.smith@liv.ac.uk>
// Date:        11 January 2008
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
//                          (controlLevels boolean)
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
var collapsedUrl = '/images/search/folderClosed.png';
var expandedUrl = '/images/search/folderOpen.png';
var itemUrl = '/images/search/folderItem.jpg';
var lastItemUrl = '/images/search/folderItem.jpg';
/* skeletal style - uncomment/comment to replace the above defaults */
//var collapsedUrl = '/images/barPlus.gif';
//var expandedUrl = '/images/barMinus.gif';
var itemUrl = '/images/search/barT.png'
var lastItemUrl = '/images/search/barLast.png'


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

    var stateStr = '';
    for (var level = 0; level < expandedLists[listId].length; level++) {
        var listObj = expandedLists[listId][level];
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



/*
// Script:   cookies.js
// Version:   0.01
// Description:
//  functions to assist cookie management
*/

function unsetCookie(name) {
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
    document.cookie = cookieList.join(';');
}

function setCookie(name, val, path) {
  if (!name) {return false;}
  // nullify any existing cookie crumb with this name
  unsetCookie(name);
  if (!val) {return false;}
  if (path==='undefined'){
      var path = '/search/';
  }
  // add specified crumb to cookie
  var cookieList = document.cookie.split(';');
  document.cookie = new Array(escape(name) + "=" + escape(val), 'path=' + path).concat(cookieList).join(';');
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
// Script:  searchForm.js
// Version: 0.09
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
                        //'dc.date|||Dates',
                        'dc.identifier|||Ref. Number', 
                        'dc.subject|||Subjects', 
                        'bath.name|||Names', 
                        'bath.personalName|||&nbsp;&nbsp;People',
                        'bath.corporateName|||&nbsp;&nbsp;Organizations',
                        'bath.geographicName|||Places',
                        'bath.genreForm|||Media Types'
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
	if (idxSelect.options[iSelIdx].value != 'dc.date') {
		var relationList = kwRelationList;
	}
	if (iSelIdx > 0) { var relationList = relationList.concat(exactRelationList); }
	if (iSelIdx < 2) { var relationList = relationList.concat(proxRelationList); }
	/* Commented because date search is currently disabled
	if (iSelIdx == 3) {
		//var rSelIdx = 4;
		var relationList = dateRelationList; 
	}
	*/
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
            /* FIXME: This is buggy
            if ($(div).is(":visible")) {
                $(div).parents(".column:eq(0)").animate({scrollTop: $(div).offset().top}, 500);
            }
            */
            return false;
        });
    });
    $('div[class*="jshide"]').hide();
}
