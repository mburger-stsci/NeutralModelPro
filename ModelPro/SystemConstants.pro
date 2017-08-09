pro SystemConstants, planet, SystemConsts, DipoleConsts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Version 2.0: 15 June 2010
;;   Creates the systemconsts and dipoleconsts structures from data stored 
;;   in the !Planet system variables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SystemConsts = {Planet:'', rPlan:0d, aPlan:0d, epsPlan:0d, $
  Objects:ptr_new(0), GM:ptr_new(0), radius:ptr_new(0), a:ptr_new(0), eps:ptr_new(0), $
  orbvel:ptr_new(0), period:ptr_new(0), orbrate:ptr_new(0)}

case strlowcase(planet) of 
  'sun': plan = !sun
  'mercury': plan = !Mercury
  'venus': plan = !Venus
  'earth': plan = !Earth
  'mars': plan = !Mars
  'jupiter': plan = !Jupiter
  'saturn': plan = !Saturn
  'uranus': plan = !Uranus
  'neptune': plan = !Neptune
  'pluto': plan = !Pluto
endcase

SystemConsts.planet = plan.name
SystemConsts.rplan = plan.radius
SystemConsts.aplan = plan.a
SystemConsts.epsplan = plan.e

tt = tag_names(plan)
if (total(strcmp(tt, 'satellites', /fold))) then begin
  *SystemConsts.objects = [plan.name, plan.satellites]

  nobj = n_elements(*SystemConsts.objects)
  mm = dblarr(nobj) & rr = dblarr(nobj) & tt = dblarr(nobj)
  a = dblarr(nobj) & eps = dblarr(nobj)

  mm[0] = plan.mass & rr[0] = plan.radius

  for i=1,nobj-1 do begin
    q = execute('sat = !' + plan.satellites[i-1])
    mm[i] = sat.mass   ;; mass in kg
    rr[i] = sat.radius ;; radius in km
    tt[i] = sat.orbperiod*24*3600. ;; orbital period in seconds
    a[i] = sat.a  ;; semi-major axis in km
    eps[i] = sat.e
  endfor
  *SystemConsts.GM = -!physconst.G*mm*1e3/(plan.radius*1e5)^3
  *SystemConsts.radius = rr/plan.radius  
  *SystemConsts.a = a/plan.radius
  *SystemConsts.eps = eps
  *SystemConsts.period = tt
  *SystemConsts.orbvel = [0d, 2*!dpi*a[1:*]/tt[1:*]]
  *SystemConsts.orbrate = [0d, 2*!dpi/tt[1:*]]
endif else begin
  *SystemConsts.objects = plan.name
  *SystemConsts.GM = -!physconst.G*plan.mass*1d3/(plan.radius*1d5)^3
  *SystemConsts.radius = 1d
  *SystemConsts.a = 0d
  *SystemConsts.eps = 0d
  *SystemConsts.period = 0d
  *SystemConsts.orbvel = 0d
  *SystemConsts.orbrate = 0d
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read in the dipole constants
file = !model.basepath + 'Data/PhysicalData/DipoleConstants.dat'
if ~file_test(file) then stop ;; file = (file_search('$HOME', 'DipoleConstants.dat'))[0]
readcol, /silent, file, delim=':', ob, mm, t, tdir, o, olon, olat, per, $
  format='A,D,D,D,D,D,D,D'
ob = strtrim(ob, 2)
q = (where(strcmp(planet, ob, /fold), nq))[0]
if (nq) $
  then DipoleConsts = {$
    strength:mm[q], $
    tilt:t[q]*!dtor, $
    lam3:tdir[q]*!dtor, $
    offset:o[q], $
    offlong:olon[q]*!dtor, $
    offlat:olat[q]*!dtor, $
    period:per[q], $
    magrat:2*!dpi/per[q]} $
   else DipoleConsts = -1

end
