/**
*
*  Crossbrowser Drag Handler
*  http://www.webtoolkit.info/
*
**/


var DragHandler = {


	// private property.
	_oElem : null,
	_lowerBound : null,
	_rightBound : null,

	// public method. Attach drag handler to an element.
	attach : function(oElem) {
		oElem.onmousedown = DragHandler._dragBegin;


		return oElem;
	},


	// private method. Begin drag process.
	_dragBegin : function(e) {

		var oElem = DragHandler._oElem = this;

	//	_lowerBound = window.innerHeight - (document.getElementById('banner').offsetHeight + document.getElementById('footer').offsetHeight + document.getElementById('keyboardcontrolbar').offsetHeight)
	//	_rightBound = window.innerWidth - document.getElementById('keyboardcontrolbar').offsetWidth
		
		if (isNaN(parseInt(oElem.style.left))) { oElem.style.left = '10px'; }
		if (isNaN(parseInt(oElem.style.top))) { oElem.style.top = '100px'; }

		var x = parseInt(oElem.style.left);
		var y = parseInt(oElem.style.top);

		e = e ? e : window.event;
		oElem.mouseX = e.clientX;
		oElem.mouseY = e.clientY;

	//	if ((oElem.mouseY - document.getElementById('banner').offsetHeight) - document.getElementById('keyboardcontrolbar').offsetHeight <= y + document.getElementById('keyboardcontrolbar').offsetHeight){
			oElem.onmousemove = DragHandler._drag;
			oElem.onmouseup = DragHandler._dragEnd;
	//	}
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
		if (y + (e.clientY - oElem.mouseY) < -2){
			oElem.style.top = '-2px';
		}
		if (y + (e.clientY - oElem.mouseY) > _lowerBound){
			oElem.style.top = _lowerBound + 'px';
		}
		if (x + (e.clientX - oElem.mouseX) < -2){
			oElem.style.left = '-2px';
		}
		if (x + (e.clientX - oElem.mouseX) > _rightBound){
			oElem.style.left = _rightBound + 'px';
		}
		
		oElem.mouseX = e.clientX;
		oElem.mouseY = e.clientY;

		return false;
	},


	// private method. Stop drag process.
	_dragEnd : function() {
		var oElem = DragHandler._oElem;

		var x = parseInt(oElem.style.left);
		var y = parseInt(oElem.style.top);
		
		oElem.onmousemove = null;
		oElem.onmouseup = null;
		DragHandler._oElem = null;
	}

}
