pro EscapeCheck, input, loc, tempR, leftfrac

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Check for escape from region of interest
;;
;; Version History
;;   4.0: 1/31/2012
;;     * created from driver_3.2
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants

if (stuff.s NE 0) then stop ;; I think there is a bug
leftCor = where(tempR[*,stuff.s] GT input.options.OuterEdge * $
  (*SystemConsts.radius)[stuff.s], hh)

if (hh NE 0) then begin
  leftfrac[leftcor] += (*loc.frac)[leftcor]
  (*loc.frac)[leftCor] = 0
endif

end
