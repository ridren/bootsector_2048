# 2048 written in 16bit x86 fitting into boot sector

full showcase: https://www.youtube.com/watch?v=KgHWpsxlf4Y


assembling:
```
nasm -f bin 2048.asm
```
then put the data into .img and run it into VM or dd it to external drive 
note that external drive will not work unless you put data into MBR
