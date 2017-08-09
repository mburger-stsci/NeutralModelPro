function load_MASCS_data, sp, param0, param1, param2, $
  modelcoords=modelcoords, silent=silent, version=version, spectra=spectra

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; General program to load MASCS data
;; 
;; Inputs:
;;   * Species
;;   * param0 = starttime or orbit number -- orbit and phase only used for flybys
;;   * param1 = endtime or phase (observation type)
;;
;; * Radiance is returned in Rayleighs
;;
;; Version History:
;;   2013-03-12
;;     * Completely rewriting to use Aimee Merkel's summary files
;;     * Moved flyby data to load_flyby_data.pro
;;
;;   3.12: 23 Oct 2012
;;     * Adding phase option for orbital data. Phase = OBSTYPE tag in data. It doesn't 
;;        need to be exact.
;;   3.5: 19 Sept 2011
;;     * Adding orbit number option for orbital data
;;   3.4: 18 July 2011
;;     * Distinguish between Level2 and Level3 files
;;   3.0: 3 March 2011
;;     * Trying again
;;   2.0: 2 Feb 2011
;;   1.0: 4 May 2010
;;     * Created by Matthew Burger
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Intro stuff
if (silent EQ !null) then silent = 0
getspec = arg_present(spectra)
getmerk = arg_present(merkel)

defsysv, '!model', exists=e
path = !model.DataPath 

if (sp EQ !null) then begin
  if ~(silent) then print, 'data = load_MASCS_data(species, orbitnum, [phase]) or '
  if ~(silent) then print, 'data = load_MASCS_data(species, starttime, endtime)'
  return, -1
endif

;; Determine whether to switch to model coordinates or use MSO
if (modelcoords EQ !null) then modelcoords = 0

;; determine if param0 is the start time or an orbit number
type0 = size(param0, /type)

case (1) of
  (type0 EQ 2) or (type0 EQ 3): begin  ;; input is an integer orbit number 
    orbitnum = param0  ;; integer -> orbitnum
    phase = (param1 EQ !null) ? 'all' : param1
    et0 = -1
    et1 = -1
    end
  (type0 EQ 7) and ((stregex(param0, '^M', /bool)) or $
    (stregex(param0, '^Orbit', /bool))) : begin       ;; Orbit given as string
    orbitnum = orbit_number(param0)
    phase = (param1 EQ !null) ? 'all' : param1
    et0 = -1
    et1 = -1
    end
  (type0 EQ 7) and (strcmp(param0, 'NM', /fold)): begin
    orbitnum = -100
    phase = (param1 EQ !null) ? 'all' : param1
    et0 = -1
    et1 = -1
    end
  (type0 EQ 7) and (strcmp(param0, 'XM', /fold)): begin
    orbitnum = -200
    phase = (param1 EQ !null) ? 'all' : param1
    et0 = -1
    et1 = -1
    end
  (type0 EQ 7) and (strcmp(param0, 'XM2', /fold)): begin
    orbitnum = -300
    phase = (param1 EQ !null) ? 'all' : param1
    et0 = -1
    et1 = -1
    end
  (type0 EQ 7) and (strcmp(param0, 'XM3', /fold)): begin
    orbitnum = -400
    phase = (param1 EQ !null) ? 'all' : param1
    et0 = -1
    et1 = -1
    end
  (type0 EQ 7) and (strcmp(param0, 'XM4', /fold)): begin
    orbitnum = -500
    phase = (param1 EQ !null) ? 'all' : param1
    et0 = -1
    et1 = -1
    end
  (type0 EQ 7) and (utc2et(param0) NE -1): begin  ;; start and end times given as string
    print, 'This is not set up correctly.'
    stop 
    if (param1 EQ !null) then stop
    if (utc2et(param1) EQ -1) then stop
;    starttime = param0 & et0 = utc2et(starttime) 
;    endtime = param1 & et1 = utc2et(endtime)
    phase = (param2 EQ !null) ? 'all' : param2
    orbitnum = -1
    end
  (type0 EQ 5): begin ;; Start and end ET times given
    if (param1 EQ !null) then stop
    print, 'This is not set up correctly.'
    stop
;;    starttime = realtime(param0, /isoc) & et0 = param0
;;    endtime = realtime(param1, /isoc) & et1 = param1
    phase = (param2 EQ !null) ? 'all' : param2
    doflyby = 0
    orbitnum = -1
    end
  else: begin   ;; inputs entered wrong
    if ~(silent) then print, 'data = load_MASCS_data(species, orbitnum, [phase]) or '
    if ~(silent) then $
      print, 'data = load_MASCS_data(species, starttime, endtime, [phase])'
    return, -1
    end
endcase

if (n_elements(orbitnum) NE 1) then stop ;; Can only give one orbit at a time
if ((orbitnum GE -3) and (orbitnum LT 0)) then begin
  print, 'Use load_flyby_data() for flyby data.'
  return, -1
endif

case (1) of
  (orbitnum EQ -100): m = 'NM'
  (orbitnum EQ -200): m = 'XM'
  (orbitnum EQ -300): m = 'XM2'
  (orbitnum EQ -400): m = 'XM3'
  (orbitnum EQ -500): m = 'XM4'
  (orbitnum GT 0) and (orbitnum LT 800): m = 'NM'
  (orbitnum GE 800) and (orbitnum LT 1805): m = 'XM'
  (orbitnum GE 1805) and (orbitnum LT 2900): m = 'XM2'
  (orbitnum GE 2900) and (orbitnum LT 3979): m = 'XM3'
  (orbitnum GE 3979): m = 'XM4'
  else: stop
endcase

;; Find the proper summary file to use
if (version EQ !null) then begin
  dirs = file_search(!model.datapath + 'V*', count=ndir)
  versions = fix(strmid(file_basename(dirs), 1))
  g = 0
  ct = n_elements(dirs)
  while (~g) do begin
    ct--
    if (ct LT 0) then stop
    file = (file_search(dirs[ct], sp + '.*.' + m + '.sav', count=nf))[0]
    g = (nf EQ 1)
  endwhile
endif else begin
  dir = !model.datapath + 'V' + padnum(version, 4) + '/'
  file = (file_search(dir, sp + '.*.' + m + '.sav', count=nf))[0]
  if (nf NE 1) then stop
endelse
if (n_elements(file) NE 1) then stop

;; Find which points to use
ct = 0
nspec = 0
case (1) of 
  (orbitnum LT 0) and (orbitnum mod 100 EQ 0): begin
    savef = obj_new('IDL_Savefile', file)
    savef.restore, 'orb_num'
    nspec = n_elements(orb_num)
    q = lindgen(nspec)
    end
  else: begin
    savef = obj_new('IDL_Savefile', file)
    savef.restore, 'orb_num'
    q = where(orb_num EQ orbitnum, nspec)
    end
endcase

;; Extract observation type
if ~(strcmp(phase, 'all', /fold)) then begin
  savef.restore, 'obs_typ'
  q = (orbitnum LT 0) ? where(stregex(obs_typ, phase, /fold, /bool), nspec) : $
    where((orb_num EQ orbitnum) and (stregex(obs_typ, phase, /fold, /bool)), nspec)
endif

;; No data found
if (nspec EQ 0) then begin
  if ~(silent) then print, 'No data for Orbit ' + strint(orbitnum) + $
    ' and obs_type = ' + phase
  data = {species:'none'}
  return, data
endif 

print, 'Using file: ' + file

fields = ['step_utc_time', 'step_utc_time', 'true_anomaly', $
  'PLANET_SUN_VECTOR_TG', 'rad_vel', 'subsolar_longitude', 'gvals', $
  'planet_sc_vector_tg', 'MSO_ROTATION_MATRIX', $
  'BORESIGHT_UNIT_VECTOR_CENTER_TG', 'BORESIGHT_UNIT_VECTOR_C1_TG', $
  'BORESIGHT_UNIT_VECTOR_C2_TG', 'BORESIGHT_UNIT_VECTOR_C3_TG', $
  'BORESIGHT_UNIT_VECTOR_C4_TG', 'macro_num', 'obs_typ', 'obs_typ_num', 'filename', $
  'scan_num', 'obs_solar_localtime', 'TARGET_ALTITUDE_SET', 'TARGET_LATITUDE_SET', $
  'TARGET_LONGITUDE_SET', 'MINALT', 'SLIT']
savef.restore, fields

if (getspec) then begin
  fields2 = ['Dark', 'sol_fit', 'orig', 'wavelength']
  savef.restore, fields2
endif

;; Determine Time
yr = '20' + strmid(step_utc_time[q], 0, 2)
dy = strmid(step_utc_time[q], 2)
UTC = yr + '-' + dy

;; Mercyear -- need to figure out a good way to do this
mercyear = intarr(nspec)

;; Orbit number
orb_num = orb_num[q]

;; TAA (radians)
taa = true_anomaly[q] * 2*!dpi/360.

;; rmerc (AU)
rmerc = sqrt(total(PLANET_SUN_VECTOR_TG[*,q]^2, 1))/!physconst.au*1e5

;; drdt (km/s) --- Need to verify
rad_vel = rad_vel[q]

;; et = utc2et(utc)
;; drdt0 = deriv(et, rmerc)*!physconst.au/1e5

;; subslong (radians)
subslong = subsolar_longitude[q]*!dtor

;; gval
gvals = gvals[q]

;; gval check
;; rmerc2 = sqrt(total(PLANET_SUN_VECTOR_TG^2, 1))/!physconst.au*1e5
;; drdt2 = deriv(midtime, rmerc2)*!physconst.au/1e5
;; g = get_gvalue(sp, 1.)
;; gg = interpol((*g.g)[*,1], *g.v, rad_vel)/rmerc2^2
;; stop

;; radiance and sigma (kR) and quality
case (sp) of 
  'Na': begin
	savef.restore, ['Na_tot_rad_kr', 'Na_tot_rad_snr']
	radiance = Na_tot_rad_kr[q]
	sigma = radiance/Na_tot_rad_snr[q]
	SNR = Na_tot_rad_snr[q]

	if (getspec) then begin
	  savef.restore, ['Na_rad_kr', 'Na_rad_snr']
	  spec = Na_rad_kr[*,q]
	  sigspec = spec/Na_rad_snr[*,q]
	endif
	end
  'Ca': begin
	savef.restore, ['Ca_tot_rad_kr', 'Ca_tot_rad_snr']
	radiance = Ca_tot_rad_kr[q]
	sigma = radiance/Ca_tot_rad_snr[q]
	SNR = Ca_tot_rad_snr[q]

	if (getspec) then begin
	  savef.restore, ['Ca_rad_kr', 'Ca_rad_snr']
	  spec = Ca_rad_kr[*,q]
	  sigspec = spec/Ca_rad_snr[*,q]
	endif
	end
  'Mg': begin
	savef.restore, ['Mg_tot_rad_kr', 'Mg_tot_rad_snr']
	radiance = Mg_tot_rad_kr[q]
	sigma = radiance/Mg_tot_rad_snr[q]
	SNR = Mg_tot_rad_snr[q]

	if (getspec) then begin
	  savef.restore, ['Mg_rad_kr', 'Mg_rad_snr']
	  spec = Mg_rad_kr[*,q]
	  sigspec = spec/Mg_rad_snr[*,q]
	endif
	end
endcase

;; Quality: 
;;   0 = good
;;   1 = S/N LT 2
;;   2 = saturated

quality = (SNR LT 2)
if (getspec) then begin
  for i=0,nspec-1 do begin
    oo = orig[*,q[i]]
    if (max(oo) GT 0.8e5) then quality[i] = 2
  endfor
endif

;; S/C position (R_merc)
planet_sc_vector_tg = planet_sc_vector_tg[*,q]
mso_rotation_matrix = mso_rotation_matrix[*,*,q]
boresight_unit_vector_center_tg = boresight_unit_vector_center_tg[*,q]
boresight_unit_vector_c1_tg = boresight_unit_vector_c1_tg[*,q]
boresight_unit_vector_c2_tg = boresight_unit_vector_c2_tg[*,q]
boresight_unit_vector_c3_tg = boresight_unit_vector_c3_tg[*,q]
boresight_unit_vector_c4_tg = boresight_unit_vector_c4_tg[*,q]
xyz = dblarr(3,nspec)
bore = dblarr(3,nspec)
corn0 = dblarr(3,nspec)
corn1 = dblarr(3,nspec)
corn2 = dblarr(3,nspec)
corn3 = dblarr(3,nspec)
for i=0,nspec-1 do begin
  xyz[*,i] = mso_rotation_matrix[*,*,i] ## planet_sc_vector_tg[*,i]/!mercury.radius
  bore[*,i] = mso_rotation_matrix[*,*,i] ## boresight_unit_vector_center_tg[*,i]
  corn0[*,i] = mso_rotation_matrix[*,*,i] ## boresight_unit_vector_c1_tg[*,i]
  corn1[*,i] = mso_rotation_matrix[*,*,i] ## boresight_unit_vector_c2_tg[*,i]
  corn2[*,i] = mso_rotation_matrix[*,*,i] ## boresight_unit_vector_c3_tg[*,i]
  corn3[*,i] = mso_rotation_matrix[*,*,i] ## boresight_unit_vector_c4_tg[*,i]
endfor

xcorner = transpose([[reform(corn0[0,*])], [reform(corn1[0,*])], [reform(corn2[0,*])], $
  [reform(corn3[0,*])]])
ycorner = transpose([[reform(corn0[1,*])], [reform(corn1[1,*])], [reform(corn2[1,*])], $
  [reform(corn3[1,*])]])
zcorner = transpose([[reform(corn0[2,*])], [reform(corn1[2,*])], [reform(corn2[2,*])], $
  [reform(corn3[2,*])]])

;; observation info
macro_num = macro_num[q]
obs_typ = obs_typ[q]
obs_typ_num = obs_typ_num[q]
filename = filename[q]
scan_num = scan_num[q]

;; Tangent info
localtime = obs_solar_localtime[q]
alttan = TARGET_ALTITUDE_SET[*,q]
lattan = TARGET_LATITUDE_SET[*,q]*!dtor
longtan = TARGET_LONGITUDE_SET[*,q]*!dtor
minalt = minalt[q]

;; Determine mercyear
readcol, !model.basepath + 'Data/MESSENGER/merc_years.dat', yr, orb, /silent
mercyear = fix(interpol(yr, orb, orb_num))

;; Determine which slit is used
slit = slit[q]
slit2 = strarr(nspec)
w = where(slit EQ 0, comp=c)
slit2[w] = 'Surface'
slit2[c] = 'Atmospheric'

data = {species:sp, $
  ;; Time Values
  UTC:ptr_new(UTC), $
  mercyear:ptr_new(mercyear), $
  orbit:ptr_new(fix(orb_num)), $

  ;; Mercury parameters
  taa:ptr_new(taa), $
  rmerc:ptr_new(rmerc), $
  drdt:ptr_new(rad_vel), $ 
  subslong:ptr_new(subslong), $
  g:ptr_new(gvals), $
  
  ;; Radiance
  radiance:ptr_new(radiance), $
  sigma:ptr_new(sigma), $

  ;; S/C position
  x:ptr_new(reform(xyz[0,*])), $
  y:ptr_new(reform(xyz[1,*])), $
  z:ptr_new(reform(xyz[2,*])), $

  ;; Boresight center
  xbore:ptr_new(reform(bore[0,*])), $
  ybore:ptr_new(reform(bore[1,*])), $
  zbore:ptr_new(reform(bore[2,*])), $

  ;; Slit corners
  xcorner:ptr_new(xcorner), $
  ycorner:ptr_new(ycorner), $
  zcorner:ptr_new(zcorner), $

  ;; Observation information
  macro:ptr_new(macro_num), $
  obstype:ptr_new(obs_typ), $
  obstype_num:ptr_new(obs_typ_num), $
  filename:ptr_new(filename), $
  index:ptr_new(scan_num), $
  quality:ptr_new(quality), $
  
  ;;tangent point information
  xtan:ptr_new(), $
  ytan:ptr_new(), $
  ztan:ptr_new(), $
  rtan:ptr_new(), $

  alttan:ptr_new(alttan), $
  minalt:ptr_new(minalt), $
  longtan:ptr_new(longtan), $
  lattan:ptr_new(lattan), $
  loctimetan:ptr_new(localtime), $

  slit:ptr_new(slit2), $
  
  ;; Coordinate frame
  frame:'MSO'}

tanpt = tangent_point(data, alt=alt, lon=lon, lat=lat)
data.xtan = ptr_new(reform(tanpt[0,*]))
data.ytan = ptr_new(reform(tanpt[1,*]))
data.ztan = ptr_new(reform(tanpt[2,*]))
data.rtan = ptr_new(sqrt(total(tanpt^2, 1)))

;; Convert to model coordinates if necessary
if (modelcoords) then begin
  if ~(silent) then print, 'Converting from MSO to model coordinates'
  MSO_to_modelcoords, data
endif 

if (getspec) then $
  spectra = {$
    spectra:ptr_new(spec), $
    sigma:ptr_new(sigspec), $
    raw:ptr_new(orig[*,q]), $
    solar:ptr_new(sol_fit[*,q]), $
    dark:ptr_new(dark[*,q]), $
    wavelength:ptr_new(wavelength[*,q])}

obj_destroy, savef

return, data

end
