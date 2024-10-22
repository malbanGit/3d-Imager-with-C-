# 3d-Imager-with-C-
This is a Vide project (-> http://vide.malban.de/)

The files were original an "answer" to a forum text. I will repeat some of the forum comments here:

# 1 ######################

Something for you to play with - if inclined.

This is a Vide C-Project that utilizes the 3d-imager.

To use it in your own project you have to copy the two files:
   3dImager.h
   3dImager.s

To your project - include the "*.h" file... and Go.
Well - the structure of your program differs...

The main() function now just looks like this:


int main(void)
{
    imagerCInit();
    return 0;
}


The imager is initialized and calls back 6 functions that you must provide:


void drawRightColor1()
void drawRightColor2()
void drawRightColor3()

void drawLeftColor1()
void drawLeftColor2()
void drawLeftColor3()

As an example in the project these are implemented as:

void drawRightColor1()
{
    VIA_t1_cnt_lo = 0x7f;

    Print_Str_d_3d(0x30,0xb0, "RIGHT\x80")
    checkPWMOutput();    // call this AFTER every "figure"

    Moveto_d_3d(10,100);
    Draw_VLp((void* const)starVlist);
    ZeroPen_3d();
    checkPWMOutput();    // call this AFTER every "figure"

    return;
}
void drawRightColor2()
{
    Print_Str_d_3d(0x30,0x00, "RIGHT\x80")
    checkPWMOutput();
    return;
}
void drawRightColor3()
{
    Print_Str_d_3d(0x30,0x50, "RIGHT\x80")
    checkPWMOutput();
    return;
}

// for the left eye     checkPWMOutput();
// is probably not needed anymore
void drawLeftColor1()
{
    Print_Str_d_3d(0xb0,0xb0, "LEFT\x80")
    Moveto_d_3d(-10,100);
    Draw_VLp((void* const)starVlist);
    ZeroPen_3d();
    return;
}
void drawLeftColor2()
{
    Print_Str_d_3d(0xb0,0x00, "LEFT\x80")
    return;
}
void drawLeftColor3()
{
    Print_Str_d_3d(0xb0,0x50, "LEFT\x80")
    return;
}

You MUST NOT use Bios functions that change the CIA_CNTL register.
Mostly that means - you are not allowed to use functions that influence the Zeroing or Unzeroing.

A couple of "helper" functions are provided - see the include file.

The "3dimager.s" is one assembler file, which provides all functions needed.

The only things you might want to change might be the "values" of the disk. These are kept in constant definitions:

T2_VALUE            =        0xe000    ; value for the wheel update frequency -> 1/(1/1500000 * 0xe000) = 26,1579241 Hz 
BLUE_ANGLE          =        60        ; values for the angles "Crazy Coaster" / "narrow Escape" 
GREEN_ANGLE         =        64        ; I use the angles to calculate in relation to the above timer value 
RED_ANGLE           =        56        ; the compare values, when the actual eye/color combination is drawn in the 
				       ; timeframe of one main round 
Following values for the actual timing "might be" calculated correctly (hahaha).

The output looks like:
http://vectrex.malban.de/tmp/Imager_C.png
vectrex.malban.de/tmp/Imager_C.png

Notes:

BAD!
Things may happen, if the overall timing goes out of whack!
If the final timing interrupt is called - and the main program is not finished - the program may crash.

Housekeeping... reacting to joystick etc... must be done in one of those callbacks (or spread across).
It depends on how much time you have got in each "eye-color"...


Malban

PS
I hacked this together in an hour at work - this has only been tested in Vide - not with the real thing!

# 2 ######################

To remove the "GOGGLE" in Vide...

Go to the configuration...
On the first TAB there is a checkbox item called "display mode text".
Uncheck it - and the text should be gone.

---

For your tests / tries... 
You might want to use some little known features of Vide.

When you are in the debugger you can type "JOYI" - this opens a window that allows you to inspect devices that are connected to the joystick port (e.g. The Imager).

1. You should enable the "camera" icon in the TOP LEFT of that windows - a little green check should then be visible.
This means, that the window gets updated upon changes.

2. Use the adjacent comboBox to switch to port 1 (default is port 0)

3. In the TAB below switch to "Imager3d" - 
Then you will be able to watch all 3d imager settings.
This also lets you chose/edit wheels!

You can also switch the output mode of the imager to "BW" or to "anaglyphic"

# 3 ######################

Another reminder - something I saw in your code.
With the right Eye - the pulse may still be on and must be switch off'able.
Therefor after ever "lengthy" operation you should once call

checkPWMOutput();

The output should be more stable.

-> your right eye should look something like:

  for (i = 0; i < next_free_line; i++) {
    x0 = line[i].x0;    x1 = line[i].x1;
    y0 = line[i].y0;    y1 = line[i].y1;
    z0 = line[i].z0;    z1 = line[i].z1;

    ZeroPen_3d();
    y = (screen[z0][y0][x0].y SCALED);
    x = (screen[z0][y0][x0].xright SCALED);
    Moveto_d_3d(x, y);
    checkPWMOutput();
    // Subtract last coord from this coord to get delta move value
    dy = (screen[z1][y1][x1].y SCALED) - y;
    dx = (screen[z1][y1][x1].xright SCALED) - x;

    Draw_Line_d(dy, dx);
    checkPWMOutput();
  }



I added a "debug" feature in my code - each time your "display round" takes longer then allowed - a variable "missCounter" is increased.
If a "missed" is counted, it means the T2 Timer has reached zero and an interrupt occured during code you wanted to run.
As it is - the missed is always in the joystick code. Probably nothing too bad will happen.
But if a "missed" occurs at the wrong time - the code WILL crash!

When you have a miss - the display also gets a bit garbled - looks like you lost a frame or so.


Considering this - on my vectrex everything looks fine now... actually really much the same as the emulator except one thing:
- On a real Vectrex the "cross" starts only moving after several seconds - some uninitialized value on a real vectrex?

I have no clue what causes that...

---

In Vide you can configure how to emulate the motor of the imager.
In configuration "Emulator" (first TAB) - there is a checkBox
"imager auto mode on default"

If it is unchecked - the motor automatically spins in the speed of the wheel that is configured - nothing will ever change the speed.

If it is checked - then a actual pulse width modulation is done - and the speed of the motor is regulated by the vectrex.
The real vectrex though "spins up" in less then a second... the emulation needs about 5-6 seconds - so the screen is blank, while the motor spins up.
You can watch this via "Joyi"...

# 4 ######################

you also asked how to "exit" the spinner or switch it off/on.
It is both easy - and "not nice".

The function in main() that you call "imagerCInit()" is not a function but can rather be seen as a goto statement.
It will never "return" - the stack is rebuilt and internally the following game loop is done by setting a certain timer to T2 and when that timer reaches Zero an interrupt is invoked.

The interrupt handler resets the stack and initiates a new round.... and so forth.

To exit that "loop" you also need a "goto" statement - one that returns you to the main function.
That can not be done in "C" - as you can not goto somewhere outside your own scope.

But with a few lines of inline assembler it is possible...
So - use this as a the main function:

(NOTE: Do not use local variables in the main function!!!)


int main(void)
{
startAgain:
    imagerCInit();
     __asm  (
    	"_mainLabel:\n"

        "orcc     #0x10\n"                 // disable 6809 interrupts
        "ldd      #0x0EFF\n"               // ensure motor is switched off
        "jsr      0xF256\n"                // Sound_Byte
        "ldb      0xC845\n"                // Vec_Music_Wk_7 restore port direction
        "andb     #0xBF\n"
        "lda      #0x07\n"
        "jsr      0xF25B\n"                // Sound_Byte_raw
        "ldd      #0x3075\n"               // set refresh rate to $30000
        "std      0xC83D\n"
        "lds      #0xCBEA\n"               // correct stack frame
    );

    while (1)
    {
        Wait_Recal();
        Intensity_5F();
        Print_Str_d(0,-50,"HELLO GRAHAM!\x80");
        check_buttons();
        if (button_1_1_pressed()) goto startAgain;
    }

    // if return value is <= 0, then a warm reset will be performed,
    // otherwise a cold reset will be performed
    return 0;
}

Then in your right eye function - or anywhere else:

if (button_1_4_pressed()) 
{
    __asm  (" jmp _mainLabel\n");
}

With this you can then "jump" back to the main function.

The example jumps back and forth from imager to non - imager display using buttons 1 and 4.
(also include controller.h)

**********
ATTENTION!
**********
Vide does for whatever reason not support switching the imager off!

I have to look at that - right now in Vide you will not be able to switch back and forth!

###############
