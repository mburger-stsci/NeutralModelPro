function modeldriver_runit, input, packs_per_it, seed=seed, showplot=showplot

common constants
common ratecoefs
common plasma

;; find the default reactions and datasets
case (1) of
  (input.options.lifetime EQ 0): loss_info = lifetime_setup(input)
  (input.options.lifetime LT 0): begin
    kappa = {photo:1, eimp:0, chx:0, kappa_photo:ptr_new(abs(1./input.options.lifetime))}
    loss_info = !null
    end
  else: loss_info = !null
endcase

;; Set up sticking
if (input.sticking_info.stickcoef NE 1) then sticking_setup, input

;; Set up the radiation pressure
if (input.forces.radpres) then begin 
  q = get_gvalue(input.options.atom, stuff.aplanet)
  ;;q /= SystemConsts.rplan ;; v in rplan/s, a in rplan/s^2
  *stuff.radpres_v = *q.v/SystemConsts.rplan
  *stuff.radpres_const = *q.radaccel/SystemConsts.rplan
endif else begin
  *stuff.radpres_v = 0.
  *stuff.radpres_const = 0.
endelse

;; Create the output structure
output = {x0:ptr_new(0), y0:ptr_new(0), z0:ptr_new(0), $
  f0:ptr_new(0), vx0:ptr_new(0), vy0:ptr_new(0), vz0:ptr_new(0), $
  phi0:ptr_new(0), lat0:ptr_new(0), lon0:ptr_new(0), $
  time:ptr_new(0), x:ptr_new(0), y:ptr_new(0), z:ptr_new(0), frac:ptr_new(0), $
  vx:ptr_new(0), vy:ptr_new(0), vz:ptr_new(0), $
  index:ptr_new(0), npackets:0L, totalsource:0d, $
  loss_info:{reactions:ptr_new(), files:ptr_new(), type:ptr_new()}, $
  lossfrac:ptr_new(0), hitfrac:ptr_new(0), ringfrac:ptr_new(0), $
  leftfrac:ptr_new(0), deposition:{longitude:ptr_new(), latitude:ptr_new(), $
  map:ptr_new()}, sourcefile:ptr_new('modeloutput')}
*output.f0 = replicate(1d, packs_per_it)

;; Determine the endtime of each packet
*output.time = (input.options.at_once) ? $
  replicate(input.options.endtime, packs_per_it) : $
  random_nr(seed=seed, packs_per_it) * input.options.endtime

;; Set up the loss_info
if (input.options.lifetime EQ 0) $
  then output.loss_info = {reactions:ptr_new(loss_info.reaction), $
    files:ptr_new(loss_info.file), type:ptr_new(loss_info.type)}

;; Set up locations of satellites at each time during the orbit
initial_positions, input

;; Determine the initial source distribution
if (input.SpatialDist.type EQ 'inputfile') $
  then outputfile_source, input, packs_per_it, seed, output=output  $
  else source_distribution, input, packs_per_it, seed, output=output
;;q = where(*output.f0 GT 1, nq) & if (nq GT 0) then stop
;;q = where(*output.frac GT 1, nq) & if (nq GT 0) then stop

;; Run the model
print, '**** RUNNING *****'
if (input.options.streamlines) $
  then stream_driver, input, output, seed=seed, showplot=showplot $
  else driver, input, output, seed=seed

return, output

end
