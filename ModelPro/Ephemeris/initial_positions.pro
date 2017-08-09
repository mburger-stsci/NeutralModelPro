pro initial_positions, input

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Calculates the initial x, y, z, phase of the planet and each satellite.
;;  If satellite motion is included, then it gives the locations of the 
;;  satellites at each time during the simulation
;;
;;  Created 21 May 2013 based on locmoon.pro
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants

nw = n_elements(*stuff.which)
phi = (*input.geometry.phi)[*stuff.which]
objects = (*SystemConsts.objects)[*stuff.which]
a = (*SystemConsts.a)[*stuff.which]
orbrate = (*SystemConsts.orbrate)[*stuff.which]

case (1) of
  (stuff.time_given) and (input.options.motion): begin
    nt = ceil(input.options.endtime/60)+1
    time = dindgen(nt)/(nt-1)*input.options.endtime ;; approx every minute
    t0 = utc2et(input.geometry.time)
    et = t0 - double(time)

    ;; Compute Satellite positions
    x = fltarr(nt,nw) & y = fltarr(nt,nw) & z = fltarr(nt,nw)
    frame = input.geometry.planet + '_Model_Frame'
    for i=1,nw-1 do begin
      relative_position, objects[i], input.geometry.planet, et, frame=frame, position=x0
      x[*,i] = reform(x0[0,*])/SystemConsts.rplan
      y[*,i] = reform(x0[1,*])/SystemConsts.rplan
      z[*,i] = reform(x0[2,*])/SystemConsts.rplan
    endfor
    ang = atan(-x,y)
    ang = (ang + 2*!pi) mod (2*!pi)
    end
  (stuff.time_given) and ~(input.options.motion): begin
    time = 0d
    x = fltarr(nw) & y = fltarr(nw) & z = fltarr(nw)
    et = utc2et(input.geometry.time)
    frame = input.geometry.planet + '_Model_Frame'
    for i=1,nw-1 do begin
      relative_position, objects[i], input.geometry.planet, et, frame=frame, position=x0
      x0 /= SystemConsts.rplan
      x[i] = x0[0] & y[i] = x0[1] & z[i] = x0[2]
    endfor
    ang = atan(-x, y)
    ang = (ang + 2*!pi) mod (2*!pi)
    end
  ~(stuff.time_given) and (input.options.motion): begin
    nt = ceil(input.options.endtime/60)+1
    time = dindgen(nt)/(nt-1)*input.options.endtime ;; approx every minute

    ;Calculate orbital longitude (radians) 
    i = replicate(1d, nt)
    ang = double(-time)#orbrate + i#double(phi)  ;;[n#m + n#m]
    ang = (ang + 2*!pi) mod (2*!pi)

    ;Calculate x and y coordinates
    x = -(i#a) * sin(ang) 
    y = (i#a) * cos(ang)
    z = dblarr(nt,nw)  ;; Assume inclination = 0 
    end
  ~(stuff.time_given) and ~(input.options.motion): begin
    time = 0d
    x = -a*sin(phi)
    y = a*cos(phi)
    z = dblarr(nw)
    ang = phi
    end
endcase

if (nw EQ 1) then begin
  x = x[0]
  y = y[0]
  z = z[0]
  time = time[0]
  phi = phi[0]
endif

positions = {time:ptr_new(time), x:ptr_new(x), y:ptr_new(y), z:ptr_new(z), $
  phi:ptr_new(ang)}

end
