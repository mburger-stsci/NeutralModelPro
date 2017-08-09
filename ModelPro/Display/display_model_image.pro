function display_model_image, result, savefile, brange=brange, log=log, _extra=e

if (n_elements(brange) NE 2) then $
  brange = minmax((*result.image)[where(*result.image NE 0)])
if (log EQ !null) then log = 0

xcyc, xc, yc

etags = (e NE !null) ? tag_names(e) : ''
rgb = (total(strcmp(etags, 'rgb_table', /fold))) ? e.rgb_table : 3
title = (total(strcmp(etags, 'title', /fold))) ? e.title : 'Image'
xtitle = (total(strcmp(etags, 'xtitle', /fold))) ? e.xtitle : 'Distance'
ytitle = (total(strcmp(etags, 'ytitle', /fold))) ? e.ytitle : 'Distance'
ztitle = (total(strcmp(etags, 'ztitle', /fold))) ? e.ztitle : 'Intensity'

if (log) $
  then im = bytscl(alog10(*result.image), alog10(brange[0]), alog10(brange[1])) $
  else im = bytscl(*result.image, brange[0], brange[1])

pp = image2(im, *result.xaxis, *result.zaxis, rgb_table=rgb, $
  dimensions=[800,600], location=[0,0], $
  position=[120,100,520,500], /dev, $
  font_size=20, title=title, xtitle=xtitle, ytitle=ytitle)
pp[0].refresh, /disable
p1 = plot(/overplot, xc, yc, thick=3, color='blue')
p2 = plotsquare2(minmax(*result.xaxis), minmax(*result.zaxis), thick=3)

pos = [550,140,600,460] 
cb = colorbar2(pos, brange, log=log, rgb_table=rgb, thick=2, font_size=20, $
  title=ztitle)
pp[0].refresh

if (savefile NE !null) then pp[0].save, savefile, width=800
pp = [pp, p1, p2, cb]

return, pp

end
