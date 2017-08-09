// Header file containing random number generators Ran, Ranq1, and Ranq2 from
//   Numerical Recipies, ch 7.
// Functions for calling using these (for use with IDL, in particular) are in
//   ran.C
// Modified 22 October 2007

struct Ran {
  // From Numerical Recipies, 3rd Edition, sec 7.1, p342.
  // Implementation of the highest quality recommended uniform deviate random
  // number generator. The constructor is called with an integer seed and
  // create an instance of the generator. The member functions int64, doub, and
  // int32 return the next values in the random sequence as a variable type
  // indicated by their names. The period of the generator is ~3.138e57.
  Ullong u,v,w;
  Ran(Ullong j) : v(4101842887655102017LL), w(1) {
    // Constructor. Call with any integer seed (except value of v above).
    u = j^v; int64();
    v = u; int64();
    w = v; int64();
  }
  inline Ullong int64() {
    // Return 64-bit random integer. See text for explanation of method.
    u = u*2862933555777941757LL + 7046029254386353087LL;
    v ^= v >> 17; v ^= v << 31; v ^= v >> 8;
    w = 4294957665U*(w & 0xffffffff) + (w >> 32);
    Ullong x = u ^ (u << 21); x ^= x >> 35; x ^= x << 4;
    return (x + v) ^ w;
  }

  // Return random double-precision floating value in the range 0. to 1.
  inline Doub doub() { return 5.42101086242752217e-20 * int64(); }

  // Return 32-bit random integer
  inline Uint int32() { return (Uint)int64(); }
};
// *********************************************************

struct Ranq1 {
  // From Numerical Recipies, 3rd Edition, Sec 7.1.3
  // Recommended generator for everyday use. The period is ~1.8e19. 
  // Should not use this to generate more than 10^12 calls
  Ullong v;
  Ranq1(Ullong j) : v(4101842887655102017LL) {
    v ^= j;
    v = int64();
  }
  inline Ullong int64() {
    v ^= v >> 21; v ^= v << 35; v ^= v >> 4;
    return v * 2685821657736338717LL;
  }
  inline Doub doub() { return 5.42101086242752217e-20 * int64();}
  inline Uint int32() { return (Uint)int64();}
};
// *********************************************************

struct Ranq2 {
  // From Numerical Recipies, 3rd Edition, Sec 7.1.3
  // Backup generator if Ranq1 has too short a period and Ran is too slow. The
  // period is ~8.5e37
  Ullong v,w;
  Ranq2(Ullong j) : v(4101842887655102017LL), w(1) {
    v ^= j;
    w = int64();
    v = int64();
  }
  inline Ullong int64() {
    v ^= v >> 17; v^= v << 31; v ^= v >> 8;
    w = 4294957665U*(w & 0xffffffff) + (w >> 32);
    return v ^ w;
  }
  inline Doub doub() { return 5.42101086242752217e-20 * int64();}
  inline Uint int32() { return (Uint)int64(); }
};
