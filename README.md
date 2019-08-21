# hexSummator
It's HEX summator which allows you to summarize two number. You enter first hex number than you enter second. After you get result number.
All steps are accompanied by messages. In this programm also provides for defence from idiot. You can't broke this program by passing uncorrect data

# Demonstration


# Key moments
- Working with stack. You can access to local variables using **[bp-x]** or by **[sp+x]**(If you use sp you must first sub sp on the total local variable storage)
- When you call interrupt it use stack for pass data and that means even if you use [bp-x] method for access local variables - ***you must sub sp for the local variables***(as if you prepare for using [sp+x]) otherwise it will overwrite your local varialble by passing interrupt data on the stack
- As when you get input number you convert it to **PC**(digit) representation for arithmetic action visa versa when you would print number you should convert it to **Human** representation

# How to run this locally
You need emu8086 to run this
Just open *.asm file than click `emulate` after that you finally should click `run`
