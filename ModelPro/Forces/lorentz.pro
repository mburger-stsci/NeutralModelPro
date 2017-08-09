function Lorentz, loc, input

common constants

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Compute the Lorentz force on an ion
;;
;;  Assumes the dipole is aligned north-south
;;  Need to add options for an input field model
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

qm = 1 ;atomiccharge(options.atom)/atomicmass(options.atom)

;;Bfield = DetermineBField(loc, input)

r = sqrt(total(*loc.x^2, 2))
x = (*loc.x)[*,0]
y = (*loc.x)[*,1]
z = (*loc.x)[*,2]

;; Field strength in Gauss
;;Bx = 3*x*z*DipoleConsts.strength*r^(-5)
;;By = 3*y*z*DipoleConsts.strength*r^(-5)
;;Bz = (3*z^2-r^2)*DipoleConsts.strength*r^(-5)
Bx = fltarr(n_elements(r))
By = fltarr(n_elements(r))
Bz = replicate(.05, n_elements(r))

;; Determine speed of ion relative to magnetic field
;;Bvx = -DipoleConsts.magrat * y
;;Bvy = DipoleConsts.magrat * x
;;vx = ((*loc.v)[*,0]-Bvx)/!physconst.c
;;vy = ((*loc.v)[*,1]-Bvy )/!physconst.c
;;vz = (*loc.v)[*,2]/!physconst.c
vx = (*loc.v)[*,0]*SystemConsts.rplan
vy = (*loc.v)[*,1]*SystemConsts.rplan
vz = (*loc.v)[*,2]*SystemConsts.rplan

;; Electric field
;;Ex = 0. & Ey = 0. & Ez = 0.
Ex = replicate(1, n_elements(r))
Ey = fltarr(n_elements(r))
Ez = fltarr(n_elements(r))

ax = qm * (Ex + vy*Bz - vz*By)
ay = qm * (Ey + vz*Bx - vx*Bz)
az = qm * (Ez + vx*By - vy*Bx)

accel = dblarr(n_elements(x),3)
accel[*,0] = ax/SystemConsts.rplan
accel[*,1] = ay/SystemConsts.rplan
accel[*,2] = az/SystemConsts.rplan

return, accel

end
