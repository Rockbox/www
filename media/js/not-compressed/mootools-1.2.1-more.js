//MooTools More, <http://mootools.net/more>. Copyright (c) 2006-2008 Valerio Proietti, <http://mad4milk.net>, MIT Style License.

// Fx.Slide, MooTools More
Fx.Slide=new Class({Extends:Fx,options:{mode:"vertical"},initialize:function(B,A){this.addEvent("complete",function(){this.open=(this.wrapper["offset"+this.layout.capitalize()]!=0);
if(this.open&&Browser.Engine.webkit419){this.element.dispose().inject(this.wrapper);}},true);this.element=this.subject=$(B);this.parent(A);var C=this.element.retrieve("wrapper");
this.wrapper=C||new Element("div",{styles:$extend(this.element.getStyles("margin","position"),{overflow:"hidden"})}).wraps(this.element);this.element.store("wrapper",this.wrapper).setStyle("margin",0);
this.now=[];this.open=true;},vertical:function(){this.margin="margin-top";this.layout="height";this.offset=this.element.offsetHeight;},horizontal:function(){this.margin="margin-left";
this.layout="width";this.offset=this.element.offsetWidth;},set:function(A){this.element.setStyle(this.margin,A[0]);this.wrapper.setStyle(this.layout,A[1]);
return this;},compute:function(E,D,C){var B=[];var A=2;A.times(function(F){B[F]=Fx.compute(E[F],D[F],C);});return B;},start:function(B,E){if(!this.check(arguments.callee,B,E)){return this;
}this[E||this.options.mode]();var D=this.element.getStyle(this.margin).toInt();var C=this.wrapper.getStyle(this.layout).toInt();var A=[[D,C],[0,this.offset]];
var G=[[D,C],[-this.offset,0]];var F;switch(B){case"in":F=A;break;case"out":F=G;break;case"toggle":F=(this.wrapper["offset"+this.layout.capitalize()]==0)?A:G;
}return this.parent(F[0],F[1]);},slideIn:function(A){return this.start("in",A);},slideOut:function(A){return this.start("out",A);},hide:function(A){this[A||this.options.mode]();
this.open=false;return this.set([-this.offset,0]);},show:function(A){this[A||this.options.mode]();this.open=true;return this.set([0,this.offset]);},toggle:function(A){return this.start("toggle",A);
}});Element.Properties.slide={set:function(B){var A=this.retrieve("slide");if(A){A.cancel();}return this.eliminate("slide").store("slide:options",$extend({link:"cancel"},B));
},get:function(A){if(A||!this.retrieve("slide")){if(A||!this.retrieve("slide:options")){this.set("slide",A);}this.store("slide",new Fx.Slide(this,this.retrieve("slide:options")));
}return this.retrieve("slide");}};Element.implement({slide:function(D,E){D=D||"toggle";var B=this.get("slide"),A;switch(D){case"hide":B.hide(E);break;case"show":B.show(E);
break;case"toggle":var C=this.retrieve("slide:flag",B.open);B[(C)?"slideOut":"slideIn"](E);this.store("slide:flag",!C);A=true;break;default:B.start(D,E);
}if(!A){this.eliminate("slide:flag");}return this;}});

// Asset, MooTools More
var Asset=new Hash({javascript:function(F,D){D=$extend({onload:$empty,document:document,check:$lambda(true)},D);var B=new Element("script",{src:F,type:"text/javascript"});
var E=D.onload.bind(B),A=D.check,G=D.document;delete D.onload;delete D.check;delete D.document;B.addEvents({load:E,readystatechange:function(){if(["loaded","complete"].contains(this.readyState)){E();
}}}).setProperties(D);if(Browser.Engine.webkit419){var C=(function(){if(!$try(A)){return ;}$clear(C);E();}).periodical(50);}return B.inject(G.head);},css:function(B,A){return new Element("link",$merge({rel:"stylesheet",media:"screen",type:"text/css",href:B},A)).inject(document.head);
},image:function(C,B){B=$merge({onload:$empty,onabort:$empty,onerror:$empty},B);var D=new Image();var A=$(D)||new Element("img");["load","abort","error"].each(function(E){var F="on"+E;
var G=B[F];delete B[F];D[F]=function(){if(!D){return ;}if(!A.parentNode){A.width=D.width;A.height=D.height;}D=D.onload=D.onabort=D.onerror=null;G.delay(1,A,A);
A.fireEvent(E,A,1);};});D.src=A.src=C;if(D&&D.complete){D.onload.delay(1);}return A.setProperties(B);},images:function(D,C){C=$merge({onComplete:$empty,onProgress:$empty},C);
if(!D.push){D=[D];}var A=[];var B=0;D.each(function(F){var E=new Asset.image(F,{onload:function(){C.onProgress.call(this,B,D.indexOf(F));B++;if(B==D.length){C.onComplete();
}}});A.push(E);});return new Elements(A);}});

/* 
 * noobSlide class
 * Author: luistar15, <leo020588 [at] gmail.com>
 * License: MIT-style license.
 */
/*
Options:
	box: dom element | required
	items: dom collection | required
	size: int | item size (px) | default: 240
	mode: string | 'horizontal', 'vertical' | default: 'horizontal'
	interval: int | for peridical | default: 5000
	buttons:{
		previous: single dom element OR dom collection| default: null
		next:  single dom element OR dom collection | default: null
		play:  single dom element OR dom collection | default: null
		playback:  single dom element OR dom collection | default: null
		stop:  single dom element OR dom collection | default: null
	}
	button_event: string | event type | default: 'click'
	handles: dom collection | default: null
	handle_event: string | event type| default: 'click'
	fxOptions: object | Fx.Style options | default: {duration:500,wait:false}
	autoPlay: boolean | default: false
	onWalk: event | pass arguments: currentItem, currentHandle | default: null
	startItem: int

Properties:
	box: dom element
	items: dom collection
	size: int
	mode: string
	interval: int
	buttons: object
	button_event: string
	handles: dom collection
	handle_event: string
	previousIndex: int
	nextIndex: int
	fx: Fx.style instance
	autoPlay: boolean
	onWalk: function
	
Methods:
	previous(manual): walk to previous item
		manual: bolean | default:false
	next(manual): walk to next item
		manual: bolean | default:false
	play (delay,direction): auto walk items
		delay: int | required
		direction: string | "previous" or "next" | required
	stop(): sopt auto walk
	walk(item,manual): walk to item
		item: int | required
		manual: bolean | default:false
	addHandleButtons(handles):
		handles: dom collection | required
	addActionButtons(action,buttons):
		action: string | "previous", "next", "play", "playback", "stop" | required
		buttons: dom collection | required

*/
var noobSlide = new Class({

	initialize: function(params){
		this.items = params.items;
		this.mode = params.mode || 'horizontal';
		this.modes = {horizontal:['left','width'], vertical:['top','height']};
		this.size = params.size || 240;
		this.box = params.box.setStyle(this.modes[this.mode][1],(this.size*this.items.length)+'px');
		this.button_event = params.button_event || 'click';
		this.handle_event = params.handle_event || 'click';
		this.interval = params.interval || 5000;
		this.buttons = {previous: [], next: [], play: [], playback: [], stop: []};
		if(params.buttons){
			for(var action in params.buttons){
				this.addActionButtons(action, $type(params.buttons[action])=='array' ? params.buttons[action] : [params.buttons[action]]);
			}
		}
		this.handles = params.handles || null;
		if(this.handles){
			this.addHandleButtons(this.handles);
		}
		this.fx = new Fx.Style(this.box,this.modes[this.mode][0],params.fxOptions||{duration:500,wait:false});
		this.onWalk = params.onWalk || null;
		this.currentIndex = params.startItem || 0;
		this.previousIndex = null;
		this.nextIndex = null;
		this.autoPlay = params.autoPlay || false;
		this._auto = null;
		this.box.setStyle(this.modes[this.mode][0],(-this.currentIndex*this.size)+'px');
		if(params.autoPlay) this.play(this.interval,'next');
	},

	previous: function(manual){
		this.currentIndex += this.currentIndex>0 ? -1 : this.items.length-1;
		this.walk(null,manual);
	},

	next: function(manual){
		this.currentIndex += this.currentIndex<this.items.length-1 ? 1 : 1-this.items.length;
		this.walk(null,manual);
	},

	play: function(delay,direction){
		this.stop();
		this[direction](false);
		this._auto = this[direction].periodical(delay,this,false);
	},

	stop: function(){
		$clear(this._auto);
	},

	walk: function(item,manual){
		if($defined(item)){
			if(item==this.currentIndex) return;
			this.currentIndex=item;
		}
		this.previousIndex = this.currentIndex + (this.currentIndex>0 ? -1 : this.items.length-1);
		this.nextIndex = this.currentIndex + (this.currentIndex<this.items.length-1 ? 1 : 1-this.items.length);
		if(manual){ this.stop(); }
		this.fx.start(-this.currentIndex*this.size);
		if(this.onWalk){ this.onWalk(this.items[this.currentIndex],(this.handles?this.handles[this.currentIndex]:null)); }
		if(manual && this.autoPlay){ this.play(this.interval); }
	},
	
	addHandleButtons: function(handles){
		for(var i=0;i<handles.length;i++){
			handles[i].addEvent(this.handle_event,this.walk.bind(this,[i,true]));
		}
	},

	addActionButtons: function(action,buttons){
		for(var i=0; i<buttons.length; i++){
			switch(action){
				case 'previous': buttons[i].addEvent(this.button_event,this.previous.bind(this,true)); break;
				case 'next': buttons[i].addEvent(this.button_event,this.next.bind(this,true)); break;
				case 'play': buttons[i].addEvent(this.button_event,this.play.bind(this,[this.interval,'next'])); break;
				case 'playback': buttons[i].addEvent(this.button_event,this.play.bind(this,[this.interval,'previous'])); break;
				case 'stop': buttons[i].addEvent(this.button_event,this.stop.bind(this)); break;
			}
			this.buttons[action].push(buttons[i]);
		}
	}
	
});

/*
 * Rockbox.org
 * rockboxPlayersList class
 * Copyright 2009 by Maciej "Macku" Adamczak <emacieka@tlen.pl>
 */
var rockboxPlayersList = new Class( {
	handleContainerId: 'players_list',
	randomManufacture: null,
	randomPlayer: null,
	randomImage: null,

	imageContainerId: 'player_image',
	imageContainer: null,
	imagesPath: 'media/images/players/',

	selectedManufacture: null,
	selectedPlayer: null,

	fx: null,
	fxComplete: true,

	initialize: function( handleContainerId, imageContainerId ) {
		this.handleContainer = $( handleContainerId || this.handleContainerId );
		this.imageContainer = $( imageContainerId || this.imageContainerId );

		// Get random manufacture, player and image
		this.setRandomManufacture();
		this.setRandomPlayer();

		// Manufatcure list
		var ulEl = new Element( 'ul', {
			'class': 'manufacture_list'
		} ).inject( this.handleContainer );

		playersList.each( function( players, manufacture ) {
			// Manufatcure name
			var liEl = new Element( 'li', {
				html: '<strong><span></span>' + manufacture + '</strong>'
			} ).inject( ulEl );
			liEl.store( 'manufacture', manufacture );

			liEl.getElement( 'strong' ).addEvent( 'mousedown', this.selectManufacture.bindWithEvent( this, liEl ) );

			// Set random manufacture
			if ( this.randomManufacture == manufacture ) {
				liEl.addClass( 'selected' );
			}

			// Player list container
			var dlEl = new Element( 'dl', {
				'class': 'players_list'
			} ).inject( liEl );

			// Player list
			players.each( function( image, player ) {
				var dtEl = new Element( 'dt', {
					html: '<span></span>'+player
				} ).inject( dlEl );
				dtEl.store( 'player', player );
				dtEl.store( 'image', image );
				dtEl.addEvent( 'mousedown', this.selectPlayer.bindWithEvent( this, dtEl ) );

				// Set random player
				if ( this.randomPlayer == player ) {
					dtEl.addClass( 'selected' );
				}

			}, this );
		}, this );

		// Set Fx
		this.fx = new Fx.Tween( this.imageContainer, {
			duration: 150,
			transition: 'expo:in'
		} );

		// Place first image player
		this.loadPlayersImage( this.randomImage, this.randomPlayer );
	},

	loadPlayersImage: function( imageName, playerName ) {
		var imagePath = this.getImagePath( imageName );

		this.fxComplete = false;

		// Ugly animation
		this.fx.start( 'opacity', 0 ).chain( function( imagePath ) {
			new Asset.image( imagePath, {
				onload: function( imagePath ) {
					this.fx.start( 'background-image', 'url("'+imagePath+'")' );
				}.bind( this, imagePath ),
				onerror: function( imagePath ) {
					this.fx.start( 'background-image', 'url("'+this.getImagePath('unknown.png')+'")' );
				}.bind( this)
			} );
		}.bind( this, imagePath ) ).chain( function( playerName ) {
			this.imageContainer.set( 'tween', {
				transition: 'expo:out',
				onComplete: function() {
					this.fxComplete = true;
					this.selectedPlayer = playerName;
				}.bind( this )
			} );
			this.imageContainer.tween( 'opacity',1 );
		}.bind( this, playerName ) );
	},

	selectManufacture: function( event, selectedElement ) {
		event.preventDefault();
		var manufactureName = selectedElement.retrieve( 'manufacture' );

		// Do not select manufacture ones again
		if ( this.selectedManufacture == manufactureName ) {
			return;
		}

		var previousElement = this.handleContainer.getElements( 'li.selected' );

		previousElement.removeClass( 'selected' );
		selectedElement.addClass( 'selected' );

		// Fade animation
		if ( ! Browser.Engine.trident ) {
			var players = selectedElement.getElements( 'dt' );
			players.each( function( playerEl ) {
				playerEl.fade( 'hide' );
				playerEl.fade();
			} );
		}

		this.selectManufacture = manufactureName;
	},

	selectPlayer: function( event, selectedElement ) {
		event.preventDefault();
		var playerName = selectedElement.retrieve( 'player' )

		// Prevent from selecting and loading player image
		if ( !this.fxComplete || this.selectedPlayer == playerName ) {
			return;
		}

		this.handleContainer.getElements( 'dt' ).removeClass( 'selected' );
		selectedElement.addClass( 'selected' );

		// Get selected player image name
		var imageName = selectedElement.retrieve( 'image' );

		// Load player image
		this.loadPlayersImage( imageName, playerName );
	},

	setRandomManufacture: function() {
		var i = Math.floor( Math.random() * playersList.getLength() );

		this.randomManufacture = playersList.getKeys()[i];
	},

	setRandomPlayer: function() {
		var players = playersList.get( this.randomManufacture );
		var i = Math.floor( Math.random() * players.getLength() );

		this.randomPlayer = players.getKeys()[i];
		this.randomImage = players.get( this.randomPlayer );
	},

	getImagePath: function( imageName ) {
		return this.imagesPath + imageName;
	}
} );