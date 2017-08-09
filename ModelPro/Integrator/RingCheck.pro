pro RingCheck, input, loc, oldx, ringfrac

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Check to see if hitting Saturn's rings
;;
;; Version History
;;   4.0: 1/31/2012
;;     * created from driver_3.2
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (input.geometry.planet NE 'Saturn') then stop

cross = oldx[*,2] * (*loc.x)[*,2]  ;; if cross is negative, then crossed eq. plane
MayHit = where(cross LE 0 , nmay)
if (nmay NE 0) then begin
  orho = sqrt(total(oldx[MayHit,0:1]^2, 2))
  nrho = sqrt(total((*loc.x)[MayHit,0:1]^2, 2))
  w = where((orho LT 2.3) or (nrho LT 2.3), nw)
  for j=0,nw-1 do begin $
    crosspt = interpol([orho[w[j]],nrho[w[j]]], [oldx[MayHit[w[j]],2], $
      (*loc.x)[MayHit[w[j]],2]], 0.)
    if (crosspt LT 2.3) then begin
      if (input.options.trackloss) then ringfrac[MayHit[w[j]]] += $
	(*loc.frac)[MayHit[w[j]]]
      (*loc.frac)[MayHit[w[j]]] = 0.
    endif
  endfor
endif
stop ;; need to check to make sure this works

end
