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

droid.makeToast("Ready for messages.");

while(true) {
	var msg = droid.bluetoothReadLine();
	droid.makeToast("Calc said: "+msg);
	droid.ttsSpeak(msg);
}
