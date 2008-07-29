/*
// Program:   ead.js
// Version:   0.08
// Description:
//            JavaScript functions used in the Cheshire3 EAD search/retrieve and display interface 
//            - part of Cheshire for Archives v3.0
//
// Language:  JavaScript
// Author:    John Harrison <john.harrison@liv.ac.uk>
// Date:      23/07/2008
//
// Copyright: &copy; University of Liverpool 2005-2008
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
//
*/ 

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

linkHash = new Array();
linkHash['text'] = new Array('[ show ]', '[ hide ]');
linkHash['plusMinus'] = new Array('[+]', '[-]');
linkHash['folders'] = new Array('<img src="/images/folderClosed.jpg" alt="[+]"/>', '<img src="/images/folderOpen.jpg" alt="[-]"/>');

function toggleShow(callLink, elementId, toggleStyle){
	if( !document.getElementById) {
		return;
	}
	if (typeof toggleStyle == "undefined") {
    	toggleStyle = "text";
  	}
	e = document.getElementById( elementId );
	if (e.style.display == 'block') {
		callLink.innerHTML = linkHash[toggleStyle][0];
		e.style.display = 'none';
	} else {
		callLink.innerHTML = linkHash[toggleStyle][1];
		e.style.display = 'block';
	}
	return;
}

function hideStuff(){
	if( !document.getElementsByTagName) {
  		return;
  	}	
  	var linkList = document.getElementsByTagName("a");
	for (var i = 0; i < linkList.length; i++) {
		var el = linkList[i]
		if (el.className.match('jstoggle')){
			var classBits = el.className.split('-')
			var toggleStyle = classBits[classBits.length-1]
			el.innerHTML = linkHash[toggleStyle][0]
			el.onclick = function() {
				var hrefParts = this.getAttribute("href").split("#")
				var div = hrefParts.pop()
				var classBits = this.className.split('-')
				var style = classBits[classBits.length-1]
				toggleShow(this, div, style);
				return false;
			}
		}
	}
	var divList = document.getElementsByTagName("div");
	for (var i = 0; i < divList.length; i++) {
		var el = divList[i]
		if (el.className.match('jshide')){
			el.style.display = 'none';
		}
	}
}

if (addLoadEvent) {
	addLoadEvent(hideStuff);
} else {
	window.onload = hideStuff;
}
