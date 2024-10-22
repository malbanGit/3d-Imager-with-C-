// NOTE!
// For the 3d-Imager to work it is necessary 
// that the active edge of the CA1 interrupt is kept
// this is handled with the VIA_cntl register.
//
// BIOS functions that ZERO the pen (Reset0Ref ... $CC)
//      or "Unzero" the Pen (MoveTo $CE )
// write to the Control register and CLEAR the CA1 flag
// 
// Therefore it is necessary to provide these functions in a version that
// keeps bit 0 of VIA_cntl set!

// ATTENTION!
// All BIOS functions that write to VIA_cntl - MUST NOT BE USED!



////////////////////////////////////////////////////
/////  DO NOT USe THESE!                        ////
////////////////////////////////////////////////////
extern __NO_INLINE void Moveto_d_active(volatile const int a, volatile const int b); 
extern __NO_INLINE void Print_Str_d_active(volatile const int a, volatile const int b, void* volatile const u); 
extern __NO_INLINE void Print_Str_active(void* volatile const u); // 


////////////////////////////////////////////////////
/////  BELOW FUNCTIONS TO USE!!!                ////
////////////////////////////////////////////////////

// Call convention X,Y - NOT! Y,X
#define Moveto_d_3d(a,b) Moveto_d_active(((int)a),((int)b))
#define Print_Str_d_3d(a,b,s) Print_Str_d_active(((int)a),((int)b),s);
#define Print_Str_3d(s) Print_Str_active(s);

__INLINE void ZeroPen_3d(void) {
  VIA_cntl = 0xcd;
}

// just in case I forget...
#define Reset0Ref() ZeroPen_3d()
#define Moveto_d(y,x) Moveto_d_active(((int)x),((int)y))

extern void imagerCInit(void);
extern void checkPWMOutput(void);
