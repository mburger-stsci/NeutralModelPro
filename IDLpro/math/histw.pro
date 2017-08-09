function histw, im, weight, min=mn, max=mx, bin=bb, nbins=nbins, xaxis=xaxis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Compute a weighted histogram 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Do everything in double precision
COMPILE_OPT idl2

sz = size(im)
dow = (n_elements(weight) EQ sz[1]) 

if (n_elements(mn) NE 1) then mn = min(im)
if (n_elements(mx) NE 1) then mx = max(im)
bin = (n_elements(bb) EQ 1) ? bb : 1.
  
result = float(histogram(im, bin=bin, min=mn, max=mx, reverse=rev))

if (dow) then begin
  hist1 = result*0.
  for i=0L,n_elements(result)-1 do if (rev[i] NE rev[i+1]) then $
    hist1[i] = total(weight[rev[rev[i]:rev[i+1]-1]])
  result = hist1
endif
nbins = n_elements(result)
xaxis = findgen(nbins)*bin + mn+bin/2.

return, result

end
