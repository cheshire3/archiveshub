/*
// Script:	cookies.js
// Version:	0.02
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
