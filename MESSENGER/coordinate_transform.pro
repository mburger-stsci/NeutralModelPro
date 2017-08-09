pro MSO_to_modelcoords, data

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MSO -- x points to sun, y points to dusk, z points north
;; model -- x points to dusk, y points anti-sun, z points north
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

xx = *data.y & yy = -*data.x & zz = *data.z
*data.x = xx & *data.y = yy & *data.z = zz

xx = *data.ybore & yy = -*data.xbore & zz = *data.zbore
*data.xbore = xx & *data.ybore = yy & *data.zbore = zz

xx = *data.ycorner & yy = -*data.xcorner & zz = *data.zcorner
*data.xcorner = xx & *data.ycorner = yy & *data.zcorner = zz

xx = *data.ytan & yy = -*data.xtan & zz = *data.ztan
*data.xtan = xx & *data.ytan = yy & *data.ztan = zz

data.frame = 'model'

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro modelcoords_to_MSO, data

xx = -*data.y & yy = *data.x & zz = *data.z
*data.x = xx & *data.y = yy & *data.z = zz

xx = -*data.ybore & yy = *data.xbore & zz = *data.zbore
*data.xbore = xx & *data.ybore = yy & *data.zbore = zz

xx = -*data.ycorner & yy = *data.xcorner & zz = *data.zcorner
*data.xcorner = xx & *data.ycorner = yy & *data.zcorner = zz

xx = -*data.ytan & yy = *data.xtan & zz = *data.ztan
*data.xtan = xx & *data.ytan = yy & *data.ztan = zz

data.frame = 'MSO'

end
