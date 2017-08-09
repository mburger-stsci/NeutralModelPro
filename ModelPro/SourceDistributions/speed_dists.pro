function gaussiandist, velocity, vprob, sigma

;; Velocity, vprob, sigma must be in the same units.
f_v = exp(-(velocity-vprob)^2/2./sigma^2)
return, f_v

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function dolsdist, velocity, dols0, dols1, atom

;; Velocity must be in km/s
;; dols0 and dols1 are in eV, basically.

tt = .5*atomicmass(atom)*(velocity*1e5)^2/!physconst.erg_eV
f_v = (velocity*1e5) * exp(-(tt-dols0)^2/dols1^2)
f_v /= max(f_v)
return, f_v

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function sputdist, velocity, U, alpha, bet, atom, v_b=v_b

;; Generic sputtering distribution
;; See helpwiki for explanation

matom = atomicmass(atom)
vb = sqrt(2*U*!physconst.erg_eV/matom)/1e5
f_v = velocity^(2*bet+1) / (velocity^2 + vb^2)^alpha
return, f_v

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function MaxwellianDist, velocity, temperature, atom

;; Velocity must be in km/s
;; Temperature in K

v_th2 = 2*temperature*!physconst.kb/atomicmass(atom)/1e10
f_v = velocity^3 * exp(-velocity^2/v_th2) 
return, f_v

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function WeibullDist, velocity, temperature, alpha, atom

v_th = sqrt(2*temperature*!physconst.kb/atomicmass(atom))/1e5
f_v = velocity^(alpha-1) * exp(-(velocity/v_th)^alpha)
return, f_v

end

