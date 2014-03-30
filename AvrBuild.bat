@ECHO OFF
"D:\AVRS4\AvrAssembler2\avrasm2.exe" -S "D:\myAVR\ARMCONT\labels.tmp" -fI -W+ie -C V2E -o "D:\myAVR\ARMCONT\ARMCONT.hex" -d "D:\myAVR\ARMCONT\ARMCONT.obj" -e "D:\myAVR\ARMCONT\ARMCONT.eep" -m "D:\myAVR\ARMCONT\ARMCONT.map" "D:\myAVR\ARMCONT\ARMCONT.asm"
