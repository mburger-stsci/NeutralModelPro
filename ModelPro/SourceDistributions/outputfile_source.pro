pro outputfile_source, input, packs_per_it, seed, output=output

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Will run the starting point inputfile then use that to create the new
;; input structure
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants
common ratecoefs

if ((input.SpatialDist.type NE 'inputfile') or (input.SpeedDist.type NE 'inputfile')) $
  then stop
if (input.SpatialDist.file NE input.SpeedDist.file) then stop

;; Restore the other inputfile
input_old = inputs_restore(input.SpatialDist.file)
;; Make sure the geometry inputs are the same
if (input.geometry.planet NE input_old.geometry.planet) then stop
if (input.geometry.startpoint NE input_old.geometry.startpoint) then stop
if (*input.geometry.phi NE *input_old.geometry.phi) then stop
if (*input.geometry.include NE *input_old.geometry.include) then stop
if (abs(input.geometry.taa-input_old.geometry.taa) GT 1e-5) then stop
if (input.geometry.subsolarlong NE input_old.geometry.subsolarlong) then stop
if (input.geometry.subsolarlat NE input_old.geometry.subsolarlat) then stop

;; save the stuff and kappa values in case they change
stuff_save = {s:stuff.s, aplanet:stuff.aplanet, vrplanet:stuff.vrplanet, $
  radpres_v:ptr_new(*stuff.radpres_v), radpres_const:ptr_new(*stuff.radpres_const), $
  local:stuff.local, strstart:stuff.strstart, which:ptr_new(*stuff.which), $
  time_given:stuff.time_given}
kappa_save = temporary(kappa)

;; need 1:1 correspondence between old and new packets
input_old.options.streamlines = 0 
input_old.options.at_once = 0

;; Now need to run this inputfile
output_old = modeldriver_runit(input_old, packs_per_it, seed=seed, showplot=showplot)
oldf = *output_old.frac

;; restore the original values
stuff = {s:stuff_save.s, aplanet:stuff_save.aplanet, vrplanet:stuff_save.vrplanet, $
  radpres_v:ptr_new(*stuff_save.radpres_v), $
  radpres_const:ptr_new(*stuff_save.radpres_const), local:stuff_save.local, $
  strstart:stuff_save.strstart, which:ptr_new(*stuff_save.which), $
  time_given:stuff_save.time_given}
kappa = temporary(kappa_save)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Figure out initial fraction based on dissociation of parent molecule
if (n_elements(input.SpatialDist.process) NE 1) then stop ;; can only use one mechanism
case strlowcase(input.SpatialDist.process) of 
  'none': ;; use frac from old output
  'photodissociation': begin
    ;; Determine photodissociation rate 
    reac_to_use = intarr(n_elements(*output_old.loss_info.reactions))
    for i=0,n_elements(*output_old.loss_info.reactions)-1 do begin
      reac = (*output_old.loss_info.reactions)[i]
      parts = strsplit(reac, '->', /extract, /regex)
      reactants = strtrim(strsplit(parts[0], ',', /extract), 2)
      products = strtrim(strsplit(parts[1], ',', /extract), 2)
      reac_to_use[i] = (total(strcmp(reactants, 'photon'))) and $
	(total(strcmp(products, input.options.atom)))
    endfor
    q = (where(reac_to_use, nq))[0] & if (nq NE 1) then stop
    print, (*output_old.loss_info.reactions)[q]
    restore, (*output_old.loss_info.files)[q]

    rate = (1-exp(-ratecoef.kappa/stuff.aplanet^2))
    out_of_shadow = (*output_old.y LT 0) or (*output_old.x^2 + *output_old.z^2 GT 1)
    *output_old.frac *= rate * out_of_shadow 
    end
  'spontaneous': begin  ;; must have used a finite lifetime in the old inputfile
    if (input_old.options.lifetime EQ 0) then stop
    rate = (1-exp(-1./input_old.options.lifetime))
    *output_old.frac *= rate
    end
  else: stop
endcase

;; Figure out initial state of new packets
*output.x0 = *output_old.x
*output.y0 = *output_old.y
*output.z0 = *output_old.z
*output.f0 = *output_old.frac
*output.vx0 = *output_old.vx
*output.vy0 = *output_old.vy
*output.vz0 = *output_old.vz

if (stuff.s EQ 0) $
  then *output.phi0 = 0 $
  else begin
    ;; set initial orbital phase
    stop
  endelse

;; Add in velocity perturbation
add_perturbation, input, output, seed=seed

;; Set current positions
*output.x = *output.x0
*output.y = *output.y0
*output.z = *output.z0
*output.frac = *output.f0
*output.vx = *output.vx0
*output.vy = *output.vy0
*output.vz = *output.vz0
output.totalsource = n_elements(*output.x0) ;; total(*output.frac)
output.npackets = n_elements(*output.x0)

;; Error checks
q = where(finite(*output.vx) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(*output.vy) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(*output.vz) EQ 0, nq) & if (nq NE 0) then stop

;;q = where(*output.f0 GT 1, nq) & if (nq GT 0) then stop
;;q = where(*output.frac GT 1, nq) & if (nq GT 0) then stop

end
