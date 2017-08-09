function load_MASCS_data, sp, param0, modelcoords=modelcoords

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Load the MASCS flyby data
;; 
;; Inputs:
;;   * Species
;;   * param0 = starttime or orbit number -- orbit and phase only used for flybys
;;   * param1 = endtime or phase (observation type)
;;
;; * for flybys, orbits M1=-1, M2=-2, M3=-3 
;; * Radiance is returned in Rayleighs
;; * Terminator data from M2 is bad -- need to get new files.
;;
;; Version History:
;;   2013-03-12
;;     * Separated out the flyby observations
;;     * Completely rewriting to use Aimee Merkel's summary files
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
  if ~(silent) then print, 'data = load_flyby_data(species, orbitnum, [phase]) or '
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
    end
  (type0 EQ 7) and ((stregex(param0, '^M', /bool)): begin  ;; Orbit given as string
    orbitnum = orbit_number(param0)
    phase = (param1 EQ !null) ? 'all' : param1
    end
  else: begin   ;; inputs entered wrong
    if ~(silent) then print, 'data = load_flyby_data(species, orbitnum, [phase])'
    return, -1
    end
endcase

;; Load the data
if (n_elements(orbitnum) NE 1) then stop ;; Can only give one orbit at a time
if (orbitnum GT 0) then stop  ;; Must be -1, -2, or -3
path = !model.DataPath + 'MASCS/Level2/' 

case (1) of
  ((orbitnum EQ -1) or (orbitnum EQ -2)): begin
    ;; Load the files from M1 or M2
    ostring = (orbitnum EQ -1) ? 'M1' : 'M2'

    files = file_search(path + ostring + '/' + ostring + '.' + sp + '*.sav')
    if (files[0] EQ '') then stop

    if (phase NE 'all') then begin
      q = (where(stregex(files, phase, /fold, /bool), nq))[0]
      if (nq NE 1) then stop
      files = files[q]
      if ~(silent) then print, 'Loading Data File: ', files
      restore, files
    endif else begin
      restore, files[0]
      datatemp = temporary(data)
      for i=1,n_elements(files)-1 do begin
	if ~(silent) then print, 'Loading Data File: ', files[i]
	restore, files[i]
	*datatemp.et = [*datatemp.et, *data.et]
	*datatemp.phase = [*datatemp.phase, *data.phase]
	*datatemp.radiance = [*datatemp.radiance, *data.radiance]
	*datatemp.sigma = [*datatemp.sigma, *data.sigma]
	*datatemp.x = [*datatemp.x, *data.x]
	*datatemp.y = [*datatemp.y, *data.y]
	*datatemp.z = [*datatemp.z, *data.z]
	*datatemp.xbore = [*datatemp.xbore, *data.xbore]
	*datatemp.ybore = [*datatemp.ybore, *data.ybore]
	*datatemp.zbore = [*datatemp.zbore, *data.zbore]
	data = 0.
      endfor
      data = temporary(datatemp)

      ;; resort the data to make sure it is chronological
      data_subset, data, sort(*data.et)
    endelse
    end
  (orbitnum EQ -3): begin
    ;; Load the files from M3
    files = file_search(path + 'M3/M3.' + sp + '*.sav')
    if (n_elements(files) NE 1) then stop
    if ~(silent) then print, 'Loading Data File: ', files
    restore, files
    if ~(strcmp(phase, 'all', /fold)) then begin
      readcol, !model.datapath + 'phase_table.dat', o, p, ut0, ut1, skip=1, delim='*', $
	format='I,A,A,A', /silent
      p = strtrim(p, 2) & ut0 = strtrim(ut0, 2) & ut1 = strtrim(ut1, 2)
      q = where(o EQ -3)
      p = p[q] & ut0=ut0[q] & ut1=ut1[q]
      et0 = utc2et(ut0) & et1 = utc2et(ut1)
      
      q = where(stregex(p, phase, /fold, /bool), nq)
      if (nq EQ 0) then stop
      w = !null
      for i=0,nq-1 do begin
	if ~(silent) then print, 'load_flyby_data: extracting M3, phase ' + p[q[i]]
	w = [w,where((*data.et GE et0[q[i]]) and (*data.et LE et1[q[i]]), nw)]
      endfor
      w = w[sort(w)]
      data_subset, data, w
    endif
    end
  else: stop
endcase

;; Add frame to the structure
data = create_struct('frame', 'MSO', data)

if (modelcoords) then begin
  if ~(silent) then print, 'Converting from MSO to model coordinates'
  MSO_to_modelcoords, data
endif

return, data

end
