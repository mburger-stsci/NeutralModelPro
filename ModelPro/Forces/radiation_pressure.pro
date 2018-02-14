function radiation_pressure, loc, out_of_shadow

common constants

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Get radiation acceleration as function of radial velocity
;; Radiation pressure depends on the species
;;
;; Radiation_const = h*g/(m*lambda)/R_planet as fn of v_rad [units = R_plan/s^2]
;;
;; Version history
;;   3.1: 12/12/2011
;;     * removed the unused inputs geometry and atom
;;     * adding check to see if v_r outside range of values for which g-value has been
;;       computed
;;   3.0: 7/20/2010
;;     * Revised for new structures
;;   2.1: Added support for multiple species based on gvalues from Killen et al 2008
;;   2.0: original
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (n_elements(out_of_shadow) EQ 0) then stop ;out_of_shadow = 1.

vv = (*loc.v)[*,1]+stuff.vrplanet

;; check to see if vv is outside range of acceptable values
q = where(vv GT max(*stuff.radpres_v), nq) 
if (nq GT 1) then vv[q] = max(*stuff.radpres_v)
q = where(vv LT min(*stuff.radpres_v), nq) 
if (nq GT 1) then vv[q] = min(*stuff.radpres_v)

gg = interpol(*stuff.radpres_const, *stuff.radpres_v, vv)
arad = out_of_shadow * gg

n = (size(*loc.x))[1]
accel = dblarr(n,3)
accel[*,1] = arad
print, mean(gg)
stop

return, accel

end

