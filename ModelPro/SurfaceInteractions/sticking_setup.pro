pro sticking_setup, input

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Set up things for dealing with surface sticking
;;
;; Things to consider:
;;   * Variable stick coefficeint
;;   * Variable thermal accommodation
;;   * Reemission function
;;
;; Version History
;;   4.0 -- 1/31/2012
;;     * Created based on Integrator/driver_3.2.pro
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants
common sticking

longitude = dindgen(361)*!dtor
latitude = dindgen(181)*!dtor - !dpi/2
;; Determine surface temperature
if (input.sticking_info.Tsurf EQ 0) then $
  Tsurf = SurfaceTemperature(input.geometry, longitude, latitude, /grid)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set up stickcoef -- make a map of stick_coef at each point on the surface
case (1) of 
  (input.sticking_info.stickcoef EQ -1): begin
    case strlowcase(input.sticking_info.stickfn) of 
      'use_map': restore, input.sticking_info.stick_mapfile
      'linear': begin
	if (input.sticking_info.Tsurf EQ 0) then begin
	  coef = 1 - input.sticking_info.epsilon * Tsurf
	  coef *= (coef GT 0)

	  q = where(Tsurf LE input.sticking_info.Tmin, nq)
	  if (nq GT 0) then coef[q] = 1.

	  q = where((coef LT 0) or (coef GT 1), nq) & if (nq NE 0) then stop
	  sticking_map = {longitude:ptr_new(longitude), latitude:ptr_new(latitude), $
	    coef:ptr_new(coef)}
	endif else begin
	  ;; Use a constant surface temperature and sticking coef
	  coef = (input.sticking_info.Tsurf GT input.sticking_info.tmin) ? $
	    1. - input.sticking_info.epsilon * input.sticking_info.Tsurf : 1.
	  coef *= (coef GT 0)
	  sticking_map = {coef:coef}
	endelse
	end
      'cossza': begin
	coef = 1 - (cos(longitude)#cos(latitude))^input.sticking_info.n
	coef *= (coef GT 0)

	q = where(Tsurf LE input.sticking_info.Tmin, nq)
	if (nq GT 0) then coef[q] = 1.

	q = where(coef GT 1, nq)
	if (nq GT 0) then $
	  if (max(coef[q]-1) GT 0.01) $
	    then stop $
	    else coef[q] = 1.

	q = where((coef LT 0) or (coef GT 1), nq) & if (nq NE 0) then stop
	q = where(finite(coef) EQ 0, nq) & if (nq NE 0) then stop
	sticking_map = {longitude:ptr_new(longitude), latitude:ptr_new(latitude), $
	  coef:ptr_new(coef)}
	end
      else: stop
    endcase
    end
  (input.sticking_info.stickcoef LT 0): begin
    coef = replicate(abs(input.sticking_info.stickcoef), n_elements(longitude), $
      n_elements(latitude))
    q = where((longitude GT !pi/2) and (longitude LT 3*!pi/2))
    coef[q,*] = 1.
    sticking_map = {longitude:ptr_new(longitude), latitude:ptr_new(latitude), $
      coef:ptr_new(coef)}
    end
  else: sticking_map = {coef:input.sticking_info.stickcoef} ;; 0 < stickcoef < 1
endcase


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set up reemission function
case strlowcase(input.sticking_info.emitfn) of 
  'maxwellian': begin
    if (input.sticking_info.tsurf EQ 0) then begin
      nt = 21 & & nv = 101 & nprob = 101
      temperature = dindgen(nt)/(nt-1)*(max(Tsurf)-min(Tsurf)) + min(Tsurf)
      v_temp = sqrt(2*temperature*!physconst.kb/atomicmass(input.options.atom)) /1e5
      prob = dindgen(nprob)/(nprob-1)
      vgrid = dblarr(nt,nprob)
      for i=0,nt-1 do begin
	vrange = dindgen(nv)/(nv-1)*v_temp[i]*3.
	f_v = MaxwellianDist(vrange, temperature[i], input.options.atom)
	sumdist = f_v
	for j=1,nv-1 do sumdist[j] += sumdist[j-1]
	sumdist /= max(sumdist)
	vgrid[i,*] = interpol(vrange, sumdist, prob)
      endfor
      ;; vgrid is velocity as function of temperature and probability
      emit = {vgrid:ptr_new(vgrid), temperature:ptr_new(temperature), $
	probability:ptr_new(prob)}
    endif else begin   ;; use constant surf temp
      v_th = sqrt(2*input.Sticking_info.Tsurf*$
	!physconst.kb/atomicmass(input.options.atom)) /1e5
      vrange = findgen(1001)/1000 * v_th*5 & vrange = vrange[1:*]
      f_v = MaxwellianDist(vrange, input.Sticking_info.Tsurf, options.atom)
      
      sumdist = f_v
      for i=1,n_elements(vrange)-1 do sumdist[i] += sumdist[i-1]
      sumdist /= max(sumdist)
      emit = {vrange:ptr_new(vrange), sumdist:ptr_new(sumdist)}
    endelse
    end
  'elastic scattering':
  else: stop
endcase

end
