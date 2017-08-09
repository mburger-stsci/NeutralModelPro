pro ImpactCheck, input, loc, hitfrac, ringfrac, deposition, tempR=tempR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Impact Check parts from driver_3.2
;;
;; Version History
;;   4.0: 1/31/2012
;;     * Created
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants
common sticking

ng = n_elements(*loc.t)
jj = replicate(1., ng)
pp = one(*stuff.which)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Did the packets hit anything?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Object positions
locmoon, input, *loc.t, x=xSat, y=ySat, z=zSat
ang = atan(-xSat, ySat)

;; Distance of packets from each object
tempR = sqrt(((*loc.x)[*,0]#pp - xSat)^2 + ((*loc.x)[*,1]#pp - ySat)^2 + $
  ((*loc.x)[*,2]#pp - zSat)^2)

;Is r < satellite radius?
eps = 0.
satrad = jj # ((*SystemConsts.radius)[*stuff.which])*(1-eps)
hhh = where((tempR-satrad) LT 0, nhits)

if (nhits NE 0) then begin
  hx = hhh mod ng  ;; packets which hit
  hy = hhh/ng      ;; objects hit
  q = where(hy GE n_elements(*stuff.which), nq) & if (nq NE 0) then stop

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Determine where packets hit surface
  if (input.sticking_info.stickcoef NE 1) then begin
    srad = satrad[hhh]
    r0 = tempR[hhh]  ;; R_plan
    x0 = (*loc.x)[hx,0]  ;; R_plan
    y0 = (*loc.x)[hx,1]  ;; R_plan
    z0 = (*loc.x)[hx,2]  ;; R_plan
    r0 = sqrt(x0^2 + y0^2 + z0^2)

    ;; Position of the satellites
    xcent = xSat[hx,hy]
    ycent = ySat[hx,hy]
    zcent = zSat[hx,hy]

    ;; Vector from center of satellite to packet
    ;;   -- packet positions relative to satellite
    x1 = (x0-xcent)/srad  ;; rsat
    y1 = (y0-ycent)/srad  ;; rsat
    z1 = (z0-zcent)/srad  ;; rsat

    ;; Velocity - orbital vel = vel relative to satellite
    ovel = (*SystemConsts.orbvel)[*stuff.which]
    vxsat = -ovel[hy]*cos(ang[hx,hy])*input.options.motion/SystemConsts.rplan
    vysat = -ovel[hy]*sin(ang[hx,hy])*input.options.motion/SystemConsts.rplan

    vx0 = (*loc.v)[hx,0] - vxsat  ;; rplan/s
    vy0 = (*loc.v)[hx,1] - vysat  ;; rplan/s
    vz0 = (*loc.v)[hx,2]  ;; rplan/s

    ;; Find where the packet hit the surface
    ;;    |x + vt| = 1 -- see ResearchNotes from 4/28/08
    a = vx0^2 + vy0^2 + vz0^2
    b = 2*(x1*vx0 + y1*vy0 + z1*vz0)
    c = x1^2 + y1^2 + z1^2 - 1

    dd = b^2 - 4*a*c 
    q = where(dd LT 0, nq) & if (nq NE 0) then stop
    t0 = (-b - sqrt(b^2-4*a*c))/(2*a)
    t1 = (-b + sqrt(b^2-4*a*c))/(2*a)
    t = (t0 LE 0)*t0 + (t1 LT 0)*t1

    ;; Point where packet hit the surface
    x2 = x1 + vx0*t
    y2 = y1 + vy0*t
    z2 = z1 + vz0*t
    ;; r2 = sqrt(x2^2 + y2^2 + z2^2)  ;; -- this should be = 1.

    lonhit = (atan(x2, -y2) + 2*!pi) mod (2*!pi)
    lathit = asin(z2)
    ;; Need to make sure these are in right coordinate frame
    if (input.geometry.planet NE 'Mercury') then stop

    ;; Put new coordinates into the array
    x_final = xcent + x2*srad 
    y_final = ycent + y2*srad 
    z_final = zcent + z2*srad

    q = where(finite(x_final) EQ 0, nq) & if (nq NE 0) then stop
    q = where(finite(y_final) EQ 0, nq) & if (nq NE 0) then stop
    q = where(finite(z_final) EQ 0, nq) & if (nq NE 0) then stop
    (*loc.x)[hx,0] = x_final
    (*loc.x)[hx,1] = y_final
    (*loc.x)[hx,2] = z_final
  endif

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Determine rebound velocity
  if (input.sticking_info.stickcoef LT 1) then begin
    vv02 = vx0^2 + vy0^2 + vz0^2  ;; rplan/s
    gm = (*SystemConsts.GM)[*stuff.which]
    PE = 2*gm[hy]*(1./r0-1./srad) 
    vv02 += PE
    q = where(vv02 LT 0, nq) & if (nq NE 0) then vv02[q] = 0.
    q = where(finite(vv02) EQ 0, nq) & if (nq NE 0) then stop

    case strlowcase(input.sticking_info.emitfn) of
      'maxwellian': begin ;; Re-emit the packets with a thermal distribution
	if (input.sticking_info.Tsurf EQ 0) then begin
	  surftemp = SurfaceTemperature(input.geometry, lonhit, lathit)
	  rr = random_nr(nhits, seed=seed, routine=0)
	  vv_new = interpolate_xy(*emit.vgrid, *emit.temperature, *emit.probability, $
	    surftemp, rr)/SystemConsts.rplan
	endif else vv_new = interpol(*emit.vrange, *emit.sumdist, $
	  random_nr(seed=seed, nhits))/SystemConsts.rplan ;; rplan/s

	vv2 = sqrt(input.Sticking_info.accom_factor*vv_new^2 + $
	  (1-input.Sticking_info.accom_factor)*vv02)
	end
      'elastic scattering': vv2 = sqrt(vv02)
    endcase

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Determine rebound angle
    angdist2 = {type:'costheta', altitude:[0,!dpi/2], azimuth:[0,2*!dpi], n:1.}
    input2 = {AngularDist:angdist2}
    output = {x0:ptr_new(x2), y0:ptr_new(y2), z0:ptr_new(z2), $
      vx0:ptr_new(vv2), vy0:ptr_new(vv2*0), vz0:ptr_new(vv2*0)}
    angular_distribution, input2, output, seed
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Rotate to proper position
    if (stuff.s EQ 0) then begin
      vx_final = *output.vx0
      vy_final = *output.vy0
      vz_final = *output.vz0
    endif else begin
      stop
    endelse

    (*loc.v)[hx,0] = vx_final
    (*loc.v)[hx,1] = vy_final
    (*loc.v)[hx,2] = vz_final
  endif

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; adjust the frac values 
  case (1) of 
    (input.sticking_info.stickcoef EQ 1): begin
      hitfrac[hx,hy] += (*loc.frac)[hx]
      (*loc.frac)[hx] = 0 ;; 100% sticking
      end
    (input.sticking_info.stickcoef GE 0): begin
      hitfrac[hx,hy] += (*loc.frac)[hx]*input.sticking_info.stickcoef
      (*loc.frac)[hx] *= (1-input.sticking_info.stickcoef)
      end
    (input.sticking_info.stickcoef EQ -1) and (input.sticking_info.Tsurf GT 0): begin
      stop ;; this is almost definitely wrong
      hitfrac[hx,hy] += (*loc.frac)[hx]*sticking_map.coef
      (*loc.frac)[hx] *= (1-sticking_map.coef)
      end 
    (input.sticking_info.stickcoef LT 0): begin
      scoef = interpolate_xy(*sticking_map.coef, *sticking_map.longitude, $
	*sticking_map.latitude, lonhit, lathit)
      hitfrac[hx,hy] = (*loc.frac)[hx]*scoef
      (*loc.frac)[hx] *= (1-scoef)
      end
    else: stop
  endcase
endif

;;q = where(hitfrac GT 0 and *loc.frac NE 0, nq) & if (nq GT 0) then stop
q = where(finite(*loc.frac) EQ 0, nq) & if (nq NE 0) then stop

end
