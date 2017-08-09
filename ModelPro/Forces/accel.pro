function accel, loc, input, magcoord

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Computes acceleration on a packet due to the specified forces
;; Adapted from accel in rkas.pro 
;;
;; Forces given in units of Rplan/s^2
;;
;; Possible forces: 
;;  * Gravity
;;  * radiation pressure
;;  * Lorentz [not yet]
;;
;; Equations of motion:
;;   dvxdt = sum_objects (GM * (x-x_obj))/(r_obj)^3
;;   dvydt = sum_objects (GM * (y-y_obj))/(r_obj)^3 + C* gamma(vy)
;;   dvzdt = sum_objects (GM * (z-z_obj))/(r_obj)^3
;;     -- r_obj = sqrt( (x-x_obj)^2 + (y-y_obj)^2 + (z-z_obj)^2 )
;;   dndt = instantaneous change in density
;;
;;  Version history:
;;    3.1: 12/12/2011
;;      * added which to stuff structure
;;      * passing input structure to functions
;;    3.0: 7/21/2010
;;      * rewritten with new structure architecture
;;    2.1: 4/29/10
;;      * adding optional out_of_shadow input
;;    2.0: Rewritten so that individual forces are farmed out 
;;    1.0: Original version
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

agrav =  (input.Forces.gravity) $
  ? gravity(loc, input) $
  : 0.
aradpres = (input.Forces.radpres) $
  ? radiation_pressure(loc, *magcoord.out_of_shadow) $
  : 0.
alor = (input.Forces.Lorentz) $
  ? Lorentz(loc, options) $
  : 0.

accel = {dvdt:ptr_new(0)}
*accel.dvdt = agrav + aradpres + alor

q = where(finite(*accel.dvdt) EQ 0) & if (q[0] NE -1) then stop
return, accel

end

