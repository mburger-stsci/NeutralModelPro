pro locmoon, input, time, x=x, y=y, z=z

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  interpolates the position of each moon given positions calculated in 
;;  initial_positions
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants

nw = n_elements(*stuff.which)
nt = n_elements(time)
x = fltarr(nt,nw) & y = fltarr(nt,nw) & z = fltarr(nt,nw) 
for i=0,nw-1 do $
  if (input.options.motion) then begin
    x[*,i] = interpol((*positions.x)[*,i], *positions.time, time)
    y[*,i] = interpol((*positions.y)[*,i], *positions.time, time)
    z[*,i] = interpol((*positions.z)[*,i], *positions.time, time)
  endif else begin
    x[*,i] = (*positions.x)[i]
    y[*,i] = (*positions.y)[i]
    z[*,i] = (*positions.z)[i]
  endelse

end
