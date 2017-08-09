pro make_model_header, outputfile

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; make_model_header: make a text format header file for the model output
;;
;; Inputs:
;;   * outputfile = model output file in IDLsave format
;;
;; Writen by Matthew Burger
;; Version History:
;;   3.2: 7/19/10
;;     * converted to new architecture
;;   3.1: 5/13/10
;;     * Added num keyword
;;     * Added code versions to the header
;;   3.0: 5/10/10
;;     * Created.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

result = obj_new('IDL_Savefile', outputfile)

;; Extract identifying info
contents = result.contents()
id = {file:outputfile, time:contents.date, user:contents.user, computer:contents.host}
t = strtrim(tag_names(id), 2)
idparam = strarr(n_elements(t))
idvalue = strarr(n_elements(t))
for i=0,n_elements(t)-1 do begin
  idparam[i] = t[i]
  idvalue[i] = string(id.(i))
endfor
idvalue = strtrim(idvalue, 2)

result.restore, 'input'
result.restore, 'output'

npackets = (input.options.streamlines) ? $
  n_elements(uniq(*output.index, sort(*output.index))) : $
  n_elements(*output.x)

;; Extract geometry info
geometry = input.geometry
t = strtrim(tag_names(geometry), 2)
geoparam = strarr(1000)
geovalue = strarr(1000)
ct = 0
for i=0,n_elements(t)-1 do begin
  if (ptr_valid(geometry.(i))) then for j=0,n_elements(*geometry.(i))-1 do begin
    geoparam[ct] = t[i]
    geovalue[ct] = string((*geometry.(i))[j])
    ct++
  endfor else begin
    geoparam[ct] = t[i]
    geovalue[ct] = string(geometry.(i))
    ct++
  endelse
endfor
geoparam = geoparam[0:ct-1]
geovalue = strtrim(geovalue[0:ct-1], 2)

;; Extract Sticking_info
sticking_info = input.sticking_info
t = strtrim(tag_names(sticking_info), 2)
stickparam = strarr(n_elements(t))
stickvalue = strarr(n_elements(t))
for i=0,n_elements(t)-1 do begin
  stickparam[i] = t[i]
  stickvalue[i] = string(sticking_info.(i))
endfor
stickvalue = strtrim(stickvalue, 2)

;; Extract Forces
forces = input.forces
t = strtrim(tag_names(forces), 2)
forceparam = strarr(n_elements(t))
forcevalue = strarr(n_elements(t))
for i=0,n_elements(t)-1 do begin
  forceparam[i] = t[i]
  forcevalue[i] = string(forces.(i))
endfor
forcevalue = strtrim(forcevalue, 2)

;; Extract spatialdist
SpatialDist = input.SpatialDist
t = strtrim(tag_names(SpatialDist), 2)
spatparam = strarr(100)
spatvalue = strarr(100)
ct = 0
for i=0,n_elements(t)-1 do begin
  n = n_elements(SpatialDist.(i))
  if (n EQ 1) then begin
    spatparam[ct] = t[i]
    spatvalue[ct] = string(SpatialDist.(i))
    ct++
  endif else for j=0,n-1 do begin
    spatparam[ct] = t[i] + strtrim(string(j),2)
    spatvalue[ct] = string((SpatialDist.(i))[j])
    ct++
  endfor
endfor
spatparam = spatparam[0:ct-1]
spatvalue = strtrim(spatvalue[0:ct-1], 2)

;; Extract speeddist
SpeedDist = input.SpeedDist
t = strtrim(tag_names(SpeedDist), 2)
speedparam = strarr(n_elements(t))
speedvalue = strarr(n_elements(t))
for i=0,n_elements(t)-1 do begin
  speedparam[i] = t[i]
  speedvalue[i] = string(SpeedDist.(i))
endfor
speedvalue = strtrim(speedvalue, 2)

;; Extract angular_dist
AngularDist = input.AngularDist
t = strtrim(tag_names(AngularDist), 2)
angparam = strarr(100)
angvalue = strarr(100)
ct = 0
for i=0,n_elements(t)-1 do begin
  n = n_elements(AngularDist.(i))
  if (n EQ 1) then begin
    angparam[ct] = t[i]
    angvalue[ct] = string(AngularDist.(i))
    ct++
  endif else for j=0,n-1 do begin
    angparam[ct] = t[i] + strtrim(string(j),2)
    angvalue[ct] = string((AngularDist.(i))[j])
    ct++
  endfor
endfor
angparam = angparam[0:ct-1]
angvalue = strtrim(angvalue[0:ct-1], 2)

;; Extract PerturbVel
PerturbVel = input.PerturbVel
t = strtrim(tag_names(PerturbVel), 2)
pertparam = strarr(n_elements(t))
pertvalue = strarr(n_elements(t))
for i=0,n_elements(t)-1 do begin
  pertparam[i] = t[i]
  pertvalue[i] = string(PerturbVel.(i))
endfor
pertvalue = strtrim(pertvalue, 2)

;; Extract plasma_info (if present)
PlasmaInfo = input.plasma_info
t = strtrim(tag_names(plasmainfo), 2)
plasmaparam = strarr(n_elements(t))
plasmavalue = strarr(n_elements(t))
for i=0,n_elements(t)-1 do begin
  plasmaparam[i] = t[i]
  plasmavalue[i] = string(plasmainfo.(i))
endfor
plasmavalue = strtrim(plasmavalue, 2)

;; extract options
options = input.options
t = strtrim(tag_names(options), 2)
optparam = strarr(n_elements(t))
optvalue = strarr(n_elements(t))
for i=0,n_elements(t)-1 do begin
  optparam[i] = t[i]
  optvalue[i] = string(options.(i))
endfor
optvalue = strtrim(optvalue, 2)

obj_destroy, result

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Save header file
hdrfile = strmid(outputfile, 0, strlen(outputfile)-strlen('output')) + 'header'
print, hdrfile
openw, lun, hdrfile, width=100, /get_lun

form = '(A-30,A3,A-)'
for i=0,n_elements(idparam)-1 do printf, lun, 'id.' + idparam[i], ' = ', $
  idvalue[i], format=form
printf, lun

printf, lun, 'savedpackets', ' = ', strint(npackets),  format=form
printf, lun, 'output.totalsource', ' = ', strint(output.totalsource), format=form
for i=0,n_elements(*output.sourcefile)-1 do $
  printf, lun, 'output.sourcefile', ' = ', (*output.sourcefile)[i], format=form
printf, lun

for i=0,n_elements(geoparam)-1 do printf, lun, 'geometry.' + geoparam[i], ' = ', $
  geovalue[i], format=form
printf, lun

for i=0,n_elements(stickparam)-1 do printf, lun, 'sticking_info.' + stickparam[i], $
  ' = ', stickvalue[i], format=form
printf, lun

for i=0,n_elements(forceparam)-1 do printf, lun, 'forces.' + forceparam[i], ' = ', $
  forcevalue[i], format=form
printf, lun

for i=0,n_elements(spatparam)-1 do printf, lun, 'SpatialDist.' + spatparam[i], ' = ', $
  spatvalue[i], format=form
printf, lun

for i=0,n_elements(speedparam)-1 do printf, lun, 'SpeedDist.' + speedparam[i], ' = ', $
  speedvalue[i], format=form
printf, lun

for i=0,n_elements(angparam)-1 do printf, lun, 'AngularDist.' + angparam[i], ' = ', $
  angvalue[i], format=form
printf, lun

for i=0,n_elements(pertparam)-1 do printf, lun, 'PerturbVel.' + pertparam[i], ' = ', $
  pertvalue[i], format=form
printf, lun

for i=0,n_elements(plasparam)-1 do printf, lun, 'PlasmaInfo.' + plasmaparam[i], ' = ', $
  plasmavalue[i], format=form
printf, lun

for i=0,n_elements(optparam)-1 do printf, lun, 'options.' + optparam[i], ' = ', $
  optvalue[i], format=form
printf, lun

free_lun, lun
destroy_structure, output
destroy_structure, input

end
