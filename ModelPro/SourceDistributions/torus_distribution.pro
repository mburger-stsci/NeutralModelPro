pro torus_distribution, geometry, spatialdist, options, seed, startloc=startloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   Distribute packets in a torus centered on the central planet that is longitudinally
;;   symmetric.
;;
;;   Torus equation:
;;     x = (r0 + r1*cos(theta))*cos(phi)
;;     y = (r0 + r1*cos(theta))*sin(phi)
;;     z = r2*sin(theta)
;;
;;   If r2 = 0, then packets are confined to the equatorial plane.
;;
;; Version History
;;   2.0: File created.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

npack = options.packets
phi = random_nr(seed=seed, npack)*2*!pi
theta = random_nr(seed=seed, npack)*2*!pi
r0 = (SpatialDist.torus_radii)[0]
r1 = random_nr(seed=seed, npack)*(SpatialDist.torus_radii)[1]
r2 = random_nr(seed=seed, npack)*(SpatialDist.torus_radii)[2]

*startloc.x = (r0 + r1*cos(theta))*cos(phi)
*startloc.y = (r0 + r1*cos(theta))*sin(phi)
*startloc.z = r2*sin(theta)

*startloc.latitude = theta
*startloc.longitude = phi

end
