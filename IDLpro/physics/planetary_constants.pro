pro planetary_constants

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;  Define planetary constants systemc variables
;;  Data is stored in PlanetaryConstants.dat
;;
;; Columns in the data file:
;;   Planet: central body of the system
;;   rPlan: Planet radius (km)
;;   aPlan: PLanetary semi-major axis (AU)
;;   epsPlan: Planetary eccentricity
;;   Objects: list of all objects that can be included.  Planet is first, then moons
;;   GM: G*M for each object (rPlan^3/s^2)
;;   radius: object radius (Rplan)
;;   a: semi-major axis (Rplan)
;;   eps: eccentricity
;;   vSat: orbital velocity (km/s)
;;   period: seconds
;;   orbrate: 2*!pi/period
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

defsysv, '!model', exists=e

if (e) $
  then file = !model.basepath + 'Data/PhysicalData/PlanetaryConstants.dat' $
  else file = '/Users/mburger/Work/Research/ModelPro/ModelPro/Data/PhysicalData/PlanetaryConstants.dat'
if ~(file_test(file)) then stop

readcol, file, /silent, skip=5, delim=':', $
  object, orbits, radius, mass, a, ecc, tilt, trot, torb, format='A,A,D,D,D,D,D,D,D'
object = strtrim(object, 2)
orbits = strtrim(orbits, 2)

for i=0,n_elements(object)-1 do begin
  varname = '!' + object[i]
  defsysv, varname, exists=e
  if ~(e) then begin
    o = where(strcmp(orbits, object[i]), nq)
    if (nq EQ 1) then o = o[0]
    print, 'Defining system variable ' + varname
    if (nq GT 0) $
      then defsysv, varname, $
	{name:object[i], $
	 orbits:orbits[i], $
	 radius:radius[i], $
	 mass:mass[i], $
	 a:a[i], $
	 e:ecc[i], $
	 tilt:tilt[i], $
	 rotperiod:trot[i], $
	 orbperiod:torb[i], $
	 satellites:object[o], $
	 units:'radius (km), mass (kg), rotperiod (hrs), rplanet (km), mplanet (kg), ' + $
	   'aplanet (AU), orbplanet (day), rotplanet (hr)'} $
      else defsysv, varname, $
	{name:object[i], $
	 orbits:orbits[i], $
	 radius:radius[i], $
	 mass:mass[i], $
	 a:a[i], $
	 e:ecc[i], $
	 tilt:tilt[i], $
	 rotperiod:trot[i], $
	 orbperiod:torb[i], $
	 units:'radius (km), mass (kg), rotperiod (hrs), rplanet (km), mplanet (kg), ' + $
	   'aplanet (AU), orbplanet (day), rotplanet (hr)'}
  endif
endfor

end
