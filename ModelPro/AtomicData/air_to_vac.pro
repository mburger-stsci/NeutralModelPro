function vac_to_air, lambda

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Vaccuum wavelength to air wavelength. Wavelengths in Angstroms.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

return, lambda / (1.0 + 2.735182E-4 + 131.4182/lambda^2 + 2.76249E8/lambda^4)

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function air_to_vac, lambda

return, lambda * (1.0 + 2.735182E-4 + 131.4182/lambda^2 + 2.76249E8/lambda^4)

end

