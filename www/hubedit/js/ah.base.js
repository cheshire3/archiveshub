/*	Global Configuration
----------------------------------------------- */
function init() {
	document.body.className += "loading hasJS";
}

$(function() {
	Setup.init();
});

var Setup = {	
	Body: null,
	init: function() {
		var cc = this;
		cc.Body = $(document.body);
		cc.Body.addClass('domReady');
		cc.Body.removeClass('loading');
		
		// equal heights
		equalHeight($('div.grid-165-165-165-165 h3'));
		
		// panel article
		$('.panel-article p:first').addClass('first');
		
		// forms
		$(".panel-form legend").each(function(){
			$(this).replaceWith("<h3>"+$(this).text()+"</h3>");
		});
		$(".panel-form fieldset").wrapInner('<div class="wrapper cF"></div>');
		$(".panel-form fieldset div.wrapper").append('<div class="crnTl"></div><div class="crnTR"></div><div class="crnBl"></div><div class="crnBr"></div>');
		
		// Accordion
		Accordion.init();
		
		// Contributors
		Contributors.init();

		// Tool tips
		Tooltips.init();
	   
		// Form validation
		Forms.init();
		
		// Panel Search
		PanelSearch.init()
		
		// Cufon
		Cufon.replace('h1, h2, h3, #Sitewide a, #Navigation a.level-1, .ead-editor strong');
	}
};

var Forms = {
	init: function() {
		if($('#Form').length>0) {
			$("#Form").validate({
				invalidHandler: function(form, validator) {
					var errors = validator.numberOfInvalids();
			      var errors = validator.numberOfInvalids();
			      if (errors) {
			        $('#FormError').fadeIn();
			      } else {
					 	$('#FormError').hide();
					}
			   },
				submitHandler: function(form) {
					$('#FormSubmit').fadeOut('fast', function(){
						form.submit();
					});
				 },
				errorElement: "div"
			});
		}	
	}
};

var PanelSearch = {
	Count: null,
	Rows: null,
	Trigger: null,
	init: function() {
		var cc = this;
		if($('#PanelSearch').length>0) {
			
			cc.Rows = $('#PanelSearch div.row-add');
			cc.Trigger = $('#SearchAddButton');
			cc.Count = 0;
			cc.render();
			cc.events();
		};	
	},
	render: function() {
		var cc = this;
		cc.Rows.hide();
		cc.Rows.eq(0).show();

	},
	events: function() {
		var cc = this;
		cc.Trigger.bind('click',function() {
			cc.Count ++;
			if(cc.Count<cc.Rows.length) {
				cc.Rows.eq(cc.Count).fadeIn();	
			}
			if(cc.Count==cc.Rows.length-1) {
				cc.Trigger.parent().css('opacity', .3);
			}
			
			return false;
		})
	}
};

var Tooltips = {
	init: function() {
		if($('a.tip').length>0) {
			$('a[href][title]').qtip({
			     content: {
		         text: false
		      },
			position: {
			      corner: {
			         target: 'topRight',
			         tooltip: 'bottomLeft'
			      }
			   },
			tip: 'bottomLeft',
			style: { 
				border: {
				         width: 7,
				         radius: 5,
				         color: '#0baedb'
				      },
				color: '#24205c',
				fontSize: '1.2em',
				padding: '10px',
				background: '#ade0f0',
			      tip: 'bottomLeft',
			      name: 'blue'
			   }
		   });
		}	
	}
};

var Accordion = {	
	Triggers: null,
	Contents: null,
	Toggle: null,
	init: function() {
		var cc = this;
		if($('#Accordion').length>0) {
			cc.Triggers = $('#Accordion h3 a');
			cc.Contents = $('#Accordion div.content');
			cc.Toggle = $('#AccordionToggle');
			cc.events();
			cc.render();
		}
	},
	render: function() {
		var cc = this;
		cc.Contents.hide();
	},
	events: function() {
		var cc = this;
		cc.Triggers.bind('click', function() {
			if($(this).hasClass('active')) {
				$(this).parent().next().hide();
				$(this).removeClass('active');
			} else {
				$(this).parent().next().fadeIn();
				$(this).addClass('active');
			}
			
		});
		cc.Toggle.bind('click', function(){
			if($(this).hasClass('active')) {
				$(this).removeClass('active');
				cc.Triggers.removeClass('active');
				cc.Contents.hide();
			} else {
				$(this).addClass('active');
				cc.Triggers.addClass('active');
				cc.Contents.fadeIn();
			}
		});
	}
};

var Contributors = {	
	Tabs: null,
	Lists: null,
	init: function() {
		var cc = this;
		if($('#ContributorTabs').length>0) {
			cc.Tabs = $('#ContributorTabs a');
			cc.Lists = $('#ContributorList li');
			cc.events();
			cc.render();
		}
	},
	render: function() {
		var cc = this;
		cc.Lists.hide();
		$('#ContributorList li.a-e').show();
		$('#ContributorTabs a[rel=a-e]').addClass('active');
	},
	events: function() {
		var cc = this;
		cc.Tabs.bind('click', function() {
			var type = $(this).attr('rel');
			if(type=='all') {
				cc.Lists.show();
			} 
			else {
				cc.Lists.hide();
				$('#ContributorList li.'+type).show();
			}
			cc.Tabs.removeClass('active');
			$(this).addClass('active');
			return false;
		});
		$("#ContributorList li a").fancybox({
			overlayShow : true,
			overlayOpacity : 0.5,
			overlayColor : '#101010',
			ajax : {
				type : "GET",
				data : 'b=2'
			},
			frameWidth : 485,
			frameHeight : 550,
			padding : 0 
		});
		
	}
};

/*	Functions
----------------------------------------------- */
function equalHeight(group) {
	tallest = 0;
    group.each(function() {
        thisHeight = $(this).height();
        if(thisHeight > tallest) {
            tallest = thisHeight;
        }
    });
    group.height(tallest);
}