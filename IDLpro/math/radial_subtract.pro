function radial_subtract, im, cent=cent, phi=phi, bin=bin, sig=sig

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  * Function returns the radially averaged profile of a 2D image.
;;
;;  INPUTS:
;;    * im: image to work with
;;    * cent: the center of the image in pixels.  The radial averaging is
;;        computed relative to this point.  [default: center pixel]
;;    * phi: angle range to sum over in degress measured clockwise from up.
;;        [default = [0,360]]
;;    * bin: number of pixels to bin in width [default = 1]
;;
;;  OUTPUT:
;;    * sig: uncertainty in the returned profile
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

if (n_elements(phi) NE 2) then phi = [0,360]

;; bin = binsize in pixels
if (n_elements(bin) EQ 0) then bin = 1

sz = size(im)

;;if (n_elements(cent) NE 2) then begin
;;  m = 0
;;  x = findgen(sz[1]) 
;;  for i=0,sz[1]-1 do m = m + x[i] * total(im[i,*])
;;  xcent = m / total(im)
;;  m = 0
;;  for i=0,sz[1]-1 do m = m + x[i] * total(im[*,i])
;;  ycent = m / total(im)
;;  cent = [xcent, ycent]
;;endif
if (n_elements(cent) NE 2) then cent = [sz[1]-1,sz[2]-1]/2.

nums = findgen(sz[1],sz[2])
rad = sqrt( ((nums mod sz[1])-cent[0])^2 + (nums/sz[1]-cent[1])^2 )/bin
ang = atan( (nums mod sz[1])-cent[0], nums/sz[1]-cent[1] )
ang = (ang/!dtor + 360) mod 360

prof = fltarr(max(round(rad)))
sig = fltarr(max(round(rad)))
for i=0,n_elements(prof)-1 do begin
  if (phi[1] GT phi[0]) $ 
    then q = where((rad GE i-.5) and (rad LT i+.5) and $
      (ang GE phi[0]) and (ang LE phi[1]), npts) $
    else q = where((rad GE i-.5) and (rad LT i+.5) and $
      ((ang GE phi[0]) or (ang LE phi[1])), npts)
  if (npts GT 1) then begin 
    prof[i] = mean(im[q])
    sig[i] = stddev(im[q])/sqrt(npts)
;;    plots, q mod sz[1], q/sz[1], psym=3, color=0, /device
  endif
endfor

return, prof

end
