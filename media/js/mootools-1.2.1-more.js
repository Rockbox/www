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
var noobSlide=new Class({initialize:function(b){this.items=b.items;this.mode=b.mode||"horizontal";
this.modes={horizontal:["left","width"],vertical:["top","height"]};this.size=b.size||240;
this.box=b.box.setStyle(this.modes[this.mode][1],(this.size*this.items.length)+"px");
this.button_event=b.button_event||"click";this.handle_event=b.handle_event||"click";
this.onWalk=b.onWalk||null;this.currentIndex=null;this.previousIndex=null;this.nextIndex=null;
this.interval=b.interval||5000;this.autoPlay=b.autoPlay||false;this._play=null;this.handles=b.handles||null;
if(this.handles){this.addHandleButtons(this.handles)}this.buttons={previous:[],next:[],play:[],playback:[],stop:[]};
if(b.addButtons){for(var a in b.addButtons){this.addActionButtons(a,$type(b.addButtons[a])=="array"?b.addButtons[a]:[b.addButtons[a]])
}}this.fx=new Fx.Tween(this.box,$extend((b.fxOptions||{duration:500,wait:false}),{property:this.modes[this.mode][0]}));
this.walk((b.startItem||0),true,true)},addHandleButtons:function(b){for(var a=0;a<b.length;
a++){b[a].addEvent(this.handle_event,this.walk.bind(this,[a,true]));b[a].addEvent(this.handle_event,function(c){c.preventDefault()
})}},addActionButtons:function(c,b){for(var a=0;a<b.length;a++){switch(c){case"previous":b[a].addEvent(this.button_event,this.previous.bind(this,[true]));
break;case"next":b[a].addEvent(this.button_event,this.next.bind(this,[true]));break;
case"play":b[a].addEvent(this.button_event,this.play.bind(this,[this.interval,"next",false]));
break;case"playback":b[a].addEvent(this.button_event,this.play.bind(this,[this.interval,"previous",false]));
break;case"stop":b[a].addEvent(this.button_event,this.stop.bind(this));break}this.buttons[c].push(b[a])
}},previous:function(a){this.walk((this.currentIndex>0?this.currentIndex-1:this.items.length-1),a)
},next:function(a){this.walk((this.currentIndex<this.items.length-1?this.currentIndex+1:0),a)
},play:function(a,c,b){this.stop();if(!b){this[c](false)}this._play=this[c].periodical(a,this,[false])
},stop:function(){$clear(this._play)},walk:function(c,b,a){if(c!=this.currentIndex){this.currentIndex=c;
this.previousIndex=this.currentIndex+(this.currentIndex>0?-1:this.items.length-1);
this.nextIndex=this.currentIndex+(this.currentIndex<this.items.length-1?1:1-this.items.length);
if(b){this.stop()}if(a){this.fx.cancel().set((this.size*-this.currentIndex)+"px")
}else{this.fx.start(this.size*-this.currentIndex)}if(b&&this.autoPlay){this.play(this.interval,"next",true)
}if(this.onWalk){this.onWalk((this.items[this.currentIndex]||null),(this.handles&&this.handles[this.currentIndex]?this.handles[this.currentIndex]:null))
}}}});

/*
 * Rockbox.org
 * rockboxPlayersList class
 * Copyright 2009 by Maciej "Macku" Adamczak <emacieka@tlen.pl>
 */
var rockboxPlayersList=new Class({handleContainerId:"players_list",randomManufacture:null,randomPlayer:null,randomImage:null,imageContainerId:"player_image",imageContainer:null,imagesPath:"media/images/players/",selectedManufacture:null,selectedPlayer:null,fx:null,fxComplete:true,initialize:function(c,a){this.handleContainer=$(c||this.handleContainerId);
this.imageContainer=$(a||this.imageContainerId);this.setRandomManufacture();this.setRandomPlayer();
var b=new Element("ul",{"class":"manufacture_list"}).inject(this.handleContainer);
playersList.each(function(g,f){var d=new Element("li",{html:"<strong><span></span>"+f+"</strong>"}).inject(b);
d.store("manufacture",f);d.getElement("strong").addEvent("mousedown",this.selectManufacture.bindWithEvent(this,d));
if(this.randomManufacture==f){d.addClass("selected")}var e=new Element("dl",{"class":"players_list"}).inject(d);
g.each(function(j,i){var h=new Element("dt",{html:"<span></span>"+i}).inject(e);h.store("player",i);
h.store("image",j);h.addEvent("mousedown",this.selectPlayer.bindWithEvent(this,h));
if(this.randomPlayer==i){h.addClass("selected")}},this)},this);this.fx=new Fx.Tween(this.imageContainer,{duration:150,transition:"expo:in"});
this.loadPlayersImage(this.randomImage,this.randomPlayer)},loadPlayersImage:function(c,b){var a=this.getImagePath(c);
this.fxComplete=false;this.fx.start("opacity",0).chain(function(d){new Asset.image(d,{onload:function(e){this.fx.start("background-image",'url("'+e+'")')
}.bind(this,d),onerror:function(e){this.fx.start("background-image",'url("'+this.getImagePath("unknown.jpg")+'")')
}.bind(this)})}.bind(this,a)).chain(function(d){this.imageContainer.set("tween",{transition:"expo:out",onComplete:function(){this.fxComplete=true;
this.selectedPlayer=d}.bind(this)});this.imageContainer.tween("opacity",1)}.bind(this,b))
},selectManufacture:function(d,e){d.preventDefault();var b=e.retrieve("manufacture");
if(this.selectedManufacture==b){return}var a=this.handleContainer.getElements("li.selected");
a.removeClass("selected");e.addClass("selected");if(!Browser.Engine.trident){var c=e.getElements("dt");
c.each(function(f){f.fade("hide");f.fade()})}this.selectManufacture=b},selectPlayer:function(c,d){c.preventDefault();
var a=d.retrieve("player");if(!this.fxComplete||this.selectedPlayer==a){return}this.handleContainer.getElements("dt").removeClass("selected");
d.addClass("selected");var b=d.retrieve("image");this.loadPlayersImage(b,a)},setRandomManufacture:function(){var a=Math.floor(Math.random()*playersList.getLength());
this.randomManufacture=playersList.getKeys()[a]},setRandomPlayer:function(){var b=playersList.get(this.randomManufacture);
var a=Math.floor(Math.random()*b.getLength());this.randomPlayer=b.getKeys()[a];this.randomImage=b.get(this.randomPlayer)
},getImagePath:function(a){return this.imagesPath+a}});