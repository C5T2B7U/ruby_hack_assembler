# BRIAN SUMNER
# UCDENVER CSCI 2940
# SPRING 2017
# NAND2TETRIS HACK ASSEMBLER
# JAVA VERSION JRUBY



javahackasm NOTES:




1.  Rubinius won't install on Windows.  This implementation was compiled with JRuby.

2.  jrubyc outputs a .class file that will not accept command line parameters when executed through the Java JVM.  This is verified in the "javahackasm_debug" version.

3.  Workaround measures have been implemented into hackasm source code to accomodate the lack of commandline parameters.

4.  Debug mode is now hard-coded into a separate debug version.  When you run the debug mode version, you will not see the prompts.  You must blindly type file names in the invisible prompts.  All program output will then be saved to:  "javahackasm_debug.log"

5.  You must have the "jruby-complete-9.1.8.0.jar" file for this program to run.  Do not delete the .\src directory.

6.  Please run javahackasm using the provided "javahackasm.bat" and "javahackasm_debug.bat" files, respectively.

