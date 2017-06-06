if(typeof(tagOptions)==='undefined'){ 
	var tagOptions=[];
	var optionIndex=0;
	tagOptions[optionIndex++]=NLPTagOptions;
}else{ 
	tagOptions[optionIndex++]=NLPTagOptions;
}

if(typeof(body)==='undefined'){
	var body=document.getElementsByTagName("body")[0];
	var bigImageSize=400;
	var minVisSmallImage=50;
	var minVisLargeImage=30;

	var scriptid={};
	var tags=[];
	var windowfocus=false;


	var Base64 = {
	 
		// private property
		_keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
	 
		// public method for encoding
		encode : function (input) {
			var output = "";
			var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
			var i = 0;
	 
			input = Base64._utf8_encode(input);
	 
			while (i < input.length) {
	 
				chr1 = input.charCodeAt(i++);
				chr2 = input.charCodeAt(i++);
				chr3 = input.charCodeAt(i++);
	 
				enc1 = chr1 >> 2;
				enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
				enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
				enc4 = chr3 & 63;
	 
				if (isNaN(chr2)) {
					enc3 = enc4 = 64;
				} else if (isNaN(chr3)) {
					enc4 = 64;
				}
	 
				output = output +
				this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2) +
				this._keyStr.charAt(enc3) + this._keyStr.charAt(enc4);
	 
			}
	 
			return output;
		},
	 
		// public method for decoding
		decode : function (input) {
			var output = "";
			var chr1, chr2, chr3;
			var enc1, enc2, enc3, enc4;
			var i = 0;
	 
			input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
	 
			while (i < input.length) {
	 
				enc1 = this._keyStr.indexOf(input.charAt(i++));
				enc2 = this._keyStr.indexOf(input.charAt(i++));
				enc3 = this._keyStr.indexOf(input.charAt(i++));
				enc4 = this._keyStr.indexOf(input.charAt(i++));
	 
				chr1 = (enc1 << 2) | (enc2 >> 4);
				chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
				chr3 = ((enc3 & 3) << 6) | enc4;
	 
				output = output + String.fromCharCode(chr1);
	 
				if (enc3 != 64) {
					output = output + String.fromCharCode(chr2);
				}
				if (enc4 != 64) {
					output = output + String.fromCharCode(chr3);
				}
	 
			}
	 
			output = Base64._utf8_decode(output);
	 
			return output;
	 
		},
	 
		// private method for UTF-8 encoding
		_utf8_encode : function (string) {
			string = string.replace(/\r\n/g,"\n");
			var utftext = "";
	 
			for (var n = 0; n < string.length; n++) {
	 
				var c = string.charCodeAt(n);
	 
				if (c < 128) {
					utftext += String.fromCharCode(c);
				}
				else if((c > 127) && (c < 2048)) {
					utftext += String.fromCharCode((c >> 6) | 192);
					utftext += String.fromCharCode((c & 63) | 128);
				}
				else {
					utftext += String.fromCharCode((c >> 12) | 224);
					utftext += String.fromCharCode(((c >> 6) & 63) | 128);
					utftext += String.fromCharCode((c & 63) | 128);
				}
	 
			}
	 
			return utftext;
		},
	 
		// private method for UTF-8 decoding
		_utf8_decode : function (utftext) {
			var string = "";
			var i = 0;
			var c = c1 = c2 = 0;
	 
			while ( i < utftext.length ) {
	 
				c = utftext.charCodeAt(i);
	 
				if (c < 128) {
					string += String.fromCharCode(c);
					i++;
				}
				else if((c > 191) && (c < 224)) {
					c2 = utftext.charCodeAt(i+1);
					string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
					i += 2;
				}
				else {
					c2 = utftext.charCodeAt(i+1);
					c3 = utftext.charCodeAt(i+2);
					string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
					i += 3;
				}
	 
			}
	 
			return string;
		}
	 
	};



	function Timer(fn, t) {
	    var timerObj = null;

	    this.stop = function() {
	        if (timerObj) {
	            clearInterval(timerObj);
	            timerObj = null;
	        }
	        return this;
	    }

	    this.start = function() {
	        if (!timerObj) {
	            this.stop();
	            timerObj = setInterval(fn, t);
	        }
	        return this;
	    }

	    this.reset = function(newT) {
	        t = newT;
	        return this.stop().start();
	    }
	}



	class Tagger {
		constructor(id,height,source,type,tagOpts) {

			this.ad={};
			this.ad.rl=window.location.href;
			this.ad.adrcg="abc1234";
			this.ad.tgdi=id;
			this.ad.abl=0;
			this.ad.firstfire=1;
			this.ad.puck=0;
			this.ad.up=0;
			this.ad.mud=0;
			this.ad.height = height;

			this.ad.apikey=tagOpts['key'];
			this.ad.source=tagOpts['source'];
			this.ad.id1=tagOpts['id1'];
			this.ad.id2=tagOpts['id2'];
			this.ad.id3=tagOpts['id3'];
			this.ad.id4=tagOpts['id4'];
			this.ad.id5=tagOpts['id5'];

			var oop=this;

			this.timer=new Timer(function(){ 
				if(!document.hidden){ 
					oop.ad.mud++;
				}
				
				if(oop.ad.firstfire==1 && oop.ad.abl==1 ){
					oop.FPTA(oop.ad);
					console.log("first fire");
					oop.ad.firstfire=0;
				}

				if(oop.ad.mud%30==0 && oop.ad.abl==1){
					console.log("30 fire");
					oop.ad.firstfire=-1;
					oop.FPTA(oop.ad);
				}

				if(windowfocus===true){
					oop.timer.stop();
					console.log("window/hidden fire");
					oop.ad.firstfire=-1;
					oop.FPTA(oop.ad);
				}
				window.localStorage.setItem(oop.ad.tgdi,JSON.stringify(oop.ad));

			},1000);

			this.visiblebrowser=window.innerHeight;

			if(type==='still'){ 
				this.timeouttime=1000;
			}else{ 
				this.timeouttime=2000;
			}

		}

		FPTA(params){
			var data=Base64.encode(JSON.stringify(params));
			var jsonstring=JSON.stringify(params);
			var api_url="http://data.nlpcaptcha.in/index.php/humanity/";
			api_url=api_url+'abc1234/';
			navigator.sendBeacon(api_url+data,data);
		}



		incremento(){ 
			if(this.ad.puck==0 && !document.hidden){ 
				this.ad.up++;
				this.ad.puck=1;
				window.localStorage.setItem(this.ad.tgdi,JSON.stringify(this.ad));
			}
		}

		ISAV(){
			var visiblearea=0;
			var visibilityfactor=0;

			var topoffset = document.getElementById(this.ad.tgdi).getBoundingClientRect().top; 
			var bottomoffset=document.getElementById(this.ad.tgdi).getBoundingClientRect().bottom;
			
			if(bottomoffset<0){
				visibilityfactor=0;
			}else if(topoffset > this.visiblebrowser){
				visibilityfactor=0;
			}else if(topoffset > 0 && bottomoffset < this.visiblebrowser){
				visibilityfactor=100;
			}else{
				if(topoffset < 0){
					visiblearea=this.ad.height-bottomoffset;
					visibilityfactor=parseInt(visiblearea/this.ad.height*100);
				}else if(bottomoffset > this.visiblebrowser){
					visiblearea=bottomoffset-this.visiblebrowser;
					visiblearea=this.ad.height-visiblearea;
					visibilityfactor=parseInt(visiblearea/this.ad.height*100);
				}
			}
			return visibilityfactor;
		}

		calvisRation(){
			var oop=this;
			setTimeout(function(){ 
				var temp=oop.ISAV();


				if(document.hidden){
					oop.timer.stop();
					console.log("hidden fire");
					oop.ad.firstfire=-1;
					oop.FPTA(oop.ad);
				}

				if(oop.ad.height >= bigImageSize && temp >= minVisLargeImage){
					// console.log("Big "+oop.ad.tgdi+" visible");
					oop.ad.abl=1;
					oop.incremento();
					oop.ad.in=temp;
					oop.timer.start();
				}else if(oop.ad.height < bigImageSize && temp >= minVisSmallImage){ 
					// console.log(oop.ad.tgdi+" visible");
					oop.ad.abl=1;
					oop.incremento();
					oop.ad.in=temp;
					oop.timer.start();
				}else{ 
					// console.log(oop.ad.tgdi+"invisible");
					oop.ad.abl=0;
					oop.ad.puck=0;
					oop.ad.in=temp;
					oop.timer.stop();
				}
				window.localStorage.setItem(oop.ad.tgdi,JSON.stringify(oop.ad));
			},oop.timeouttime);
		}

	}


	window.addEventListener("DOMContentLoaded",function(){
		var ab=document.querySelectorAll("script[src*='tagVisibility.js']");
		for (var i = 0; i < ab.length; i++) {
			var d={};
			d["scriptId"]="abc123+"+parseInt(i+1);
			d["targetId"]="adTagged_"+d["scriptId"];
			d["height"]=ab[i].previousElementSibling.previousElementSibling.clientHeight;
			d["options"]=tagOptions[i];
			ab[i].previousElementSibling.previousElementSibling.setAttribute("id",d["targetId"]);
			ab[i].setAttribute("id",d["scriptId"]);
			scriptid[i]=d;
			tags[i]=new Tagger(d["targetId"],d["height"],tagOptions[i]['source'],tagOptions[i]['id2'],tagOptions[i]);
		}
	});
	console.log(scriptid);
}
	
function callEveryone(){ 
	for (var i = 0; i < tags.length; i++) {
		tags[i].calvisRation();
	}
}

function callOnFocus(){ 
	for (var i = 0; i < tags.length; i++) {
		tags[i].ad.puck=0;
		tags[i].calvisRation();
	}
}


window.onload=callEveryone;
window.onscroll=callEveryone;

window.onfocus=function(){ 
	console.log("called on focus");
	windowfocus=false;
	callOnFocus();
}
window.onblur=function(){ 
	console.log("window blurred");
	windowfocus=true;
	callEveryone();
}

window.onbeforeunload=function(){ 
	for (var i = 0; i < tags.length; i++) {
		tags[i].timer.stop();
		tags[i].FPTA(tags[i].ad);
	}
}