pro planet_dist2, taa, SystemConsts, d=distance, v=velocity, m=meananom

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Given a true anomaly angle, determine the distance and radial velocity of the planet 
;; relative to the sun.
;;
;; Outputs: distance (AU) and radial velocity (km/s)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

a = SystemConsts.aplan  ;AU		semi-major axis
eps = SystemConsts.epsplan

if (eps GT 0) then begin
  time = findgen(1001)/1000. ;; time = t/P

  ;; Mean anomaly
  M = (2*!pi*time) mod (2*!pi)

  ;; eccentric anomaly
  EEtemp = findgen(1001)/1000*2*!pi

  mm = EEtemp - eps*sin(EEtemp)
  EE = fltarr(n_elements(time))
  err = fltarr(n_elements(time))
  for i=0,n_elements(EE)-1 do ee[i] = interpol(eetemp, mm-m[i], 0)

  ;; true anomaly
  phi = (2*atan(sqrt((1+eps)/(1-eps)) * tan(EE/2)) + (2*!pi)) mod (2*!pi)
  r = a * (1-eps^2)/(1+eps*cos(phi))

  P = sqrt(a^3)
  drdt = deriv(time*!physconst.sec_year*P, r*!physconst.au/1e5)  ;; km/s

  distance = interpol(r, phi, taa)
  velocity = interpol(drdt, phi, taa)
  meananom = interpol(M, phi, taa)
endif else begin
  distance = a
  velocity = 0.
endelse

end
