#include <nr3.h>
#include "ran.h"
#include <idl_export.h>

// File contains functions for using the random number generators from
// Numerical Recipies in IDL.
// Modified 22 October 2007
//   -- moving the structures to header file ran.h so that other routines
//      can use them easily

extern "C" {
  int ran_nr(int *seed, IDL_LONG *n, double result[]);
  int ranq1_nr(int *seed, IDL_LONG *n, double result[]);
  int ranq2_nr(int *seed, IDL_LONG *n, double result[]);
}
// *********************************************************

int ran_nr(int *seed, IDL_LONG *n, double result[]) {
  // Function to generate random sequence with Ran algorithm
  Ullong s = (Ullong) *seed;
  Doub result2[*n];
  Ran ran0(s);
  for (long i=0;i<*n;i++) {
    result2[i] = ran0.doub();
    result[i] = (double) result2[i];
  }
  return 1;
}
// *********************************************************

int ranq1_nr(int *seed, IDL_LONG *n, double result[]) {
  // Function to generate random sequence with Ran algorithm
  Ullong s = (Ullong) *seed;
  Doub result2[*n];
  Ranq1 ran0(s);
  for (long i=0;i<*n;i++) {
    result2[i] = ran0.doub();
    result[i] = (double) result2[i];
  }
  return 1;
}
// *********************************************************

int ranq2_nr(int *seed, IDL_LONG *n, double result[]) {
  // Function to generate random sequence with Ran algorithm
  Ullong s = (Ullong) *seed;
  Doub result2[*n];
  Ranq2 ran0(s);
  for (long i=0;i<*n;i++) {
    result2[i] = ran0.doub();
    result[i] = (double) result2[i];
  }
  return 1;
}
// *********************************************************

