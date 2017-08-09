function planet_geometry, time, planet

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Given a time and an object, determine some basic geometry info
;; from the SPICE kernels
;; 
;; For planets:
;;   * r in AU
;;   * drdt in km/s
;;   * TAA in radians
;;   * Sub-solar longitude and latitude in radians
;;   * Sub-earth longitude and latitude in radians
;;
;; Returns a structure with this information
;; 
;; 4/29/2014 -- Made a comparison with HORIZONS. Matches all values, although with the
;; caveat that the light travel time needs to be accounted for correctly. -- assummes 
;; light travel time from planet to sun. For the most part this doesn't matter, but does 
;; make a difference for rapid rotators (e.g., Jupiter)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

et = (size(time, /type) EQ 7) ? utc2et(time) : time

pnum = naif_ids(planet)
snum = naif_ids('sun')

;; Determine planet location relative to sun
case (planet) of 
  'Mercury': begin
    frame0 = 'MSGR_MSO'
    frame1 = 'IAU_MERCURY'
    end
  'Jupiter': begin
    frame0 = 'Jupiter_Equatorial_Frame'
    frame1 = 'IAU_JUPITER'
    end
  'Saturn': begin
    frame0 = 'Saturn_Equatorial_Frame'
    frame1 = 'IAU_SATURN'
    end
  else: stop
endcase

systemconstants, planet, Sysconst

relative_position, planet, 'Sun', et, frame=frame0, position=x0, velocity=v0
relative_position, planet, 'Sun', et, frame=frame1, position=x1, velocity=v1
relative_position, planet, 'Sun', et, frame='J2000', position=x2, velocity=v2

relative_position, planet, 'Earth', et, frame=frame0, position=e0, velocity=ve0
relative_position, planet, 'Earth', et, frame=frame1, position=e1, velocity=ve1

nt = n_elements(time)

;; Compute TAA
mu = (!sun.mass*1e3)*!physconst.G ;; cm^3 s^-2
taa = fltarr(nt)
for i=0,nt-1 do begin
  xx = reform(x2[*,i]*1e5) & vv = reform(v2[*,i]*1e5)

  ;; r and drdt from sun
  rr = sqrt(total(xx^2))
  drdt = total(xx*vv)/rr

  ;;;;;;;;
  ;; Eccentricity vector
  e = total(vv*vv)*xx/mu - total(xx*vv)*vv/mu - xx/rr
  ee = sqrt(total(e*e))
  taa[i] = acos(total(e*xx)/ee/rr)
  if (total(xx*vv) LT 0) then taa[i] = 2*!pi-taa[i]
endfor

;; Compute distance from Sun
x0 = x0*1e5/!physconst.au
x1 = x1*1e5/!physconst.au

if (nt EQ 1) then begin
  taa = taa[0] 

  r0 = sqrt(total(x0^2))
  r1 = sqrt(total(x1^2))
  if (abs(r0-r1) GT 1e-6) then stop

  ;; Compute radial velocity relative to Sun
  drdt0 = total(x0*v0)/r0
  drdt1 = total(x1*v1)/r1

  ;; Compute subsolar longitude and latitude
  lat = -sin(x1[2]/r1)
  lon = (atan(x1[1], -x1[0])+2*!pi) mod (2*!pi) ;; this increases with time - agrees with 
    						;; Horizons

  ;; Compute subearth longitude and latitude
  re0 = sqrt(total(e0^2))
  re = sqrt(total(e1^2))

  lat_e = -sin(e1[2]/re)
  lon_e = (atan(e1[1], -e1[0])+2*!pi) mod (2*!pi)

;;  ;; compute phase ange
;;  phase0 = acos(total(x0*e0)/r0/re0)
;;  phase1 = acos(total(x1*e1)/r1/re1)
;;  stop
endif else begin
  r0 = sqrt(total(x0^2, 1))
  r1 = sqrt(total(x1^2, 1))
  if (max(abs(r0-r1)) GT 1e-6) then stop

  drdt0 = total(x0*v0, 1)/r0
  lat = -sin(reform(x1[2,*])/r1)
  lon = (atan(reform(x1[1,*]), -reform(x1[0,*]))+2*!pi) mod (2*!pi)

  re = sqrt(total(e1^2, 1))
  lat_e = -sin(reform(e1[2,*])/re)
  lon_e = (atan(reform(e1[1,*]), -reform(e1[0,*]))+2*!pi) mod (2*!pi)
endelse

;; compute angular diameter seen from Earth
diam = 2*sysconst.rplan/re/!dtor*3600.

geometry = {et:ptr_new(et), r:ptr_new(r0), drdt:ptr_new(drdt0), taa:ptr_new(taa), $
  subslong:ptr_new(lon), subslat:ptr_new(lat), subelong:ptr_new(lon_e), $
  subelat:ptr_new(lat_e), angdiam:ptr_new(diam)}

return, geometry

end
