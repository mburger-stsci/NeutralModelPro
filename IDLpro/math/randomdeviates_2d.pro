pro RandomDeviates_2d, fdist, x0, y0, npack, xpts, ypts, seed=seed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Randomly pick points from a 2D probability distribution using the 
;; acceptance/rejection method
;;
;; Inputs: 
;;   fdist: string containing name of probability distribion function
;;   num: number of points to compute
;;
;; Outputs:
;;   x, y
;;
;; Version History
;;   1.0: 11/30/2010
;;     * Created
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mx = [max(x0)-min(x0),min(x0)]
my = [max(y0)-min(y0),min(y0)]
fmax = max(fdist)

sc = fmax*n_elements(fdist)/total(fdist)

maxpack = long(1e5) ;; don't ever pick more than 1e6 points at once
todo = npack
xpts = !null & ypts = !null
while (todo GT 0) do begin
;;  nn = long(min([sc*todo, maxpack]))
  nn = maxpack
  ux = random_nr(nn, seed=seed)*mx[0] + mx[1] 
  uy = random_nr(nn, seed=seed)*my[0] + my[1]
  uf = random_nr(nn, seed=seed)*fmax

  val = interpolate_xy(fdist, x0, y0, ux, uy)
  q = where(uf LT val, nq)
  if (nq NE 0) then begin
    xpts = [xpts, ux[q]] & ypts = [ypts, uy[q]]
  endif
  todo = npack - n_elements(xpts)
endwhile

xpts = xpts[0:npack-1] & ypts = ypts[0:npack-1]

end
