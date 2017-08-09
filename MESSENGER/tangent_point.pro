function tangent_point, data, altitude=altitude, longitude=longitude, $
  latitude=latitude, loctime=loctime

;; Determine Tangent Points
rr = sqrt(*data.x^2 + *data.y^2 + *data.z^2)
costh = (-*data.x**data.xbore - *data.y**data.ybore - $
 *data.z**data.zbore)/rr
;; alt = rr * sin(acos(costh))
t = rr * costh

;; Location of tangent pt over surface
xpt = *data.x + *data.xbore*t 
ypt = *data.y + *data.ybore*t 
zpt = *data.z + *data.zbore*t 

;; temp = *data.xbore*xpt + *data.ybore*ypt + *data.zbore*zpt
altitude = sqrt(xpt^2 + ypt^2 + zpt^2)

case (data.frame) of
  'MSO': begin
    longitude = (atan(ypt,xpt) + 2*!dpi) mod (2*!dpi)
    latitude = asin(zpt/altitude)
    end
  'model': begin
    longitude = (atan(xpt,-ypt) + 2*!dpi) mod (2*!dpi)
    latitude = asin(zpt/altitude)
    end
  else: stop
endcase

loctime = ((longitude+!pi)*24./(2*!pi) + 24) mod 24
points = transpose([[xpt], [ypt], [zpt]])
return, points

end
