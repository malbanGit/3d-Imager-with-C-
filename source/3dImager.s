; NOTE!!!
; IF USED IN 'C' YOU MIGHT NEED TO SAVE SOME REGS WHEN CALLING
; YOUR FUNCTIONS, LIKE REG 'U' and 'Y'!
; ALSO CHECK YOUR DP SETTINGS, BELOW DP = D0 is assumed!
                    .module  _3dimager.asx.s 
                    .area    .text 
;***************************************************************************
; DEFINE SECTION
;***************************************************************************
; load vectrex bios routine definitions
; include line ->                     INCLUDE  "VECTREX.I"                  ; vectrex function includes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this file contains includes for vectrex BIOS functions and variables      ;
; it was written by Bruce Tomlin, slighte changed by Malban                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INCLUDE_I           =        1 
Vec_Snd_Shadow      =        0xC800                       ;Shadow of sound chip registers (15 bytes) 
Vec_Btn_State       =        0xC80F                       ;Current state of all joystick buttons 
Vec_Prev_Btns       =        0xC810                       ;Previous state of all joystick buttons 
Vec_Buttons         =        0xC811                       ;Current toggle state of all buttons 
Vec_Button_1_1      =        0xC812                       ;Current toggle state of stick 1 button 1 
Vec_Button_1_2      =        0xC813                       ;Current toggle state of stick 1 button 2 
Vec_Button_1_3      =        0xC814                       ;Current toggle state of stick 1 button 3 
Vec_Button_1_4      =        0xC815                       ;Current toggle state of stick 1 button 4 
Vec_Button_2_1      =        0xC816                       ;Current toggle state of stick 2 button 1 
Vec_Button_2_2      =        0xC817                       ;Current toggle state of stick 2 button 2 
Vec_Button_2_3      =        0xC818                       ;Current toggle state of stick 2 button 3 
Vec_Button_2_4      =        0xC819                       ;Current toggle state of stick 2 button 4 
Vec_Joy_Resltn      =        0xC81A                       ;Joystick A/D resolution (0x80=min 0x00=max) 
Vec_Joy_1_X         =        0xC81B                       ;Joystick 1 left/right 
Vec_Joy_1_Y         =        0xC81C                       ;Joystick 1 up/down 
Vec_Joy_2_X         =        0xC81D                       ;Joystick 2 left/right 
Vec_Joy_2_Y         =        0xC81E                       ;Joystick 2 up/down 
Vec_Joy_Mux         =        0xC81F                       ;Joystick enable/mux flags (4 bytes) 
Vec_Joy_Mux_1_X     =        0xC81F                       ;Joystick 1 X enable/mux flag (=1) 
Vec_Joy_Mux_1_Y     =        0xC820                       ;Joystick 1 Y enable/mux flag (=3) 
Vec_Joy_Mux_2_X     =        0xC821                       ;Joystick 2 X enable/mux flag (=5) 
Vec_Joy_Mux_2_Y     =        0xC822                       ;Joystick 2 Y enable/mux flag (=7) 
Vec_Misc_Count      =        0xC823                       ;Misc counter/flag byte, zero when not in use 
Vec_0Ref_Enable     =        0xC824                       ;Check0Ref enable flag 
Vec_Loop_Count      =        0xC825                       ;Loop counter word (incremented in Wait_Recal) 
Vec_Brightness      =        0xC827                       ;Default brightness 
Vec_Dot_Dwell       =        0xC828                       ;Dot dwell time? 
Vec_Pattern         =        0xC829                       ;Dot pattern (bits) 
Vec_Text_HW         =        0xC82A                       ;Default text height and width 
Vec_Text_Height     =        0xC82A                       ;Default text height 
Vec_Text_Width      =        0xC82B                       ;Default text width 
Vec_Str_Ptr         =        0xC82C                       ;Temporary string pointer for Print_Str 
Vec_Counters        =        0xC82E                       ;Six bytes of counters 
Vec_Counter_1       =        0xC82E                       ;First counter byte 
Vec_Counter_2       =        0xC82F                       ;Second counter byte 
Vec_Counter_3       =        0xC830                       ;Third counter byte 
Vec_Counter_4       =        0xC831                       ;Fourth counter byte 
Vec_Counter_5       =        0xC832                       ;Fifth counter byte 
Vec_Counter_6       =        0xC833                       ;Sixth counter byte 
Vec_RiseRun_Tmp     =        0xC834                       ;Temp storage word for rise/run 
Vec_Angle           =        0xC836                       ;Angle for rise/run and rotation calculations 
Vec_Run_Index       =        0xC837                       ;Index pair for run 
;                       0xC839   ;Pointer to copyright string during startup
Vec_Rise_Index      =        0xC839                       ;Index pair for rise 
;                       0xC83B   ;High score cold-start flag (=0 if valid)
Vec_RiseRun_Len     =        0xC83B                       ;length for rise/run 
;                       0xC83C   ;temp byte
Vec_Rfrsh           =        0xC83D                       ;Refresh time (divided by 1.5MHz) 
Vec_Rfrsh_lo        =        0xC83D                       ;Refresh time low byte 
Vec_Rfrsh_hi        =        0xC83E                       ;Refresh time high byte 
Vec_Music_Work      =        0xC83F                       ;Music work buffer (14 bytes, backwards?) 
Vec_Music_Wk_A      =        0xC842                       ; register 10 
;                       0xC843   ;        register 9
;                       0xC844   ;        register 8
Vec_Music_Wk_7      =        0xC845                       ; register 7 
Vec_Music_Wk_6      =        0xC846                       ; register 6 
Vec_Music_Wk_5      =        0xC847                       ; register 5 
;                       0xC848   ;        register 4
;                       0xC849   ;        register 3
;                       0xC84A   ;        register 2
Vec_Music_Wk_1      =        0xC84B                       ; register 1 
;                       0xC84C   ;        register 0
Vec_Freq_Table      =        0xC84D                       ;Pointer to note-to-frequency table (normally 0xFC8D) 
Vec_Max_Players     =        0xC84F                       ;Maximum number of players for Select_Game 
Vec_Max_Games       =        0xC850                       ;Maximum number of games for Select_Game 
Vec_ADSR_Table      =        0xC84F                       ;Storage for first music header word (ADSR table) 
Vec_Twang_Table     =        0xC851                       ;Storage for second music header word ('twang' table) 
Vec_Music_Ptr       =        0xC853                       ;Music data pointer 
Vec_Expl_ChanA      =        0xC853                       ;Used by Explosion_Snd - bit for first channel used? 
Vec_Expl_Chans      =        0xC854                       ;Used by Explosion_Snd - bits for all channels used? 
Vec_Music_Chan      =        0xC855                       ;Current sound channel number for Init_Music 
Vec_Music_Flag      =        0xC856                       ;Music active flag (0x00=off 0x01=start 0x80=on) 
Vec_Duration        =        0xC857                       ;Duration counter for Init_Music 
Vec_Music_Twang     =        0xC858                       ;3 word 'twang' table used by Init_Music 
Vec_Expl_1          =        0xC858                       ;Four bytes copied from Explosion_Snd's U-reg parameters 
Vec_Expl_2          =        0xC859                       ; 
Vec_Expl_3          =        0xC85A                       ; 
Vec_Expl_4          =        0xC85B                       ; 
Vec_Expl_Chan       =        0xC85C                       ;Used by Explosion_Snd - channel number in use? 
Vec_Expl_ChanB      =        0xC85D                       ;Used by Explosion_Snd - bit for second channel used? 
Vec_ADSR_Timers     =        0xC85E                       ;ADSR timers for each sound channel (3 bytes) 
Vec_Music_Freq      =        0xC861                       ;Storage for base frequency of each channel (3 words) 
;                       0xC85E   ;Scratch 'score' storage for Display_Option (7 bytes)
Vec_Expl_Flag       =        0xC867                       ;Explosion_Snd initialization flag? 
;               0xC868...0xC876   ;Unused?
Vec_Expl_Timer      =        0xC877                       ;Used by Explosion_Snd 
;                       0xC878   ;Unused?
Vec_Num_Players     =        0xC879                       ;Number of players selected in Select_Game 
Vec_Num_Game        =        0xC87A                       ;Game number selected in Select_Game 
Vec_Seed_Ptr        =        0xC87B                       ;Pointer to 3-byte random number seed (=0xC87D) 
Vec_Random_Seed     =        0xC87D                       ;Default 3-byte random number seed 
                                                          ; 
;    0xC880 - 0xCBEA is user RAM  ;
                                                          ; 
Vec_Default_Stk     =        0xCBEA                       ;Default top-of-stack 
Vec_High_Score      =        0xCBEB                       ;High score storage (7 bytes) 
Vec_SWI3_Vector     =        0xCBF2                       ;SWI2/SWI3 interrupt vector (3 bytes) 
Vec_SWI2_Vector     =        0xCBF2                       ;SWI2/SWI3 interrupt vector (3 bytes) 
Vec_FIRQ_Vector     =        0xCBF5                       ;FIRQ interrupt vector (3 bytes) 
Vec_IRQ_Vector      =        0xCBF8                       ;IRQ interrupt vector (3 bytes) 
Vec_SWI_Vector      =        0xCBFB                       ;SWI/NMI interrupt vector (3 bytes) 
Vec_NMI_Vector      =        0xCBFB                       ;SWI/NMI interrupt vector (3 bytes) 
Vec_Cold_Flag       =        0xCBFE                       ;Cold start flag (warm start if = 0x7321) 
                                                          ; 
VIA_port_b          =        0xD000                       ;VIA port B data I/O register 
;       0 sample/hold (0=enable  mux 1=disable mux)
;       1 mux sel 0
;       2 mux sel 1
;       3 sound BC1
;       4 sound BDIR
;       5 comparator input
;       6 external device (slot pin 35) initialized to input
;       7 /RAMP
VIA_port_a          =        0xD001                       ;VIA port A data I/O register (handshaking) 
VIA_DDR_b           =        0xD002                       ;VIA port B data direction register (0=input 1=output) 
VIA_DDR_a           =        0xD003                       ;VIA port A data direction register (0=input 1=output) 
VIA_t1_cnt_lo       =        0xD004                       ;VIA timer 1 count register lo (scale factor) 
VIA_t1_cnt_hi       =        0xD005                       ;VIA timer 1 count register hi 
VIA_t1_lch_lo       =        0xD006                       ;VIA timer 1 latch register lo 
VIA_t1_lch_hi       =        0xD007                       ;VIA timer 1 latch register hi 
VIA_t2_lo           =        0xD008                       ;VIA timer 2 count/latch register lo (refresh) 
VIA_t2_hi           =        0xD009                       ;VIA timer 2 count/latch register hi 
VIA_shift_reg       =        0xD00A                       ;VIA shift register 
VIA_aux_cntl        =        0xD00B                       ;VIA auxiliary control register 
;       0 PA latch enable
;       1 PB latch enable
;       2 \                     110=output to CB2 under control of phase 2 clock
;       3  > shift register control     (110 is the only mode used by the Vectrex ROM)
;       4 /
;       5 0=t2 one shot                 1=t2 free running
;       6 0=t1 one shot                 1=t1 free running
;       7 0=t1 disable PB7 output       1=t1 enable PB7 output
VIA_cntl            =        0xD00C                       ;VIA control register 
;       0 CA1 control     CA1 -> SW7    0=IRQ on low 1=IRQ on high
;       1 \
;       2  > CA2 control  CA2 -> /ZERO  110=low 111=high
;       3 /
;       4 CB1 control     CB1 -> NC     0=IRQ on low 1=IRQ on high
;       5 \
;       6  > CB2 control  CB2 -> /BLANK 110=low 111=high
;       7 /
VIA_int_flags       =        0xD00D                       ;VIA interrupt flags register 
;               bit                             cleared by
;       0 CA2 interrupt flag            reading or writing port A I/O
;       1 CA1 interrupt flag            reading or writing port A I/O
;       2 shift register interrupt flag reading or writing shift register
;       3 CB2 interrupt flag            reading or writing port B I/O
;       4 CB1 interrupt flag            reading or writing port A I/O
;       5 timer 2 interrupt flag        read t2 low or write t2 high
;       6 timer 1 interrupt flag        read t1 count low or write t1 high
;       7 IRQ status flag               write logic 0 to IER or IFR bit
VIA_int_enable      =        0xD00E                       ;VIA interrupt enable register 
;       0 CA2 interrupt enable
;       1 CA1 interrupt enable
;       2 shift register interrupt enable
;       3 CB2 interrupt enable
;       4 CB1 interrupt enable
;       5 timer 2 interrupt enable
;       6 timer 1 interrupt enable
;       7 IER set/clear control
VIA_port_a_nohs     =        0xD00F                       ;VIA port A data I/O register (no handshaking) 
Cold_Start          =        0xF000                       ; 
Warm_Start          =        0xF06C                       ; 
Init_VIA            =        0xF14C                       ; 
Init_OS_RAM         =        0xF164                       ; 
Init_OS             =        0xF18B                       ; 
Wait_Recal          =        0xF192                       ; 
Set_Refresh         =        0xF1A2                       ; 
DP_to_D0            =        0xF1AA                       ; 
DP_to_C8            =        0xF1AF                       ; 
Read_Btns_Mask      =        0xF1B4                       ; 
Read_Btns           =        0xF1BA                       ; 
Joy_Analog          =        0xF1F5                       ; 
Joy_Digital         =        0xF1F8                       ; 
Sound_Byte          =        0xF256                       ; 
Sound_Byte_x        =        0xF259                       ; 
Sound_Byte_raw      =        0xF25B                       ; 
Clear_Sound         =        0xF272                       ; 
Sound_Bytes         =        0xF27D                       ; 
Sound_Bytes_x       =        0xF284                       ; 
Do_Sound            =        0xF289                       ; 
Do_Sound_x          =        0xF28C                       ; 
Intensity_1F        =        0xF29D                       ; 
Intensity_3F        =        0xF2A1                       ; 
Intensity_5F        =        0xF2A5                       ; 
Intensity_7F        =        0xF2A9                       ; 
Intensity_a         =        0xF2AB                       ; 
Dot_ix_b            =        0xF2BE                       ; 
Dot_ix              =        0xF2C1                       ; 
Dot_d               =        0xF2C3                       ; 
Dot_here            =        0xF2C5                       ; 
Dot_List            =        0xF2D5                       ; 
Dot_List_Reset      =        0xF2DE                       ; 
Recalibrate         =        0xF2E6                       ; 
Moveto_x_7F         =        0xF2F2                       ; 
Moveto_d_7F         =        0xF2FC                       ; 
Moveto_ix_FF        =        0xF308                       ; 
Moveto_ix_7F        =        0xF30C                       ; 
Moveto_ix_b         =        0xF30E                       ; 
Moveto_ix           =        0xF310                       ; 
Moveto_d            =        0xF312                       ; 
Reset0Ref_D0        =        0xF34A                       ; 
Check0Ref           =        0xF34F                       ; 
Reset0Ref           =        0xF354                       ; 
Reset_Pen           =        0xF35B                       ; 
Reset0Int           =        0xF36B                       ; 
Print_Str_hwyx      =        0xF373                       ; 
Print_Str_yx        =        0xF378                       ; 
Print_Str_d         =        0xF37A                       ; 
Print_List_hw       =        0xF385                       ; 
Print_List          =        0xF38A                       ; 
Print_List_chk      =        0xF38C                       ; 
Print_Ships_x       =        0xF391                       ; 
Print_Ships         =        0xF393                       ; 
Mov_Draw_VLc_a      =        0xF3AD                       ;count y x y x ... 
Mov_Draw_VL_b       =        0xF3B1                       ;y x y x ... 
Mov_Draw_VLcs       =        0xF3B5                       ;count scale y x y x ... 
Mov_Draw_VL_ab      =        0xF3B7                       ;y x y x ... 
Mov_Draw_VL_a       =        0xF3B9                       ;y x y x ... 
Mov_Draw_VL         =        0xF3BC                       ;y x y x ... 
Mov_Draw_VL_d       =        0xF3BE                       ;y x y x ... 
Draw_VLc            =        0xF3CE                       ;count y x y x ... 
Draw_VL_b           =        0xF3D2                       ;y x y x ... 
Draw_VLcs           =        0xF3D6                       ;count scale y x y x ... 
Draw_VL_ab          =        0xF3D8                       ;y x y x ... 
Draw_VL_a           =        0xF3DA                       ;y x y x ... 
Draw_VL             =        0xF3DD                       ;y x y x ... 
Draw_Line_d         =        0xF3DF                       ;y x y x ... 
Draw_VLp_FF         =        0xF404                       ;pattern y x pattern y x ... 0x01 
Draw_VLp_7F         =        0xF408                       ;pattern y x pattern y x ... 0x01 
Draw_VLp_scale      =        0xF40C                       ;scale pattern y x pattern y x ... 0x01 
Draw_VLp_b          =        0xF40E                       ;pattern y x pattern y x ... 0x01 
Draw_VLp            =        0xF410                       ;pattern y x pattern y x ... 0x01 
Draw_Pat_VL_a       =        0xF434                       ;y x y x ... 
Draw_Pat_VL         =        0xF437                       ;y x y x ... 
Draw_Pat_VL_d       =        0xF439                       ;y x y x ... 
Draw_VL_mode        =        0xF46E                       ;mode y x mode y x ... 0x01 
Print_Str           =        0xF495                       ; 
Random_3            =        0xF511                       ; 
Random              =        0xF517                       ; 
Init_Music_Buf      =        0xF533                       ; 
Clear_x_b           =        0xF53F                       ; 
Clear_C8_RAM        =        0xF542                       ;never used by GCE carts? 
Clear_x_256         =        0xF545                       ; 
Clear_x_d           =        0xF548                       ; 
Clear_x_b_80        =        0xF550                       ; 
Clear_x_b_a         =        0xF552                       ; 
Dec_3_Counters      =        0xF55A                       ; 
Dec_6_Counters      =        0xF55E                       ; 
Dec_Counters        =        0xF563                       ; 
Delay_3             =        0xF56D                       ;30 cycles 
Delay_2             =        0xF571                       ;25 cycles 
Delay_1             =        0xF575                       ;20 cycles 
Delay_0             =        0xF579                       ;12 cycles 
Delay_b             =        0xF57A                       ;5*B + 10 cycles 
Delay_RTS           =        0xF57D                       ;5 cycles 
Bitmask_a           =        0xF57E                       ; 
Abs_a_b             =        0xF584                       ; 
Abs_b               =        0xF58B                       ; 
Rise_Run_Angle      =        0xF593                       ; 
Get_Rise_Idx        =        0xF5D9                       ; 
Get_Run_Idx         =        0xF5DB                       ; 
Get_Rise_Run        =        0xF5EF                       ; 
Rise_Run_X          =        0xF5FF                       ; 
Rise_Run_Y          =        0xF601                       ; 
Rise_Run_Len        =        0xF603                       ; 
Rot_VL_ab           =        0xF610                       ; 
Rot_VL              =        0xF616                       ; 
Rot_VL_Mode         =        0xF61F                       ; 
Rot_VL_M_dft        =        0xF62B                       ; 
;Rot_VL_dft      EQU     0xF637   ;
;Rot_VL_ab       EQU     0xF610   ;
;Rot_VL          EQU     0xF616   ;
;Rot_VL_Mode_a   EQU     0xF61F   ;
;Rot_VL_Mode     EQU     0xF62B   ;
;Rot_VL_dft      EQU     0xF637   ;
Xform_Run_a         =        0xF65B                       ; 
Xform_Run           =        0xF65D                       ; 
Xform_Rise_a        =        0xF661                       ; 
Xform_Rise          =        0xF663                       ; 
Move_Mem_a_1        =        0xF67F                       ; 
Move_Mem_a          =        0xF683                       ; 
Init_Music_chk      =        0xF687                       ; 
Init_Music          =        0xF68D                       ; 
Init_Music_x        =        0xF692                       ; 
Select_Game         =        0xF7A9                       ; 
Clear_Score         =        0xF84F                       ; 
Add_Score_a         =        0xF85E                       ; 
Add_Score_d         =        0xF87C                       ; 
Strip_Zeros         =        0xF8B7                       ; 
Compare_Score       =        0xF8C7                       ; 
New_High_Score      =        0xF8D8                       ; 
Obj_Will_Hit_u      =        0xF8E5                       ; 
Obj_Will_Hit        =        0xF8F3                       ; 
Obj_Hit             =        0xF8FF                       ; 
Explosion_Snd       =        0xF92E                       ; 
Draw_Grid_VL        =        0xFF9F                       ; 
                                                          ; 
music1              =        0xFD0D                       ; 
music2              =        0xFD1D                       ; 
music3              =        0xFD81                       ; 
music4              =        0xFDD3                       ; 
music5              =        0xFE38                       ; 
music6              =        0xFE76                       ; 
music7              =        0xFEC6                       ; 
music8              =        0xFEF8                       ; 
music9              =        0xFF26                       ; 
musica              =        0xFF44                       ; 
musicb              =        0xFF62                       ; 
musicc              =        0xFF7A                       ; 
musicd              =        0xFF8F                       ; 
Char_Table          =        0xF9F4 
Char_Table_End      =        0xFBD4 
; include line ->                     include  "3dImagerVars.i"
; include line ->                     INCLUDE  "VECTREX.I"                  ; vectrex function includes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this file contains includes for vectrex BIOS functions and variables      ;
; it was written by Bruce Tomlin, slighte changed by Malban                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    .area    .bss 
;                    org      0xc900 
                    .globl   _flagImagerSyncReceived 
_flagImagerSyncReceived:  .blkb  1 
                    .globl   _loopCounterIRQ1 
_loopCounterIRQ1:   .blkb    1                            ; sample counter of IRQ Handler, 8 IRQs are taken as one sample sequence 
                    .globl   _countIRQFailureAfterRefreshFor8Samples 
_countIRQFailureAfterRefreshFor8Samples:  .blkb  1        ; storage for the current sampling 
                    .globl   _countIRQFailureAfterRefreshFor8Samples_1 
_countIRQFailureAfterRefreshFor8Samples_1:  .blkb  1      ; storage for the last sampling 
                    .globl   _countIRQFailureAfterRefreshFor8Samples_2 
_countIRQFailureAfterRefreshFor8Samples_2:  .blkb  1      ; storage for the last last sampling 
                    .globl   _countIRQFailureAfterRefreshFor8Samples_3 
_countIRQFailureAfterRefreshFor8Samples_3:  .blkb  1      ; storage for the last last last sampling 
                    .globl   _PWM_T2_Compare_current 
_PWM_T2_Compare_current:  .blkb  1                        ; in the current "main" round used compare value for pulse width modulation 
                    .globl   _PWM_T2_Compare_faster 
_PWM_T2_Compare_faster:  .blkb  1                         ; calculated value for a pulse that should spin the wheel slightly faster 
                    .globl   _PWM_T2_Compare_slower 
_PWM_T2_Compare_slower:  .blkb  1                         ; calculated value for a pulse that should spin the wheel slightly slower 
                    .globl   _tmp_counter 
_tmp_counter:       .blkb    1                            ; gets overwritten by "_PWM_T2_Compare_slower" 
;
T2_VALUE            =        0xe000                       ; value for the wheel update frequency -> 1/(1/1500000 * 0xe000) = 26,1579241 Hz 
T2_HI               =        (((T2_VALUE)>>8)&0xff) 
T2_LO               =        ((T2_VALUE)&0xff) 
T2_INVERSE          =        (T2_LO*256)+T2_HI 
BLUE_ANGLE          =        60                           ; values for the angles "Crazy Coaster" / "narrow Escape" 
GREEN_ANGLE         =        64                           ; I use the angles to calculate in relation to the above timer value 
RED_ANGLE           =        56                           ; the compare values, when the actual eye/color combination is drawn in the timeframe of one main round 
;
RIGHT_BLUE_TIMER_WAIT  =     T2_VALUE                     ; index hole is located so, that we can start right away with blue color 

;Trying to avoid 32bit values in calculation!
T2_VALUE_8bit       =        (T2_VALUE>>8) 

T2_BLUE_16bit       =        T2_VALUE_8bit * BLUE_ANGLE 
T2_BLUE_16bit120    =        T2_BLUE_16bit / 120 
T2_BLUE_16bit120_8  =        T2_BLUE_16bit120 << 8 
T2_BLUE_16bit120_3  =        T2_BLUE_16bit120_8 / 3 

T2_GREEN_16bit      =        T2_VALUE_8bit * GREEN_ANGLE 
T2_GREEN_16bit120   =        T2_GREEN_16bit / 120 
T2_GREEN_16bit120_8  =       T2_GREEN_16bit120 << 8 
T2_GREEN_16bit120_3  =       T2_GREEN_16bit120_8 / 3 

T2_RED_16bit        =        T2_VALUE_8bit * RED_ANGLE 
T2_RED_16bit120     =        T2_RED_16bit / 120 
T2_RED_16bit120_8   =        T2_RED_16bit120 << 8 
T2_RED_16bit120_3   =        T2_RED_16bit120_8 / 3 

RIGHT_GREEN_TIMER_WAIT  =    RIGHT_BLUE_TIMER_WAIT - T2_BLUE_16bit120_3 
RIGHT_RED_TIMER_WAIT  =      RIGHT_GREEN_TIMER_WAIT - T2_GREEN_16bit120_3 
LEFT_BLUE_TIMER_WAIT  =      RIGHT_RED_TIMER_WAIT - T2_RED_16bit120_3 
LEFT_GREEN_TIMER_WAIT  =     LEFT_BLUE_TIMER_WAIT - T2_BLUE_16bit120_3 
LEFT_RED_TIMER_WAIT  =       LEFT_GREEN_TIMER_WAIT - T2_GREEN_16bit120_3 

;RIGHT_GREEN_TIMER_WAIT  =    RIGHT_BLUE_TIMER_WAIT - ((T2_VALUE*BLUE_ANGLE)/360) 
;RIGHT_RED_TIMER_WAIT  =      RIGHT_GREEN_TIMER_WAIT - ((T2_VALUE*GREEN_ANGLE)/360) 
;LEFT_BLUE_TIMER_WAIT  =      RIGHT_RED_TIMER_WAIT - ((T2_VALUE*RED_ANGLE)/360) 
;LEFT_GREEN_TIMER_WAIT  =     LEFT_BLUE_TIMER_WAIT - ((T2_VALUE*BLUE_ANGLE)/360) 
;LEFT_RED_TIMER_WAIT  =       LEFT_GREEN_TIMER_WAIT - ((T2_VALUE*GREEN_ANGLE)/360) 
;
InterruptVectorRam  =        0xCBF9 
;
; Macro definitions
;
; = PSG Port A to input (vectrex receives data from device)
;
; = PSG Port A to output (vectrex sets data to device)
;
; = the pulse from the PWM to LOW (duty cycle!)
;
; = the pulse from the PWM to HI (NO duty cycle!)
;
; checks if current PWM timer settings are reached
; if yes, the pulse is switched to HI
; and the compare value to 0, which indicates
; that for this round no more PWM checks are neccessary
; Attention
; A) Imager routines expect the interrupt on CA1 to be triggered by a positive edge
;    configuration of the "edge" is done with Via reg 0xc periphal control register.
;
;    BIOS routines store values into that regisser and "overwrite" the needed imager
;    settings, most commonly routines, which access
;    ZERO and BLANK can be = with that register, 
;    so all integrator reset stuff (WaitRecal, Reset0Ref..., all MoveTo...)
;    are dangerous. For the example I provided several routines, which support the different bit.
;
;***************************************************************************
; Variable / RAM SECTION
;***************************************************************************
; insert your variables (RAM usage) in the BSS section
; user RAM starts at 0xc880 
;***************************************************************************
; HEADER SECTION
;***************************************************************************
; The cartridge ROM starts at address 0
                    .area    .text 
; NOTE!!!
; THIS MIGHT BE INCORRECT FOR YOUR NEEDS!
; MOST OF THE TIME FOR MALBAN THIS IS GOOD!
                    .setdp   0xd000,_DATA 
                    .globl   _imagerCInit 
_imagerCInit: 
                    LDA      #0xD0 
                    TFR      A,DP 
; Warning - direct line found!
;                    direct   0xD0 
                    jsr      imagerInit                   ; initiate the Imager 
                    jmp      ReturnFromIRQ                ; and do one interrupt handling 

; main "IRQ" Loop
                    .globl   ReturnFromIRQ 
ReturnFromIRQ: 
                    ldd      Vec_Rfrsh                    ; initiate our timing reference! 
                    std      *VIA_t2_lo                   ; Set refresh timer 
                    jsr      Intensity_3F 

; the first thing we should do here is check the joystick ports (buttons!)
; so they do not interfere later with PWM pulses
; however - for the example
; there is no joystick polling required, so - for the sake of
; lazyness, I just leave that out!    (But I need it so replacing the call - GT)
;;                    PSG_PORT_A_INPUT
;;                    jsr      >Read_Btns
                    ldb      Vec_Music_Wk_7               ; Get current I/O enable setting 
                    andb     #0xBF 
                    lda      #0x07 
                    jsr      Sound_Byte_raw               ; Config Port A as an input 
                    jsr      Read_Btns
;
; macro call ->                     PSG_PORT_A_OUTPUT                     ; start our duty cycle, PSG to output 
                    ldb      Vec_Music_Wk_7               ; Get current I/O enable setting 
                    orb      #0x40 
                    lda      #0x07 
                    jsr      Sound_Byte_raw               ; Config Port A as an output 
; macro call ->                     PULSE_LOW                             ; and output a low signal 
                    ldd      #0x0E80                      ; write 0x80 to reg 14 of psg 
                    jsr      Sound_Byte                   ; this means pulse on 
                    lda      #0xCF                        ; Un-zero integrators, and trigger 
                    sta      *VIA_cntl                    ; IRQ on positive edge. 
                    ldb      #0x02                        ; CA1 bitmask 
                    stb      *VIA_int_flags               ; enable (clear) interrupt flag for CA1 in VIA 
                    andcc    #0xEF                        ; and also enable interrupts in general in our CPU 
;
                    .globl   wait_for_draw_right_blue 
wait_for_draw_right_blue: 
                    jsr      _checkPWMOutput              ; after each timeconsuming "thing" (or in iddle loop) check if PWM impulse should be put off duty 
                    ldd      #RIGHT_BLUE_TIMER_WAIT       ; check timee2 if we should start doing out current eye/color combination 
;;                    ldd      #RIGHT_BLUE_TIMER_WAIT+RIGHT_GREEN_TIMER_WAIT+RIGHT_RED_TIMER_WAIT       ; check timee2 if we should start doing out current eye/color combination 
;;                    ldd      #RIGHT_RED_TIMER_WAIT       ; check timee2 if we should start doing out current eye/color combination 
                    cmpa     *VIA_t2_hi 
                    bls      wait_for_draw_right_blue     ; if not, just wait till time passes 
                    .globl   _drawRightColor1 
                    jsr      _drawRightColor1 

;;                   .globl   wait_for_draw_right_green 
;;wait_for_draw_right_green: 
;;                    jsr      _checkPWMOutput              ; after each timeconsuming "thing" (or in iddle loop) check if PWM impulse should be put off duty 
;;                    ldd      #RIGHT_GREEN_TIMER_WAIT      ; check timer if we should start doing out current eye/color combination 
;;                    cmpa     *VIA_t2_hi 
;;                    bls      wait_for_draw_right_green    ; if not, just wait till time passes 
;;                    .globl   _drawRightColor2 
;;                    jsr      _drawRightColor2 

;;                    .globl   wait_for_draw_right_red 
;;wait_for_draw_right_red: 
;;                    jsr      _checkPWMOutput              ; after each timeconsuming "thing" (or in iddle loop) check if PWM impulse should be put off duty 
;;                    ldd      #RIGHT_RED_TIMER_WAIT        ; check timer2 if we should start doing out current eye/color combination 
;;                    cmpa     *VIA_t2_hi 
;;                    bls      wait_for_draw_right_red      ; if not, just wait till time passes 
;;                    .globl   _drawRightColor3 
;;                    jsr      _drawRightColor3 
                    .globl   wait_for_draw_left_blue 
wait_for_draw_left_blue: 
                    jsr      _checkPWMOutput              ; after each timeconsuming "thing" (or in iddle loop) check if PWM impulse should be put off duty 
                    ldd      #LEFT_BLUE_TIMER_WAIT        ; check timer2 if we should start doing out current eye/color combination 
;;                    ldd      #LEFT_BLUE_TIMER_WAIT+LEFT_GREEN_TIMER_WAIT+LEFT_RED_TIMER_WAIT        ; check timer2 if we should start doing out current eye/color combination 
;;                    ldd      #LEFT_RED_TIMER_WAIT        ; check timer2 if we should start doing out current eye/color combination 
                    cmpa     *VIA_t2_hi 
                    bls      wait_for_draw_left_blue      ; if not, just wait till time passes 
                    .globl   _drawLeftColor1 
                    jsr      _drawLeftColor1 

;;                    .globl   wait_for_draw_left_green 
;;wait_for_draw_left_green: 
;;                    jsr      _checkPWMOutput              ; after each timeconsuming "thing" (or in iddle loop) check if PWM impulse should be put off duty 
;;                    ldd      #LEFT_GREEN_TIMER_WAIT       ; check timer2 if we should start doing out current eye/color combination 
;;                    cmpa     *VIA_t2_hi 
;;                    bls      wait_for_draw_left_green     ; if not, just wait till time passes 
;;                    .globl   _drawLeftColor2 
;;                    jsr      _drawLeftColor2 

;;                    .globl   wait_for_draw_left_red 
;;wait_for_draw_left_red: 
;;                    jsr      _checkPWMOutput              ; after each timeconsuming "thing" (or in iddle loop) check if PWM impulse should be put off duty 
;;                    ldd      #LEFT_RED_TIMER_WAIT         ; check timer2 if we should start doing out current eye/color combination 
;;                    cmpa     *VIA_t2_hi 
;;                    bls      wait_for_draw_left_red       ; if not, just wait till time passes 
;;                    .globl   _drawLeftColor3 
;;                    jsr      _drawLeftColor3 

; at last we should check for joytick movement
; which actually for the example is not really neccessary!
;
                    clr      Vec_Misc_Count    ; Disable joystick approximation
                    jsr      Joy_Digital
;
                    jsr      ZeroResetPenAndDelay         ; and finish main loop 
                    jsr      Reset_Pen 
                    cwai     #0xEF                        ; * Enable IRQ & wait for goggle index 
;***************************************************************************
; DATA SECTION
;***************************************************************************
                    .globl   _redString 
_redString: 
                    .ascii   "RED"                        ; only capital letters
                    .byte    0x80                         ; 0x80 is end of string 
                    .globl   _greenString 
_greenString: 
                    .ascii   "GREEN"                      ; only capital letters
                    .byte    0x80                         ; 0x80 is end of string 
                    .globl   _blueString 
_blueString: 
                    .ascii   "BLUE"                       ; only capital letters
                    .byte    0x80                         ; 0x80 is end of string 
;***************************************************************************
; include line ->                     include  "3dImager.i"
; include line ->                     INCLUDE  "VECTREX.I"                  ; vectrex function includes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this file contains includes for vectrex BIOS functions and variables      ;
; it was written by Bruce Tomlin, slighte changed by Malban                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; subroutines for imager handling
                    .area    .text 
; NOTE!!!
; THIS MIGHT BE INCORRECT FOR YOUR NEEDS!
; MOST OF THE TIME FOR MALBAN THIS IS GOOD!
                    .setdp   0xd000,_DATA 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sets wheel frequency (T2 Timer) to Narrow Escape timer value of 0xe000
; init Interrupt
; and vars used by later pwm calculation
                    .globl   imagerInit 
imagerInit: 
                    ldd      #T2_INVERSE 
                    std      Vec_Rfrsh                    ; Set refresh timer = 0.0382 sec 
                    stb      _PWM_T2_Compare_slower 
                    ldd      #0x08 
                    std      _countIRQFailureAfterRefreshFor8Samples 
                    stb      _loopCounterIRQ1             ; Init IRQ handler's loop counter 
                    clr      _PWM_T2_Compare_faster 
                    clr      _PWM_T2_Compare_current 
                    ldd      #0x7E82 
                    .globl   _0064 
_0064: 
                    sta      Vec_IRQ_Vector               ; Set up IRQ interrupt vector: JMP 
                    stb      *VIA_int_enable 
                    ldd      #IRQ_Handler 
                    std      InterruptVectorRam           ; Set IRQ interrupt function: Sync 
                    jsr      ZeroResetPenAndDelay         ; zero integrators, and ensure CA1 trigger on active edge 
                    clr      _tmp_counter                 ; Set loop counter = 0 (we want 3 correct syncs, this is the counter for that) 
; from here on get the imager spinning with
; short pulses (no output is done till we reach the spin frequency we want)
                    .globl   spinFullWheel 
spinFullWheel: 
                    ldd      Vec_Rfrsh                    ; Wait for the goggle's disk to come upto speed* 
                    std      *VIA_t2_lo                   ; Set refresh timer 
; macro call ->                     PSG_PORT_A_INPUT                      ; get the sync state befor we initiate next pulse sequences 
                    ldb      Vec_Music_Wk_7               ; Get current I/O enable setting 
                    andb     #0xBF 
                    lda      #0x07 
                    jsr      Sound_Byte_raw               ; Config Port A as an input 
                    bsr      GetGoggleIndexState 
                    sta      _flagImagerSyncReceived      ; and store the result 
                    .globl   doAnotherPulseSequence 
doAnotherPulseSequence: 
; macro call ->                     PSG_PORT_A_OUTPUT                     ; switch to output, that we can set the pulse 
                    ldb      Vec_Music_Wk_7               ; Get current I/O enable setting 
                    orb      #0x40 
                    lda      #0x07 
                    jsr      Sound_Byte_raw               ; Config Port A as an output 
; macro call ->                     PULSE_LOW  
                    ldd      #0x0E80                      ; write 0x80 to reg 14 of psg 
                    jsr      Sound_Byte                   ; this means pulse on 
                    ldb      #0x60                        ; set delay loop value 
                    .globl   pulseOnDelayLoop 
pulseOnDelayLoop: 
                    decb     
                    bne      pulseOnDelayLoop             ; Delay for awhile 
; macro call ->                     PULSE_HI  
                    ldd      #0x0EFF                      ; write 0xff to reg 14 of psg 
                    jsr      Sound_Byte                   ; this means pulse off 
; macro call ->                     PSG_PORT_A_INPUT                      ; switch to input, so we can poll the "button 4" CA1 flag 
                    ldb      Vec_Music_Wk_7               ; Get current I/O enable setting 
                    andb     #0xBF 
                    lda      #0x07 
                    jsr      Sound_Byte_raw               ; Config Port A as an input 
                    bsr      GetGoggleIndexState 
                    tst      _flagImagerSyncReceived      ; check the last sync state 
                    bne      previousStateOff             ; has gone from off to on (jump if previous was off) 
                    tsta                                  ; previous state of sync was on 
                    bne      syncFromOnToOff              ; if switch was from on to off, than a full "round" was done -> jump 
                    .globl   previousStateOff 
previousStateOff: 
                    sta      _flagImagerSyncReceived      ; otherwise store the current sync state and do another pulse sequence 
                    bra      doAnotherPulseSequence 

; we have succeded in getting the imager wheel spinning for a full round (at least we see the sync hole)
; now lets check if we did that in the required frequency, checking Timer T2 for that purpose
                    .globl   syncFromOnToOff 
syncFromOnToOff: 
                    lda      *VIA_int_flags               ; load T2 interrupt flag 
                    bita     #0x20                        ; if the timer interrupt flag is set, than the timer elapsed BEFOR 
                    bne      spinFullWheel                ; we got to the sync hole -> we are to slow, spin another full round 
                    inc      _tmp_counter                 ; The disk is now upto speed; for 
                    lda      _tmp_counter                 ; good measure, repeat, for a 
                    cmpa     #0x03                        ; total of 3 times. 
                    bne      spinFullWheel 
                    rts                                   ; setup done! 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Exit: a = state of goggle index signal
; 0 => index signal not seen
; !=0 => index signal seen
; GetGoggleIndexState()
                    .globl   GetGoggleIndexState 
GetGoggleIndexState: 
                    lda      #0x0E                        ; Check to see if the color wheel index has been seen. 
                    sta      *VIA_port_a                  ; PSG register 14 
                    ldd      #0x1901 
                    sta      *VIA_port_b                  ; PSG latch 
                    nop      
                    stb      *VIA_port_b                  ; PSG inactive 
                    clr      *VIA_DDR_a                   ; configure port A of via as input 
                    ldd      #0x0901 
                    sta      *VIA_port_b                  ; PSG read 
                    nop      
                    lda      *VIA_port_a                  ; Read Port VIA A and this PSG A lines 
                    nop      
                    stb      *VIA_port_b                  ; PSG inactive 
                    ldb      #0xFF 
                    stb      *VIA_DDR_a                   ; Set Port A lines as outputs 
                    anda     #0x80                        ; only button 4 of joystick 1 is of interested (CA1 
                    rts      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; checks whether interrupt occured befor T2 expired or after
; if befor, we are slightly to fast, if after, than we are slightly to slow
; the next pulse modulation is contolled by  "_PWM_T2_Compare_current", in dependence of to slow or to fast
; a slightly different compare value is taken and used in the next main loop round
;
; the greater the compare value, the shorter is the PWM pulse
; if the wheel spins "to fast", the (go) "slow(er) compare" value is taken the next round
; if the wheel spins to slow, the (go) "fast(er) compare" value is taken the next round
; the (go) faster value is always smaller than the (go) slower value
; (since the smaller the value, the longer the pulse lasts, since it is a compare value to the expire of T2)
;
; every 8 wheel spins (main loops) the values are reevaluated and can be corrected
; for a detailed explanation see VIDE documentation!
; expects DP = D0
                    .globl   IRQ_Handler 
IRQ_Handler: 
                    clr      *VIA_shift_reg               ; ensure vectors are not drawn anymore!, clear shift (blank = enabled) 
                    lda      *VIA_int_flags               ; load the current interruptflags 
                    bita     #0x20                        ; did refresh timer2 already expire? 
                    bne      Timeout                      ; Yes -> so mark another timeout 
                    lda      _PWM_T2_Compare_slower       ; if not, the pulse next round will be shorter 
                    sta      _PWM_T2_Compare_current 
                    dec      _loopCounterIRQ1             ; decrement the IRQ loop counter 
                    bgt      FinishIRQ                    ; have we taken 8 samples? -> if not "return" to main loop 
                    bra      ProcessSamples               ; if yes -> process the results 

                    .globl   Timeout 
Timeout: 
                    lda      _PWM_T2_Compare_faster       ; a timeout did occur, meaning, the wheel spun to slow, so we 
                    sta      _PWM_T2_Compare_current      ; increase the pulse length slightly next round 
                    inc      _countIRQFailureAfterRefreshFor8Samples ; Increment failure counter 
                    dec      _loopCounterIRQ1             ; have we taken 8 samples? 
                    bgt      FinishIRQ                    ; -> if not "return" to main loop 
                    .globl   ProcessSamples 
ProcessSamples: 
                    ldb      #0x08 
                    stb      _loopCounterIRQ1             ; reset IRQ sample counter 
; begin calculation for the "_PWM_T2_Compare_faster" adjustment
                    ldb      _countIRQFailureAfterRefreshFor8Samples ; Sum the # of failures for this 
                    addb     _countIRQFailureAfterRefreshFor8Samples_1 ; pass and the previous pass. 
                    tfr      b,a                          ; duplicate b to a 
                    suba     #0x0D                        ; transform a to an adjustment value 
                    nega                                  ; if to many misses (>13) (wheel to slow) A will be negative, if to "few" misses (<13) (wheel to fast) A will be positive 
                    cmpb     #0x0D 
                    beq      fasterAdjustmentDone         ; jmp if last 2 failure counts == 13, no adjustment 
                    bpl      fast_wheelToSlowAdjustment   ; jmp if last 2 failure counts > 13 
; here if last 2 failure counts < 13, 
; then the wheel in average is too fast, 
; add positive value to the "fast compare", 
; so the resulting value is greater, 
; -> resulting in a shorter PWM pulse, and the speed gets slowed down
                    adda     _PWM_T2_Compare_faster       ; add positive difference 
                    bcs      fasterAdjustmentDone         ; if we are above maximum, jump 
                    sta      _PWM_T2_Compare_faster       ; otherwise store the adjustment 
                    bra      fasterAdjustmentDone 

                    .globl   fast_wheelToSlowAdjustment 
fast_wheelToSlowAdjustment: 
; here if last 2 failure counts > 13, 
; then the wheel in average is too slow, 
; add negative value to the "fast compare", 
; so the resulting value is smaller, 
; -> resulting in a longer PWM pulse, and the speed gets sped up
                    adda     _PWM_T2_Compare_faster       ; add the negative difference 
                    bcc      fasterAdjustmentDone         ; if underflow - jump 
                    sta      _PWM_T2_Compare_faster       ; otherwise store the adjustment 
                    .globl   fasterAdjustmentDone 
fasterAdjustmentDone: 
; begin calculation for the "_PWM_T2_Compare_slower" adjustment
                    addb     _countIRQFailureAfterRefreshFor8Samples_2 ; Failures for (pass - 2) 
                    addb     _countIRQFailureAfterRefreshFor8Samples_3 ; Failures for (pass - 3) 
                    subb     #0x18                        ; b contains sum of 4 passes of failure counts (32 values), subtract 3/4 
                    beq      slowerAdjustmentDone         ; if exactly 24 - we do not change the slower compare value -> jump 
                    tfr      b,a                          ; double b to a 
                    clrb                                  ; "extend" a to d 
                    nega                                  ; negate the difference 
                    asra                                  ; and sign correct divide it by two 
                    rorb                                  ; put that C bit into b (which is not used) 
                    tsta     
                    bmi      slow_wheelToSlowAdjustment   ; if A negative, than more than 24 failures did occur (we are to slow -> ) 
; here if last failue counts are less then 24 (out of 32)
; in average the wheel is to fast, so
; add positive value to the "slow compare", 
; so the resulting value is greater, 
; -> resulting in a shorter PWM pulse, and the speed gets slowed down
                    addd     _PWM_T2_Compare_slower       ; wheel to fast, add positive adjustment adjustment 
                    bcs      slowerAdjustmentDone         ; if overflow jump 
                    std      _PWM_T2_Compare_slower       ; otherwise store the new value 
                    bra      slowerAdjustmentDone 

                    .globl   slow_wheelToSlowAdjustment 
slow_wheelToSlowAdjustment: 
; here if last failue counts are more then 24 (out of 32)
; in average the wheel is to slow, so
; add negative value to the "slow compare", 
; so the resulting value is smaller, 
; -> resulting in a longer PWM pulse, and the speed gets sped up 
                    addd     _PWM_T2_Compare_slower       ; "subtract" adjustment 
                    bcc      slowerAdjustmentDone         ; if underflow - jump 
                    std      _PWM_T2_Compare_slower       ; otherwise store the new value 
                    .globl   slowerAdjustmentDone 
slowerAdjustmentDone: 
; here we begin our last check
; the "slower" and "faster" compare should not be too close to each other
; if slow is with a 0x1a reach of "fast", than ensure 0x1a as minimum distance bewteen the two
                    lda      _PWM_T2_Compare_slower       ; 
                    suba     #0x1A 
                    suba     _PWM_T2_Compare_faster 
                    bhi      ShuffleFailureInfo           ; if distance hi enough jump 
                    lda      _PWM_T2_Compare_faster       ; otherwise slow = fast + 0x1a 
                    adda     #0x1A 
                    sta      _PWM_T2_Compare_slower 
                    .globl   ShuffleFailureInfo 
ShuffleFailureInfo: 
                    ldd      _countIRQFailureAfterRefreshFor8Samples_1 ; Shuffle down the failure results (16 bit this contains pass 1+2) 
                    std      _countIRQFailureAfterRefreshFor8Samples_2 ; information for the last 3 passes (and puts it into passt 2+3) 
                    lda      _countIRQFailureAfterRefreshFor8Samples ; discarding the results for the (get current result) 
                    sta      _countIRQFailureAfterRefreshFor8Samples_1 ; oldest pass (and store to 1) 
                    clr      _countIRQFailureAfterRefreshFor8Samples ; Start w/ 0 failures for next pass 
                    .globl   FinishIRQ 
FinishIRQ: 
                    nop                                   ; ensure PWM is off duty 
; macro call ->                     PULSE_HI  
                    ldd      #0x0EFF                      ; write 0xff to reg 14 of psg 
                    jsr      Sound_Byte                   ; this means pulse off 
; macro call ->                     PSG_PORT_A_OUTPUT  
                    ldb      Vec_Music_Wk_7               ; Get current I/O enable setting 
                    orb      #0x40 
                    lda      #0x07 
                    jsr      Sound_Byte_raw               ; Config Port A as an output 
                    jsr      Reset0Ref                    ; don't bother with interrupt, edge thingy will be set in main... 
                    lds      #0xCBEA                      ; restore stack frame 
                    jmp      ReturnFromIRQ 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    .globl   ZeroResetPenAndDelay 
ZeroResetPenAndDelay: 
                    lda      #0xCD                        ; Zero integrators, and trigger IRQ 
                    sta      *VIA_cntl                    ; on positive edge. 
                    jsr      Reset_Pen 
                    jsr      Delay_RTS 
                    rts      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    .globl   _checkPWMOutput 
_checkPWMOutput: 
; macro call ->                     PWM_CHECK  
                    lda      _PWM_T2_Compare_current 
                    beq      pwm_check_done10 
                    cmpa     *VIA_t2_hi                   ; if T2 still larger, than pulse must be kept in duty mode -> jump 
                    bls      pwm_check_done10 
; macro call ->                     PULSE_HI  
                    ldd      #0x0EFF                      ; write 0xff to reg 14 of psg 
                    jsr      Sound_Byte                   ; this means pulse off 
; macro call ->                     PSG_PORT_A_INPUT  
                    ldb      Vec_Music_Wk_7               ; Get current I/O enable setting 
                    andb     #0xBF 
                    lda      #0x07 
                    jsr      Sound_Byte_raw               ; Config Port A as an input 
                    clr      _PWM_T2_Compare_current 
                    .globl   pwm_check_done10 
pwm_check_done10: 
                    rts      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; copy of the BIOS Print_Str_d with the only difference being
; that the active edge of the CA1 interrupt is kept

; callable as _Print_Str_d_active(x,y, string)
; x is in reg B
; y is on stack
; String pointer in X
                    .globl   _Print_Str_d_active 
_Print_Str_d_active: 
                    lda      2,s                          ; load y coordinate to A 
                                                          ; in B already X coordinate 

                    JSR      _Moveto_d_active_asm 
                    JSR      Delay_1 

; callable as _Print_Str_d_active(string)
                    .globl   _Print_Str_active 
_Print_Str_active: 

                    pshs     u                            ; save U 
                    tfr      x,u                          ; string pointer to U 

                    STU      Vec_Str_Ptr                  ;Save string pointer 
                    LDX      #Char_Table-0x20             ;Point to start of chargen bitmaps 
                    LDD      #0x1883                      ;a￢ﾆﾒAUX: b￢ﾆﾒORB: 0x8x = Disable RAMP, Disable Mux, mux sel = 01 (int offsets) 
                    CLR      *VIA_port_a                  ;Clear D/A output 
                    STA      *VIA_aux_cntl                ;Shift reg mode = 110 (shift out under system clock), T1 PB7 disabled, one shot mode 
                    LDX      #Char_Table-0x20             ;Point to start of chargen bitmaps 
                                                          ; first entry here, ramp is disabled 
                                                          ; if there was a jump from below 
                                                          ; ramp will be enabled by next line 
                    .globl   LF4A5 
LF4A5: 
                    STB      *VIA_port_b                  ;ramp off/on set mux to channel 1 
                    DEC      *VIA_port_b                  ;Enable mux 
                    LDD      #0x8081                      ;both to ORB, both disable ram, mux sel = 0 (y int), a:￢ﾆﾒenable mux: b:￢ﾆﾒdisable mux 
                    nop                                   ;Wait a moment 
                    INC      *VIA_port_b                  ;Disable mux 
                    STB      *VIA_port_b                  ;Disable RAMP, set mux to channel 0, disable mux 
                    STA      *VIA_port_b                  ;Enable mux 
                    TST      0xC800                       ;I think this is a delay only 
                    INC      *VIA_port_b                  ;disable mux 
                    LDA      Vec_Text_Width               ;Get text width 
                    STA      *VIA_port_a                  ;Send it to the D/A 
                    LDD      #0x0100                      ;both to ORB, both ENABLE RAMP, a:￢ﾆﾒ disable mux, b:￢ﾆﾒ enable mux 
                    LDU      Vec_Str_Ptr                  ;Point to start of text string 
                    STA      *VIA_port_b                  ;[4]enable RAMP, disable mux 
                    BRA      LF4CB                        ;[3] 

; one letter is drawn (one row that is) in 18 cycles
; 13 cycles overhead
; ramp is thus active for #ofLetters*18 + 13 cycles
                    .globl   LF4C7 
LF4C7: 
                    LDA      A,X                          ;[+5]Get bitmap from chargen table 
                    STA      *VIA_shift_reg               ;[+4]rasterout of char bitmap "row" thru shift out in shift register 
                    .globl   LF4CB 
LF4CB: 
                    LDA      ,U+                          ;[+6]Get next character 
                    BPL      LF4C7                        ;[+3]Go back if not terminator 
                    LDA      #0x81                        ;[2]disable mux, disable ramp 
                    STA      *VIA_port_b                  ;[4]disable RAMP, disable mux 
                    NEG      *VIA_port_a                  ;Negate text width to D/A 
                    LDA      #0x01                        ;enable ramp, disable mux 
                    STA      *VIA_port_b                  ;enable RAMP, disable mux 
                    CMPX     #Char_Table_End-0x20         ;[4]Check for last row 
                    BEQ      LF50A                        ;[3]Branch if last row 
                    LEAX     0x50,X                       ;[3]Point to next chargen row 
                    TFR      U,D                          ;[6]Get string length 
                    SUBD     Vec_Str_Ptr                  ;[7] 
                    SUBB     #0x02                        ;[2] - 2 
                    ASLB                                  ;[2] * 2 calculate return "way" 
                    BRN      LF4EB                        ;[3]Delay a moment 
                    .globl   LF4EB 
LF4EB: 
                    LDA      #0x81                        ;[2]disable RAMP, disable mux 
                    nop                                   ;[2] 
                    DECB                                  ;[2] 
                    BNE      LF4EB                        ;Delay some more in a loop 
                    STA      *VIA_port_b                  ;disable RAMP, disable mux 
                    LDB      Vec_Text_Height              ;Get text height 
                    STB      *VIA_port_a                  ;Store text height in D/A [go down ￢ﾆﾒ later] 
                    DEC      *VIA_port_b                  ;Enable mux 
                    LDD      #0x8101 
                    nop                                   ;Wait a moment 
                    STA      *VIA_port_b                  ;disable RAMP, disable mux 
                    CLR      *VIA_port_a                  ;Clear D/A 
                    STB      *VIA_port_b                  ;enable RAMP, disable mux 
                    STA      *VIA_port_b                  ;disable RAMP, disable mux 
                    LDB      #0x03                        ;0x0x = ENABLE RAMP? 
                    BRA      LF4A5                        ;Go back for next scan line 

                    .globl   LF50A 
LF50A: 
                    LDA      #0x98 
                    STA      *VIA_aux_cntl                ;T1￢ﾆﾒPB7 enabled 
                    puls     u 
                    JMP      ZeroResetPenAndDelay         ;Reset the zero reference 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; copy of the BIOS Moveto_d with the only difference being
; that the active edge of the CA1 interrupt is kept
                    .globl   _Moveto_d_active 
; callable as _Moveto_d_active(x,y)
; x is in reg B
; y is on stack
_Moveto_d_active: 
                    lda      2,s 
_Moveto_d_active_asm: 
;                    pshs     a 
;                    lda      #0x7f 
;                    sta      *VIA_t1_cnt_lo 
;                    puls     a 
                    STA      VIA_port_a                   ;Store Y in D/A register 
                    LDA      #0xCF                        ;Blank low, zero high, active edge 
                    STA      VIA_cntl                     ; 
                    CLRA     
                    STA      VIA_port_b                   ;Enable mux 
                    STA      VIA_shift_reg                ;Clear shift regigster 
                    INC      VIA_port_b                   ;Disable mux 
                    STB      VIA_port_a                   ;Store X in D/A register 
                    STA      VIA_t1_cnt_hi                ;enable timer 
                    LDB      #0x40                        ; 
                    .globl   finish_moving_loop 
finish_moving_loop: 
                    BITB     VIA_int_flags                ; 
                    BEQ      finish_moving_loop           ; 
                    rts      
