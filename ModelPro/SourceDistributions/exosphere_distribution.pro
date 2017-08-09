pro exosphere_distribution, input, output, npack, seed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   Distribute packets from a spherically symmetric exosphere
;;     f(r) = r^b 
;;   or 
;;     f(r) = exp(-r/h) 
;;
;; Version History
;;   2.1: 20 November 2009
;;     * Added option to prevent packet creation in planet's geometric shadow
;;     * Added option to choose between specifying a scale height or a powerlaw exponent
;;   2.0: File created
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

stop
todo = lindgen(npack)
SpatialDist = input.SpatialDist

;; Set the angular distribution
ll = !dpi*dindgen(1001)/1000. - !dpi/2.
f_lat = cos(ll)

r = findgen(10001)/100.+1
r = r[where(r LE SpatialDist.rmax)]
case (SpatialDist.exotype) of
  'powerlaw': f_r = r^SpatialDist.b 
  'exponential': f_r = exp(-(r-1)/SpatialDist.b)
endcase
f_r[0] = 0. ;; Don't allow packets to start right at the surface

*output.x0 = dblarr(npack)
*output.y0 = dblarr(npack)
*output.z0 = dblarr(npack)
while (npack GT 0) do begin
  lat = MonteCarloDistribution(ll, f_lat, npack)
  lon = 2*!dpi * random_nr(seed=seed, npack) 

  rr = MonteCarloDistribution(r, f_r, npack)
  q = where(rr LT 1. or rr GT SpatialDist.rmax, nq) 
  while (nq NE 0) do begin
    w = MonteCarloDistribution(r, f_r, nq)
    rr[q] = w
    q = where(rr LT 1. or rr GT SpatialDist.rmax, nq) 
  endwhile

  if strcmp(input.geometry.planet, input.geometry.StartPoint, /fold) then begin
    ;; Starting at a planet
    (*output.x0)[todo] = double(rr * sin(lon)*cos(lat)) ;; longitude = 0 => -yaxis
    (*output.y0)[todo] = -double(rr * cos(lon)*cos(lat)) ;; longitude = 90 => axis
    (*output.z0)[todo] = double(rr * sin(lat))
  endif else begin
    ;; Starting at a satellite
    (*output.x0)[todo] = -double(rr * sin(lon)*cos(lat)) ;; longitude = 0 => -yaxis
    (*output.y0)[todo] = -double(rr * cos(lon)*cos(lat)) ;; longitude = 90 => axis
    (*output.z0)[todo] = double(rr * sin(lat))
  endelse

  rho = *output.x0^2 + *output.z0^2

  ;; not working right if block_shadow and starting at a satellite 
  if (spatialdist.block_shadow) and ~(strcmp(input.geometry.planet, $
    input.geometry.StartPoint, /fold)) then stop 

  if (spatialdist.block_shadow) $
    then todo = where((rho LE 1) and (*output.y0 GT 0), npack) $
    else npack = 0
endwhile

end

