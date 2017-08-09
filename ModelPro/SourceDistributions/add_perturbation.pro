pro add_perturbation, input, output, seed=seed

common constants

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Adds a perturbation to a pre-existing velocity distribution
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

npack = n_elements(*output.x0)
PerturbVel = input.PerturbVel
case (PerturbVel.type) of 
  'none': 
  'gaussian': if (PerturbVel.sigma EQ 0.) $
    then vperturb = replicate(PerturbVel.vprob, npack) $
    else vperturb = RandomGaussian(npack, PerturbVel.vprob, PerturbVel.sigma)
  'maxwellian': begin
    v_th = sqrt(2*PertrubVel.temperature*!physconst.kb/atomicmass(input.options.atom)) $
      /1e5
    velocity = findgen(1001)/1000 * v_th*5 & velocity = velocity[1:*]
    f_v = MaxwellianDist(velocity, PerturbVel.temperature, input.options.atom)
    vperturb = RandomDeviates_1d(velocity, f_v, npack)   ;; km/s
    end
  else: stop
endcase
vperturb /= SystemConsts.rplan
  
;; Assume isotropic perturbation
;; Choose the altitude -- f(alt) = cos(alt) 
sinalt = random_nr(seed=seed, npack)*2-1
alt = asin(sinalt)

;; Choose the azimuth
az = random_nr(seed=seed, npack)*2*!pi

v_north = sin(alt)
v_corot = -cos(alt) * cos(az)
v_rad = cos(alt) * sin(az)

vxperturb = v_rad * vperturb
vyperturb = v_corot * vperturb
vzperturb = v_north * vperturb

q = where(finite(v_north) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(v_corot) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(v_rad) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(vxperturb) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(vyperturb) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(vzperturb) EQ 0, nq) & if (nq NE 0) then stop

;; Starting velocity
*output.vx0 += vxperturb
*output.vy0 += vyperturb
*output.vz0 += vzperturb

end
