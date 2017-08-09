pro out_cat, out0, out1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Combine two output structures
;; out0 is changed.
;;
;; Written 14 March 2011
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

*out0.x0 = [*out0.x0, *out1.x0]
*out0.y0 = [*out0.y0, *out1.y0]
*out0.z0 = [*out0.z0, *out1.z0]
*out0.f0 = [*out0.f0, *out1.f0]
*out0.vx0 = [*out0.vx0, *out1.vx0]
*out0.vy0 = [*out0.vy0, *out1.vy0]
*out0.vz0 = [*out0.vz0, *out1.vz0]
*out0.phi0 = [*out0.phi0, *out1.phi0]
*out0.lat0 = [*out0.lat0, *out1.phi1]
*out0.lon0 = [*out0.lon0, *out1.lon1]
out0.totalsource += out1.totalsource
out0.npackets += out1.npackets
*out0.time = [*out0.time, *out1.time]
*out0.x = [*out0.x, *out1.x]
*out0.y = [*out0.y, *out1.y]
*out0.z = [*out0.z, *out1.z]
*out0.frac = [*out0.frac, *out1.frac]
*out0.vx = [*out0.vx, *out1.vx]
*out0.vy = [*out0.vy, *out1.vy]
*out0.vz = [*out0.vz, *out1.vz]
*out0.index = [*out0.index, *out1.index]
*out0.lossfrac = float([*out0.lossfrac, *out1.lossfrac])
*out0.ringfrac = float([*out0.ringfrac, *out1.ringfrac])
*out0.leftfrac = float([*out0.leftfrac, *out1.leftfrac])
*out0.sourcefile = [*out0.sourcefile, *out1.sourcefile]
s = size(*out0.hitfrac)
if (s[0] EQ 1) $
  then *out0.hitfrac = float([*out0.hitfrac, *out1.hitfrac]) $
  else begin
    temp = fltarr(n_elements(*out0.x),s[2])
    temp[0:s[1]-1,*] = float(*out0.hitfrac)
    temp[s[1]:*,*] = float(*out1.hitfrac)
    *out0.hitfrac = temp
  endelse
*out0.deposition.map += *out1.deposition.map

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro out_sub, output, q

*output.x0 = (*output.x0)[q]
*output.y0 = (*output.y0)[q]
*output.z0 = (*output.z0)[q]
*output.f0 = (*output.f0)[q]
*output.vx0 = (*output.vx0)[q]
*output.vy0 = (*output.vy0)[q]
*output.vz0 = (*output.vz0)[q]
*output.phi0 = (*output.phi0)[q]
*output.lon0 = (*output.lon0)[q]
*output.lat0 = (*output.lat0)[q]
*output.time = (*output.time)[q]
*output.x = (*output.x)[q]
*output.y = (*output.y)[q]
*output.z = (*output.z)[q]
*output.frac = (*output.frac)[q]
*output.vx = (*output.vx)[q]
*output.vy = (*output.vy)[q]
*output.vz = (*output.vz)[q]
*output.index = (*output.index)[q]

*output.leftfrac = (*output.leftfrac)[q]
*output.lossfrac = (*output.lossfrac)[q]
*output.ringfrac = (*output.ringfrac)[q]
s = size(*output.hitfrac)
if (s[0] EQ 1) $
  then *output.hitfrac = (*output.hitfrac)[q] $ 
  else *output.hitfrac = (*output.hitfrac)[q,*]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;function out_extract, output, q
;;
;;output0 = {x0:ptr_new(0), y0:ptr_new(0), z0:ptr_new(0), f0:ptr_new(0), vx0:ptr_new(0), $
;;  vy0:ptr_new(0), vz0:ptr_new(0), phi0:ptr_new(0), lat0:ptr_new(0), lon0:ptr_new(0), $
;;  time:ptr_new(0), x:ptr_new(0), y:ptr_new(0), z:ptr_new(0), frac:ptr_new(0), $
;;  vx:ptr_new(0), vy:ptr_new(0), vz:ptr_new(0), index:ptr_new(0), npackets:0L, $
;;  totalsource:0d, loss_info:{reactions:ptr_new(), files:ptr_new(), type:ptr_new()}, $
;;  lossfrac:ptr_new(0), hitfrac:ptr_new(0), ringfrac:ptr_new(0), leftfrac:ptr_new(0), $
;;  deposition:{longitude:ptr_new(), latitude:ptr_new(), map:ptr_new()}, $
;;  sourcefile:ptr_new('modeloutput')}
;;
;;*output0.x0 = (*output.x)[q]
;;*output0.y0 = (*output.y)[q]
;;*output0.z0 = (*output.z)[q]
;;*output0.f0 = (*output.frac)[q]
;;*output0.vx0 = (*output.vx0)[q]
;;*output0.vy0 = (*output.vy0)[q]
;;*output0.vz0 = (*output.vz0)[q]
;;*output0.phi0 = (*output.phi0)[q]
;;*output0.lat0 = 0.
;;*output0.lon0 = 0.
;;*output0.time = (*output.time)[q]
;;*output0.x = (*output.x)[q]
;;*output0.y = (*output.y)[q]
;;*output0.z = (*output.z)[q]
;;*output0.frac = (*output.frac)[q]
;;*output0.vx = (*output.vx)[q]
;;*output0.vy = (*output.vy)[q]
;;*output0.vz = (*output.vz)[q]
;;*output0.index = (*output.index)[q]
;;output0.npackets = n_elements(q)
;;output0.totalsource = total(*output0.f0)
;;output0.loss_info = output.loss_info
;;*output0.lossfrac = (*output.lossfrac)[q]
;;*output0.hitfrac = (*output.hitfrac)[q]
;;*output0.ringfrac = (*output.ringfrac)[q]
;;*output0.leftfrac = (*output.leftfrac)[q]
;;
;;return, output0
;;
;;end
