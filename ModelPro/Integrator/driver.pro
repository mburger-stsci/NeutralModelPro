pro driver, input, output, seed=seed, verbose=verbose

;;**************************************************************************
;;
;;  Driver routine to run the 5th order RK integrator from Numerical 
;;  Recipies, 3rd Ed.
;;
;;  Version History:
;;   3.4  7/31/2012
;;     -- Found error that occurs when lifetime << timestep. Fixed errmax to look
;;        at loc.frac and compute frac more precisely.
;;   3.3  1/31/2012
;;     -- Adding more flexible sticking coefficient
;;   3.2: 12/12/2011
;;     -- Added which to stuff structure
;;   3.1: 4/27/2011
;;     -- Need to speed up when modeling satellites
;;   3.0: 7/20/2010
;;     -- Revising for new structure architecture
;;   2.7: 7/6/2010:
;;     -- Adding impact_check_2.9 to this program so it does not use the include
;;   2.6: 4/26/2010:
;;     -- Added moon's temperature map
;;     -- removed thermalized option from emitfn case (no longer used)
;;   2.5: 1/14/2010:
;;     -- Keep track of fate of each packet
;;     -- Keep track of deposition on the surface
;;     -- Replace ptr_free with destory_structure
;;   2.4: 12/7/2009
;;     -- Allowing variable surface temperature for Maxwellian reemission
;;   2.3: 11/6/2009
;;     -- changing the way it does the thermalization. New velocity is determined from
;;         partial accomodation to thermal speed at surface
;;   2.2: Added variable surface temperature for particle sticking (for Mercury, 
;;     Based on surface temperature in Leblanc & Johnson 2003). -- I don't think I 
;;     did this [12/7/09]
;;   2.1: Added support for elastic bouncing of particles from the surface
;;   2.0: Revised for current structure setup
;;   1.2: Previous working version
;;   1.1: Older version to work with rk4
;;   1.0: Similar to the original version to work with rk7
;; 
;; Impact_check version history (before inclusion into this program):
;;   Version 2.9 4/28/10
;;      -- Changing definition of accommodation coefficient
;;         * Need energy accommodation rather than velocity accommodation
;;         * Before: v_1 = a v_th + (1-a) v_0
;;         * After: v_1^2 = a v_th^2 + (1-a) v_0^2
;;   Version 2.8 3/9/10
;;      -- Fixing issue with thermal accomodation - Now choose speed based on 
;;     thermal distribution.
;;   Version 2.7 1/19/10
;;      -- fixing some problems with v2.6
;;   Version 2.6 1/14/2010
;;      -- keep track of what happens to each packet
;;      -- keep track of surface deposition
;;           * doesn't get the map right for satellites.
;;   Version 2.4 11/6/2009
;;      -- added thermal accomodation to the surface 
;;   Version 2.1 -- added option for elastic bouncing
;;
;;***************************************************************

common constants
common sticking

if (verbose EQ !null) then verbose = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remake the loc structure to speed up the math and make it easier to read
loc = {t:ptr_new(0), x:ptr_new(0), v:ptr_new(0), frac:ptr_new(0)}
;;  lossfrac:ptr_new(0), hitfrac:ptr_new(0), ringfrac:ptr_new(0)} 
*loc.x = [[*output.x], [*output.y], [*output.z]]
*loc.v = [[*output.vx], [*output.vy], [*output.vz]]
*loc.frac = *output.frac
*loc.t = *output.time ;; This is how much time before present and works up to zero
npack = n_elements(*output.x)

lossfrac = dblarr(npack)
hitfrac = dblarr(npack,n_elements(*SystemConsts.objects))
ringfrac = dblarr(npack)
leftfrac = dblarr(npack)
deposition = {longitude:ptr_new(findgen(360)*!dtor), $
  latitude:ptr_new(findgen(180)*!dtor-!pi/2), $
  map:ptr_new(dblarr(360,180,n_elements(*SystemConsts.objects)))}
ilon = findgen(360)
ilat = findgen(180)

;; Set up the stepsizes
h = replicate(1000d, npack)	;initial guess at best stepsize
hold = h  ;; last step used by each packet

;Set variables in preparation for iteration
count = 0L  ;; number of steps taken

;These control how quickly the stepsize is increased or decreased between iterations
safety = .95
shrink = -.25
grow = -.2

;; yscale = scaling parameter for each variable
;;   x,y,z ~ R_plan
;;   vx,vy,vz ~ 1 km/s (1/Rplan Rplan/s)
;;   frac ~ exp(-t/lifetime) ~ mean(frac)

resolution = input.options.resolution

;; A check
if (input.sticking_info.stickcoef EQ -1) then $
  if (input.sticking_info.Tsurf GT 0) then $
    if (n_elements(sticking_map.coef) NE 1) then stop

;******************************************************************************
;Keep takeing R.K. steps until every packet has reached the time of "image taken"
;******************************************************************************

moretogo = where((*loc.t GT resolution) and (*loc.frac GT 0), ntogo, comp=w)
if (w[0] NE -1) then (*loc.t)[w] = 0.
done = (ntogo EQ 0)

if ((max(*loc.frac) GT 1.) or (min(*loc.frac) LT 0.)) then stop
while ~(done) do begin
;;  if ((max(*loc.frac) GT 1.) or (min(*loc.frac) LT 0.)) then stop
  ;Now generate sub-arrays containing only the particles that are still being tracked

  loc0 = {t: ptr_new((*loc.t)[moretogo]), x:ptr_new((*loc.x)[moretogo,*]), $
    v:ptr_new((*loc.v)[moretogo,*]), frac:ptr_new((*loc.frac)[moretogo])}

  w = where(*loc0.frac EQ 0, nw) & if (nw NE 0) then stop
  w = where(finite(*loc0.x) EQ 0, nw) & if (nw NE 0) then stop
  w = where(finite(*loc0.v) EQ 0, nw) & if (nw NE 0) then stop

  oldx = *loc0.x  ;; This is used for determining if anything hit the rings
  oldf = *loc0.frac
  h = hold[moretogo]

  ;Adjust stepsize to be no more than time remaining
  h = (h LE (*loc0.t))*h + (h GT (*loc0.t))*(*loc0.t)

  ;; Run the rk5 step
  rk5, loc0, h, input, delta

  ;; Do the error check
  ;; scale = a_tol + |y| * r_tol
  ;;   for x: a_tol = r_tol = resolution
  ;;   for v: a_tol = r_tol = resoltuon/10. -- require v to be more precise
  ;;   for f: a_tol = 0.01 ; r_tol = 0 -- set fractional tolerance to 1%
  scalespace = resolution + abs(*loc0.x) * resolution
  scalevel = 0.1*(resolution + abs(*loc0.v) * resolution)
  scaleabund = (resolution + abs(*loc0.frac) * resolution)

  ;; difference relative to acceptable difference
  *delta.x /= scalespace
  *delta.v /= scalevel
  *delta.frac /= scaleabund
  xerrmax = max(*delta.x, dim=2)
  verrmax = max(*delta.v, dim=2)
  
  ;; Maximum error for each packet
  errmax = (xerrmax GE verrmax)*xerrmax + (xerrmax LT verrmax)*verrmax
  errmax = (errmax GE *delta.frac)*errmax + (errmax LT *delta.frac)**delta.frac

  q = where(finite(errmax) EQ 0, nq) & if (nq NE 0) then stop
  q = where((*loc0.frac LT 0) and (errmax LT 1), nq) & if (nq GT 0) then stop
  q = where((*loc0.frac-oldf GT scaleabund[q]) and (errmax LE 1), nq) 
  if (nq GT 0) then begin
    print, strint(nq) + ' have frac > oldf. Adjusting errmax.'
    errmax[q] = 1.1
;    stop
  endif

  ;; Check where difference is very small - adjust step size
  noerr = where(errmax LE 1e-7)
  if (noerr[0] NE -1) then begin
    errmax[noerr] = 1.
    h[noerr] = h[noerr]*10.
  endif

  ;; Put the post-step values
  g = where(errmax LE 1.0, ng, comp=b)
  if (ng GT 0) then begin
    (*loc.t)[moretogo[g]] = (*loc0.t)[g]
    (*loc.x)[moretogo[g],*] = (*loc0.x)[g,*] 
    (*loc.v)[moretogo[g],*] = (*loc0.v)[g,*] 
    (*loc.frac)[moretogo[g]] = (*loc0.frac)[g] 
    lossfrac[moretogo[g]] += (oldf[g]-(*loc0.frac)[g])  ;; add in change in frac
    h[g] = safety*h[g]*errmax[g]^grow
  endif 

  if (ng NE ntogo) then begin
    ;; don't adjust the bad values, but do fix the stepsize
    htemp = safety * h[b] * errmax[b]^shrink
    q = where(htemp LT 0.0, nq) & if (nq NE 0) then stop

    ;; don't let step size drop below 1/10th previous step size
    h[b] = max([[htemp], [0.1*h[b]]], dim=2)
  endif
  qqq = where(h LT 1e-7, nqq) & if (nqq NE 0) then stop  ;; error test

  destroy_structure, loc0
  destroy_structure, delta

  ;save new values of h
  hold[moretogo] = h

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Impact check
  ;; Only look at packets which moved during this step
  if (ng GT 0) then begin 
    ;; Make a new structure with just the packets that moved this step
    loc1 = {t:ptr_new((*loc.t)[moretogo[g]]), x:ptr_new((*loc.x)[moretogo[g],*]), $
      v:ptr_new((*loc.v)[moretogo[g],*]), frac:ptr_new((*loc.frac)[moretogo[g],*])}
    
    oldfrac = *loc1.frac
    hitfrac1 = hitfrac[moretogo[g],*]
    ringfrac1 = ringfrac[moretogo[g]]
    leftfrac1 = leftfrac[moretogo[g]]

    ;; Check for surface impacts
    ImpactCheck, input, loc1, hitfrac1, ringfrac1, deposition, tempR=tempR

    ;; Check for escape 
    if ~(input.options.fullSystem) then EscapeCheck, input, loc1, tempR, leftfrac1

    ;; If Saturn, then check to see if anything hit the rings
    if (input.geometry.planet EQ 'Saturn') then RingCheck, input, loc1, oldx[g,*], $
      RingFrac1

    ;; Check to see if any packets have shrunk out of existence
;;    q = where((*loc1.frac GT 0) and (*loc1.frac LT 1e-10), nq)
    q = where((*loc1.frac GT -1e-7) and (*loc1.frac LT 1e-10), nq)
    if (nq NE 0) then (*loc1.frac)[q] = 0.
    q = where(*loc1.frac LT 0, nq) & if (nq GT 0) then stop

    ;; If any new hits, set the time remaining to 0.
    w = where(*loc1.frac EQ 0, nw)
    if (nw NE 0) then (*loc1.t)[w] = 0.

    ;Put new values back into original array (again)
    (*loc.t)[moretogo[g]] = *loc1.t
    (*loc.x)[moretogo[g],*] = *loc1.x
    (*loc.v)[moretogo[g],*] = *loc1.v
    (*loc.frac)[moretogo[g]] = *loc1.frac
    hitfrac[moretogo[g],*] = hitfrac1
    ringfrac[moretogo[g]] = ringfrac1
    leftfrac[moretogo[g]] = leftfrac1
    destroy_structure, loc1
  endif
  ;;end impact check
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  moretogo = where(*loc.t GT resolution, ntogo)  ;; check to see which ones aren't done
  if (verbose) and (count mod 100 EQ 0) then $
    print, stuff.strstart + 'Step Number: ' + string(count) + $
    ', Packets Remaining: ' + string(ntogo)
  count += 1 ;; step counter

  ;If it goes 100000 steps then it will never stop!
  done = ((ntogo EQ 0) or (count GT 100000.)) 
endwhile

*output.x = reform((*loc.x)[*,0])
*output.y = reform((*loc.x)[*,1])
*output.z = reform((*loc.x)[*,2])
*output.vx = reform((*loc.v)[*,0])
*output.vy = reform((*loc.v)[*,1])
*output.vz = reform((*loc.v)[*,2])
*output.frac = *loc.frac
*output.index = lindgen(n_elements(*output.x))
*output.hitfrac = reform(hitfrac)
*output.lossfrac = lossfrac
*output.ringfrac = ringfrac
*output.leftfrac = leftfrac
output.deposition = deposition

destroy_structure, loc

end

