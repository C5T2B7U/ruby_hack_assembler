@ECHO OFF
ECHO.
ECHO.
ECHO SUMNERBR:  HACK ASSEMBLER FOR RUBY FOR JAVA  --  DEBUG MODE
ECHO.
ECHO.
ECHO INSTRUCTIONS:
ECHO 1.  You will see a listing of all *.asm files in the current directory.
ECHO 2.  Wait several seconds for the assembler program to initialize. 
ECHO 3.  Once loaded you will be presented with a blank prompt.
ECHO 4.  Enter a valid .asm inputfile name into the blank prompt.
ECHO 5.  You will be presented with another blank prompt.
ECHO 6.  Enter a valid .hack outputfile name into the blank prompt.
ECHO 7.  Assembler execution will begin.
ECHO 8.  All display output is being redirected to:  javahackasm_debug.log
ECHO 9.  After assembler execution this file will be shown in directory.
ECHO.
ECHO.
PAUSE

dir /w *.asm
ECHO.
ECHO.

java -cp .;.\src\jruby-complete-9.1.8.0.jar javahackasm_debug > javahackasm_debug.log

ECHO.
ECHO.

dir javahackasm_debug.log

ECHO.
ECHO.
PAUSE