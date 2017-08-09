pro stream_driver, input, output, seed=seed, showplot=showplot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Steps packets through the rk stepper with constant step size and
;; saves the results from each step
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants
common sticking

if (showplot EQ !null) then showplot = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remake the loc structure to speed up the math and make it easier to read
loc = {t:ptr_new(0), x:ptr_new(0), v:ptr_new(0), frac:ptr_new(0)} 
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

;; A check
if (input.sticking_info.stickcoef EQ -1) then $
  if (input.sticking_info.Tsurf GT 0) then $
    if (n_elements(sticking_map.coef) NE 1) then stop

;Set output variables
dt = double(input.options.endtime)/double(input.options.nsteps-2)
xx0 = dblarr(npack,3,input.options.nsteps)
vv0 = dblarr(npack,3,input.options.nsteps)
ff0 = dblarr(npack,input.options.nsteps)
tt0 = dblarr(npack,input.options.nsteps)

lossfrac0 = dblarr(npack,input.options.nsteps)
ringfrac0 = dblarr(npack,input.options.nsteps)
hitfrac0 = dblarr(npack,n_elements(*SystemConsts.objects),input.options.nsteps)
leftfrac0 = dblarr(npack,input.options.nsteps)

;; Store initial values
xx0[*,*,0] = *loc.x
vv0[*,*,0] = *loc.v
ff0[*,0] = *loc.frac
tt0[*,0] = *loc.t

curtime = input.options.endtime
ct = 1L  ;; number of steps taken
h = replicate(dt, npack)

;; Set up the display
if (showplot) then begin
  xcyc, xc, yc
  plot, xc, yc, xr=[-6,6], yr=[-6,6], /iso
  oplot, *output.x, *output.y, psym=8, color=2
;;  for i=0,npack-1 do oplot, (*output.x)[i]+[0,(*output.vx)[i]*!mercury.radius], $
;;    (*output.y)[i]+[0,(*output.vy)[i]*!mercury.radius], color=4
endif

moretogo = where(*loc.frac GT 0, ntogo)
done = (ntogo EQ 0)
while ((curtime GT 0) and ~(done)) do begin
  loc0 = {t: ptr_new((*loc.t)[moretogo]), x:ptr_new((*loc.x)[moretogo,*]), $
    v:ptr_new((*loc.v)[moretogo,*]), frac:ptr_new((*loc.frac)[moretogo])}
  oldf = *loc0.frac
  hfrac = hitfrac[moretogo,*]
  rfrac = ringfrac[moretogo]
  lfrac = leftfrac[moretogo]

  w = where(*loc0.frac EQ 0, nw) & if (nw NE 0) then stop
  w = where(finite(*loc0.x) EQ 0, nw) & if (nw NE 0) then stop
  w = where(finite(*loc0.v) EQ 0, nw) & if (nw NE 0) then stop

  ;; Run the rk5 step
  rk5, loc0, h, input, delta

  ;; Check for surface impacts
  ImpactCheck, input, loc0, hfrac, rfrac, deposition, tempR=tempR
  
  ;; Check for escape 
  if ~(input.options.fullSystem) then EscapeCheck, input, loc0, tempR, lfrac
  
  ;; If Saturn, then check to see if anything hit the rings
;;  if (input.geometry.planet EQ 'Saturn') then RingCheck, input, loc0, oldx[g,*], $
;;    RingFrac1

  ;; Check to see if any packets have shrunk out of existence
  q = where((*loc0.frac GT -1e-7) and (*loc0.frac LT 1e-10), nq)
  if (nq NE 0) then (*loc0.frac)[q] = 0.
  q = where(*loc0.frac LT 0, nq) & if (nq GT 0) then stop

  ;; If any new hits, set the time remaining to 0.
  w = where(*loc0.frac EQ 0, nw)
  if (nw NE 0) then (*loc0.t)[w] = 0.

  ;Put new values back into original array (again)
  (*loc.t)[moretogo] = *loc0.t
  (*loc.x)[moretogo,*] = *loc0.x
  (*loc.v)[moretogo,*] = *loc0.v
  (*loc.frac)[moretogo] = *loc0.frac
  (*loc.t)[moretogo] = *loc0.t
  lossfrac[moretogo] += (oldf-*loc0.frac)  ;; add in change in frac
  hitfrac[moretogo] += hfrac
  ringfrac[moretogo] += rfrac
  leftfrac[moretogo] += lfrac

  ;; Save the results for later
  xx0[*,*,ct] = *loc.x
  vv0[*,*,ct] = *loc.v
  ff0[*,ct] = *loc.frac
  tt0[*,ct] = *loc.t
  lossfrac0[*,ct] = lossfrac
  hitfrac0[*,*,ct] = hitfrac
  ringfrac0[*,ct] = ringfrac
  leftfrac0[*,ct] = leftfrac

  q = where(leftfrac0 GT 0 and ff0 NE 0)

  ;; check to see if any packets are finished
  moretogo = where(*loc.frac GT 0, ntogo)
  done = (ntogo EQ 0)

  ;; update the display
  if (showplot) then oplot, (*loc0.x)[*,0], (*loc0.x)[*,1], psym=8, color=5, symsize=.5
  ct++
  curtime -= dt
endwhile

*output.x0 = (*output.x0 # replicate(1., input.options.nsteps))[*]
*output.y0 = (*output.y0 # replicate(1., input.options.nsteps))[*]
*output.z0 = (*output.z0 # replicate(1., input.options.nsteps))[*]
*output.vx0 = (*output.vx0 # replicate(1., input.options.nsteps))[*]
*output.vy0 = (*output.vy0 # replicate(1., input.options.nsteps))[*]
*output.vz0 = (*output.vz0 # replicate(1., input.options.nsteps))[*]
*output.phi0 = (*output.phi0 # replicate(1., input.options.nsteps))[*]

*output.x = (reform(xx0[*,0,*]))[*]
*output.y = (reform(xx0[*,1,*]))[*]
*output.z = (reform(xx0[*,2,*]))[*]
*output.vx = (reform(vv0[*,0,*]))[*]
*output.vy = (reform(vv0[*,1,*]))[*]
*output.vz = (reform(vv0[*,2,*]))[*]
*output.frac = ff0[*]
*output.time = tt0[*]
*output.index = lindgen(npack*input.options.nsteps) mod npack
output.totalsource = output.totalsource*input.options.nsteps
output.npackets = long(npack)*long(input.options.nsteps)

if (n_elements(*SystemConsts.objects) GT 1)  $
  then stop $ ;; need to fix hitfrac
  else *output.hitfrac = (reform(hitfrac0))[*]
*output.lossfrac = (reform(lossfrac0))[*]
*output.ringfrac = (reform(ringfrac0))[*]
*output.leftfrac = (reform(leftfrac0))[*]
output.deposition = deposition

if (output.npackets NE n_elements(*output.x)) then stop

end
