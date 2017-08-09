function solidangle, a, b, c

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Given three vectors a, b, and c, this calculates the solid angle
;; subtended
;;
;; Reference: http://en.wikipedia.org/wiki/Solid_angle
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

a0 = a/sqrt(total(a^2))
b0 = b/sqrt(total(b^2))
c0 = c/sqrt(total(c^2))

q0 = abs(total(a0*crossp(b0,c0)))
q1 = 1 + total(a0*b0) + total(b0*c0) + total(a0*c0)
omega0 = atan(q0, q1)
if (omega0 LT 0) then omega0 += !pi

return, omega0*2.

end
