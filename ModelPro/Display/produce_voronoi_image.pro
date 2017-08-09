function produce_voronoi_image, files

common constants
common results

;;;;;;;;;;;;;;;;
;; Determine the image origin
s = (where(strcmp(*SystemConsts.objects, format.geometry.origin, /fold), ns))[0]
if (ns NE 1) then stop

;;;;;;;;;;;;;;;
;; Determine image field of view and rotation
geometry = format.geometry

image = dblarr((geometry.dims)[0],(geometry.dims)[1])
immin = geometry.center - geometry.width/2.
immax = geometry.center + geometry.width/2.

scale = geometry.width/(geometry.dims-1) 	;; [xscale,zscale] in Rplan/pix
Apix = (scale[0]*scale[1])*(SystemConsts.rplan*1e5)^2 ;; cm^2/pix

;; xaxis and zaxis in Robj measured from center of object
xaxis = findgen((geometry.dims)[0])*scale[0] + immin[0]
zaxis = findgen((geometry.dims)[1])*scale[1] + immin[1]

;; Determine frame rotation
M = determine_image_rotation(input, format)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
xx = !null & yy = !null & zz = !null & frac = !null 
vx = !null & vy = !null & vz = !null & radvel_sun = !null
nf = n_elements(files)
for ff=0,nf-1 do begin
  ;; restore output file and extract useful packets
  ;; pts_sun is in solar reference frame with origin=Object center, units R_obj
  ;; vels_sun in km/s
  results_loadfile, files[ff], pts_sun, vels_sun, frac2 ;; note - not keeing frac=0

  ;; Rotate the packets to observer frame
  pts_obs = M ## pts_sun    ;; observer along -y axis
  vels_obs = M ## vels_sun 

  ;; Determine which packets are not blocked by the planet
  rhosqr_obs = pts_obs[*,0]^2 + pts_obs[*,2]^2  ;; rho in observer's frame
  inview = ((rhosqr_obs GT 1) or (pts_obs[*,1] LT 0))
  frac2 *= inview

  h = where((pts_obs[*,0] GE immin[0]) and (pts_obs[*,0] LE immax[0]) and $
    (pts_obs[*,2] GE immin[1]) and (pts_obs[*,2] LE immax[1]), nh) 
  if (nh GT 0) then begin
    xx = [xx, pts_obs[h,0]] & yy = [yy, pts_obs[h,1]] & zz = [zz, pts_obs[h,2]]
    vx = [vx, vels_obs[h,0]] & vy = [vy, vels_obs[h,1]] & vz = [vz, vels_obs[h,2]]
    frac = [frac, frac2[h]] 
    radvel_sun = [radvel_sun, vels_sun[h,1]+stuff.vrplanet]  ;; for g-value
  endif
  print, 'Loaded inputs ' + strint(ff+1) + ' of ' + strint(nf)
endfor
out = {x:ptr_new(temporary(xx)), y:ptr_new(temporary(yy)), $
  z:ptr_new(temporary(zz)), frac:ptr_new(temporary(frac)), $
  vx:ptr_new(temporary(vx)), vy:ptr_new(temporary(vy)), $
  vz:ptr_new(temporary(vz)), radvel_sun:ptr_new(temporary(radvel_sun))}

weight = results_packet_weighting(out, format)
;; Additional factors:
case (format.quantity) of
  'column': weight /= Apix
  'intensity': weight /= Apix
  'density': weight /= Vpix
  else: stop
endcase

;; Determine voronoi regions
regions = results_voronoi(out)

;; make the kd_tree for these points
tree = results_kd_tree(out)

dy = min(scale)/2.
ny = round((max(*out.y)-min(*out.y))/dy)+1
yaxis = findgen(ny)*dy + min(*out.y)

density = dblarr((geometry.dims)[0],(geometry.dims)[1],ny)
yy = (one(zaxis)#yaxis)[*]
zz = (zaxis#one(yaxis))[*]
nn = n_elements(yy)
for i=0,(geometry.dims)[0]-1 do begin
  t0 = systime(1)
  xx = replicate(xaxis[i],nn)
  temp = results_density(xx, yy, zz, out, regions, tree)
  density[i,*,*] = reform(temp, (geometry.dims)[1], ny)
  t1 = systime(1)
  print, i, t1-t0
endfor

;;for i=0,(geometry.dims)[0]-1 do begin
;;  for j=0,(geometry.dims)[1]-1 do begin
;;    density[i,j,*] = results_density(replicate(xaxis[i],ny), yaxis, $
;;      replicate(zaxis[i],ny), out, regions, tree)
;;  endfor
;;  print, i
;;endfor

result = {image:ptr_new(image), xaxis:ptr_new(xaxis), zaxis:ptr_new(zaxis), $
  format:format, yaxis:ptr_new(yaxis), density:ptr_new(density)}
return, result

end
