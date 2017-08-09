function rotationmatrix, vec1, vec2, axis=axis, angle=angle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Given two vectors, determine the rotation matrix that transforms
;; from vector 1 to vector 2
;;
;; Written 25 Jan 2011
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

axis = crossp(vec1, vec2)
angle = acos(total(vec1*vec2)/sqrt(total(vec1^2))/sqrt(total(vec2^2)))
p2 = rotation(vec1, axis, angle, R=R)

if (max(abs(crossp(p2, vec2))) GT 1e-6) then stop

return, R

end

