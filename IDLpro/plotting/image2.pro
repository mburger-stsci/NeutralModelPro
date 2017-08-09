function image2, im, x, y, _extra=e, xlog=xlog, ylog=ylog

sz = (size(im))[1:2]
if (x EQ !null) then x = findgen(sz[0])
if (y EQ !null) then y = findgen(sz[1])
if (xlog EQ !null) then xlog = 0
if (ylog EQ !null) then ylog = 0

p0 = plot(findgen(10), /nodata, xrange=minmax(x), yrange=minmax(y), $
  _extra=e, xlog=xlog, ylog=ylog)

if (keyword_set(e.position)) then begin
  position = e.position
  image_dimensions=[e.position[2]-e.position[0], e.position[3]-e.position[1]] 
endif else begin
  image_dimensions=(size(im))[1:2]
  position = p0.ConvertCoord(min(x), min(y), /data, /to_device)
endelse

;;if ((xlog) or (ylog)) then begin
;;  xx = (x#one(y))[*] 
;;  yy = (one(x)#y)[*]
;;  ff = im[*]
;;
;;  xout = findgen(image_dimensions[0])/(image_dimensions[0]-1)*(max(x)-min(x)) + min(x)
;;  yout = findgen(image_dimensions[1])/(image_dimensions[1]-1)*(max(y)-min(y)) + min(y)
;;  im2 = GridData(xx, yy, ff, /grid, xout=xout, yout=yout)
;;endif
;;
;;p1 = image(im2, /overplot, _extra=e)

p1 = image(im, /current, image_location=[position[0], position[1]], $
  image_dimensions=image_dimensions, _extra=e)
p0.order, /bring_to_front
p0.select

return, [p0, p1]

end

