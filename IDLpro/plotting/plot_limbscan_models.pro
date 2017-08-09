function plot_limbscan_models, data0, models, filename=filename, $
  ystyle=yst, title=title

if (title EQ !null) then title = ''

onum = (*data0.orbit)[0]
if (yst EQ !null) then yst=0

if (models EQ !null) $
  then nmod = 0 $
  else begin
    sz = size(models)
    nmod = (sz[0] EQ 1) ? 1 : sz[2]
  endelse

use = where(stregex(*data0.obstype, 'dayside', /fold, /bool), nuse)
data = data_extract(data0, use)

tanpt = tangent_point(data, lon=lon, lat=lat, loctime=loctime)
hr = round(loctime)
alt = (*data.rtan-1)*!mercury.radius

hours = hr[uniq(hr, sort(hr))]
nhrs = n_elements(hours)
case (nhrs) of
  1: layout = [1,1]
  2: layout = [2,1]
  3: layout = [3,1]
  4: layout = [2,2]
  5: layout = [3,2]
  6: layout = [3,2]
  7: layout = [3,3]
  8: layout = [3,3]
  9: layout = [3,3]
  10: layout = [4,3]
  11: layout = [4,3]
  12: layout = [4,3]
  13: layout = [4,4]
  else: stop
endcase

p0 = objarr(nhrs)
if (nmod GT 0) then o0 = objarr(nhrs,nmod)

temp = (nmod EQ 0) ? *data.radiance : [*data.radiance, models[*]]
temp = temp[where(temp GT 0)]
;;yr0 = plot_range(temp, /log)
yr0 = [0.1, round(max(temp)*2)]
yr1 = plot_range(temp)

for i=0,nhrs-1 do begin
  q = where(hr EQ hours[i])
  s = sort(alt[q])
  q = q[s]
  case (yst) of
    0: begin
       yr = yr0
       log = 1
       end
    1: begin
       yr = yr1
       log = 0
       end
    2: begin
       yr = plot_range((*data.radiance)[q], /log)
       log = 1
       end
    3: begin
       yr = plot_range((*data.radiance)[q])
       log = 0
       end
    else: stop
  endcase

  p0[i] = plot(alt[q], (*data.radiance)[q], symbol='o', $
    /sym_filled, linestyle=' ', xrange=[0,3000], $
    layout=[layout,i+1], current=(i NE 0), dimensions=[1600,1200], font_size=16, $
    ylog=log, yrange=yr, title='hr ' + strint(hours[i]), location=[100,0], $
    buffer=(filename NE !null), color='magenta', xtitle='Altitude (km)', $
    ytitle='Radiance (kR)')
  w = where((*data.quality)[q] EQ 1, nw)
  if (nw GT 0) then p0a = plot(/overplot, alt[q[w]], (*data.radiance)[q[w]], symbol='o', $
    /sym_filled, linestyle=' ', color='yellow')
  w = where((*data.quality)[q] EQ 3, nw)
  if (nw GT 0) then p0a = plot(/overplot, alt[q[w]], (*data.radiance)[q[w]], symbol='o', $
    /sym_filled, linestyle=' ', color='cyan')
  w = where((*data.quality)[q] EQ 0, nw)
  if (nw GT 0) then p4 = errorplot(alt[q[w]], (*data.radiance)[q[w]], $
    (*data.sigma)[q[w]], symbol='o', linestyle=' ', /sym_filled, /overplot)
  if (i EQ 0) then p0[i].refresh, /disable

  for j=0,nmod-1 do o0[i,j] = plot(/overplot, alt[q], models[use[q],j], thick=3, $
    color=color(j+2))
endfor
;t0 = text(.5, .98, /normal, align=.5, font_size=20, orbit_string(onum)+', '+title)
;;for i=0,nmod-1 do t1 = text(.65, .35-0.03*i, ff[i], /normal, $
;;  color=color(i+2), font_size=16)

l0 = text(/device, 20, 1160, font_size=20, title)

p0[0].refresh

if (filename NE !null) then begin
  p0[0].save, filename, width=WindowWidth(p0[0])
  p0[0].close
endif

return, p0

end
