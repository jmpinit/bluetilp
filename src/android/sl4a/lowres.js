load("/sdcard/com.googlecode.rhinoforandroid/extras/rhino/android.js");

var droid = new Android();

droid.bluetoothConnect("00001101-0000-1000-8000-00805F9B34FB");

function pause(len) {
	len += new Date().getTime();
	while(new Date() < len) {}
}

function comm(msg) {
	droid.bluetoothWrite(msg);
}

droid.makeToast("Preparing to transfer...");
pause(2000);

//plasma code
var plasma = new Array;
var time = 0;
var width = 16;
var height = 8;
var zlimit = 8;

function refresh() {
	comm('z');
	for(var y=0; y<height; y++) {
		for(var x=0; x<width; x++) {
			if(!(y==height-1 && x==width-1)) {
				var val = Math.floor(plasma[y*width+x]);
				if(val>=0 && val<zlimit) {
					comm(String.fromCharCode(97+val));
				} else {
					comm('a');
				}
				//pause(5);
			}
		}
	}
	pause(800);
}

function set(x, y, v) {
	plasma[y*width+x] = Math.floor(v);
}

function calculate() {
	for(var y=0; y<height; y++) {
		for(var x=0; x<width; x++) {
			set(x, y, (zlimit/2)+(zlimit/4)*Math.cos(x+time/6)+(zlimit/4)*Math.sin(Math.sqrt(Math.pow(y-height/2, 2)+Math.pow(x-width/2, 2))));	
		}
	}
}

while(true) {
	calculate();
	droid.makeToast("refreshing...");
	refresh();
	time++;
}
