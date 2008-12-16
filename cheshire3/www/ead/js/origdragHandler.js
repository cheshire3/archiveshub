/**
*
*  Crossbrowser Drag Handler
*  http://www.webtoolkit.info/
*
**/

var DragHandler = {


    // private property.
    _oElem : null,


    // public method. Attach drag handler to an element.
    attach : function(oElem) {
        oElem.onmousedown = DragHandler._dragBegin;

        // callbacks
        oElem.dragBegin = new Function();
        oElem.drag = new Function();
        oElem.dragEnd = new Function();

        return oElem;
    },


    // private method. Begin drag process.
    _dragBegin : function(e) {
        var oElem = DragHandler._oElem = this;
	
        if (isNaN(parseInt(oElem.style.left))) { oElem.style.left = '10px'; }
        if (isNaN(parseInt(oElem.style.top))) { oElem.style.top = '100px'; }

        var x = parseInt(oElem.style.left);
        var y = parseInt(oElem.style.top);

        e = e ? e : window.event;
        oElem.mouseX = e.clientX;
        oElem.mouseY = e.clientY;

        oElem.dragBegin(oElem, x, y);

	//original uses document. in next two lines - we need oElem so other drag 
	//scripts on page work
        oElem.onmousemove = DragHandler._drag;
        oElem.onmouseup = DragHandler._dragEnd;
        return false;
    },


    // private method. Drag (move) element.
    _drag : function(e) {
        var oElem = DragHandler._oElem;

        var x = parseInt(oElem.style.left);
        var y = parseInt(oElem.style.top);

        e = e ? e : window.event;
        oElem.style.left = x + (e.clientX - oElem.mouseX) + 'px';
        oElem.style.top = y + (e.clientY - oElem.mouseY) + 'px';

        oElem.mouseX = e.clientX;
        oElem.mouseY = e.clientY;

        oElem.drag(oElem, x, y);

        return false;
    },


    // private method. Stop drag process.
    _dragEnd : function() {
        var oElem = DragHandler._oElem;

        var x = parseInt(oElem.style.left);
        var y = parseInt(oElem.style.top);

        oElem.dragEnd(oElem, x, y);
	//original uses document. in next two lines - we need oElem so other drag 
	//scripts on page work
        oElem.onmousemove = null;
        oElem.onmouseup = null;
        DragHandler._oElem = null;
    }

}
