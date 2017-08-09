function plot_range, x, log=log

if (log EQ !null) then log = 0

if (log) then begin
  xr = minmax(alog10(x))
  xr[0] = floor(xr[0]) 
  xr[1] = ceil(xr[1])
  xr = 10.^xr
endif else begin
  xr = minmax(x)
  xr[0] = floor(xr[0]) 
  xr[1] = ceil(xr[1])
endelse

return, xr

end
