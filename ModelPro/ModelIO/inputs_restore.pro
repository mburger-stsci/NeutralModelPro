function inputs_restore, file

;; Read in the input file as params and values
readcol, file, param, value, delim='=', format='A,A', /silent
param = strlowcase(strtrim(param, 2))

;; strip off any comments in the values
q = stregex(value, ';')
w = where(q NE -1, nq)
if (nq GT 0) then for i=0,nq-1 do $
  value[w[i]] = strmid(value[w[i]], 0, q[w[i]])
value = strtrim(value, 2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Make the geometry structure
;; Fields:
;;   planet -- required
;;   StartPoint -- required
;;   phi -- required for Jupiter and Saturn with one for each object 
;;       -- phi[0] = 0 always 
;;       -- for Mercury, the input is ignored and phi set to 0.
;;   include -- optional with one for each object 
;;           -- if not provided set to 1 for each object
;;           -- if included, must have correct number (Jup=5, Sat=10, Merc=1)
;;   CML --  replaced with SubSolarLong
;;   taa -- required for Mercury only
;;   SubSolarLong -- default = 0 deg. 
;;   SubSolLat -- default = 0 deg.
;;   aplanet ---| these are added to the structure but default value is deteremined 
;;   vrplanet --| in modeldriver.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

geom = where(strmatch(param, 'geometry*'))
gparam = strmid(param[geom], strlen('geometry.'))
gval = value[geom]

;; Choose the planet
q = (where(gparam EQ 'planet', nq))[0]
if (nq NE 1) then stop
planet = gval[q]
SystemConstants, planet, SystemConsts

;; Choose the startpoint
q = (where(gparam EQ 'startpoint', nq))[0]
startpoint = (nq EQ 1) ? gval[q] : planet

;; Determine which objects to include
;; include is 1/0 for each object. Can be on separate lines or as a comma-separated
;;   list. Must have as many entries as there are objects in the system
;; objects is a comma separated list of names of objects to include
qInc = where(gparam EQ 'include', ninc)
qObj = (where(gparam EQ 'objects', nobj))[0]
if ((nobj NE 0) and (nobj NE 1)) then stop  ;; must be either 0 or 1

nObjects = n_elements(*SystemConsts.objects)
case (1) of
  ;; Neither object nor include specified
  (nobj EQ 0) and (ninc EQ 0): $            ;; include everything
    inc = replicate(1, nObjects)

  ;; an include list of 1/0 specified
  (nobj EQ 0) and (ninc EQ 1): begin        ;; have a comma separated list of includes
    inc = fix(strsplit(gval[qInc], ',', /extract))
    if (n_elements(inc) EQ 1) then inc = replicate(inc[0], nObjects)
    if (n_elements(inc) NE nObjects) then stop
    inc = fix(inc NE 0)
    end
  (nobj EQ 0) and (ninc EQ nObjects): $     ;; have separate include line for each obj
    inc = fix(gval[qInc] NE 0)
  (nobj EQ 0): stop   ;; the include list as the wrong number of elements

  (ninc EQ 0) and (nobj EQ 1): begin      ;; have a list of objects to include
    obj = gval[qObj]
    inc = intarr(nObjects)
    for i=0,nObjects-1 do $
      inc[i] = stregex(obj, (*SystemConsts.objects)[i], /fold, /bool)
    end
  (nobj EQ 1) and (ninc EQ 1): begin        ;; have a comma separated list of includes
    inc = fix(strsplit(gval[qInc], ',', /extract))
    if (n_elements(inc) EQ 1) then inc = replicate(inc[0], nObjects)
    if (n_elements(inc) NE nObjects) then stop
    inc = fix(inc NE 0)
    end
  else: stop  ;; should not be possible to get here
endcase
if (nObjects EQ 1) then inc = inc[0]

q = (where(gparam EQ 'time', nq))[0]
if (nq EQ 1) then begin
  ;; Determine geometry based on time
  time = gval[q]
  if (utc2et(time) EQ -1) then begin
    print, 'Not a valid time'
    stop
  endif

  geometry = {planet:planet, StartPoint:StartPoint, time:time, taa:0d, $
    phi:ptr_new(0d), include:ptr_new(inc), subsolarlong:0d, subsolarlat:0d}

  determine_starting_points, geometry, SystemConsts
endif else begin
  ;; Starting positions are given
  q = (where(gparam EQ 'subsolarlong', nq))[0]
  subslong = (nq EQ 1) ? double(gval[q]) : 0d

  q = (where(gparam EQ 'subsolarlat', nq))[0]
  subslat = (nq EQ 1) ? double(gval[q]) : 0d

  q = (where(gparam EQ 'taa', nq))[0]
  taa = (nq EQ 1) ? double(gval[q]) : 0d

  ;; Phi can be a comma separated list or repeated values
  q = where(gparam EQ 'phi', nq)
  case (1) of 
    (nq EQ 0) and (nObjects EQ 1): phi = 0d
    (nq EQ 0) and (nObjects GT 1): stop
    (nq EQ nObjects): phi = double(gval[q])
    (nq EQ 1) and (nObjects GT 1): phi = double(strsplit(gval[q], ',', /extract))
    else: stop  ;; can't get here probably
  endcase
  if (n_elements(phi) NE nObjects) then stop

  geometry = {planet:planet, StartPoint:StartPoint, taa:taa, phi:ptr_new(phi), $
    include:ptr_new(inc), subsolarlong:subslong, subsolarlat:subslat}
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sticking_info
;; This is optional - if not there, assumed that everything sticks to the surface
;; fields: 
;;   * stickcoef  -- if stickcoef = 1. then there are no other options
;;   * emitfn -- options = 'Maxwellian', 'elastic scattering' 
;;   * surftemp -- if emitfn = 'Maxwellian'
;; -- will need to expand on this
st = where(strmatch(param, 'sticking_info*'), ns)
if (ns EQ 0) then stop

sparam = strmid(param[st], strlen('sticking_info.'))
sval = value[st]

q = (where(sparam EQ 'stickcoef', nq))[0]
if (nq NE 1) then stop else stick = float(sval[q])

if (stick GE 1) $
  then sticking_info = {stickcoef:1.} $
  else begin
    ;; Determine surface temperature 
    q = (where(sparam EQ 'tsurf', nq))[0]
    Tsurf = (nq EQ 1) ? max([0d, double(sval[q])]) : 0d

    ;; Determine sticking coefficient 
    q = (where(sparam EQ 'stickfn', nq))[0]
    stickfn = (nq EQ 1) ? sval[q] : ''
    case (1) of 
      (stick GE 0) and (stick LT 1): sticking = {stickcoef:stick}
      (stick EQ -1) and (stickfn EQ 'use_map'): begin
	q = (where(sparam EQ 'stick_mapfile', nq))[0]
	if (nq NE 1) then stop else stick_mapfile = sval[q]
	sticking = {stickcoef:-1, stickfn:'use_map', stick_mapfile:stick_mapfile}
	end
      (stick EQ -1) and (stickfn EQ 'linear'): begin
	q = (where(sparam EQ 'epsilon', nq))[0]
	if (nq NE 1) then stop else eps = float(sval[q])

	q = (where(sparam EQ 'n', nq))[0]
	n = (nq EQ 1) ? float(sval[q]) : 1.

	q = (where(sparam EQ 'tmin', nq))[0]
	if (nq NE 1) then stop else tmin = float(sval[q])
	sticking = {stickcoef:-1, stickfn:'linear', n:n, epsilon:eps, Tmin:tmin}
	end
      (stick EQ -1) and (stickfn EQ 'cossza'): begin
	q = (where(sparam EQ 'n', nq))[0]
	if (nq NE 1) then stop else n = float(sval[q])

	q = (where(sparam EQ 'tmin', nq))[0]
	if (nq NE 1) then stop else tmin = float(sval[q])
	sticking = {stickcoef:-1, stickfn:'cossza', n:n, Tmin:tmin}
	end
      else: stop
    endcase

    ;; Determine re-emission function
    q = (where(sparam EQ 'emitfn', nq))[0] & if (nq EQ 0) then stop
    fn = sval[q]
    case strlowcase(fn) of 
      'use_map': begin
	q = (where(sparam EQ 'accom_mapfile', nq))[0]
	if (nq NE 1) then stop else accom_mapfile = sval[q]
	sticking = {emitfn:fn, accom_mapfile:accom_mapfile}
	end
      'maxwellian': begin
	q = (where(sparam EQ 'accom_factor', nq))[0]
	if (nq EQ 1) then accom_factor = double(sval[q]) else stop
	if (accom_factor LT 0) then accom_factor = 0d
	if (accom_factor GT 1) then accom_factor = 1d

	emission = {emitfn:fn, accom_factor:accom_factor}
	end
      'elastic scattering': emission = {emitfn:fn}
      else: stop ;; not set up yet
    endcase

    ;; Put them together
    sticking_info = create_struct('Tsurf', tsurf, sticking, emission)
  endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Forces
;;  Any force not explicitly set is turned off
;;  options:
;;    * gravity
;;    * radpres
;;    * lorentz
forces = {gravity:0, radpres:0, lorentz:0}
ff = where(strmatch(param, 'forces*'), ns)
if (ns NE 0) then begin
  fparam = strmid(param[ff], strlen('forces.'))
  fval = value[ff]
  q = (where(fparam EQ 'gravity', nq))[0]
  if (nq EQ 1) then forces.gravity = fix(fval(q))
  q = (where(fparam EQ 'radpres', nq))[0]
  if (nq EQ 1) then forces.radpres = fix(fval(q))
  q = (where(fparam EQ 'lorentz', nq))[0]
  if (nq EQ 1) then forces.lorentz = fix(fval(q))
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SpatialDist
;;   * surface -- default is evenly spread out over sphere with radius=1
;;   * torus -- no default - r0,r1,r2 must be specified
spat = where(strmatch(param, 'spatialdist*'), ns)
sparam = strmid(param[spat], strlen('spatialdist.'))
sval = value[spat]
q = (where(sparam EQ 'type'))[0]
spatdist = sval[q]

case strlowcase(spatdist) of 
  'surface': begin
    q = (where(sparam EQ 'use_map', nq))[0]
    usemap = (nq EQ 1) ? fix(sval[q]) : 0

    q = (where(sparam EQ 'exobase', nq))[0]
    exobase = (nq EQ 1) ? double(sval[q]) : 1d

    if (usemap) then begin
      q = (where(sparam EQ 'mapfile'))[0]
      mapfile = sval[q]
      SpatialDist = {type:'surface', exobase:exobase, use_map:1, $
	mapfile:mapfile}
    endif else begin
      q = where(sparam EQ 'longitude0', nq)
      lon0 = (nq EQ 1) ? double(sval[q]) : 0d
      q = where(sparam EQ 'longitude1', nq)
      lon1 = (nq EQ 1) ? double(sval[q]) : 2*!dpi

      q = where(sparam EQ 'latitude0', nq)
      lat0 = (nq EQ 1) ? double(sval[q]) : -!dpi/2.
      q = where(sparam EQ 'latitude1', nq)
      lat1 = (nq EQ 1) ? double(sval[q]) : !dpi/2.

      SpatialDist = {type:'surface', exobase:exobase, use_map:0, $
	longitude:[lon0,lon1], latitude:[lat0,lat1]}
    endelse
    end
  'torus': begin 
    q = (where(sparam EQ 'torus_radius0', nq))[0]
    if (nq EQ 1) then r0 = double(sval[q]) else stop
    q = (where(sparam EQ 'torus_radius1', nq))[0]
    if (nq EQ 1) then r1 = double(sval[q]) else stop
    q = (where(sparam EQ 'torus_radius2', nq))[0]
    if (nq EQ 1) then r2 = double(sval[q]) else stop

    SpatialDist = {type:'torus', torus_radii:[r0, r1, r2]}
    end
  'exosphere': begin
    q= (where(sparam EQ 'exotype', nq))[0]
    if (nq EQ 1) then exotype = sval[q] else stop
    q = (where(sparam EQ 'b', nq))[0]
    if (nq EQ 1) then b = float(sval[q]) else stop
    q = (where(sparam EQ 'rmax', nq))[0]
    rmax = (nq EQ 1) ? sval[q] : 10.
    q = (where(sparam EQ 'block_shadow', nq))[0]
    block_shadow = (nq EQ 1) ? fix(sval[q]) : 0

    SpatialDist = {type:'exosphere', exotype:exotype, b:b, rmax:rmax, $
      block_shadow:block_shadow}
    end
  'so2 exosphere': begin
    q = (where(sparam EQ 'size', nq))[0]
    case (1) of 
      stregex(sval[q], 'large', /fold, /bool): size = 'large'
      stregex(sval[q], 'small', /fold, /bool): size = 'small'
      else: stop
    endcase 
    SpatialDist = {type:'SO2 exosphere', size:size}
    end
  'psd': begin
    q = (where(sparam EQ 'exobase', nq))[0]
    exobase = (nq EQ 1) ? double(sval[q]) : 1d

    q = (where(sparam EQ 'diffusionlimit', nq))[0]
    dlimit = (nq EQ 1) ? double(sval[q]) : 1d30 ; default = unlimited

    q = (where(sparam EQ 'kappa', nq))[0]
    kappa = (nq EQ 1) ? double(sval[q]) : 0d

    if (kappa GT 0) then begin
      q = (where(sparam EQ 'protonprecipfile', nq))[0]
      if (nq EQ 1) then ff = sval[q] else stop
    endif else ff = ''

    SpatialDist = {type:'PSD', diffusionlimit:dlimit, kappa:kappa, $
      ProtonPrecipFile:ff, exobase:exobase}
    end
  'wall': begin
    q = (where(sparam EQ 'p0', nq))[0]
    if (nq EQ 1) then p0 = double(sval[q]) else stop

    q = (where(sparam EQ 'range'))[0]
    rr = strsplit(sval[q], /extract, ',')
    range = double(rr)

    q = (where(sparam EQ 'axis', nq))[0]
    if (nq EQ 1) then ax = sval[q] else stop
    if (~strcmp(ax, 'x') and ~strcmp(ax, 'y') and ~strcmp(ax, 'z')) then stop

    SpatialDist = {type:'wall', axis:ax, p0:p0, range:range}
    end
  'box': begin
    q = where(stregex(sparam, 'xrange', /fold, /bool), nq)
    case (nq) of 
      1: xrange = double(strsplit(sval[q], /extract, ',')) 
      2: xrange = double(sval[q])
      else: stop
    endcase
    
    q = where(stregex(sparam, 'yrange', /fold, /bool), nq)
    case (nq) of 
      1: yrange = double(strsplit(sval[q], /extract, ',')) 
      2: yrange = double(sval[q])
      else: stop
    endcase
    
    q = where(stregex(sparam, 'zrange', /fold, /bool), nq)
    case (nq) of 
      1: zrange = double(strsplit(sval[q], /extract, ',')) 
      2: zrange = double(sval[q])
      else: stop
    endcase
    
    SpatialDist = {type:'box', xrange:xrange, yrange:yrange, zrange:zrange}
    end
  'inputfile': begin
    q = (where(stregex(sparam, 'file', /fold, /bool), nq))[0]
    if (nq EQ 1) then infile = sval[q] else stop
    q = (where(stregex(sparam, 'process', /fold, /bool), nq))[0]
    if (nq EQ 1) then process = sval[q] else stop  ;; keep each disc. process separate
    SpatialDist = {type:'inputfile', file:infile, process:process}
    end
  else: stop
endcase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  VelocityDist: SpeedDist and AnglularDist
;; 
vdist = where(strmatch(param, 'speeddist*'))
vparam = strmid(param[vdist], strlen('speeddist.'))
vval = value[vdist]

q = (where(vparam EQ 'type'))[0]
spd = strlowcase(vval[q])

if (stregex(spd, 'maxwellian', /fold, /bool)) then type = 'maxwellian'
case (spd) of 
  'gaussian': begin   ;; vprob, sigma
    q = (where(vparam EQ 'vprob'))[0]
    vprob = double(vval[q])
    q = (where(vparam EQ 'sigma'))[0]
    sigma = double(vval[q])
    speeddist = {type:'gaussian', vprob:vprob, sigma:sigma}
    end
  'trigaussian': begin ;; vxprob, vxsigma, vyprob, vysigma, vzprob, vzsigma
    q = (where(vparam EQ 'vxprob'))[0]
    vxprob = double(vval[q])
    q = (where(vparam EQ 'vxsigma'))[0]
    vxsigma = double(vval[q])

    q = (where(vparam EQ 'vyprob'))[0]
    vyprob = double(vval[q])
    q = (where(vparam EQ 'vysigma'))[0]
    vysigma = double(vval[q])

    q = (where(vparam EQ 'vzprob'))[0]
    vzprob = double(vval[q])
    q = (where(vparam EQ 'vzsigma'))[0]
    vzsigma = double(vval[q])

    speeddist = {type:'trigaussian', vxprob:vxprob, vxsigma:vxsigma, vyprob:vyprob, $
      vysigma:vysigma, vzprob:vzprob, vzsigma:vzsigma} 
    end
  'dolsfunction': begin  ;; dols0, dols1
    q = (where(vparam EQ 'dols0'))[0]
    dols0 = vval[q]
    q =  (where(vparam EQ 'dols1'))[0]
    dols1 = vval[q]
    speeddist = {type:'dolsfunction', dols0:dols0, dols1:dols1}
    end
  'sputtering': begin  ;; U, alpha, beta
    q = (where(vparam EQ 'u'))[0]
    U = double(vval[q])
    q = (where(vparam EQ 'alpha'))[0]
    alpha = double(vval[q])
    q = (where(vparam EQ 'beta'))[0]
    beta = double(vval[q])
    speeddist = {type:'sputtering', U:U, alpha:alpha, beta:beta}
    end
  'maxwellian': begin ;; temperature
    q = (where(vparam EQ 'temperature', nq))[0]
    if (nq EQ 0) then stop
    temp = double(vval[q])
    speeddist = {type:'maxwellian', temperature:temp}
    end
  'flat': begin  ;; vprob, delv
    q = (where(vparam EQ 'vprob'))[0]
    vprob = double(vval[q])
    q = (where(vparam EQ 'delv'))[0]
    delv = double(vval[q])
    speeddist = {type:'flat', vprob:vprob, delv:delv}
    end
  'circular orbits': speeddist = {type:'circular orbits'}  ;; no options
  'user defined': begin
    q = (where(vparam EQ 'distfile', nq))[0]
    if (nq NE 0) then distfile = vval[q] else stop
    speeddist = {type:'user defined', distfile:distfile}
    end
  'inputfile': begin
    q = (where(vparam EQ 'file', nq))[0]
    if (nq EQ 1) then infile = vval[q] else stop
    speeddist = {type:'inputfile', file:infile}
    end
  else: stop
endcase

vdist = where(strmatch(param, 'angulardist*'))
vparam = strmid(param[vdist], strlen('angulardist.'))
vval = value[vdist]

q = (where(vparam EQ 'type'))[0]
ang = strlowcase(vval[q])
if (SpeedDist.type EQ 'circular orbits') then ang = 'none'

case (ang) of  ;; none, radial, isotropic, costheta
  'none': angulardist = {type:'none'}
  'radial': angulardist = {type:'radial'}
  'isotropic': begin
    ;; For distributions starting at the surface, make sure the packets are pointed
    ;; outward
    case (SpatialDist.type) of 
      'surface': altmin = 0.
      'torus': altimin = -!dpi/2.
      'exosphere': altmin = -!dpi/2.
      'SO2 exosphere': altmin = -!dpi/2.
      'wall': altmin = -!dpi/2.
      'box': altmin = -!dpi/2.
      else: stop
    endcase

    q = where(vparam EQ 'azimuth0', nq)
    az0 = (nq EQ 1) ? double(vval[q]) : 0d
    q = where(vparam EQ 'azimuth1', nq)
    az1 = (nq EQ 1) ? double(vval[q]) : 2*!dpi

    q = where(vparam EQ 'altitude0', nq)
    alt0 = (nq EQ 1) ? double(vval[q]) : altmin
    q = where(vparam EQ 'altitude1', nq)
    alt1 = (nq EQ 1) ? double(vval[q]) : !dpi/2.

    angulardist = {type:'isotropic', azimuth:[az0, az1], altitude:[alt0, alt1]}
    end
  'costheta': begin
    q = where(vparam EQ 'azimuth0', nq)
    az0 = (nq EQ 1) ? double(vval[q]) : 0d
    q = where(vparam EQ 'azimuth1', nq)
    az1 = (nq EQ 1) ? double(vval[q]) : 2*!dpi

    q = where(vparam EQ 'altitude0', nq)
    alt0 = (nq EQ 1) ? double(vval[q]) : 0.
    q = where(vparam EQ 'altitude1', nq)
    alt1 = (nq EQ 1) ? double(vval[q]) : !dpi/2.

    q = (where(vparam EQ 'n', nq))[0]
    n = (nq EQ 1) ? double(vval[q]): 1d

    angulardist = {type:'costheta', azimuth:[az0, az1], altitude:[alt0, alt1], n:n}
    end
  'plumelike': begin
    q = where(vparam EQ 'azimuth0', nq)
    az0 = (nq EQ 1) ? double(vval[q]) : 0d
    q = where(vparam EQ 'azimuth1', nq)
    az1 = (nq EQ 1) ? double(vval[q]) : 2*!dpi

    q = where(vparam EQ 'altitude0', nq)
    alt0 = (nq EQ 1) ? double(vval[q]) : 0.
    q = where(vparam EQ 'altitude1', nq)
    alt1 = (nq EQ 1) ? double(vval[q]) : !dpi/2.

    q = (where(vparam EQ 'n', nq))[0]
    n = (nq EQ 1) ? double(vval[q]): 1d

    angulardist = {type:'plumelike', azimuth:[az0, az1], altitude:[alt0, alt1], n:n}
    end
  'vector':begin
    q = where(stregex(vparam, 'vector', /fold, /bool), nq)
    case (nq) of 
      1: vector = double(strsplit(vval[q], /extract, ',')) 
      3: vector = double(vval[q])
      else: stop
    endcase
    if (n_elements(vector) NE 3) then stop
    angulardist = {type:'vector', vector:vector}
    end
  else: stop
endcase 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PerturbVel 
pdist = where(strmatch(param, 'perturbvel*'), npert)
if (npert NE 0) then begin
  pparam = strmid(param[pdist], strlen('perturbvel.'))
  pval = value[pdist]

  q = (where(pparam EQ 'type'))[0]
  type = pval[q]

  case (type) of 
    'none': PerturbVel = {type:'none'}
    'gaussian': begin
      q = (where(pparam EQ 'vprob'))[0]
      vprob = double(pval[q])
      q = (where(pparam EQ 'sigma'))[0]
      sigma = double(pval[q])

      PerturbVel = {type:'gaussian', vprob:vprob, sigma:sigma}
      end
    'trigaussian': begin ;; vxprob, vxsigma, vyprob, vysigma, vzprob, vzsigma
      q = (where(pparam EQ 'vxprob'))[0]
      vxprob = double(pval[q])
      q = (where(pparam EQ 'vxsigma'))[0]
      vxsigma = double(pval[q])

      q = (where(pparam EQ 'vyprob'))[0]
      vyprob = double(pval[q])
      q = (where(pparam EQ 'vysigma'))[0]
      vysigma = double(pval[q])

      q = (where(pparam EQ 'vzprob'))[0]
      vzprob = double(pval[q])
      q = (where(pparam EQ 'vzsigma'))[0]
      vzsigma = double(pval[q])

      PerturbVel = {type:'trigaussian', vxprob:vxprob, vxsigma:vxsigma, vyprob:vyprob, $
	vysigma:vysigma, vzprob:vzprob, vzsigma:vzsigma} 
      end
    'charge exchange': begin ;; flowvel
      q = (where(pparam EQ 'flowvel'))[0]
      flowvel = double(pval[q])
      PerturbVel = {type:'charge exchange', flowvel:flowvel}
      end
    else: stop
  endcase
endif else PerturbVel = {type:'none'}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Plasma_info
case (planet) of 
  'Mercury': begin
    ;; Options for plasma_info.fieldmodel:
    ;;   'dipole': simple dipole field
    ;;   filename: one of Mehdi's field models
    pdist = where(strmatch(param, 'plasma*'))
    pparam = strmid(param[pdist], strlen('plasma.'))
    pval = value[pdist]

    q = (where(pparam EQ 'Bfieldmodel', nq))[0]
    Bfieldmodel = (nq EQ 1) ? pparam[q] : 'dipole'
    plasma_info = {Bfieldmodel:Bfieldmodel}
    end
  'Earth': plasma_info = {type:'none'}
  'Mars': plasma_info = {type:'none'}
  'Jupiter': begin
    ;; These are the current defaults, but need to review this.
    ;; plamsa parameters:
    ;;   eps - default = 0.14/5.7
    ;;   thermal: default = 1
    ;;   energetic: default = 1
    pdist = where(strmatch(param, 'plasma*'))
    pparam = strmid(param[pdist], strlen('plasma.'))
    pval = value[pdist]

    q = (where(pparam EQ 'eps', nq))[0]
    eps = (nq EQ 1) ? double(pval[q]) : 0.14/5.7

    q = (where(pparam EQ 'thermal', nq))[0]
    th = (nq EQ 1) ? fix(pval[q]) : 1
    q = (where(pparam EQ 'energetic', nq))[0]
    en = (nq EQ 1) ? fix(pval[q]) : 1

    q = (where(pparam EQ 'fieldmodel', nq))[0]
    fieldmodel = (nq EQ 1) ? pparam[q] : 'dipole'

    plasma_info = {eps:eps, thermal:th, energetic:en}
    end
  'Saturn': begin
    ;;   ElecDenMod: default = 1
    ;;   ElecTempMod: default = 1
    pdist = where(strmatch(param, 'plasma*'),np)
    if (np NE 0) then begin
      pparam = strmid(param[pdist], strlen('plasma.'))
      pval = value[pdist]
    endif else begin
      pparam = ''
      pval = 0.
    endelse

    q = (where(pparam EQ 'elecdenmod', nq))[0]
    denmod = (nq EQ 1) ? double(pval[q]) : 1d

    q = (where(pparam EQ 'electempmod', nq))[0]
    tmod = (nq EQ 1) ? double(pval[q]) : 1d

    plasma_info = {ElecDenMod:denmod, ElecTempMod:tmod}
    end
endcase

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Options
;;   * endtime
;;   * resolution - default = 1e-6
;;   * motion - default = 1 for Jupiter and Saturn, no effect for Mercury
;;   * lifetime - default = 0
;;   * atom 
;;   * at_once - default = 0 but reset when doing streamlines
;;   * fullsystem - default = 1 for Jupiter and Saturn, default=0 for Mercury
;;   * outeredge - if fullsystem set to 0, default = 20
;; 

odist = where(strmatch(param, 'options*'))
oparam = strmid(param[odist], strlen('options.'))
oval = value[odist]

q = (where(oparam EQ 'endtime', nq))[0]
if (nq NE 1) then stop else endtime = double(oval[q]) 

q = (where(oparam EQ 'resolution', nq))[0]
res = (nq EQ 1) ? double(oval[q]) : 1d-6

q = (where(oparam EQ 'at_once', nq))[0]
at = (nq EQ 1) ? fix(oval[q]) : 0

q = (where(oparam EQ 'atom', nq))[0]
if (nq NE 1) then stop else atom = oval[q]

q = (where(oparam EQ 'lifetime', nq))[0]
life = (nq EQ 1) ? double(oval[q]) : 0d

f = (where(oparam EQ 'fullsystem', nf))[0]
if (planet EQ 'Mercury') then begin
  full = (nf EQ 1) ? fix(oval[f]) : 0
  m = 0
endif else begin
  full = (nf EQ 1) ? fix(oval[f]) : 1

  q = (where(oparam EQ 'motion', nq))[0]
  m = (nq EQ 1) ? fix(oval[q]) : 1
endelse

if ~(full) then begin
  q = (where((oparam EQ 'outeredge'), nq))[0]
  outer = (nq EQ 1) ? double(oval[q]) : 20d
endif else outer = 0.

;;q = (where(oparam EQ 'trackloss', nq))[0]
;;trackloss = (nq EQ 1) ? fix(oval[q]) : 0

q = (where(oparam EQ 'streamlines', nq))[0]
if (nq EQ 1) then stream = fix(oval[q]) else stream = 0

if (stream) then begin
  q = (where(oparam EQ 'nsteps', nq))[0]
  nsteps = (nq EQ 1) ? long(oval[q]) : 1000L
endif else nsteps = 0L

options = {endtime:endtime, resolution:res, motion:m, lifetime:life, $
  atom:atom, at_once:at, fullsystem:full, outeredge:outer, trackloss:1, $
  streamlines:stream, nsteps:nsteps}

;; Checks on SpatialDist.type = inputfile
if ((SpatialDist.type EQ 'inputfile') xor (SpeedDist.type EQ 'inputfile')) then stop
if (SpatialDist.type EQ 'inputfile') then $
  if (SpatialDist.file NE SpeedDist.file) then stop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Put all the inputs into a single structure
input = {geometry:geometry, sticking_info:sticking_info, forces:forces, $
  spatialdist:spatialdist, angulardist:angulardist, speeddist:speeddist, $
  options:options, perturbvel:perturbvel, plasma_info:plasma_info}

return, input

end
