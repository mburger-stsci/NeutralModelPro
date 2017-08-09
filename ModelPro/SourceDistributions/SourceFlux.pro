function SourceFlux, sourcemap, sourcerate, map=map

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Given a sourcemap structure and (optionally) the source rate, returns 
;; the peak flux. If sourcerate is not given, assumes = 1e26
;;
;; Note - currently assumes that planet = Mercury
;;
;; Keyword output:
;;   map = re-normalized flux map with maximum=peakflux
;;
;; Version History
;;   1.0: written 8 Nov 2011
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (sourcerate EQ !null) then sourcerate = 1e26

dlon = (*sourcemap.longitude)[1]-(*sourcemap.longitude)[0]
dlat = (*sourcemap.latitude)[1]-(*sourcemap.latitude)[0]
dcos = one(*sourcemap.longitude) # cos(*sourcemap.latitude)

maptotal = total(*sourcemap.map*dcos) * (!Mercury.radius*1e5)^2 * dlon * dlat
map = *sourcemap.map * sourcerate/maptotal
peakflux = max(map)

return, peakflux

end


