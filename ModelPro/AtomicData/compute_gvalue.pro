function compute_gvalue, species, rsun

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Computes the g-vaules from the atomic data
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;   3: begin  ;; SO2 set up -- photo-dissociative excitation
;;      a = 1.
;;      filest = path + species[i] + '/' + species[i] + '.Huebner1992.'
;;      reference = 'Hubener et al. 1992 + a guess'
;;      v = [-15., 0, 15]
;;      lambda = [1304, 1356, 1479] & nl = n_elements(lambda)
;;      g0 = [1., 1., 1.]*1.59e-4 * 0.1
;;      g1 = [1., 1., 1.]*1.59e-4 * 0.1
;;      g2 = [1., 1., 1.]*5.09e-5 * 0.2
;;      g = [[g0], [g1], [g2]]
;;      end
;;

if (rsun EQ !null) then rsun = 1.

file = !model.basepath + 'Data/PhysicalData/EinsteinA.dat'
if ~(file_test(file)) then stop

;; Load the constants for the lines
readcol, file, sp, lam, A, g1, g2, delim=':', /silent, skip=1, format='A,F,F,F,F'

sp = strtrim(sp, 2)
q = where(sp EQ species, nq)
if (nq EQ 0) then stop

sp = sp[q] & lam = lam[q] & A = A[q] & g1 = g1[q] & g2 = g2[q]

vv = findgen(61)/2-15.  ;; km/s
gg = fltarr(n_elements(vv), nq)

for i=0,nq-1 do begin
  ;; Load the solar spectrum & determine vrel
  spec = load_solar_spectrum([lam[i]-1,lam[i]+1])

  lambda = spec[*,0]
  flux = spec[*,1]*1e8
  vrel =  (lam[i]-lambda)/lam[i] * !physconst.c / 1e5 ;; vrel in km/s

  ff = interpol(flux, vrel, vv)
  ll = interpol(lambda, vrel, vv)*1e-8

  ;; Compute g
  gg[*,i] = ff * ll^4/!physconst.c/8./!dpi * A[i] * (g2[i]/g1[i]) / rsun^2

;  plot, vv, gg[*,i], /xst
;  oplot, [0,0], [0,1e30], color=2
;  stop
endfor

;; Compute radiation acceleration
rr = !physconst.h/atomicmass(species)/lam*1e-8
qq = 0.
for i=0,nq-1 do qq += rr[i]*gg[*,i]*1e-5  ;; km s^-2

gvalue = {species:species, a:rsun, wavelength:ptr_new(lam), v:ptr_new(vv), $
  g:ptr_new(gg), radaccel:ptr_new(radaccel)}

return, gvalue

end
