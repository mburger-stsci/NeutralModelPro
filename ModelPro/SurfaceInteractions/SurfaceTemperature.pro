function SurfaceTemperature, geometry, longitude, latitude, t0=t0, t1=t1, n=n, grid=grid

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Estimate the surface temperature of an object as a function of longitude 
;; and latitude
;;
;; Coordinate system depends on the type of object. Will revise as needed.
;;
;; Version history
;;   4.0: 1/31/2012
;;     * Created -- only making Mercury option
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if ((min(longitude) LT 0) or (max(longitude) GT 2*!pi)) then stop
if (grid EQ !null) then grid = 0

case (geometry.startpoint) of 
  'Mercury': begin
    if (t0 EQ !null) then t0 = 100.
    if (t1 EQ !null) then t1 = 600 + 125*(cos(geometry.taa)-1)/2.
    if (n EQ !null) then n = 0.25

    if (grid) then begin
      longrid = longitude # one(latitude)
      Tsurf = double(t0 + (t1*(abs(cos(longitude)#cos(latitude)))^n) * $
	((longrid LE !pi/2) or (longrid GT 3*!pi/2)))
    endif else begin
      if (n_elements(longitude) NE n_elements(latitude)) then stop
      Tsurf = double(t0 + (t1*(abs(cos(longitude)*cos(latitude)))^n) * $
	((longitude LE !pi/2) or (longitude GT 3*!pi/2)))
    endelse
    end
  else: stop
endcase

return, Tsurf

end
