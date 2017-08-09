function produce_los, files, dataall, savelos=savelos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; If given, data needs to have x, y, z, dx, dy, dz or the corners
;;
;; common block contains 
;;  * input
;;  * format
;;  * SystemConsts
;;  * stuff = {aplanet, vrplanet, atoms_per_packet, mod_rate, totalsource}
;;  * gvalue = {lines, velocity, g}
;;  * plasma = TBD
;;
;; Version History:
;;   4.16: 10/23/2012
;;     * Making this more precise near the planet
;;   4.15: 1/31/2012
;;     * Fixed problem with lines of sight that intersect planet
;;   4.14: 1/xx/2012
;;     * Added option to use a cone instead of a cylinder
;;   4.11: 12/8/2011
;;     * Need to make sure it doesn't use too many packets at once
;;   4.8: 7/20/2011
;;     * adding ability to use cylinder instead of instrument FOV
;;     * adding more comments
;;     * possible bug fixes
;;   4.6: 4/21/2011
;;     * Makes use of parallelized kd_tree code
;;   4.5: 4/20/2011
;;     * same as 4.6 with debugging info still included.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants
common results

if (savelos EQ !null) then savelos = 0

;; Determine which mechamisms to do
if (format.quantity EQ 'intensity') then begin
  doresscat = (max(strcmp(format.emission.mechanism, 'resscat', /fold)))
  doeimp = (max(strcmp(format.emission.mechanism, 'eimp', /fold)))
endif else begin
  doresscat = 0 
  doeimp = 0
endelse

;; Determine points and lines of sights
geometry = format.geometry
geotags = strlowcase(tag_names(geometry))

;; Determine how dr is set
formtags = strlowcase(tag_names(geometry))
q = fix(total(strmatch(tag_names(format), 'dr', /fold)))
if (q) $
  then dr = format.dr $
  else dr = geometry.dr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the data if not given
if (size(dataall, /type) NE 8) then begin
  ;; figure out what information is given
  tag_spacecraft = total(stregex(geotags, 'spacecraft', /bool))
  tag_orbit = total(stregex(geotags, 'orbit', /bool))
  tag_phase = total(stregex(geotags, 'phase', /bool))
  tag_tstart = total(stregex(geotags, 'tstart', /bool))
  tag_tend = total(stregex(geotags, 'tend', /bool))
  tag_dt = total(stregex(geotags, 'dt', /bool))

  if (tag_spacecraft EQ 0) then begin
    print, 'A spacecraft must be specified for LOS measurements.'
    stop
  endif
  sc = strlowcase(geometry.spacecraft)
  case (sc) of 
    'messenger': begin
      ;; can specify either (tstart, tend) or (orbit, phase)
      case (1) of 
        (tag_orbit): begin
	  phase =  (tag_phase) ? geometry.phase : 'all'
	  dataall = load_MASCS_data(input.options.atom, geometry.orbit, phase, /model, $
	    version=2, spec=spec)
	  end
	(tag_tstart) and (tag_tend): $
	  dataall = load_MASCS_data(input.options.atom, geometry.tstart, geometry.tend, $
	    phase, /model)
	else: begin
	  print, 'Not set up yet.'
	  stop
	  endelse
      endcase
      end
    else: stop
  endcase
  if (strcmp(dataall.species, 'none', /fold)) then stop
endif else begin ;; Make sure have necessary data info
  tags = tag_names(dataall)
  if (total(strcmp(tags, 'x', /fold)) NE 1) then stop
  if (total(strcmp(tags, 'y', /fold)) NE 1) then stop
  if (total(strcmp(tags, 'z', /fold)) NE 1) then stop
  if (total(strcmp(tags, 'xbore', /fold)) NE 1) then stop
  if (total(strcmp(tags, 'ybore', /fold)) NE 1) then stop
  if (total(strcmp(tags, 'zbore', /fold)) NE 1) then stop
endelse

changecoords = 0
if (dataall.frame NE 'model') then begin
  changecoords = 1
  MSO_to_modelcoords, dataall
endif

;; Now have data = {x, y, z, xbore, ybore, zbore, xcorner, ycorner, zcorner}, 
;; corners are not necessary unless doing a slit -- there will be errors

sss = (where(strlowcase(*SystemConsts.Objects) EQ $
  strlowcase(input.geometry.StartPoint)))[0]
robj = (sss EQ 0) ? SystemConsts.rplan*1e5 : $    ;; radius of object in cm
  SystemConsts.rplan*(*SystemConsts.radius)[s]*1e5 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Determine which observations are too far from the planet and which
;; look at the planet
;; Distance of s/c from planet
dist_from_plan = sqrt(*dataall.x^2 + *dataall.y^2 + *dataall.z^2)

;; Angle between look dir and planet -- negative since want from look pt to planet
ang = acos((-*dataall.x**dataall.xbore - *dataall.y**dataall.ybore - $
  *dataall.z**dataall.zbore)/dist_from_plan)

;; Remove observations not looking close enough to the object
case (1) of 
  (input.options.fullsystem) and (format.only_good_points): $
    todo = where(*dataall.quality EQ 0)
  ~(input.options.fullsystem) and (format.only_good_points): $
    todo = where((*dataall.rtan LE input.options.OuterEdge) and (*dataall.quality EQ 0))
  (input.options.fullsystem) and ~(format.only_good_points): $
    todo = lindgen(n_elements(*dataall.radiance))
  ~(input.options.fullsystem) and ~(format.only_good_points): $
    todo = where(*dataall.rtan LE input.options.OuterEdge)
  else: stop ;; shouldn't happen
endcase 

tt = tag_names(dataall)
data = max(stregex(tt, 'orbit', /fold, /bool)) $
  ? data_extract(dataall, todo) $
  : {x:ptr_new((*dataall.x)[todo]), y:ptr_new((*dataall.y)[todo]), $
     z:ptr_new((*dataall.z)[todo]), xbore:ptr_new((*dataall.xbore)[todo]), $
     ybore:ptr_new((*dataall.ybore)[todo]), zbore:ptr_new((*dataall.zbore)[todo])}
ang = ang[todo]
dist_from_plan = dist_from_plan[todo]

;; check to see if look direction intersects the planet anywhere
;; angular size of planet from look pt.
asize_plan = asin(1./dist_from_plan)

;; Don't worry about lines of sight that don't hit the planet
missp = where(ang GT asize_plan, nmissp, comp=hitp)
if (nmissp GT 0) then dist_from_plan[missp] = 1e30

;; Determine limits of view
;;xx = [*data.x, *data.x+*data.xbore*10]
;;yy = [*data.y, *data.y+*data.ybore*10]
;;zz = [*data.z, *data.z+*data.zbore*10]

tstart = systime(1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Now look at the model outputs
nf = n_elements(files)
nspec = n_elements(*data.x)
nall = n_elements(*dataall.x)

case (1) of 
  (dr EQ -1) or (format.geometry.dphi EQ -1): method = 'variable'
  (dr EQ 0) and (format.geometry.dphi EQ 0): method = 'slit' ;; use instrument slit
  (dr GT 0) and (format.geometry.dphi EQ 0): method = 'cylinder' ;; use cylinder
  (dr EQ 0) and (format.geometry.dphi GT 0): method = 'cone' ;; use cone
  else: stop ;; error
endcase

if (method EQ 'slit') and ~(strcmp(geometry.spacecraft, 'messenger', /fold)) then stop

case (method) of 
  'voronoi': result = los_voronoi(files, data)
  else: begin
    radiance = fltarr(nspec)
    ninview = lonarr(nspec)
    if (savelos) then begin
      losn = ptrarr(nspec, /allocate)
      losr = ptrarr(nspec, /allocate)
      losx = ptrarr(nspec, /allocate)
      losy = ptrarr(nspec, /allocate)
      losz = ptrarr(nspec, /allocate)
      losradvel = ptrarr(nspec, /allocate)
    endif

    ;; Load the packets
    time = fltarr(nf)
    for ff=0,nf-1 do begin
      t0 = systime(1)
      results_loadfile, files[ff], pts, vels_sun, frac2 ;; note - not keeing frac=0
      out2 = {x:ptr_new(pts[*,0]), y:ptr_new(pts[*,1]), z:ptr_new(pts[*,2]), $
        frac:ptr_new(frac2), radvel_sun:ptr_new(vels_sun[*,1]+stuff.vrplanet)}
      out = {x:ptr_new(pts[*,0]), y:ptr_new(pts[*,1]), z:ptr_new(pts[*,2]), $
	frac:ptr_new(frac2), radvel_sun:ptr_new(vels_sun[*,1]+stuff.vrplanet)}
      t1 = systime(1)

      ;; Determine emission measure for each packet
      ;; based shadow on whether los goes through shadow
      out_of_shadow = replicate(1, n_elements(*out2.x))
      *out2.frac = results_packet_weighting(out, out_of_shadow)
;;      out_of_shadow = replicate(1, n_elements(*out.x))
;;      *out.frac = results_packet_weighting(out, out_of_shadow)

      if ((method EQ 'slit') or (method EQ 'variable')) then begin
	;; Find corner points in spherical coords
	rcorn = sqrt(*data.xcorner^2 + *data.ycorner^2 + *data.zcorner^2)
	phicorn = atan(-*data.xcorner, *data.ycorner)
	thetacorn = acos(*data.zcorner/rcorn)

	c0 = transpose([[reform((*data.xcorner)[0,*])], $
	      [reform((*data.ycorner)[0,*])], $
	      [reform((*data.zcorner)[0,*])]])
	c1 = transpose([[reform((*data.xcorner)[1,*])], $
	      [reform((*data.ycorner)[1,*])], $
	      [reform((*data.zcorner)[1,*])]])
	c2 = transpose([[reform((*data.xcorner)[2,*])], $
	      [reform((*data.ycorner)[2,*])], $
	      [reform((*data.zcorner)[2,*])]])
	c3 = transpose([[reform((*data.xcorner)[3,*])], $
	      [reform((*data.ycorner)[3,*])], $
	      [reform((*data.zcorner)[3,*])]])
	;;OmegaSlit = 4 * asin(sin(1*!dtor/2) * sin(0.04*!dtor/2))
      endif
      t2 = systime(1)
      ;;print, t1-t0, t2-t1

      for i=0,nspec-1 do begin
	;; Do an initial cull
	s0 = systime(1)
	xx = (*data.x)[i] + [0, (*data.xbore)[i]*10]
	yy = (*data.y)[i] + [0, (*data.ybore)[i]*10]
	zz = (*data.z)[i] + [0, (*data.zbore)[i]*10]

	q = where((*out2.x GE min(xx-0.5)) and (*out2.x LE max(xx+0.5)) and $
	  (*out2.y GT min(yy-0.5)) and (*out2.y LE max(yy+0.5)) and $
	  (*out2.z GT min(zz-0.5)) and (*out2.z LE max(zz+0.5)), nq) 
	*out.x = (*out2.x)[q]
	*out.y = (*out2.y)[q]
	*out.z = (*out2.z)[q]
	*out.frac = (*out2.frac)[q]
	*out.radvel_sun = (*out2.radvel_sun)[q]

	;; Distance of packet from spacecraft
	s0a = systime(1)
	xpr = *out.x - (*data.x)[i]
	ypr = *out.y - (*data.y)[i]
	zpr = *out.z - (*data.z)[i]
	rpr = sqrt(xpr^2 + ypr^2 + zpr^2)

	;; Packet-s/c-boresight angle
	costheta = (xpr*(*data.xbore)[i] + ypr*(*data.ybore)[i] + $
	  zpr*(*data.zbore)[i])/rpr

	q = where(costheta GT 1, nq) 
	if (nq GT 0) then costheta[q] = 1d

	q = where(costheta LT -1, nq) 
	if (nq GT 0) then costheta[q] = -1d

	method2 = method
	if (method EQ 'variable') then $
	  case (1) of 
;	    ((*data.alttan)[0,i] LT 100): method2 = 'slit'
            ((*data.alttan)[0,i] EQ 0): begin
	      method2 = 'cone'
	      format.geometry.dphi = 3*!dtor
	      end
	    ((*data.alttan)[0,i] LT 500): begin
	      method2 = 'cone'
	      format.geometry.dphi = 0.5*!dtor
	      end
	    ((*data.alttan)[0,i] LT 1000): begin
	      method2 = 'cone'
	      format.geometry.dphi = 1*!dtor
	      end
	    else: begin
	      method2 = 'cone'
	      format.geometry.dphi = 3*!dtor
	      end
	  endcase

	;; delta = perpendicular distance to the line of sight
	Apix = 0
	case (method2) of 
	  'slit': begin
            ;; Convert each LOS to spherical coords
	    phi = atan(-xpr, ypr)
	    theta = acos(zpr/rpr)

	    slit = obj_new('IDLanROI', phicorn[*,i], thetacorn[*,i], /double)
	    ii = slit.ContainsPoints(phi,theta)
	    inview = where((ii) and (rpr LT dist_from_plan) and (costheta GT 0) $ 
	      and (*out.frac GT 0), nin)

	    OmegaSlit = SolidAngle(c0[*,i], c1[*,i], c2[*,i]) + $
	      SolidAngle(c0[*,i], c1[*,i], c3[*,i])
	    if (nin GT 0) then Apix = OmegaSlit * (rpr[inview]*robj)^2 ;; area = Ωr^2
	    obj_destroy, slit
	    end
	  'cylinder': begin
	    delta = rpr * sin(acos(costheta))
	    q = where(finite(delta) EQ 0, nq) & if (nq GT 0) then stop
	    inview = where((abs(delta) LT dr) and (costheta GT 0) and (*out.frac GT 0) $
	      and (rpr LT dist_from_plan[i]), nin)
	    if (nin GT 0) then Apix = replicate(!pi * (dr*robj)^2, nin)
	    end
          'cone': begin
	    inview = where((costheta GE cos(format.geometry.dphi)) and (*out.frac GT 0) $
	      and (rpr LT dist_from_plan[i]), nin)
	    if (nin GT 0) then Apix = !pi * (rpr[inview]*sin(format.geometry.dphi)*robj)^2
	    end
	  else: stop
	endcase
	s5 = systime(1)
	
	if (nin GT 0) then begin
	  if (Apix[0] EQ 0) then stop
	  ftemp = (*out.frac)[inview]/apix
	  if (doresscat) then begin
	    ;; Determine whether the point along the LOS the packet represents is in 
	    ;; shadow
	    losrad = rpr[inview] * costheta[inview] ;; projection of packet onto LOS
	    xhit = (*data.x)[i] + (*data.xbore)[i]*losrad ;; point packet represents
	    yhit = (*data.y)[i] + (*data.ybore)[i]*losrad
	    zhit = (*data.z)[i] + (*data.zbore)[i]*losrad
	    rhohit = xhit^2 + zhit^2
	    out_of_shadow = (rhohit GT 1) or (yhit LT 0)
	    ftemp *= out_of_shadow
	  endif

;;	  if (savelos) then begin
;;	    *losr[i] = [*losr[i], rpr[inview]]
;;	    *losn[i] = [*losn[i], ftemp]
;;	    *losx[i] = [*losx[i], (*out.x)[inview]]
;;	    *losy[i] = [*losy[i], (*out.y)[inview]]
;;	    *losz[i] = [*losz[i], (*out.z)[inview]]
;;	    *losradvel[i] = [*losradvel[i], (*out.radvel_sun)[inview]]
;;	  endif
	  radiance[i] += total(ftemp)
	  ninview[i] += nin
	endif
      endfor
;;      plot, radiance, yr=[0,1e6]
      t1 = systime(1)
      print, 'Finished file #' + strint(ff+1) + ' of ' + strint(nf) 
      print, 'Time = ' + strint(t1-t0)
    endfor
    radall = fltarr(nall) & radall[todo] = radiance
    if (savelos) $
      then result = {radiance:ptr_new(radall), npackets:ptr_new(ninview), $
	losr:losr, losn:losn, losx:losx, losy:losy, losz:losz, $
	losradvel:losradvel, format:format} $
       else result = {radiance:ptr_new(radall), npackets:ptr_new(ninview), format:format}
    endelse
endcase

if (changecoords) then modelcoords_to_MSO, dataall

tend = systime(1)
print, 'LOS time: ', tend-tstart

return, result

end
