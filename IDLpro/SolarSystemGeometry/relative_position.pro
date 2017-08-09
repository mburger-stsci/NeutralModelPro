pro relative_position, object, reference, param0, param1, param2, abcor=abcor, $
  position=position, frame=frame, velocity=velocity, time=et

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Determine the relative position of object to reference
;;  This is basically a rewrite of cspice_spkezr without having to remember
;;  all the options to set
;;
;;  Output: 
;;    pos = position in km
;;    vel = velocity in km/s
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (n_elements(frame) EQ 0) then Frame = 'J2000'

objnum = strtrim(string(naif_ids(object)), 2)
refnum = strtrim(string(naif_ids(reference)), 2)

case (n_params()) of 
  5: begin
     et0 = (size(param0, /type) EQ 7) ? utc2et(param0) : param0
     et1 = (size(param1, /type) EQ 7) ? utc2et(param1) : param1
     deltat = param2
 
     num = long((et1-et0)/deltat)
     et = et0 + findgen(num)*deltat
     end
  3: et = (size(param0, /type) EQ 7) ? utc2et(param0) : param0
  else: stop
endcase

if (abcor EQ !null) then abcor = 'LT+S'
cspice_spkezr, objnum, et, Frame, abcor, refnum, pos, ltime

position = pos[0:2,*]
velocity = pos[3:5,*]

end
