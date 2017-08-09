function produce_density, files, data, savefile=savefile, getvel=getvel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; determine density at points data.x, data.y, data.z
;; 
;; if format.dr = 0, then determines density from the voronoi region
;; if format.dr > 0, then determines density from packets within sphere
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants
common results

;;if (format.quantity NE 'density') then stop ;; only can do points at the moment
if (getvel EQ !null) then getvel = 0

;; Determine how dr is set
geometry = format.geometry
formtags = strlowcase(tag_names(geometry))
q = fix(total(strmatch(tag_names(format), 'dr', /fold)))
if (q) $
  then dr = format.dr $
  else dr = geometry.dr

if (size(data, /type) NE 8) then stop ;; data must be given as a structure

nf = n_elements(files)
nspec = n_elements(*data.x)

if (dr EQ 0) then begin
  print, 'Using voronoi regions to determine density'

  ;; Load the packets
  xx = !null & yy = !null & zz = !null & frac = !null & radvel_sun = !null
  for ff=0,nf-1 do begin
    results_loadfile, files[ff], pts, vels_sun, frac2 ;; note - not keeing frac=0
    xx = [xx, pts[*,0]] & yy = [yy, pts[*,1]] & zz = [zz, pts[*,2]]
    stop
    frac = [frac, frac2] 
    radvel_sun = [radvel_sun, vels_sun[*,1]+stuff.vrplanet]  ;; for g-value
    print, 'Loaded outputs ' + strint(ff+1) + ' of ' + strint(nf)
  endfor

  out = {x:ptr_new(temporary(xx)), y:ptr_new(temporary(yy)), $
    z:ptr_new(temporary(zz)), frac:ptr_new(temporary(frac)), $
    radvel_sun:ptr_new(temporary(radvel_sun))}
  rhosqr_sun = *out.x^2 + *out.z^2 
  if (savefile NE !null) then save, out, rhosqr_sun, file=savefile

  ;; remove packets outside region of interest
  q = where((*out.x GE min(*data.x)-.1) and (*out.x LE max(*data.x)+.1) and $
    (*out.y GE min(*data.y)-.1) and (*out.y LE max(*data.y)+.1) and $
    (*out.z GE min(*data.z)-.1) and (*out.z LE max(*data.z)+.1) and $
    (*out.frac GT 0), nq)
  if (nq GT 0) then begin
    *out.x = (*out.x)[q]
    *out.y = (*out.y)[q]
    *out.z = (*out.z)[q]
    *out.frac = (*out.frac)[q]
    *out.radvel_sun = (*out.radvel_sun)[q]
  endif

  ;; determine packet weighting
  *out.frac = results_packet_weighting(out)

  regions = results_voronoi(out)
  tree = results_kd_tree(out)

  density = results_density(*data.x, *data.y, *data.z, out, regions, tree)
endif else begin
  ;; Using sphere
  vpix = 4./3.*!pi*(dr*SystemConsts.rplan*1e5)^3

  ndata = n_elements(*data.x)
  npackets = lonarr(ndata)
  density = dblarr(ndata)
  density2 = dblarr(ndata)

  if (getvel) then begin
    v_xyz = dblarr(3,ndata) & v_ren = dblarr(3,ndata)
    sigma_xyz = dblarr(3,ndata) & sigma_ren = dblarr(3,ndata)

    vx = dblarr(ndata) & vr = dblarr(ndata)
    vy = dblarr(ndata) & ve = dblarr(ndata)
    vz = dblarr(ndata) & vn = dblarr(ndata)
    vv = dblarr(ndata)

    sigx = dblarr(ndata) & sigr = dblarr(ndata)
    sigy = dblarr(ndata) & sige = dblarr(ndata)
    sigz = dblarr(ndata) & sign = dblarr(ndata)
    sigv = dblarr(ndata)
    sigx2 = dblarr(ndata)
  endif

  ;; Loop over each outputfile 
  for ff=0,nf-1 do begin
    results_loadfile, files[ff], pts, vels_sun, frac2 ;; note - not keeing frac=0
    out = {x:ptr_new(pts[*,0]), y:ptr_new(pts[*,1]), z:ptr_new(pts[*,2]), $
      frac:ptr_new(frac2), vx:ptr_new(vels_sun[*,0]), vy:ptr_new(vels_sun[*,1]), $
      vz:ptr_new(vels_sun[*,2]), radvel_sun:ptr_new(vels_sun[*,1]+stuff.vrplanet)} 
    q = where(finite(*out.frac) EQ 0, nq) & if (nq NE 0) then stop
  
    q = where((*out.x GE min(*data.x)-.1) and (*out.x LE max(*data.x)+.1) and $
      (*out.y GE min(*data.y)-.1) and (*out.y LE max(*data.y)+.1) and $
      (*out.z GE min(*data.z)-.1) and (*out.z LE max(*data.z)+.1) and $
      (*out.frac GT 0), nq)
    if (nq GT 0) then begin
      *out.x = (*out.x)[q]
      *out.y = (*out.y)[q]
      *out.z = (*out.z)[q]
      *out.frac = (*out.frac)[q]

      if (getvel) then begin
	*out.vx = (*out.vx)[q]
	*out.vy = (*out.vy)[q]
	*out.vz = (*out.vz)[q]
	*out.radvel_sun = (*out.radvel_sun)[q]
	vtemp = sqrt(*out.vx^2 + *out.vy^2 + *out.vz^2)

	rr = sqrt(*out.x^2 + *out.y^2 + *out.z^2)
	v_rad = (*out.vx**out.x + *out.vy**out.y + *out.vz**out.z)/rr

	ee = sqrt(*out.x^2 + *out.y^2)
	v_east = (*out.vx**out.y - *out.vy**out.x)/ee

	nn = sqrt((*out.x**out.z)^2 + (*out.y**out.z)^2 + (*out.x^2+*out.y^2)^2)
	v_north = (-*out.vx**out.x**out.z - *out.vy**out.y**out.z + $
	  *out.vz*(*out.x^2+*out.y^2))/nn

	vtemp2 = sqrt(v_rad^2 + v_east^2 + v_north^2)
	if (max(abs(vtemp-vtemp2)) GT 1e-4) then stop
      endif

      ;; Determine emission measure for each packet
      rhosqr_sun = *out.x^2 + *out.z^2 
      out_of_shadow = ((rhosqr_sun GT 1) or (*out.y LT 0))
      
      *out.frac = results_packet_weighting(out, out_of_shadow)/vpix
      frac2 = *out.frac^2
    
      for i=0,n_elements(*data.x)-1 do begin
	xpr = *out.x-(*data.x)[i]
	ypr = *out.y-(*data.y)[i]
	zpr = *out.z-(*data.z)[i]
	rpr = sqrt(xpr^2 + ypr^2 + zpr^2)
	q = where(rpr LT dr, nq)
	if (nq GT 0) then begin
	  npackets[i] += nq
	  density[i] += total((*out.frac)[q])
	  density2[i] += total(frac2[q])

	  if (getvel) then begin
	    vx[i] += total((*out.vx)[q]*(*out.frac)[q])
	    vy[i] += total((*out.vy)[q]*(*out.frac)[q])
	    vz[i] += total((*out.vz)[q]*(*out.frac)[q])

	    vr[i] += total(v_rad[q]*(*out.frac)[q])
	    ve[i] += total(v_east[q]*(*out.frac)[q])
	    vn[i] += total(v_north[q]*(*out.frac)[q])

	    vv[i] += total(vtemp[q]*(*out.frac)[q])

	    sigx2[i] += total((*out.vx)[q]^2*(*out.frac)[q]^2)
	    sigx[i] += total((*out.vx)[q]^2*frac2[q])
	    sigy[i] += total((*out.vy)[q]^2*frac2[q])
	    sigz[i] += total((*out.vz)[q]^2*frac2[q])

	    sigr[i] += total(v_rad[q]^2*frac2[q])
	    sige[i] += total(v_east[q]^2*frac2[q])
	    sign[i] += total(v_north[q]^2*frac2[q])

	    sigv[i] += total(vtemp[q]^2*frac2[q])

	    q = where(finite(vx) EQ 0, nq) & if (nq NE 0) then stop
	    q = where(finite(sigx) EQ 0, nq) & if (nq NE 0) then stop
	    q = where(finite(vv) EQ 0, nq) & if (nq NE 0) then stop
	    q = where(finite(sigv) EQ 0, nq) & if (nq NE 0) then stop
	  endif
	endif
      endfor
    endif
    print, 'Finished outputs ' + strint(ff+1) + ' of ' + strint(nf)
    out = 0
  endfor
endelse
print, minmax(density)
if (max(density) EQ 0) then stop

if (getvel) then begin
  q = where(density GT 0, nq, comp=w)
  v_xyz[0,q] = vx[q]/density[q]
  v_xyz[1,q] = vy[q]/density[q]
  v_xyz[2,q] = vz[q]/density[q]

  v_ren[0,q] = vr[q]/density[q]
  v_ren[1,q] = ve[q]/density[q]
  v_ren[2,q] = vn[q]/density[q]

  v_rms = dblarr(n_elements(*data.x))
  v_rms[q] = vv[q]/density[q]

  q = where(npackets GT 1, nq)
  sigma_xyz[0,q] = sqrt(sigx[q]/density2[q] - reform(v_xyz[0,q])^2)
  sigma_xyz[1,q] = sqrt(sigy[q]/density2[q] - reform(v_xyz[1,q])^2)
  sigma_xyz[2,q] = sqrt(sigz[q]/density2[q] - reform(v_xyz[2,q])^2)

  sigma_ren[0,q] = sqrt(sigr[q]/density2[q] - reform(v_ren[0,q])^2)
  sigma_ren[1,q] = sqrt(sige[q]/density2[q] - reform(v_ren[1,q])^2)
  sigma_ren[2,q] = sqrt(sign[q]/density2[q] - reform(v_ren[2,q])^2)

  sigma_rms = dblarr(n_elements(*data.x))

  w = sigv[q]/density2[q] - v_rms[q]^2
  ww = where(w LT 0, nw)
  if (nw GT 0) then w[ww] = 0.
  sigma_rms[q] = sqrt(w)

  qq = where(finite(v_xyz) EQ 0, nq) & if (nq NE 0) then stop
  qq = where(finite(v_ren) EQ 0, nq) & if (nq NE 0) then stop
  qq = where(finite(v_rms) EQ 0, nq) & if (nq NE 0) then stop
  qq = where(finite(sigma_xyz) EQ 0, nq) & if (nq NE 0) then sigma_xyz[qq] = 0.
  qq = where(finite(sigma_ren) EQ 0, nq) & if (nq NE 0) then sigma_ren[qq] = 0
  qq = where(finite(sigma_rms) EQ 0, nq) & if (nq NE 0) then sigma_rms[qq] = 0
endif

;; v_xyz is in model cartesian coordinates
;; v_ren is in mercury-centered radial coordinates
;; v_rms is the root mean squared speed
if (getvel) $
  then result = {density:ptr_new(density), npackets:ptr_new(npackets), $
    v_xyz:ptr_new(v_xyz), sigma_xyz:ptr_new(sigma_xyz), $
    v_ren:ptr_new(v_ren), sigma_ren:ptr_new(sigma_ren), $
    v_rms:ptr_new(v_rms), sigma_rms:ptr_new(sigma_rms), format:format} $
  else result = {density:ptr_new(density), npackets:ptr_new(npackets), format:format}

return, result

end
