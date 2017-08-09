function los_voronoi, files, data

;; Load the packets
xx = !null & yy = !null & zz = !null & frac = !null & radvel_sun = !null
for ff=0,nf-1 do begin
 results_loadfile, files[ff], pts, vels_sun, frac2 ;; note - not keeing frac=0
 xx = [xx, pts[*,0]] & yy = [yy, pts[*,1]] & zz = [zz, pts[*,2]]
 frac = [frac, frac2] 
 radvel_sun = [radvel_sun, vels_sun[*,1]+stuff.vrplanet]  ;; for g-value
 print, 'Loaded inputs ' + strint(ff+1) + ' of ' + strint(nf)
endfor
out = {x:ptr_new(temporary(xx)), y:ptr_new(temporary(yy)), $
 z:ptr_new(temporary(zz)), frac:ptr_new(temporary(frac)), $
 radvel_sun:ptr_new(temporary(radvel_sun))}

;; Determine if blocked by planet
rhosqr_sun = *out.x^2 + *out.z^2 
out_of_shadow = ((rhosqr_sun GT 1) or (*out.y LT 0)) 

;; construct the voronoi regions and a kdtree to determine the los density
print, 'Using instrument FOV'

;; make the voronoi region for these points
regions = results_voronoi(out2)

;; make the kd_tree for these points
tree = results_kd_tree(out2)

;; Determine FOV
phic = atan(*data.ycorner, *data.xcorner)   ;; Corners
thc = asin(*data.zcorner) & sinthc = *data.zcorner
phib = atan(*data.ybore, *data.xbore) & thb = asin(*data.zbore) ;; Boresight

;; Determine where LOS intersects modeled region
limits = results_find_intersection_points(data, input)
lim0 = reform(limits[0,*]) & lim1 = reform(limits[1,*])
m0 = min(phic, dim=1) & m1 = max(phic, dim=1)
l0 = min(sinthc, dim=1) & l1 = max(sinthc, dim=1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop over each individual LOS
nr = 1000L & nphi = 15L & nth = 15L

radiance = dblarr(nspec)
density = dblarr(nr,nspec)
denr = dblarr(nr,nspec)
rrr = dindgen(nr)/(nr-1) & ppp = dindgen(nphi)/(nphi-1) & ttt = dindgen(nth)/(nth-1)
iii = one(ppp) & jjj = one(ttt)

for i=0,nspec-1 do begin
  if (todo[i]) then begin
    t0 = systime(1)
    rtemp = rrr*(lim1[i]-lim0[i]) + lim0[i] 
    ddr = rtemp[1]-rtemp[0]
    phitemp = ((ppp*(m1[i]-m0[i]) + m0[i]) # jjj)[*]
    sinthtemp = (iii # (ttt*(l1[i]-l0[i]) + l0[i]))[*]
    thtemp = asin(sinthtemp)

    xtemp0 = cos(phitemp)*cos(thtemp)
    ytemp0 = sin(phitemp)*cos(thtemp)
    ztemp0 = sinthtemp

    roi = obj_new('IDLanROI', phic[*,i], sinthc[*,i])
    q = where(roi.ContainsPoints(phitemp, sinthtemp), nq)
    obj_destroy, roi

    xden = (xtemp0[q]#rtemp)[*] + (*data.x)[i]
    yden = (ytemp0[q]#rtemp)[*] + (*data.y)[i]
    zden = (ztemp0[q]#rtemp)[*] + (*data.z)[i]

    den1 = results_density(xden, yden, zden, out2, regions, tree)
    den1 = reform(den1, nq, nr)
    denr[*,i] = rtemp
    density[*,i] = total(den1, 1)/nq
    radiance[i] = total(density[*,i])*ddr*robj
    t1 = systime(1)
    print, 'LOS Spec Number: ' + strint(i+1) + ' of ' + strint(nspec), t1-t0
  endif
endfor
;; Determine slit solid angle
;;omega = slit_solidangle(data)

return, result

end
