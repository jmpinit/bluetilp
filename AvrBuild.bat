@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\Projects\Hardware\Blue_TILP\labels.tmp" -fI -W+ie -o "C:\Projects\Hardware\Blue_TILP\blue_tilp.hex" -d "C:\Projects\Hardware\Blue_TILP\blue_tilp.obj" -e "C:\Projects\Hardware\Blue_TILP\blue_tilp.eep" -m "C:\Projects\Hardware\Blue_TILP\blue_tilp.map" "C:\Projects\Hardware\Blue_TILP\blue_tilp.asm"
