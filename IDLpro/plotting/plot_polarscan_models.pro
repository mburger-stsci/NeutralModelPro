function plot_polarscan_models, data0, models0, filename=filename

onum = (*data0.orbit)[0]

if (models0 EQ !null) $
  then nmod = 0 $
  else begin
    sz = size(models0)
    nmod = (sz[0] EQ 1) ? 1 : sz[2]
  endelse

use = where(stregex(*data0.obstype, 'polar', /fold, /bool) and $
  (*data0.radiance GT 0), nuse)
if (nuse EQ 0) then stop
data = data_extract(data0, use)
if (nmod GT 0) then models = models0[use,*]

alt = (*data.rtan-1)*!mercury.radius
lat = reform((*data.lattan)[0,*])

;; Determine which plots to do
np = where(lat GT 50*!dtor, nnp)
sp = where(lat LT -50*!dtor, nsp)

donorth = (nnp GT 1)
dosouth = (nsp GT 1)

yr0 = plot_range(*data.radiance, /log)

case (1) of
  donorth and dosouth: begin
    p0 = plot(alt[np], (*data.radiance)[np], linestyle=' ', color='magenta', $
      symbol='o', /sym_filled, dimensions=[1600,800], layout=[2,1,1], $
      buffer=(filename NE !null), title=orbit_string(onum)+', North Pole Scan', $
      xtitle='Altitude (km)', ytitle='Radiance (kR)', font_size=20, xrange=[0,2000], $
      /ylog, yrange=yr0, margin=[.15,.15,.1,.1])
    p0.refresh, /disable
    w = where((*data.quality)[np] EQ 1, nw)
    if (nw GT 0) then p0a = plot(alt[np[w]], (*data.radiance)[np[w]], linestyle=' ', $
      color='yellow', symbol='o', /sym_filled, /overplot)
    w = where((*data.quality)[np] EQ 3, nw)
    if (nw GT 0) then p0a = plot(alt[np[w]], (*data.radiance)[np[w]], linestyle=' ', $
      color='cyan', symbol='o', /sym_filled, /overplot)
    w = where((*data.quality)[np] EQ 0, nw)
    if (nw GT 0) then p0 = errorplot(alt[np[w]], (*data.radiance)[np[w]], $
      (*data.sigma)[np[w]], linestyle=' ', symbol='o', /sym_filled, /overplot)
    for i=0,nmod-1 do o0 = plot(/overplot, alt[np], models[np,i], color=color(i+2), $
      thick=3)

    p1 = plot(alt[sp], (*data.radiance)[sp], linestyle=' ', color='magenta', $
      symbol='o', /sym_filled, /current, layout=[2,1,2], font_size=20, $
      title=orbit_string(onum) + ', South Pole Scan', xtitle='Altitude', $
      ytitle='Radiance (kR)', xrange=[0,2000], /ylog, yrange=yr0, margin=[.15,.15,.1,.1])
    w = where((*data.quality)[sp] EQ 1, nw)
    if (nw GT 0) then p0a = plot(alt[sp[w]], (*data.radiance)[sp[w]], linestyle=' ', $
      color='yellow', symbol='o', /sym_filled, /overplot)
    w = where((*data.quality)[sp] EQ 0, nw)
    if (nw GT 0) then p0 = errorplot(alt[sp[w]], (*data.radiance)[sp[w]], $
      (*data.sigma)[sp[w]], linestyle=' ', symbol='o', /sym_filled, /overplot)
    for i=0,nmod-1 do o0 = plot(/overplot, alt[sp], models[sp,i], color=color(i+2), $
      thick=3)
    p0.refresh
    end
  donorth and ~dosouth: begin
    p0 = plot(alt[np], (*data.radiance)[np], color='magenta', linestyle=' ', $
      symbol='o', /sym_filled, dimensions=[800,800], $
      buffer=(filename NE !null), title=orbit_string(onum)+', North Pole Scan', $
      xtitle='Altitude (km)', ytitle='Radiance (kR)', font_size=20, xrange=[0,2000], $
      /ylog, yrange=yr0)
    p0.refresh, /disable
    w = where((*data.quality)[np] EQ 1, nw)
    if (nw GT 0) then p0a = plot(alt[np[w]], (*data.radiance)[np[w]], linestyle=' ', $
      color='yellow', symbol='o', /sym_filled, /overplot)
    w = where((*data.quality)[np] EQ 0, nw)
    if (nw GT 0) then p0 = errorplot(alt[np[w]], (*data.radiance)[np[w]], $
      (*data.sigma)[np[w]], linestyle=' ', symbol='o', /sym_filled, /overplot)
    for i=0,nmod-1 do o0 = plot(/overplot, alt[np], models[np,i], color=color(i+2), $
      thick=3)
    p0.refresh
    end
  ~donorth and dosouth:begin
    p0 = plot(alt[sp], (*data.radiance)[sp], color='magenta', linestyle=' ', $
      symbol='o', /sym_filled, dimensions=[800,800], $
      buffer=(filename NE !null), title=orbit_string(onum)+', South Pole Scan', $
      xtitle='Altitude (km)', ytitle='Radiance (kR)', font_size=20, xrange=[0,2000], $
      /ylog, yrange=yr0)
    p0.refresh, /disable
    w = where((*data.quality)[sp] EQ 1, nw)
    if (nw GT 0) then p0a = plot(alt[sp[w]], (*data.radiance)[sp[w]], linestyle=' ', $
      color='yellow', symbol='o', /sym_filled, /overplot)
    w = where((*data.quality)[sp] EQ 0, nw)
    if (nw GT 0) then p0 = errorplot(alt[sp[w]], (*data.radiance)[sp[w]], $
      (*data.sigma)[sp[w]], linestyle=' ', symbol='o', /sym_filled, /overplot)
    for i=0,nmod-1 do o0 = plot(/overplot, alt[sp], models[sp,i], color=color(i+2), $
      thick=3)
    p0.refresh
    end
endcase

if (filename NE !null) then begin
  p0.save, filename, width=WindowWidth(p0[0])
  p0.close
endif

return, p0

end
