pro rk5, loc, h, input, delta 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This does a 5th order RK step and computes the error estimate
;; See Numerical Recipes, ch 17.2
;;
;; For each step:
;;   f_x = v 
;;   f_v = a
;;   f_f = -f * ioniz 
;;
;; Version History 
;; * 3.4: 8/2/2012
;;     * Replace frac with ln(frac)
;; * 3.3: 8/1/2012
;;     * There are some issues computing frac. Trying to fix.
;; * 3.2: 12/12/2011
;;     * added which to stuff structure
;; * 3.1: 4/27/2011
;;     * cleaning up a bit and checking the error estimate
;; * 3.0: 7/21/10
;;     * Updating for new structure architecture
;; * 2.2: 4/26/10
;;     * The radiation pressure function only looks to see if the packet is in the 
;;       planet shadow. Adding fix to check for moon shadow also
;; * 2.1: 4/26/10
;;     * xyz_to_magcoords and ionization_rate now determine whether the packet is 
;;       shadowed by planets and moons. rk_5 is consistent with changes in those 
;;       routines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants

f0 = *loc.frac
*loc.frac = alog(*loc.frac)

hh = h # [1., 1., 1.] 

;; RK coefficients
c2 = 0.2d & c3 = 0.3d & c4 = 0.8d & c5 = 8./9.d & c6 = 1d & c7 = 1d

b1 = 35d/384d & b2 = 0d & b3 = 500d/1113d & b4 = 125d/192d & b5 = -2187d/6784d 
b6 = 11d/84d & b7 = 0d
b1s = 5179d/57600d & b2s = 0d & b3s = 7571d/16695d & b4s = 393d/640d 
  b5s = -92097d/339200d & b6s = 187d/2100d & b7s = 1d/40d
b1d = b1-b1s & b2d = b2-b2s & b3d = b3-b3s & b4d = b4-b4s & b5d = b5-b5s & b6d = b6-b6s 
  b7d = b7-b7s

a21 = 0.2d
a31 = 3d/40d & a32 = 9d/40d
a41 = 44d/45d & a42 = -56d/15d & a43 = 32d/9d
a51 = 19372d/6561d & a52 = -25360d/2187d & a53 = 64448d/6561d & a54 = -212d/729d
a61 = 9017d/3168d & a62 = -355d/33d & a63 = 46732d/5247d & a64 = 49d/176d 
  a65 = -5103d/18656d
a71 = b1 & a72 = b2 & a73 = b3 & a74 = b4 & a75 = b5 & a76 = b6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (1) Determine initial acceleration and ionization rate
magcoord = xyz_to_magcoord(loc, input)
accel1 = accel(loc, input, magcoord)
ioniz1 = ionization_rate(loc, input, magcoord)
magcoord = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Step 2
loc2 = {t: ptr_new(*loc.t-c2*h), $
        x: ptr_new(*loc.x+hh*a21**loc.v), $
	v: ptr_new(*loc.v+hh*a21**accel1.dvdt), $
	frac:ptr_new(*loc.frac-h*a21*ioniz1)}

magcoord = xyz_to_magcoord(loc2, input)
accel2 = accel(loc2, input, magcoord)
ioniz2 = ionization_rate(loc2, input, magcoord)
magcoord = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Step 3
loc3 = {t: ptr_new(*loc.t - c3*h), $
        x: ptr_new(*loc.x + hh * (a31**loc.v + a32**loc2.v)), $
	v: ptr_new(*loc.v + hh * (a31**accel1.dvdt + a32**accel2.dvdt)), $
        frac:ptr_new(*loc.frac - h * (a31*ioniz1 + a32*ioniz2))}

magcoord = xyz_to_magcoord(loc3, input)
accel3 = accel(loc3, input, magcoord)
ioniz3 = ionization_rate(loc3, input, magcoord)
magcoord = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Step 4
loc4 = {t: ptr_new(*loc.t - c4*h), $
        x: ptr_new(*loc.x + hh * (a41**loc.v + a42**loc2.v + a43**loc3.v)), $
	v: ptr_new(*loc.v + hh * (a41**accel1.dvdt + a42**accel2.dvdt + $
  	  a43**accel3.dvdt)), $
	frac:ptr_new(*loc.frac - h * (a41*ioniz1 + a42*ioniz2 + a43*ioniz3))}

magcoord = xyz_to_magcoord(loc4, input)
accel4 = accel(loc4, input, magcoord)
ioniz4 = ionization_rate(loc4, input, magcoord)
magcoord = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Step 5
loc5 = {t: ptr_new(*loc.t - c5*h), $
        x: ptr_new(*loc.x + hh * (a51**loc.v + a52**loc2.v + a53**loc3.v + $
	  a54**loc4.v)), $
	v: ptr_new(*loc.v + hh * (a51**accel1.dvdt + a52**accel2.dvdt + $
	  a53**accel3.dvdt + a54**accel4.dvdt)), $
	frac:ptr_new(*loc.frac - h * (a51*ioniz1 + a52*ioniz2 + a53*ioniz3 + $
	  a54*ioniz4))}

magcoord = xyz_to_magcoord(loc5, input)
accel5 = accel(loc5, input, magcoord)
ioniz5 = ionization_rate(loc5, input, magcoord)
magcoord = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Step 6
loc6 = {t: ptr_new(*loc.t - c6*h), $
        x: ptr_new(*loc.x + hh * (a61**loc.v + a62**loc2.v + a63**loc3.v + $
	  a64**loc4.v + a65**loc5.v)), $
	v: ptr_new(*loc.v + hh * (a61**accel1.dvdt + a62**accel2.dvdt + $
	  a63**accel3.dvdt + a64**accel4.dvdt + a65**accel5.dvdt)), $
	frac:ptr_new(*loc.frac - h * (a61*ioniz1 + a62*ioniz2 + a63*ioniz3 + $
	  a64*ioniz4 + a65*ioniz5))}

magcoord = xyz_to_magcoord(loc6, input)
accel6 = accel(loc6, input, magcoord)
ioniz6 = ionization_rate(loc6, input, magcoord)
magcoord = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compute the final result
*loc.t = *loc.t - h
*loc.x = *loc.x + hh * (a71**loc.v + a72**loc2.v + a73**loc3.v + a74**loc4.v + $
  a75**loc5.v + a76**loc6.v)
*loc.v = *loc.v + hh * (a71**accel1.dvdt + a72**accel2.dvdt + a73**accel3.dvdt + $
  a74**accel4.dvdt + a75**accel5.dvdt + a76**accel6.dvdt)
*loc.frac = *loc.frac - h * (a71*ioniz1 + a72*ioniz2 + a73*ioniz3 + a74*ioniz4 + $
  a75*ioniz5 + a76*ioniz6)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Step 8 -- Estimate the error
magcoord = xyz_to_magcoord(loc, input)
accel7 = accel(loc, input, magcoord)
ioniz7 = ionization_rate(loc, input, magcoord)
magcood = 0

deltax = abs(hh * (b1d**loc.v + b2d**loc2.v + b3d**loc3.v + b4d**loc4.v + $
  b5d**loc5.v + b6d**loc6.v + b7d**loc.v))
deltav = abs(hh * (b1d**accel1.dvdt + b2d**accel2.dvdt + b3d**accel3.dvdt + $
  b4d**accel4.dvdt + b5d**accel5.dvdt + b6d**accel6.dvdt + b7d**accel7.dvdt))
deltaf = abs(h * (b1d*ioniz1 + b2d*ioniz2 + b3d*ioniz3 + b4d*ioniz4 + b5d*ioniz5 + $
  b6d*ioniz6 + b7d*ioniz7))
;q = where(*loc.frac GT alog(f0), nq) & if (nq GT 0) then stop

delta = {x:ptr_new(deltax), v:ptr_new(deltav), frac:ptr_new(deltaf)}

;; Put frac back the way it was
*loc.frac = exp(*loc.frac)

accel1 = 0 & accel2 = 0 & accel3 = 0  & accel4 = 0 & accel5 = 0 & accel6 = 0 & accel7 = 0
loc2 = 0 & loc3 = 0 & loc4 = 0 & loc5 = 0 & loc6 = 0 


end
