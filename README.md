# Bluetooth TI-84+

I put an Attiny13 and RN-42 into a TI-84+ and wrote assembly code to create a TI Link Protocol to Bluetooth bridge that works in both directions. It's transparent to the calculator's operating system, but makes the calculator appear as a regular serial port to any connected computer. I used that property to [fly a drone with my calculator](http://hackaday.com/2012/08/15/toorcamp-quadcopter-controlled-by-a-ti-84/).

Code is at github [here](https://github.com/jmptable/bluetilp).
