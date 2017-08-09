closewin
sp = ['C', 'Ca+', 'Ca', 'H', 'He', 'K', 'Mg+', 'Mg', 'Mn', 'Na', 'O', 'OH', $
  'S', 'Ti']

tek_color
tvlct, /get, rr, gg, bb

p1 = objarr(n_elements(sp)) & t1 = objarr(n_elements(sp))
p0 = plot(findgen(10), findgen(10), /nodata, xrange=[-15,15], $
  yrange=[1e-5,1e2], /ylog, xtitle='Radial Velocity (km s$^{-1}$)', $
  ytitle='Radiation Acceleration (cm s$^{-2}$)', dimensions=[1000,600], $
  font_size=20, title='Radiation Acceleration at 1 AU')
p0.refresh, /disable
for i=0,n_elements(sp)-1 do begin
  g = get_gvalue(sp[i], 1.)
  p1[i] = plot(/overplot, *g.v, *g.radaccel*1e5, $
    color=[rr[i+2],gg[i+2],bb[i+2]], thick=3)

  q = (i mod 2) ? 0 : -1
  x = q ? 12.5 : -14
  t1[i] = text(x, (*g.radaccel)[q]*1e5, sp[i], font_size=20, $
    color=[rr[i+2],gg[i+2],bb[i+2]], /data)
endfor
p0.refresh

p0.save, 'figures/radaccel.png', dimensions=1000

end
