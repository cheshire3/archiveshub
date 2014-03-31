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
linkHash['folders'] = new Array('<img src="/img/folderClosed.gif" alt="[+]"/>', '<img src="/img/folderOpen.gif" alt="[-]"/>');


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

function blankout(id) {
    if (typeof id == 'undefined'){
        id = 'content';
    }
    $('#'+id).hide();
    $('#loadImg').show();
}
