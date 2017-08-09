pro source_distribution, input, npack, seed, output=output

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Determine the initial positions and velocities for each packet
;;  This puts everything into one program and removes it from modjup.
;;
;;  A description of each step in this program is given in MonteCarlo.tex
;;
;;  Options:
;;    (1) Spatial Distributions
;;      (a) Surface  -- satellite-centric
;;      (b) SO_2 Exosphere  -- satellite-centric
;;      (c) Torus -- planet-centric
;;      (d) cloud -- planet-centric
;;      (e) exosphere - satellite-centric
;;      (f) PSD - satellite-centric
;;  
;;    (2) Speed Distribution
;;      (a) Gaussian -- f(v) ~ v_prob + exp(.5*(v/vth)^2)
;;      (b) Sputtering
;;      (c) maxwellian
;;      (d) dolsfunction
;;      (e) curcular orbits
;;      (f) flat
;;
;;    (3) angular distributions
;;	(a) radial
;;	(b) cos(theta)
;;	(c) isotropic
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants

;; Decide where the starting point is
s = stuff.s

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (1) Spatial distribution
;;  Choose a starting location for each packet.
case strlowcase(input.SpatialDist.type) of 
  ;; note -- torus and SO2 exosphere distributions not revised yet
  'surface': surface_distribution, input, output, npack, seed
  'torus': stop; torus_distribution, geometry, spatialdist, options, seed, startloc=startloc
  'exosphere': exosphere_distribution, input, output, npack, seed
  'so2 exosphere': SO2exosphere_distribution, input, output, npack, seed
  'psd': PSD_distribution, input, output, npack, seed
  'wall': wall_distribution, input, output, npack, seed
  'box': box_distribution, input, output, npack, seed
  else: stop
endcase
q = where(finite(*output.x0) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(*output.y0) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(*output.z0) EQ 0, nq) & if (nq NE 0) then stop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (2) Velocity distribution
;; Choose a speed and direction for each packet
speed_distribution, input, output, seed
q = where(finite(*output.vx0) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(*output.vy0) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(*output.vz0) EQ 0, nq) & if (nq NE 0) then stop

if (strlowcase(input.angulardist.type) NE 'none') then $
  angular_distribution, input, output, seed
q = where(finite(*output.vx0) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(*output.vy0) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(*output.vz0) EQ 0, nq) & if (nq NE 0) then stop

if (input.PerturbVel.type NE 'none') then stop ;; not revised yet
;  add_perturbation, startloc, PerturbVel, options, seed

;; Now have initial positions
;;   x,y,z in either Rplan or Rsat
;;   vx,vy,vz in Rplan/s
;;   time
;; * Still need to move packets to the proper position relative to the planet
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (3) Rotate everything to proper position for running the model
;; * if using a planet-centered distribution (torus), then don't need to do 
;;   anything special

if (stuff.s EQ 0) then begin ;; Everything is already setup correctly
  *output.x = *output.x0
  *output.y = *output.y0
  *output.z = *output.z0

  *output.vx = *output.vx0
  *output.vy = *output.vy0
  *output.vz = *output.vz0

  *output.phi0 = 0.  ;; this is meaningless for planet-centered distribution
endif else begin
  ;; Determine positions of starting point
  locmoon, input, *output.time, x=satx, y=saty, z=satz
  obj = (*SystemConsts.objects)[*stuff.which]
  s = (where(input.geometry.startpoint EQ obj, nq))[0]
  if (nq NE 1) then stop
  satx = satx[*,s] & saty = saty[*,s] & satz = satz[*,s] 
  ang = (atan(-satx, saty) + 2*!dpi) mod (2*!dpi)
  *output.phi0 = ang  ;; Starting local time for each packet

  ;; Get the initial positions
  xx = *output.x0 & yy = *output.y0 & zz = *output.z0
  vx = *output.vx0 & vy = *output.vy0 & vz = *output.vz0

  ;; Add in orbital velocity if needed
  vx -= input.options.motion*(*SystemConsts.orbvel)[stuff.s]/SystemConsts.rplan

  ;; Rotate packets around z-axis to proper orbital phase
  *output.x = xx * cos(ang) - yy * sin(ang)
  *output.y = xx * sin(ang) + yy * cos(ang)
  *output.z = zz

  *output.vx = vx * cos(ang) - vy * sin(ang)
  *output.vy = vx * sin(ang) + vy * cos(ang)
  *output.vz = vz

  ;; Rescale to units of Rplan and move out to starting position
  *output.x = *output.x*(*SystemConsts.radius)[stuff.s] + satx
  *output.y = *output.y*(*SystemConsts.radius)[stuff.s] + saty
  *output.z = *output.z*(*SystemConsts.radius)[stuff.s] + satz
endelse

q = where(finite(*output.vx) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(*output.vy) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(*output.vz) EQ 0, nq) & if (nq NE 0) then stop

*output.frac = *output.f0
output.totalsource = total(*output.frac)
output.npackets = npack

end
