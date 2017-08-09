function SourceRate, sourcemap, peakflux

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Given a sourcemap structure and (optionally) the peak flux, calculates 
;; the total source rate
;;
;; Note - currently assumes that planet = Mercury
;;
;; Version History:
;;   1.0: written 8 Nov 2011
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

if (peakflux EQ !null) $
  then map = *sourcemap.map $ 
  else map = *sourcemap.map/max(*sourcemap.map)*peakflux

dlon = (*sourcemap.longitude)[1]-(*sourcemap.longitude)[0]
dlat = (*sourcemap.latitude)[1]-(*sourcemap.latitude)[0]
dcos = one(*sourcemap.longitude) # cos((*sourcemap.latitude))

sourcerate = total(map*dcos) * (!Mercury.radius*1e5)^2 * dlon * dlat

return, sourcerate

end


