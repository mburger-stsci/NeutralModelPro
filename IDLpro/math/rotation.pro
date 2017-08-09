function rotation, vector, ax, theta, R=R

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Rotate a 3-vector an angle theta around the axis ax.
;;
;; Theta is given in radians
;; 
;; Written by Matthew Burger, 4 Feb 2010.
;; Revised 9 March 2010
;; http://en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_given_an_axis_and_an_angle
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

l = ax / sqrt(total(ax^2))
lx = l[0] & ly = l[1] & lz = l[2]
c = cos(theta)
s = sin(theta)

if (theta EQ 0) $
  then R = [[1.,0.,0.], [0.,1.,0.], [0.,0.,1]] $
  else R = transpose([[lx^2 + (1-lx^2)*c, lx*ly*(1-c)-lz*s, lx*lz*(1-c)+ly*s], $
    [lx*ly*(1-c)+lz*s, ly^2 + (1-ly^2)*c, ly*lz*(1-c)-lx*s], $
    [lx*lz*(1-c)-ly*s, ly*lz*(1-c)+lx*s, lz^2 + (1-lz^2)*c]]) 

result = R # vector
return, result

end
