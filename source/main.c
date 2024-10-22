#include <vectrex.h>
#include "controller.h"

#define int8_t int
#define set_scale(s) do { VIA_t1_cnt_lo = s; } while (0)

#define SCALED

typedef struct screenxy {
    int8_t xleft, xright, y;
} screenxy;

#ifdef NEED_RANDOM
static unsigned int8_t _x, _a, _b, _c;

static void init_random(unsigned int s1,unsigned int s2,unsigned int s3, unsigned int x0) {
    _x = x0; _a = s1; _b = s2; _c = s3; _x++; _a = (_a^_c^_x); _b = (_b+_a); _c = ((_c+(_b>>1))^_a);
}

static unsigned int8_t random(void) { // assert returns unsigned value that fits in an int.
    _x++; _a = (_a^_c^_x); _b = (_b+_a); _c = ((_c+(_b>>1))^_a);
    return _c;
}
#endif

#include "perspective.h"

// Storing an (X,Y,Z) point using 3 X 4-bit nybbles uses half the space that
// using ints would do, but adds a few thousand cycles to the runtime which is unacceptable.
//#define NIBBLE :4
#define NIBBLE

typedef struct lines {
    unsigned int x0 NIBBLE, x1 NIBBLE;
    unsigned int y0 NIBBLE, y1 NIBBLE;
    unsigned int z0 NIBBLE, z1 NIBBLE;
} lines;
#define MAX_LINE_SEGMENTS 100  // 100 lines is way more than we can comfortably draw at the moment.
static lines line[MAX_LINE_SEGMENTS]; // 600 bytes if ints, 300 if nibbles
static unsigned int8_t next_free_line = 0;

static inline void add_line(const unsigned int8_t x0, const unsigned int8_t y0, unsigned const int8_t z0,
const unsigned int8_t x1, const unsigned int8_t y1, unsigned const int8_t z1) {
    // Could probably speed this up by using globals rather than 6 parameters.
    // Or make it inline (which I just did). Not that it matters as these are not in main loop.
    line[next_free_line].x0 = x0; line[next_free_line].x1 = x1;
    line[next_free_line].y0 = y0; line[next_free_line].y1 = y1;
    line[next_free_line].z0 = z0; line[next_free_line].z1 = z1;
    next_free_line += 1;
}

#include <vectrex.h>
#include "3dImager.h"

#define NEAR 10
#define MID  5
#define FAR  0

#define DX (-22)
const signed char starVlist[] = {
    (signed char) 0x00, +0x02, +0x07,  // pattern, y, x
    (signed char) 0xFF, +0x00, -0x05,  // pattern, y, x
    (signed char) 0xFF, +0x05, -0x02,  // pattern, y, x
    (signed char) 0xFF, -0x05, -0x02,  // pattern, y, x
    (signed char) 0xFF, +0x00, -0x05,  // pattern, y, x
    (signed char) 0xFF, -0x04, +0x04,  // pattern, y, x
    (signed char) 0xFF, -0x05, -0x02,  // pattern, y, x
    (signed char) 0xFF, +0x03, +0x05,  // pattern, y, x
    (signed char) 0xFF, -0x03, +0x05,  // pattern, y, x
    (signed char) 0xFF, +0x05, -0x02,  // pattern, y, x
    (signed char) 0xFF, +0x04, +0x04,  // pattern, y, x
    (signed char) 0x01 // endmarker (high bit in pattern not set)
};


static unsigned int reset_list;
void drawRightColor1(void) {
    VIA_t1_cnt_lo = 0x7f;
    
    #ifdef TEXT
    ZeroPen_3d();
    Print_Str_d_3d(DX-0x5+NEAR, -0x30, "NEAR\x80")
    checkPWMOutput();    // call this AFTER every "figure"
    
    Moveto_d_3d(10,100);
    Draw_VLp((void* const)starVlist);
    ZeroPen_3d();
    checkPWMOutput();    // call this AFTER every "figure"
    
    ZeroPen_3d();
    Print_Str_d_3d(DX+MID, 0x00, "MID\x80")
    checkPWMOutput();
    
    ZeroPen_3d();
    Print_Str_d_3d(DX+FAR, 0x30, "FAR\x80")
    checkPWMOutput();
    #endif
    
    unsigned int8_t i, x0,x1,y0,y1,z0,z1;
    int x, y, dx, dy;
    
    set_scale(0xFF);
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
    ZeroPen_3d();
    if (button_1_4_pressed())
    {
        __asm  (" jmp _mainLabel\n");
    }
    return;
}
// for the left eye     checkPWMOutput();
// is probably not needed anymore
void drawLeftColor1(void) {
    
    static unsigned int tick = 0U, zdepth = 0U;
    static int deltaz = 1;
    
    #ifdef TEXT
    ZeroPen_3d();
    Print_Str_d_3d(DX-0x5-NEAR, -0x30, "NEAR\x80")
    Moveto_d_3d(-10,100);
    Draw_VLp((void* const)starVlist);
    ZeroPen_3d();
    
    Print_Str_d_3d(DX-MID, 0x00, "MID\x80")
    
    ZeroPen_3d();
    Print_Str_d_3d(DX-FAR, 0x30, "FAR\x80")
    #endif
    
    unsigned int8_t i, x0,x1,y0,y1,z0,z1;//, zdepth = 4;
    int x, y, dx, dy;
    
    set_scale(0xFF);
    for (i = 0; i < next_free_line; i++) {
        x0 = line[i].x0;    x1 = line[i].x1;
        y0 = line[i].y0;    y1 = line[i].y1;
        z0 = line[i].z0;    z1 = line[i].z1;
        
        ZeroPen_3d();
        y = (screen[z0][y0][x0].y SCALED);
        x = (screen[z0][y0][x0].xleft SCALED);
        Moveto_d_3d(x, y);
        // Subtract last coord from this coord to get delta move value
        dy = (screen[z1][y1][x1].y SCALED) - y;
        dx = (screen[z1][y1][x1].xleft SCALED) - x;
        Draw_Line_d(dy, dx);
    }
    ZeroPen_3d();
    
    if (++tick == 2) {
        next_free_line = reset_list;
        zdepth = (unsigned int)((int)zdepth + deltaz);
        if ((zdepth == 0) || (zdepth == 15)) deltaz = -deltaz;
        add_line( 0U, 0U,zdepth,   15U,15U,zdepth); // moving X
        add_line(15U, 0U,zdepth,   0U, 15U,zdepth);
        
        add_line( 0U, zdepth, 0U,   15U,zdepth, 0U); // raising and lowering bar
        
        add_line( 0U, 0U,zdepth,   0U,15U,zdepth); // moving box
        add_line( 0U,15U,zdepth,  15U,15U,zdepth);
        add_line(15U,15U,zdepth,  15U, 0U,zdepth);
        add_line(15U, 0U,zdepth,   0U, 0U,zdepth);
        
        tick = 0;
    }
    
    return;
}


int main(void) {
    //init_random(0xcb,0xa9,0xd5,0x34);
    //(void)random();
    
    next_free_line = 0;
    
    add_line( 0U, 0U,0U,   0U,15U,0U);
    add_line( 0U,15U,0U,  15U,15U,0U);
    add_line(15U,15U,0U,  15U, 0U,0U);
    add_line(15U, 0U,0U,   0U, 0U,0U);
    
    add_line( 0U, 0U,15U,   0U,15U,15U);
    add_line( 0U,15U,15U,  15U,15U,15U);
    add_line(15U,15U,15U,  15U, 0U,15U);
    add_line(15U, 0U,15U,   0U, 0U,15U);
    
    add_line( 0U, 0U,0U,   0U, 0U,15U);
    add_line( 0U,15U,0U,   0U,15U,15U);
    add_line(15U,15U,0U,  15U,15U,15U);
    add_line(15U, 0U,0U,  15U, 0U,15U);
    
    //for (reset_list = next_free_line; reset_list < 16; reset_list++) {
        //  add_line(random()&15,random()&15,random()&15, random()&15,random()&15,random()&15);
        //}
    reset_list = next_free_line;
    add_line( 0U, 0U, 0U,   15U,15U, 0U);
    add_line(15U, 0U, 0U,   0U, 15U, 0U);
    
    set_scale(0xFF);
    
    // Compiled with -O ... 19 vectors and then things collapse. :-(
    // May be enough for some sort of 3D pong game...
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
    
    return 0;
}
