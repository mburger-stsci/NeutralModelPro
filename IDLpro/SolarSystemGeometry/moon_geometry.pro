function moon_geometry, time, moon

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Given a time, determine:
;;   orbital phase
;;   sub-solar longitude
;;   sub-solar latitude
;;   distance from planet
;;   distance from sun
;;   radial velocity relative to sun
;;   orbital speed
;;
;; Note -- assumes tidally locked for the moment.
;; tested 4/29/2014
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

q = execute('moonconst = !' + moon)
if (q EQ 0) then stop

q = execute('planconst = !' + moonconst.orbits)
if (q EQ 0) then stop

et = (size(time, /type) EQ 7) ? utc2et(time) : time
net = n_elements(et)

phi = dblarr(net) & subslong = dblarr(net) & subslat = dblarr(net)
radius = dblarr(net) & r = dblarr(net) & drdt = dblarr(net) & orbspd = dblarr(net)

frame0 = 'IAU_' + moon

relative_position, moon, moonconst.orbits, et, frame=frame0, position=xx0, velocity=vv0
relative_position, moon, 'Sun', et, frame=frame0, position=xx1, velocity=vv1

xx0 /= planconst.radius
xx1 *= 1e5/!physconst.au

if (net EQ 1) then begin
  rsun = sqrt(total(xx1^2))
  drdtsun = total(xx1*vv1)/rsun

  rplan = sqrt(total(xx0^2))
  vorb = sqrt(total(vv0^2))

  lon = (atan(xx1[1], -xx1[0])+2*!pi) mod (2*!pi)
  lat = asin(-xx1[2]/rsun)

endif else begin
  rsun = sqrt(total(xx1^2, 1))
  drdtsun = total(xx1*vv1, 1)/rsun

  rplan = sqrt(total(xx0^2, 1))
  vorb = sqrt(total(vv0^2, 1))

  lon = reform((atan(xx1[1,*], -xx1[0,*])+2*!pi) mod (2*!pi)) 
  lat = reform(asin(-xx1[2,*]/rsun))
endelse

geometry = {et:ptr_new(et), phi:ptr_new(lon), subslong:ptr_new(lon), $
  subslat:ptr_new(lat), rsun:ptr_new(rsun), drdtsun:ptr_new(drdtsun), $
  rplan:ptr_new(rplan), orbvel:ptr_new(vorb)}

return, geometry

end

